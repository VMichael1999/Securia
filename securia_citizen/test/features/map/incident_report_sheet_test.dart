import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securia_citizen/app/strings/sos_strings.dart';
import 'package:securia_citizen/features/map/presentation/widgets/incident_report_sheet.dart';
import 'package:securia_core/securia_core.dart';

import '../../helpers/fake_platform.dart';
import '../../helpers/pump_app.dart';

void main() {
  setUpAll(mockNoCamera);

  Future<void> openSheet(
    WidgetTester tester,
    ValueChanged<IncidentReport?> onResult,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpApp(
      tester,
      Builder(
        builder:
            (context) => TextButton(
              onPressed:
                  () async => onResult(await IncidentReportSheet.show(context)),
              child: const Text('abrir'),
            ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('Enviar está deshabilitado hasta elegir el tipo', (tester) async {
    IncidentReport? result;
    await openSheet(tester, (r) => result = r);

    await tester.ensureVisible(find.text(SosStrings.reportChooseType));
    await tester.tap(find.text(SosStrings.reportChooseType));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.text(SosStrings.reportSubtitle), findsOneWidget);
  });

  testWidgets('Devuelve tipo, observación y foto', (tester) async {
    IncidentReport? result;
    await openSheet(tester, (r) => result = r);

    await tester.tap(find.text(IncidentType.violencia.shortLabel));
    await tester.pump();
    // En el entorno de test no hay cámara: se adjunta la evidencia simulada
    await tester.tap(find.text(SosStrings.detailsCamera));
    await tester.pumpAndSettle();
    expect(find.text(SosStrings.detailsPhotoAttached), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  Pelea en la esquina ');
    await tester.ensureVisible(find.text(SosStrings.reportSend));
    await tester.tap(find.text(SosStrings.reportSend));
    await tester.pumpAndSettle();

    expect(result?.type, IncidentType.violencia);
    expect(result?.description, 'Pelea en la esquina');
    expect(result?.photoPath, SosStrings.simulatedPhoto);
  });

  testWidgets('Sin observación ni foto envía solo el tipo', (tester) async {
    IncidentReport? result;
    await openSheet(tester, (r) => result = r);

    await tester.tap(find.text(IncidentType.accidenteTransito.shortLabel));
    await tester.pump();
    await tester.ensureVisible(find.text(SosStrings.reportSend));
    await tester.tap(find.text(SosStrings.reportSend));
    await tester.pumpAndSettle();

    expect(result?.type, IncidentType.accidenteTransito);
    expect(result?.description, isNull);
    expect(result?.photoPath, isNull);
  });
}
