import 'package:test/test.dart';
import 'package:securia_core/securia_core.dart';

void main() {
  late InMemorySecuriaRepository repo;
  const location = GeoLocation(latitude: -12.0864, longitude: -77.0345);

  setUp(() => repo = InMemorySecuriaRepository.fresh());

  Matcher authError(CitizenAuthError error) =>
      isA<CitizenAuthException>().having((e) => e.error, 'error', error);

  test('Sin sesión no hay ciudadano actual', () {
    expect(repo.getCurrentCitizen(), isNull);
  });

  test('Inicia sesión con DNI y celular sin importar espacios', () async {
    final citizen = await repo.signInCitizen(
      dni: '74829104',
      phone: '984512893',
    );

    expect(citizen.fullName, contains('Michael'));
    expect(repo.getCurrentCitizen()?.id, citizen.id);
  });

  test('Rechaza un DNI no registrado', () {
    expect(
      repo.signInCitizen(dni: '00000000', phone: '999999999'),
      throwsA(authError(CitizenAuthError.notRegistered)),
    );
  });

  test('Rechaza un celular que no coincide con el DNI', () {
    expect(
      repo.signInCitizen(dni: '74829104', phone: '911111111'),
      throwsA(authError(CitizenAuthError.phoneMismatch)),
    );
  });

  test(
    'Registrar deja la sesión iniciada y permite volver a ingresar',
    () async {
      final nuevo = await repo.registerCitizen(
        fullName: 'Rosa Quispe',
        dni: '45678912',
        phone: '987 654 321',
      );
      expect(repo.getCurrentCitizen()?.id, nuevo.id);

      await repo.signOutCitizen();
      expect(repo.getCurrentCitizen(), isNull);

      final again = await repo.signInCitizen(
        dni: '45678912',
        phone: '987654321',
      );
      expect(again.id, nuevo.id);
    },
  );

  test('No permite registrar dos veces el mismo DNI', () {
    expect(
      repo.registerCitizen(
        fullName: 'Otro',
        dni: '74829104',
        phone: '900000000',
      ),
      throwsA(authError(CitizenAuthError.alreadyRegistered)),
    );
  });

  test('Cada ciudadano reporta con sus propios datos', () async {
    final rosa = await repo.registerCitizen(
      fullName: 'Rosa Quispe',
      dni: '45678912',
      phone: '987654321',
    );
    final incident = await repo.createIncident(
      type: IncidentType.robo,
      title: 'Robo',
      description: '',
      location: location,
      urgency: UrgencyLevel.alta,
    );

    expect(incident.citizenId, rosa.id);
    expect(incident.citizenName, 'Rosa Quispe');
  });

  test('Sin sesión no se puede reportar', () {
    expect(
      repo.createIncident(
        type: IncidentType.robo,
        title: 'Robo',
        description: '',
        location: location,
        urgency: UrgencyLevel.alta,
      ),
      throwsStateError,
    );
  });
}
