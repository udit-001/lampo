import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'bulb_state.dart';

part 'bulb.freezed.dart';

@freezed
abstract class Bulb with _$Bulb {
  const Bulb._();

  const factory Bulb({
    required InternetAddress ip,
    @Default(38899) int port,
    String? mac,
    String? model,
    String? firmware,
    BulbState? state,
    String? alias,
    @Default(true) bool isOnline,
    String? lastSeenIp,
    DateTime? lastSeen,
  }) = _Bulb;

  String get id => mac ?? ip.address;

  String get displayName {
    if (alias != null && alias!.isNotEmpty) return alias!;
    if (model != null && mac != null) {
      return '$model (${mac!.substring(mac!.length - 5)})';
    }
    if (model != null) return model!;
    return 'WiZ Bulb (${ip.address})';
  }

  Map<String, dynamic> toJson() => {
        'mac': mac,
        'model': model,
        'firmware': firmware,
        'alias': alias,
        'ip': lastSeenIp ?? ip.address,
        'port': port,
        if (lastSeen != null) 'lastSeen': lastSeen!.toIso8601String(),
      };

  factory Bulb.fromJson(Map<String, dynamic> json) {
    final ipStr = json['ip'] as String? ?? '0.0.0.0';
    final lastSeenStr = json['lastSeen'] as String?;
    return Bulb(
      ip: InternetAddress(ipStr),
      port: json['port'] as int? ?? 38899,
      mac: json['mac'] as String?,
      model: json['model'] as String?,
      firmware: json['firmware'] as String?,
      alias: json['alias'] as String?,
      isOnline: false,
      lastSeenIp: ipStr,
      lastSeen: lastSeenStr != null ? DateTime.parse(lastSeenStr) : null,
    );
  }
}
