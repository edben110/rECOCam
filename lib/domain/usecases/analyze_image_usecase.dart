import 'dart:io';

import '../entities/recycle_result.dart';
import '../repositories/recycle_repository.dart';

/// Caso de uso para analizar una imagen y obtener información de reciclaje.
/// Aplica el Principio de Responsabilidad Única (SRP): encapsula la
/// lógica de orquestación del análisis sin contener reglas de negocio.
class AnalyzeImageUseCase {
  final RecycleRepository _repository;

  const AnalyzeImageUseCase(this._repository);

  /// Ejecuta el análisis de una imagen y retorna el resultado.
  Future<RecycleResult> call(File imageFile) async {
    return _repository.analyzeImage(imageFile);
  }
}
