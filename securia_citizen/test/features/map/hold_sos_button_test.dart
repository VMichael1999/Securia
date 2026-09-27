import 'package:flutter_test/flutter_test.dart';
import 'package:securia_citizen/app/strings/sos_strings.dart';
import 'package:securia_citizen/features/map/presentation/widgets/hold_sos_button.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('Un toque corto no envía la alerta', (tester) async {
    var triggered = 0;
    await pumpApp(tester, HoldSosButton(onTriggered: () => triggered++));

    await tester.tap(find.text(SosStrings.sosLabel));
    await tester.pump(const Duration(seconds: 2));

    expect(triggered, 0);
  });

  testWidgets('Soltar antes de 1,5 s cancela el gesto', (tester) async {
    var triggered = 0;
    await pumpApp(tester, HoldSosButton(onTriggered: () => triggered++));

    final gesture = await tester.startGesture(
      tester.getCenter(find.text(SosStrings.sosLabel)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text(SosStrings.sosKeepHolding), findsOneWidget);

    await gesture.up();
    await tester.pump(const Duration(seconds: 2));

    expect(triggered, 0);
    expect(find.text(SosStrings.sosHoldHint), findsOneWidget);
  });

  testWidgets('Mantener presionado 1,5 s envía la alerta una sola vez', (
    tester,
  ) async {
    var triggered = 0;
    await pumpApp(tester, HoldSosButton(onTriggered: () => triggered++));

    final gesture = await tester.startGesture(
      tester.getCenter(find.text(SosStrings.sosLabel)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 200));

    expect(triggered, 1);
  });

  testWidgets('Mientras envía, ignora nuevos gestos y lo indica', (
    tester,
  ) async {
    var triggered = 0;
    await pumpApp(
      tester,
      HoldSosButton(isSending: true, onTriggered: () => triggered++),
    );

    expect(find.text(SosStrings.sosSending), findsOneWidget);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text(SosStrings.sosSending)),
    );
    await tester.pump(const Duration(seconds: 2));
    await gesture.up();

    expect(triggered, 0);
  });
}
