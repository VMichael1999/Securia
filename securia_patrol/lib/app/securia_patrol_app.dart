import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';
import 'injection.dart';
import 'theme/patrol_colors.dart';
import 'theme/patrol_typography.dart';
import '../features/auth/presentation/views/patrol_login_view.dart';
import '../features/tactical_map/presentation/bloc/patrol_bloc.dart';

/// Aplicación de la unidad de patrullaje (PNP o serenazgo)
class SecuriaPatrolApp extends StatelessWidget {
  const SecuriaPatrolApp({super.key});

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: SecuriaFonts.sans,
      package: SecuriaFonts.package,
    );

    return base.copyWith(
      scaffoldBackgroundColor: PatrolColors.background,
      colorScheme: const ColorScheme.dark(
        primary: PatrolColors.action,
        onPrimary: PatrolColors.onAction,
        secondary: PatrolColors.action,
        onSecondary: PatrolColors.onAction,
        surface: PatrolColors.surface,
        onSurface: PatrolColors.ink,
        onSurfaceVariant: PatrolColors.inkMuted,
        outline: PatrolColors.border,
        error: PatrolColors.critical,
      ),
      textTheme: PatrolTypography.textTheme,
      dividerColor: PatrolColors.border,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: PatrolColors.action,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: PatrolColors.elevated,
        contentTextStyle: PatrolTypography.label.copyWith(fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SecuriaRadius.md + 2),
          side: const BorderSide(color: PatrolColors.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: PatrolColors.surface,
        indicatorColor: PatrolColors.elevated,
        surfaceTintColor: Colors.transparent,
        height: SecuriaTouch.primaryAction,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color:
                states.contains(WidgetState.selected)
                    ? PatrolColors.ink
                    : PatrolColors.inkMuted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => PatrolTypography.caption.copyWith(
            color:
                states.contains(WidgetState.selected)
                    ? PatrolColors.ink
                    : PatrolColors.inkMuted,
            fontWeight:
                states.contains(WidgetState.selected)
                    ? FontWeight.w800
                    : FontWeight.w600,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: PatrolColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: const DialogThemeData(surfaceTintColor: Colors.transparent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = getIt<ISecuriaRepository>();

    return BlocProvider<PatrolBloc>(
      create:
          (_) => PatrolBloc(
            repository: repository,
            initialPatrol: repository.getCurrentPatrol(),
          ),
      child: MaterialApp(
        title: 'Securia Patrulla',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const PatrolLoginView(),
      ),
    );
  }
}
