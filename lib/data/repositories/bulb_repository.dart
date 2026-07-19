// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import '../models/bulb.dart';
import '../models/bulb_command.dart';
import '../models/bulb_event.dart';
import '../models/bulb_state.dart';
import '../services/bulb_store.dart';
import '../services/discovery.dart';
import '../services/wiz_protocol.dart';
import '../../domain/models/bulb_limits.dart';
import '../../domain/models/bulb_type.dart';
import '../../domain/models/rgbcw_converter.dart';

class BulbRepository {
  final WizProtocol _proto;
  final Discovery _discovery;
  final BulbStore _store;
  StreamSubscription<BulbEvent>? _eventSub;
  Timer? _pollTimer;
  List<Bulb> _bulbs = [];
  bool _isScanning = false;
  Map<String, Bulb> _saved = {};
  final Map<String, ({BulbCommand command, DateTime timestamp})> _pendingCommands = {};
  final Set<String> _commandFailed = {};
  final Set<String> _interactingBulbIds = {};
  final List<void Function()> _listeners = [];
  final Duration _backgroundThreshold;
  DateTime? _backgroundedAt;
  bool _isReconnecting = false;

  BulbRepository({
    required WizProtocol proto,
    required Discovery discovery,
    required BulbStore store,
    Duration backgroundThreshold = const Duration(minutes: 2),
  })  : _proto = proto,
        _discovery = discovery,
        _store = store,
        _backgroundThreshold = backgroundThreshold;

  void addListener(void Function() callback) {
    _listeners.add(callback);
  }

  void removeListener(void Function() callback) {
    _listeners.remove(callback);
  }

  void _notifyListeners() {
    for (final cb in _listeners) {
      cb();
    }
  }

  bool _initialized = false;

