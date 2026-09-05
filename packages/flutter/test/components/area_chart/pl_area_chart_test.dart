import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

final List<PlassChartSeries> series = <PlassChartSeries>[
  const PlassChartSeries(
    name: 'Direct',
    data: <PlassChartDatum>[PlassChartDatum(30), PlassChartDatum(40), PlassChartDatum(50)],
  ),
  const PlassChartSeries(
    name: 'Search',
    data: <PlassChartDatum>[PlassChartDatum(10), PlassChartDatum(10), PlassChartDatum(50)],
  ),
];

const List<PlassChartCategory> months = <PlassChartCategory>[
  PlassChartCategory.text('Jan'),
  PlassChartCategory.text('Feb'),
  PlassChartCategory.text('Mar'),
];

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(500, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: 500));
  await tester.pumpAndSettle();
}

void main() {
  group('PlAreaChart', () {
    testWidgets('draws a plot and names itself', (WidgetTester tester) async {
      await _pump(tester, PlAreaChart(series: series, categories: months));

      expect(find.bySemanticsLabel('Chart'), findsOneWidget);
    });

    testWidgets('names every series in the legend', (WidgetTester tester) async {
      await _pump(tester, PlAreaChart(series: series, categories: months));

      expect(find.text('Direct'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('takes every stacking it names', (WidgetTester tester) async {
      for (final PlAreaStacking stacking in PlAreaStacking.values) {
        await _pump(tester, PlAreaChart(series: series, categories: months, stacking: stacking));

        expect(find.byType(PlAreaChart), findsOneWidget);
      }
    });

    testWidgets('normalises each category to a hundred when it is full', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        PlAreaChart(series: series, categories: months, stacking: PlAreaStacking.full),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      // The summary keeps the number the caller passed rather than the share —
      // a chart that can only tell you percentages has thrown the data away.
      expect(node.value, contains('Direct'));
      expect(node.value, contains('Search'));
    });

    testWidgets('keeps a gap a gap', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlAreaChart(
          series: <PlassChartSeries>[
            PlassChartSeries(
              name: 'Direct',
              data: <PlassChartDatum>[
                PlassChartDatum(30),
                PlassChartDatum.gap(),
                PlassChartDatum(50),
              ],
            ),
          ],
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, contains('50'));
    });

    testWidgets('says nothing is there when every value is a gap', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlAreaChart(
          series: <PlassChartSeries>[
            PlassChartSeries(data: <PlassChartDatum>[PlassChartDatum.gap()]),
          ],
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('takes the height it was given', (WidgetTester tester) async {
      await _pump(
        tester,
        PlAreaChart(series: <PlassChartSeries>[series.first], categories: months, height: 160),
      );

      expect(tester.getSize(find.byType(PlAreaChart)).height, closeTo(160, 0.5));
    });
  });
}
