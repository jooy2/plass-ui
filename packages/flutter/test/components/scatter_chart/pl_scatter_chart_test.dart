import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/chart.dart';
import 'package:plass_ui/src/internal/chart_frame.dart';

import '../../support/canvas.dart';
import '../../support/host.dart';

PlassChartDatum _at(double x, double y, {double? z}) =>
    PlassChartDatum.point(PlassChartPoint(x: PlassChartCategory.number(x), y: y, z: z));

final List<PlassChartSeries> spend = <PlassChartSeries>[
  PlassChartSeries(name: 'Q1', data: <PlassChartDatum>[_at(10, 22), _at(20, 31), _at(30, 28)]),
  PlassChartSeries(name: 'Q2', data: <PlassChartDatum>[_at(12, 40), _at(26, 35)]),
];

/// Paints the plot as it stands now.
RecordingCanvas _paintScatter(WidgetTester tester) {
  final canvas = RecordingCanvas();
  final Finder plot = find.byWidgetPredicate(
    (Widget widget) => widget is CustomPaint && widget.painter != null && widget.size.height > 40,
  );

  tester.widget<CustomPaint>(plot.first).painter!.paint(canvas, tester.getSize(plot.first));

  return canvas;
}

/// The alpha of every mark's fill, in the order they were painted.
List<double> _fillAlphas(WidgetTester tester) {
  return <double>[for (final Paint paint in _paintScatter(tester).fills) paint.color.a];
}

