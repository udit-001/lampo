import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/bulb.dart';

class BulbStore {
  static const _key = 'bulbs';
  static const _welcomedKey = 'has_been_welcomed';

  Future<Map<String, Bulb>> loadBulbs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final map = <String, Bulb>{};
      for (final item in list) {
        final bulb = Bulb.fromJson(item as Map<String, dynamic>);
        if (bulb.mac != null) map[bulb.mac!] = bulb;
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  Future<void> _persist(Map<String, Bulb> bulbs) async {
    final prefs = await SharedPreferences.getInstance();
    final list = bulbs.values.map((b) => b.toJson()).toList();
    await prefs.setString(_key, jsonEncode(list));
  }

  Future<void> saveBulb(Bulb bulb) async {
    final bulbs = await loadBulbs();
    if (bulb.mac != null) {
      bulbs[bulb.mac!] = bulb;
      await _persist(bulbs);
    }
  }

  Future<void> removeBulb(String mac) async {
    final bulbs = await loadBulbs();
    bulbs.remove(mac);
    await _persist(bulbs);
  }

  Future<void> saveAll(Iterable<Bulb> bulbs) async {
    final map = <String, Bulb>{};
    for (final bulb in bulbs) {
      if (bulb.mac != null) map[bulb.mac!] = bulb;
    }
    await _persist(map);
  }

  Future<bool> hasBeenWelcomed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_welcomedKey) ?? false;
  }

  Future<void> setWelcomed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomedKey, true);
  }

  Future<void> setAlias(String mac, String alias) async {
    final bulbs = await loadBulbs();
    final bulb = bulbs[mac];
    if (bulb != null) {
      bulbs[mac] = bulb.copyWith(alias: alias);
      await _persist(bulbs);
    }
  }
}
