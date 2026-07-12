import 'package:flutter/services.dart';

enum WifiBand { ghz24, ghz5, ghz6, unknown }

abstract class WifiBandService {
  Future<WifiBand> detectBand();
}

class WifiBandServiceImpl implements WifiBandService {
  static const _channel = MethodChannel('com.lampo/wifi_band');

  @override
  Future<WifiBand> detectBand() async {
    try {
      final result = await _channel.invokeMethod<String>('getWifiBand');
      return switch (result) {
        '2.4GHz' => WifiBand.ghz24,
        '5GHz' => WifiBand.ghz5,
        '6GHz' => WifiBand.ghz6,
        _ => WifiBand.unknown,
      };
    } catch (_) {
      return WifiBand.unknown;
    }
  }
}
