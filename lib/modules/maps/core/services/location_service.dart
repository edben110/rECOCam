import 'package:geolocator/geolocator.dart';

import '../../../../core/services/logger_service.dart';

class LocationService {
  Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      LoggerService.instance.warning('Servicios de ubicación desactivados');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        LoggerService.instance.warning('Permiso de ubicación denegado');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      LoggerService.instance.warning(
        'Permiso de ubicación denegado permanentemente',
      );
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      LoggerService.instance.info(
        'Ubicación obtenida: ${position.latitude}, ${position.longitude}',
      );

      return position;
    } catch (e) {
      LoggerService.instance.error('Error obteniendo ubicación', e);
      return null;
    }
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );
  }

  double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }
}
