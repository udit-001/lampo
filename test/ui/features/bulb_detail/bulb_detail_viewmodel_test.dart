import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lampo/data/models/bulb.dart';
import 'package:lampo/data/models/bulb_event.dart';
import 'package:lampo/data/models/bulb_state.dart';
import 'package:lampo/data/repositories/bulb_repository.dart';
import 'package:lampo/data/services/fake_wiz_protocol.dart';
import 'package:lampo/ui/features/bulb_detail/bulb_detail_viewmodel.dart';

import '../../../data/services/fake_bulb_store.dart';
import '../../../data/services/fake_discovery.dart';

void main() {
  late FakeWizProtocol proto;
  late FakeBulbStore store;
  late FakeDiscovery discovery;
  late BulbRepository repository;
  late BulbDetailViewModel viewModel;

  Bulb rgbBulb() => Bulb(
        ip: InternetAddress('192.168.1.100'),
        mac: 'mac1',
        model: 'ESP01_SHRGB_31',
        state: const BulbState(on: true, dimming: 80),
      );

  setUp(() async {
    proto = FakeWizProtocol();
    store = FakeBulbStore();
    discovery = FakeDiscovery(
      discoverResult: [rgbBulb()],
    );
    repository = BulbRepository(proto: proto, discovery: discovery, store: store);
    await repository.init();
    await repository.scan();

    viewModel = BulbDetailViewModel(repository: repository, bulbId: 'mac1');
  });

  group('BulbDetailViewModel', () {
    test('exposes bulb state', () {
      expect(viewModel.state.on, true);
      expect(viewModel.state.dimming, 80);
    });

    test('toggle notifies listeners', () {
      var notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      viewModel.toggle();

      expect(notifyCount, greaterThan(0));
      expect(viewModel.state.on, false);
    });

    test('setBrightness notifies listeners', () {
      var notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      viewModel.setBrightness(50);

      expect(notifyCount, greaterThan(0));
      expect(viewModel.state.dimming, 50);
    });

    test('setMode changes mode and notifies', () {
      var notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      viewModel.setMode(BulbMode.color);

      expect(notifyCount, greaterThan(0));
      expect(viewModel.selectedMode, BulbMode.color);
    });

    test('setSliderDragging sets interacting flag', () {
      viewModel.setSliderDragging(true);
      expect(viewModel.isUserInteracting, true);

      viewModel.setSliderDragging(false);
      expect(viewModel.isUserInteracting, false);
    });

    test('inferMode detects color mode', () async {
      proto.setCannedState('192.168.1.100', const BulbState(on: true, r: 100, g: 200, b: 50));
      proto.emitEvent(StateUpdate(
        ip: InternetAddress('192.168.1.100'),
        state: const BulbState(on: true, r: 100, g: 200, b: 50),
      ));

      await Future.delayed(Duration.zero);

      final colorViewModel = BulbDetailViewModel(repository: repository, bulbId: 'mac1');
      expect(colorViewModel.selectedMode, BulbMode.color);
    });

    test('inferMode detects scene mode', () async {
      proto.setCannedState('192.168.1.100', const BulbState(on: true, sceneId: 1));
      proto.emitEvent(StateUpdate(
        ip: InternetAddress('192.168.1.100'),
        state: const BulbState(on: true, sceneId: 1),
      ));

      await Future.delayed(Duration.zero);

      final sceneViewModel = BulbDetailViewModel(repository: repository, bulbId: 'mac1');
      expect(sceneViewModel.selectedMode, BulbMode.scene);
    });

    test('commandFailed is false initially', () {
      expect(viewModel.commandFailed, false);
    });
  });

  group('BulbDetailViewModel capability-driven modes', () {
    test('RGB bulb shows all three modes', () {
      expect(viewModel.availableModes, contains(BulbMode.white));
      expect(viewModel.availableModes, contains(BulbMode.color));
      expect(viewModel.availableModes, contains(BulbMode.scene));
      expect(viewModel.availableModes.length, 3);
      expect(viewModel.showBrightness, true);
      expect(viewModel.showModeToggle, true);
    });

    test('TW bulb hides color mode', () async {
      final twProto = FakeWizProtocol();
      twProto.setCannedState('192.168.1.201', const BulbState(on: true, dimming: 50));
      final twStore = FakeBulbStore();
      final twDiscovery = FakeDiscovery(
        discoverResult: [
          Bulb(
            ip: InternetAddress('192.168.1.201'),
            mac: 'macTw',
            model: 'ESP01_SHTW_31',
            state: const BulbState(on: true, dimming: 50),
          ),
        ],
      );
      final twRepo = BulbRepository(proto: twProto, discovery: twDiscovery, store: twStore);
      await twRepo.init();
      await twRepo.scan();

      final twVm = BulbDetailViewModel(repository: twRepo, bulbId: 'macTw');
      expect(twVm.availableModes, contains(BulbMode.white));
      expect(twVm.availableModes, contains(BulbMode.scene));
      expect(twVm.availableModes.contains(BulbMode.color), false);
      expect(twVm.showModeToggle, true);
    });

    test('DW bulb shows only scene mode, toggle hidden', () async {
      final dwProto = FakeWizProtocol();
      dwProto.setCannedState('192.168.1.202', const BulbState(on: true, dimming: 50));
      final dwStore = FakeBulbStore();
      final dwDiscovery = FakeDiscovery(
        discoverResult: [
          Bulb(
            ip: InternetAddress('192.168.1.202'),
            mac: 'macDw',
            model: 'ESP01_SHDW_31',
            state: const BulbState(on: true, dimming: 50),
          ),
        ],
      );
      final dwRepo = BulbRepository(proto: dwProto, discovery: dwDiscovery, store: dwStore);
      await dwRepo.init();
      await dwRepo.scan();

      final dwVm = BulbDetailViewModel(repository: dwRepo, bulbId: 'macDw');
      expect(dwVm.availableModes, [BulbMode.scene]);
      expect(dwVm.showModeToggle, false);
      expect(dwVm.showBrightness, true);
    });

    test('socket bulb shows no modes and no brightness', () async {
      final socketProto = FakeWizProtocol();
      socketProto.setCannedState('192.168.1.203', const BulbState(on: true));
      final socketStore = FakeBulbStore();
      final socketDiscovery = FakeDiscovery(
        discoverResult: [
          Bulb(
            ip: InternetAddress('192.168.1.203'),
            mac: 'macSocket',
            model: 'ESP01_SOCKET_31',
            state: const BulbState(on: true),
          ),
        ],
      );
      final socketRepo = BulbRepository(proto: socketProto, discovery: socketDiscovery, store: socketStore);
      await socketRepo.init();
      await socketRepo.scan();

      final socketVm = BulbDetailViewModel(repository: socketRepo, bulbId: 'macSocket');
      expect(socketVm.availableModes, isEmpty);
      expect(socketVm.showBrightness, false);
      expect(socketVm.showModeToggle, false);
    });

    test('setMode rejects unavailable mode', () async {
      final twProto = FakeWizProtocol();
      twProto.setCannedState('192.168.1.201', const BulbState(on: true, dimming: 50));
      final twStore = FakeBulbStore();
      final twDiscovery = FakeDiscovery(
        discoverResult: [
          Bulb(
            ip: InternetAddress('192.168.1.201'),
            mac: 'macTw',
            model: 'ESP01_SHTW_31',
            state: const BulbState(on: true, dimming: 50),
          ),
        ],
      );
      final twRepo = BulbRepository(proto: twProto, discovery: twDiscovery, store: twStore);
      await twRepo.init();
      await twRepo.scan();

      final twVm = BulbDetailViewModel(repository: twRepo, bulbId: 'macTw');
      var notifyCount = 0;
      twVm.addListener(() => notifyCount++);

      twVm.setMode(BulbMode.white);
      final countAfterValid = notifyCount;
      expect(twVm.selectedMode, BulbMode.white);

      twVm.setMode(BulbMode.color);
      expect(notifyCount, countAfterValid);
      expect(twVm.selectedMode, BulbMode.white);
    });

    test('inferMode falls back to first available when current state mode unsupported', () async {
      final dwProto = FakeWizProtocol();
      dwProto.setCannedState('192.168.1.202', const BulbState(on: true, r: 100, g: 200, b: 50));
      final dwStore = FakeBulbStore();
      final dwDiscovery = FakeDiscovery(
        discoverResult: [
          Bulb(
            ip: InternetAddress('192.168.1.202'),
            mac: 'macDw',
            model: 'ESP01_SHDW_31',
            state: const BulbState(on: true, r: 100, g: 200, b: 50),
          ),
        ],
      );
      final dwRepo = BulbRepository(proto: dwProto, discovery: dwDiscovery, store: dwStore);
      await dwRepo.init();
      await dwRepo.scan();

      final dwVm = BulbDetailViewModel(repository: dwRepo, bulbId: 'macDw');
      expect(dwVm.availableModes, [BulbMode.scene]);
      expect(dwVm.selectedMode, BulbMode.scene);
    });
  });
}
