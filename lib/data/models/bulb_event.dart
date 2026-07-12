import 'dart:io';

import 'bulb_info.dart';
import 'bulb_state.dart';

sealed class BulbEvent {
  final InternetAddress ip;

  const BulbEvent({required this.ip});
}

class StateUpdate extends BulbEvent {
  final BulbState state;

  const StateUpdate({required super.ip, required this.state});
}

class Registration extends BulbEvent {
  final String mac;
  final String? model;
  final String? firmware;

  const Registration({
    required super.ip,
    required this.mac,
    this.model,
    this.firmware,
  });
}

class SyncPilot extends BulbEvent {
  final BulbState state;

  const SyncPilot({required super.ip, required this.state});
}

BulbInfo registrationToInfo(Registration event) => BulbInfo(
      mac: event.mac,
      model: event.model,
      firmware: event.firmware,
    );