  List<Bulb> get bulbs => _bulbs;
  bool get isScanning => _isScanning;
  bool get isReconnecting => _isReconnecting;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _saved = await _store.loadBulbs();
    _bulbs = _saved.values
        .map((b) => b.copyWith(isOnline: false))
        .toList();
    _eventSub = _proto.events.listen(_handleEvent);
    _notifyListeners();
  }

  Future<void> startupFetch() async {
    if (_bulbs.isEmpty) return;

    final results = await Future.wait(
      _bulbs.map((bulb) async {
        try {
          final state = await _proto.getPilotState(bulb).timeout(
            const Duration(seconds: 3),
          );
          if (state != null) {
            final updated = bulb.copyWith(
              isOnline: true,
              state: BulbState.fromMap(
                _stateToMap(state),
                previous: bulb.state,
              ),
              lastSeen: DateTime.now(),
            );
            return await _fetchKelvinRange(updated);
          } else {
            return bulb.copyWith(isOnline: false);
          }
        } catch (_) {
          return bulb.copyWith(isOnline: false);
        }
      }),
    );

    _bulbs = results;
    final anyOnline = _bulbs.any((b) => b.isOnline);
    if (!anyOnline) {
      await scan();
    } else {
      for (final bulb in _bulbs.where((b) => b.isOnline)) {
        _proto.register(bulb.ip);
      }
      await _store.saveAll(_bulbs.where((b) => b.mac != null));
      _startPolling();
    }
    _notifyListeners();
  }

  void _handleEvent(BulbEvent event) {
    final idx = _bulbs.indexWhere((b) => b.ip.address == event.ip.address);
    if (idx == -1) return;

    if (_interactingBulbIds.contains(_bulbs[idx].id)) return;

    final now = DateTime.now();
    switch (event) {
      case StateUpdate(:final state):
        _bulbs[idx] = _bulbs[idx].copyWith(
          state: BulbState.fromMap(
            _stateToMap(state),
            previous: _bulbs[idx].state,
          ),
          lastSeen: now,
        );
        _checkCommandFailed(_bulbs[idx], _bulbs[idx].state ?? const BulbState());
        _notifyListeners();
      case Registration(:final mac, :final model, :final firmware):
        _bulbs[idx] = _bulbs[idx].copyWith(
          mac: mac,
          model: model ?? _bulbs[idx].model,
          firmware: firmware ?? _bulbs[idx].firmware,
          lastSeen: now,
        );
        _notifyListeners();
      case SyncPilot(:final state):
        _bulbs[idx] = _bulbs[idx].copyWith(
          state: BulbState.fromMap(
            _stateToMap(state),
            previous: _bulbs[idx].state,
          ),
          lastSeen: now,
        );
        _checkCommandFailed(_bulbs[idx], _bulbs[idx].state ?? const BulbState());
        _notifyListeners();
    }
  }

  Map<String, dynamic> _stateToMap(BulbState state) {
    return {
      'state': state.on,
      if (state.r != null) 'r': state.r,
      if (state.g != null) 'g': state.g,
      if (state.b != null) 'b': state.b,
      if (state.c != null) 'c': state.c,
      if (state.w != null) 'w': state.w,
      if (state.temp != null) 'temp': state.temp,
      if (state.dimming != null) 'dimming': state.dimming,
      if (state.sceneId != null) 'sceneId': state.sceneId,
      if (state.speed != null) 'speed': state.speed,
      if (state.rssi != null) 'rssi': state.rssi,
    };
  }

  Future<Bulb> _fetchKelvinRange(Bulb bulb) async {
    var updated = bulb;
    try {
      final config = await _proto.getModelConfig(bulb.ip).timeout(
        const Duration(seconds: 2),
      );
      if (config != null) {
        final cctRange = config['cctRange'];
        if (cctRange is List && cctRange.length >= 4) {
          final min = (cctRange[0] as num).toInt();
          final max = (cctRange[3] as num).toInt();
          if (min > 0 && max > min) {
            updated = updated.copyWith(kelvinMin: min, kelvinMax: max);
          }
        }
      }
    } catch (_) {}
    final bulbClass = BulbTypeDetector.detectFromModuleName(updated.model);
    return updated.copyWith(bulbClass: bulbClass);
  }

  Future<void> scan() async {
    if (_isScanning) return;
    _isScanning = true;
    _notifyListeners();

    try {
      final found = await _discovery.discover();
      if (found.isEmpty) {
        final subnetResults = await _discovery.scanSubnet();
        _reconcile(subnetResults);
      } else {
        _reconcile(found);
      }
      await _store.saveAll(_bulbs.where((b) => b.mac != null));
      _saved = await _store.loadBulbs();
      for (final bulb in _bulbs.where((b) => b.isOnline)) {
        _proto.register(bulb.ip);
      }
      _notifyListeners();
      for (final bulb in _bulbs.where((b) => b.isOnline)) {
        final state = await _proto.getPilotState(bulb);
        if (state != null) {
          final idx = _bulbs.indexWhere((b) => b.id == bulb.id);
          if (idx != -1) {
            final withState = _bulbs[idx].copyWith(
              state: BulbState.fromMap(
                _stateToMap(state),
                previous: _bulbs[idx].state,
              ),
            );
            final withKelvin = await _fetchKelvinRange(withState);
            _bulbs[idx] = withKelvin;
            _notifyListeners();
          }
        }
      }
      await _store.saveAll(_bulbs.where((b) => b.mac != null));
      _startPolling();
    } finally {
      _isScanning = false;
      _notifyListeners();
    }
  }

  void _reconcile(List<Bulb> foundBulbs) {
    final now = DateTime.now();
    final foundByMac = <String, Bulb>{};
    for (final b in foundBulbs) {
      if (b.mac != null) foundByMac[b.mac!] = b;
    }

    final merged = <Bulb>[];
    final seen = <String>{};

    for (final entry in foundByMac.entries) {
      final mac = entry.key;
      final found = entry.value;
      seen.add(mac);
      final savedBulb = _saved[mac];
      if (savedBulb != null) {
        merged.add(savedBulb.copyWith(
          isOnline: true,
          ip: found.ip,
          model: found.model,
          firmware: found.firmware,
          lastSeenIp: found.ip.address,
          lastSeen: now,
        ));
      } else {
        merged.add(found.copyWith(lastSeen: now));
      }
    }

    for (final entry in _saved.entries) {
      if (!seen.contains(entry.key)) {
        merged.add(entry.value.copyWith(isOnline: false));
      }
    }

    _bulbs = merged;
  }

  Future<void> _pollAllBulbs() async {
    for (final bulb in _bulbs.where((b) => b.isOnline)) {
      if (_interactingBulbIds.contains(bulb.id)) continue;
      final state = await _proto.getPilotState(bulb);
      final idx = _bulbs.indexWhere((b) => b.id == bulb.id);
      if (idx != -1) {
        if (state != null) {
          _bulbs[idx] = _bulbs[idx].copyWith(
            state: BulbState.fromMap(
              _stateToMap(state),
              previous: _bulbs[idx].state,
            ),
            lastSeen: DateTime.now(),
          );
        } else {
          _bulbs[idx] = _bulbs[idx].copyWith(isOnline: false);
        }
        _checkCommandFailed(_bulbs[idx], _bulbs[idx].state ?? const BulbState());
        _notifyListeners();
      }
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _pollAllBulbs());
  }

  void onAppPaused() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _interactingBulbIds.clear();
    _backgroundedAt = DateTime.now();
  }

  Future<void> onAppResumed() async {
    if (_backgroundedAt == null) return;
    final elapsed = DateTime.now().difference(_backgroundedAt!);
    _backgroundedAt = null;

    if (elapsed < _backgroundThreshold) {
      await _quickReconnect();
    } else {
      await _reconnect();
    }
  }

  Future<void> _quickReconnect() async {
    for (final bulb in _bulbs.where((b) => b.isOnline)) {
      _proto.register(bulb.ip);
    }
    _startPolling();
    await _pollAllBulbs();
  }

  Future<void> _reconnect() async {
    _isReconnecting = true;
    _notifyListeners();
    _discovery.clearCache();
    await startupFetch();
    _isReconnecting = false;
    _notifyListeners();
  }

  BulbState getBulbState(Bulb bulb) {
    final idx = _bulbs.indexWhere((b) => b.id == bulb.id);
    if (idx == -1) return const BulbState();
    return _bulbs[idx].state ?? const BulbState();
  }

  Future<BulbState?> refreshBulbState(Bulb bulb) async {
    final state = await _proto.getPilotState(bulb);
    if (state != null) {
      final idx = _bulbs.indexWhere((b) => b.id == bulb.id);
      if (idx != -1 && !_interactingBulbIds.contains(bulb.id)) {
        _bulbs[idx] = _bulbs[idx].copyWith(
          isOnline: true,
          state: BulbState.fromMap(
            _stateToMap(state),
            previous: _bulbs[idx].state,
          ),
          lastSeen: DateTime.now(),
        );
        _checkCommandFailed(_bulbs[idx], _bulbs[idx].state ?? const BulbState());
        _notifyListeners();
      }
    }
    return state;
  }

  Future<void> refreshAll() async {
    for (final bulb in _bulbs) {
      if (_interactingBulbIds.contains(bulb.id)) continue;
      final idx = _bulbs.indexWhere((b) => b.id == bulb.id);
      if (idx == -1) continue;
      try {
        final state = await _proto.getPilotState(bulb).timeout(
          const Duration(seconds: 3),
        );
        if (state != null) {
          _bulbs[idx] = _bulbs[idx].copyWith(
            isOnline: true,
            state: BulbState.fromMap(
              _stateToMap(state),
              previous: _bulbs[idx].state,
            ),
            lastSeen: DateTime.now(),
          );
        } else {
          _bulbs[idx] = _bulbs[idx].copyWith(isOnline: false);
        }
        _checkCommandFailed(_bulbs[idx], _bulbs[idx].state ?? const BulbState());
      } catch (_) {
        _bulbs[idx] = _bulbs[idx].copyWith(isOnline: false);
      }
      _notifyListeners();
    }
  }

  Bulb? getBulbById(String id) {
    final idx = _bulbs.indexWhere((b) => b.id == id);
    return idx == -1 ? null : _bulbs[idx];
  }

  bool getCommandFailed(Bulb bulb) => _commandFailed.contains(bulb.id);

  void setUserInteracting(Bulb bulb, bool interacting) {
    if (interacting) {
      _interactingBulbIds.add(bulb.id);
    } else {
      _interactingBulbIds.remove(bulb.id);
    }
  }

  void _trackCommand(Bulb bulb, BulbCommand command) {
    _pendingCommands[bulb.id] = (command: command, timestamp: DateTime.now());
    _commandFailed.remove(bulb.id);
  }

  void _checkCommandFailed(Bulb bulb, BulbState polledState) {
    final pending = _pendingCommands[bulb.id];
    if (pending == null) return;

    if (_matchesCommand(polledState, pending.command)) {
      _pendingCommands.remove(bulb.id);
      _commandFailed.remove(bulb.id);
    } else {
      final elapsed = DateTime.now().difference(pending.timestamp);
      if (elapsed > const Duration(seconds: 10)) {
        _commandFailed.add(bulb.id);
      }
    }
  }

  bool _matchesCommand(BulbState state, BulbCommand command) {
    if (command.on != null && state.on != command.on) return false;
    if (command.dimming != null && state.dimming != command.dimming) return false;
    if (command.r != null && state.r != command.r) return false;
    if (command.g != null && state.g != command.g) return false;
    if (command.b != null && state.b != command.b) return false;
    if (command.temp != null && state.temp != command.temp) return false;
    if (command.sceneId != null && state.sceneId != command.sceneId) return false;
    if (command.speed != null && state.speed != command.speed) return false;
    return true;
  }

  void toggle(Bulb bulb) {
    final current = getBulbState(bulb);
    final command = BulbCommand(on: !current.on);
    _proto.setPilot(bulb, command);
    _trackCommand(bulb, command);
    final idx = _bulbs.indexWhere((b) => b.id == bulb.id);
    if (idx != -1) {
      _bulbs[idx] = _bulbs[idx].copyWith(
        state: current.merge(command),
      );
      _notifyListeners();
    }
  }

  void setBrightness(Bulb bulb, int percent) {
    final clamped = percent.clamp(BulbLimits.minBrightness, BulbLimits.maxBrightness);
    final current = getBulbState(bulb);
    final command = BulbCommand(dimming: clamped);
    _proto.setPilot(bulb, command);
    _trackCommand(bulb, command);
    final idx = _bulbs.indexWhere((b) => b.id == bulb.id);
    if (idx != -1) {
      _bulbs[idx] = _bulbs[idx].copyWith(
        state: current.merge(command),
      );
      _notifyListeners();
    }
  }

  void setWhiteTemp(Bulb bulb, int kelvin) {
    final minK = bulb.kelvinMin;
    final maxK = bulb.kelvinMax;
    final clamped = kelvin.clamp(minK, maxK);
    final current = getBulbState(bulb);
    final command = BulbCommand(temp: clamped);
    _proto.setPilot(bulb, command);
    _trackCommand(bulb, command);
    final idx = _bulbs.indexWhere((b) => b.id == bulb.id);
    if (idx != -1) {
      _bulbs[idx] = _bulbs[idx].copyWith(
        state: BulbState(
          on: current.on,
          c: current.c,
          w: current.w,
          temp: clamped,
          dimming: current.dimming,
          speed: current.speed,
          rssi: current.rssi,
        ),
      );
      _notifyListeners();
    }
  }

  void setColor(Bulb bulb, int r, int g, int b) {
    final cr = r.clamp(BulbLimits.minChannel, BulbLimits.maxChannel);
    final cg = g.clamp(BulbLimits.minChannel, BulbLimits.maxChannel);
    final cb = b.clamp(BulbLimits.minChannel, BulbLimits.maxChannel);
    final cw = RgbcwConverter.rgb2rgbcw(cr, cg, cb);
    final current = getBulbState(bulb);
    final command = BulbCommand(r: cw.r, g: cw.g, b: cw.b, w: cw.warmWhite);
    _proto.setPilot(bulb, command);
    _trackCommand(bulb, command);
    final idx = _bulbs.indexWhere((b) => b.id == bulb.id);
    if (idx != -1) {
      _bulbs[idx] = _bulbs[idx].copyWith(
        state: BulbState(
          on: current.on,
          r: cw.r,
          g: cw.g,
          b: cw.b,
          w: cw.warmWhite,
          dimming: current.dimming,
          speed: current.speed,
          rssi: current.rssi,
        ),
      );
      _notifyListeners();
    }
  }

  void setScene(Bulb bulb, int sceneId) {
    if (!BulbLimits.isValidSceneId(sceneId)) return;
    final current = getBulbState(bulb);
    final command = BulbCommand(sceneId: sceneId);
    _proto.setPilot(bulb, command);
    _trackCommand(bulb, command);
    final idx = _bulbs.indexWhere((b) => b.id == bulb.id);
    if (idx != -1) {
      _bulbs[idx] = _bulbs[idx].copyWith(
        state: BulbState(
          on: current.on,
          c: current.c,
          w: current.w,
          dimming: current.dimming,
          sceneId: sceneId,
          speed: current.speed,
          rssi: current.rssi,
        ),
      );
      _notifyListeners();
    }
  }

  void setSpeed(Bulb bulb, int speed) {
    final clamped = speed.clamp(BulbLimits.minSpeed, BulbLimits.maxSpeed);
    final current = getBulbState(bulb);
    final command = BulbCommand(speed: clamped);
    _proto.setPilot(bulb, command);
    _trackCommand(bulb, command);
    final idx = _bulbs.indexWhere((b) => b.id == bulb.id);
    if (idx != -1) {
      _bulbs[idx] = _bulbs[idx].copyWith(
        state: current.merge(command),
      );
      _notifyListeners();
    }
  }

  Future<void> setAlias(Bulb bulb, String alias) async {
    if (bulb.mac == null) return;
    await _store.setAlias(bulb.mac!, alias);
    final idx = _bulbs.indexWhere((b) => b.id == bulb.id);
    if (idx != -1) {
      _bulbs[idx] = _bulbs[idx].copyWith(alias: alias);
      _notifyListeners();
    }
  }

  Future<void> removeBulb(Bulb bulb) async {
    if (bulb.mac == null) return;
    await _store.removeBulb(bulb.mac!);
    _bulbs = _bulbs.where((b) => b.id != bulb.id).toList();
    _saved.remove(bulb.mac);
    _notifyListeners();
  }

  void dispose() {
    _pollTimer?.cancel();
    _eventSub?.cancel();
    _proto.close();
  }
}
