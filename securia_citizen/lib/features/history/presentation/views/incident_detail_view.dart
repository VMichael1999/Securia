import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Pantalla de detalle de un incidente con minimapa interactivo y seguimiento policial
class IncidentDetailView extends StatelessWidget {
  final IncidentModel incident;

  const IncidentDetailView({
    super.key,
    required this.incident,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE dd \'de\' MMMM \'de\' yyyy', 'es').format(incident.timestamp);
    final timeStr = DateFormat('hh:mm a', 'es').format(incident.timestamp);
    final incidentLatLng = incident.location.toLatLng();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryNavy),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detalle del Incidente',
          style: AppTypography.titleLarge.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tarjeta Resumen con Estado
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: incident.type.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(incident.type.icon, color: incident.type.color, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              incident.title,
                              style: AppTypography.titleLarge.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${incident.id.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Badge de estado y nivel de urgencia
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: incident.status.badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: incident.status.badgeColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: incident.status.badgeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              incident.status.label,
                              style: TextStyle(
                                color: incident.status.badgeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: incident.urgency.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Urgencia: ${incident.urgency.label}',
                          style: TextStyle(
                            color: incident.urgency.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 2. Línea de Tiempo del Despacho de Seguridad
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seguimiento en Tiempo Real',
                    style: AppTypography.titleMedium.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  _buildTimelineStep(
                    title: 'Alerta SOS Recibida',
                    subtitle: 'Emitida por $timeStr',
                    isDone: true,
                    isCurrent: incident.status == IncidentStatus.reportado,
                  ),
                  _buildTimelineStep(
                    title: 'Patrulla Asignada',
                    subtitle: incident.assignedPatrolCode != null
                        ? 'Unidad ${incident.assignedPatrolCode} (${incident.assignedOfficerName ?? "Oficial"})'
                        : 'En espera de asignación de cuadrante',
                    isDone: incident.status.index >= IncidentStatus.asignado.index,
                    isCurrent: incident.status == IncidentStatus.asignado,
                  ),
                  _buildTimelineStep(
                    title: 'En Desplazamiento / Camino',
                    subtitle: incident.status.index >= IncidentStatus.enCamino.index
                        ? 'Patrulla acudiendo con sirena activa'
                        : 'Pendiente de inicio de ruta',
                    isDone: incident.status.index >= IncidentStatus.enCamino.index,
                    isCurrent: incident.status == IncidentStatus.enCamino,
                  ),
                  _buildTimelineStep(
                    title: 'En el Lugar del Incidente',
                    subtitle: incident.status.index >= IncidentStatus.enLugar.index
                        ? 'Oficiales en contacto y control de área'
                        : 'Arribo estimado en 3 minutos',
                    isDone: incident.status.index >= IncidentStatus.enLugar.index,
                    isCurrent: incident.status == IncidentStatus.enLugar,
                  ),
                  _buildTimelineStep(
                    title: 'Incidente Controlado y Resuelto',
                    subtitle: incident.status == IncidentStatus.resuelto
                        ? (incident.notes.isNotEmpty ? incident.notes.last : 'Intervención completada con éxito')
                        : 'En proceso de atención',
                    isDone: incident.status == IncidentStatus.resuelto,
                    isCurrent: incident.status == IncidentStatus.resuelto,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 3. Minimapa con Ubicación Exacta
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ubicación del Incidente',
                          style: AppTypography.titleMedium.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const Icon(Icons.map_outlined, color: AppColors.accentBlue, size: 20),
                      ],
                    ),
                  ),

                  // Contenedor del Minimapa
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(0), bottom: Radius.circular(16)),
                    child: SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: incidentLatLng,
                          initialZoom: 16.0,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.securia.citizen',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: incidentLatLng,
                                width: 44,
                                height: 44,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: incident.type.color,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                                    ],
                                  ),
                                  child: Icon(incident.type.icon, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.emergencyRed, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                incident.location.address,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              if (incident.location.reference != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Ref: ${incident.location.reference}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 4. Descripción del Hecho y Foto de Evidencia
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Descripción de la Emergencia',
                    style: AppTypography.titleMedium.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    incident.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 14),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        '$dateStr a las $timeStr',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  // Foto adjunta
                  if (incident.photoPath != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Fotografía de Evidencia Adjunta',
                      style: AppTypography.titleMedium.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: incident.photoPath == 'simulated_evidence_photo'
                          ? Container(
                              height: 180,
                              width: double.infinity,
                              color: AppColors.surfaceMuted,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo_camera_rounded, size: 48, color: AppColors.textSecondary),
                                  SizedBox(height: 8),
                                  Text(
                                    'Evidencia visual capturada por cámara',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            )
                          : Image.file(
                              File(incident.photoPath!),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isCurrent,
    bool isLast = false,
  }) {
    Color dotColor = isDone ? AppColors.successEmerald : AppColors.borderSubtle;
    if (isCurrent) dotColor = AppColors.accentBlue;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.accentBlue.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: isDone ? AppColors.successEmerald.withValues(alpha: 0.5) : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isCurrent || isDone ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13.5,
                    color: isCurrent ? AppColors.primaryNavy : (isDone ? AppColors.primaryNavy : AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
