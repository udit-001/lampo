import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/bulb.dart';
import '../models/bulb_command.dart';
import '../models/bulb_event.dart';
import '../models/bulb_info.dart';
import '../models/bulb_state.dart';
import 'wiz_protocol.dart';

class WizProtocolImpl implements WizProtocol {
  final RawDatagramSocket _socket;
  final StreamController<BulbEvent> _eventController =
      StreamController.broadcast();
  final Map<String, Completer<Map<String, dynamic>>> _pending = {};

  WizProtocolImpl._(this._socket) {
    _socket.listen(_handleDatagram);
  }

  static Future<WizProtocolImpl> create() async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;
    return WizProtocolImpl._(socket);
  }

  @override
  Stream<BulbEvent> get events => _eventController.stream;

  void _send(Map<String, dynamic> msg, InternetAddress ip,
      [int port = wizPort]) {
    final data = utf8.encode(jsonEncode(msg));
    _socket.send(data, ip, port);
  }

  Future<Map<String, dynamic>?> _sendAndWait(
    Map<String, dynamic> msg,
    InternetAddress ip, {
    Duration timeout = const Duration(seconds: 2),
    int port = wizPort,
  }) async {
    final completer = Completer<Map<String, dynamic>>();
    _pending[ip.address] = completer;
    _send(msg, ip, port);
    try {
      return await completer.future.timeout(timeout);
    } on TimeoutException {
      _pending.remove(ip.address);
      return null;
    }
  }

  @override
  void setPilot(Bulb bulb, BulbCommand command) {
    _send(
      {'method': 'setPilot', 'params': command.toSetPilotParams()},
      bulb.ip,
      bulb.port,
    );
  }

  @override
  Future<BulbState?> getPilotState(Bulb bulb) async {
    final result = await _sendAndWait(
      {'method': 'getPilot', 'params': {}},
      bulb.ip,
      port: bulb.port,
    );
    if (result == null || result['result'] == null) return null;
    return BulbState.fromMap(result['result'] as Map<String, dynamic>);
  }

  @override
  Future<BulbInfo?> getSystemConfig(InternetAddress ip, {int port = wizPort}) async {
    final result = await _sendAndWait(
      {'method': 'getSystemConfig', 'params': {}},
      ip,
      port: port,
    );
    if (result == null || result['result'] == null) return null;
    final cfg = result['result'] as Map<String, dynamic>;
    final mac = cfg['mac'] as String?;
    if (mac == null) return null;
    return BulbInfo(
      mac: mac,
      model: cfg['moduleName'] as String?,
      firmware: cfg['fwVersion'] as String?,
    );
  }

  @override
  Future<Map<String, dynamic>?> getModelConfig(InternetAddress ip, {int port = wizPort}) async {
    final result = await _sendAndWait(
      {'method': 'getModelConfig', 'params': {}},
      ip,
      port: port,
    );
    if (result == null || result['result'] == null) return null;
    return result['result'] as Map<String, dynamic>;
  }

  @override
  void register(InternetAddress broadcastIp, {int port = wizPort}) {
    _send({
      'method': 'registration',
      'params': {
        'phoneMac': '000000000000',
        'register': true,
        'phoneIp': '1.2.3.4',
      },
    }, broadcastIp, port);
  }

  void _handleDatagram(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final datagram = _socket.receive();
    if (datagram == null) return;

    try {
      final json =
          jsonDecode(utf8.decode(datagram.data)) as Map<String, dynamic>;
      final ip = InternetAddress(datagram.address.address);
      final method = json['method'] as String?;

      final pending = _pending.remove(ip.address);
      if (pending != null && !pending.isCompleted) {
        pending.complete(json);
      }

      final result = json['result'] as Map<String, dynamic>?;
      if (method == 'getPilot' && result != null) {
        _eventController.add(StateUpdate(
          ip: ip,
          state: BulbState.fromMap(result),
        ));
      } else if (method == 'registration' && result != null) {
        final mac = result['mac'] as String?;
        if (mac != null) {
          _eventController.add(Registration(
            ip: ip,
            mac: mac,
            model: result['moduleName'] as String?,
            firmware: result['fwVersion'] as String?,
          ));
        }
      } else if (method == 'syncPilot' && result != null) {
        _eventController.add(SyncPilot(
          ip: ip,
          state: BulbState.fromMap(result),
        ));
      }
    } catch (_) {}
  }

  @override
  void close() {
    _socket.close();
    _eventController.close();
  }
}
