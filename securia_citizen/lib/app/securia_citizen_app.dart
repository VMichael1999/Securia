import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import 'theme/app_colors.dart';
import 'theme/app_typography.dart';
import '../features/auth/presentation/views/citizen_login_view.dart';

/// Aplicación principal de Securia Ciudadano
class SecuriaCitizenApp extends StatelessWidget {
  const SecuriaCitizenApp({super.key});

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: SecuriaFonts.sans,
        package: SecuriaFonts.package,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: AppTypography.textTheme,
        colorScheme: const ColorScheme.light(
          primary: AppColors.ink,
          onPrimary: AppColors.onColor,
          secondary: AppColors.help,
          onSecondary: AppColors.onColor,
          error: AppColors.sos,
          onError: AppColors.onColor,
          surface: AppColors.surface,
          onSurface: AppColors.ink,
          outline: AppColors.borderStrong,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.ink,
          contentTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.onColor,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SecuriaRadius.md),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          titleTextStyle: AppTypography.titleLarge,
          contentTextStyle: AppTypography.bodyMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SecuriaRadius.xl),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.ink,
          surfaceTintColor: AppColors.background,
          elevation: 0,
          titleTextStyle: AppTypography.titleMedium,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Securia',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const CitizenLoginView(),
    );
  }
}
