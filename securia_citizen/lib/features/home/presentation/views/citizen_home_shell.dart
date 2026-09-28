import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/injection.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../map/data/location_service.dart';
import '../../../map/presentation/bloc/citizen_bloc.dart';
import '../../../map/presentation/bloc/citizen_event.dart';
import '../../../map/presentation/views/citizen_map_view.dart';
import '../../../history/presentation/views/citizen_history_view.dart';
import '../../../profile/presentation/views/citizen_profile_view.dart';

/// Shell principal con navegación por pestañas para el ciudadano
///
/// Crea el [CitizenBloc] de la sesión: al cerrar sesión la vista se desmonta
/// y el bloc se cierra con ella.
class CitizenHomeShell extends StatefulWidget {
  final CitizenProfileModel citizen;

  const CitizenHomeShell({super.key, required this.citizen});

  @override
  State<CitizenHomeShell> createState() => _CitizenHomeShellState();
}

class _CitizenHomeShellState extends State<CitizenHomeShell> {
  int _currentIndex = 0;

  static const String _mapLabel = 'Mapa';
  static const String _reportsLabel = 'Mis reportes';
  static const String _profileLabel = 'Perfil';

  final List<Widget> _views = const [
    CitizenMapView(),
    CitizenHistoryView(),
    CitizenProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => CitizenBloc(
            repository: getIt<ISecuriaRepository>(),
            citizen: widget.citizen,
            locationService: getIt<LocationService>(),
          )..add(const CitizenStarted()),
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _views),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.surfaceMuted,
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => AppTypography.caption.copyWith(
                color: states.contains(WidgetState.selected)
                    ? AppColors.ink
                    : AppColors.inkMuted,
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w800
                    : FontWeight.w600,
              ),
            ),
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                color: states.contains(WidgetState.selected)
                    ? AppColors.ink
                    : AppColors.inkMuted,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) =>
                setState(() => _currentIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map_rounded),
                label: _mapLabel,
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: _reportsLabel,
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: _profileLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
