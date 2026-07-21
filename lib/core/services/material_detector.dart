import 'dart:typed_data';

import '../exceptions/app_exceptions.dart';
import '../services/image_classifier.dart';
import '../services/logger_service.dart';
import '../../domain/entities/recycle_rule.dart';
import '../../domain/repositories/recycle_rules.dart';

/// Resultado de detección de material.
class MaterialDetection {
  final String label;
  final double confidence;
  final RecycleRule rule;

  const MaterialDetection({
    required this.label,
    required this.confidence,
    required this.rule,
  });
}

/// Servicio que coordina la detección de materiales.
/// Integra el clasificador de imágenes con las reglas de reciclaje
/// para identificar el material predominante de un objeto.
class MaterialDetector {
  final ImageClassifier _classifier;
  final RecycleRules _rules;

// ignore_for_file: prefer_initializing_formals
  MaterialDetector({
    required ImageClassifier classifier,
    required RecycleRules rules,
  })  : _classifier = classifier,
        _rules = rules;

  /// Analiza un tensor preprocesado y retorna la detección de material.
  Future<MaterialDetection> detectFromImage(Uint8List tensor) async {
    if (!_classifier.isLoaded) {
      throw const InferenceException(
        message: 'El modelo de clasificación no ha sido cargado.',
      );
    }

    final results = await _classifier.classifyFromTensor(tensor);

    if (results.isEmpty) {
      throw const InferenceException(
        message: 'La clasificación no devolvió resultados.',
      );
    }

    final topResult = results.first;

    final rule = _rules.findBestMatch(topResult.label);

    LoggerService.instance.info(
      'Material detectado: ${rule.label} '
      '(${rule.material}) - Confianza: '
      '${(topResult.confidence * 100).toStringAsFixed(1)}%',
    );

    return MaterialDetection(
      label: topResult.label,
      confidence: topResult.confidence,
      rule: rule,
    );
  }
}
