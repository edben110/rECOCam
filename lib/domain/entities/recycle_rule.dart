import 'package:equatable/equatable.dart';

/// Entidad que representa una regla de reciclaje completa.
/// Contiene la información de un objeto reciclable incluyendo su material,
/// estado de reciclabilidad y recomendaciones de disposición.
class RecycleRule extends Equatable {
  final String label;
  final String material;
  final bool recyclable;
  final bool reusable;
  final String containerColor;
  final String description;
  final String recommendation;
  final List<String> aliases;

  const RecycleRule({
    required this.label,
    required this.material,
    required this.recyclable,
    required this.reusable,
    required this.containerColor,
    required this.description,
    required this.recommendation,
    this.aliases = const [],
  });

  /// Regla por defecto para objetos no encontrados.
  factory RecycleRule.unknown(String detectedLabel) => RecycleRule(
        label: detectedLabel,
        material: 'Desconocido',
        recyclable: false,
        reusable: false,
        containerColor: 'Gris',
        description:
            'Objeto "$detectedLabel" no encontrado en la base de conocimiento.',
        recommendation:
            'No hay información disponible. Consulta con tu autoridad ambiental.',
      );

  @override
  List<Object?> get props => [
        label,
        material,
        recyclable,
        reusable,
        containerColor,
        description,
        recommendation,
        aliases,
      ];
}
