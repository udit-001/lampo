import 'package:lampo/data/services/wifi_band_service.dart';

class FakeWifiBandService implements WifiBandService {
  WifiBand bandResult;

  FakeWifiBandService({this.bandResult = WifiBand.unknown});

  @override
  Future<WifiBand> detectBand() async => bandResult;
}
