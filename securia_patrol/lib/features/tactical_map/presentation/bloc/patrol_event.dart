import 'package:securia_core/securia_core.dart';

abstract class PatrolEvent {
  const PatrolEvent();
}

/// Inicio de sesión / vinculación de patrulla activa
class PatrolStarted extends PatrolEvent {
  final PatrolUnitModel unit;
  const PatrolStarted(this.unit);
}

/// Recepción en tiempo real de la lista de incidentes emitida por el repositorio
class PatrolIncidentsReceived extends PatrolEvent {
  final List<IncidentModel> incidents;
  const PatrolIncidentsReceived(this.incidents);
}

/// Actualización de la posición GPS de la patrulla
class PatrolLocationUpdated extends PatrolEvent {
  final GeoLocation newLocation;
  const PatrolLocationUpdated(this.newLocation);
}

/// Selección de un incidente en el mapa táctico o en la lista de triage
class PatrolSelectIncident extends PatrolEvent {
  final IncidentModel? incident;
  const PatrolSelectIncident(this.incident);
}

/// Aceptación del despacho de una alerta SOS
class PatrolAcceptDispatch extends PatrolEvent {
  final IncidentModel incident;
  const PatrolAcceptDispatch(this.incident);
}

/// La patrulla enciende sirenas y se dirige a la zona del incidente
class PatrolEnCamino extends PatrolEvent {
  final IncidentModel incident;
  const PatrolEnCamino(this.incident);
}

/// La patrulla arriba físicamente a las coordenadas del incidente
class PatrolEnLugar extends PatrolEvent {
  final IncidentModel incident;
  const PatrolEnLugar(this.incident);
}

/// Conclusión y resolución del incidente con acta / reporte policial
class PatrolResolveIncident extends PatrolEvent {
  final IncidentModel incident;
  final String resolutionNote;
  const PatrolResolveIncident({
    required this.incident,
    required this.resolutionNote,
  });
}

/// Alternar estado de sirena policial táctica
class PatrolToggleSiren extends PatrolEvent {
  const PatrolToggleSiren();
}

/// Descartar o silenciar banner flotante de proximidad
class PatrolDismissProximityAlert extends PatrolEvent {
  final String incidentId;
  const PatrolDismissProximityAlert(this.incidentId);
}

/// Cambio de estado de servicio de la patrulla
class PatrolChangeDutyStatus extends PatrolEvent {
  final PatrolStatus status;
  const PatrolChangeDutyStatus(this.status);
}
