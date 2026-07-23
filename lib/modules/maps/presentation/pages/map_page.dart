import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/map_viewmodel.dart';
import '../widgets/map_widget.dart';
import '../widgets/city_selector.dart';
import '../widgets/recycle_point_list.dart';
import '../widgets/recycle_point_card.dart';
import '../widgets/map_search_bar.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapViewModel>().initialize();
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
      body: Consumer<MapViewModel>(
        builder: (context, vm, _) {
          return Column(
            children: [
              CitySelector(
                selectedCity: vm.selectedCity,
                selectedLocality: vm.selectedLocality,
                availableLocalities: vm.availableLocalities,
                onCityChanged: vm.selectCity,
                onLocalityChanged: vm.selectLocality,
              ),
              MapSearchBar(
                onSearch: vm.search,
                onFilterChanged: vm.setTipoFilter,
                currentFilter: vm.tipoFilter,
              ),
              Expanded(
                child: _buildBody(vm),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(MapViewModel vm) {
    if (vm.selectedCity == null) {
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

    return Stack(
      fit: StackFit.expand,
      children: [
        MapWidget(
          points: vm.filteredPoints,
          selectedPoint: vm.selectedPoint,
          currentLocation: vm.currentLocation,
          initialCenter: vm.getInitialCenter(),
          onPointSelected: vm.selectPoint,
          onMapTap: () => vm.clearSelection(),
        ),
        if (vm.state == MapState.loading)
          const Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),
        if (vm.errorMessage != null)
          Positioned(
            top: vm.state == MapState.loading ? 40 : 8,
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
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: vm.selectedPoint != null
                ? RecyclePointCard(point: vm.selectedPoint!)
                : RecyclePointList(
                    points: vm.filteredPoints,
                    onPointSelected: vm.selectPoint,
                  ),
          ),
        ),
      ],
    );
  }
}
