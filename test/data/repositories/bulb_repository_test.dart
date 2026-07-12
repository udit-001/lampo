import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lampo/data/models/bulb.dart';
import 'package:lampo/data/models/bulb_event.dart';
import 'package:lampo/data/models/bulb_state.dart';
import 'package:lampo/data/repositories/bulb_repository.dart';
import 'package:lampo/data/services/fake_wiz_protocol.dart';

import '../services/fake_bulb_store.dart';
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
  late BulbRepository repo;

  setUp(() {
    proto = FakeWizProtocol();
    store = FakeBulbStore();
    discovery = FakeDiscovery();
    repo = BulbRepository(proto: proto, discovery: discovery, store: store);
  });

  group('BulbRepository', () {
    test('scan finds bulbs and adds them to the list', () async {
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(proto: proto, discovery: discovery, store: store);

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
      repo = BulbRepository(proto: proto, discovery: discovery, store: store);

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
      repo = BulbRepository(proto: proto, discovery: discovery, store: store);

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
      repo = BulbRepository(proto: proto, discovery: discovery, store: store);

      await repo.init();
      await repo.scan();

      final saved = await store.loadBulbs();
      expect(saved, contains('mac1'));
    });

    test('isScanning transitions during scan', () async {
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1')],
      );
      repo = BulbRepository(proto: proto, discovery: discovery, store: store);
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
      repo = BulbRepository(proto: proto, discovery: discovery, store: store);
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
      repo = BulbRepository(proto: proto, discovery: discovery, store: store);
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
      repo = BulbRepository(proto: proto, discovery: discovery, store: store);
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
      repo = BulbRepository(proto: proto, discovery: discovery, store: store);
      repo.addListener(() => callCount++);

      await repo.init();
      await repo.scan();

      expect(callCount, greaterThan(0));
    });

    test('SyncPilot event updates lastSeen', () async {
      discovery = FakeDiscovery(
        discoverResult: [_bulb('mac1', ip: '192.168.1.100')],
      );
      repo = BulbRepository(proto: proto, discovery: discovery, store: store);
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
      repo = BulbRepository(proto: proto, discovery: discovery, store: store);
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
      repo = BulbRepository(proto: proto, discovery: discovery, store: store);
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
}
