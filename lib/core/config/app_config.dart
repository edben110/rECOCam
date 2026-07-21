import 'package:shared_preferences/shared_preferences.dart';

/// Configuración centralizada de la aplicación.
/// Patrón Singleton para garantizar una única instancia.
class AppConfig {
  AppConfig._();

  static const String appName = 'rECOCam';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Aplicación de clasificación de residuos reciclables con IA local';

  // Rutas de assets
  static const String modelPath = 'assets/models/mobilenet_v3_large.tflite';
  static const String labelsPath = 'assets/labels/labels.txt';
  static const String knowledgeBasePath = 'assets/json/recycle_rules.json';

  // Parámetros del modelo
  static const int inputSize = 224;
  static const int numChannels = 3;
  static const int numThreads = 4;

  // Parámetros de imagen
  static const int imageQuality = 85;
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;

  // Umbrales de confianza
  static const double confidenceThreshold = 0.3;
  static const double highConfidenceThreshold = 0.7;

  // SharedPreferences keys
  static const String keyLastAnalysis = 'last_analysis';
  static const String keyAnalysisCount = 'analysis_count';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs => _prefs;
}
