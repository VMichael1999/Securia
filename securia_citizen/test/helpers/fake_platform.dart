import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simula la plataforma para pantallas con mapa y tipografía remota:
/// - `path_provider`, que usa el caché de tiles de flutter_map
/// - red sin respuesta, para que google_fonts no falle al descargar fuentes
///   (en tests se usa la fuente por defecto)
void mockPlatformPlugins() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (_) async => Directory.systemTemp.path,
      );
  HttpOverrides.global = _OfflineHttpOverrides();
}

/// Simula un dispositivo sin cámara: image_picker falla y la app adjunta
/// la evidencia simulada
void mockNoCamera() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/image_picker'),
        (_) async => throw PlatformException(code: 'no_available_camera'),
      );
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
