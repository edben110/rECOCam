import 'package:uuid/uuid.dart';

import '../../domain/entities/recycle_point.dart';

class RecyclePointModel extends RecyclePoint {
  const RecyclePointModel({
    required super.id,
    required super.nombre,
    required super.direccion,
    required super.latitud,
    required super.longitud,
    required super.tipo,
    required super.descripcion,
    super.ciudad,
    super.localidad,
    super.horario,
    super.telefono,
    super.website,
    super.distance,
  });

  static RecyclePointModel? fromOverpass(Map<String, dynamic> element) {
    try {
      final tags = element['tags'] as Map<String, dynamic>? ?? {};
      final lat = element['lat'] as double? ??
          (element['center'] as Map<String, dynamic>?)?['lat'] as double?;
      final lon = element['lon'] as double? ??
          (element['center'] as Map<String, dynamic>?)?['lon'] as double?;

      if (lat == null || lon == null) return null;

      final id = element['id']?.toString() ?? const Uuid().v4();
      final nombre = _buildNombre(tags);
      final direccion = _buildAddress(tags);
      final tipo = _mapType(tags['amenity'] ?? '');
      final descripcion = _buildDescription(tags);
      final horario = tags['opening_hours'] ?? '';
      final telefono = tags['phone'] ?? tags['contact:phone'] ?? '';
      final website = tags['website'] ?? tags['contact:website'] ?? '';
      final ciudad = tags['addr:city'] ?? '';
      final localidad = tags['addr:suburb'] ??
          tags['addr:neighbourhood'] ??
          tags['addr:quarter'] ??
          '';

      return RecyclePointModel(
        id: id,
        nombre: nombre,
        direccion: direccion,
        latitud: lat,
        longitud: lon,
        tipo: tipo,
        descripcion: descripcion,
        ciudad: ciudad,
        localidad: localidad,
        horario: horario,
        telefono: telefono,
        website: website,
      );
    } catch (e) {
      return null;
    }
  }

  static RecyclePointModel? fromJson(Map<String, dynamic> json) {
    try {
      return RecyclePointModel(
        id: json['id'] as String? ?? '',
        nombre: json['nombre'] as String? ?? '',
        direccion: json['direccion'] as String? ?? '',
        latitud: (json['latitud'] as num?)?.toDouble() ?? 0,
        longitud: (json['longitud'] as num?)?.toDouble() ?? 0,
        tipo: json['tipo'] as String? ?? '',
        descripcion: json['descripcion'] as String? ?? '',
        ciudad: json['ciudad'] as String? ?? '',
        localidad: json['localidad'] as String? ?? '',
        horario: json['horario'] as String? ?? '',
        telefono: json['telefono'] as String? ?? '',
        website: json['website'] as String? ?? '',
        distance: (json['distance'] as num?)?.toDouble(),
      );
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'tipo': tipo,
      'descripcion': descripcion,
      'ciudad': ciudad,
      'localidad': localidad,
      'horario': horario,
      'telefono': telefono,
      'website': website,
      'distance': distance,
    };
  }

  static String _buildNombre(Map<String, dynamic> tags) {
    final rawName = tags['name'] ?? tags['operator'] ?? '';
    if (rawName.isNotEmpty) return rawName;

    final amenity = tags['amenity'] ?? '';
    return _mapType(amenity).isNotEmpty
        ? _mapType(amenity)
        : 'Punto de reciclaje';
  }

  static String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];

    final street = tags['addr:street'] ?? '';
    final number = tags['addr:housenumber'] ?? '';
    if (street.isNotEmpty) {
      parts.add(number.isNotEmpty ? '$street $number' : street);
    }

    final suburb =
        tags['addr:suburb'] ?? tags['addr:neighbourhood'] ?? '';
    if (suburb.isNotEmpty) parts.add(suburb);

    final city = tags['addr:city'] ?? '';
    if (city.isNotEmpty) parts.add(city);

    if (parts.isNotEmpty) return parts.join(', ');

    final description = tags['description'] ?? '';
    if (description.isNotEmpty) return description;

    final note = tags['note'] ?? '';
    if (note.isNotEmpty) return note;

    final place = tags['place'] ?? '';
    if (place.isNotEmpty) return place;

    final name = tags['name'] ?? '';
    if (name.isNotEmpty) return name;

    return 'Sin dirección registrada';
  }

  static String _mapType(String amenity) {
    switch (amenity) {
      case 'recycling':
        return 'Centro de reciclaje';
      case 'recycling_centre':
        return 'Centro de acopio';
      case 'recycling_container':
        return 'Contenedor de reciclaje';
      case 'waste_disposal':
        return 'Punto de disposición';
      case 'waste_basket':
        return 'Cesta de basura';
      case 'waste_transfer_station':
        return 'Estación de transferencia';
      case 'waste_disposal_site':
        return 'Sitio de disposición';
      case 'composting':
        return 'Compostaje';
      case 'trash':
        return 'Basurero';
      case 'garbage':
        return 'Basurero';
      default:
        return 'Punto de reciclaje';
    }
  }

  static String _buildDescription(Map<String, dynamic> tags) {
    final materials = <String>[];
    final materialKeys = {
      'recycling:paper': 'Papel',
      'recycling:glass': 'Vidrio',
      'recycling:plastic': 'Plástico',
      'recycling:metal': 'Metal',
      'recycling:organic': 'Orgánico',
      'recycling:textile': 'Textil',
      'recycling:e-waste': 'Electrónicos',
      'recycling:batteries': 'Baterías',
      'recycling:clothing': 'Ropa',
      'recycling:shoes': 'Calzado',
      'recycling:cartons': 'Cartón',
      'recycling:packaging': 'Empaques',
      'recycling:wood': 'Madera',
      'recycling:green_waste': 'Jardín',
      'recycling:waste': 'Residuos generales',
    };

    for (final entry in materialKeys.entries) {
      if (tags[entry.key] == 'yes' || tags[entry.key] == 'container') {
        materials.add(entry.value);
      }
    }

    if (materials.isEmpty) return 'Centro de recolección de residuos';
    return 'Materiales: ${materials.join(', ')}';
  }
}
