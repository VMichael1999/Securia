import 'package:flutter/material.dart';

/// Paleta de colores para la aplicación ciudadana Securia
///
/// Base: azul casi oscuro, verde casi oscuro y blanco.
/// El rojo se reserva exclusivamente para SOS y alertas, para que el ojo
/// lo encuentre al instante en una emergencia.
class AppColors {
  // Fondos y Superficies
  static const Color background = Color(0xFFF7F9FA);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF0F4F3);
  static const Color surfaceDark = Color(0xFF0F2447);

  // Colores Primarios Ciudadano: Azul casi oscuro, Verde casi oscuro y Blanco
  static const Color primaryNavy = Color(0xFF0F2447);
  static const Color primaryBlue = Color(0xFF0F2447);
  static const Color primaryGreen = Color(0xFF0B5D3E);
  static const Color primaryGreenLight = Color(0xFFE3F1EA);
  static const Color accentBlue = primaryGreen; // Acento activo = verde oscuro
  static const Color securityGreen = primaryGreen;
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Estados de Emergencia y Alerta (exclusivo para SOS y pánico ciudadano)
  static const Color emergencyRed = Color(0xFFDC2626);
  static const Color emergencyRedDark = Color(0xFF991B1B);
  static const Color emergencyRedLight = Color(0xFFFEE2E2);
  static const Color emergencyPulse = Color(0xFFEF4444);
  static const Color warningOrange = Color(0xFFEA580C);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color successEmerald = Color(0xFF0E7A4F);
  static const Color successLight = primaryGreenLight;

  // Textos y Bordes
  static const Color textPrimary = Color(0xFF0F2447);
  static const Color textSecondary = Color(0xFF5B6B7F);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFCBD5E1);

  // Gradientes
  static const LinearGradient sosGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFF991B1B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyGradient = LinearGradient(
    colors: [Color(0xFF0F2447), Color(0xFF0B3A2C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
