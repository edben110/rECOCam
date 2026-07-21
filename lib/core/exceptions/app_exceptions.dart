/// Excepción base para todas las excepciones personalizadas de la aplicación.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException($code): $message';
}

/// Excepción para errores de carga del modelo TFLite.
class ModelLoadException extends AppException {
  const ModelLoadException({
    super.message = 'Error al cargar el modelo de IA.',
    super.originalError,
  }) : super(code: 'MODEL_LOAD_ERROR');
}

/// Excepción para errores durante la inferencia.
class InferenceException extends AppException {
  const InferenceException({
    super.message = 'Error al ejecutar la inferencia.',
    super.originalError,
  }) : super(code: 'INFERENCE_ERROR');
}

/// Excepción para errores de procesamiento de imagen.
class ImageProcessingException extends AppException {
  const ImageProcessingException({
    super.message = 'Error al procesar la imagen.',
    super.originalError,
  }) : super(code: 'IMAGE_PROCESSING_ERROR');
}

/// Excepción para errores de cámara.
class AppCameraException extends AppException {
  const AppCameraException({
    super.message = 'Error con la cámara.',
    super.originalError,
  }) : super(code: 'CAMERA_ERROR');
}

/// Excepción para errores de permisos.
class PermissionException extends AppException {
  const PermissionException({
    super.message = 'Permisos denegados.',
    super.originalError,
  }) : super(code: 'PERMISSION_ERROR');
}

/// Excepción para errores de la base de conocimiento.
class KnowledgeBaseException extends AppException {
  const KnowledgeBaseException({
    super.message = 'Error al acceder a la base de conocimiento.',
    super.originalError,
  }) : super(code: 'KNOWLEDGE_BASE_ERROR');
}
