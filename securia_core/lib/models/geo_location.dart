import 'package:latlong2/latlong.dart';

/// Representación geográfica de coordenadas y referencia urbana
class GeoLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String? reference;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
    this.address = 'Ubicación seleccionada',
    this.reference,
  });

  LatLng toLatLng() => LatLng(latitude, longitude);

  static GeoLocation fromLatLng(
    LatLng point, {
    String address = 'Ubicación en el mapa',
    String? reference,
  }) {
    return GeoLocation(
      latitude: point.latitude,
      longitude: point.longitude,
      address: address,
      reference: reference,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'reference': reference,
      };

  factory GeoLocation.fromJson(Map<String, dynamic> json) => GeoLocation(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        address: json['address'] as String? ?? 'Ubicación en el mapa',
        reference: json['reference'] as String?,
      );

  GeoLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? reference,
  }) {
    return GeoLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      reference: reference ?? this.reference,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoLocation &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
