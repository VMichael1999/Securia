import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';
import 'resolution_dialog.dart';

/// Hoja de control táctico inferior para gestión de despacho y ruta policial
class TacticalHudSheet extends StatelessWidget {
  final IncidentModel incident;
  final double? distanceMeters;
  final int? etaMinutes;
  final bool isAssignedToMe;
  final VoidCallback onAcceptDispatch;
  final VoidCallback onEnCamino;
  final VoidCallback onEnLugar;
  final Function(String note) onResolve;
  final VoidCallback onClose;

  const TacticalHudSheet({
    super.key,
    required this.incident,
    this.distanceMeters,
    this.etaMinutes,
    required this.isAssignedToMe,
    required this.onAcceptDispatch,
    required this.onEnCamino,
    required this.onEnLugar,
    required this.onResolve,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final distStr = distanceMeters != null
        ? (distanceMeters! >= 1000
            ? '${(distanceMeters! / 1000).toStringAsFixed(1)} km'
            : '${distanceMeters!.toStringAsFixed(0)} m')
        : '--';

    final etaStr = etaMinutes != null ? '$etaMinutes min' : '--';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(
          top: BorderSide(color: PatrolColors.surfaceBorder, width: 1.5),
          left: BorderSide(color: PatrolColors.surfaceBorder, width: 1),
          right: BorderSide(color: PatrolColors.surfaceBorder, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de agarre
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: PatrolColors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Encabezado de incidente con badges y botón cerrar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: incident.type.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: incident.type.color.withValues(alpha: 0.6)),
                ),
                child: Icon(incident.type.icon, color: incident.type.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: incident.urgency.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: incident.urgency.color),
                          ),
                          child: Text(
                            'URGENCIA ${incident.urgency.label.toUpperCase()}',
                            style: TextStyle(
                              color: incident.urgency.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: incident.status.badgeColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            incident.status.label,
                            style: TextStyle(
                              color: incident.status.badgeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      incident.title,
                      style: PatrolTypography.titleMedium.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      incident.location.address,
                      style: PatrolTypography.bodySmall.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: PatrolColors.textMuted, size: 20),
                onPressed: onClose,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Telemetría táctica (Distancia, Tiempo estimado, Patrulla asignada)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PatrolColors.surfaceBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTelemetryItem(
                    icon: Icons.navigation_rounded,
                    label: 'DISTANCIA',
                    value: distStr,
                    valueColor: PatrolColors.policeAccent,
                  ),
                ),
                Container(width: 1, height: 28, color: PatrolColors.surfaceBorder),
                Expanded(
                  child: _buildTelemetryItem(
                    icon: Icons.timer_outlined,
                    label: 'ETA ESTIMADO',
                    value: etaStr,
                    valueColor: PatrolColors.warningAmber,
                  ),
                ),
                Container(width: 1, height: 28, color: PatrolColors.surfaceBorder),
                Expanded(
                  child: _buildTelemetryItem(
                    icon: Icons.shield_outlined,
                    label: 'PATRULLA',
                    value: incident.assignedPatrolCode ?? 'Sin Asignar',
                    valueColor: isAssignedToMe ? PatrolColors.policeAccent : PatrolColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          if (incident.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: PatrolColors.surfaceBorder),
              ),
              child: Text(
                'Nota: "${incident.description}"',
                style: const TextStyle(
                  color: PatrolColors.textSecondary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Botones de acción táctica según estado del ciclo de vida
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildTelemetryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: PatrolColors.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: PatrolColors.textMuted,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: PatrolTypography.telemetry.copyWith(
            color: valueColor,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (incident.status == IncidentStatus.resuelto) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: PatrolColors.successGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PatrolColors.successGreen),
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: PatrolColors.successGreen, size: 18),
              SizedBox(width: 8),
              Text(
                'INTERVENCIÓN RESUELTA Y CONCLUIDA',
                style: TextStyle(
                  color: PatrolColors.successGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!isAssignedToMe && incident.status == IncidentStatus.reportado) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onAcceptDispatch,
          style: ElevatedButton.styleFrom(
            backgroundColor: PatrolColors.policeBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security_rounded, size: 18),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'TOMAR DESPACHO Y ASIGNAR UNIDAD',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (incident.status == IncidentStatus.asignado) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onEnCamino,
          style: ElevatedButton.styleFrom(
            backgroundColor: PatrolColors.alertCrimson,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flash_on_rounded, size: 18),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'EN CAMINO (SIRENA ACTIVA)',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (incident.status == IncidentStatus.enCamino) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onEnLugar,
          style: ElevatedButton.styleFrom(
            backgroundColor: PatrolColors.warningAmber,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pin_drop_rounded, size: 18),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'CONFIRMAR ARRIBO (EN EL LUGAR)',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (incident.status == IncidentStatus.enLugar) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => ResolutionDialog(
                incident: incident,
                onConfirmResolution: onResolve,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: PatrolColors.successGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fact_check_rounded, size: 18),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'CONCLUIR Y RESOLVER INCIDENTE',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