/// How wide the fill of the mark furthest to the start is drawn now.
double _firstMarkWidth(WidgetTester tester) {
  final RecordingCanvas canvas = _paintScatter(tester);
  final List<Rect> fills = <Rect>[
    for (int i = 0; i < canvas.paints.length; i += 1)
      if (canvas.paints[i].style == PaintingStyle.fill) canvas.paths[i].getBounds(),
  ]..sort((Rect a, Rect b) => a.center.dx.compareTo(b.center.dx));

  return fills.first.width;
}

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

    testWidgets('ticks an axis of dates like a calendar, or through xAxis.format', (
      WidgetTester tester,
    ) async {
      PlassChartDatum on(int date, double y) => PlassChartDatum.point(
        PlassChartPoint(x: PlassChartCategory.date(DateTime(2026, 3, date)), y: y),
      );
      final List<PlassChartSeries> deploys = <PlassChartSeries>[
        PlassChartSeries(name: 'Web', data: <PlassChartDatum>[on(1, 3), on(9, 5), on(20, 4)]),
      ];
      List<String> ticks() => _xTicks(tester);

      await _pump(tester, PlScatterChart(series: deploys));

      expect(ticks().any((String text) => text.contains('Mar')), isTrue);
      expect(ticks().any((String text) => RegExp(r'\d{6,}').hasMatch(text)), isFalse);

      await _pump(
        tester,
        PlScatterChart(
          series: deploys,
          xAxis: PlChartAxis(
            format: (double value) =>
                'day ${DateTime.fromMillisecondsSinceEpoch(value.round()).day}',
          ),
        ),
      );

      expect(ticks().every((String text) => text.startsWith('day ')), isTrue);
    });

    testWidgets('ticks an axis of numbers compactly, or through xAxis.format, as React does', (
      WidgetTester tester,
    ) async {
      List<PlassChartSeries> across(double from, double to) => <PlassChartSeries>[
        PlassChartSeries(name: 'Q1', data: <PlassChartDatum>[_at(from, 3), _at(to, 5)]),
      ];

      // Thousands grouped and tens of thousands shortened, as the card writes
      // a point's x, and never in the y's `format`.
      await _pump(
        tester,
        PlScatterChart(
          series: across(10000, 50000),
          format: (double value) => '\$${value.toStringAsFixed(2)}',
        ),
      );

      expect(_xTicks(tester), <String>['10K', '20K', '30K', '40K', '50K']);

      await _pump(tester, PlScatterChart(series: across(2000, 6000)));

      expect(_xTicks(tester), contains('2,000'));
      expect(_xTicks(tester), isNot(contains('2000')));

      await _pump(
        tester,
        PlScatterChart(
          series: across(10000, 50000),
          xAxis: PlChartAxis(format: (double value) => '${value.round()} km'),
        ),
      );

      expect(_xTicks(tester), contains('10000 km'));
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

    testWidgets('reads a bubble with its z in brackets after the pair', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        PlScatterChart(
          series: <PlassChartSeries>[
            PlassChartSeries(name: 'Q1', data: <PlassChartDatum>[_at(1, 1, z: 100), _at(2, 2)]),
          ],
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, 'Q1: 1, 1 (100); 2, 2');
    });

    testWidgets('writes every number of a point compactly and grouped without a format', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        PlScatterChart(
          series: <PlassChartSeries>[
            PlassChartSeries(name: 'Q1', data: <PlassChartDatum>[_at(12345, 1234.5, z: 1500000)]),
          ],
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, 'Q1: 12.3K, 1,234.5 (1.5M)');
    });

    testWidgets('stops reading a series switched off in the legend, and reads it again', (
      WidgetTester tester,
    ) async {
      await _pump(tester, PlScatterChart(series: spend));

      String said() => tester.getSemantics(find.bySemanticsLabel('Chart')).value;

      await tester.tap(find.bySemanticsLabel('Q2'));
      await tester.pumpAndSettle();

      expect(said(), 'Q1: 10, 22; 20, 31; 30, 28');

      await tester.tap(find.bySemanticsLabel('Q2'));
      await tester.pumpAndSettle();

      expect(said(), contains('Q2: 12, 40; 26, 35'));
    });

    testWidgets('leaves the drawn marks alone while a hidden entry is pointed at', (
      WidgetTester tester,
    ) async {
      // An entry that is switched off has no marks on the plot to be
      // highlighted, so pointing at it must leave the rest where they are.
      await _pump(
        tester,
        PlScatterChart(
          series: <PlassChartSeries>[
            spend.first,
            PlassChartSeries(name: 'Q2', data: spend.last.data, hidden: true),
          ],
        ),
      );

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.bySemanticsLabel('Q2')));
      await tester.pump();

      final canvas = RecordingCanvas();
      final Finder plot = find.byWidgetPredicate(
        (Widget widget) =>
            widget is CustomPaint && widget.painter != null && widget.size.height > 40,
      );

      tester.widget<CustomPaint>(plot.first).painter!.paint(canvas, tester.getSize(plot.first));

      expect(canvas.fills, isNotEmpty);
      expect(canvas.fills.every((Paint paint) => paint.color.a == 1), isTrue);
    });

    testWidgets('rings each mark as thinly as the React build does', (WidgetTester tester) async {
      await _pump(tester, PlScatterChart(series: spend));

      final canvas = RecordingCanvas();
      final Finder plot = find.byWidgetPredicate(
        (Widget widget) =>
            widget is CustomPaint && widget.painter != null && widget.size.height > 40,
      );

      tester.widget<CustomPaint>(plot.first).painter!.paint(canvas, tester.getSize(plot.first));

      final List<Paint> rings = canvas.paints
          .where((Paint paint) => paint.style == PaintingStyle.stroke)
          .toList();

      // A stroke straddles the path and the fill over it keeps only the outer
      // half, so `markGap` is the 1px of surface the React mark shows and
      // twice it was a ring twice as thick.
      expect(rings, isNotEmpty);
      expect(rings.every((Paint paint) => paint.strokeWidth == markGap), isTrue);
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

        if (find.byType(PlassChartTooltipCard).evaluate().isNotEmpty) {
          // The point's own x over its series and its y, which is what says
          // the readout is about a mark rather than about a column.
          final List<String> lines = _cardLines(tester);

          expect(lines, hasLength(3));
          expect(<String>['Q1', 'Q2'], contains(lines[1]));

          return;
        }
      }

      fail('no point was ever under the press');
    });

    testWidgets('walks the points with the arrow keys in the order they were given', (
      WidgetTester tester,
    ) async {
      final FocusNode before = FocusNode();

      addTearDown(before.dispose);
      await _pump(tester, afterFocusStop(before, PlScatterChart(series: spend)));

      before.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      String said() => find.semantics.byFlag(SemanticsFlag.isLiveRegion).evaluate().single.label;

      expect(said(), isEmpty);

      // Each point is read the way its card is, and the way the React build
      // reads it: its own x, then its series and its y.
      for (final (LogicalKeyboardKey key, String reading) in <(LogicalKeyboardKey, String)>[
        (LogicalKeyboardKey.arrowRight, '10, Q1: 22'),
        (LogicalKeyboardKey.arrowRight, '20, Q1: 31'),
        (LogicalKeyboardKey.arrowRight, '30, Q1: 28'),
        (LogicalKeyboardKey.arrowRight, '12, Q2: 40'),
        (LogicalKeyboardKey.end, '26, Q2: 35'),
        (LogicalKeyboardKey.arrowLeft, '12, Q2: 40'),
        (LogicalKeyboardKey.home, '10, Q1: 22'),
      ]) {
        await tester.sendKeyEvent(key);
        await tester.pump();

        expect(said(), reading, reason: '$key');
      }

      expect(find.text('Q1'), findsWidgets);
    });

    testWidgets('grows the mark a key reaches over the house duration', (
      WidgetTester tester,
    ) async {
      final FocusNode before = FocusNode();

      addTearDown(before.dispose);
      await _pump(tester, afterFocusStop(before, PlScatterChart(series: spend)));

      before.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // The first point is the one furthest to the start, at an x of 10.
      final double rest = _firstMarkWidth(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      // The clock starts on the frame after the change, as an animation's does.
      await tester.pump();
      await tester.pump(PlassTokens.duration ~/ 2);

      final double halfway = _firstMarkWidth(tester);

      await tester.pumpAndSettle();

      final double grown = _firstMarkWidth(tester);

      expect(grown, greaterThan(rest));
      expect(halfway, closeTo(rest + (grown - rest) * PlassTokens.ease.transform(0.5), 1e-3));
      expect(halfway, lessThan(grown));
    });

    testWidgets('fades the other series as a legend entry is pointed at, over the house duration', (
      WidgetTester tester,
    ) async {
      await _pump(tester, PlScatterChart(series: spend));

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.bySemanticsLabel('Q2')));
      await tester.pump();
      await tester.pump();
      await tester.pump(PlassTokens.duration ~/ 2);

      final List<double> halfway = _fillAlphas(tester);
      final double along = PlassTokens.ease.transform(0.5);

      // Q1's three marks on their way down, and Q2's two where they were.
      expect(halfway.where((double alpha) => alpha < 1), <Matcher>[
        for (int i = 0; i < 3; i += 1) closeTo(1 - 0.72 * along, 1e-6),
      ]);
      expect(halfway.where((double alpha) => alpha == 1), hasLength(2));

      await tester.pumpAndSettle();

      expect(
        _fillAlphas(tester).where((double alpha) => alpha < 1),
        everyElement(closeTo(0.28, 1e-6)),
      );
    });

    testWidgets('reads a point\'s own label in place of its y', (WidgetTester tester) async {
      await _pump(
        tester,
        PlScatterChart(
          series: <PlassChartSeries>[
            PlassChartSeries(
              name: 'Q1',
              data: <PlassChartDatum>[
                const PlassChartDatum.point(
                  PlassChartPoint(x: PlassChartCategory.number(1), y: 2, label: 'Two'),
                ),
                _at(3, 4),
              ],
            ),
          ],
        ),
      );

      // As the card and the React table write it.
      expect(tester.getSemantics(find.bySemanticsLabel('Chart')).value, 'Q1: 1, Two; 3, 4');
    });

    testWidgets('names nothing beside the swatch of a series with no name, in the point colour', (
      WidgetTester tester,
    ) async {
      const Color own = Color(0xFF123456);
      final FocusNode before = FocusNode();

      addTearDown(before.dispose);
      await _pump(
        tester,
        afterFocusStop(
          before,
          const PlScatterChart(
            series: <PlassChartSeries>[
              PlassChartSeries(
                data: <PlassChartDatum>[
                  PlassChartDatum.point(
                    PlassChartPoint(x: PlassChartCategory.number(10), y: 22, color: own),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      before.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      // As the React card is: the swatch says which series it is, and its
      // colour is the one the mark is painted in rather than the series'.
      expect(_cardLines(tester), <String>['10', '22']);
      expect(find.semantics.byFlag(SemanticsFlag.isLiveRegion).evaluate().single.label, '10, 22');
      expect(_cardSwatch(tester), own);
    });

    testWidgets('writes the x as its axis does, and never in the y\'s format', (
      WidgetTester tester,
    ) async {
      final List<PlassChartSeries> one = <PlassChartSeries>[
        PlassChartSeries(name: 'Q1', data: <PlassChartDatum>[_at(12345, 22)]),
      ];

      // Compactly, as the React axis writes its ticks, where `format` is the
      // y's alone.
      expect(
        await _readingOf(
          tester,
          PlScatterChart(series: one, format: (double value) => '\$${value.toStringAsFixed(2)}'),
        ),
        ('Q1: 12.3K, \$22.00', '12.3K', '12.3K, Q1: \$22.00'),
      );

      // Through the x axis' own format when it has one.
      expect(
        await _readingOf(
          tester,
          PlScatterChart(
            series: one,
            xAxis: PlChartAxis(format: (double value) => '${value.round()} km'),
          ),
        ),
        ('Q1: 12345 km, 22', '12345 km', '12345 km, Q1: 22'),
      );

      // And a moment as the date every card writes, rather than as the
      // milliseconds it is placed by.
      expect(
        await _readingOf(
          tester,
          PlScatterChart(
            series: <PlassChartSeries>[
              PlassChartSeries(
                name: 'Q1',
                data: <PlassChartDatum>[
                  PlassChartDatum.point(
                    PlassChartPoint(x: PlassChartCategory.date(DateTime(2026, 3)), y: 22),
                  ),
                ],
              ),
            ],
          ),
        ),
        ('Q1: Mar 1, 22', 'Mar 1', 'Mar 1, Q1: 22'),
      );
    });

    testWidgets('heads the card with a point\'s x over its series, y and z, as React does', (
      WidgetTester tester,
    ) async {
      final FocusNode before = FocusNode();

      addTearDown(before.dispose);
      await _pump(
        tester,
        afterFocusStop(
          before,
          PlScatterChart(
            series: <PlassChartSeries>[
              PlassChartSeries(
                name: 'Q1',
                data: <PlassChartDatum>[
                  _at(12345, 1234.5, z: 1500000),
                  const PlassChartDatum.point(
                    PlassChartPoint(x: PlassChartCategory.number(2), y: 2, z: 5, label: 'Two'),
                  ),
                  _at(3, 3),
                ],
              ),
            ],
          ),
        ),
      );

      before.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // The x as the axis writes it, the y through the chart's number writer
      // and a bubble's z after it in brackets, as on the React card. A point's
      // own label stands in for its y alone, so the z still follows it.
      for (final (List<String> lines, String reading) in <(List<String>, String)>[
        (<String>['12.3K', 'Q1', '1,234.5 (1.5M)'], '12.3K, Q1: 1,234.5 (1.5M)'),
        (<String>['2', 'Q1', 'Two (5)'], '2, Q1: Two (5)'),
        (<String>['3', 'Q1', '3'], '3, Q1: 3'),
      ]) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        expect(_cardLines(tester), lines);
        expect(find.semantics.byFlag(SemanticsFlag.isLiveRegion).evaluate().single.label, reading);
      }
    });
  });
}

/// What a chart of one point says about it: the text handed over for the
/// drawing, the card's heading and what the live region reads, once the arrow
/// keys have reached it.
Future<(String, String, String)> _readingOf(WidgetTester tester, PlScatterChart chart) async {
  final FocusNode before = FocusNode();

  addTearDown(before.dispose);
  await _pump(tester, afterFocusStop(before, chart));

  before.requestFocus();
  await tester.pump();
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
  await tester.pump();

  return (
    tester.getSemantics(find.bySemanticsLabel('Chart')).value,
    _cardLines(tester).first,
    find.semantics.byFlag(SemanticsFlag.isLiveRegion).evaluate().single.label,
  );
}

/// What the x axis writes under the plot, read off the painter of the axes.
List<String> _xTicks(WidgetTester tester) =>
    ((tester
                    .widgetList<CustomPaint>(find.byType(CustomPaint))
                    .firstWhere((CustomPaint paint) => paint.size.height > 40)
                    .painter!
                as dynamic)
            .categoryTexts
        as List<String>);

/// The colour of the swatch on the tooltip card, the one small square on it.
Color? _cardSwatch(WidgetTester tester) =>
    (tester
                .widgetList<Container>(
                  find.descendant(
                    of: find.byType(PlassChartTooltipCard),
                    matching: find.byType(Container),
                  ),
                )
                .singleWhere((Container box) => box.constraints?.maxWidth == 8)
                .decoration!
            as BoxDecoration)
        .color;

/// Every line of text on the tooltip card, top to bottom.
List<String> _cardLines(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(of: find.byType(PlassChartTooltipCard), matching: find.byType(Text)),
    )
    .map((Text text) => text.data!)
    .toList();
