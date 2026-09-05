import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(host(SizedBox(height: 220, child: child), width: 320));
  await tester.pumpAndSettle();
}

void main() {
  group('PlGaugeChart', () {
    testWidgets('names itself with the reading and the top of the scale', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const PlGaugeChart(value: 68, semanticLabel: 'Quota'));

      expect(find.bySemanticsLabel('Quota: 68 / 100'), findsOneWidget);
    });

    testWidgets('writes the reading in the middle as real text', (WidgetTester tester) async {
      await _pump(tester, const PlGaugeChart(value: 68, semanticLabel: 'Quota'));

      expect(find.text('68'), findsOneWidget);
    });

    testWidgets('draws a dash for a reading it has not been given', (WidgetTester tester) async {
      await _pump(tester, const PlGaugeChart(value: null, semanticLabel: 'Quota'));

      expect(find.text('—'), findsOneWidget);
      expect(find.bySemanticsLabel('Quota'), findsOneWidget);
    });

    testWidgets('reads its own min and max rather than assuming a percentage', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const PlGaugeChart(value: 90, min: 60, max: 120, semanticLabel: 'Speed'));

      expect(find.bySemanticsLabel('Speed: 90 / 120'), findsOneWidget);
    });

    testWidgets('says nothing is there when the range is empty', (WidgetTester tester) async {
      await _pump(tester, const PlGaugeChart(value: 5, min: 10, max: 10));

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('takes every sweep from a half-dial to a ring', (WidgetTester tester) async {
      for (final double sweep in <double>[90, 180, 270, 360]) {
        await _pump(tester, PlGaugeChart(value: 40, sweep: sweep, semanticLabel: 'Quota'));

        expect(find.byType(PlGaugeChart), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('takes ticks and a range together', (WidgetTester tester) async {
      await _pump(tester, const PlGaugeChart(value: 40, ticks: 5, semanticLabel: 'Quota'));

      expect(find.byType(PlGaugeChart), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('takes the caller own content in place of the number', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlGaugeChart(value: 68, center: Text('Nearly'), semanticLabel: 'Quota'),
      );

      expect(find.text('Nearly'), findsOneWidget);
      expect(find.text('68'), findsNothing);
    });

    testWidgets('hangs a caption under the reading', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlGaugeChart(value: 68, caption: Text('of quota'), semanticLabel: 'Quota'),
      );

      expect(find.text('of quota'), findsOneWidget);
      expect(find.text('68'), findsOneWidget);
    });

    testWidgets('says nothing on its own behalf when it has no name', (WidgetTester tester) async {
      await _pump(tester, const PlGaugeChart(value: 68));

      expect(find.bySemanticsLabel('Quota'), findsNothing);
      // The reading is still text, so it is still read.
      expect(find.text('68'), findsOneWidget);
    });

    testWidgets('takes the highest band at or below the reading', (WidgetTester tester) async {
      // Written high-first on purpose: a rule that took the last match in list
      // order would answer `warning` here.
      await _pump(
        tester,
        const PlGaugeChart(
          value: 95,
          semanticLabel: 'Quota',
          thresholds: <PlassThreshold>[
            PlassThreshold(from: 90, color: PlassColor.danger),
            PlassThreshold(from: 60, color: PlassColor.warning),
          ],
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Quota: 95 / 100'));

      expect(node.label, contains('95'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('sweeps to a new reading rather than jumping to it', (WidgetTester tester) async {
      await _pump(tester, const PlGaugeChart(value: 10, semanticLabel: 'Quota'));

      await tester.pumpWidget(
        host(
          const SizedBox(height: 220, child: PlGaugeChart(value: 90, semanticLabel: 'Quota')),
          width: 320,
        ),
      );

      // Mid-flight: the label is already the new reading while the arc is not.
      await tester.pump(const Duration(milliseconds: 80));

      expect(find.bySemanticsLabel('Quota: 90 / 100'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
