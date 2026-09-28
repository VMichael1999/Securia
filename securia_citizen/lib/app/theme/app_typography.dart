import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import 'app_colors.dart';

/// Tipografía de la app ciudadana: Plus Jakarta Sans empaquetada en
/// securia_core (funciona sin internet) y JetBrains Mono para cifras.
class AppTypography {
  AppTypography._();

  static TextStyle _sans(double size, FontWeight weight, Color? color,
          {double? height}) =>
      TextStyle(
        fontFamily: SecuriaFonts.sans,
        package: SecuriaFonts.package,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  static TextStyle get displayLarge =>
      _sans(32, FontWeight.w800, AppColors.ink, height: 1.15);
  static TextStyle get headline =>
      _sans(26, FontWeight.w800, AppColors.ink, height: 1.2);
  static TextStyle get titleLarge =>
      _sans(20, FontWeight.w800, AppColors.ink, height: 1.25);
  static TextStyle get titleMedium =>
      _sans(16, FontWeight.w700, AppColors.ink, height: 1.3);
  static TextStyle get bodyLarge =>
      _sans(16, FontWeight.w500, AppColors.ink, height: 1.4);
  static TextStyle get bodyMedium =>
      _sans(14, FontWeight.w500, AppColors.inkSecondary, height: 1.4);
  static TextStyle get bodySmall =>
      _sans(13, FontWeight.w500, AppColors.inkSecondary, height: 1.35);
  static TextStyle get label =>
      _sans(14, FontWeight.w700, AppColors.ink, height: 1.2);
  static TextStyle get caption =>
      _sans(12, FontWeight.w600, AppColors.inkMuted, height: 1.3);
  static TextStyle get button =>
      _sans(16, FontWeight.w700, AppColors.onColor, height: 1.2);

  /// Etiqueta grande del botón SOS
  static TextStyle get sosLabel =>
      _sans(40, FontWeight.w800, AppColors.onColor, height: 1).copyWith(letterSpacing: 1);

  /// Texto de botones: sin color, lo pone el propio botón (foregroundColor)
  static TextStyle get buttonLabel => _sans(15, FontWeight.w700, null, height: 1.2);

  /// Cifras de seguimiento (minutos, distancia, precisión)
  static TextStyle mono({double size = 15, Color color = AppColors.ink}) =>
      SecuriaFonts.monoStyle(fontSize: size, color: color);

  /// TextTheme de Material con la misma escala
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
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
