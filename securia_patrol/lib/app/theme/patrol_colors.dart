import 'package:flutter/material.dart';

/// Paleta de colores tácticos y de alta visibilidad para Securia Patrullaje / PNP
class PatrolColors {
  PatrolColors._();

  // Fondos Tácticos Oscuros
  static const Color background = Color(0xFF0A0F1D);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceElevated = Color(0xFF1E293B);
  static const Color surfaceCard = Color(0xFF161F36);
  static const Color surfaceBorder = Color(0xFF27354E);

  // Colores Primarios Policiales
  static const Color tacticalNavy = Color(0xFF0F2042);
  static const Color tacticalBlue = Color(0xFF1E40AF);
  static const Color policeBlue = Color(0xFF2563EB);
  static const Color cyanAccent = Color(0xFF00E5FF);
  static const Color cyanGlow = Color(0x3300E5FF);

  // Estados de Alerta y Respuesta
  static const Color alertCrimson = Color(0xFFEF4444);
  static const Color alertCrimsonGlow = Color(0x4DEF4444);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color successGreen = Color(0xFF10B981);
  static const Color infoBlue = Color(0xFF38BDF8);

  // Textos Tácticos
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Gradientes
  static const LinearGradient tacticalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
    ],
  );

  static const LinearGradient policeSirenGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFEF4444),
      Color(0xFF2563EB),
    ],
  );
}
