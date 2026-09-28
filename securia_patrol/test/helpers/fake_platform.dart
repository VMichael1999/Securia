import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securia_core/securia_core.dart';

/// Simula la plataforma para pantallas con mapa:
/// - Google Maps no existe en pruebas: se dibuja el mapa falso de SecuriaMap
/// - `path_provider` y red sin respuesta, por si algún plugin los pide
void mockPlatformPlugins() {
  SecuriaMap.debugUseFakeMap = true;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (_) async => Directory.systemTemp.path,
      );
  HttpOverrides.global = _OfflineHttpOverrides();
}

class _OfflineHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _PendingHttpClient();
}

/// Cliente cuyas peticiones nunca responden (ni éxito ni error)
class _PendingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isMethod) return Completer<HttpClientRequest>().future;
    return null;
  }
}
