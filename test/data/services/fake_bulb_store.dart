import 'package:lampo/data/models/bulb.dart';
import 'package:lampo/data/services/bulb_store.dart';

class FakeBulbStore extends BulbStore {
  final Map<String, Bulb> _bulbs = {};

  @override
  Future<Map<String, Bulb>> loadBulbs() async => Map.from(_bulbs);

  @override
  Future<void> saveAll(Iterable<Bulb> bulbs) async {
    for (final bulb in bulbs) {
      if (bulb.mac != null) _bulbs[bulb.mac!] = bulb;
    }
  }

  @override
  Future<void> setAlias(String mac, String alias) async {
    final bulb = _bulbs[mac];
    if (bulb != null) {
      _bulbs[mac] = bulb.copyWith(alias: alias);
    }
  }

  @override
  Future<void> removeBulb(String mac) async {
    _bulbs.remove(mac);
  }
}
