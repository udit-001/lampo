import 'package:flutter/foundation.dart';

import '../../../data/models/bulb.dart';
import '../../../data/repositories/bulb_repository.dart';
import '../../../data/services/wifi_band_service.dart';

class BulbViewModel extends ChangeNotifier {
  final BulbRepository _repository;
  final WifiBandService _wifiBandService;
  bool _isInitializing = true;
  String? _scanError;
  WifiBand _wifiBand = WifiBand.unknown;

  BulbViewModel({
    required BulbRepository repository,
    required WifiBandService wifiBandService,
  })  : _repository = repository, // ignore: prefer_initializing_formals
        _wifiBandService = wifiBandService { // ignore: prefer_initializing_formals
    _repository.addListener(notifyListeners);
  }

  List<Bulb> get bulbs => _repository.bulbs;
  bool get isScanning => _repository.isScanning;
  bool get isReconnecting => _repository.isReconnecting;
  bool get isInitializing => _isInitializing;
  String? get scanError => _scanError;
  WifiBand get wifiBand => _wifiBand;

  Future<void> init() async {
    await _repository.init();
    _isInitializing = false;
    notifyListeners();

    if (_repository.bulbs.isEmpty) {
      await scan();
    } else {
      _repository.startupFetch();
    }
  }

  Future<void> scan() async {
    _scanError = null;
    notifyListeners();
    try {
      await _repository.scan();
      if (_repository.bulbs.isEmpty) {
        _wifiBand = await _wifiBandService.detectBand();
      }
    } catch (e) {
      _scanError = e.toString();
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    await _repository.refreshAll();
    notifyListeners();
  }

  void toggle(Bulb bulb) {
    _repository.toggle(bulb);
    notifyListeners();
  }

  Future<void> setAlias(Bulb bulb, String alias) async {
    await _repository.setAlias(bulb, alias);
    notifyListeners();
  }

  Future<void> removeBulb(Bulb bulb) async {
    await _repository.removeBulb(bulb);
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
