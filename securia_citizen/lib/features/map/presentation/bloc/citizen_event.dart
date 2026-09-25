import 'package:securia_core/securia_core.dart';

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

class CitizenReportSosRequested extends CitizenEvent {
  final IncidentType type;
  final String description;
  final String? photoBase64;
  final String? photoPath;
  final UrgencyLevel urgency;
  final GeoLocation location;

  const CitizenReportSosRequested({
    required this.type,
    required this.description,
    this.photoBase64,
    this.photoPath,
    required this.urgency,
    required this.location,
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
