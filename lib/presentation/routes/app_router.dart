import 'package:flutter/material.dart';

import '../pages/home/home_page.dart';
import '../../modules/maps/presentation/pages/map_page.dart';

/// Centraliza las rutas de navegación de la aplicación.
class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String result = '/result';
  static const String map = '/map';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );

      case result:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );

      case map:
        return MaterialPageRoute(
          builder: (_) => const MapPage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
