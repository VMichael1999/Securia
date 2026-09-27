import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import '../models/geo_location.dart';

/// Utilidades de cálculo geográfico, distancias y generación de polilíneas
class GeoUtils {
  static const double _earthRadiusKm = 6371.0;

  /// Velocidad promedio de una patrulla en respuesta de emergencia urbana
  static const double patrolResponseSpeedKmh = 45.0;

  /// Calcula la distancia geodésica en kilómetros entre dos coordenadas (Haversine)
  static double calculateDistanceKm(GeoLocation p1, GeoLocation p2) {
    final lat1 = p1.latitude * math.pi / 180.0;
    final lon1 = p1.longitude * math.pi / 180.0;
    final lat2 = p2.latitude * math.pi / 180.0;
    final lon2 = p2.longitude * math.pi / 180.0;

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return _earthRadiusKm * c;
  }

  /// Verifica si una coordenada se encuentra dentro de un radio de cobertura en kilómetros
  static bool isWithinRadius(
    GeoLocation center,
    GeoLocation target,
    double radiusKm,
  ) {
    return calculateDistanceKm(center, target) <= radiusKm;
  }

  /// Formatea la distancia a metros o kilómetros de forma amigable
  static String formatDistance(double km) {
    if (km < 1.0) {
      final meters = (km * 1000).round();
      return '$meters m';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  /// Estima el tiempo de arribo (ETA) en minutos a una velocidad promedio en km/h
  static int estimateEtaMinutes(double km, {double averageSpeedKmh = 35.0}) {
    final hours = km / averageSpeedKmh;
    final minutes = (hours * 60).ceil();
    return math.max(1, minutes);
  }

  /// Genera una polilínea urbana realista que sigue trazos rectangulares de calles
  /// en lugar de una línea recta diagonal que atravesaría manzanas
  static List<GeoLocation> generateUrbanPolyline(
    GeoLocation origin,
    GeoLocation destination,
  ) {
    final waypoints = <GeoLocation>[origin];

    final lat1 = origin.latitude;
    final lon1 = origin.longitude;
    final lat2 = destination.latitude;
    final lon2 = destination.longitude;

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    // Crea puntos de inflexión de avenidas perpendiculares
    // Punto intermedio 1 (Avenida principal)
    final midLat1 = lat1 + (dLat * 0.45);
    final midLon1 = lon1 + (dLon * 0.10);
    waypoints.add(
      GeoLocation(
        latitude: midLat1,
        longitude: midLon1,
        address: 'Vía de aproximación',
      ),
    );

    // Punto intermedio 2 (Giro en cruce)
    final midLat2 = lat1 + (dLat * 0.50);
    final midLon2 = lon1 + (dLon * 0.65);
    waypoints.add(
      GeoLocation(
        latitude: midLat2,
        longitude: midLon2,
        address: 'Giro a la derecha',
      ),
    );

    // Punto intermedio 3 (Tramo final directo)
    final midLat3 = lat1 + (dLat * 0.88);
    final midLon3 = lon1 + (dLon * 0.95);
    waypoints.add(
      GeoLocation(
        latitude: midLat3,
        longitude: midLon3,
        address: 'Aproximación final',
      ),
    );

    waypoints.add(destination);
    return waypoints;
  }

  /// Convierte una lista de [GeoLocation] a [LatLng] para FlutterMap PolylineLayer
  static List<LatLng> toLatLngList(List<GeoLocation> locations) {
    return locations.map((loc) => loc.toLatLng()).toList();
  }
}
