import 'dart:async';
import 'dart:io';

import '../models/bulb.dart';
import '../models/bulb_command.dart';
import '../models/bulb_event.dart';
import '../models/bulb_info.dart';
import '../models/bulb_state.dart';
import 'wiz_protocol.dart';

class FakeWizProtocol implements WizProtocol {
  final Map<String, BulbState> _states = {};
  final Map<String, BulbInfo> _infos = {};
  final Map<String, Map<String, dynamic>> _modelConfigs = {};
  final List<({Bulb bulb, BulbCommand command})> sentCommands = [];
  final List<InternetAddress> registeredIps = [];
  final StreamController<BulbEvent> _eventController =
      StreamController.broadcast();

  void setCannedState(String ip, BulbState state) {
    _states[ip] = state;
  }

  void setCannedInfo(String ip, BulbInfo info) {
    _infos[ip] = info;
  }

  void setCannedModelConfig(String ip, Map<String, dynamic> config) {
    _modelConfigs[ip] = config;
  }

  void emitEvent(BulbEvent event) {
    _eventController.add(event);
  }

  @override
  Future<BulbState?> getPilotState(Bulb bulb) async {
    return _states[bulb.ip.address];
  }

  @override
  void setPilot(Bulb bulb, BulbCommand command) {
    sentCommands.add((bulb: bulb, command: command));
  }

  @override
  Future<BulbInfo?> getSystemConfig(InternetAddress ip, {int port = wizPort}) async {
    return _infos[ip.address];
  }

  @override
  Future<Map<String, dynamic>?> getModelConfig(InternetAddress ip, {int port = wizPort}) async {
    return _modelConfigs[ip.address];
  }

  @override
  void register(InternetAddress broadcastIp, {int port = wizPort}) {
    registeredIps.add(broadcastIp);
  }

  @override
  Stream<BulbEvent> get events => _eventController.stream;

  @override
  void close() {
    _eventController.close();
  }
}
