import 'enums.dart';
import 'geo_location.dart';

/// Modelo de Unidad Policial o Serenazgo en servicio de patrullaje
class PatrolUnitModel {
  final String id;
  final String unitCode;
  final String officerName;
  final String phone;
  final GeoLocation location;
  final double coverageRadiusKm;
  final PatrolStatus status;
  final String? activeIncidentId;

  const PatrolUnitModel({
    required this.id,
    required this.unitCode,
    required this.officerName,
    required this.phone,
    required this.location,
    this.coverageRadiusKm = 3.0,
    this.status = PatrolStatus.disponible,
    this.activeIncidentId,
  });

  PatrolUnitModel copyWith({
    String? id,
    String? unitCode,
    String? officerName,
    String? phone,
    GeoLocation? location,
    double? coverageRadiusKm,
    PatrolStatus? status,
    String? activeIncidentId,
  }) {
    return PatrolUnitModel(
      id: id ?? this.id,
      unitCode: unitCode ?? this.unitCode,
      officerName: officerName ?? this.officerName,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      coverageRadiusKm: coverageRadiusKm ?? this.coverageRadiusKm,
      status: status ?? this.status,
      activeIncidentId: activeIncidentId ?? this.activeIncidentId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'unitCode': unitCode,
        'officerName': officerName,
        'phone': phone,
        'location': location.toJson(),
        'coverageRadiusKm': coverageRadiusKm,
        'status': status.name,
        'activeIncidentId': activeIncidentId,
      };

  factory PatrolUnitModel.fromJson(Map<String, dynamic> json) => PatrolUnitModel(
        id: json['id'] as String,
        unitCode: json['unitCode'] as String,
        officerName: json['officerName'] as String,
        phone: json['phone'] as String,
        location: GeoLocation.fromJson(json['location'] as Map<String, dynamic>),
        coverageRadiusKm: (json['coverageRadiusKm'] as num?)?.toDouble() ?? 3.0,
        status: PatrolStatus.values.byName(json['status'] as String),
        activeIncidentId: json['activeIncidentId'] as String?,
      );
}
