import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';
import '../../../tactical_map/presentation/bloc/patrol_bloc.dart';
import '../../../tactical_map/presentation/bloc/patrol_event.dart';
import '../../../tactical_map/presentation/bloc/patrol_state.dart';

/// Cola de Despacho y Triage Policial de Incidentes
class PatrolTriageView extends StatefulWidget {
  final Function(int targetTab)? onSwitchTab;

  const PatrolTriageView({
    super.key,
    this.onSwitchTab,
  });

  @override
  State<PatrolTriageView> createState() => _PatrolTriageViewState();
}

class _PatrolTriageViewState extends State<PatrolTriageView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatrolColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: PatrolColors.policeBlue, size: 22),
            const SizedBox(width: 8),
            Text(
              'Triage y Despacho Táctico',
              style: PatrolTypography.titleLarge.copyWith(fontSize: 18),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: PatrolColors.policeBlue,
          indicatorWeight: 3,
          labelColor: PatrolColors.policeBlue,
          unselectedLabelColor: PatrolColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Activas'),
            Tab(text: 'Mis Despachos'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      body: BlocBuilder<PatrolBloc, PatrolState>(
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildIncidentsList(
                incidents: state.activeIncidents,
                state: state,
                emptyMessage: 'No hay emergencias pendientes en el sector.',
              ),
              _buildIncidentsList(
                incidents: state.myAssignedIncidents,
                state: state,
                emptyMessage: 'No tienes incidentes asignados actualmente.',
              ),
              _buildIncidentsList(
                incidents: state.resolvedIncidents,
                state: state,
                emptyMessage: 'Aún no has registrado intervenciones concluidas en este turno.',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIncidentsList({
    required List<IncidentModel> incidents,
    required PatrolState state,
    required String emptyMessage,
  }) {
    if (incidents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 54,
                color: PatrolColors.textMuted,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: PatrolColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: incidents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final incident = incidents[index];
        final distKm = GeoUtils.calculateDistanceKm(
          state.currentPatrol.location,
          incident.location,
        );
        final distStr = GeoUtils.formatDistance(distKm);

        final isAssignedToMe = incident.assignedPatrolId == state.currentPatrol.id;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isAssignedToMe
                  ? PatrolColors.policeAccent
                  : PatrolColors.surfaceBorder,
              width: isAssignedToMe ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior con categoría, badges y distancia
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: incident.type.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(incident.type.icon, color: incident.type.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          incident.type.title,
                          style: PatrolTypography.titleMedium.copyWith(fontSize: 14.5),
                        ),
                        Text(
                          DateFormat('dd/MM HH:mm').format(incident.timestamp),
                          style: PatrolTypography.bodySmall.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: incident.urgency.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: incident.urgency.color),
                    ),
                    child: Text(
                      incident.urgency.label.toUpperCase(),
                      style: TextStyle(
                        color: incident.urgency.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Dirección y distancia
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: PatrolColors.textMuted, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      incident.location.address,
                      style: const TextStyle(color: PatrolColors.textPrimary, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    distStr,
                    style: PatrolTypography.telemetry.copyWith(fontSize: 12),
                  ),
                ],
              ),

              if (incident.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  incident.description,
                  style: const TextStyle(color: PatrolColors.textSecondary, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Botones de acción rápida
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<PatrolBloc>().add(PatrolSelectIncident(incident));
                        widget.onSwitchTab?.call(0); // Cambiar al tab del mapa
                      },
                      icon: const Icon(Icons.map_outlined, size: 16),
                      label: const Text('Rastrear en Mapa'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PatrolColors.policeBlue,
                        side: const BorderSide(color: PatrolColors.policeBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  if (incident.status == IncidentStatus.reportado) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<PatrolBloc>().add(PatrolAcceptDispatch(incident));
                          widget.onSwitchTab?.call(0);
                        },
                        icon: const Icon(Icons.flash_on_rounded, size: 16),
                        label: const Text('Tomar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PatrolColors.alertCrimson,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
