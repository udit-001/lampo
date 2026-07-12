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

  setUp(() async {
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
}
