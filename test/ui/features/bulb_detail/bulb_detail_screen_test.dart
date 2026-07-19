import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lampo/data/models/bulb.dart';
import 'package:lampo/data/models/bulb_state.dart';
import 'package:lampo/data/repositories/bulb_repository.dart';
import 'package:lampo/data/services/fake_wiz_protocol.dart';
import 'package:lampo/ui/core/preview_box.dart';
import 'package:lampo/ui/features/bulb_detail/bulb_detail_screen.dart';

import '../../../data/services/fake_bulb_store.dart';
import '../../../data/services/fake_discovery.dart';

void main() {
  late FakeWizProtocol proto;
  late FakeBulbStore store;
  late FakeDiscovery discovery;
  late BulbRepository repository;

  Bulb offBulb() => Bulb(
        ip: InternetAddress('192.168.1.100'),
        mac: 'mac1234',
        model: 'ESP01_SHRGB_31',
        state: const BulbState(on: false, dimming: 50),
      );

  Future<void> pumpScreen(
    WidgetTester tester, {
    Bulb? bulb,
    BulbRepository? repo,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BulbDetailScreen(
          bulb: bulb ?? offBulb(),
          repository: repo ?? repository,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  setUp(() async {
    proto = FakeWizProtocol();
    proto.setCannedState(
      '192.168.1.100',
      const BulbState(on: false, dimming: 50),
    );
    store = FakeBulbStore();
    discovery = FakeDiscovery(discoverResult: [offBulb()]);
    repository = BulbRepository(
      proto: proto,
      discovery: discovery,
      store: store,
    );
    await repository.init();
    await repository.scan();
  });

  tearDown(() {
    repository.dispose();
    proto.close();
  });

  group('BulbDetailScreen power-on when bulb is off + reachable', () {
    testWidgets('AppBar Switch is enabled', (tester) async {
      await pumpScreen(tester);
      final sw = tester.widget<Switch>(find.byType(Switch));
      expect(sw.onChanged, isNotNull);
    });

    testWidgets('PreviewBox tap is enabled', (tester) async {
      await pumpScreen(tester);
      final preview = tester.widget<PreviewBox>(find.byType(PreviewBox));
      expect(preview.onTap, isNotNull);
    });

    testWidgets('tapping AppBar Switch turns bulb on', (tester) async {
      await pumpScreen(tester);
      expect(repository.getBulbById('mac1234')?.state?.on, false);

      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.pump();

      expect(repository.getBulbById('mac1234')?.state?.on, true);
    });

    testWidgets('tapping PreviewBox turns bulb on', (tester) async {
      await pumpScreen(tester);
      expect(repository.getBulbById('mac1234')?.state?.on, false);

      await tester.tap(find.byType(PreviewBox));
      await tester.pump();
      await tester.pump();

      expect(repository.getBulbById('mac1234')?.state?.on, true);
    });

    testWidgets('brightness slider stays disabled while off', (tester) async {
      await pumpScreen(tester);
      final slider = tester.widget<Slider>(find.byType(Slider).first);
      expect(slider.onChanged, isNull);
    });

    testWidgets('color temperature slider stays disabled while off',
        (tester) async {
      await pumpScreen(tester);
      final sliders = find.byType(Slider);
      expect(sliders, findsNWidgets(2));
      final tempSlider = tester.widget<Slider>(sliders.at(1));
      expect(tempSlider.onChanged, isNull);
    });
  });

  group('BulbDetailScreen power toggles disabled when unreachable', () {
    testWidgets('AppBar Switch and PreviewBox disabled when bulb is offline',
        (tester) async {
      final offlineBulb = Bulb(
        ip: InternetAddress('192.168.1.100'),
        mac: 'macOffline',
        model: 'ESP01_SHRGB_31',
        state: const BulbState(on: false, dimming: 50),
        isOnline: false,
      );
      final offlineProto = FakeWizProtocol();
      final offlineRepo = BulbRepository(
        proto: offlineProto,
        discovery: FakeDiscovery(discoverResult: const []),
        store: FakeBulbStore(),
      );
      await offlineRepo.init();

      try {
        await pumpScreen(tester, bulb: offlineBulb, repo: offlineRepo);

        final sw = tester.widget<Switch>(find.byType(Switch));
        expect(sw.onChanged, isNull);

        final preview = tester.widget<PreviewBox>(find.byType(PreviewBox));
        expect(preview.onTap, isNull);
      } finally {
        offlineRepo.dispose();
        offlineProto.close();
      }
    });
  });
}
