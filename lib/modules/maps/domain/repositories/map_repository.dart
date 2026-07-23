import '../entities/recycle_point.dart';

abstract class MapRepository {
  Future<List<RecyclePoint>> getRecyclePoints({
    required String ciudad,
    String? localidad,
    String? tipo,
    double? latitud,
    double? longitud,
    double? radioKm,
  });

  Future<void> cachePoints(List<RecyclePoint> points, String ciudad);
  Future<List<RecyclePoint>> getCachedPoints(String ciudad);

  String? getLastCity();
  Future<void> saveLastCity(String ciudad);

  String? getLastLocality();
  Future<void> saveLastLocality(String localidad);

  DateTime? getLastUpdate();
  Future<void> saveLastUpdate(DateTime date);

  Future<void> loadLastCity();
  Future<void> loadLastLocality();
  Future<void> loadLastUpdate();
}
