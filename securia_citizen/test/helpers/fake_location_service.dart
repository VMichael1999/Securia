import 'dart:async';

import 'package:securia_citizen/features/map/data/location_service.dart';
import 'package:securia_core/securia_core.dart';

/// Ubicación simulada para pruebas: se le empujan lecturas a voluntad
class FakeLocationService implements LocationService {
  final _controller = StreamController<LocationReading>.broadcast();
  int settingsOpened = 0;

  /// Lectura precisa en San Isidro (±8 m)
  static final LocationReading precise = LocationReading(
    status: LocationStatus.precise,
    location: const GeoLocation(
      latitude: -12.0920,
      longitude: -77.0330,
      address: 'Calle Las Begonias, San Isidro',
    ),
    accuracyMeters: 8,
    takenAt: DateTime.now(),
  );

  /// Lectura vieja y con margen grande (±150 m, hace 6 min)
  static LocationReading imprecise() => LocationReading(
    status: LocationStatus.imprecise,
    location: const GeoLocation(
      latitude: -12.0920,
      longitude: -77.0330,
      address: 'Calle Las Begonias, San Isidro',
    ),
    accuracyMeters: 150,
    takenAt: DateTime.now().subtract(const Duration(minutes: 6)),
  );

  void emit(LocationReading reading) => _controller.add(reading);

  @override
  Stream<LocationReading> watch() => _controller.stream;

  @override
  Future<void> openSettings() async => settingsOpened++;
}
