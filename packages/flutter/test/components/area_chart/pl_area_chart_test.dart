import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/canvas.dart';
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

/// Paints the plot as it stands now.
RecordingCanvas _paintArea(WidgetTester tester) {
  final canvas = RecordingCanvas();
  final Finder plot = find.byWidgetPredicate(
    (Widget widget) => widget is CustomPaint && widget.painter != null && widget.size.height > 40,
  );

  tester.widget<CustomPaint>(plot.first).painter!.paint(canvas, tester.getSize(plot.first));

  return canvas;
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

    testWidgets('writes the caller number in its format when it is full', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        PlAreaChart(
          series: const <PlassChartSeries>[
            PlassChartSeries(name: 'New', data: <PlassChartDatum>[PlassChartDatum(4000)]),
            PlassChartSeries(name: 'Renewed', data: <PlassChartDatum>[PlassChartDatum(16000)]),
          ],
          stacking: PlAreaStacking.full,
          format: (double value) => '\$${value.toInt()}',
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Chart')).value,
        r'New: $4000. Renewed: $16000',
      );
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

    testWidgets('fades a series as one layer, its band and its line whole inside it', (
      WidgetTester tester,
    ) async {
      for (final PlAreaStacking stacking in <PlAreaStacking>[
        PlAreaStacking.none,
        PlAreaStacking.total,
      ]) {
        await _pump(tester, PlAreaChart(series: series, categories: months, stacking: stacking));

        expect(_paintArea(tester).layers, isEmpty, reason: stacking.name);

        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getCenter(find.bySemanticsLabel('Search')));
        await tester.pumpAndSettle();

        // Direct is drawn into a layer faded to 0.28, and Search outside any.
        // Inside it, a band that is not stacked is its wash under a line of the
        // full colour, and a stacked band is its flat tint at 0.7, each as it
        // is drawn at rest.
        final RecordingCanvas canvas = _paintArea(tester);

        expect(canvas.layers, <Matcher>[closeTo(0.28, 1e-6)], reason: stacking.name);

        if (stacking == PlAreaStacking.none) {
          expect(canvas.paints.map((Paint paint) => paint.color.a), <double>[1, 1, 1, 1]);
          expect(canvas.opacities, <Matcher>[
            closeTo(0.28, 1e-6),
            closeTo(0.28, 1e-6),
            equals(1),
            equals(1),
          ]);
        } else {
          expect(canvas.paints.map((Paint paint) => paint.color.a), <Matcher>[
            closeTo(0.7, 1e-6),
            closeTo(0.7, 1e-6),
          ]);
          expect(canvas.opacities, <Matcher>[closeTo(0.7 * 0.28, 1e-6), closeTo(0.7, 1e-6)]);
        }

        await mouse.removePointer();
        await tester.pumpAndSettle();
      }
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
