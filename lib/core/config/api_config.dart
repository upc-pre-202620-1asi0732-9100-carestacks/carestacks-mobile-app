import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig._();

  /// Puerto del backend local.
  static const String _localPort = '8080';

  /// Permite sobreescribir la URL en tiempo de compilación:
  ///   flutter run --dart-define=API_BASE_URL=https://mi-backend.com
  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;

    // El emulador de Android accede a la máquina host vía 10.0.2.2.
    // iOS simulator / desktop / web usan localhost directamente.
    final host = (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
        ? '10.0.2.2'
        : 'localhost';
    return 'http://$host:$_localPort';
  }
}
