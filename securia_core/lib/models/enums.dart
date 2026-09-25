import 'package:flutter/material.dart';

/// Tipo de incidente o emergencia de seguridad
enum IncidentType {
  asalto(
    title: 'Asalto a mano armada',
    code: 'ASALTO',
    color: Color(0xFFDC2626), // Rojo emergencia
    icon: Icons.shield_outlined,
    urgencyText: 'Crítica',
  ),
  robo(
    title: 'Robo / Hurto al paso',
    code: 'ROBO',
    color: Color(0xFFEA580C), // Naranja intenso
    icon: Icons.warning_amber_rounded,
    urgencyText: 'Alta',
  ),
  emergenciaMedica(
    title: 'Emergencia Médica / Ambulancia',
    code: 'MEDICA',
    color: Color(0xFFE11D48), // Carmesí médico
    icon: Icons.medical_services_outlined,
    urgencyText: 'Crítica',
  ),
  accidenteTransito(
    title: 'Accidente de tránsito',
    code: 'ACCIDENTE',
    color: Color(0xFFD97706), // Ámbar
    icon: Icons.car_crash_outlined,
    urgencyText: 'Alta',
  ),
  incendio(
    title: 'Incendio / Siniestro',
    code: 'INCENDIO',
    color: Color(0xFFB91C1C), // Rojo fuego
    icon: Icons.local_fire_department_outlined,
    urgencyText: 'Crítica',
  ),
  sospechoso(
    title: 'Actividad sospechosa',
    code: 'SOSPECHOSO',
    color: Color(0xFF4F46E5), // Índigo preventivo
    icon: Icons.person_search_outlined,
    urgencyText: 'Media',
  ),
  violencia(
    title: 'Violencia / Agresión física',
    code: 'VIOLENCIA',
    color: Color(0xFF7C2D12), // Marrón rojizo
    icon: Icons.gavel_rounded,
    urgencyText: 'Alta',
  ),
  otro(
    title: 'Otra emergencia ciudadana',
    code: 'OTRO',
    color: Color(0xFF475569), // Gris pizarra
    icon: Icons.report_problem_outlined,
    urgencyText: 'Media',
  );

  final String title;
  final String code;
  final Color color;
  final IconData icon;
  final String urgencyText;

  const IncidentType({
    required this.title,
    required this.code,
    required this.color,
    required this.icon,
    required this.urgencyText,
  });
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
}

/// Nivel de urgencia de la alerta
enum UrgencyLevel {
  critica(label: 'Crítica', color: Color(0xFFDC2626)),
  alta(label: 'Alta', color: Color(0xFFEA580C)),
  media(label: 'Media', color: Color(0xFFF59E0B)),
  baja(label: 'Baja', color: Color(0xFF10B981));

  final String label;
  final Color color;

  const UrgencyLevel({
    required this.label,
    required this.color,
  });
}

/// Estado del agente o patrulla policial
enum PatrolStatus {
  disponible(label: 'En Patrullaje / Disponible', color: Color(0xFF10B981)),
  enRespuesta(label: 'Acudiendo a Emergencia', color: Color(0xFFEF4444)),
  fueraServicio(label: 'Fuera de Servicio', color: Color(0xFF64748B));

  final String label;
  final Color color;

  const PatrolStatus({
    required this.label,
    required this.color,
  });
}
