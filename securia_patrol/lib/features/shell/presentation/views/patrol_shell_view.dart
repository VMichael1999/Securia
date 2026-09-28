import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/strings/shift_strings.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';
import '../../../queue/presentation/views/dispatch_queue_view.dart';
import '../../../shift/presentation/views/shift_view.dart';
import '../../../tactical_map/presentation/bloc/patrol_bloc.dart';
import '../../../tactical_map/presentation/bloc/patrol_state.dart';
import '../../../tactical_map/presentation/views/tactical_map_view.dart';

/// Navegación principal de la unidad: Mapa, Cola y Turno
class PatrolShellView extends StatefulWidget {
  const PatrolShellView({super.key});

  @override
  State<PatrolShellView> createState() => _PatrolShellViewState();
}

class _PatrolShellViewState extends State<PatrolShellView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatrolColors.background,
      body: IndexedStack(
        index: _index,
        children: [
          const TacticalMapView(),
          DispatchQueueView(onOpenMap: () => setState(() => _index = 0)),
          const ShiftView(),
        ],
      ),
      bottomNavigationBar: BlocSelector<PatrolBloc, PatrolState, int>(
        selector: (state) => state.pendingCount,
        builder: (context, pending) {
          Widget queueIcon(IconData icon) => Badge(
            isLabelVisible: pending > 0,
            backgroundColor: PatrolColors.criticalFill,
            textColor: PatrolColors.onCritical,
            label: Text(
              '$pending',
              style: PatrolTypography.mono(
                size: 11,
                color: PatrolColors.onCritical,
              ),
            ),
            child: Icon(icon),
          );

          return DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: PatrolColors.border)),
            ),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map_rounded),
                  label: ShiftStrings.navMap,
                ),
                NavigationDestination(
                  icon: queueIcon(Icons.format_list_bulleted_rounded),
                  selectedIcon: queueIcon(Icons.format_list_bulleted_rounded),
                  label: ShiftStrings.navQueue,
                  tooltip:
                      pending > 0 ? ShiftStrings.queueBadge(pending) : null,
                ),
                const NavigationDestination(
                  icon: Icon(Icons.badge_outlined),
                  selectedIcon: Icon(Icons.badge_rounded),
                  label: ShiftStrings.navShift,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
