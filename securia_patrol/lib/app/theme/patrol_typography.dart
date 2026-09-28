import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import 'patrol_colors.dart';

/// Tipografía de la app policial: Plus Jakarta Sans empaquetada en
/// securia_core (funciona sin internet) y JetBrains Mono para la telemetría.
class PatrolTypography {
  PatrolTypography._();

  static TextStyle _sans(
    double size,
    FontWeight weight,
    Color? color, {
    double? height,
  }) => TextStyle(
    fontFamily: SecuriaFonts.sans,
    package: SecuriaFonts.package,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );

  /// Título de la alerta entrante: se lee de reojo
  static TextStyle get display => _sans(
    32,
    FontWeight.w800,
    PatrolColors.ink,
    height: 1.08,
  ).copyWith(letterSpacing: -0.6);
  static TextStyle get headline => _sans(
    26,
    FontWeight.w800,
    PatrolColors.ink,
    height: 1.15,
  ).copyWith(letterSpacing: -0.4);
  static TextStyle get titleLarge =>
      _sans(19, FontWeight.w800, PatrolColors.ink, height: 1.25);
  static TextStyle get titleMedium =>
      _sans(16, FontWeight.w700, PatrolColors.ink, height: 1.3);
  static TextStyle get bodyLarge =>
      _sans(15, FontWeight.w600, PatrolColors.inkSecondary, height: 1.4);
  static TextStyle get bodyMedium =>
      _sans(14, FontWeight.w500, PatrolColors.inkSecondary, height: 1.4);
  static TextStyle get bodySmall =>
      _sans(13, FontWeight.w500, PatrolColors.inkMuted, height: 1.35);
  static TextStyle get label =>
      _sans(15, FontWeight.w700, PatrolColors.ink, height: 1.2);
  static TextStyle get caption =>
      _sans(12, FontWeight.w700, PatrolColors.inkMuted, height: 1.3);

  /// Texto de botones: sin color, lo pone el propio botón
  static TextStyle get buttonLabel =>
      _sans(16, FontWeight.w800, null, height: 1.2);

  /// Botón de acción principal (72 px de alto)
  static TextStyle get actionLabel =>
      _sans(20, FontWeight.w800, null, height: 1.15);

  /// Telemetría: distancia, llegada, horas y códigos de unidad
  static TextStyle mono({
    double size = 15,
    Color color = PatrolColors.ink,
    FontWeight weight = FontWeight.w700,
  }) =>
      SecuriaFonts.monoStyle(fontSize: size, color: color, fontWeight: weight);

  /// TextTheme de Material con la misma escala
  static TextTheme get textTheme => TextTheme(
    displaySmall: display,
    headlineMedium: headline,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: label,
    labelSmall: caption,
  );
}
