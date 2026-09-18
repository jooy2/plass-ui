import 'dart:ui' show Paragraph;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/canvas.dart';
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

    testWidgets('writes the caller number in its format when it is full, in the tooltip too', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        PlBarChart(
          series: const <PlassChartSeries>[
            PlassChartSeries(name: 'New', data: <PlassChartDatum>[PlassChartDatum(4000)]),
            PlassChartSeries(name: 'Renewed', data: <PlassChartDatum>[PlassChartDatum(16000)]),
          ],
          stacking: PlBarStacking.full,
          format: (double value) => '\$${value.toInt()}',
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Chart')).value,
        r'New: $4000. Renewed: $16000',
      );

      await tester.tapAt(tester.getCenter(find.byType(PlBarChart)));
      await tester.pump();

      expect(find.text(r'$4000'), findsOneWidget);
      expect(find.text(r'$16000'), findsOneWidget);
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

    testWidgets('writes the last value that is there when the series ends in a gap', (
      WidgetTester tester,
    ) async {
      /// How many pieces of text the plot paints: its axes, and a label on
      /// every bar that carries one.
      Future<int> texts(PlassChartValueLabels which) async {
        await _pump(
          tester,
          PlBarChart(
            series: const <PlassChartSeries>[
              PlassChartSeries(
                data: <PlassChartDatum>[
                  PlassChartDatum(10),
                  PlassChartDatum(20),
                  PlassChartDatum.gap(),
                ],
              ),
            ],
            categories: regions,
            valueLabels: which,
          ),
        );

        final canvas = _TextCanvas();
        final Finder plot = find.byWidgetPredicate(
          (Widget widget) =>
              widget is CustomPaint && widget.painter != null && widget.size.height > 40,
        );

        tester.widget<CustomPaint>(plot.first).painter!.paint(canvas, tester.getSize(plot.first));

        return canvas.paragraphs;
      }

      // The same axes either way, so the difference is the labels: `all` writes
      // the 10 and the 20, and `last` has to write the 20 rather than nothing.
      expect(await texts(PlassChartValueLabels.all) - await texts(PlassChartValueLabels.last), 1);
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

/// Counts the text a painter lays down, which is all a label on a canvas is.
class _TextCanvas extends RecordingCanvas {
  int paragraphs = 0;

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) {
    paragraphs += 1;
  }
}
