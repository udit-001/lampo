import 'package:lampo/data/models/bulb.dart';
import 'package:lampo/data/services/discovery.dart';
import 'package:lampo/data/services/fake_wiz_protocol.dart';

class FakeDiscovery extends Discovery {
  final List<Bulb> discoverResult;
  final List<Bulb> scanSubnetResult;

  FakeDiscovery({
    this.discoverResult = const [],
    this.scanSubnetResult = const [],
  }) : super(FakeWizProtocol());

  @override
  Future<List<Bulb>> discover({
    String? broadcast,
    Duration timeout = const Duration(seconds: 3),
  }) async =>
      discoverResult;

  @override
  Future<List<Bulb>> scanSubnet({
    String? subnet,
    Duration perHostTimeout = const Duration(milliseconds: 1000),
  }) async =>
      scanSubnetResult;
}
