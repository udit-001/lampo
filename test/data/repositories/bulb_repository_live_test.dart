import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lampo/data/models/bulb.dart';
import 'package:lampo/data/models/bulb_event.dart';
import 'package:lampo/data/models/bulb_state.dart';
import 'package:lampo/data/repositories/bulb_repository.dart';
import 'package:lampo/data/services/fake_wiz_protocol.dart';

import '../services/fake_bulb_store.dart';
import '../services/fake_connectivity_service.dart';
import '../services/fake_discovery.dart';

void main() {
  late FakeWizProtocol proto;
  late FakeBulbStore store;
  late FakeDiscovery discovery;
  late FakeConnectivityService connectivity;
  late BulbRepository repo;

  setUp(() async {
    proto = FakeWizProtocol();
    store = FakeBulbStore();
    connectivity = FakeConnectivityService();
    discovery = FakeDiscovery(
      discoverResult: [
        Bulb(
          ip: InternetAddress('192.168.1.100'),
          mac: 'mac1',
          state: const BulbState(on: true, dimming: 80),
        ),
      ],
    );
    repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
    await repo.init();
    await repo.scan();
  });

  group('syncPilot updates', () {
    test('SyncPilot event updates bulb state', () async {
      proto.emitEvent(SyncPilot(
        ip: InternetAddress('192.168.1.100'),
        state: const BulbState(on: false, dimming: 50),
      ));

      await Future.delayed(Duration.zero);

      final state = repo.getBulbState(repo.bulbs.first);
      expect(state.on, false);
      expect(state.dimming, 50);
    });

    test('SyncPilot merge preserves fields not in the event', () async {
      proto.emitEvent(SyncPilot(
        ip: InternetAddress('192.168.1.100'),
        state: const BulbState(on: true, r: 255, g: 0, b: 0),
      ));

      await Future.delayed(Duration.zero);

      final state = repo.getBulbState(repo.bulbs.first);
      expect(state.r, 255);
      expect(state.dimming, 80);
    });

    test('SyncPilot is skipped when user is interacting', () async {
      repo.setUserInteracting(repo.bulbs.first, true);

      proto.emitEvent(SyncPilot(
        ip: InternetAddress('192.168.1.100'),
        state: const BulbState(on: false, dimming: 10),
      ));

      await Future.delayed(Duration.zero);

      final state = repo.getBulbState(repo.bulbs.first);
      expect(state.on, true);
      expect(state.dimming, 80);

      repo.setUserInteracting(repo.bulbs.first, false);

      proto.emitEvent(SyncPilot(
        ip: InternetAddress('192.168.1.100'),
        state: const BulbState(on: false, dimming: 10),
      ));

      await Future.delayed(Duration.zero);

      final updatedState = repo.getBulbState(repo.bulbs.first);
      expect(updatedState.on, false);
      expect(updatedState.dimming, 10);
    });
  });

  group('refreshBulbState', () {
    test('fetches and merges state from protocol', () async {
      proto.setCannedState('192.168.1.100', const BulbState(on: true, dimming: 60, temp: 4000));

      final state = await repo.refreshBulbState(repo.bulbs.first);

      expect(state, isNotNull);
      expect(state!.dimming, 60);
      expect(repo.getBulbState(repo.bulbs.first).dimming, 60);
    });

    test('returns null when protocol has no state', () async {
      proto.setCannedState('192.168.1.100', const BulbState(on: true, dimming: 80));

      final state = await repo.refreshBulbState(Bulb(
        ip: InternetAddress('192.168.1.200'),
        mac: 'unknown',
      ));

      expect(state, isNull);
    });
  });

  group('registration on scan', () {
    test('registers with each found bulb after scan', () async {
      proto.registeredIps.clear();

      await repo.scan();

      expect(proto.registeredIps, contains(InternetAddress('192.168.1.100')));
    });
  });
}
