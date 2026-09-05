import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

final List<PlassChartSeries> series = <PlassChartSeries>[
  const PlassChartSeries(
    name: 'This year',
    data: <PlassChartDatum>[PlassChartDatum(42), PlassChartDatum(58), PlassChartDatum(31)],
  ),
  const PlassChartSeries(
    name: 'Last year',
    data: <PlassChartDatum>[PlassChartDatum(35), PlassChartDatum(44), PlassChartDatum(38)],
  ),
];

const List<PlassChartCategory> regions = <PlassChartCategory>[
  PlassChartCategory.text('Europe'),
  PlassChartCategory.text('Asia'),
  PlassChartCategory.text('Americas'),
];

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(500, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: 500));
  await tester.pumpAndSettle();
}

void main() {
  group('PlBarChart', () {
    testWidgets('draws a plot and names itself', (WidgetTester tester) async {
      await _pump(tester, PlBarChart(series: series, categories: regions));

      expect(find.bySemanticsLabel('Chart'), findsOneWidget);
    });

    testWidgets('names every series in the legend', (WidgetTester tester) async {
      await _pump(tester, PlBarChart(series: series, categories: regions));

      expect(find.text('This year'), findsOneWidget);
      expect(find.text('Last year'), findsOneWidget);
    });

    testWidgets('runs either way round', (WidgetTester tester) async {
      for (final PlassOrientation orientation in PlassOrientation.values) {
        await _pump(
          tester,
          PlBarChart(series: series, categories: regions, orientation: orientation),
        );

        expect(find.byType(PlBarChart), findsOneWidget);
      }
    });

    testWidgets('takes every stacking it names', (WidgetTester tester) async {
      for (final PlBarStacking stacking in PlBarStacking.values) {
        await _pump(tester, PlBarChart(series: series, categories: regions, stacking: stacking));

        expect(find.byType(PlBarChart), findsOneWidget);
      }
    });

    testWidgets('keeps the caller number when it is stacked to full', (WidgetTester tester) async {
      await _pump(
        tester,
        PlBarChart(series: series, categories: regions, stacking: PlBarStacking.full),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, contains('This year'));
    });

    testWidgets('leaves a gap undrawn rather than drawing a zero', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlBarChart(
          series: <PlassChartSeries>[
            PlassChartSeries(
              name: 'This year',
              data: <PlassChartDatum>[
                PlassChartDatum(42),
                PlassChartDatum.gap(),
                PlassChartDatum(31),
              ],
            ),
          ],
          categories: regions,
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, contains('31'));
    });

    testWidgets('says nothing is there when every value is a gap', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlBarChart(
          series: <PlassChartSeries>[
            PlassChartSeries(data: <PlassChartDatum>[PlassChartDatum.gap()]),
          ],
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('takes every value-label setting it names', (WidgetTester tester) async {
      for (final PlassChartValueLabels which in PlassChartValueLabels.values) {
        await _pump(
          tester,
          PlBarChart(
            series: <PlassChartSeries>[series.first],
            categories: regions,
            valueLabels: which,
          ),
        );

        expect(find.byType(PlBarChart), findsOneWidget);
      }
    });

    testWidgets('takes a bar thickness cap', (WidgetTester tester) async {
      await _pump(
        tester,
        PlBarChart(
          series: series,
          categories: regions,
          barSize: 8,
          height: 180,
          // The legend sits under the plot, so it is the one thing between the
          // height asked for and the height measured.
          legend: const PlChartLegend(hidden: true),
        ),
      );

      expect(tester.getSize(find.byType(PlBarChart)).height, closeTo(180, 0.5));
    });
  });
}
