import '../../data/datasources/recycle_knowledge_datasource.dart';
import '../../data/repositories/recycle_repository_impl.dart';
import '../../domain/repositories/recycle_repository.dart';
import 'camera_service.dart';
import 'image_classifier.dart';
import 'image_processor.dart';

/// Contenedor de dependencias (Service Locator).
/// Centraliza la creación y gestión de instancias de servicios.
/// Patrón Singleton para garantizar una única instancia.
class ServiceProvider {
  ServiceProvider._();

  static final ServiceProvider _instance = ServiceProvider._();
  static ServiceProvider get instance => _instance;

  late final CameraService cameraService;
  late final ImageClassifier imageClassifier;
  late final ImageProcessor imageProcessor;
  late final RecycleKnowledgeDatasource knowledgeDatasource;
  late final RecycleRepository repository;

  /// Inicializa todas las dependencias.
  void initialize() {
    cameraService = CameraService.instance;
    imageClassifier = ImageClassifier();
    imageProcessor = ImageProcessor();
    knowledgeDatasource = RecycleKnowledgeDatasource();

    repository = RecycleRepositoryImpl(
      classifier: imageClassifier,
      processor: imageProcessor,
      rules: knowledgeDatasource,
    );
  }

  /// Libera todos los recursos.
  void dispose() {
    repository.dispose();
    cameraService.dispose();
  }
}
