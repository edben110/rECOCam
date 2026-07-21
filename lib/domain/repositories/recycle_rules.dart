import '../../domain/entities/recycle_rule.dart';

/// Interfaz para el servicio de reglas de reciclaje.
/// Define el contrato para buscar reglas en la base de conocimiento.
abstract class RecycleRules {
  /// Inicializa la base de conocimiento.
  Future<void> initialize();

  /// Busca una regla por etiqueta exacta.
  RecycleRule? findByLabel(String label);

  /// Busca la mejor coincidencia para una etiqueta dada.
  RecycleRule findBestMatch(String label);

  /// Retorna todas las reglas cargadas.
  List<RecycleRule> get allRules;
}
