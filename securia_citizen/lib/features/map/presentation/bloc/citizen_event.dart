import 'package:securia_core/securia_core.dart';
import '../../data/location_service.dart';

abstract class CitizenEvent {
  const CitizenEvent();
}

class CitizenStarted extends CitizenEvent {
  const CitizenStarted();
}

class CitizenIncidentsUpdated extends CitizenEvent {
  final List<IncidentModel> incidents;
  const CitizenIncidentsUpdated(this.incidents);
}

class CitizenFilterChanged extends CitizenEvent {
  final bool? filterTodayOnly;
  final IncidentType? selectedCategory;
  final bool clearCategory;

  const CitizenFilterChanged({
    this.filterTodayOnly,
    this.selectedCategory,
    this.clearCategory = false,
  });
}

/// SOS inmediato: se emite con un solo gesto, sin formulario.
/// El tipo se puede precisar después con [CitizenSosDetailsUpdated].
class CitizenImmediateSosRequested extends CitizenEvent {
  final GeoLocation location;
  const CitizenImmediateSosRequested(this.location);
}

/// Reporte con detalle: tipo elegido y, opcionalmente, observación y foto.
/// La urgencia se deriva del tipo ([IncidentType.defaultUrgency]).
class CitizenIncidentReportRequested extends CitizenEvent {
  final IncidentType type;
  final GeoLocation location;
  final String? description;
  final String? photoPath;

  const CitizenIncidentReportRequested({
    required this.type,
    required this.location,
    this.description,
    this.photoPath,
  });
}

/// Completa una alerta ya enviada con tipo, comentario o foto.
class CitizenSosDetailsUpdated extends CitizenEvent {
  final String incidentId;
  final IncidentType? type;
  final String? description;
  final String? photoPath;

  const CitizenSosDetailsUpdated(
    this.incidentId, {
    this.type,
    this.description,
    this.photoPath,
  });
}

class CitizenCancelActiveSos extends CitizenEvent {
  final String incidentId;
  const CitizenCancelActiveSos(this.incidentId);
}

class CitizenSelectIncidentForPreview extends CitizenEvent {
  final IncidentModel? incident;
  const CitizenSelectIncidentForPreview(this.incident);
}

/// Nueva lectura del GPS (o cambio de permiso / estado del GPS)
class CitizenLocationChanged extends CitizenEvent {
  final LocationReading reading;
  const CitizenLocationChanged(this.reading);
}
