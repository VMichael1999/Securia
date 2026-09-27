import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';
import 'injection.dart';
import 'theme/patrol_colors.dart';
import '../features/auth/presentation/views/patrol_login_view.dart';
import '../features/tactical_map/presentation/bloc/patrol_bloc.dart';

/// Aplicación principal de Securia Patrullaje / Despacho Policial
class SecuriaPatrolApp extends StatelessWidget {
  const SecuriaPatrolApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Patrulla por defecto inicial para bootstrap del BLoC
    const initialPatrol = PatrolUnitModel(
      id: 'patrol_01',
      unitCode: 'PL-402',
      officerName: 'Suboficial R. Mendoza',
      phone: '993 102 481',
      location: GeoLocation(
        latitude: -12.0835,
        longitude: -77.0378,
        address: 'Av. Guardia Civil con Av. Javier Prado, San Borja',
      ),
      coverageRadiusKm: 3.5,
      status: PatrolStatus.disponible,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<PatrolBloc>(
          create: (_) => PatrolBloc(
            repository: getIt<ISecuriaRepository>(),
            initialPatrol: initialPatrol,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Securia Patrol - Despacho Táctico',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: PatrolColors.background,
          colorScheme: const ColorScheme.dark(
            primary: PatrolColors.policeBlue,
            secondary: PatrolColors.policeAccent,
            surface: PatrolColors.surfaceCard,
            error: PatrolColors.alertCrimson,
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: const Color(0xFF0F2447),
            contentTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFF10B981), width: 1.2),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: PatrolColors.surface,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const PatrolLoginView(),
      ),
    );
  }
}
