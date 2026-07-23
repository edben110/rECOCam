import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/services/logger_service.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    final connected = results.any((r) => r != ConnectivityResult.none);
    LoggerService.instance.debug(
      'Conectividad: ${connected ? "conectado" : "sin conexión"}',
    );
    return connected;
  }

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      return results.any((r) => r != ConnectivityResult.none);
    });
  }
}
