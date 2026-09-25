import 'package:flutter/material.dart';

/// Paleta de colores para la aplicación ciudadana Securia
class AppColors {
  // Fondos y Superficies
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color surfaceDark = Color(0xFF0F2447);

  // Colores Primarios Ciudadano: Azul casi oscuro, Verde y Blanco
  static const Color primaryNavy = Color(0xFF0F2447);
  static const Color primaryBlue = Color(0xFF0F2447);
  static const Color accentBlue = Color(0xFF10B981); // Verde de seguridad como acento activo
  static const Color securityGreen = Color(0xFF10B981);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Estados de Emergencia y Alerta (exclusivo para SOS y pánico ciudadano)
  static const Color emergencyRed = Color(0xFFDC2626);
  static const Color emergencyRedLight = Color(0xFFFEE2E2);
  static const Color emergencyPulse = Color(0xFFEF4444);
  static const Color warningOrange = Color(0xFFEA580C);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color successEmerald = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);

  // Textos y Bordes
  static const Color textPrimary = Color(0xFF0F2447);
  static const Color textSecondary = Color(0xFF64748B);
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
    colors: [Color(0xFF0F2447), Color(0xFF1A365D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
