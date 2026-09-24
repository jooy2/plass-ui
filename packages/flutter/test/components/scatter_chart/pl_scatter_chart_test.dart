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
      List<String> ticks() =>
          ((tester
                          .widgetList<CustomPaint>(find.byType(CustomPaint))
                          .firstWhere((CustomPaint paint) => paint.size.height > 40)
                          .painter!
                      as dynamic)
                  .categoryTexts
              as List<String>);

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

    testWidgets('heads the card with the point\'s x over its series and its y, as React does', (
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
              PlassChartSeries(name: 'Q1', data: <PlassChartDatum>[_at(12345, 1234.5, z: 1500000)]),
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

      // The x as a category is written, the y through the chart's number
      // writer, and the size is left to the bubble, as on the React card.
      expect(_cardLines(tester), <String>['12345', 'Q1', '1,234.5']);
      expect(
        find.semantics.byFlag(SemanticsFlag.isLiveRegion).evaluate().single.label,
        '12345, Q1: 1,234.5',
      );
    });
  });
}

/// Every line of text on the tooltip card, top to bottom.
List<String> _cardLines(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(of: find.byType(PlassChartTooltipCard), matching: find.byType(Text)),
    )
    .map((Text text) => text.data!)
    .toList();
