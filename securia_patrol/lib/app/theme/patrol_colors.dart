import 'package:flutter/material.dart';

/// Paleta de colores tácticos y de alta visibilidad para Securia Patrullaje / PNP
class PatrolColors {
  PatrolColors._();

  // Fondos y Superficies Limpias (Iguales al aplicativo ciudadano)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceElevated = Colors.white;
  static const Color surfaceCard = Colors.white;
  static const Color surfaceBorder = Color(0xFFE2E8F0);

  // Colores Primarios: Azul casi oscuro, Verde y Blanco
  static const Color tacticalNavy = Color(0xFF0F2447);
  static const Color tacticalBlue = Color(0xFF0F2447);
  static const Color policeBlue = Color(0xFF0F2447);
  static const Color policeAccent = Color(0xFF10B981); // Verde de seguridad
  static const Color policeLight = Color(0xFFD1FAE5);
  static const Color cyanAccent = Color(0xFF10B981);
  static const Color cyanGlow = Color(0x3310B981);

  // Estados de Alerta y Respuesta
  static const Color alertCrimson = Color(0xFFDC2626);
  static const Color alertCrimsonGlow = Color(0x3DDC2626);
  static const Color warningAmber = Color(0xFFEA580C);
  static const Color successGreen = Color(0xFF10B981);
  static const Color infoBlue = Color(0xFF0F2447);

  // Textos y Contraste de Alta Legibilidad sobre fondos claros
  static const Color textPrimary = Color(0xFF0F2447);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Gradientes
  static const LinearGradient tacticalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F2447),
      Color(0xFF1A365D),
    ],
  );

  static const LinearGradient policeSirenGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFEF4444),
      Color(0xFF991B1B),
    ],
  );
}
