import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:securia_citizen/app/injection.dart';
import 'package:securia_citizen/app/securia_citizen_app.dart';
import 'package:securia_citizen/app/strings/auth_strings.dart';
import 'package:securia_citizen/app/strings/sos_strings.dart';
import 'package:securia_citizen/features/auth/presentation/cubit/citizen_auth_cubit.dart';
import 'package:securia_citizen/features/map/data/location_service.dart';
import 'package:securia_citizen/features/profile/presentation/views/citizen_profile_view.dart';
import 'package:securia_core/securia_core.dart';

import '../../helpers/fake_location_service.dart';
import '../../helpers/fake_platform.dart';

void main() {
  late InMemorySecuriaRepository repo;

  setUpAll(() async {
    mockPlatformPlugins();
    SecuriaMap.debugUseFakeMap = true;
    // main() inicializa las fechas en español; el test arranca la app sin main()
    await initializeDateFormatting('es');
  });

  /// El pulso del SOS se repite siempre: pumpAndSettle nunca terminaría
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    // La fuente de los tests es más ancha que la real: evita desbordes falsos
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    // Repositorio limpio por test, creado dentro del reloj simulado
    await getIt.reset();
    repo = InMemorySecuriaRepository.fresh();
    getIt.registerSingleton<ISecuriaRepository>(repo);
    getIt.registerSingleton<LocationService>(FakeLocationService());

    await tester.pumpWidget(const SecuriaCitizenApp());
    await settle(tester);
  }

  Finder field(String label) => find.descendant(
    of:
        find
            .ancestor(of: find.text(label), matching: find.byType(Column))
            .first,
    matching: find.byType(TextField),
  );

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.tap(find.text(text).last);
    await settle(tester);
  }

  Future<void> login(WidgetTester tester, String dni, String phone) async {
    await tester.enterText(field(AuthStrings.dniLabel), dni);
    await tester.enterText(field(AuthStrings.phoneLabel), phone);
    await tapText(tester, AuthStrings.loginButton);
  }

  group('Validadores', () {
    test('DNI de 8 dígitos y celular de 9', () {
      expect(CitizenAuthValidators.isValidDni('12345678'), isTrue);
      expect(CitizenAuthValidators.isValidDni('7482910'), isFalse);
      expect(CitizenAuthValidators.isValidPhone('900 000 001'), isTrue);
      expect(CitizenAuthValidators.isValidPhone('98451289'), isFalse);
      expect(CitizenAuthValidators.isValidFullName('Rosa Quispe'), isTrue);
      expect(CitizenAuthValidators.isValidFullName('Rosa'), isFalse);
    });

    test('Iniciales del avatar toleran espacios dobles', () {
      expect(CitizenProfileView.initialsOf('rosa  quispe'), 'RQ');
      expect(CitizenProfileView.initialsOf('Rosa'), 'R');
    });
  });

  testWidgets('El login empieza vacío, sin datos de otro ciudadano', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text(AuthStrings.loginTitle), findsOneWidget);
    expect(find.text('12345678'), findsNothing);
  });

  testWidgets('Datos con formato inválido muestran el error en el campo', (
    tester,
  ) async {
    await pumpApp(tester);
    await login(tester, '123', '45');

    expect(find.text(AuthStrings.dniInvalid), findsOneWidget);
    expect(find.text(AuthStrings.phoneInvalid), findsOneWidget);
    expect(repo.getCurrentCitizen(), isNull);
  });

  testWidgets('DNI no registrado invita a crear cuenta', (tester) async {
    await pumpApp(tester);
    await login(tester, '11112222', '911222333');

    expect(
      find.text(AuthStrings.error(CitizenAuthError.notRegistered)),
      findsOneWidget,
    );
  });

  testWidgets('Celular que no coincide no deja ingresar', (tester) async {
    await pumpApp(tester);
    await login(tester, '12345678', '911222333');

    expect(
      find.text(AuthStrings.error(CitizenAuthError.phoneMismatch)),
      findsOneWidget,
    );
    expect(find.text(SosStrings.sosLabel), findsNothing);
  });

  testWidgets('Un ciudadano registrado ingresa al mapa con su sesión', (
    tester,
  ) async {
    await pumpApp(tester);
    await login(tester, '12345678', '900000001');

    expect(find.text(SosStrings.sosLabel), findsOneWidget);
    expect(repo.getCurrentCitizen()?.dni, '12345678');
  });

  testWidgets('Un ciudadano nuevo se registra y entra directo al mapa', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapText(tester, AuthStrings.goToRegister);

    await tester.enterText(field(AuthStrings.fullNameLabel), 'Rosa Quispe');
    await tester.enterText(field(AuthStrings.dniLabel), '45678912');
    await tester.enterText(field(AuthStrings.phoneLabel), '987654321');
    await tapText(tester, AuthStrings.dataConsent);
    await tapText(tester, AuthStrings.registerButton);

    expect(find.text(SosStrings.sosLabel), findsOneWidget);
    expect(repo.getCurrentCitizen()?.fullName, 'Rosa Quispe');
  });

  testWidgets('Sin aceptar el tratamiento de datos no se crea la cuenta', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapText(tester, AuthStrings.goToRegister);

    await tester.enterText(field(AuthStrings.fullNameLabel), 'Rosa Quispe');
    await tester.enterText(field(AuthStrings.dniLabel), '45678912');
    await tester.enterText(field(AuthStrings.phoneLabel), '987654321');
    await tapText(tester, AuthStrings.registerButton);

    expect(find.text(AuthStrings.consentRequired), findsOneWidget);
    expect(repo.getCurrentCitizen(), isNull);
  });

  testWidgets('El consentimiento de salud es aparte y queda registrado', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapText(tester, AuthStrings.goToRegister);

    await tester.enterText(field(AuthStrings.fullNameLabel), 'Rosa Quispe');
    await tester.enterText(field(AuthStrings.dniLabel), '45678912');
    await tester.enterText(field(AuthStrings.phoneLabel), '987654321');
    await tapText(tester, AuthStrings.healthConsent);
    await tapText(tester, AuthStrings.dataConsent);
    await tapText(tester, AuthStrings.registerButton);

    final citizen = repo.getCurrentCitizen();
    expect(citizen?.dataConsentAt, isNotNull);
    expect(citizen?.hasHealthDataConsent, isTrue);
  });

  testWidgets('Registrar un DNI existente avisa que ya tiene cuenta', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapText(tester, AuthStrings.goToRegister);

    await tester.enterText(field(AuthStrings.fullNameLabel), 'Otra Persona');
    await tester.enterText(field(AuthStrings.dniLabel), '12345678');
    await tester.enterText(field(AuthStrings.phoneLabel), '900111222');
    await tapText(tester, AuthStrings.dataConsent);
    await tapText(tester, AuthStrings.registerButton);

    expect(
      find.text(AuthStrings.error(CitizenAuthError.alreadyRegistered)),
      findsOneWidget,
    );
  });

  testWidgets('Cerrar sesión pide confirmación y vuelve al login', (
    tester,
  ) async {
    await pumpApp(tester);
    await login(tester, '12345678', '900000001');

    await tapText(tester, 'Perfil');
    await tapText(tester, AuthStrings.logout);
    expect(find.text(AuthStrings.logoutTitle), findsOneWidget);

    await tapText(tester, AuthStrings.logoutConfirm);

    expect(find.text(AuthStrings.loginTitle), findsOneWidget);
    expect(repo.getCurrentCitizen(), isNull);
  });
}
