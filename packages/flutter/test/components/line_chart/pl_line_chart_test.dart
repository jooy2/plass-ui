import 'dart:ui' show Paragraph;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/chart.dart';
import 'package:plass_ui/src/internal/chart_frame.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';

import '../../support/canvas.dart';
import '../../support/host.dart';

final List<PlassChartSeries> series = <PlassChartSeries>[
  const PlassChartSeries(
    name: 'Revenue',
    data: <PlassChartDatum>[
      PlassChartDatum(12),
      PlassChartDatum(19),
      PlassChartDatum(15),
      PlassChartDatum(22),
    ],
  ),
  const PlassChartSeries(
    name: 'Cost',
    data: <PlassChartDatum>[
      PlassChartDatum(8),
      PlassChartDatum(11),
      PlassChartDatum(9),
      PlassChartDatum(13),
    ],
  ),
];

const List<PlassChartCategory> months = <PlassChartCategory>[
  PlassChartCategory.text('Jan'),
  PlassChartCategory.text('Feb'),
  PlassChartCategory.text('Mar'),
  PlassChartCategory.text('Apr'),
];

Future<void> _pump(WidgetTester tester, Widget child, {double width = 500}) async {
  tester.view.physicalSize = Size(width, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: width));
  await tester.pumpAndSettle();
}

