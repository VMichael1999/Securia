import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'patrol_colors.dart';

/// Tipografía táctica de alta legibilidad en pantallas nocturnas y dinámicas
class PatrolTypography {
  PatrolTypography._();

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: PatrolColors.textPrimary,
        letterSpacing: 0.0,
      );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: PatrolColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: PatrolColors.textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: PatrolColors.textSecondary,
      );

  static TextStyle get telemetry => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: PatrolColors.policeAccent,
        letterSpacing: 0.5,
      );

  static TextStyle get tacticalCode => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: PatrolColors.textPrimary,
        letterSpacing: 1.0,
      );
}
