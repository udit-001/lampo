// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../../../data/models/bulb.dart';
import '../../../data/models/bulb_state.dart';
import '../../../data/repositories/bulb_repository.dart';

enum BulbMode { white, color, scene }

class BulbDetailViewModel extends ChangeNotifier {
  final BulbRepository _repository;
  final String bulbId;
  BulbMode _selectedMode = BulbMode.white;
  bool _isUserInteracting = false;
  bool _isLoading = false;

  BulbDetailViewModel({
    required BulbRepository repository,
    required this.bulbId,
  }) : _repository = repository {
    _repository.addListener(_onRepositoryChanged);
    _selectedMode = _inferMode();
  }

  Bulb? get bulb => _repository.getBulbById(bulbId);
  BulbState get state => bulb?.state ?? const BulbState();
  bool get commandFailed => bulb != null && _repository.getCommandFailed(bulb!);
  BulbMode get selectedMode => _selectedMode;
  bool get isUserInteracting => _isUserInteracting;
  bool get isLoading => _isLoading;

  Future<void> refreshState() async {
    final b = bulb;
    if (b == null) return;
    _isLoading = true;
    notifyListeners();

    await _repository.refreshBulbState(b);

    _isLoading = false;
    _selectedMode = _inferMode();
    notifyListeners();
  }

  BulbMode _inferMode() {
    final s = state;
    if (s.r != null && s.g != null && s.b != null) return BulbMode.color;
    if (s.sceneId != null && s.sceneId! > 0) return BulbMode.scene;
    return BulbMode.white;
  }

  void setMode(BulbMode mode) {
    _selectedMode = mode;
    notifyListeners();
  }

  void toggle() {
    final b = bulb;
    if (b == null) return;
    _repository.toggle(b);
    notifyListeners();
  }

  void setBrightness(int percent) {
    final b = bulb;
    if (b == null) return;
    _repository.setBrightness(b, percent);
    notifyListeners();
  }

  void setWhiteTemp(int kelvin) {
    final b = bulb;
    if (b == null) return;
    _repository.setWhiteTemp(b, kelvin);
    _selectedMode = BulbMode.white;
    notifyListeners();
  }

  void setColor(int r, int g, int blue) {
    final b = bulb;
    if (b == null) return;
    _repository.setColor(b, r, g, blue);
    _selectedMode = BulbMode.color;
    notifyListeners();
  }

  void setScene(int sceneId) {
    final b = bulb;
    if (b == null) return;
    _repository.setScene(b, sceneId);
    _selectedMode = BulbMode.scene;
    notifyListeners();
  }

  void setSpeed(int speed) {
    final b = bulb;
    if (b == null) return;
    _repository.setSpeed(b, speed);
    notifyListeners();
  }

  Future<void> setAlias(String alias) async {
    final b = bulb;
    if (b == null) return;
    await _repository.setAlias(b, alias);
    notifyListeners();
  }

  Future<void> removeBulb() async {
    final b = bulb;
    if (b == null) return;
    await _repository.removeBulb(b);
    notifyListeners();
  }

  void setSliderDragging(bool dragging) {
    _isUserInteracting = dragging;
    final b = bulb;
    if (b != null) {
      _repository.setUserInteracting(b, dragging);
    }
  }

  void _onRepositoryChanged() {
    if (!_isUserInteracting) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    final b = bulb;
    if (b != null) {
      _repository.setUserInteracting(b, false);
    }
    super.dispose();
  }
}
