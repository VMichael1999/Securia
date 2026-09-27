import 'package:flutter/material.dart';

/// Paleta de colores tácticos y de alta visibilidad para Securia Patrullaje / PNP
class PatrolColors {
  PatrolColors._();

  // Fondos y Superficies Oscuras: Negro y Azul Oscuro
  static const Color background = Color(0xFF000000); // Negro puro de fondo
  static const Color surface = Color(0xFF050811); // Negro profundo
  static const Color surfaceElevated = Color(0xFF0F1E38); // Azul oscuro elevado
  static const Color surfaceCard = Color(0xFF0A1426); // Tarjetas en Azul oscuro sobre negro
  static const Color surfaceBorder = Color(0xFF1E2F4D); // Borde azul oscuro sutil

  // Colores Primarios Policiales: Verde, Azul oscuro y Negro
  static const Color tacticalNavy = Color(0xFF0F2447); // Azul oscuro institucional
  static const Color tacticalBlue = Color(0xFF0F2447); // Azul oscuro
  static const Color policeBlue = Color(0xFF0F2447); // Azul oscuro institucional
  static const Color policeAccent = Color(0xFF10B981); // Verde de seguridad
  static const Color policeLight = Color(0xFF34D399); // Verde claro de alta visibilidad
  static const Color policeGreenDark = Color(0xFF064E3B); // Verde casi oscuro institucional
  static const Color overlayScrim = Color(0xD9000000); // Velo negro para alertas a pantalla completa
  static const Color cyanAccent = Color(0xFF10B981);
  static const Color cyanGlow = Color(0x3310B981);

  // Estados de Alerta y Respuesta
  static const Color alertCrimson = Color(0xFFEF4444); // Rojo sólido de emergencia
  static const Color alertCrimsonGlow = Color(0x3DEF4444);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color successGreen = Color(0xFF10B981); // Verde
  static const Color infoBlue = Color(0xFF0F2447);

  // Textos y Contraste de Alta Densidad: Blanco puro sobre superficies oscuras
  static const Color textPrimary = Color(0xFFFFFFFF); // Blanco puro (nunca blanco sobre blanco)
  static const Color textSecondary = Color(0xFF94A3B8); // Gris claro legible
  static const Color textMuted = Color(0xFF64748B);

  // Gradientes
  static const LinearGradient tacticalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF000000), // Negro
      Color(0xFF0F2447), // Azul oscuro
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
