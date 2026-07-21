import 'package:logger/logger.dart';

/// Servicio de logging centralizado.
/// Singleton que wrapping el paquete `logger`.
class LoggerService {
  LoggerService._();

  static final LoggerService _instance = LoggerService._();
  static LoggerService get instance => _instance;

  late final Logger _logger;

  void init() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
      ),
      level: Level.debug,
    );
  }

  void debug(String message) => _logger.d(message);
  void info(String message) => _logger.i(message);
  void warning(String message) => _logger.w(message);
  void error(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.f(message, error: error, stackTrace: stackTrace);
}
