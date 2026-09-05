import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

List<PlassChartDatum> _row(List<double?> values) => <PlassChartDatum>[
  for (final double? value in values)
    if (value == null) const PlassChartDatum.gap() else PlassChartDatum(value),
];

final List<PlassChartSeries> week = <PlassChartSeries>[
  PlassChartSeries(name: 'Mon', data: _row(<double?>[2, 9, 6, 1])),
  PlassChartSeries(name: 'Tue', data: _row(<double?>[3, 11, 8, 2])),
  PlassChartSeries(name: 'Wed', data: _row(<double?>[1, 7, 12, 4])),
];

const List<PlassChartCategory> hours = <PlassChartCategory>[
  PlassChartCategory.text('09'),
  PlassChartCategory.text('12'),
  PlassChartCategory.text('15'),
  PlassChartCategory.text('18'),
];

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(500, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: 500));
  await tester.pumpAndSettle();
}

void main() {
  group('PlHeatmapChart', () {
    testWidgets('draws a plot and names itself', (WidgetTester tester) async {
      await _pump(tester, PlHeatmapChart(series: week, categories: hours));

      expect(find.bySemanticsLabel('Chart'), findsOneWidget);
    });

    testWidgets('reads out every cell with both of its coordinates', (WidgetTester tester) async {
      await _pump(tester, PlHeatmapChart(series: week, categories: hours));

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, contains('Mon: 09 2, 12 9, 15 6, 18 1'));
      expect(node.value, contains('Wed: 09 1'));
    });

    testWidgets('leaves a gap out of the reading', (WidgetTester tester) async {
      await _pump(
        tester,
        PlHeatmapChart(
          series: <PlassChartSeries>[
            PlassChartSeries(name: 'Mon', data: _row(<double?>[2, null, 6])),
          ],
          categories: hours,
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, 'Mon: 09 2, 15 6');
    });

    testWidgets('says nothing is there when every cell is a gap', (WidgetTester tester) async {
      await _pump(
        tester,
        PlHeatmapChart(
          series: <PlassChartSeries>[
            PlassChartSeries(name: 'Mon', data: _row(<double?>[null, null])),
          ],
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('names the two ends of the scale in the legend', (WidgetTester tester) async {
      await _pump(
        tester,
        PlHeatmapChart(
          series: <PlassChartSeries>[
            PlassChartSeries(name: 'Mon', data: _row(<double?>[4, 40])),
          ],
        ),
      );

      expect(find.text('4'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
    });

    testWidgets('names the middle too when the scale diverges', (WidgetTester tester) async {
      await _pump(
        tester,
        PlHeatmapChart(
          scale: PlChartScaleKind.diverging,
          midpoint: 50,
          series: <PlassChartSeries>[
            PlassChartSeries(name: 'Delta', data: _row(<double?>[20, 80])),
          ],
        ),
      );

      // Both arms reach as far as the further one, so the ends are symmetric
      // about the middle rather than the data's own two values.
      expect(find.text('50'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
    });

    testWidgets('takes both shapes it names', (WidgetTester tester) async {
      for (final PlHeatmapShape shape in PlHeatmapShape.values) {
        await _pump(tester, PlHeatmapChart(series: week, categories: hours, shape: shape));

        expect(find.byType(PlHeatmapChart), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('takes every value-label setting it names', (WidgetTester tester) async {
      for (final PlHeatmapLabels which in PlHeatmapLabels.values) {
        await _pump(tester, PlHeatmapChart(series: week, categories: hours, valueLabels: which));

        expect(find.byType(PlHeatmapChart), findsOneWidget);
      }
    });

    testWidgets('shows a readout for the cell under the press', (WidgetTester tester) async {
      await _pump(tester, PlHeatmapChart(series: week, categories: hours, height: 240));

      final Rect plot = tester.getRect(find.byType(CustomPaint).first);

      // The first row's second cell: a quarter along the columns, a sixth down.
      await tester.tapAt(Offset(plot.left + plot.width * 0.45, plot.top + plot.height * 0.17));
      await tester.pumpAndSettle();

      expect(find.textContaining(' · '), findsOneWidget);
    });

    testWidgets('takes a second press on the same cell as a dismissal', (
      WidgetTester tester,
    ) async {
      await _pump(tester, PlHeatmapChart(series: week, categories: hours, height: 240));

      final Rect plot = tester.getRect(find.byType(CustomPaint).first);
      final Offset inside = Offset(plot.left + plot.width * 0.45, plot.top + plot.height * 0.17);

      await tester.tapAt(inside);
      await tester.pumpAndSettle();
      expect(find.textContaining(' · '), findsOneWidget);

      await tester.tapAt(inside);
      await tester.pumpAndSettle();
      expect(find.textContaining(' · '), findsNothing);
    });
  });
}
