import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Banner dinámico flotante superior que muestra el estado en vivo de una alerta activa
class ActiveAlertBanner extends StatelessWidget {
  final IncidentModel incident;
  final VoidCallback onCancel;
  final VoidCallback onTap;

  const ActiveAlertBanner({
    super.key,
    required this.incident,
    required this.onCancel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bannerColor = AppColors.emergencyRed;
    String statusTitle = '🚨 ALERTA SOS EMITIDA';
    String statusSubtitle = 'Buscando patrulla policial cercana en la zona...';

    if (incident.status == IncidentStatus.asignado) {
      bannerColor = AppColors.warningOrange;
      statusTitle = '🚔 PATRULLA ASIGNADA';
      statusSubtitle =
          '${incident.assignedPatrolCode ?? "Unidad"} notificada del incidente';
    } else if (incident.status == IncidentStatus.enCamino) {
      bannerColor = AppColors.accentBlue;
      statusTitle = '🚔 PATRULLA EN CAMINO';
      statusSubtitle =
          '${incident.assignedPatrolCode ?? "Unidad"} acudiendo a tu ubicación';
    } else if (incident.status == IncidentStatus.enLugar) {
      bannerColor = const Color(0xFF7C3AED);
      statusTitle = '👮 OFICIAL EN EL LUGAR';
      statusSubtitle = 'Intervención y contacto en progreso';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bannerColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: bannerColor.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fmd_good_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        statusTitle,
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          incident.type.title.split(' ').first,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusSubtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Botón cancelar
            GestureDetector(
              onTap: onCancel,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
