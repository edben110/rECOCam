import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../exceptions/app_exceptions.dart';

/// Utilidades para procesamiento y manipulación de imágenes.
class ImageUtils {
  ImageUtils._();

  /// Redimensiona una imagen manteniendo la proporción.
  static File resizeImage({
    required File imageFile,
    required int maxWidth,
    required int maxHeight,
  }) {
    try {
      final bytes = imageFile.readAsBytesSync();
      final decoded = img.decodeImage(bytes);

      if (decoded == null) {
        throw const ImageProcessingException(
          message: 'No se pudo decodificar la imagen.',
        );
      }

      final resized = img.copyResize(
        decoded,
        width: maxWidth <= 0 ? null : maxWidth,
        height: maxHeight <= 0 ? null : maxHeight,
        maintainAspect: true,
      );

      final resizedBytes = img.encodeJpg(resized, quality: 85);
      final outputPath = imageFile.path.replaceAll(
        RegExp(r'\.[^.]+$'),
        '_resized.jpg',
      );

      return File(outputPath)
        ..writeAsBytesSync(resizedBytes);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ImageProcessingException(originalError: e);
    }
  }

  /// Convierte un archivo de imagen a bytes normalizados para el modelo TFLite.
  /// Retorna un tensor Float32 de forma [1, 224, 224, 3] con valores en [0, 1].
  static Float32List imageToTensor({
    required File imageFile,
    required int inputSize,
  }) {
    try {
      final bytes = imageFile.readAsBytesSync();
      final decoded = img.decodeImage(bytes);

      if (decoded == null) {
        throw const ImageProcessingException(
          message: 'No se pudo decodificar la imagen para conversión a tensor.',
        );
      }

      final resized = img.copyResize(
        decoded,
        width: inputSize,
        height: inputSize,
        maintainAspect: false,
      );

      final inputBuffer = Float32List(1 * inputSize * inputSize * 3);
      var index = 0;

      for (var y = 0; y < inputSize; y++) {
        for (var x = 0; x < inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          inputBuffer[index++] = pixel.r / 255.0;
          inputBuffer[index++] = pixel.g / 255.0;
          inputBuffer[index++] = pixel.b / 255.0;
        }
      }

      return inputBuffer;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ImageProcessingException(originalError: e);
    }
  }

  /// Obtiene el tamaño de archivo en KB.
  static double getFileSizeKB(File file) {
    final bytes = file.lengthSync();
    return bytes / 1024;
  }

  /// Genera un nombre de archivo temporal único.
  static String generateTempFileName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'recocam_${timestamp}_$random.jpg';
  }
}
