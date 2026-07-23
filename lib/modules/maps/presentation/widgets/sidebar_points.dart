import 'package:flutter/material.dart';

import '../../domain/entities/recycle_point.dart';

class SidebarPoints extends StatelessWidget {
  final List<RecyclePoint> points;
  final Function(RecyclePoint) onPointSelected;
  final bool isVisible;
  final VoidCallback onToggle;

  const SidebarPoints({
    super.key,
    required this.points,
    required this.onPointSelected,
    required this.isVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = (screenWidth * 0.55).clamp(260.0, 420.0);

    return Stack(
      children: [
        if (isVisible)
          GestureDetector(
            onTap: onToggle,
            child: Container(
              color: Colors.black.withValues(alpha: 0.25),
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: isVisible ? 0 : -sidebarWidth - 8,
          top: 0,
          bottom: 0,
          width: sidebarWidth,
          child: GestureDetector(
            onTap: () {},
            child: Material(
              elevation: 8,
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const Divider(height: 1),
                    Expanded(
                      child: points.isEmpty
                          ? _buildEmptyState(context)
                          : _buildPointsList(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: isVisible ? sidebarWidth : 0,
          top: MediaQuery.of(context).padding.top + 8,
          child: AnimatedSlide(
            offset: isVisible ? const Offset(0, 0) : Offset.zero,
            duration: const Duration(milliseconds: 200),
            child: FloatingActionButton.small(
              heroTag: 'sidebar_toggle',
              onPressed: onToggle,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isVisible ? Icons.close : Icons.menu,
                  key: ValueKey(isVisible),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Icon(
            Icons.recycling,
            color: Theme.of(context).colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Puntos de reciclaje',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${points.length} registrado${points.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Sin resultados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No se encontraron puntos\ncon los filtros actuales',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsList(BuildContext context) {
    return ListView.builder(
      itemCount: points.length,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemBuilder: (context, index) {
        final point = points[index];
        return _buildPointItem(context, point);
      },
    );
  }

  Widget _buildPointItem(BuildContext context, RecyclePoint point) {
    final primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onPointSelected(point),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getColorForType(point.tipo),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(point.tipo),
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      point.direccion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            point.tipo,
                            style: TextStyle(
                              fontSize: 10,
                              color: primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (point.distance != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${point.distance!.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 11,
                              color: primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForType(String type) {
    if (type.contains('reciclaje')) return const Color(0xFF2E7D32);
    if (type.contains('acopio')) return const Color(0xFF1565C0);
    if (type.contains('Contenedor')) return const Color(0xFF6A1B9A);
    if (type.contains('disposición')) return const Color(0xFFE65100);
    if (type.contains('Cesta')) return const Color(0xFF757575);
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
