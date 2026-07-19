import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lampo/data/models/bulb.dart';
import 'package:lampo/data/models/bulb_state.dart';
import 'package:lampo/data/repositories/bulb_repository.dart';
import 'package:lampo/data/services/fake_wiz_protocol.dart';
import 'package:lampo/domain/models/bulb_limits.dart';
import 'package:lampo/domain/models/bulb_type.dart';

import '../services/fake_bulb_store.dart';
import '../services/fake_connectivity_service.dart';
import '../services/fake_discovery.dart';

Bulb _bulb(String mac, {String ip = '192.168.1.100'}) {
  return Bulb(
    ip: InternetAddress(ip),
    mac: mac,
    model: 'ESP_07',
    isOnline: true,
  );
}

void main() {
  late FakeWizProtocol proto;
  late FakeBulbStore store;
  late FakeDiscovery discovery;
  late FakeConnectivityService connectivity;
  late BulbRepository repo;

  setUp(() {
    connectivity = FakeConnectivityService();
  });

  Future<void> setupRepo({BulbState? initialState}) async {
    proto = FakeWizProtocol();
    store = FakeBulbStore();
    discovery = FakeDiscovery(
      discoverResult: [_bulb('mac1')],
    );
    repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
    await repo.init();
    await repo.scan();
    if (initialState != null) {
      proto.setCannedState('192.168.1.100', initialState);
      await repo.refreshBulbState(repo.bulbs.first);
    }
    proto.sentCommands.clear();
  }

  group('BulbRepository clamping', () {
    group('setBrightness', () {
      test('clamps below minimum to 1', () async {
        await setupRepo();
        repo.setBrightness(repo.bulbs.first, 0);
        expect(proto.sentCommands.first.command.dimming, BulbLimits.minBrightness);
      });

      test('clamps above maximum to 100', () async {
        await setupRepo();
        repo.setBrightness(repo.bulbs.first, 150);
        expect(proto.sentCommands.first.command.dimming, BulbLimits.maxBrightness);
      });

      test('passes through valid value unchanged', () async {
        await setupRepo();
        repo.setBrightness(repo.bulbs.first, 50);
        expect(proto.sentCommands.first.command.dimming, 50);
      });
    });

    group('setSpeed', () {
      test('clamps below minimum to 10', () async {
        await setupRepo();
        repo.setSpeed(repo.bulbs.first, 0);
        expect(proto.sentCommands.first.command.speed, BulbLimits.minSpeed);
      });

      test('clamps above maximum to 200', () async {
        await setupRepo();
        repo.setSpeed(repo.bulbs.first, 250);
        expect(proto.sentCommands.first.command.speed, BulbLimits.maxSpeed);
      });

      test('passes through valid value unchanged', () async {
        await setupRepo();
        repo.setSpeed(repo.bulbs.first, 100);
        expect(proto.sentCommands.first.command.speed, 100);
      });
    });

    group('setWhiteTemp', () {
      test('clamps below bulb minimum', () async {
        await setupRepo();
        repo.setWhiteTemp(repo.bulbs.first, 500);
        expect(proto.sentCommands.first.command.temp, 2200);
      });

      test('clamps above bulb maximum', () async {
        await setupRepo();
        repo.setWhiteTemp(repo.bulbs.first, 20000);
        expect(proto.sentCommands.first.command.temp, 6500);
      });

      test('passes through valid value unchanged', () async {
        await setupRepo();
        repo.setWhiteTemp(repo.bulbs.first, 4000);
        expect(proto.sentCommands.first.command.temp, 4000);
      });

      test('respects device-dynamic kelvin range', () async {
        proto = FakeWizProtocol();
        store = FakeBulbStore();
        discovery = FakeDiscovery(
          discoverResult: [
            Bulb(
              ip: InternetAddress('192.168.1.100'),
              mac: 'mac1',
              model: 'ESP_07',
              kelvinMin: 2700,
              kelvinMax: 6500,
            ),
          ],
        );
        repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
        await repo.init();
        await repo.scan();

        repo.setWhiteTemp(repo.bulbs.first, 1000);
        expect(proto.sentCommands.first.command.temp, 2700);
      });
    });

    group('setColor', () {
      test('clamps negative values to 0', () async {
        await setupRepo();
        repo.setColor(repo.bulbs.first, -10, -5, 0);
        expect(proto.sentCommands.first.command.r, BulbLimits.minChannel);
        expect(proto.sentCommands.first.command.g, BulbLimits.minChannel);
        expect(proto.sentCommands.first.command.b, BulbLimits.minChannel);
      });

      test('clamps above 255 — white converts to rgb=0, w=128', () async {
        await setupRepo();
        repo.setColor(repo.bulbs.first, 300, 256, 999);
        expect(proto.sentCommands.first.command.r, 0);
        expect(proto.sentCommands.first.command.g, 0);
        expect(proto.sentCommands.first.command.b, 0);
        expect(proto.sentCommands.first.command.w, 128);
      });

      test('pure red passes through with w=0', () async {
        await setupRepo();
        repo.setColor(repo.bulbs.first, 255, 0, 0);
        expect(proto.sentCommands.first.command.r, 255);
        expect(proto.sentCommands.first.command.g, 0);
        expect(proto.sentCommands.first.command.b, 0);
        expect(proto.sentCommands.first.command.w, 0);
      });

      test('white sets warm white channel', () async {
        await setupRepo();
        repo.setColor(repo.bulbs.first, 255, 255, 255);
        expect(proto.sentCommands.first.command.w, 128);
      });
    });

    group('setScene', () {
      test('sends command for valid scene ID', () async {
        await setupRepo();
        repo.setScene(repo.bulbs.first, 1);
        expect(proto.sentCommands.length, 1);
        expect(proto.sentCommands.first.command.sceneId, 1);
      });

      test('skips command for invalid scene ID', () async {
        await setupRepo();
        repo.setScene(repo.bulbs.first, 9999);
        expect(proto.sentCommands.length, 0);
      });

      test('skips command for scene ID 0', () async {
        await setupRepo();
        repo.setScene(repo.bulbs.first, 0);
        expect(proto.sentCommands.length, 0);
      });

      test('accepts newly added scene IDs (26, 36, 40)', () async {
        await setupRepo();
        repo.setScene(repo.bulbs.first, 26);
        expect(proto.sentCommands.last.command.sceneId, 26);

        repo.setScene(repo.bulbs.first, 36);
        expect(proto.sentCommands.last.command.sceneId, 36);

        repo.setScene(repo.bulbs.first, 40);
        expect(proto.sentCommands.last.command.sceneId, 40);
      });
    });

    group('device-dynamic kelvin range', () {
      test('getModelConfig cctRange updates bulb kelvin bounds on scan', () async {
        proto = FakeWizProtocol();
        proto.setCannedState('192.168.1.100', const BulbState(on: true));
        proto.setCannedModelConfig('192.168.1.100', {
          'cctRange': [2700, 2700, 6500, 6500],
        });
        store = FakeBulbStore();
        discovery = FakeDiscovery(
          discoverResult: [_bulb('mac1')],
        );
        repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
        await repo.init();
        await repo.scan();

        expect(repo.bulbs.first.kelvinMin, 2700);
        expect(repo.bulbs.first.kelvinMax, 6500);
      });

      test('falls back to default 2200-6500 when getModelConfig unavailable', () async {
        await setupRepo();
        expect(repo.bulbs.first.kelvinMin, 2200);
        expect(repo.bulbs.first.kelvinMax, 6500);
      });

      test('persists kelvin range to store', () async {
        proto = FakeWizProtocol();
        proto.setCannedState('192.168.1.100', const BulbState(on: true));
        proto.setCannedModelConfig('192.168.1.100', {
          'cctRange': [2700, 2700, 5000, 5000],
        });
        store = FakeBulbStore();
        discovery = FakeDiscovery(
          discoverResult: [_bulb('mac1')],
        );
        repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
        await repo.init();
        await repo.scan();

        final saved = await store.loadBulbs();
        expect(saved['mac1']?.kelvinMin, 2700);
        expect(saved['mac1']?.kelvinMax, 5000);
      });

      test('detects bulb class from model name during scan', () async {
        proto = FakeWizProtocol();
        proto.setCannedState('192.168.1.100', const BulbState(on: true));
        store = FakeBulbStore();
        discovery = FakeDiscovery(
          discoverResult: [
            Bulb(
              ip: InternetAddress('192.168.1.100'),
              mac: 'mac1',
              model: 'ESP01_SHTW1C_31',
            ),
          ],
        );
        repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
        await repo.init();
        await repo.scan();

        expect(repo.bulbs.first.bulbClass, BulbClass.tw);
      });

      test('defaults to RGB when model name is null', () async {
        await setupRepo();
        expect(repo.bulbs.first.bulbClass, BulbClass.rgb);
      });

      test('detects DW from model name', () async {
        proto = FakeWizProtocol();
        proto.setCannedState('192.168.1.100', const BulbState(on: true));
        store = FakeBulbStore();
        discovery = FakeDiscovery(
          discoverResult: [
            Bulb(
              ip: InternetAddress('192.168.1.100'),
              mac: 'mac1',
              model: 'ESP01_SHDW1C_31',
            ),
          ],
        );
        repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
        await repo.init();
        await repo.scan();

        expect(repo.bulbs.first.bulbClass, BulbClass.dw);
      });

      test('persists bulb class to store', () async {
        proto = FakeWizProtocol();
        proto.setCannedState('192.168.1.100', const BulbState(on: true));
        store = FakeBulbStore();
        discovery = FakeDiscovery(
          discoverResult: [
            Bulb(
              ip: InternetAddress('192.168.1.100'),
              mac: 'mac1',
              model: 'ESP01_SHDW1C_31',
            ),
          ],
        );
        repo = BulbRepository(proto: proto, discovery: discovery, store: store, connectivity: connectivity);
        await repo.init();
        await repo.scan();

        final saved = await store.loadBulbs();
        expect(saved['mac1']?.bulbClass, BulbClass.dw);
      });
    });
  });
}
