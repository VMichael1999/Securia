import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/injection.dart';
import '../../../../app/theme/app_colors.dart';
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
          )..add(const CitizenStarted()),
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _views),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.border, width: 1.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: AppColors.primaryNavy,
            unselectedItemColor: AppColors.textMuted,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11.5,
            ),
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map_rounded),
                label: 'Mapa SOS',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                activeIcon: Icon(Icons.assignment_rounded),
                label: 'Mis Reportes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Mi Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
