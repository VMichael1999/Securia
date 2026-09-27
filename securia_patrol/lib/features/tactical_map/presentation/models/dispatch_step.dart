import 'package:securia_core/securia_core.dart';

/// Siguiente acción que la unidad debe tomar sobre un incidente.
///
/// La HUD muestra siempre un único botón principal en el mismo lugar:
/// ACEPTAR → EN CAMINO → LLEGUÉ → CONCLUIR.
enum DispatchStep {
  accept,
  onTheWay,
  arrived,
  conclude,

  /// Lo atiende otra unidad, o ya está cerrado: no hay acción para esta unidad
  none;

  static DispatchStep of(IncidentModel incident, {required String patrolId}) {
    final isMine = incident.assignedPatrolId == patrolId;
    switch (incident.status) {
      case IncidentStatus.reportado:
        return DispatchStep.accept;
      case IncidentStatus.asignado:
        return isMine ? DispatchStep.onTheWay : DispatchStep.none;
      case IncidentStatus.enCamino:
        return isMine ? DispatchStep.arrived : DispatchStep.none;
      case IncidentStatus.enLugar:
        return isMine ? DispatchStep.conclude : DispatchStep.none;
      case IncidentStatus.resuelto:
      case IncidentStatus.cancelado:
        return DispatchStep.none;
    }
  }
}
