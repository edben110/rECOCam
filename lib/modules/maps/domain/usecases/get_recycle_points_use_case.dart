import '../entities/recycle_point.dart';
import '../repositories/map_repository.dart';

class GetRecyclePointsUseCase {
  final MapRepository _repository;

  GetRecyclePointsUseCase({required MapRepository repository})
      : _repository = repository;

  Future<List<RecyclePoint>> call({
    required String ciudad,
    String? localidad,
    String? tipo,
    double? latitud,
    double? longitud,
    double? radioKm,
  }) async {
    final points = await _repository.getRecyclePoints(
      ciudad: ciudad,
      localidad: localidad,
      tipo: tipo,
      latitud: latitud,
      longitud: longitud,
      radioKm: radioKm,
    );

    if (latitud != null && longitud != null) {
      return _sortByDistance(points, latitud, longitud);
    }

    return points;
  }

  List<RecyclePoint> _sortByDistance(
    List<RecyclePoint> points,
    double userLat,
    double userLng,
  ) {
    final sorted = List<RecyclePoint>.from(points);
    sorted.sort((a, b) {
      final distA = _calculateDistance(userLat, userLng, a.latitud, a.longitud);
      final distB = _calculateDistance(userLat, userLng, b.latitud, b.longitud);
      return distA.compareTo(distB);
    });
    return sorted;
  }

  static double _calculateDistance(
    double lat1, double lng1, double lat2, double lng2,
  ) {
    const r = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) * _cos(_toRadians(lat2)) *
            _sin(dLng / 2) * _sin(dLng / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return r * c;
  }

  static double _toRadians(double deg) => deg * 3.141592653589793 / 180.0;
  static double _sin(double x) {
    final xi = x.remainder(2 * 3.141592653589793);
    return xi - (xi * xi * xi) / 6.0;
  }

  static double _cos(double x) => 1.0 - x * x / 2.0;
  static double _sqrt(double x) {
    if (x <= 0) return 0;
    var guess = x / 2.0;
    for (var i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2.0;
    }
    return guess;
  }

  static double _atan2(double y, double x) {
    if (x > 0) return (y / x);
    if (x < 0 && y >= 0) return 3.141592653589793 + (y / x);
    if (x < 0 && y < 0) return -3.141592653589793 + (y / x);
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }
}
