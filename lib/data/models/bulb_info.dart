import 'package:freezed_annotation/freezed_annotation.dart';

part 'bulb_info.freezed.dart';

@freezed
abstract class BulbInfo with _$BulbInfo {
  const factory BulbInfo({
    required String mac,
    String? model,
    String? firmware,
  }) = _BulbInfo;
}
