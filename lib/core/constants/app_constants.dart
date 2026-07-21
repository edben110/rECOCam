import 'package:flutter/material.dart';

/// Constantes de la aplicación incluyendo colores, textos y valores por defecto.
class AppConstants {
  AppConstants._();

  // Colores de contenedores según normativa colombiana
  static const Map<String, Color> containerColors = {
    'Amarillo': Color(0xFFFFD600),
    'Azul': Color(0xFF2962FF),
    'Verde': Color(0xFF00C853),
    'Blanco': Color(0xFFE0E0E0),
    'Negro': Color(0xFF212121),
    'Gris': Color(0xFF757575),
    'Rojo': Color(0xFFD50000),
  };

  // Iconos por tipo de material
  static const Map<String, IconData> materialIcons = {
    'Plástico': Icons.local_drink,
    'Vidrio': Icons.wine_bar,
    'Metal': Icons.hardware,
    'Papel': Icons.description,
    'Cartón': Icons.inventory_2,
    'Cartón contaminado': Icons.delete,
    'Orgánico': Icons.eco,
    'Electrónico': Icons.devices,
    'Textil': Icons.checkroom,
    'Mixto': Icons.category,
    'Desconocido': Icons.help_outline,
  };

  // Estados de reciclaje
  static const String recyclable = 'Reciclable';
  static const String notRecyclable = 'No Reciclable';
  static const String reusable = 'Reutilizable';
  static const String notReusable = 'No Reutilizable';

  // Mensajes
  static const String analyzingMessage = 'Analizando imagen...';
  static const String noResultsMessage = 'No se pudo identificar el objeto.';
  static const String errorMessage = 'Error al procesar la imagen.';
  static const String cameraPermissionMessage =
      'Se necesita permiso de cámara para tomar fotos.';
  static const String defaultRecommendation =
      'Consulta con tu autoridad ambiental local para disposición adecuada.';
}
