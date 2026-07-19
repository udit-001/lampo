import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lampo/data/models/bulb.dart';
import 'package:lampo/data/models/bulb_state.dart';
import 'package:lampo/data/repositories/bulb_repository.dart';
import 'package:lampo/data/services/fake_wiz_protocol.dart';

import '../services/fake_bulb_store.dart';
import '../services/fake_discovery.dart';

void main() {
  late FakeWizProtocol proto;
  late FakeBulbStore store;
  late FakeDiscovery discovery;
  late BulbRepository repo;

  setUp(() async {
    proto = FakeWizProtocol();
    store = FakeBulbStore();
    discovery = FakeDiscovery(
      discoverResult: [
        Bulb(
          ip: InternetAddress('192.168.1.100'),
          mac: 'mac1',
          state: const BulbState(on: true, dimming: 80, temp: 4000, r: 100, g: 200, b: 50),
        ),
      ],
    );
    repo = BulbRepository(proto: proto, discovery: discovery, store: store);
    await repo.init();
    await repo.scan();
  });

  group('BulbRepository.setScene', () {
    test('sends correct BulbCommand', () {
      repo.setScene(repo.bulbs.first, 5);

      expect(proto.sentCommands.length, 1);
      expect(proto.sentCommands.first.command.sceneId, 5);
    });

    test('merge clears temp and RGB, preserves brightness', () {
      repo.setScene(repo.bulbs.first, 5);

      final state = repo.getBulbState(repo.bulbs.first);
      expect(state.sceneId, 5);
      expect(state.dimming, 80);
      expect(state.temp, isNull);
      expect(state.r, isNull);
      expect(state.g, isNull);
      expect(state.b, isNull);
    });
  });

  group('BulbRepository.setSpeed', () {
    test('sends correct BulbCommand', () {
      repo.setSpeed(repo.bulbs.first, 75);

      expect(proto.sentCommands.length, 1);
      expect(proto.sentCommands.first.command.speed, 75);
    });

    test('merge only touches speed', () {
      repo.setSpeed(repo.bulbs.first, 75);

      final state = repo.getBulbState(repo.bulbs.first);
      expect(state.speed, 75);
      expect(state.dimming, 80);
      expect(state.temp, 4000);
      expect(state.r, 100);
      expect(state.sceneId, isNull);
    });
  });
}
