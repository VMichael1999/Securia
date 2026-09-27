import 'package:flutter/material.dart';

/// Tipo de incidente o emergencia de seguridad
///
/// Cada tipo define su urgencia por defecto para que el ciudadano reporte
/// con un solo toque, sin tener que clasificar la gravedad.
enum IncidentType {
  emergenciaGeneral(
    title: 'Emergencia SOS',
    shortLabel: 'SOS',
    code: 'SOS',
    color: Color(0xFFDC2626),
    icon: Icons.sos_rounded,
    defaultUrgency: UrgencyLevel.critica,
  ),
  asalto(
    title: 'Asalto a mano armada',
    shortLabel: 'Asalto',
    code: 'ASALTO',
    color: Color(0xFFDC2626),
    icon: Icons.shield_outlined,
    defaultUrgency: UrgencyLevel.critica,
  ),
  robo(
    title: 'Robo / Hurto al paso',
    shortLabel: 'Robo',
    code: 'ROBO',
    color: Color(0xFFEA580C),
    icon: Icons.warning_amber_rounded,
    defaultUrgency: UrgencyLevel.alta,
  ),
  emergenciaMedica(
    title: 'Emergencia Médica / Ambulancia',
    shortLabel: 'Médica',
    code: 'MEDICA',
    color: Color(0xFFE11D48),
    icon: Icons.medical_services_outlined,
    defaultUrgency: UrgencyLevel.critica,
  ),
  accidenteTransito(
    title: 'Accidente de tránsito',
    shortLabel: 'Accidente',
    code: 'ACCIDENTE',
    color: Color(0xFFD97706),
    icon: Icons.car_crash_outlined,
    defaultUrgency: UrgencyLevel.alta,
  ),
  incendio(
    title: 'Incendio / Siniestro',
    shortLabel: 'Incendio',
    code: 'INCENDIO',
    color: Color(0xFFB91C1C),
    icon: Icons.local_fire_department_outlined,
    defaultUrgency: UrgencyLevel.critica,
  ),
  sospechoso(
    title: 'Actividad sospechosa',
    shortLabel: 'Sospechoso',
    code: 'SOSPECHOSO',
    color: Color(0xFF4F46E5),
    icon: Icons.person_search_outlined,
    defaultUrgency: UrgencyLevel.media,
  ),
  violencia(
    title: 'Violencia / Agresión física',
    shortLabel: 'Violencia',
    code: 'VIOLENCIA',
    color: Color(0xFF9F1239),
    icon: Icons.front_hand_outlined,
    defaultUrgency: UrgencyLevel.critica,
  ),
  otro(
    title: 'Otra emergencia ciudadana',
    shortLabel: 'Otro',
    code: 'OTRO',
    color: Color(0xFF475569),
    icon: Icons.report_problem_outlined,
    defaultUrgency: UrgencyLevel.media,
  );

  final String title;
  final String shortLabel;
  final String code;
  final Color color;
  final IconData icon;
  final UrgencyLevel defaultUrgency;

  const IncidentType({
    required this.title,
    required this.shortLabel,
    required this.code,
    required this.color,
    required this.icon,
    required this.defaultUrgency,
  });

  /// Tipos que el ciudadano puede elegir al reportar un incidente con detalle
  static const List<IncidentType> reportTypes = [
    asalto,
    robo,
    violencia,
    emergenciaMedica,
    accidenteTransito,
    incendio,
    sospechoso,
    otro,
  ];

  /// Opciones para precisar una alerta SOS inmediata ya enviada
  static const List<IncidentType> sosFollowUpTypes = [
    asalto,
    violencia,
    emergenciaMedica,
    accidenteTransito,
    incendio,
    otro,
  ];
}

/// Estado en el ciclo de vida del reporte de incidente
enum IncidentStatus {
  reportado(
    label: 'Reportado',
    description: 'Buscando unidad policial cercana',
    badgeColor: Color(0xFFEF4444),
  ),
  asignado(
    label: 'Patrulla Asignada',
    description: 'Unidad de seguridad notificada',
    badgeColor: Color(0xFFF59E0B),
  ),
  enCamino(
    label: 'Patrulla en Camino',
    description: 'Unidad dirigiéndose al lugar de la alerta',
    badgeColor: Color(0xFF3B82F6),
  ),
  enLugar(
    label: 'En el Lugar',
    description: 'Personal de seguridad interviniendo la zona',
    badgeColor: Color(0xFF8B5CF6),
  ),
  resuelto(
    label: 'Controlado / Resuelto',
    description: 'Incidente atendido y concluido',
    badgeColor: Color(0xFF10B981),
  ),
  cancelado(
    label: 'Cancelado',
    description: 'Alerta cancelada por el usuario o falsa alarma',
    badgeColor: Color(0xFF64748B),
  );

  final String label;
  final String description;
  final Color badgeColor;

  const IncidentStatus({
    required this.label,
    required this.description,
    required this.badgeColor,
  });

  /// El incidente ya no requiere acción (resuelto o cancelado)
  bool get isClosed =>
      this == IncidentStatus.resuelto || this == IncidentStatus.cancelado;
}

/// Nivel de urgencia de la alerta
enum UrgencyLevel {
  critica(label: 'Crítica', color: Color(0xFFDC2626)),
  alta(label: 'Alta', color: Color(0xFFEA580C)),
  media(label: 'Media', color: Color(0xFFF59E0B)),
  baja(label: 'Baja', color: Color(0xFF10B981));

  final String label;
  final Color color;

  const UrgencyLevel({required this.label, required this.color});
}

/// Estado del agente o patrulla policial
enum PatrolStatus {
  disponible(label: 'En Patrullaje / Disponible', color: Color(0xFF10B981)),
  enRespuesta(label: 'Acudiendo a Emergencia', color: Color(0xFFEF4444)),
  fueraServicio(label: 'Fuera de Servicio', color: Color(0xFF64748B));

  final String label;
  final Color color;

  const PatrolStatus({required this.label, required this.color});
}
