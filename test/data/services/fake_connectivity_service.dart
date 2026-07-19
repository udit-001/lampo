import 'dart:async';

import 'package:lampo/data/services/connectivity_service.dart';

class FakeConnectivityService implements ConnectivityService {
  ConnectionType _connectionType;
  final StreamController<ConnectionType> _controller =
      StreamController<ConnectionType>.broadcast();

  FakeConnectivityService({
    ConnectionType connectionType = ConnectionType.wifi,
  }) : _connectionType = connectionType; // ignore: prefer_initializing_formals

  void emit(ConnectionType type) {
    _connectionType = type;
    _controller.add(type);
  }

  @override
  Future<ConnectionType> checkConnectivity() async => _connectionType;

  @override
  Stream<ConnectionType> get onConnectivityChanged => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
