import 'package:flutter_test/flutter_test.dart';
import 'package:securia_citizen/app/strings/sos_strings.dart';
import 'package:securia_citizen/features/map/presentation/widgets/alert_status_tracker.dart';
import 'package:securia_core/securia_core.dart';

import '../../helpers/pump_app.dart';

void main() {
  final base = IncidentModel(
    id: 'inc_1',
    type: IncidentType.asalto,
    title: 'Asalto',
    description: '',
    location: const GeoLocation(latitude: -12.0864, longitude: -77.0345),
    citizenId: 'cit_001',
    citizenName: 'Ciudadano',
    citizenPhone: '999',
    timestamp: DateTime(2026, 9, 25),
  );

  Future<List<String>> pumpTracker(
    WidgetTester tester,
    IncidentModel incident,
  ) async {
    final calls = <String>[];
    await pumpApp(
      tester,
      AlertStatusTracker(
        incident: incident,
        onTap: () => calls.add('tap'),
        onCall: () => calls.add('call'),
        onAddDetails: () => calls.add('details'),
        onCancel: () => calls.add('cancel'),
      ),
    );
    return calls;
  }

  testWidgets('Recién enviada indica que busca patrulla', (tester) async {
    await pumpTracker(tester, base);
    expect(find.text(SosStrings.trackerSearching), findsOneWidget);
    expect(find.text(IncidentType.asalto.shortLabel), findsOneWidget);
  });

  testWidgets('En camino muestra la unidad y el tiempo estimado', (
    tester,
  ) async {
    await pumpTracker(
      tester,
      base.copyWith(
        status: IncidentStatus.enCamino,
        assignedPatrolCode: 'PL-402',
        assignedPatrolLocation: const GeoLocation(
          latitude: -12.0835,
          longitude: -77.0378,
        ),
      ),
    );
    expect(find.text(SosStrings.trackerOnTheWay), findsOneWidget);
    expect(find.textContaining('PL-402 · Llega en ~'), findsOneWidget);
  });

  testWidgets('En el lugar muestra al oficial interviniendo', (tester) async {
    await pumpTracker(
      tester,
      base.copyWith(
        status: IncidentStatus.enLugar,
        assignedPatrolCode: 'PL-402',
      ),
    );
    expect(find.text(SosStrings.trackerOnSite), findsOneWidget);
  });

  testWidgets('Cada botón dispara su acción', (tester) async {
    final calls = await pumpTracker(tester, base);

    await tester.tap(find.text(SosStrings.call105));
    await tester.tap(find.text(SosStrings.addDetails));
    await tester.tap(find.text(SosStrings.cancelAlert));

    expect(calls, ['call', 'details', 'cancel']);
  });
}
