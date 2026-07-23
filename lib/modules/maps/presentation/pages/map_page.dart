import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/recycle_point.dart';
import '../viewmodels/map_viewmodel.dart';
import '../widgets/map_widget.dart';
import '../widgets/city_selector.dart';
import '../widgets/sidebar_points.dart';
import '../widgets/recycle_point_card.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool _sidebarOpen = false;
  int _selectionGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapViewModel>().initialize();
    });
  }

  void _toggleSidebar() {
    setState(() => _sidebarOpen = !_sidebarOpen);
  }

  void _onPointSelected(MapViewModel vm, RecyclePoint point) {
    vm.selectPoint(point);
    setState(() {
      _selectionGeneration++;
      _sidebarOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puntos de Reciclaje'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MapViewModel>().refresh(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildCitySelector(),
              Expanded(
                child: _buildMapArea(),
              ),
            ],
          ),
          Positioned(
            top: 8,
            left: 8,
            child: FloatingActionButton.small(
              heroTag: 'sidebar_hamburger',
              onPressed: _toggleSidebar,
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 4,
              child: Icon(
                _sidebarOpen ? Icons.close : Icons.menu,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          _buildSidebar(),
          _buildFloatingCard(),
          _buildProgressIndicator(),
          _buildErrorBanner(),
        ],
      ),
    );
  }

  Widget _buildCitySelector() {
    return Consumer<MapViewModel>(
      builder: (context, vm, _) {
        return CitySelector(
          selectedCity: vm.selectedCity,
          onCityChanged: vm.selectCity,
        );
      },
    );
  }

  Widget _buildMapArea() {
    return Consumer<MapViewModel>(
      builder: (context, vm, _) {
        if (vm.selectedCity == null) {
          return _buildEmptyState();
        }

        return MapWidget(
          points: vm.filteredPoints,
          selectedPoint: vm.selectedPoint,
          currentLocation: vm.currentLocation,
          initialCenter: vm.getInitialCenter(),
          onPointSelected: (point) => _onPointSelected(vm, point),
          onMapTap: () => vm.clearSelection(),
          selectionGeneration: _selectionGeneration,
        );
      },
    );
  }

  Widget _buildSidebar() {
    return Consumer<MapViewModel>(
      builder: (context, vm, _) {
        return SidebarPoints(
          points: vm.filteredPoints,
          allPointsCount: vm.points.length,
          selectedLocality: vm.selectedLocality,
          availableLocalities: vm.availableLocalities,
          tipoFilter: vm.tipoFilter,
          searchQuery: vm.searchQuery,
          onPointSelected: (point) => _onPointSelected(vm, point),
          isVisible: _sidebarOpen,
          onToggle: _toggleSidebar,
          onLocalityChanged: vm.selectLocality,
          onTipoFilterChanged: vm.setTipoFilter,
          onSearchChanged: vm.search,
        );
      },
    );
  }

  Widget _buildFloatingCard() {
    return Consumer<MapViewModel>(
      builder: (context, vm, _) {
        if (vm.selectedPoint == null) return const SizedBox.shrink();

        return Positioned(
          left: 12,
          right: 12,
          bottom: 16,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: RecyclePointCard(
              point: vm.selectedPoint!,
              onClose: () => vm.clearSelection(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Consumer<MapViewModel>(
      builder: (context, vm, _) {
        if (vm.state != MapState.loading) return const SizedBox.shrink();

        return const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: LinearProgressIndicator(),
        );
      },
    );
  }

  Widget _buildErrorBanner() {
    return Consumer<MapViewModel>(
      builder: (context, vm, _) {
        if (vm.errorMessage == null) return const SizedBox.shrink();

        final topOffset = vm.state == MapState.loading ? 40.0 : 0.0;

        return Positioned(
          top: topOffset,
          left: 16,
          right: 16,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vm.errorMessage!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => vm.clearError(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Seleccione una ciudad',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Use el selector superior para comenzar',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
