import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/services/logger_service.dart';
import 'core/services/service_provider.dart';
import 'presentation/pages/main_shell.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/viewmodels/recycle_viewmodel.dart';
import 'modules/maps/core/di/map_service_provider.dart';
import 'modules/maps/presentation/viewmodels/map_viewmodel.dart';

/// Punto de entrada de la aplicación rECOCam.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LoggerService.instance.init();
  LoggerService.instance.info('Iniciando rECOCam...');

  await AppConfig.init();

  // Inicializar contenedor de dependencias
  ServiceProvider.instance.initialize();
  MapServiceProvider.instance.initialize();

  runApp(const RecoCamApp());
}

/// Widget raíz de la aplicación con inyección de dependencias.
class RecoCamApp extends StatelessWidget {
  const RecoCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = ServiceProvider.instance;
    final msp = MapServiceProvider.instance;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RecycleViewModel(
            cameraService: sp.cameraService,
            repository: sp.repository,
          )..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => MapViewModel(
            getRecyclePointsUseCase: msp.getRecyclePointsUseCase,
            locationService: msp.locationService,
            connectivityService: msp.connectivityService,
            repository: msp.mapRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'rECOCam',
        debugShowCheckedModeBanner: false,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
        onGenerateRoute: AppRouter.generateRoute,
        home: const MainShell(),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorSchemeSeed: const Color(0xFF2E7D32),
      useMaterial3: true,
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorSchemeSeed: const Color(0xFF2E7D32),
      useMaterial3: true,
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
