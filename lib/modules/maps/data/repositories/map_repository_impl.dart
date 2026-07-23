import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../datasources/overpass_datasource.dart';
import '../models/recycle_point_model.dart';
import '../../domain/entities/recycle_point.dart';
import '../../domain/repositories/map_repository.dart';
import '../../../../core/services/logger_service.dart';

class MapRepositoryImpl implements MapRepository {
  final OverpassDatasource _datasource;
  static const String _keyLastCity = 'maps_last_city';
  static const String _keyLastLocality = 'maps_last_locality';
  static const String _keyLastUpdate = 'maps_last_update';

  MapRepositoryImpl({required OverpassDatasource datasource})
      : _datasource = datasource;

  @override
  Future<List<RecyclePoint>> getRecyclePoints({
    required String ciudad,
    String? localidad,
    String? tipo,
    double? latitud,
    double? longitud,
    double? radioKm,
  }) async {
    try {
      final points = await _datasource.fetchRecyclePoints(
        ciudad: ciudad,
        localidad: localidad,
        tipo: tipo,
        latitud: latitud,
        longitud: longitud,
        radioKm: radioKm,
      );

      LoggerService.instance.info(
        '${points.length} puntos de reciclaje encontrados en $ciudad',
      );

      return points;
    } catch (e) {
      LoggerService.instance.error('Error obteniendo puntos de reciclaje', e);
      return getCachedPoints(ciudad);
    }
  }

  @override
  Future<void> cachePoints(List<RecyclePoint> points, String ciudad) async {
    try {
      final dir = await _getCacheDir();
      final file = File('${dir.path}/maps_cache_${_sanitize(ciudad)}.json');
      final jsonList = points.map((p) {
        return RecyclePointModel(
          id: p.id,
          nombre: p.nombre,
          direccion: p.direccion,
          latitud: p.latitud,
          longitud: p.longitud,
          tipo: p.tipo,
          descripcion: p.descripcion,
          ciudad: p.ciudad,
          localidad: p.localidad,
          horario: p.horario,
          telefono: p.telefono,
          website: p.website,
          distance: p.distance,
        ).toJson();
      }).toList();

      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      LoggerService.instance.error('Error cacheando puntos', e);
    }
  }

  @override
  Future<List<RecyclePoint>> getCachedPoints(String ciudad) async {
    try {
      final dir = await _getCacheDir();
      final file = File('${dir.path}/maps_cache_${_sanitize(ciudad)}.json');
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      final jsonList = jsonDecode(content) as List<dynamic>;

      return jsonList
          .map((json) =>
              RecyclePointModel.fromJson(json as Map<String, dynamic>))
          .whereType<RecyclePointModel>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  String? getLastCity() => _lastCity;
  String? _lastCity;

  @override
  Future<void> loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    _lastCity = prefs.getString(_keyLastCity);
  }

  @override
  Future<void> saveLastCity(String ciudad) async {
    _lastCity = ciudad;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastCity, ciudad);
  }

  @override
  String? getLastLocality() => _lastLocality;
  String? _lastLocality;

  @override
  Future<void> loadLastLocality() async {
    final prefs = await SharedPreferences.getInstance();
    _lastLocality = prefs.getString(_keyLastLocality);
  }

  @override
  Future<void> saveLastLocality(String localidad) async {
    _lastLocality = localidad;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastLocality, localidad);
  }

  @override
  DateTime? getLastUpdate() => _lastUpdate;
  DateTime? _lastUpdate;

  @override
  Future<void> loadLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyLastUpdate);
    if (str != null) _lastUpdate = DateTime.tryParse(str);
  }

  @override
  Future<void> saveLastUpdate(DateTime date) async {
    _lastUpdate = date;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastUpdate, date.toIso8601String());
  }

  Future<Directory> _getCacheDir() async {
    final dir = await getTemporaryDirectory();
    final cacheDir = Directory('${dir.path}/maps_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  String _sanitize(String name) {
    return name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
  }
}
