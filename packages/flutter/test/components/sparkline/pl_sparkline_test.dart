import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

const List<PlassChartDatum> trend = <PlassChartDatum>[
  PlassChartDatum(12),
  PlassChartDatum(19),
  PlassChartDatum(15),
  PlassChartDatum(22),
  PlassChartDatum(18),
  PlassChartDatum(26),
];

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(host(child, width: 300));
  await tester.pumpAndSettle();
}

void main() {
  group('PlSparkline', () {
    testWidgets('draws a strip sized against the text beside it', (WidgetTester tester) async {
      await _pump(tester, const PlSparkline(data: trend, semanticLabel: 'Signups'));

      final Size size = tester.getSize(find.byType(PlSparkline));

      // Short enough to sit in a line of text rather than to be a picture.
      expect(size.height, lessThan(48));
    });

    testWidgets('reads out the numbers rather than describing the shape', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const PlSparkline(
          data: <PlassChartDatum>[PlassChartDatum(1), PlassChartDatum.gap(), PlassChartDatum(3)],
          semanticLabel: 'Signups',
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Signups'));

      expect(node.value, '1, —, 3');
    });

    testWidgets('says nothing at all when it carries no name', (WidgetTester tester) async {
      await _pump(tester, const PlSparkline(data: trend));

      expect(find.bySemanticsLabel('Signups'), findsNothing);
      expect(find.byType(ExcludeSemantics), findsOneWidget);
    });

    testWidgets('takes every shape it names', (WidgetTester tester) async {
      for (final PlSparklineShape shape in PlSparklineShape.values) {
        await _pump(tester, PlSparkline(data: trend, shape: shape));

        expect(find.byType(PlSparkline), findsOneWidget);
      }
    });

    testWidgets('takes every curve it names', (WidgetTester tester) async {
      for (final PlChartCurve curve in PlChartCurve.values) {
        await _pump(tester, PlSparkline(data: trend, curve: curve));

        expect(find.byType(PlSparkline), findsOneWidget);
      }
    });

    testWidgets('takes a width rather than filling its parent', (WidgetTester tester) async {
      // Under an `Align`, because the host hands its child a tight width and a
      // widget cannot be narrower than a tight constraint.
      await _pump(tester, const Align(child: PlSparkline(data: trend, width: 120)));

      expect(tester.getSize(find.byType(PlSparkline)).width, 120);
    });

    testWidgets('climbs the size ladder', (WidgetTester tester) async {
      double? shorter;

      for (final PlassSize size in <PlassSize>[PlassSize.xs, PlassSize.xl]) {
        await _pump(tester, PlSparkline(data: trend, size: size));

        final double height = tester.getSize(find.byType(PlSparkline)).height;

        if (shorter == null) {
          shorter = height;
        } else {
          expect(height, greaterThan(shorter));
        }
      }
    });

    testWidgets('draws nothing rather than throwing on an empty series', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const PlSparkline(data: <PlassChartDatum>[]));

      expect(find.byType(PlSparkline), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('takes a baseline, a floor and a ceiling together', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlSparkline(data: trend, baseline: 20, min: 0, max: 40, endDot: true),
      );

      expect(find.byType(PlSparkline), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('takes a family or an exact colour', (WidgetTester tester) async {
      await _pump(tester, const PlSparkline(data: trend, color: PlassColor.danger));
      expect(find.byType(PlSparkline), findsOneWidget);

      await _pump(tester, const PlSparkline(data: trend, tint: Color(0xFF00FF00)));
      expect(find.byType(PlSparkline), findsOneWidget);
    });
  });
}
