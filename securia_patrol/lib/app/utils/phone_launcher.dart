import 'package:url_launcher/url_launcher.dart';

/// Inicia llamadas telefónicas desde la app (ciudadano, central).
class PhoneLauncher {
  PhoneLauncher._();

  /// Abre el marcador con [number]. Devuelve `false` si el dispositivo no puede.
  static Future<bool> call(String number) async {
    final uri = Uri(scheme: 'tel', path: number.replaceAll(' ', ''));
    try {
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }
}
