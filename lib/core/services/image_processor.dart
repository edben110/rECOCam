import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../config/app_config.dart';
import '../exceptions/app_exceptions.dart';
import '../services/logger_service.dart';

/// Servicio de preprocesamiento de imágenes para el modelo TFLite.
/// Responsabilidades: redimensionar, decodificar y convertir imágenes
/// a tensores float normalizados compatibles con el modelo.
class ImageProcessor {
  /// Convierte un archivo de imagen a un tensor Uint8List con valores [0, 255]
  /// con forma [1, inputSize, inputSize, 3] (formato cuantizado).
  Future<Uint8List> processImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: AppConfig.inputSize,
        targetHeight: AppConfig.inputSize,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      if (byteData == null) {
        throw const ImageProcessingException(
          message: 'No se pudieron extraer los datos de la imagen.',
        );
      }

      final inputBuffer = _convertRgbaToRgbUint8(byteData);

      image.dispose();

      LoggerService.instance.debug(
        'Imagen procesada: ${AppConfig.inputSize}x${AppConfig.inputSize}x3',
      );

      return inputBuffer;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ImageProcessingException(originalError: e);
    }
  }

  /// Convierte datos RGBA a un buffer RGB uint8 [0,255] para modelo cuantizado.
  Uint8List _convertRgbaToRgbUint8(ByteData rgba) {
    final width = AppConfig.inputSize;
    final height = AppConfig.inputSize;
    final buffer = Uint8List(width * height * 3);

    var idx = 0;
    for (var i = 0; i < rgba.lengthInBytes; i += 4) {
      buffer[idx++] = rgba.getUint8(i);     // R
      buffer[idx++] = rgba.getUint8(i + 1); // G
      buffer[idx++] = rgba.getUint8(i + 2); // B
    }

    return buffer;
  }
}
