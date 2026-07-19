import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lampo/data/models/bulb.dart';
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
          state: const BulbState(on: true, dimming: 80, sceneId: 1, r: 100, g: 200, b: 50),
        ),
      ],
    );
    repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
    await repo.init();
    await repo.scan();
  });

  group('BulbRepository.setWhiteTemp', () {
    test('sends correct BulbCommand', () {
      repo.setWhiteTemp(repo.bulbs.first, 4500);

      expect(proto.sentCommands.length, 1);
      expect(proto.sentCommands.first.command.temp, 4500);
    });

    test('merge clears sceneId and RGB, preserves brightness', () {
      repo.setWhiteTemp(repo.bulbs.first, 4500);

      final state = repo.getBulbState(repo.bulbs.first);
      expect(state.temp, 4500);
      expect(state.dimming, 80);
      expect(state.sceneId, isNull);
      expect(state.r, isNull);
      expect(state.g, isNull);
      expect(state.b, isNull);
    });
  });

  group('BulbRepository.setColor', () {
    test('sends correct BulbCommand', () {
      repo.setColor(repo.bulbs.first, 255, 0, 128);

      expect(proto.sentCommands.length, 1);
      expect(proto.sentCommands.first.command.r, 255);
      expect(proto.sentCommands.first.command.g, 0);
      expect(proto.sentCommands.first.command.b, 128);
    });

    test('merge clears sceneId and temp, preserves brightness', () {
      repo.setColor(repo.bulbs.first, 255, 0, 128);

      final state = repo.getBulbState(repo.bulbs.first);
      expect(state.r, 255);
      expect(state.g, 0);
      expect(state.b, 128);
      expect(state.dimming, 80);
      expect(state.sceneId, isNull);
      expect(state.temp, isNull);
    });
  });
}
