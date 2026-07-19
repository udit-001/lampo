import 'dart:async';
import 'dart:io';

import '../models/bulb.dart';
import '../models/bulb_command.dart';
import '../models/bulb_event.dart';
import '../models/bulb_info.dart';
import '../models/bulb_state.dart';

const int wizPort = 38899;

abstract class WizProtocol {
  Future<BulbState?> getPilotState(Bulb bulb);
  void setPilot(Bulb bulb, BulbCommand command);
  Future<BulbInfo?> getSystemConfig(InternetAddress ip, {int port});
  Future<Map<String, dynamic>?> getModelConfig(InternetAddress ip, {int port});
  void register(InternetAddress broadcastIp, {int port});
  Stream<BulbEvent> get events;
  void close();
}
