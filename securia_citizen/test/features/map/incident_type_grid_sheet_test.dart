import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securia_citizen/features/map/presentation/widgets/incident_type_grid_sheet.dart';
import 'package:securia_core/securia_core.dart';

import '../../helpers/pump_app.dart';

void main() {
  const title = 'Título';

  /// Abre la hoja desde un botón y entrega el resultado a [onResult]
  Future<void> openSheet(
    WidgetTester tester, {
    required List<IncidentType> types,
    required ValueChanged<IncidentType?> onResult,
    String? skipLabel,
  }) async {
    await pumpApp(
      tester,
      Builder(
        builder:
            (context) => TextButton(
              onPressed:
                  () async => onResult(
                    await IncidentTypeGridSheet.show(
                      context,
                      title: title,
                      subtitle: 'Subtítulo',
                      types: types,
                      skipLabel: skipLabel,
                    ),
                  ),
              child: const Text('abrir'),
            ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('Muestra un mosaico por cada tipo de reporte', (tester) async {
    await openSheet(tester, types: IncidentType.reportTypes, onResult: (_) {});

    for (final type in IncidentType.reportTypes) {
      expect(find.text(type.shortLabel), findsOneWidget);
    }
    expect(find.text(IncidentType.emergenciaGeneral.shortLabel), findsNothing);
  });

  testWidgets('Un toque en un tipo lo devuelve y cierra la hoja', (
    tester,
  ) async {
    IncidentType? selected;
    await openSheet(
      tester,
      types: IncidentType.reportTypes,
      onResult: (type) => selected = type,
    );

    await tester.tap(find.text(IncidentType.incendio.shortLabel));
    await tester.pumpAndSettle();

    expect(selected, IncidentType.incendio);
    expect(find.text(title), findsNothing);
  });

  testWidgets('Omitir cierra sin elegir tipo', (tester) async {
    IncidentType? selected = IncidentType.otro;
    await openSheet(
      tester,
      types: IncidentType.sosFollowUpTypes,
      skipLabel: 'Omitir',
      onResult: (type) => selected = type,
    );

    await tester.tap(find.text('Omitir'));
    await tester.pumpAndSettle();

    expect(selected, isNull);
    expect(find.text(title), findsNothing);
  });
}
