import 'package:flutter/material.dart';

/// Resultados de intervención más frecuentes, para cerrar sin redactar un acta
enum ResolutionOutcome {
  detenido(
    label: 'Detenido',
    note: 'Intervención con detenido(s) trasladado(s) a comisaría.',
    icon: Icons.person_off_rounded,
  ),
  disuelto(
    label: 'Disuelto',
    note: 'Situación controlada y zona despejada por la unidad.',
    icon: Icons.groups_rounded,
  ),
  atendido(
    label: 'Atendido',
    note: 'Ciudadano atendido; se brindó apoyo en el lugar.',
    icon: Icons.volunteer_activism_rounded,
  ),
  derivado(
    label: 'Derivado',
    note: 'Caso derivado a la entidad competente (comisaría, SAMU, bomberos).',
    icon: Icons.alt_route_rounded,
  ),
  falsaAlarma(
    label: 'Falsa alarma',
    note: 'Se verificó el lugar y no se encontró incidencia.',
    icon: Icons.do_not_disturb_on_outlined,
  );

  final String label;
  final String note;
  final IconData icon;

  const ResolutionOutcome({
    required this.label,
    required this.note,
    required this.icon,
  });

  /// Nota de cierre: el resultado elegido más el detalle opcional del agente
  String buildNote(String? extra) {
    final detail = extra?.trim() ?? '';
    return detail.isEmpty ? '[$label] $note' : '[$label] $note $detail';
  }
}
