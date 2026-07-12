import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lampo/data/models/bulb.dart';
import 'package:lampo/data/models/bulb_state.dart';
import 'package:lampo/data/repositories/bulb_repository.dart';
import 'package:lampo/data/services/fake_wiz_protocol.dart';
import 'package:lampo/data/services/wifi_band_service.dart';
import 'package:lampo/ui/features/home/home_viewmodel.dart';

import '../../../data/services/fake_bulb_store.dart';
import '../../../data/services/fake_discovery.dart';
import '../../../data/services/fake_wifi_band_service.dart';

void main() {
  late FakeWizProtocol proto;
  late FakeBulbStore store;
  late FakeDiscovery discovery;
  late BulbRepository repository;
  late FakeWifiBandService wifiBandService;
  late BulbViewModel viewModel;

  setUp(() {
    proto = FakeWizProtocol();
    store = FakeBulbStore();
    discovery = FakeDiscovery(
      discoverResult: [
        Bulb(
          ip: InternetAddress('192.168.1.100'),
          mac: 'mac1',
          model: 'ESP_07',
          state: const BulbState(on: true, dimming: 80),
        ),
      ],
    );
    wifiBandService = FakeWifiBandService();
    repository = BulbRepository(proto: proto, discovery: discovery, store: store);
    viewModel = BulbViewModel(
      repository: repository,
      wifiBandService: wifiBandService,
    );
  });

  group('BulbViewModel', () {
    test('init loads bulbs and notifies listeners', () async {
      var notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      await viewModel.init();

      expect(notifyCount, greaterThan(0));
    });

    test('scan populates bulbs and notifies listeners', () async {
      var notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      await viewModel.init();
      final initialCount = notifyCount;

      await viewModel.scan();

      expect(notifyCount, greaterThan(initialCount));
      expect(viewModel.bulbs.length, 1);
      expect(viewModel.bulbs.first.mac, 'mac1');
    });

    test('isScanning transitions during scan', () async {
      await viewModel.init();

      expect(viewModel.isScanning, false);

      final scanFuture = viewModel.scan();
      expect(viewModel.isScanning, true);

      await scanFuture;
      expect(viewModel.isScanning, false);
    });

    test('toggle updates bulb state and notifies', () async {
      await viewModel.init();
      await viewModel.scan();

      var notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      final bulb = viewModel.bulbs.first;
      expect(bulb.state!.on, true);

      viewModel.toggle(bulb);

      expect(notifyCount, greaterThan(0));
      expect(viewModel.bulbs.first.state!.on, false);
    });

    test('setAlias updates bulb and notifies', () async {
      await viewModel.init();
      await viewModel.scan();

      var notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      await viewModel.setAlias(viewModel.bulbs.first, 'Living Room');

      expect(notifyCount, greaterThan(0));
      expect(viewModel.bulbs.first.alias, 'Living Room');
    });

    test('removeBulb removes from list and notifies', () async {
      await viewModel.init();
      await viewModel.scan();

      expect(viewModel.bulbs.length, 1);

      var notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      await viewModel.removeBulb(viewModel.bulbs.first);

      expect(notifyCount, greaterThan(0));
      expect(viewModel.bulbs.length, 0);
    });

    test('scan with no bulbs checks wifi band', () async {
      final emptyDiscovery = FakeDiscovery(
        discoverResult: const [],
        scanSubnetResult: const [],
      );
      final emptyRepo = BulbRepository(
        proto: proto,
        discovery: emptyDiscovery,
        store: FakeBulbStore(),
      );
      final vm = BulbViewModel(
        repository: emptyRepo,
        wifiBandService: FakeWifiBandService(bandResult: WifiBand.ghz5),
      );

      await vm.init();
      await vm.scan();

      expect(vm.bulbs, isEmpty);
      expect(vm.wifiBand, WifiBand.ghz5);
    });

    test('scan with bulbs does not check wifi band', () async {
      wifiBandService.bandResult = WifiBand.ghz5;

      await viewModel.init();
      await viewModel.scan();

      expect(viewModel.bulbs, isNotEmpty);
      expect(viewModel.wifiBand, WifiBand.unknown);
    });
  });
}
