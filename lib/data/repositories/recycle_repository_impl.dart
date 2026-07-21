import 'dart:io';

import '../../core/config/app_config.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/services/image_classifier.dart';
import '../../core/services/image_processor.dart';
import '../../core/services/logger_service.dart';
import '../../core/services/material_detector.dart';
import '../../domain/entities/recycle_result.dart';
import '../../domain/repositories/recycle_repository.dart';
import '../../domain/repositories/recycle_rules.dart';

/// Implementación del repositorio de análisis de reciclaje.
/// Coordina el pipeline completo: imagen -> preprocesamiento ->
/// clasificación -> reglas -> resultado.
class RecycleRepositoryImpl implements RecycleRepository {
  final ImageClassifier _classifier;
  final ImageProcessor _processor;
  final MaterialDetector _detector;
  final RecycleRules _rules;

  bool _isInitialized = false;

// ignore_for_file: prefer_initializing_formals
  RecycleRepositoryImpl({
    required ImageClassifier classifier,
    required ImageProcessor processor,
    required RecycleRules rules,
  })  : _classifier = classifier,
        _processor = processor,
        _rules = rules,
        _detector = MaterialDetector(classifier: classifier, rules: rules);

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      LoggerService.instance.info('Inicializando repositorio de análisis...');

      await _classifier.loadModel();
      await _classifier.loadLabels(AppConfig.labelsPath);
      await _rules.initialize();

      _isInitialized = true;
      LoggerService.instance.info('Repositorio inicializado correctamente');
    } catch (e) {
      _isInitialized = false;
      LoggerService.instance.error('Error al inicializar repositorio', e);
      rethrow;
    }
  }

  @override
  Future<RecycleResult> analyzeImage(File imageFile) async {
    if (!_isInitialized) {
      throw const InferenceException(
        message: 'El repositorio no ha sido inicializado.',
      );
    }

    try {
      LoggerService.instance.info('Iniciando análisis de imagen...');

      // Paso 1: Preprocesar imagen
      final tensor = await _processor.processImage(imageFile);

      // Paso 2: Detectar material con clasificador + reglas
      final detection = await _detector.detectFromImage(tensor);

      // Paso 3: Construir resultado
      final result = RecycleResult(
        detectedObject: detection.rule.label,
        material: detection.rule.material,
        confidence: detection.confidence,
        isRecyclable: detection.rule.recyclable,
        isReusable: detection.rule.reusable,
        containerColor: detection.rule.containerColor,
        description: detection.rule.description,
        recommendation: detection.rule.recommendation,
      );

      LoggerService.instance.info(
        'Análisis completado: ${result.detectedObject} '
        '(${result.material}) - ${result.containerColor}',
      );

      return result;
    } catch (e) {
      LoggerService.instance.error('Error durante el análisis', e);
      if (e is AppException) rethrow;
      throw InferenceException(originalError: e);
    }
  }

  @override
  void dispose() {
    _classifier.dispose();
    _isInitialized = false;
    LoggerService.instance.info('Repositorio liberado');
  }
}
