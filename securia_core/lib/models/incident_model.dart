import 'enums.dart';
import 'geo_location.dart';

/// Modelo de Incidente reportado por un ciudadano
class IncidentModel {
  final String id;
  final IncidentType type;
  final String title;
  final String description;
  final GeoLocation location;
  final String? photoBase64;
  final String? photoPath;
  final String citizenId;
  final String citizenName;
  final String citizenPhone;
  final DateTime timestamp;
  final IncidentStatus status;
  final UrgencyLevel urgency;
  final String? assignedPatrolId;
  final String? assignedPatrolCode;
  final String? assignedOfficerName;
  final GeoLocation? assignedPatrolLocation;
  final List<GeoLocation> routeWaypoints;
  final List<String> notes;

  const IncidentModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.location,
    this.photoBase64,
    this.photoPath,
    required this.citizenId,
    required this.citizenName,
    required this.citizenPhone,
    required this.timestamp,
    this.status = IncidentStatus.reportado,
    this.urgency = UrgencyLevel.alta,
    this.assignedPatrolId,
    this.assignedPatrolCode,
    this.assignedOfficerName,
    this.assignedPatrolLocation,
    this.routeWaypoints = const [],
    this.notes = const [],
  });

  /// Indica si el reporte fue emitido el día de hoy
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  /// Indica si el incidente tiene asignada una patrulla en camino
  bool get hasActivePatrol =>
      assignedPatrolId != null &&
      (status == IncidentStatus.enCamino || status == IncidentStatus.enLugar);

  IncidentModel copyWith({
    String? id,
    IncidentType? type,
    String? title,
    String? description,
    GeoLocation? location,
    String? photoBase64,
    String? photoPath,
    String? citizenId,
    String? citizenName,
    String? citizenPhone,
    DateTime? timestamp,
    IncidentStatus? status,
    UrgencyLevel? urgency,
    String? assignedPatrolId,
    String? assignedPatrolCode,
    String? assignedOfficerName,
    GeoLocation? assignedPatrolLocation,
    List<GeoLocation>? routeWaypoints,
    List<String>? notes,
  }) {
    return IncidentModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      photoBase64: photoBase64 ?? this.photoBase64,
      photoPath: photoPath ?? this.photoPath,
      citizenId: citizenId ?? this.citizenId,
      citizenName: citizenName ?? this.citizenName,
      citizenPhone: citizenPhone ?? this.citizenPhone,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      urgency: urgency ?? this.urgency,
      assignedPatrolId: assignedPatrolId ?? this.assignedPatrolId,
      assignedPatrolCode: assignedPatrolCode ?? this.assignedPatrolCode,
      assignedOfficerName: assignedOfficerName ?? this.assignedOfficerName,
      assignedPatrolLocation:
          assignedPatrolLocation ?? this.assignedPatrolLocation,
      routeWaypoints: routeWaypoints ?? this.routeWaypoints,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'description': description,
        'location': location.toJson(),
        'photoBase64': photoBase64,
        'photoPath': photoPath,
        'citizenId': citizenId,
        'citizenName': citizenName,
        'citizenPhone': citizenPhone,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
        'urgency': urgency.name,
        'assignedPatrolId': assignedPatrolId,
        'assignedPatrolCode': assignedPatrolCode,
        'assignedOfficerName': assignedOfficerName,
        'assignedPatrolLocation': assignedPatrolLocation?.toJson(),
        'routeWaypoints': routeWaypoints.map((w) => w.toJson()).toList(),
        'notes': notes,
      };

  factory IncidentModel.fromJson(Map<String, dynamic> json) => IncidentModel(
        id: json['id'] as String,
        type: IncidentType.values.byName(json['type'] as String),
        title: json['title'] as String,
        description: json['description'] as String,
        location: GeoLocation.fromJson(json['location'] as Map<String, dynamic>),
        photoBase64: json['photoBase64'] as String?,
        photoPath: json['photoPath'] as String?,
        citizenId: json['citizenId'] as String,
        citizenName: json['citizenName'] as String,
        citizenPhone: json['citizenPhone'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        status: IncidentStatus.values.byName(json['status'] as String),
        urgency: UrgencyLevel.values.byName(json['urgency'] as String),
        assignedPatrolId: json['assignedPatrolId'] as String?,
        assignedPatrolCode: json['assignedPatrolCode'] as String?,
        assignedOfficerName: json['assignedOfficerName'] as String?,
        assignedPatrolLocation: json['assignedPatrolLocation'] != null
            ? GeoLocation.fromJson(
                json['assignedPatrolLocation'] as Map<String, dynamic>)
            : null,
        routeWaypoints: (json['routeWaypoints'] as List<dynamic>?)
                ?.map((w) => GeoLocation.fromJson(w as Map<String, dynamic>))
                .toList() ??
            const [],
        notes: (json['notes'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );
}
