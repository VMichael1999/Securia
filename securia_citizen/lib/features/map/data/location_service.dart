import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:securia_core/securia_core.dart';

/// Qué tan confiable es la ubicación con la que saldría una alerta
enum LocationStatus {
  /// Todavía no hay una lectura del GPS
  locating,

  /// Lectura reciente con margen pequeño
  precise,

  /// Hay lectura, pero con margen grande o antigua
  imprecise,

  /// El usuario no dio permiso de ubicación
  denied,

  /// El GPS del teléfono está apagado
  disabled,
}

/// Una lectura del GPS con su margen de error
class LocationReading {
  final LocationStatus status;
  final GeoLocation? location;
  final double? accuracyMeters;
  final DateTime? takenAt;

  const LocationReading({
    required this.status,
    this.location,
    this.accuracyMeters,
    this.takenAt,
  });

  /// Margen a partir del cual se avisa que la ubicación es imprecisa
  static const double impreciseAboveMeters = 50;

  /// Antigüedad a partir de la cual una lectura deja de ser confiable
  static const Duration staleAfter = Duration(minutes: 2);

  static LocationStatus classify(double accuracyMeters, Duration age) =>
      accuracyMeters > impreciseAboveMeters || age > staleAfter
          ? LocationStatus.imprecise
          : LocationStatus.precise;
}

/// Fuente de ubicación del ciudadano (GPS real o simulada en pruebas)
abstract class LocationService {
  /// Lecturas continuas; la primera llega con [LocationStatus.locating]
  Stream<LocationReading> watch();

  /// Abre los ajustes para dar permiso o encender el GPS
  Future<void> openSettings();
}

/// Ubicación real con geolocator y dirección legible con geocoding
class GeolocatorLocationService implements LocationService {
  static const _settings = LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 10,
  );

  @override
  Stream<LocationReading> watch() async* {
    yield const LocationReading(status: LocationStatus.locating);

    if (!await Geolocator.isLocationServiceEnabled()) {
      yield const LocationReading(status: LocationStatus.disabled);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      yield const LocationReading(status: LocationStatus.denied);
      return;
    }

    final last = await Geolocator.getLastKnownPosition();
    if (last != null) yield await _toReading(last);

    yield* Geolocator.getPositionStream(locationSettings: _settings)
        .asyncMap(_toReading);
  }

  Future<LocationReading> _toReading(Position position) async {
    final age = DateTime.now().difference(position.timestamp);
    return LocationReading(
      status: LocationReading.classify(position.accuracy, age),
      location: GeoLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: await _addressOf(position),
      ),
      accuracyMeters: position.accuracy,
      takenAt: position.timestamp,
    );
  }

  /// "Calle Las Begonias, San Isidro"; si falla, las coordenadas
  Future<String> _addressOf(Position p) async {
    try {
      final places = await placemarkFromCoordinates(p.latitude, p.longitude);
      if (places.isNotEmpty) {
        final place = places.first;
        final parts = [place.thoroughfare, place.subLocality ?? place.locality]
            .where((part) => part != null && part.trim().isNotEmpty)
            .toList();
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {
      // Sin red o sin geocodificador: se usan coordenadas
    }
    return '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}';
  }

  @override
  Future<void> openSettings() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    } else {
      await Geolocator.openLocationSettings();
    }
  }
}
