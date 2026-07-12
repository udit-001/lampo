import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lampo/data/models/bulb.dart';
import 'package:lampo/data/models/bulb_command.dart';
import 'package:lampo/data/models/bulb_event.dart';
import 'package:lampo/data/models/bulb_info.dart';
import 'package:lampo/data/models/bulb_state.dart';
import 'package:lampo/data/services/fake_wiz_protocol.dart';
import 'package:lampo/data/services/wiz_protocol.dart';

void main() {
  group('FakeWizProtocol', () {
    test('implements WizProtocol interface', () {
      final fake = FakeWizProtocol();
      expect(fake, isA<WizProtocol>());
      fake.close();
    });

    test('getPilotState returns canned state', () async {
      final fake = FakeWizProtocol();
      const state = BulbState(on: true, dimming: 80);
      fake.setCannedState('192.168.1.100', state);

      final bulb = Bulb(ip: InternetAddress('192.168.1.100'));
      final result = await fake.getPilotState(bulb);

      expect(result, isNotNull);
      expect(result!.on, true);
      expect(result.dimming, 80);
      fake.close();
    });

    test('getPilotState returns null when no canned state', () async {
      final fake = FakeWizProtocol();
      final bulb = Bulb(ip: InternetAddress('192.168.1.100'));
      final result = await fake.getPilotState(bulb);
      expect(result, isNull);
      fake.close();
    });

    test('setPilot records sent command', () {
      final fake = FakeWizProtocol();
      final bulb = Bulb(ip: InternetAddress('192.168.1.100'));
      const command = BulbCommand(on: true, dimming: 50);
      fake.setPilot(bulb, command);

      expect(fake.sentCommands.length, 1);
      expect(fake.sentCommands.first.bulb.ip.address, '192.168.1.100');
      expect(fake.sentCommands.first.command.dimming, 50);
      fake.close();
    });

    test('getSystemConfig returns canned info', () async {
      final fake = FakeWizProtocol();
      const info = BulbInfo(mac: 'abc123', model: 'ESP_07', firmware: '1.25.0');
      fake.setCannedInfo('192.168.1.100', info);

      final result = await fake.getSystemConfig(InternetAddress('192.168.1.100'));

      expect(result, isNotNull);
      expect(result!.mac, 'abc123');
      expect(result.model, 'ESP_07');
      fake.close();
    });

    test('events stream emits emitted events', () async {
      final fake = FakeWizProtocol();
      const state = BulbState(on: true, dimming: 80);

      final events = <BulbEvent>[];
      fake.events.listen(events.add);

      fake.emitEvent(StateUpdate(
        ip: InternetAddress('192.168.1.100'),
        state: state,
      ));

      await Future.delayed(Duration.zero);

      expect(events.length, 1);
      expect(events.first, isA<StateUpdate>());
      fake.close();
    });

    test('register is a no-op', () {
      final fake = FakeWizProtocol();
      fake.register(InternetAddress('192.168.1.255'));
      expect(fake.sentCommands.length, 0);
      fake.close();
    });
  });
}
