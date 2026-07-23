import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/recycle_point.dart';
import '../../core/utils/map_marker_factory.dart';
import '../../core/config/map_config.dart';

class MapWidget extends StatefulWidget {
  final List<RecyclePoint> points;
  final RecyclePoint? selectedPoint;
  final LatLng? currentLocation;
  final LatLng initialCenter;
  final Function(RecyclePoint) onPointSelected;
  final VoidCallback onMapTap;
  final int selectionGeneration;

  const MapWidget({
    super.key,
    required this.points,
    this.selectedPoint,
    this.currentLocation,
    required this.initialCenter,
    required this.onPointSelected,
    required this.onMapTap,
    this.selectionGeneration = 0,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedPoint != null &&
        widget.selectedPoint != oldWidget.selectedPoint) {
      _mapController.move(
        LatLng(widget.selectedPoint!.latitud, widget.selectedPoint!.longitud),
        MapConfig.selectedZoom,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.initialCenter,
        initialZoom: MapConfig.defaultZoom,
        minZoom: MapConfig.minZoom,
        maxZoom: MapConfig.maxZoom,
        onTap: (_, _) => widget.onMapTap(),
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.recocam.recocam',
        ),
        MarkerLayer(markers: _buildMarkers()),
        if (widget.currentLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: widget.currentLocation!,
                width: 30,
                height: 30,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        RichAttributionWidget(
          popupInitialDisplayDuration: Duration.zero,
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    final selectedId = widget.selectedPoint?.id;
    final markers = <Marker>[];

    for (final point in widget.points) {
      markers.add(
        MapMarkerFactory.createMarker(
          context: context,
          point: point,
          isSelected: point.id == selectedId,
          onTap: () => widget.onPointSelected(point),
        ),
      );
    }

    return markers;
  }
}