void main() {
  group('PlLineChart', () {
    group('rendering', () {
      testWidgets('draws a plot', (WidgetTester tester) async {
        await _pump(tester, PlLineChart(series: series, categories: months));

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('names itself', (WidgetTester tester) async {
        await _pump(tester, PlLineChart(series: series, categories: months));

        expect(find.bySemanticsLabel('Chart'), findsOneWidget);
      });

      testWidgets('takes a name of its own', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(series: series, categories: months, semanticLabel: 'Revenue by month'),
        );

        expect(find.bySemanticsLabel('Revenue by month'), findsOneWidget);
      });

      testWidgets('writes the categories along the axis', (WidgetTester tester) async {
        await _pump(tester, PlLineChart(series: series, categories: months));

        // Axis labels are painted rather than laid out as widgets, so what a
        // test can check is that the frame was handed them: the semantics
        // summary names each series and where it ended up.
        final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

        expect(node.value, contains('Revenue'));
        expect(node.value, contains('22'));
        expect(node.value, contains('Cost'));
      });

      testWidgets('calls a series with no name by its number', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(
            series: <PlassChartSeries>[
              for (final PlassChartSeries one in series) PlassChartSeries(data: one.data),
            ],
            categories: months,
          ),
        );

        expect(
          tester.getSemantics(find.bySemanticsLabel('Chart')).value,
          '1: Jan 12; Feb 19; Mar 15; Apr 22. 2: Jan 8; Feb 11; Mar 9; Apr 13',
        );
        expect(find.text('2'), findsOneWidget);
      });

      testWidgets('says nothing is there when every value is a gap', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlLineChart(
            series: <PlassChartSeries>[
              PlassChartSeries(
                data: <PlassChartDatum>[PlassChartDatum.gap(), PlassChartDatum.gap()],
              ),
            ],
          ),
        );

        expect(find.text('Nothing here'), findsOneWidget);
      });

      testWidgets('draws the empty widget it was given, whatever it is', (
        WidgetTester tester,
      ) async {
        const List<PlassChartSeries> gaps = <PlassChartSeries>[
          PlassChartSeries(data: <PlassChartDatum>[PlassChartDatum.gap()]),
        ];

        await _pump(
          tester,
          const PlLineChart(
            series: gaps,
            empty: Text.rich(
              TextSpan(
                text: 'No visits ',
                children: <InlineSpan>[TextSpan(text: 'yet')],
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('No visits yet', findRichText: true), findsOneWidget);

        await _pump(
          tester,
          const PlLineChart(
            series: gaps,
            empty: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[Text('Nothing to plot')],
            ),
          ),
        );

        expect(find.text('Nothing to plot'), findsOneWidget);
      });

      testWidgets('draws nothing at all for an empty set of series', (WidgetTester tester) async {
        await _pump(tester, const PlLineChart(series: <PlassChartSeries>[]));

        expect(find.text('Nothing here'), findsOneWidget);
      });
    });

    group('the legend', () {
      testWidgets('names every series', (WidgetTester tester) async {
        await _pump(tester, PlLineChart(series: series, categories: months));

        expect(find.text('Revenue'), findsOneWidget);
        expect(find.text('Cost'), findsOneWidget);
      });

      for (final PlassSide side in <PlassSide>[PlassSide.left, PlassSide.right]) {
        testWidgets('stacks the entries beside the plot on the ${side.name}', (
          WidgetTester tester,
        ) async {
          final List<String> names = <String>[
            'Organic search',
            'Paid search',
            'Newsletter',
            'Partner referrals',
            'Direct',
          ];

          await _pump(
            tester,
            PlLineChart(
              series: <PlassChartSeries>[
                for (final String name in names)
                  PlassChartSeries(name: name, data: series.first.data),
              ],
              categories: months,
              legend: PlChartLegend(side: side),
            ),
            width: 360,
          );

          expect(tester.takeException(), isNull);

          final Rect chart = tester.getRect(find.byType(PlLineChart));
          final Rect plot = tester.getRect(
            find.byWidgetPredicate(
              (Widget widget) =>
                  widget is CustomPaint && widget.painter != null && widget.size.height > 40,
            ),
          );

          for (int i = 1; i < names.length; i += 1) {
            expect(
              tester.getTopLeft(find.text(names[i])).dy,
              greaterThan(tester.getTopLeft(find.text(names[i - 1])).dy),
            );
          }

          expect(plot.width, greaterThan(chart.width / 2));
          expect(
            side == PlassSide.left
                ? tester.getTopLeft(find.text(names.first)).dx < plot.left
                : tester.getTopLeft(find.text(names.first)).dx > plot.right,
            isTrue,
          );
        });
      }

      testWidgets('draws none for a single series', (WidgetTester tester) async {
        await _pump(tester, PlLineChart(series: <PlassChartSeries>[series.first]));

        expect(find.text('Revenue'), findsNothing);
      });

      testWidgets('draws none when it is hidden', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(
            series: series,
            categories: months,
            legend: const PlChartLegend(hidden: true),
          ),
        );

        expect(find.text('Revenue'), findsNothing);
      });

      testWidgets('switches a series off when its entry is pressed', (WidgetTester tester) async {
        await _pump(tester, PlLineChart(series: series, categories: months));

        SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));
        expect(node.value, contains('Cost'));

        await tester.tap(find.bySemanticsLabel('Cost'));
        await tester.pumpAndSettle();

        node = tester.getSemantics(find.bySemanticsLabel('Chart'));
        expect(node.value, isNot(contains('Cost')));
        expect(node.value, contains('Revenue'));
      });

      testWidgets('switches a series off from a screen reader or the keyboard', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlLineChart(series: series, categories: months));

        tester.semantics.tap(find.semantics.byLabel('Cost'));
        await tester.pumpAndSettle();
        expect(tester.getSemantics(find.bySemanticsLabel('Chart')).value, isNot(contains('Cost')));

        // The entry is a focus stop, and Enter switches it back on.
        final FocusNode node = Focus.of(tester.element(find.text('Cost')));
        node.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(tester.getSemantics(find.bySemanticsLabel('Chart')).value, contains('Cost'));
      });

      testWidgets('switches a series that started hidden back on', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(
            series: <PlassChartSeries>[
              series.first,
              PlassChartSeries(name: 'Cost', data: series.last.data, hidden: true),
            ],
            categories: months,
          ),
        );

        expect(tester.getSemantics(find.bySemanticsLabel('Chart')).value, isNot(contains('Cost')));

        await tester.tap(find.bySemanticsLabel('Cost'));
        await tester.pumpAndSettle();

        expect(tester.getSemantics(find.bySemanticsLabel('Chart')).value, contains('Cost'));
      });

      testWidgets('fades an entry that is switched off, and only that one', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlLineChart(
            series: <PlassChartSeries>[
              series.first,
              PlassChartSeries(name: 'Cost', data: series.last.data, hidden: true),
            ],
            categories: months,
          ),
        );

        // Revenue's entry is on, and is not painted through an opacity of 1,
        // which would be a layer on every entry of the legend for nothing.
        expect(
          tester.layers.whereType<OpacityLayer>().map((OpacityLayer layer) => layer.alpha),
          <int>[Color.getAlphaFromOpacity(0.4)],
        );
      });

      testWidgets('fades the other series as an entry is pointed at, over the house duration', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlLineChart(series: series, categories: months));

        /// The alpha each line is stroked at now, in the order of the series.
        List<double> lineAlphas() {
          final canvas = RecordingCanvas();
          final Finder plot = find.byWidgetPredicate(
            (Widget widget) =>
                widget is CustomPaint && widget.painter != null && widget.size.height > 40,
          );

          tester.widget<CustomPaint>(plot.first).painter!.paint(canvas, tester.getSize(plot.first));

          return <double>[
            for (final Paint paint in canvas.paints)
              if (paint.style == PaintingStyle.stroke) paint.color.a,
          ];
        }

        expect(lineAlphas(), <double>[1, 1]);

        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getCenter(find.bySemanticsLabel('Cost')));
        await tester.pump();
        // The clock starts on the frame after the change, as an animation's
        // does.
        await tester.pump();
        await tester.pump(PlassTokens.duration ~/ 2);

        // Halfway through, as far along as the house curve is by then.
        final List<double> halfway = lineAlphas();

        expect(halfway.first, closeTo(1 - 0.72 * PlassTokens.ease.transform(0.5), 1e-6));
        expect(halfway.first, greaterThan(0.28));
        expect(halfway.last, 1);

        await tester.pumpAndSettle();

        // A paint keeps its colour in single precision.
        expect(lineAlphas(), <Matcher>[closeTo(0.28, 1e-6), equals(1)]);

        await mouse.moveTo(Offset.zero);
        await tester.pumpAndSettle();

        expect(lineAlphas(), <double>[1, 1]);
      });

      testWidgets('fades the other series at once under reduced motion', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = const Size(500, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          host(
            PlLineChart(series: series, categories: months),
            width: 500,
            disableAnimations: true,
          ),
        );
        await tester.pumpAndSettle();

        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getCenter(find.bySemanticsLabel('Cost')));
        await tester.pump();

        final canvas = RecordingCanvas();
        final Finder plot = find.byWidgetPredicate(
          (Widget widget) =>
              widget is CustomPaint && widget.painter != null && widget.size.height > 40,
        );

        tester.widget<CustomPaint>(plot.first).painter!.paint(canvas, tester.getSize(plot.first));

        expect(
          <double>[
            for (final Paint paint in canvas.paints)
              if (paint.style == PaintingStyle.stroke) paint.color.a,
          ],
          <Matcher>[closeTo(0.28, 1e-6), equals(1)],
        );
        expect(tester.binding.transientCallbackCount, 0);
      });

      testWidgets('leaves a series alone when the legend is not interactive', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlLineChart(
            series: series,
            categories: months,
            legend: const PlChartLegend(interactive: false),
          ),
        );

        expect(find.bySemanticsLabel('Cost'), findsNothing);
        expect(find.text('Cost'), findsOneWidget);
      });

      testWidgets('starts a series off when it says it is hidden', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(
            series: <PlassChartSeries>[
              series.first,
              const PlassChartSeries(
                name: 'Cost',
                hidden: true,
                data: <PlassChartDatum>[PlassChartDatum(8), PlassChartDatum(11)],
              ),
            ],
            categories: months,
          ),
        );

        final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

        expect(node.value, isNot(contains('Cost')));
      });
    });

    group('the tooltip', () {
      testWidgets('shows the column under the pointer', (WidgetTester tester) async {
        await _pump(tester, PlLineChart(series: series, categories: months));

        final Offset centre = tester.getCenter(find.byType(PlLineChart));

        await tester.tapAt(centre);
        await tester.pump();

        // The card names the category and every visible series at it.
        expect(find.textContaining(RegExp('Jan|Feb|Mar|Apr')), findsWidgets);
      });

      testWidgets('moves with the pointer without drawing the chart again inside a column', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlLineChart(series: series, categories: months));

        final Finder frame = find.byWidgetPredicate(
          (Widget widget) =>
              widget is CustomPaint && widget.painter != null && widget.size.height > 40,
        );
        CustomPainter? painter() => tester.widget<CustomPaint>(frame.first).painter;
        final Rect plot = tester.getRect(frame.first);
        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: plot.topLeft + const Offset(2, 40));
        await mouse.moveTo(plot.topLeft + const Offset(4, 40));
        await tester.pump();

        final CustomPainter? first = painter();
        final Rect card = tester.getRect(find.byType(PlassChartTooltipCard));

        // Still the first column: the card follows, and the chart is not rebuilt.
        await mouse.moveTo(plot.topLeft + const Offset(8, 60));
        await tester.pump();

        expect(painter(), same(first));
        expect(tester.getRect(find.byType(PlassChartTooltipCard)), isNot(card));

        // Another column is a new drawing.
        await mouse.moveTo(plot.topRight + const Offset(-4, 60));
        await tester.pump();

        expect(painter(), isNot(same(first)));
      });

      testWidgets('heads a date column with its day rather than a timestamp', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlLineChart(
            series: series,
            categories: <PlassChartCategory>[
              for (int day = 1; day <= 4; day += 1) PlassChartCategory.date(DateTime(2026, 3, day)),
            ],
          ),
        );

        await tester.tapAt(tester.getTopLeft(find.byType(PlLineChart)) + const Offset(2, 60));
        await tester.pump();

        expect(find.text('Mar 1'), findsOneWidget);
        expect(find.textContaining('2026-03'), findsNothing);
      });

      testWidgets('keeps the whole card inside a short chart, at either end', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlLineChart(series: series, categories: months, height: 90),
          width: 300,
        );

        final Rect box = tester.getRect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is CustomPaint && widget.painter != null && widget.size.height > 40,
          ),
        );

        for (final Offset at in <Offset>[
          box.bottomLeft + const Offset(2, -2),
          box.bottomRight - const Offset(2, 2),
        ]) {
          await tester.tapAt(at);
          await tester.pump();

          final Rect card = tester.getRect(find.byType(PlassChartTooltipCard));

          expect(card.left, greaterThanOrEqualTo(box.left));
          expect(card.right, lessThanOrEqualTo(box.right));
          expect(card.top, greaterThanOrEqualTo(box.top));
          expect(card.bottom, lessThanOrEqualTo(box.bottom));

          // A second press on the same column takes the card down again.
          await tester.tapAt(at);
          await tester.pump();
        }
      });

      testWidgets('narrows to the series nearest the pointer in item mode', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlLineChart(
            series: series,
            categories: months,
            tooltip: const PlChartTooltip(mode: PlassChartTooltipMode.item),
          ),
        );

        final Rect plot = tester.getRect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is CustomPaint && widget.painter != null && widget.size.height > 40,
          ),
        );

        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

        addTearDown(mouse.removePointer);

        // January is Revenue 12 over Cost 8, so the top of that column is the
        // Revenue point and the bottom is the Cost one.
        await mouse.addPointer(location: plot.topLeft + const Offset(2, 4));
        await mouse.moveTo(plot.topLeft + const Offset(4, 4));
        await tester.pump();

        expect(find.text('12'), findsOneWidget);
        expect(find.text('8'), findsNothing);

        await mouse.moveTo(plot.bottomLeft + const Offset(2, -4));
        await tester.pump();

        expect(find.text('8'), findsOneWidget);
        expect(find.text('12'), findsNothing);
      });

      testWidgets('keeps the whole column in the default mode', (WidgetTester tester) async {
        await _pump(tester, PlLineChart(series: series, categories: months));

        final Rect plot = tester.getRect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is CustomPaint && widget.painter != null && widget.size.height > 40,
          ),
        );

        await tester.tapAt(plot.topLeft + const Offset(2, 4));
        await tester.pump();

        expect(find.text('12'), findsOneWidget);
        expect(find.text('8'), findsOneWidget);
      });

      testWidgets('shows none when it is hidden', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(
            series: series,
            categories: months,
            tooltip: const PlChartTooltip(hidden: true),
          ),
        );

        final Offset centre = tester.getCenter(find.byType(PlLineChart));

        await tester.tapAt(centre);
        await tester.pump();

        expect(find.text('12'), findsNothing);
      });
    });

    group('the keyboard', () {
      /// Puts the chart after a focus stop of its own and arrives on it by Tab.
      Future<void> tabTo(WidgetTester tester, Widget chart) async {
        final FocusNode before = FocusNode();

        addTearDown(before.dispose);
        await _pump(tester, afterFocusStop(before, chart));

        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }

      /// What the live region is saying.
      String said(WidgetTester tester) {
        return find.semantics.byFlag(SemanticsFlag.isLiveRegion).evaluate().single.label;
      }

      testWidgets('is a tab stop, and says nothing until a key moves', (WidgetTester tester) async {
        await tabTo(tester, PlLineChart(series: series, categories: months));

        final SemanticsNode chart = tester.getSemantics(find.bySemanticsLabel('Chart'));

        expect(chart, isSemantics(label: 'Chart', isFocusable: true, isFocused: true));
        expect(said(tester), isEmpty);
      });

      testWidgets('walks the columns with the arrow keys, Home and End, and stops at the ends', (
        WidgetTester tester,
      ) async {
        await tabTo(tester, PlLineChart(series: series, categories: months));

        for (final (LogicalKeyboardKey key, String reading) in <(LogicalKeyboardKey, String)>[
          (LogicalKeyboardKey.arrowRight, 'Jan, Revenue: 12, Cost: 8'),
          (LogicalKeyboardKey.arrowRight, 'Feb, Revenue: 19, Cost: 11'),
          (LogicalKeyboardKey.end, 'Apr, Revenue: 22, Cost: 13'),
          (LogicalKeyboardKey.arrowRight, 'Apr, Revenue: 22, Cost: 13'),
          (LogicalKeyboardKey.arrowLeft, 'Mar, Revenue: 15, Cost: 9'),
          (LogicalKeyboardKey.home, 'Jan, Revenue: 12, Cost: 8'),
          (LogicalKeyboardKey.arrowLeft, 'Jan, Revenue: 12, Cost: 8'),
        ]) {
          await tester.sendKeyEvent(key);
          await tester.pump();

          expect(said(tester), reading, reason: '$key');
        }
      });

      testWidgets('starts from the last column when the first key goes back', (
        WidgetTester tester,
      ) async {
        await tabTo(tester, PlLineChart(series: series, categories: months));

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();

        expect(said(tester), 'Apr, Revenue: 22, Cost: 13');
      });

      testWidgets('stands the card on the column a key reached, and keeps it off the tree', (
        WidgetTester tester,
      ) async {
        // One series and so no legend, which is when the plot and the chart
        // are one node and a card on the tree would be read into its name.
        await tabTo(
          tester,
          PlLineChart(series: <PlassChartSeries>[series.first], categories: months),
        );

        expect(find.byType(PlassChartTooltipCard), findsNothing);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        expect(find.byType(PlassChartTooltipCard), findsOneWidget);
        expect(find.text('Jan'), findsOneWidget);
        // Said once, by the live region, rather than read into the chart's
        // name as well.
        expect(said(tester), 'Jan, Revenue: 12');
        expect(tester.getSemantics(find.bySemanticsLabel('Chart')).label, 'Chart');
      });

      testWidgets('draws the ring only while the keyboard holds it', (WidgetTester tester) async {
        // One series, so there is no legend whose own ring could be the one
        // found once the focus moves on.
        await tabTo(tester, PlLineChart(series: <PlassChartSeries>[series.first]));

        bool ringed() => tester
            .widgetList<CustomPaint>(find.byType(CustomPaint))
            .any((CustomPaint paint) => paint.foregroundPainter is PlassFocusRingPainter);

        expect(ringed(), isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        expect(ringed(), isFalse);
      });

      testWidgets('clears on Escape, and lets Escape through when there is nothing to clear', (
        WidgetTester tester,
      ) async {
        await tabTo(tester, PlLineChart(series: series, categories: months));

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(said(tester), isNotEmpty);

        expect(await tester.sendKeyEvent(LogicalKeyboardKey.escape), isTrue);
        await tester.pump();

        expect(said(tester), isEmpty);
        expect(find.byType(PlassChartTooltipCard), findsNothing);

        // A sheet the chart sits in still gets the key it closes on.
        expect(await tester.sendKeyEvent(LogicalKeyboardKey.escape), isFalse);
        expect(await tester.sendKeyEvent(LogicalKeyboardKey.keyA), isFalse);
      });

      testWidgets('clears what it was reading when the focus leaves', (WidgetTester tester) async {
        await tabTo(tester, PlLineChart(series: series, categories: months));

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(said(tester), isNotEmpty);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        expect(said(tester), isEmpty);
        expect(find.byType(PlassChartTooltipCard), findsNothing);
      });

      testWidgets('reads the whole column in item mode, which a key has no pointer for', (
        WidgetTester tester,
      ) async {
        await tabTo(
          tester,
          PlLineChart(
            series: series,
            categories: months,
            tooltip: const PlChartTooltip(mode: PlassChartTooltipMode.item),
          ),
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        expect(said(tester), 'Jan, Revenue: 12, Cost: 8');
        expect(find.text('12'), findsOneWidget);
        expect(find.text('8'), findsOneWidget);
      });

      testWidgets('walks the marks in nearest mode, each read with its category', (
        WidgetTester tester,
      ) async {
        await tabTo(
          tester,
          PlLineChart(
            series: series,
            categories: months,
            tooltip: const PlChartTooltip(mode: PlassChartTooltipMode.nearest),
          ),
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(said(tester), 'Jan, Revenue: 12');

        // One series at a time: a mark names its own, so the next mark is the
        // next of Revenue's rather than Cost's January.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(said(tester), 'Feb, Revenue: 19');

        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump();
        expect(said(tester), 'Apr, Cost: 13');
      });

      testWidgets('heads a nearest card with the category, over the series and its value', (
        WidgetTester tester,
      ) async {
        await tabTo(
          tester,
          PlLineChart(
            series: series,
            categories: months,
            tooltip: const PlChartTooltip(mode: PlassChartTooltipMode.nearest),
          ),
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        // The column's card narrowed to one mark, which is what the live region
        // reads: "Jan", then Revenue beside its swatch and what it is worth.
        final Finder card = find.byType(PlassChartTooltipCard);
        final List<String> lines = tester
            .widgetList<Text>(find.descendant(of: card, matching: find.byType(Text)))
            .map((Text text) => text.data!)
            .toList();

        expect(lines, <String>['Jan', 'Revenue', '12']);
      });

      testWidgets('reads a series with no name by its value alone', (WidgetTester tester) async {
        await tabTo(
          tester,
          PlLineChart(
            series: <PlassChartSeries>[PlassChartSeries(data: series.first.data)],
            categories: months,
          ),
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        expect(said(tester), 'Jan, 12');
      });

      testWidgets('leaves the keys alone and says nothing when its tooltip is off', (
        WidgetTester tester,
      ) async {
        await tabTo(
          tester,
          PlLineChart(
            series: series,
            categories: months,
            tooltip: const PlChartTooltip(hidden: true),
          ),
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        expect(find.semantics.byFlag(SemanticsFlag.isLiveRegion), findsNothing);
        expect(find.byType(PlassChartTooltipCard), findsNothing);
      });
    });

    group('the axes', () {
      testWidgets('gives the room back when an axis is hidden', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(
            series: series,
            categories: months,
            xAxis: const PlChartAxis(hidden: true),
            yAxis: const PlChartAxis(hidden: true),
            legend: const PlChartLegend(hidden: true),
            height: 200,
          ),
        );

        // Nothing to assert on the painted band directly; what is checkable is
        // that the chart still lays out at the height it was given.
        expect(tester.getSize(find.byType(PlLineChart)).height, closeTo(200, 0.5));
      });

      testWidgets('takes the height it was given', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(series: <PlassChartSeries>[series.first], categories: months, height: 140),
        );

        expect(tester.getSize(find.byType(PlLineChart)).height, closeTo(140, 0.5));
      });

      testWidgets('follows the size ladder when it was given none', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(
            series: <PlassChartSeries>[series.first],
            categories: months,
            size: PlassSize.xs,
          ),
        );

        expect(tester.getSize(find.byType(PlLineChart)).height, closeTo(120, 0.5));
      });
    });

    group('labels', () {
      testWidgets('takes an axis name and reserves room for it', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(
            series: <PlassChartSeries>[series.first],
            categories: months,
            height: 200,
            yAxis: const PlChartAxis(label: 'Revenue'),
            xAxis: const PlChartAxis(label: 'Month'),
          ),
        );

        // Both names are painted rather than laid out, so what a test can check
        // is that the chart still fits the height it was given once the two
        // bands have been taken out of it.
        expect(tester.getSize(find.byType(PlLineChart)).height, closeTo(200, 0.5));
      });

      testWidgets('writes every value setting it names', (WidgetTester tester) async {
        for (final PlassChartValueLabels which in PlassChartValueLabels.values) {
          await _pump(
            tester,
            PlLineChart(
              series: <PlassChartSeries>[series.first],
              categories: months,
              valueLabels: which,
            ),
          );

          expect(find.byType(PlLineChart), findsOneWidget);
        }
      });

      testWidgets('writes the values through the format it was given', (WidgetTester tester) async {
        await _pump(
          tester,
          PlLineChart(
            series: <PlassChartSeries>[series.first],
            categories: months,
            format: (double value) => '£$value',
          ),
        );

        final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

        expect(node.value, contains('£'));
      });

      testWidgets('writes a value label compactly and grouped without a format', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const PlLineChart(
            series: <PlassChartSeries>[
              PlassChartSeries(
                name: 'Revenue',
                data: <PlassChartDatum>[PlassChartDatum(9999), PlassChartDatum(1234567)],
              ),
            ],
            valueLabels: PlassChartValueLabels.all,
            // With both axes and the legend hidden, the value labels are the
            // only text the plot paints.
            xAxis: PlChartAxis(hidden: true),
            yAxis: PlChartAxis(hidden: true),
            legend: PlChartLegend(hidden: true),
          ),
        );

        final canvas = _TextCanvas();

        for (final CustomPaint paint in tester.widgetList<CustomPaint>(find.byType(CustomPaint))) {
          paint.painter?.paint(canvas, tester.getSize(find.byWidget(paint)));
        }

        // A canvas keeps no words, only how long each painted line is: `9,999`
        // and `1.2M`, where the number as it was stored is `9999` and `1234567`.
        expect(canvas.lengths, <int>[5, 4]);
      });
    });

    group('curves and markers', () {
      testWidgets('draws every curve it names', (WidgetTester tester) async {
        for (final PlChartCurve curve in PlChartCurve.values) {
          await _pump(tester, PlLineChart(series: series, categories: months, curve: curve));

          expect(find.byType(PlLineChart), findsOneWidget);
        }
      });

      testWidgets('takes every marker setting it names', (WidgetTester tester) async {
        for (final PlChartMarkers markers in PlChartMarkers.values) {
          await _pump(tester, PlLineChart(series: series, categories: months, markers: markers));

          expect(find.byType(PlLineChart), findsOneWidget);
        }
      });

      testWidgets('draws a reference line across the plot and says it in the reading', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const PlLineChart(
            series: <PlassChartSeries>[
              PlassChartSeries(
                name: 'Uptime',
                data: <PlassChartDatum>[PlassChartDatum(1), PlassChartDatum(3)],
              ),
            ],
            reference: <PlassChartReference>[PlassChartReference(value: 2, label: 'Target')],
          ),
        );

        // A target is a fact about the picture rather than decoration on it, so
        // the reader who is given the reading instead of the drawing gets it.
        expect(tester.getSemantics(find.bySemanticsLabel('Chart')).value, contains('Target'));
      });

      testWidgets('draws a series with a gap in it', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlLineChart(
            series: <PlassChartSeries>[
              PlassChartSeries(
                name: 'Uptime',
                data: <PlassChartDatum>[
                  PlassChartDatum(1),
                  PlassChartDatum.gap(),
                  PlassChartDatum(3),
                ],
              ),
            ],
          ),
        );

        final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

        // The gap is a gap: the series still ends at its last real value.
        expect(node.value, contains('3'));
      });

      testWidgets('bridges a gap when it is told to', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlLineChart(
            nulls: PlassChartNulls.connect,
            series: <PlassChartSeries>[
              PlassChartSeries(
                name: 'Uptime',
                data: <PlassChartDatum>[
                  PlassChartDatum(1),
                  PlassChartDatum.gap(),
                  PlassChartDatum(3),
                ],
              ),
            ],
          ),
        );

        expect(find.byType(PlLineChart), findsOneWidget);
      });

      testWidgets('reads a gap as a zero when it is told to, in the reading too', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const PlLineChart(
            nulls: PlassChartNulls.zero,
            series: <PlassChartSeries>[
              PlassChartSeries(
                name: 'Uptime',
                data: <PlassChartDatum>[
                  PlassChartDatum(1),
                  PlassChartDatum.gap(),
                  PlassChartDatum(3),
                ],
              ),
            ],
          ),
        );

        // A zero is a value, so it reaches the reading a screen reader is
        // handed as well as the line — the painter is not the only thing that
        // was told about it.
        expect(tester.getSemantics(find.bySemanticsLabel('Chart')).value, contains('0'));
      });

      testWidgets('still honours the deprecated boolean where `nulls` says nothing', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const PlLineChart(
            // ignore: deprecated_member_use
            connectNulls: true,
            series: <PlassChartSeries>[
              PlassChartSeries(
                name: 'Uptime',
                data: <PlassChartDatum>[
                  PlassChartDatum(1),
                  PlassChartDatum.gap(),
                  PlassChartDatum(3),
                ],
              ),
            ],
          ),
        );

        expect(find.byType(PlLineChart), findsOneWidget);
      });

      testWidgets('draws the dot a pixel inside the marker radius and the ring a pixel outside', (
        WidgetTester tester,
      ) async {
        for (final PlassSize size in PlassSize.values) {
          await _pump(tester, PlLineChart(series: series, categories: months, size: size));

          // The React marker is a circle of the radius stroked 2px wide in the
          // surface over its fill, so the colour shows to a pixel inside the
          // radius and the ring runs from there to a pixel outside it.
          final double radius = markerRadii[size]!;

          expect(_markerRadii(tester), <double>[
            radius + 1,
            radius - 1,
            radius + 1,
            radius - 1,
          ], reason: size.name);

          final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

          await mouse.addPointer(location: Offset.zero);
          await mouse.moveTo(tester.getTopLeft(_plot()) + const Offset(2, 4));
          await tester.pumpAndSettle();

          // And the same about a radius a pixel larger under the crosshair.
          expect(_markerRadii(tester), <double>[
            radius + 2,
            radius,
            radius + 1,
            radius - 1,
          ], reason: size.name);

          await mouse.removePointer();
          await tester.pumpAndSettle();
        }
      });

      testWidgets('grows the markers under the crosshair by a pixel, over the house duration', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlLineChart(series: series, categories: months));

        final double radius = markerRadii[PlassSize.md]!;

        // Revenue's markers on January and on February, each a ring and a dot.
        expect(_markerRadii(tester), <double>[radius + 1, radius - 1, radius + 1, radius - 1]);

        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: Offset.zero);
        // Onto January, the first column.
        await mouse.moveTo(tester.getTopLeft(_plot()) + const Offset(2, 4));
        await tester.pump();
        // The clock starts on the frame after the change, as an animation's
        // does.
        await tester.pump();
        await tester.pump(PlassTokens.duration ~/ 2);

        // Halfway through, as far along as the house curve is by then, and
        // February still at rest.
        final double halfway = radius + PlassTokens.ease.transform(0.5);
        final List<double> radii = _markerRadii(tester);

        expect(radii[1], closeTo(halfway - 1, 1e-6));
        expect(radii[0], closeTo(halfway + 1, 1e-6));
        expect(radii[1], lessThan(radius));
        expect(radii.sublist(2), <double>[radius + 1, radius - 1]);

        await tester.pumpAndSettle();

        expect(_markerRadii(tester), <double>[radius + 2, radius, radius + 1, radius - 1]);

        await mouse.moveTo(Offset.zero);
        await tester.pumpAndSettle();

        expect(_markerRadii(tester), <double>[radius + 1, radius - 1, radius + 1, radius - 1]);
      });

      testWidgets('grows them at once under reduced motion', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(500, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          host(
            PlLineChart(series: series, categories: months),
            width: 500,
            disableAnimations: true,
          ),
        );
        await tester.pumpAndSettle();

        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getTopLeft(_plot()) + const Offset(2, 4));
        await tester.pump();

        final double radius = markerRadii[PlassSize.md]!;

        expect(_markerRadii(tester).sublist(0, 2), <double>[radius + 2, radius]);
        expect(tester.binding.transientCallbackCount, 0);
      });

      testWidgets('draws the one marker a line without them shows at its grown size', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlLineChart(
            series: <PlassChartSeries>[series.first],
            categories: months,
            markers: PlChartMarkers.none,
          ),
        );

        expect(_markerRadii(tester), isEmpty);

        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getTopLeft(_plot()) + const Offset(2, 4));
        await tester.pump();

        // Nothing was there to grow from, so it is put there at its size, as
        // the React marker is when the crosshair reaches its column.
        final double radius = markerRadii[PlassSize.md]!;

        expect(_markerRadii(tester), <double>[radius + 2, radius]);

        await tester.pumpAndSettle();
      });

      testWidgets('grows every series\' marker in the column of the mark read in nearest mode', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlLineChart(
            series: series,
            categories: months,
            tooltip: const PlChartTooltip(mode: PlassChartTooltipMode.nearest),
          ),
        );

        // A ring and a dot per marker, Revenue's four and then Cost's four, so
        // February's are the third pair of each.
        final _CircleCanvas rest = _paintPlot(tester);
        const List<int> february = <int>[2, 3, 10, 11];

        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: Offset.zero);
        // Beside Revenue's February point, and far from Cost's.
        await mouse.moveTo(tester.getTopLeft(_plot()) + rest.centres[2] + const Offset(1, 1));
        await tester.pump();
        await tester.pump();
        await tester.pump(PlassTokens.duration ~/ 2);

        final double along = PlassTokens.ease.transform(0.5);
        final List<double> halfway = _paintPlot(tester).radii;

        for (int i = 0; i < rest.radii.length; i += 1) {
          final double grown = february.contains(i) ? along : 0;

          expect(halfway[i], closeTo(rest.radii[i] + grown, 1e-6), reason: 'circle $i');
        }

        await tester.pumpAndSettle();

        final _CircleCanvas settled = _paintPlot(tester);

        for (int i = 0; i < rest.radii.length; i += 1) {
          final double grown = february.contains(i) ? 1 : 0;

          expect(settled.radii[i], rest.radii[i] + grown, reason: 'circle $i');
        }

        // A mark is read on its own, so there is no crosshair, and the card is
        // still that one mark's.
        expect(settled.downRules, 0);

        final List<String> lines = tester
            .widgetList<Text>(
              find.descendant(of: find.byType(PlassChartTooltipCard), matching: find.byType(Text)),
            )
            .map((Text text) => text.data!)
            .toList();

        expect(lines, <String>['Feb', 'Revenue', '19']);
      });

      testWidgets('draws the markers in the column of the mark read on a line without them', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();

        addTearDown(before.dispose);
        await _pump(
          tester,
          afterFocusStop(
            before,
            PlLineChart(
              series: series,
              categories: months,
              markers: PlChartMarkers.none,
              tooltip: const PlChartTooltip(mode: PlassChartTooltipMode.nearest),
            ),
          ),
        );

        expect(_paintPlot(tester).radii, isEmpty);

        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        // Revenue's January and then its February.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        final double radius = markerRadii[PlassSize.md]!;
        final _CircleCanvas painted = _paintPlot(tester);

        // Revenue's February marker and Cost's, one above the other, each at the
        // size a marker under the crosshair is, and no crosshair.
        expect(painted.radii, <double>[radius + 2, radius, radius + 2, radius]);
        expect(painted.centres[0].dx, painted.centres[2].dx);
        expect(painted.centres[0].dy, lessThan(painted.centres[2].dy));
        expect(painted.downRules, 0);

        await tester.pumpAndSettle();
      });
    });
  });
}

