import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectionType { wifi, cellular, none }

abstract class ConnectivityService {
  Future<ConnectionType> checkConnectivity();
  Stream<ConnectionType> get onConnectivityChanged;
}

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<ConnectionType> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _mapResults(results);
    } catch (_) {
      return ConnectionType.wifi;
    }
  }

  @override
  Stream<ConnectionType> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_mapResults);
  }

  ConnectionType _mapResults(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet)) {
      return ConnectionType.wifi;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return ConnectionType.cellular;
    }
    return ConnectionType.none;
  }
}
