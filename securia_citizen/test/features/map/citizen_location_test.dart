import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securia_citizen/app/injection.dart';
import 'package:securia_citizen/app/strings/sos_strings.dart';
import 'package:securia_citizen/features/map/data/location_service.dart';
import 'package:securia_citizen/features/map/presentation/bloc/citizen_bloc.dart';
import 'package:securia_citizen/features/map/presentation/bloc/citizen_event.dart';
import 'package:securia_citizen/features/map/presentation/views/citizen_map_view.dart';
import 'package:securia_core/securia_core.dart';

import '../../helpers/fake_location_service.dart';
import '../../helpers/fake_platform.dart';
import '../../helpers/pump_app.dart';

void main() {
  late InMemorySecuriaRepository repo;
  late CitizenBloc bloc;
  late FakeLocationService gps;

  setUpAll(() {
    mockPlatformPlugins();
    SecuriaMap.debugUseFakeMap = true;
  });

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> pumpMap(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await getIt.reset();
    repo = InMemorySecuriaRepository.fresh();
    gps = FakeLocationService();
    getIt.registerSingleton<LocationService>(gps);
    final citizen = await repo.signInCitizen(
      dni: InMemorySecuriaRepository.demoDni,
      phone: InMemorySecuriaRepository.demoPhone,
    );
    bloc = CitizenBloc(
      repository: repo,
      citizen: citizen,
      locationService: gps,
    );
    addTearDown(bloc.close);

    await pumpApp(
      tester,
      const CitizenMapView(),
      providers: [BlocProvider<CitizenBloc>.value(value: bloc)],
    );
    bloc.add(const CitizenStarted());
    await settle(tester);
  }

  testWidgets('Mientras no hay GPS lo dice y el SOS sigue disponible', (
    tester,
  ) async {
    await pumpMap(tester);

    expect(find.text(SosStrings.locating), findsOneWidget);
    expect(find.text(SosStrings.sosLabel), findsOneWidget);
    expect(find.text(SosStrings.reportButton), findsOneWidget);
  });

  testWidgets('Con GPS preciso muestra dónde estás y con qué margen', (
    tester,
  ) async {
    await pumpMap(tester);
    gps.emit(FakeLocationService.precise);
    await settle(tester);

    expect(find.text('Calle Las Begonias, San Isidro'), findsOneWidget);
    expect(find.text(SosStrings.accuracy(8)), findsOneWidget);
    expect(bloc.state.userLocation.address, 'Calle Las Begonias, San Isidro');
  });

  testWidgets('El SOS sale con la ubicación real del GPS', (tester) async {
    await pumpMap(tester);
    gps.emit(FakeLocationService.precise);
    await settle(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text(SosStrings.sosLabel)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await gesture.up();
    await settle(tester);

    final sent = repo.getSnapshotIncidents().first;
    expect(sent.location.latitude, -12.0920);
    expect(sent.location.address, 'Calle Las Begonias, San Isidro');
  });

  testWidgets(
    'Ubicación imprecisa: avisa, ofrece corregirla y el segundo botón llama al 105',
    (tester) async {
      await pumpMap(tester);
      gps.emit(FakeLocationService.imprecise());
      await settle(tester);

      expect(find.text(SosStrings.impreciseTitle), findsOneWidget);
      expect(find.textContaining('±150 m'), findsOneWidget);
      expect(find.text(SosStrings.call105), findsOneWidget);
      expect(find.text(SosStrings.reportButton), findsNothing);
      // El SOS nunca se desactiva
      expect(find.text(SosStrings.sosLabel), findsOneWidget);

      await tester.tap(find.text(SosStrings.impreciseAction));
      expect(gps.settingsOpened, 1);
    },
  );

  testWidgets('Sin permiso de ubicación explica qué hacer', (tester) async {
    await pumpMap(tester);
    gps.emit(const LocationReading(status: LocationStatus.denied));
    await settle(tester);

    expect(find.text(SosStrings.deniedTitle), findsOneWidget);
    expect(find.text(SosStrings.deniedAction), findsOneWidget);
    expect(find.text(SosStrings.call105), findsOneWidget);
  });

  testWidgets(
    'Al mantener el SOS la pantalla se apaga y explica cómo cancelar',
    (tester) async {
      await pumpMap(tester);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text(SosStrings.sosLabel)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.textContaining('Suelta para cancelar'), findsOneWidget);

      await gesture.up();
      await tester.pump();
      // Al soltar, el anillo se vacía rápido (250 ms) y la pantalla vuelve
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('Suelta para cancelar'), findsNothing);
      expect(
        repo.getSnapshotIncidents().any(
          (i) =>
              i.citizenId == bloc.state.citizenProfile.id && !i.status.isClosed,
        ),
        isFalse,
      );
    },
  );

  testWidgets('Con alerta activa el gesto atrás no cierra la pantalla', (
    tester,
  ) async {
    await pumpMap(tester);
    bloc.add(CitizenImmediateSosRequested(bloc.state.userLocation));
    await settle(tester);
    // Cierra la pregunta de seguimiento
    await tester.tap(find.text(SosStrings.followUpSkip));
    await settle(tester);

    final handled = await tester.binding.handlePopRoute();
    await settle(tester);

    expect(handled, isTrue);
    expect(find.text(SosStrings.backBlocked), findsOneWidget);
    expect(find.text(SosStrings.trackerSearching), findsOneWidget);
  });
}
