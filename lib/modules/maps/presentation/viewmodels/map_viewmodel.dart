import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/recycle_point.dart';
import '../../domain/repositories/map_repository.dart';
import '../../domain/usecases/get_recycle_points_use_case.dart';
import '../../core/services/location_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/config/map_config.dart';
import '../../../../core/services/logger_service.dart';

enum MapState { initial, loading, loaded, error, empty }

class MapViewModel extends ChangeNotifier {
  final GetRecyclePointsUseCase _getRecyclePointsUseCase;
  final LocationService _locationService;
  final ConnectivityService _connectivityService;
  final MapRepository _repository;

  MapViewModel({
    required GetRecyclePointsUseCase getRecyclePointsUseCase,
    required LocationService locationService,
    required ConnectivityService connectivityService,
    required MapRepository repository,
  })  : _getRecyclePointsUseCase = getRecyclePointsUseCase,
        _locationService = locationService,
        _connectivityService = connectivityService,
        _repository = repository;

  MapState _state = MapState.initial;
  MapState get state => _state;

  List<RecyclePoint> _allPoints = [];
  List<RecyclePoint> get points => _allPoints;

  List<RecyclePoint> _filteredPoints = [];
  List<RecyclePoint> get filteredPoints => _filteredPoints;

  RecyclePoint? _selectedPoint;
  RecyclePoint? get selectedPoint => _selectedPoint;

  String? _selectedCity;
  String? get selectedCity => _selectedCity;

  String? _selectedLocality;
  String? get selectedLocality => _selectedLocality;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _tipoFilter;
  String? get tipoFilter => _tipoFilter;

  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<String> _availableLocalities = [];
  List<String> get availableLocalities => _availableLocalities;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _repository.loadLastCity();
    await _repository.loadLastLocality();
    await _repository.loadLastUpdate();

    final lastCity = _repository.getLastCity();
    final lastLocality = _repository.getLastLocality();

    if (lastCity != null && lastCity.isNotEmpty) {
      _selectedCity = lastCity;
      _selectedLocality = lastLocality;
      notifyListeners();
      await _tryLoadCachedOrFresh();
    }

    _getCurrentLocation();
  }

  Future<void> _tryLoadCachedOrFresh() async {
    if (_selectedCity == null) return;

    final lastUpdate = _repository.getLastUpdate();
    final cacheValid = lastUpdate != null &&
        DateTime.now().difference(lastUpdate) < MapConfig.cacheExpiration;

    if (cacheValid) {
      final cached = await _repository.getCachedPoints(_selectedCity!);
      if (cached.isNotEmpty) {
        _allPoints = cached;
        _extractLocalities();
        _applyFilters();
        _state = MapState.loaded;
        notifyListeners();
        return;
      }
    }

    await loadPoints();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      _currentLocation = LatLng(position.latitude, position.longitude);
      notifyListeners();
    }
  }

  Future<void> selectCity(String city) async {
    _selectedCity = city;
    _selectedLocality = null;
    _selectedPoint = null;
    await _repository.saveLastCity(city);
    notifyListeners();
    await loadPoints();
  }

  void selectLocality(String? locality) {
    _selectedLocality = locality;
    if (locality != null) {
      _repository.saveLastLocality(locality);
    }
    _selectedPoint = null;
    _applyFilters();
    notifyListeners();
  }

  Future<void> loadPoints() async {
    if (_selectedCity == null || _selectedCity!.isEmpty) return;

    _state = MapState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final isConnected = await _connectivityService.isConnected;
      if (!isConnected) {
        final cached = await _repository.getCachedPoints(_selectedCity!);
        _allPoints = cached;
        _extractLocalities();
        _applyFilters();
        _state = _allPoints.isEmpty ? MapState.empty : MapState.loaded;
        _errorMessage = 'Sin conexión. Mostrando datos cacheados.';
        notifyListeners();
        return;
      }

      final newPoints = await _getRecyclePointsUseCase(
        ciudad: _selectedCity!,
        latitud: _currentLocation?.latitude,
        longitud: _currentLocation?.longitude,
      );

      _allPoints = newPoints;
      _extractLocalities();

      await _repository.cachePoints(_allPoints, _selectedCity!);
      await _repository.saveLastUpdate(DateTime.now());

      _applyFilters();

      _state = _allPoints.isEmpty ? MapState.empty : MapState.loaded;
      notifyListeners();
    } catch (e) {
      LoggerService.instance.error('Error cargando puntos', e);
      final cached = await _repository.getCachedPoints(_selectedCity!);
      if (cached.isNotEmpty) {
        _allPoints = cached;
        _extractLocalities();
        _applyFilters();
        _state = MapState.loaded;
        _errorMessage = 'Error de conexión. Mostrando datos cacheados.';
      } else {
        _state = MapState.error;
        _errorMessage = 'Error al cargar los datos. Intente de nuevo.';
      }
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void setTipoFilter(String? tipo) {
    _tipoFilter = tipo;
    _applyFilters();
    notifyListeners();
  }

  void selectPoint(RecyclePoint? point) {
    _selectedPoint = point;
    notifyListeners();
  }

  void clearSelection() {
    _selectedPoint = null;
    notifyListeners();
  }

  LatLng getInitialCenter() {
    if (_currentLocation != null) return _currentLocation!;

    if (_selectedCity != null) {
      final cityData = MapConfig.colombianCities.firstWhere(
        (c) => c['nombre'] == _selectedCity,
        orElse: () => MapConfig.colombianCities.first,
      );
      return LatLng(
        double.parse(cityData['lat']!),
        double.parse(cityData['lng']!),
      );
    }

    return const LatLng(
      MapConfig.defaultLatitude,
      MapConfig.defaultLongitude,
    );
  }

  void _applyFilters() {
    var result = List<RecyclePoint>.from(_allPoints);

    if (_searchQuery.isNotEmpty) {
      result = result.where((p) {
        return p.nombre.toLowerCase().contains(_searchQuery) ||
            p.direccion.toLowerCase().contains(_searchQuery) ||
            p.tipo.toLowerCase().contains(_searchQuery) ||
            p.descripcion.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    if (_selectedLocality != null && _selectedLocality!.isNotEmpty) {
      result = result.where((p) => p.localidad == _selectedLocality).toList();
    }

    if (_tipoFilter != null && _tipoFilter!.isNotEmpty) {
      if (_tipoFilter == 'contenedor_cesta') {
        result = result.where((p) =>
            p.tipo == 'Contenedor de reciclaje' ||
            p.tipo == 'Cesta de basura').toList();
      } else {
        result = result.where((p) => p.tipo == _tipoFilter).toList();
      }
    }

    _filteredPoints = result;
  }

  void _extractLocalities() {
    _availableLocalities.clear();
    final localities = _allPoints
        .map((p) => p.localidad)
        .where((l) => l.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    _availableLocalities.addAll(localities);
  }

  Future<void> refresh() async => loadPoints();
}
