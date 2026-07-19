import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lampo/data/models/bulb.dart';
import 'package:lampo/data/models/bulb_event.dart';
import 'package:lampo/data/models/bulb_state.dart';
import 'package:lampo/data/repositories/bulb_repository.dart';
import 'package:lampo/data/services/connectivity_service.dart';
import 'package:lampo/data/services/fake_wiz_protocol.dart';

import '../services/fake_bulb_store.dart';
import '../services/fake_connectivity_service.dart';
import '../services/fake_discovery.dart';

Bulb _bulb(String mac, {String ip = '192.168.1.100', bool online = true}) {
  return Bulb(
    ip: InternetAddress(ip),
    mac: mac,
    model: 'ESP_07',
    isOnline: online,
  );
}

void main() {
  late FakeWizProtocol proto;
  late FakeBulbStore store;
  late FakeDiscovery discovery;
  late FakeConnectivityService connectivity;
  late BulbRepository repo;

  setUp(() {
    proto = FakeWizProtocol();
    store = FakeBulbStore();
    discovery = FakeDiscovery();
    connectivity = FakeConnectivityService();
    repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
  });

  group('BulbRepository', () {
    test('scan finds bulbs and adds them to the list', () async {
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);

      await repo.init();
      await repo.scan();

      expect(repo.bulbs.length, 1);
      expect(repo.bulbs.first.mac, 'mac1');
      expect(repo.bulbs.first.isOnline, true);
    });

    test('reconciliation marks saved-but-not-found as offline', () async {
      store.saveAll([
        _bulb('saved-mac', ip: '192.168.1.50', online: false),
      ]);

      discovery = FakeDiscovery(
        discoverResult: [_bulb('found-mac', ip: '192.168.1.100')],
      );
      repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);

      await repo.init();
      await repo.scan();

      expect(repo.bulbs.length, 2);
      final savedBulb = repo.bulbs.firstWhere((b) => b.mac == 'saved-mac');
      expect(savedBulb.isOnline, false);
    });

    test('reconciliation updates saved bulb with new IP and model', () async {
      store.saveAll([
        _bulb('found-mac', ip: '192.168.1.50', online: false),
      ]);

      discovery = FakeDiscovery(
        discoverResult: [
          Bulb(
            ip: InternetAddress('192.168.1.100'),
            mac: 'found-mac',
            model: 'NewModel',
          ),
        ],
      );
      repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);

      await repo.init();
      await repo.scan();

      final bulb = repo.bulbs.firstWhere((b) => b.mac == 'found-mac');
      expect(bulb.isOnline, true);
      expect(bulb.ip.address, '192.168.1.100');
      expect(bulb.model, 'NewModel');
      expect(bulb.lastSeen, isNotNull);
    });

    test('scan persists found bulbs via store', () async {
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);

      await repo.init();
      await repo.scan();

      final saved = await store.loadBulbs();
      expect(saved, contains('mac1'));
    });

    test('isScanning transitions during scan', () async {
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1')],
      );
      repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
      await repo.init();

      expect(repo.isScanning, false);

      final scanFuture = repo.scan();
      expect(repo.isScanning, true);

      await scanFuture;
      expect(repo.isScanning, false);
    });

    test('toggle sends command and updates state optimistically', () async {
      discovery = FakeDiscovery(
        discoverResult: [
          Bulb(
            ip: InternetAddress('192.168.1.100'),
            mac: 'mac1',
            state: const BulbState(on: true),
          ),
        ],
      );
      repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
      await repo.init();
      await repo.scan();

      repo.toggle(repo.bulbs.first);

      expect(proto.sentCommands.length, 1);
      expect(proto.sentCommands.first.command.on, false);
      expect(repo.bulbs.first.state!.on, false);
    });

    test('setAlias updates bulb and persists', () async {
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1')],
      );
      repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
      await repo.init();
      await repo.scan();

      await repo.setAlias(repo.bulbs.first, 'Living Room');

      expect(repo.bulbs.first.alias, 'Living Room');
      final saved = await store.loadBulbs();
      expect(saved['mac1']?.alias, 'Living Room');
    });

    test('removeBulb removes from list and store', () async {
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1')],
      );
      repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
      await repo.init();
      await repo.scan();

      await repo.removeBulb(repo.bulbs.first);

      expect(repo.bulbs.length, 0);
      final saved = await store.loadBulbs();
      expect(saved, isEmpty);
    });

    test('listeners fire on state changes', () async {
      var callCount = 0;
      repo.addListener(() => callCount++);

      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1')],
      );
      repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
      repo.addListener(() => callCount++);

      await repo.init();
      await repo.scan();

      expect(callCount, greaterThan(0));
    });

    test('SyncPilot event updates lastSeen', () async {
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
      await repo.init();
      await repo.scan();

      final oldLastSeen = repo.bulbs.first.lastSeen;
      expect(oldLastSeen, isNotNull);

      await Future.delayed(const Duration(milliseconds: 10));

      proto.emitEvent(SyncPilot(
        ip: InternetAddress('192.168.1.100'),
        state: const BulbState(on: true, dimming: 50),
      ));
      await Future.delayed(Duration.zero);

      expect(repo.bulbs.first.lastSeen, isNotNull);
      expect(
        repo.bulbs.first.lastSeen!.isAfter(oldLastSeen!),
        isTrue,
      );
    });

    test('StateUpdate event updates lastSeen', () async {
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
      await repo.init();
      await repo.scan();

      final oldLastSeen = repo.bulbs.first.lastSeen;

      await Future.delayed(const Duration(milliseconds: 10));

      proto.emitEvent(StateUpdate(
        ip: InternetAddress('192.168.1.100'),
        state: const BulbState(on: false),
      ));
      await Future.delayed(Duration.zero);

      expect(
        repo.bulbs.first.lastSeen!.isAfter(oldLastSeen!),
        isTrue,
      );
    });

    test('refreshBulbState updates lastSeen on successful fetch', () async {
      proto.setCannedState('192.168.1.100', const BulbState(on: true));

      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
      await repo.init();
      await repo.scan();

      final oldLastSeen = repo.bulbs.first.lastSeen;

      await Future.delayed(const Duration(milliseconds: 10));

      await repo.refreshBulbState(repo.bulbs.first);

      expect(
        repo.bulbs.first.lastSeen!.isAfter(oldLastSeen!),
        isTrue,
      );
    });
  });

  group('lifecycle', () {
    test('onAppPaused clears interacting bulb IDs', () async {
      proto.setCannedState('192.168.1.100', const BulbState(on: true));
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
      await repo.init();
      await repo.scan();

      expect(repo.bulbs.first.state!.on, true);

      repo.setUserInteracting(repo.bulbs.first, true);
      proto.emitEvent(SyncPilot(
        ip: InternetAddress('192.168.1.100'),
        state: const BulbState(on: false),
      ));
      await Future.delayed(Duration.zero);
      expect(repo.bulbs.first.state!.on, true);

      repo.onAppPaused();

      proto.emitEvent(SyncPilot(
        ip: InternetAddress('192.168.1.100'),
        state: const BulbState(on: false),
      ));
      await Future.delayed(Duration.zero);
      expect(repo.bulbs.first.state!.on, false);
    });

    test('onAppResumed after short background re-registers and re-polls', () async {
      proto.setCannedState('192.168.1.100', const BulbState(on: true));
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
      await repo.init();
      await repo.scan();

      final registrationsBefore = proto.registeredIps.length;

      proto.setCannedState('192.168.1.100', const BulbState(on: false));

      repo.onAppPaused();
      await repo.onAppResumed();

      expect(proto.registeredIps.length, greaterThan(registrationsBefore));
      expect(repo.bulbs.first.state!.on, false);
    });

    test('onAppResumed after long background clears cache and calls startupFetch', () async {
      proto.setCannedState('192.168.1.100', const BulbState(on: true));
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(
        proto: proto,
        discovery: discovery,
        store: store,
        connectivity: connectivity,
        backgroundThreshold: Duration.zero,
      );
      await repo.init();
      await repo.scan();

      repo.onAppPaused();

      bool wasReconnecting = false;
      repo.addListener(() {
        if (repo.isReconnecting) wasReconnecting = true;
      });

      await repo.onAppResumed();

      expect(wasReconnecting, true);
      expect(repo.isReconnecting, false);
      expect(discovery.clearCacheCalled, true);
    });

    test('onAppResumed without prior onAppPaused is a no-op', () async {
      await repo.onAppResumed();
      expect(repo.isReconnecting, false);
    });
  });

  group('connectivity', () {
    test('WiFi to cellular pauses polling and updates connectionType', () async {
      proto.setCannedState('192.168.1.100', const BulbState(on: true));
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(
        proto: proto,
        discovery: discovery,
        store: store,
        connectivity: connectivity,
        reconnectDelay: Duration.zero,
      );
      await repo.init();
      await repo.scan();

      expect(repo.connectionType, ConnectionType.wifi);

      connectivity.emit(ConnectionType.cellular);
      await Future.delayed(Duration.zero);

      expect(repo.connectionType, ConnectionType.cellular);
      expect(discovery.clearCacheCalled, false);
    });

    test('cellular to WiFi triggers debounced reconnect', () async {
      proto.setCannedState('192.168.1.100', const BulbState(on: true));
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(
        proto: proto,
        discovery: discovery,
        store: store,
        connectivity: connectivity,
        reconnectDelay: Duration.zero,
      );
      await repo.init();
      await repo.scan();

      connectivity.emit(ConnectionType.cellular);
      await Future.delayed(Duration.zero);

      proto.setCannedState('192.168.1.100', const BulbState(on: false));

      connectivity.emit(ConnectionType.wifi);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(discovery.clearCacheCalled, true);
      expect(repo.isReconnecting, false);
      expect(repo.bulbs.first.state!.on, false);
    });

    test('rapid network flapping triggers only one reconnect', () async {
      proto.setCannedState('192.168.1.100', const BulbState(on: true));
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(
        proto: proto,
        discovery: discovery,
        store: store,
        connectivity: connectivity,
        reconnectDelay: const Duration(milliseconds: 100),
      );
      await repo.init();
      await repo.scan();

      connectivity.emit(ConnectionType.cellular);
      await Future.delayed(Duration.zero);
      connectivity.emit(ConnectionType.wifi);
      await Future.delayed(Duration.zero);
      connectivity.emit(ConnectionType.cellular);
      await Future.delayed(Duration.zero);
      connectivity.emit(ConnectionType.wifi);

      await Future.delayed(const Duration(milliseconds: 150));

      expect(discovery.clearCacheCalled, true);
      expect(discovery.clearCacheCallCount, 1);
    });

    test('WiFi to WiFi transition triggers reconnect', () async {
      proto.setCannedState('192.168.1.100', const BulbState(on: true));
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(
        proto: proto,
        discovery: discovery,
        store: store,
        connectivity: connectivity,
        reconnectDelay: Duration.zero,
      );
      await repo.init();
      await repo.scan();

      connectivity.emit(ConnectionType.wifi);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(discovery.clearCacheCalled, true);
      expect(repo.isReconnecting, false);
    });

    test('isReconnecting transitions correctly during connectivity reconnect', () async {
      proto.setCannedState('192.168.1.100', const BulbState(on: true));
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(
        proto: proto,
        discovery: discovery,
        store: store,
        connectivity: connectivity,
        reconnectDelay: Duration.zero,
      );
      await repo.init();
      await repo.scan();

      bool wasReconnecting = false;
      repo.addListener(() {
        if (repo.isReconnecting) wasReconnecting = true;
      });

      connectivity.emit(ConnectionType.cellular);
      await Future.delayed(Duration.zero);

      connectivity.emit(ConnectionType.wifi);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(wasReconnecting, true);
      expect(repo.isReconnecting, false);
    });
  });

  group('pull-to-refresh', () {
    test('refreshAll re-polls all bulbs and updates states', () async {
      proto.setCannedState('192.168.1.100', const BulbState(on: true, dimming: 80));
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(
        proto: proto,
        discovery: discovery,
        store: store,
        connectivity: connectivity,
      );
      await repo.init();
      await repo.scan();

      expect(repo.bulbs.first.state!.on, true);
      expect(repo.bulbs.first.state!.dimming, 80);

      proto.setCannedState('192.168.1.100', const BulbState(on: false, dimming: 50));

      await repo.refreshAll();

      expect(repo.bulbs.first.state!.on, false);
      expect(repo.bulbs.first.state!.dimming, 50);
    });

    test('refreshAll brings offline bulbs back online', () async {
      proto.setCannedState('192.168.1.100', const BulbState(on: true));
      proto.setCannedState('192.168.1.50', const BulbState(on: false, dimming: 30));
      store.saveAll([_bulb('saved-mac', ip: '192.168.1.50', online: false)]);
      discovery = FakeDiscovery(
        discoverResult: [_bulb('found-mac', ip: '192.168.1.100')],
      );
      repo = BulbRepository(
        proto: proto,
        discovery: discovery,
        store: store,
        connectivity: connectivity,
      );
      await repo.init();
      await repo.scan();

      final savedBulb = repo.bulbs.firstWhere((b) => b.mac == 'saved-mac');
      expect(savedBulb.isOnline, false);

      await repo.refreshAll();

      final refreshed = repo.bulbs.firstWhere((b) => b.mac == 'saved-mac');
      expect(refreshed.isOnline, true);
      expect(refreshed.state!.dimming, 30);
    });

    test('refreshAll does not trigger scan', () async {
      proto.setCannedState('192.168.1.100', const BulbState(on: true));
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(
        proto: proto,
        discovery: discovery,
        store: store,
        connectivity: connectivity,
      );
      await repo.init();
      await repo.scan();

      await repo.refreshAll();

      expect(repo.isScanning, false);
    });

    test('refreshAll marks unresponsive bulbs as offline', () async {
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(
        proto: proto,
        discovery: discovery,
        store: store,
        connectivity: connectivity,
      );
      await repo.init();
      await repo.scan();

      expect(repo.bulbs.first.isOnline, true);

      await repo.refreshAll();

      expect(repo.bulbs.first.isOnline, false);
    });
  });
}
