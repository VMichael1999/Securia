import 'package:get_it/get_it.dart';
import 'package:securia_core/securia_core.dart';
import '../features/map/data/location_service.dart';

final getIt = GetIt.instance;

void setupCitizenDependencies() {
  if (!getIt.isRegistered<ISecuriaRepository>()) {
    getIt.registerLazySingleton<ISecuriaRepository>(
      () => InMemorySecuriaRepository(),
    );
  }
  if (!getIt.isRegistered<LocationService>()) {
    getIt.registerLazySingleton<LocationService>(GeolocatorLocationService.new);
  }
}
