import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../profile/presentation/views/patrol_profile_view.dart';
import '../../../tactical_map/presentation/bloc/patrol_bloc.dart';
import '../../../tactical_map/presentation/bloc/patrol_state.dart';
import '../../../tactical_map/presentation/views/tactical_map_view.dart';
import '../../../triage/presentation/views/patrol_triage_view.dart';

/// Shell principal de navegación para la aplicación de Patrullaje Securia
class PatrolShellView extends StatefulWidget {
  const PatrolShellView({super.key});

  @override
  State<PatrolShellView> createState() => _PatrolShellViewState();
}

class _PatrolShellViewState extends State<PatrolShellView> {
  int _currentIndex = 0;

  void _onSwitchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatrolBloc, PatrolState>(
      builder: (context, state) {
        final activeCount = state.activeIncidents.length;

        final views = [
          const TacticalMapView(),
          PatrolTriageView(onSwitchTab: _onSwitchTab),
          const PatrolProfileView(),
        ];

        return Scaffold(
          backgroundColor: PatrolColors.background,
          body: IndexedStack(
            index: _currentIndex,
            children: views,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: PatrolColors.surface,
              border: Border(
                top: BorderSide(color: PatrolColors.surfaceBorder, width: 1),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: PatrolColors.surface,
              selectedItemColor: PatrolColors.cyanAccent,
              unselectedItemColor: PatrolColors.textMuted,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              type: BottomNavigationBarType.fixed,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.radar_rounded),
                  activeIcon: Icon(Icons.radar_rounded, color: PatrolColors.cyanAccent),
                  label: 'Mapa Táctico',
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: activeCount > 0,
                    label: Text(
                      '$activeCount',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
                    ),
                    backgroundColor: PatrolColors.alertCrimson,
                    child: const Icon(Icons.format_list_bulleted_rounded),
                  ),
                  activeIcon: Badge(
                    isLabelVisible: activeCount > 0,
                    label: Text(
                      '$activeCount',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
                    ),
                    backgroundColor: PatrolColors.alertCrimson,
                    child: const Icon(Icons.format_list_bulleted_rounded, color: PatrolColors.cyanAccent),
                  ),
                  label: 'Despacho',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.local_police_outlined),
                  activeIcon: Icon(Icons.local_police_rounded, color: PatrolColors.cyanAccent),
                  label: 'Mi Guardia',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
