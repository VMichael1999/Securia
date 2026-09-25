import 'package:get_it/get_it.dart';
import 'package:securia_core/securia_core.dart';

final getIt = GetIt.instance;

void setupCitizenDependencies() {
  if (!getIt.isRegistered<ISecuriaRepository>()) {
    getIt.registerLazySingleton<ISecuriaRepository>(
      () => InMemorySecuriaRepository(),
    );
  }
}
