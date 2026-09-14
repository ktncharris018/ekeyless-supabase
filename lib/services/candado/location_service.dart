import 'package:geolocator/geolocator.dart';

abstract class ILocationService {
  Future<bool> verificarGPS();
}

class LocationService implements ILocationService {
  @override
  Future<bool> verificarGPS() async {
    final habilitado = await Geolocator.isLocationServiceEnabled();
    if (!habilitado) {
      await Geolocator.openLocationSettings();
      return Geolocator.isLocationServiceEnabled();
    }
    return true;
  }
}
