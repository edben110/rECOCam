/// Utilidades de formato para la presentación de datos.
class FormatUtils {
  FormatUtils._();

  /// Formatea un porcentaje de confianza.
  static String formatConfidence(double confidence) {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }

  /// Capitaliza la primera letra de un string.
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Convierte snake_case a Title Case.
  static String snakeCaseToTitle(String text) {
    return text
        .split('_')
        .map((word) => capitalize(word))
        .join(' ');
  }
}
