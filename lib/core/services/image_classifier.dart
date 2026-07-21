import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../config/app_config.dart';
import '../exceptions/app_exceptions.dart';
import 'logger_service.dart';

/// Resultado crudo de la inferencia del modelo TFLite.
class ClassificationResult {
  final String label;
  final double confidence;
  final int index;

  const ClassificationResult({
    required this.label,
    required this.confidence,
    required this.index,
  });

  @override
  String toString() =>
      'ClassificationResult(label: $label, confidence: $confidence)';
}

/// Servicio exclusivo de inferencia con TensorFlow Lite.
/// Responsabilidades: cargar modelo, cargar labels, ejecutar inferencia
/// sobre un tensor preprocesado y devolver resultados.
class ImageClassifier {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<String> get labels => List.unmodifiable(_labels);

  /// Carga el modelo TFLite desde los assets del bundle.
  Future<void> loadModel() async {
    try {
      LoggerService.instance.info('Cargando modelo TFLite...');

      final options = InterpreterOptions()..threads = AppConfig.numThreads;

      _interpreter = await Interpreter.fromAsset(
        AppConfig.modelPath,
        options: options,
      );

      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      LoggerService.instance.info(
        'Modelo cargado exitosamente. '
        'Input: $inputShape, Output: $outputShape',
      );

      _isLoaded = true;
    } catch (e) {
      _isLoaded = false;
      LoggerService.instance.error('Error al cargar el modelo TFLite', e);
      throw ModelLoadException(originalError: e);
    }
  }

  /// Carga las etiquetas desde un asset del bundle Flutter.
  Future<void> loadLabels(String assetPath) async {
    try {
      LoggerService.instance.info('Cargando labels desde: $assetPath');

      final String labelsData = await rootBundle.loadString(assetPath);

      _labels = labelsData
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.trim())
          .toList();

      LoggerService.instance.info('${_labels.length} labels cargados');
    } catch (e) {
      LoggerService.instance.error('Error al cargar labels', e);
      throw ModelLoadException(originalError: e);
    }
  }

  /// Ejecuta la inferencia sobre un tensor preprocesado.
  /// El tensor debe tener forma [1, inputSize, inputSize, 3] con
  /// valores uint8 en [0, 255] (formato del modelo cuantizado Coral).
  Future<List<ClassificationResult>> classifyFromTensor(
    Uint8List inputBuffer,
  ) async {
    if (!_isLoaded || _interpreter == null) {
      throw const InferenceException(
        message: 'El modelo no ha sido cargado.',
      );
    }

    try {
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final outputSize = outputShape[1];
      final outputBuffer = Uint8List(outputSize);

      _interpreter!.run(inputBuffer, outputBuffer);

      final results = <ClassificationResult>[];
      for (var i = 0; i < outputSize && i < _labels.length; i++) {
        results.add(ClassificationResult(
          label: _labels[i],
          confidence: outputBuffer[i] / 255.0,
          index: i,
        ));
      }

      results.sort((a, b) => b.confidence.compareTo(a.confidence));

      LoggerService.instance.debug(
        'Inferencia completada. Top: '
        '${results.first.label} (${results.first.confidence})',
      );

      return results;
    } catch (e) {
      if (e is AppException) rethrow;
      throw InferenceException(originalError: e);
    }
  }

  /// Libera el intérprete TFLite.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
    LoggerService.instance.info('Intérprete TFLite liberado');
  }
}
