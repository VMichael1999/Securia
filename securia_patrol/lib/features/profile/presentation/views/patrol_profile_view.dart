import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';
import '../../../auth/presentation/views/patrol_login_view.dart';
import '../../../tactical_map/presentation/bloc/patrol_bloc.dart';
import '../../../tactical_map/presentation/bloc/patrol_event.dart';
import '../../../tactical_map/presentation/bloc/patrol_state.dart';

/// Pantalla de Gestión de Guardia, Estado de Servicio y Perfil Policial
class PatrolProfileView extends StatelessWidget {
  const PatrolProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatrolColors.background,
      appBar: AppBar(
        backgroundColor: PatrolColors.surfaceCard,
        elevation: 0,
        title: Text(
          'Unidad y Guardia Operativa',
          style: PatrolTypography.titleLarge.copyWith(fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<PatrolBloc, PatrolState>(
        builder: (context, state) {
          final patrol = state.currentPatrol;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Tarjeta de Oficial y Unidad
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: PatrolColors.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: PatrolColors.surfaceBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: PatrolColors.policeBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.local_police_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: PatrolColors.policeAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'UNIDAD ${patrol.unitCode}',
                                style: PatrolTypography.tacticalCode.copyWith(
                                  color: PatrolColors.policeAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              patrol.officerName,
                              style: PatrolTypography.titleMedium.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Radio Central: ${patrol.phone}',
                              style: PatrolTypography.bodySmall.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Selector de Estado de Servicio (Cupertino)
                Text(
                  'Estado de Servicio en Turno',
                  style: PatrolTypography.titleMedium.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<PatrolStatus>(
                    groupValue: patrol.status,
                    backgroundColor: PatrolColors.surfaceCard,
                    thumbColor: PatrolColors.policeAccent,
                    children: {
                      PatrolStatus.disponible: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Text(
                          'Disponible',
                          style: TextStyle(
                            color: patrol.status == PatrolStatus.disponible
                                ? Colors.white
                                : PatrolColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      PatrolStatus.enRespuesta: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Text(
                          'En Respuesta',
                          style: TextStyle(
                            color: patrol.status == PatrolStatus.enRespuesta
                                ? Colors.white
                                : PatrolColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      PatrolStatus.fueraServicio: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Text(
                          'Pausa / Fuera',
                          style: TextStyle(
                            color: patrol.status == PatrolStatus.fueraServicio
                                ? Colors.white
                                : PatrolColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    },
                    onValueChanged: (newStatus) {
                      if (newStatus != null) {
                        context.read<PatrolBloc>().add(PatrolChangeDutyStatus(newStatus));
                      }
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Métricas y Estadísticas del Turno
                Text(
                  'Rendimiento Operativo del Turno',
                  style: PatrolTypography.titleMedium.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        icon: Icons.check_circle_outline_rounded,
                        value: '${state.resolvedIncidents.length}',
                        label: 'Intervenciones Resueltas',
                        accentColor: PatrolColors.successGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        icon: Icons.speed_rounded,
                        value: '3.8 min',
                        label: 'Tiempo Prom. Respuesta',
                        accentColor: PatrolColors.policeAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        icon: Icons.radar_rounded,
                        value: '${state.radarRadiusKm} km',
                        label: 'Radio Cobertura Táctica',
                        accentColor: PatrolColors.warningAmber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        icon: Icons.alt_route_rounded,
                        value: '28.4 km',
                        label: 'Distancia Patrullada',
                        accentColor: PatrolColors.policeLight,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 4. Ubicación actual reportada
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PatrolColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: PatrolColors.surfaceBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location_rounded, color: PatrolColors.policeAccent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cuadrante Actual Georreferenciado',
                              style: TextStyle(
                                color: PatrolColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              patrol.location.address,
                              style: const TextStyle(
                                color: PatrolColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 5. Finalizar Turno / Salir (Sólido Rojo con Letra Blanca)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const PatrolLoginView()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                    label: const Text(
                      'FINALIZAR GUARDIA / CERRAR SESIÓN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PatrolColors.alertCrimson,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String value,
    required String label,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PatrolColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PatrolColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 18),
              const Spacer(),
              Text(
                value,
                style: PatrolTypography.telemetry.copyWith(
                  color: accentColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: PatrolColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
