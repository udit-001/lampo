import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lampo/data/models/bulb.dart';

void main() {
  group('Bulb JSON', () {
    test('toJson includes lastSeen when set', () {
      final ts = DateTime(2026, 7, 13, 10, 30);
      final bulb = Bulb(
        ip: InternetAddress('192.168.1.100'),
        mac: 'abc123',
        model: 'ESP_07',
        lastSeen: ts,
      );
      final json = bulb.toJson();
      expect(json['lastSeen'], ts.toIso8601String());
    });

    test('toJson omits lastSeen when null', () {
      final bulb = Bulb(
        ip: InternetAddress('192.168.1.100'),
        mac: 'abc123',
      );
      final json = bulb.toJson();
      expect(json.containsKey('lastSeen'), isFalse);
    });

    test('fromJson restores lastSeen', () {
      final ts = DateTime(2026, 7, 13, 10, 30);
      final json = {
        'mac': 'abc123',
        'model': 'ESP_07',
        'ip': '192.168.1.100',
        'port': 38899,
        'lastSeen': ts.toIso8601String(),
      };
      final bulb = Bulb.fromJson(json);
      expect(bulb.lastSeen, ts);
      expect(bulb.mac, 'abc123');
      expect(bulb.model, 'ESP_07');
    });

    test('fromJson handles missing lastSeen gracefully', () {
      final json = {
        'mac': 'abc123',
        'ip': '192.168.1.100',
        'port': 38899,
      };
      final bulb = Bulb.fromJson(json);
      expect(bulb.lastSeen, isNull);
    });

    test('toJson/fromJson round-trip preserves lastSeen', () {
      final ts = DateTime(2026, 7, 13, 10, 30);
      final bulb = Bulb(
        ip: InternetAddress('192.168.1.100'),
        mac: 'abc123',
        model: 'ESP_07',
        firmware: '1.2.3',
        alias: 'Living Room',
        lastSeen: ts,
        lastSeenIp: '192.168.1.100',
      );
      final restored = Bulb.fromJson(bulb.toJson());
      expect(restored.lastSeen, ts);
      expect(restored.mac, 'abc123');
      expect(restored.model, 'ESP_07');
      expect(restored.firmware, '1.2.3');
      expect(restored.alias, 'Living Room');
      expect(restored.lastSeenIp, '192.168.1.100');
    });
  });
}
