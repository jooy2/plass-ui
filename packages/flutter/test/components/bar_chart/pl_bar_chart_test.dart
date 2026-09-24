import 'dart:math' as math;
import 'dart:ui' show Paragraph;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/chart_frame.dart';

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

    testWidgets('turns its category labels when the axis asks, and writes them whole', (
      WidgetTester tester,
    ) async {
      const List<PlassChartCategory> channels = <PlassChartCategory>[
        PlassChartCategory.text('Organic search'),
        PlassChartCategory.text('Direct traffic'),
        PlassChartCategory.text('Email campaigns'),
        PlassChartCategory.text('Paid social'),
        PlassChartCategory.text('Referral links'),
        PlassChartCategory.text('Affiliate partners'),
      ];

      const PlassChartSeries sessions = PlassChartSeries(
        name: 'Sessions',
        data: <PlassChartDatum>[
          PlassChartDatum(48),
          PlassChartDatum(39),
          PlassChartDatum(27),
          PlassChartDatum(19),
          PlassChartDatum(11),
          PlassChartDatum(8),
        ],
      );

      Future<_TurnCanvas> draw(double angle) async {
        await _pump(
          tester,
          PlBarChart(
            series: const <PlassChartSeries>[sessions],
            categories: channels,
            xAxis: PlChartAxis(tickAngle: angle),
            height: 300,
            legend: const PlChartLegend(hidden: true),
          ),
        );

        final canvas = _TurnCanvas();
        final Finder plot = find.byWidgetPredicate(
          (Widget widget) =>
              widget is CustomPaint && widget.painter != null && widget.size.height > 40,
        );

        tester.widget<CustomPaint>(plot.first).painter!.paint(canvas, tester.getSize(plot.first));

        return canvas;
      }

      final _TurnCanvas upright = await draw(0);
      final _TurnCanvas turned = await draw(-45);

      // Upright, the labels are cut to their slots and thinned by stride;
      // turned, every one of the six is written and each is turned once.
      expect(upright.turns, isEmpty);
      expect(turned.turns.length, 6);
      expect(turned.turns.first, closeTo(-45 * math.pi / 180, 1e-9));
      expect(turned.paragraphs, greaterThan(upright.paragraphs));
    });

    testWidgets('puts the categories in order of size, and folds the tail into one', (
      WidgetTester tester,
    ) async {
      const List<PlassChartCategory> cities = <PlassChartCategory>[
        PlassChartCategory.text('Seoul'),
        PlassChartCategory.text('Tokyo'),
        PlassChartCategory.text('Lisbon'),
        PlassChartCategory.text('Quito'),
      ];
      const List<PlassChartSeries> visits = <PlassChartSeries>[
        PlassChartSeries(
          name: 'Visits',
          data: <PlassChartDatum>[
            PlassChartDatum(10),
            PlassChartDatum(50),
            PlassChartDatum(30),
            PlassChartDatum(5),
          ],
        ),
      ];

      await _pump(
        tester,
        const PlBarChart(series: visits, categories: cities, sort: PlassChartSort.descending),
      );

      // The reading a screen reader is handed is the only path to the numbers,
      // so it is also where the new order has to show up.
      expect(
        tester.getSemantics(find.bySemanticsLabel('Chart')).value,
        'Visits: Tokyo 50; Lisbon 30; Seoul 10; Quito 5',
      );

      await _pump(tester, const PlBarChart(series: visits, categories: cities, maxCategories: 2));

      // Decided by size and never by the order asked for, and what is left is
      // last: it is not a category, it is the rest.
      expect(
        tester.getSemantics(find.bySemanticsLabel('Chart')).value,
        'Visits: Tokyo 50; Lisbon 30; Other 15',
      );
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

    testWidgets('walks the categories down a horizontal chart with the up and down keys', (
      WidgetTester tester,
    ) async {
      final FocusNode before = FocusNode();

      addTearDown(before.dispose);
      await _pump(
        tester,
        afterFocusStop(
          before,
          PlBarChart(series: series, categories: regions, orientation: PlassOrientation.horizontal),
        ),
      );

      before.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      String said() => find.semantics.byFlag(SemanticsFlag.isLiveRegion).evaluate().single.label;

      // The categories run down the side, so the keys that walk them do too.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(said(), 'Europe, This year: 42, Last year: 35');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(said(), 'Asia, This year: 58, Last year: 44');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(said(), 'Europe, This year: 42, Last year: 35');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(said(), 'Europe, This year: 42, Last year: 35');
      expect(find.byType(PlassChartTooltipCard), findsOneWidget);
    });

    testWidgets('writes a bar of a series with no name on its card by its colour and value', (
      WidgetTester tester,
    ) async {
      const Color own = Color(0xFF123456);
      final FocusNode before = FocusNode();

      addTearDown(before.dispose);
      await _pump(
        tester,
        afterFocusStop(
          before,
          const PlBarChart(
            series: <PlassChartSeries>[
              PlassChartSeries(
                data: <PlassChartDatum>[
                  PlassChartDatum(42),
                  PlassChartDatum.point(PlassChartPoint(y: 58, color: own)),
                ],
              ),
            ],
            categories: <PlassChartCategory>[
              PlassChartCategory.text('Europe'),
              PlassChartCategory.text('Asia'),
            ],
          ),
        ),
      );

      before.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      // As the React card is: nothing beside the swatch, which says which
      // series it is, in the colour the bar is painted in.
      final Finder card = find.byType(PlassChartTooltipCard);

      expect(
        tester
            .widgetList<Text>(find.descendant(of: card, matching: find.byType(Text)))
            .map((Text text) => text.data!)
            .toList(),
        <String>['Asia', '58'],
      );
      expect(
        (tester
                    .widgetList<Container>(
                      find.descendant(of: card, matching: find.byType(Container)),
                    )
                    .singleWhere((Container box) => box.constraints?.maxWidth == 8)
                    .decoration!
                as BoxDecoration)
            .color,
        own,
      );
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

/// The same, plus every turn the painter made — which is what a turned label is
/// on a canvas, where there is no `transform` attribute to read back.
class _TurnCanvas extends _TextCanvas {
  final List<double> turns = <double>[];

  @override
  void rotate(double radians) {
    turns.add(radians);
  }
}
