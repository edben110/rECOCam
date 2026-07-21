import 'dart:io';

import '../entities/recycle_result.dart';

/// Interfaz del repositorio de análisis de reciclaje.
/// Define el contrato para la capa de datos.
/// Coordina entre el clasificador de imágenes y la base de conocimiento.
abstract class RecycleRepository {
  /// Inicializa el repositorio (carga modelo, labels y base de conocimiento).
  Future<void> initialize();

  /// Analiza una imagen y retorna un resultado de reciclaje completo.
  Future<RecycleResult> analyzeImage(File imageFile);

  /// Libera recursos (intérprete TFLite, etc).
  void dispose();

  /// Indica si el repositorio está inicializado y listo.
  bool get isInitialized;
}