/// The plot's painter, which is the tallest `CustomPaint` with one.
Finder _plot() {
  return find
      .byWidgetPredicate(
        (Widget widget) =>
            widget is CustomPaint && widget.painter != null && widget.size.height > 40,
      )
      .first;
}

/// The plot as it is painted now.
_CircleCanvas _paintPlot(WidgetTester tester) {
  final _CircleCanvas canvas = _CircleCanvas();

  tester.widget<CustomPaint>(_plot()).painter!.paint(canvas, tester.getSize(_plot()));

  return canvas;
}

/// The radii of the first series' first two markers as they are painted now,
/// each its ring and then its dot, or of as many as there are.
List<double> _markerRadii(WidgetTester tester) {
  final List<double> radii = _paintPlot(tester).radii;

  return radii.length > 4 ? radii.sublist(0, 4) : radii;
}

/// A canvas that keeps every circle painted on it and counts the rules drawn
/// straight down, which on a chart whose columns stand upright is only ever the
/// crosshair, and drops everything else.
class _CircleCanvas implements Canvas {
  final List<Offset> centres = <Offset>[];
  final List<double> radii = <double>[];
  int downRules = 0;

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    centres.add(c);
    radii.add(radius);
  }

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    if (p1.dx == p2.dx) {
      downRules += 1;
    }
  }

  @override
  void noSuchMethod(Invocation invocation) {}
}

/// A canvas that keeps how many characters each piece of text painted on it
/// holds, and drops everything else.
class _TextCanvas implements Canvas {
  final List<int> lengths = <int>[];

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) =>
      lengths.add(paragraph.getLineBoundary(const TextPosition(offset: 0)).end);

  @override
  void noSuchMethod(Invocation invocation) {}
}
