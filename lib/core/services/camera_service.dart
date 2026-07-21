import 'dart:io';

import 'package:camera/camera.dart' hide CameraException;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/app_config.dart';
import '../exceptions/app_exceptions.dart';
import '../utils/image_utils.dart';
import 'logger_service.dart';

/// Servicio para gestión de cámara y captura de imágenes.
/// Implementa el patrón Singleton para manejar un único controlador de cámara.
class CameraService {
  CameraService._();

  static final CameraService _instance = CameraService._();
  static CameraService get instance => _instance;

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  CameraController? get controller => _cameraController;

  /// Solicita permisos de cámara.
  Future<bool> requestPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      LoggerService.instance.warning('Permiso de cámara denegado');
      return false;
    }
    return true;
  }

  /// Inicializa la cámara con la cámara trasera por defecto.
  Future<void> initializeCamera({
    ResolutionPreset resolution = ResolutionPreset.high,
  }) async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw const AppCameraException(
          message: 'No se encontraron cámaras disponibles.',
        );
      }

      final backCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        resolution,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      _isInitialized = true;

      LoggerService.instance.info('Cámara inicializada correctamente');
    } catch (e) {
      _isInitialized = false;
      if (e is AppException) rethrow;
      throw AppCameraException(originalError: e);
    }
  }

  /// Captura una foto usando la cámara y retorna el archivo redimensionado.
  Future<File> capturePhoto() async {
    if (!_isInitialized || _cameraController == null) {
      throw const AppCameraException(
        message: 'La cámara no está inicializada.',
      );
    }

    try {
      final XFile xFile = await _cameraController!.takePicture();
      final File originalFile = File(xFile.path);

      final File resizedFile = ImageUtils.resizeImage(
        imageFile: originalFile,
        maxWidth: AppConfig.maxImageWidth,
        maxHeight: AppConfig.maxImageHeight,
      );

      LoggerService.instance.info(
        'Foto capturada: ${resizedFile.path} '
        '(${ImageUtils.getFileSizeKB(resizedFile).toStringAsFixed(1)} KB)',
      );

      return resizedFile;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppCameraException(originalError: e);
    }
  }

  /// Abre la galería del dispositivo para seleccionar una imagen.
  Future<File?> pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConfig.maxImageWidth.toDouble(),
        maxHeight: AppConfig.maxImageHeight.toDouble(),
        imageQuality: AppConfig.imageQuality,
      );

      if (pickedFile == null) return null;

      final File file = File(pickedFile.path);
      LoggerService.instance.info(
        'Imagen seleccionada de galería: ${file.path}',
      );

      return file;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppCameraException(originalError: e);
    }
  }

  /// Cambia el flash mode de la cámara.
  Future<void> toggleFlash() async {
    if (_cameraController == null || !_isInitialized) return;

    final currentMode = _cameraController!.value.flashMode;
    final newMode = currentMode == FlashMode.off
        ? FlashMode.auto
        : currentMode == FlashMode.auto
            ? FlashMode.always
            : FlashMode.off;

    await _cameraController!.setFlashMode(newMode);
  }

  /// Libera los recursos de la cámara.
  Future<void> dispose() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
      _isInitialized = false;
      LoggerService.instance.info('Cámara liberada correctamente');
    }
  }
}
