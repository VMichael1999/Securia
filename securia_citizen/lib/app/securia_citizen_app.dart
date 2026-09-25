import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';
import 'injection.dart';
import 'theme/app_colors.dart';
import '../features/auth/presentation/views/citizen_login_view.dart';
import '../features/map/presentation/bloc/citizen_bloc.dart';
import '../features/map/presentation/bloc/citizen_event.dart';

/// Aplicación principal de Securia Ciudadano
class SecuriaCitizenApp extends StatelessWidget {
  const SecuriaCitizenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CitizenBloc>(
          create: (_) => CitizenBloc(
            repository: getIt<ISecuriaRepository>(),
          )..add(const CitizenStarted()),
        ),
      ],
      child: MaterialApp(
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
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryNavy,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const CitizenLoginView(),
      ),
    );
  }
}
