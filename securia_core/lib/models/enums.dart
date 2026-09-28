import 'package:flutter/material.dart';

/// Tipo de incidente o emergencia de seguridad
///
/// No lleva color: en la UI el color lo pone la urgencia, no el tipo.
///
/// Cada tipo define su urgencia por defecto para que el ciudadano reporte
/// con un solo toque, sin tener que clasificar la gravedad.
enum IncidentType {
  emergenciaGeneral(
    title: 'Emergencia SOS',
    shortLabel: 'SOS',
    code: 'SOS',
    icon: Icons.sos_rounded,
    defaultUrgency: UrgencyLevel.critica,
  ),
  asalto(
    title: 'Asalto a mano armada',
    shortLabel: 'Asalto',
    code: 'ASALTO',
    icon: Icons.gpp_bad_rounded,
    defaultUrgency: UrgencyLevel.critica,
  ),
  robo(
    title: 'Robo al paso',
    shortLabel: 'Robo al paso',
    code: 'ROBO',
    icon: Icons.backpack_rounded,
    defaultUrgency: UrgencyLevel.alta,
  ),
  emergenciaMedica(
    title: 'Emergencia médica',
    shortLabel: 'Emergencia médica',
    code: 'MEDICA',
    icon: Icons.medical_services_rounded,
    defaultUrgency: UrgencyLevel.critica,
  ),
  accidenteTransito(
    title: 'Accidente de tránsito',
    shortLabel: 'Accidente',
    code: 'ACCIDENTE',
    icon: Icons.car_crash_rounded,
    defaultUrgency: UrgencyLevel.alta,
  ),
  incendio(
    title: 'Incendio',
    shortLabel: 'Incendio',
    code: 'INCENDIO',
    icon: Icons.local_fire_department_rounded,
    defaultUrgency: UrgencyLevel.critica,
  ),
  sospechoso(
    title: 'Actividad sospechosa',
    shortLabel: 'Sospechoso',
    code: 'SOSPECHOSO',
    icon: Icons.visibility_rounded,
    defaultUrgency: UrgencyLevel.media,
  ),
  violencia(
    title: 'Violencia o agresión',
    shortLabel: 'Violencia',
    code: 'VIOLENCIA',
    icon: Icons.front_hand_rounded,
    defaultUrgency: UrgencyLevel.critica,
  ),
  otro(
    title: 'Otra emergencia',
    shortLabel: 'Otro',
    code: 'OTRO',
    icon: Icons.more_horiz_rounded,
    defaultUrgency: UrgencyLevel.media,
  );

  final String title;
  final String shortLabel;
  final String code;
  final IconData icon;
  final UrgencyLevel defaultUrgency;

  const IncidentType({
    required this.title,
    required this.shortLabel,
    required this.code,
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
  ),
  asignado(
    label: 'Patrulla asignada',
    description: 'Unidad de seguridad notificada',
  ),
  enCamino(
    label: 'Patrulla en camino',
    description: 'Unidad dirigiéndose al lugar de la alerta',
  ),
  enLugar(
    label: 'En el lugar',
    description: 'Personal de seguridad interviniendo la zona',
  ),
  resuelto(
    label: 'Resuelto',
    description: 'Incidente atendido y concluido',
  ),
  cancelado(
    label: 'Cancelado',
    description: 'Alerta cancelada por el usuario o falsa alarma',
  );

  final String label;
  final String description;

  const IncidentStatus({
    required this.label,
    required this.description,
  });

  /// El incidente ya no requiere acción (resuelto o cancelado)
  bool get isClosed =>
      this == IncidentStatus.resuelto || this == IncidentStatus.cancelado;
}

/// Nivel de urgencia de la alerta
enum UrgencyLevel {
  critica(label: 'Crítica'),
  alta(label: 'Alta'),
  media(label: 'Media'),
  baja(label: 'Baja');

  final String label;

  const UrgencyLevel({required this.label});
}

/// Estado del agente o patrulla policial
enum PatrolStatus {
  disponible(label: 'Disponible'),
  enRespuesta(label: 'En intervención'),
  fueraServicio(label: 'Fuera de servicio');

  final String label;

  const PatrolStatus({required this.label});
}
