import '../../data/datasources/overpass_datasource.dart';
import '../../data/repositories/map_repository_impl.dart';
import '../../domain/repositories/map_repository.dart';
import '../../domain/usecases/get_recycle_points_use_case.dart';
import '../services/location_service.dart';
import '../services/connectivity_service.dart';

class MapServiceProvider {
  MapServiceProvider._();
  static final MapServiceProvider _instance = MapServiceProvider._();
  static MapServiceProvider get instance => _instance;

  late final OverpassDatasource overpassDatasource;
  late final MapRepository mapRepository;
  late final GetRecyclePointsUseCase getRecyclePointsUseCase;
  late final LocationService locationService;
  late final ConnectivityService connectivityService;

  void initialize() {
    overpassDatasource = OverpassDatasource();
    mapRepository = MapRepositoryImpl(datasource: overpassDatasource);
    getRecyclePointsUseCase = GetRecyclePointsUseCase(
      repository: mapRepository,
    );
    locationService = LocationService();
    connectivityService = ConnectivityService();
  }
}
