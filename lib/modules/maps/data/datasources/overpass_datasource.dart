import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/recycle_point_model.dart';
import '../../core/config/map_config.dart';

class OverpassDatasource {
  static const String _baseUrl =
      'https://overpass-api.de/api/interpreter';

  static const List<String> _recyclingTags = [
    'recycling',
    'recycling_centre',
    'recycling_container',
    'waste_disposal',
    'waste_basket',
  ];

  static const double _defaultRadiusMeters = 15000;
  static const int _maxRetries = 2;
  static const Duration _retryDelay = Duration(seconds: 5);

  final Dio _dio;

  OverpassDatasource({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<RecyclePointModel>> fetchRecyclePoints({
    required String ciudad,
    String? localidad,
    String? tipo,
    double? latitud,
    double? longitud,
    double? radioKm,
  }) async {
    final query = _buildQuery(
      ciudad: ciudad,
      localidad: localidad,
      tipo: tipo,
    );

    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final response = await _dio.post(
          _baseUrl,
          data: 'data=${Uri.encodeComponent(query)}',
          options: Options(
            contentType: 'application/x-www-form-urlencoded',
            receiveTimeout: const Duration(seconds: 60),
            sendTimeout: const Duration(seconds: 10),
            headers: {
              'User-Agent': 'rECOCam/1.0 (Flutter waste classification app)',
            },
            validateStatus: (status) => true,
          ),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          if (data is String) {
            return _parseJson(jsonDecode(data));
          }
          return _parseJson(data);
        }

        if (response.statusCode == 429 || response.statusCode == 504) {
          if (attempt < _maxRetries) {
            await Future.delayed(_retryDelay * (attempt + 1));
            continue;
          }
        }

        throw Exception(
          'Error consultando Overpass API: ${response.statusCode}',
        );
      } on DioException catch (e) {
        if (attempt < _maxRetries &&
            (e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.receiveTimeout)) {
          await Future.delayed(_retryDelay * (attempt + 1));
          continue;
        }
        rethrow;
      }
    }

    throw Exception('Error consultando Overpass API: máximo de reintentos alcanzado');
  }

  String _buildQuery({
    required String ciudad,
    String? localidad,
    String? tipo,
  }) {
    final tags = tipo != null && tipo.isNotEmpty
        ? [tipo]
        : _recyclingTags;

    final cityData = MapConfig.colombianCities.firstWhere(
      (c) => c['nombre'] == ciudad,
      orElse: () => MapConfig.colombianCities.first,
    );

    final lat = double.parse(cityData['lat']!);
    final lng = double.parse(cityData['lng']!);
    final radius = _defaultRadiusMeters;
    final amenityFilter = tags.join('|');

    return '''
[out:json][timeout:25];
(
  node["amenity"~"$amenityFilter"](around:$radius,$lat,$lng);
  way["amenity"~"$amenityFilter"](around:$radius,$lat,$lng);
);
out center body;
''';
  }

  List<RecyclePointModel> _parseJson(dynamic data) {
    try {
      final map = data as Map<String, dynamic>;
      final elements = map['elements'] as List<dynamic>? ?? [];
      final points = <RecyclePointModel>[];

      for (final element in elements) {
        final model = RecyclePointModel.fromOverpass(element);
        if (model != null) points.add(model);
      }

      return points;
    } catch (e) {
      return [];
    }
  }
}
