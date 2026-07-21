import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa un resultado de análisis de reciclaje.
/// Contiene toda la información sobre un objeto analizado.
class RecycleResult extends Equatable {
  final String detectedObject;
  final String material;
  final double confidence;
  final bool isRecyclable;
  final bool isReusable;
  final String containerColor;
  final String description;
  final String recommendation;
  final String? iconName;

  const RecycleResult({
    required this.detectedObject,
    required this.material,
    required this.confidence,
    required this.isRecyclable,
    required this.isReusable,
    required this.containerColor,
    required this.description,
    required this.recommendation,
    this.iconName,
  });

  /// Resultado por defecto cuando no se detecta nada.
  factory RecycleResult.empty() => const RecycleResult(
        detectedObject: 'Desconocido',
        material: 'Desconocido',
        confidence: 0.0,
        isRecyclable: false,
        isReusable: false,
        containerColor: 'Gris',
        description: 'No se pudo identificar el objeto en la imagen.',
        recommendation:
            'Intenta tomar la foto con mejor iluminación y enfoque.',
      );

  @override
  List<Object?> get props => [
        detectedObject,
        material,
        confidence,
        isRecyclable,
        isReusable,
        containerColor,
        description,
        recommendation,
        iconName,
      ];
}
