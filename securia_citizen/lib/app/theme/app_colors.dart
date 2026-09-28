import 'package:flutter/material.dart';

/// Paleta "Sereno" de la app ciudadana.
///
/// Cada color tiene un solo trabajo:
/// - [ink]: texto y acciones (azul casi oscuro)
/// - [help]: la ayuda en marcha (verde casi oscuro)
/// - [sos]: solo el SOS y tu alerta activa. Nada más es rojo.
/// - [urgencyHigh]: urgencia alta (ámbar), solo donde se muestra urgencia
/// - [incident]: incidentes de otros, en azul neutro para no competir con el SOS
class AppColors {
  AppColors._();

  // Superficies
  static const Color background = Color(0xFFF7F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF2F4);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);

  // Texto y acciones
  static const Color ink = Color(0xFF0F2447);
  static const Color inkSecondary = Color(0xFF4A5A6E);
  static const Color inkMuted = Color(0xFF64748B);

  /// Texto e íconos sobre fondos de color (ink, help, sos)
  static const Color onColor = Color(0xFFFFFFFF);

  // Ayuda en marcha
  static const Color help = Color(0xFF0B5D3E);
  static const Color helpSoft = Color(0xFFE3F1EA);

  // SOS y alerta propia
  static const Color sos = Color(0xFFDC2626);
  static const Color sosPressed = Color(0xFF991B1B);
  static const Color sosSoft = Color(0xFFFEE2E2);

  // Urgencia alta (ámbar legible sobre blanco)
  static const Color urgencyHigh = Color(0xFFB45309);
  static const Color urgencyHighSoft = Color(0xFFFEF3C7);

  /// Incidentes reportados por otros vecinos
  static const Color incident = Color(0xFF3D5A80);

  /// Velo que apaga la pantalla mientras se mantiene el SOS
  static const Color scrim = Color(0xB30F2447);
}
