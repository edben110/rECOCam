import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/exceptions/app_exceptions.dart';
import '../../core/services/camera_service.dart';
import '../../core/services/logger_service.dart';
import '../../domain/entities/recycle_result.dart';
import '../../domain/repositories/recycle_repository.dart';

/// ViewModel principal para la pantalla de análisis de reciclaje.
/// Implementa ChangeNotifier para notificar a la UI sobre cambios de estado.
/// Sigue el patrón MVVM separando la lógica de presentación de la vista.
/// Recibe todas sus dependencias por inyección de dependencias.
class RecycleViewModel extends ChangeNotifier {
  final CameraService _cameraService;
  final RecycleRepository _repository;

// ignore_for_file: prefer_initializing_formals
  RecycleViewModel({
    required CameraService cameraService,
    required RecycleRepository repository,
  })  : _cameraService = cameraService,
        _repository = repository;

  bool _isLoading = false;
  bool _isInitialized = false;
  String _errorMessage = '';
  File? _capturedImage;
  RecycleResult? _result;
  bool _showCamera = false;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String get errorMessage => _errorMessage;
  File? get capturedImage => _capturedImage;
  RecycleResult? get result => _result;
  bool get showCamera => _showCamera;

  /// Inicializa el repositorio (modelo TFLite + base de conocimiento).
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    _clearError();

    try {
      await _repository.initialize();
      _isInitialized = true;
      LoggerService.instance.info('RecycleViewModel inicializado');
    } catch (e) {
      _setError('Error al inicializar: ${_getErrorMessage(e)}');
      LoggerService.instance.error('Error al inicializar ViewModel', e);
    } finally {
      _setLoading(false);
    }
  }

  /// Inicializa la cámara para captura.
  Future<void> initializeCamera() async {
    final hasPermission = await _cameraService.requestPermission();
    if (!hasPermission) {
      _setError(
        'Permiso de cámara denegado. Concede el permiso desde configuración.',
      );
      return;
    }

    _setLoading(true);
    try {
      await _cameraService.initializeCamera();
      _showCamera = true;
      notifyListeners();
    } catch (e) {
      _setError('Error al inicializar cámara: ${_getErrorMessage(e)}');
    } finally {
      _setLoading(false);
    }
  }

  /// Captura una foto desde la cámara.
  Future<void> capturePhoto() async {
    _setLoading(true);
    _clearError();

    try {
      final File photo = await _cameraService.capturePhoto();
      _capturedImage = photo;
      _showCamera = false;
      notifyListeners();

      await _analyzeImage(photo);
    } catch (e) {
      _setError('Error al capturar foto: ${_getErrorMessage(e)}');
    } finally {
      _setLoading(false);
    }
  }

  /// Selecciona una imagen desde la galería.
  Future<void> pickFromGallery() async {
    _setLoading(true);
    _clearError();

    try {
      final File? image = await _cameraService.pickFromGallery();
      if (image == null) {
        _setLoading(false);
        return;
      }

      _capturedImage = image;
      notifyListeners();

      await _analyzeImage(image);
    } catch (e) {
      _setError('Error al seleccionar imagen: ${_getErrorMessage(e)}');
    } finally {
      _setLoading(false);
    }
  }

  /// Analiza la imagen usando el pipeline completo del repositorio.
  Future<void> _analyzeImage(File imageFile) async {
    _setLoading(true);
    _clearError();

    try {
      _result = await _repository.analyzeImage(imageFile);
      notifyListeners();
    } catch (e) {
      _setError('Error durante el análisis: ${_getErrorMessage(e)}');
      LoggerService.instance.error('Error en análisis de imagen', e);
    } finally {
      _setLoading(false);
    }
  }

  /// Resetea el estado para análisis de una nueva imagen.
  void resetAnalysis() {
    _capturedImage = null;
    _result = null;
    _showCamera = false;
    _clearError();
    notifyListeners();
  }

  /// Muestra la cámara para una nueva captura.
  void showCameraView() {
    _showCamera = true;
    notifyListeners();
  }

  /// Oculta la cámara.
  void hideCameraView() {
    _showCamera = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
  }

  String _getErrorMessage(dynamic error) {
    if (error is AppException) return error.message;
    return error.toString();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _repository.dispose();
    super.dispose();
  }
}
