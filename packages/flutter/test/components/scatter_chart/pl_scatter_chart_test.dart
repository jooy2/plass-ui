import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

PlassChartDatum _at(double x, double y, {double? z}) =>
    PlassChartDatum.point(PlassChartPoint(x: PlassChartCategory.number(x), y: y, z: z));

final List<PlassChartSeries> spend = <PlassChartSeries>[
  PlassChartSeries(name: 'Q1', data: <PlassChartDatum>[_at(10, 22), _at(20, 31), _at(30, 28)]),
  PlassChartSeries(name: 'Q2', data: <PlassChartDatum>[_at(12, 40), _at(26, 35)]),
];

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(500, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: 500));
  await tester.pumpAndSettle();
}

void main() {
  group('PlScatterChart', () {
    testWidgets('draws a plot and names itself', (WidgetTester tester) async {
      await _pump(tester, PlScatterChart(series: spend));

      expect(find.bySemanticsLabel('Chart'), findsOneWidget);
    });

    testWidgets('reads out every point rather than where a series ended', (
      WidgetTester tester,
    ) async {
      await _pump(tester, PlScatterChart(series: spend));

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, contains('Q1: 10, 22; 20, 31; 30, 28'));
      expect(node.value, contains('Q2: 12, 40; 26, 35'));
    });

    testWidgets('leaves a point with no value out of the reading', (WidgetTester tester) async {
      await _pump(
        tester,
        PlScatterChart(
          series: <PlassChartSeries>[
            PlassChartSeries(
              name: 'Q1',
              data: <PlassChartDatum>[_at(1, 2), const PlassChartDatum.gap(), _at(3, 4)],
            ),
          ],
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, 'Q1: 1, 2; 3, 4');
    });

    testWidgets('reads a point x off the categories when it carries none', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const PlScatterChart(
          series: <PlassChartSeries>[
            PlassChartSeries(
              name: 'Q1',
              data: <PlassChartDatum>[PlassChartDatum(22), PlassChartDatum(31)],
            ),
          ],
          categories: <PlassChartCategory>[
            PlassChartCategory.number(10),
            PlassChartCategory.number(20),
          ],
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      // A band axis would number these 0 and 1. What they sit against is the
      // number the caller gave.
      expect(node.value, 'Q1: 10, 22; 20, 31');
    });

    testWidgets('names every series in the legend', (WidgetTester tester) async {
      await _pump(tester, PlScatterChart(series: spend));

      expect(find.bySemanticsLabel('Q1'), findsOneWidget);
      expect(find.bySemanticsLabel('Q2'), findsOneWidget);
    });

    testWidgets('takes every shape it names', (WidgetTester tester) async {
      for (final PlScatterShape shape in PlScatterShape.values) {
        await _pump(tester, PlScatterChart(series: spend, shape: shape));

        expect(find.byType(PlScatterChart), findsOneWidget);
      }
    });

    testWidgets('takes a bubble size without complaint', (WidgetTester tester) async {
      await _pump(
        tester,
        PlScatterChart(
          series: <PlassChartSeries>[
            PlassChartSeries(
              name: 'Q1',
              data: <PlassChartDatum>[_at(1, 1, z: 100), _at(2, 2, z: 25)],
            ),
          ],
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, contains('1, 1'));
    });

    testWidgets('says nothing is there when every point is a gap', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlScatterChart(
          series: <PlassChartSeries>[
            PlassChartSeries(data: <PlassChartDatum>[PlassChartDatum.gap()]),
          ],
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('shows a readout for the point under the press', (WidgetTester tester) async {
      await _pump(tester, PlScatterChart(series: spend, height: 260));

      // The frame lays the marks out, so where a point lands is not something
      // the test should guess at: press through the middle of the plot and take
      // whichever readout comes up.
      final Rect plot = tester.getRect(find.byType(CustomPaint).first);

      for (double t = 0.1; t <= 0.9; t += 0.1) {
        await tester.tapAt(Offset(plot.left + plot.width * t, plot.top + plot.height * 0.5));
        await tester.pumpAndSettle();

        if (find.textContaining(', ').evaluate().isNotEmpty) {
          // The heading names the series it belongs to, which is what says the
          // readout is about a mark rather than about a column.
          expect(find.text('Q1').hitTestable(), findsWidgets);

          return;
        }
      }

      fail('no point was ever under the press');
    });
  });
}
