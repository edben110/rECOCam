import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/recycle_point.dart';

class RecyclePointCard extends StatelessWidget {
  final RecyclePoint point;
  final VoidCallback? onClose;

  const RecyclePointCard({super.key, required this.point, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildDetails(context),
            ),
          ),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(point.tipo),
            color: Theme.of(context).colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  point.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  point.tipo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            visualDensity: VisualDensity.compact,
            onPressed: () {
              if (onClose != null) {
                onClose!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    final rows = <Widget>[
      _buildDetailRow(Icons.location_on, 'Dirección', point.direccion),
    ];
    if (point.ciudad.isNotEmpty) {
      rows.add(_buildDetailRow(Icons.location_city, 'Ciudad', point.ciudad));
    }
    if (point.localidad.isNotEmpty) {
      rows.add(_buildDetailRow(Icons.map, 'Localidad', point.localidad));
    }
    rows.add(_buildDetailRow(Icons.category, 'Tipo', point.tipo));
    if (point.descripcion.isNotEmpty) {
      rows.add(
          _buildDetailRow(Icons.info_outline, 'Descripción', point.descripcion));
    }
    if (point.horario.isNotEmpty) {
      rows.add(_buildDetailRow(Icons.access_time, 'Horario', point.horario));
    }
    if (point.telefono.isNotEmpty) {
      rows.add(_buildDetailRow(Icons.phone, 'Teléfono', point.telefono));
    }
    if (point.website.isNotEmpty) {
      rows.add(_buildDetailRow(Icons.web, 'Sitio web', point.website));
    }
    if (point.distance != null) {
      rows.add(_buildDetailRow(
        Icons.straighten,
        'Distancia',
        '${point.distance!.toStringAsFixed(1)} km',
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: point.direccion));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dirección copiada al portapapeles'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('Copiar dirección'),
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    if (type.contains('reciclaje')) return Icons.recycling;
    if (type.contains('acopio')) return Icons.inventory_2;
    if (type.contains('Contenedor')) return Icons.delete_outline;
    if (type.contains('disposición')) return Icons.dangerous;
    return Icons.place;
  }
}
