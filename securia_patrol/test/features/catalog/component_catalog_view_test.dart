import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securia_patrol/app/securia_patrol_app.dart';
import 'package:securia_patrol/app/widgets/urgency_badge.dart';
import 'package:securia_patrol/features/catalog/presentation/views/component_catalog_view.dart';

void main() {
  testWidgets('El catálogo muestra todas las urgencias y componentes sin errores', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(theme: SecuriaPatrolApp.theme, home: const ComponentCatalogView()),
    );
    await tester.pump();

    expect(find.byType(UrgencyBadge), findsNWidgets(4));
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
