import 'package:flutter/material.dart';

import '../../domain/entities/recycle_point.dart';

class RecyclePointList extends StatelessWidget {
  final List<RecyclePoint> points;
  final Function(RecyclePoint) onPointSelected;

  const RecyclePointList({
    super.key,
    required this.points,
    required this.onPointSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return DraggableScrollableSheet(
          initialChildSize: 0.2,
          minChildSize: 0.1,
          maxChildSize: 0.6,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildHandle(),
                  _buildHeader(context),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: points.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final point = points[index];
                        return _buildPointItem(context, point);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.recycling,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '${points.length} puntos encontrados',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointItem(BuildContext context, RecyclePoint point) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColorForType(point.tipo),
          child: Icon(
            _getIcon(point.tipo),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          point.nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              point.direccion,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              point.tipo,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        trailing: point.distance != null
            ? Text(
                '${point.distance!.toStringAsFixed(1)} km',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              )
            : null,
        onTap: () => onPointSelected(point),
      ),
    );
  }

  Color _getColorForType(String type) {
    if (type.contains('reciclaje')) return const Color(0xFF2E7D32);
    if (type.contains('acopio')) return const Color(0xFF1565C0);
    if (type.contains('Contenedor')) return const Color(0xFF6A1B9A);
    if (type.contains('disposición')) return const Color(0xFFE65100);
    return const Color(0xFF424242);
  }

  IconData _getIcon(String type) {
    if (type.contains('reciclaje')) return Icons.recycling;
    if (type.contains('acopio')) return Icons.inventory_2;
    if (type.contains('Contenedor')) return Icons.delete_outline;
    if (type.contains('disposición')) return Icons.dangerous;
    if (type.contains('Cesta')) return Icons.delete;
    return Icons.place;
  }
}
