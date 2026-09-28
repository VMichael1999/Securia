import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';

/// Paleta "Sereno" de la app policial (oscura, para usar de noche).
///
/// Cada color tiene un solo trabajo:
/// - [action]: la acción principal y la ayuda en marcha (verde)
/// - [critical]: urgencia crítica y alerta entrante (rojo). Nada más es rojo.
/// - [high]: urgencia alta (ámbar)
/// - Todo lo demás en negro, azul oscuro, blanco y grises.
class PatrolColors {
  PatrolColors._();

  // Superficies
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF050811);
  static const Color card = Color(0xFF0A1426);
  static const Color elevated = Color(0xFF0F1E38);
  static const Color border = Color(0xFF1E2F4D);

  // Texto
  static const Color ink = Color(0xFFFFFFFF);
  static const Color inkSecondary = Color(0xFFDDE4EE);
  static const Color inkMuted = Color(0xFF94A3B8);

  // Acción principal y ayuda en marcha
  static const Color action = Color(0xFF34D399);
  static const Color onAction = Color(0xFF02140D);

  /// Fondo de una opción elegida (verde muy oscuro)
  static const Color actionSoft = Color(0xFF0B2A20);

  // Urgencia
  /// Texto e íconos de urgencia crítica sobre fondos oscuros
  static const Color critical = Color(0xFFEF4444);

  /// Relleno de urgencia crítica: con texto blanco llega a 4.5:1
  static const Color criticalFill = Color(0xFFDC2626);
  static const Color onCritical = Color(0xFFFFFFFF);
  static const Color high = Color(0xFFF59E0B);

  /// Velo sobre el mapa detrás de la alerta entrante
  static const Color scrim = Color(0xDB000000);

  /// Color de marca y texto de una urgencia
  static Color urgency(UrgencyLevel level) => switch (level) {
    UrgencyLevel.critica => critical,
    UrgencyLevel.alta => high,
    UrgencyLevel.media || UrgencyLevel.baja => inkMuted,
  };
}
