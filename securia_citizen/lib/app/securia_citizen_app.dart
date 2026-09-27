import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import '../features/auth/presentation/views/citizen_login_view.dart';

/// Aplicación principal de Securia Ciudadano
class SecuriaCitizenApp extends StatelessWidget {
  const SecuriaCitizenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Securia - Seguridad Ciudadana',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryNavy,
          primary: AppColors.primaryNavy,
          secondary: AppColors.accentBlue,
          error: AppColors.emergencyRed,
          surface: Colors.white,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.primaryNavy,
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF334155), width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryNavy,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const CitizenLoginView(),
    );
  }
}
