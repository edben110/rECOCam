import '../../domain/entities/recycle_rule.dart';

/// Modelo de datos para la regla de reciclaje en la base de datos JSON.
/// Mapea directamente el JSON de la base de conocimiento y se convierte
/// a la entidad de dominio RecycleRule.
class RecycleRuleModel {
  final String label;
  final String material;
  final bool recyclable;
  final bool reusable;
  final String containerColor;
  final String description;
  final String recommendation;
  final List<String> aliases;

  const RecycleRuleModel({
    required this.label,
    required this.material,
    required this.recyclable,
    required this.reusable,
    required this.containerColor,
    required this.description,
    required this.recommendation,
    this.aliases = const [],
  });

  factory RecycleRuleModel.fromJson(Map<String, dynamic> json) {
    return RecycleRuleModel(
      label: json['label'] as String? ?? '',
      material: json['material'] as String? ?? 'Desconocido',
      recyclable: json['recyclable'] as bool? ?? false,
      reusable: json['reusable'] as bool? ?? false,
      containerColor: json['container_color'] as String? ?? 'Gris',
      description: json['description'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      aliases: (json['aliases'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'material': material,
      'recyclable': recyclable,
      'reusable': reusable,
      'container_color': containerColor,
      'description': description,
      'recommendation': recommendation,
      'aliases': aliases,
    };
  }

  /// Convierte el modelo a la entidad de dominio.
  RecycleRule toEntity() {
    return RecycleRule(
      label: label,
      material: material,
      recyclable: recyclable,
      reusable: reusable,
      containerColor: containerColor,
      description: description,
      recommendation: recommendation,
      aliases: aliases,
    );
  }

  @override
  String toString() =>
      'RecycleRuleModel(label: $label, material: $material, '
      'recyclable: $recyclable, container: $containerColor)';
}
