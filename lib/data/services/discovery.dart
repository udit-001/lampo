import 'dart:async';
import 'dart:io';

import '../models/bulb.dart';
import '../models/bulb_event.dart';
import 'wiz_protocol.dart';

class NetworkInfo {
  final String broadcastIp;
  final String subnet;

  const NetworkInfo({required this.broadcastIp, required this.subnet});
}

class Discovery {
  final WizProtocol _proto;
  NetworkInfo? _cachedNetwork;

  Discovery(this._proto);

  void clearCache() {
    _cachedNetwork = null;
  }

  Future<NetworkInfo> _detectNetwork() async {
    if (_cachedNetwork != null) return _cachedNetwork!;

    String broadcastIp = '192.168.1.255';
    String subnet = '192.168.1';

    var found = false;
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (addr.type != InternetAddressType.IPv4) continue;
          final ip = addr.address;
          if (ip.startsWith('127.')) continue;

          final parts = ip.split('.');
          if (parts.length != 4) continue;

          final subnetPrefix = '${parts[0]}.${parts[1]}.${parts[2]}';
          final lastOctet = int.tryParse(parts[3]) ?? 0;

          if (lastOctet == 0 || lastOctet == 255) continue;

          subnet = subnetPrefix;
          broadcastIp = '$subnetPrefix.255';
          found = true;
          break;
        }
        if (found) break;
      }
    } catch (_) {}

    _cachedNetwork = NetworkInfo(broadcastIp: broadcastIp, subnet: subnet);
    return _cachedNetwork!;
  }

  Future<List<Bulb>> discover({
    String? broadcast,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final net = await _detectNetwork();
    final broadcastIp = InternetAddress(broadcast ?? net.broadcastIp);

    final found = <String, Bulb>{};
    final completer = Completer<List<Bulb>>();
    final sub = _proto.events.listen((event) {
      if (event is Registration) {
        final ip = event.ip.address;
        if (!found.containsKey(ip)) {
          found[ip] = Bulb(
            ip: event.ip,
            mac: event.mac,
            model: event.model,
            firmware: event.firmware,
          );
        }
      }
    });

    _proto.register(broadcastIp);

    Timer(timeout, () {
      sub.cancel();
      if (!completer.isCompleted) completer.complete(found.values.toList());
    });

    return completer.future;
  }

  Future<List<Bulb>> scanSubnet({
    String? subnet,
    Duration perHostTimeout = const Duration(milliseconds: 1000),
  }) async {
    final net = await _detectNetwork();
    final subnetPrefix = subnet ?? net.subnet;

    final found = <String, Bulb>{};
    final futures = <Future<void>>[];

    for (var i = 1; i < 255; i++) {
      final ipStr = '$subnetPrefix.$i';
      futures.add(_probe(ipStr, found, perHostTimeout));
    }

    await Future.wait(futures);
    return found.values.toList();
  }

  Future<void> _probe(
    String ipStr,
    Map<String, Bulb> found,
    Duration timeout,
  ) async {
    try {
      final ip = InternetAddress(ipStr);
      final info = await _proto.getSystemConfig(ip).timeout(timeout);
      if (info != null) {
        found[ipStr] = Bulb(
          ip: ip,
          mac: info.mac,
          model: info.model,
          firmware: info.firmware,
        );
      }
    } catch (_) {}
  }
}
