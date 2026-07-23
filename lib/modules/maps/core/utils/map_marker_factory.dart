import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/recycle_point.dart';

class MapMarkerFactory {
  static Marker createMarker({
    required BuildContext context,
    required RecyclePoint point,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Marker(
      point: LatLng(point.latitud, point.longitud),
      width: isSelected ? 50 : 40,
      height: isSelected ? 50 : 40,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : _getColorForType(point.tipo),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _getIconForType(point.tipo),
            color: Colors.white,
            size: isSelected ? 28 : 22,
          ),
        ),
      ),
    );
  }

  static Color _getColorForType(String type) {
    if (type.contains('reciclaje')) return const Color(0xFF2E7D32);
    if (type.contains('acopio')) return const Color(0xFF1565C0);
    if (type.contains('Contenedor')) return const Color(0xFF6A1B9A);
    if (type.contains('disposición')) return const Color(0xFFE65100);
    return const Color(0xFF424242);
  }

  static IconData _getIconForType(String type) {
    if (type.contains('reciclaje')) return Icons.recycling;
    if (type.contains('acopio')) return Icons.inventory_2;
    if (type.contains('Contenedor')) return Icons.delete_outline;
    if (type.contains('disposición')) return Icons.dangerous;
    if (type.contains('Cesta')) return Icons.delete;
    return Icons.place;
  }
}
