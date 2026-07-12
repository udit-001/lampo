import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lampo/data/models/bulb.dart';
import 'package:lampo/data/models/bulb_event.dart';
import 'package:lampo/data/models/bulb_state.dart';
import 'package:lampo/data/repositories/bulb_repository.dart';
import 'package:lampo/data/services/fake_wiz_protocol.dart';

import '../services/fake_bulb_store.dart';
import '../services/fake_discovery.dart';

Bulb _bulb(String mac, {String ip = '192.168.1.100', BulbState? state}) {
  return Bulb(
    ip: InternetAddress(ip),
    mac: mac,
    model: 'ESP_07',
    state: state,
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
    discovery = FakeDiscovery(
      discoverResult: [_bulb('mac1', state: const BulbState(on: true, dimming: 80))],
    );
    repo = BulbRepository(proto: proto, discovery: discovery, store: store);
  });

  group('BulbRepository.setBrightness', () {
    test('creates correct BulbCommand and sends it', () async {
      await repo.init();
      await repo.scan();

      repo.setBrightness(repo.bulbs.first, 50);

      expect(proto.sentCommands.length, 1);
      expect(proto.sentCommands.first.command.dimming, 50);
      expect(proto.sentCommands.first.command.on, isNull);
    });

    test('optimistic merge preserves other fields', () async {
      await repo.init();
      await repo.scan();

      repo.setBrightness(repo.bulbs.first, 50);

      final state = repo.getBulbState(repo.bulbs.first);
      expect(state.dimming, 50);
      expect(state.on, true);
    });
  });

  group('BulbRepository.toggle', () {
    test('creates correct BulbCommand', () async {
      await repo.init();
      await repo.scan();

      repo.toggle(repo.bulbs.first);

      expect(proto.sentCommands.length, 1);
      expect(proto.sentCommands.first.command.on, false);
    });

    test('merge preserves brightness', () async {
      await repo.init();
      await repo.scan();

      repo.toggle(repo.bulbs.first);

      final state = repo.getBulbState(repo.bulbs.first);
      expect(state.on, false);
      expect(state.dimming, 80);
    });
  });

  group('BulbRepository command tracking', () {
    test('getCommandFailed returns false initially', () async {
      await repo.init();
      await repo.scan();

      expect(repo.getCommandFailed(repo.bulbs.first), false);
    });

    test('getBulbById finds the bulb', () async {
      await repo.init();
      await repo.scan();

      final bulb = repo.getBulbById('mac1');
      expect(bulb, isNotNull);
      expect(bulb!.mac, 'mac1');
    });

    test('getBulbById returns null for unknown id', () async {
      await repo.init();
      await repo.scan();

      expect(repo.getBulbById('unknown'), isNull);
    });
  });

  group('BulbRepository.setUserInteracting', () {
    test('prevents state merge during drag', () async {
      await repo.init();
      await repo.scan();

      repo.setUserInteracting(repo.bulbs.first, true);

      proto.setCannedState('192.168.1.100', const BulbState(on: false, dimming: 10));
      proto.emitEvent(StateUpdate(
        ip: InternetAddress('192.168.1.100'),
        state: const BulbState(on: false, dimming: 10),
      ));

      await Future.delayed(Duration.zero);

      expect(repo.getBulbState(repo.bulbs.first).dimming, 80);

      repo.setUserInteracting(repo.bulbs.first, false);

      proto.emitEvent(StateUpdate(
        ip: InternetAddress('192.168.1.100'),
        state: const BulbState(on: false, dimming: 10),
      ));

      await Future.delayed(Duration.zero);

      expect(repo.getBulbState(repo.bulbs.first).dimming, 10);
    });
  });
}
