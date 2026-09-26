import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/chart_frame.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';

import '../../support/canvas.dart';
import '../../support/host.dart';

const List<PlassChartDatum> traffic = <PlassChartDatum>[
  PlassChartDatum(40),
  PlassChartDatum(25),
  PlassChartDatum(20),
  PlassChartDatum(15),
];

const List<PlassChartCategory> sources = <PlassChartCategory>[
  PlassChartCategory.text('Search'),
  PlassChartCategory.text('Social'),
  PlassChartCategory.text('Direct'),
  PlassChartCategory.text('Referral'),
];

/// The same slices, with the first one carrying its own words.
const List<PlassChartDatum> labelled = <PlassChartDatum>[
  PlassChartDatum.point(PlassChartPoint(y: 40, label: 'About two in five')),
  PlassChartDatum(25),
  PlassChartDatum(20),
  PlassChartDatum(15),
];

/// The alpha every slice is filled at now, in the order they are drawn.
List<double> _sliceAlphas(WidgetTester tester) {
  final canvas = RecordingCanvas();
  final Finder disc = find.byWidgetPredicate(
    (Widget widget) => widget is CustomPaint && widget.painter != null && widget.size.height > 40,
  );

  tester.widget<CustomPaint>(disc.first).painter!.paint(canvas, tester.getSize(disc.first));

  return <double>[for (final Paint paint in canvas.fills) paint.color.a];
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(500, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: 500));
  await tester.pumpAndSettle();
}

void main() {
  group('PlPieChart', () {
    testWidgets('draws a disc and names itself', (WidgetTester tester) async {
      await _pump(tester, const PlPieChart(data: traffic, categories: sources));

      expect(find.bySemanticsLabel('Chart'), findsOneWidget);
    });

    testWidgets('names every slice in the legend rather than the series', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const PlPieChart(data: traffic, categories: sources));

      for (final PlassChartCategory source in sources) {
        expect(find.text(source.toString()), findsOneWidget);
      }
    });

    testWidgets('names a slice that is a date by its day', (WidgetTester tester) async {
      await _pump(
        tester,
        PlPieChart(
          data: traffic,
          categories: <PlassChartCategory>[
            for (int i = 0; i < traffic.length; i += 1)
              PlassChartCategory.date(DateTime(2026, 3, i + 1)),
          ],
        ),
      );

      expect(find.text('Mar 1'), findsOneWidget);
      expect(find.textContaining('2026-03'), findsNothing);
    });

    testWidgets('reads out every slice and its share', (WidgetTester tester) async {
      await _pump(tester, const PlPieChart(data: traffic, categories: sources));

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, contains('Search 40 · 40%'));
      expect(node.value, contains('Referral 15 · 15%'));
    });

    testWidgets('reads a slice by its own label when it carries one', (WidgetTester tester) async {
      await _pump(tester, const PlPieChart(data: labelled, categories: sources));

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      // The point's own words stand in for its value and share, as they do on
      // every other chart; a slice without any is still read by its share.
      expect(node.value, contains('Search About two in five'));
      expect(node.value, isNot(contains('Search 40 · 40%')));
      expect(node.value, contains('Social 25 · 25%'));
    });

    testWidgets('writes a slice compactly and grouped without a format', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const PlPieChart(
          data: <PlassChartDatum>[PlassChartDatum(1234.5), PlassChartDatum(48300)],
          categories: <PlassChartCategory>[
            PlassChartCategory.text('Search'),
            PlassChartCategory.text('Social'),
          ],
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, contains('Search 1,234.5 · '));
      expect(node.value, contains('Social 48.3K · '));
    });

    testWidgets('takes every shape it names', (WidgetTester tester) async {
      for (final PlPieShape shape in PlPieShape.values) {
        await _pump(tester, PlPieChart(data: traffic, categories: sources, shape: shape));

        expect(find.byType(PlPieChart), findsOneWidget);
      }
    });

    testWidgets('leaves a gap and a zero out of the reading', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlPieChart(
          data: <PlassChartDatum>[
            PlassChartDatum(40),
            PlassChartDatum.gap(),
            PlassChartDatum(0),
            PlassChartDatum(60),
          ],
          categories: sources,
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      // Only the slices that have an angle, as in the React build: a slice
      // worth nothing is not read as "Direct 0 · 0%".
      expect(node.value, 'Search 40 · 40%, Referral 60 · 60%');
    });

    testWidgets('says nothing is there when the total is zero', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlPieChart(
          data: <PlassChartDatum>[PlassChartDatum(0), PlassChartDatum(0)],
          categories: sources,
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);

      // And reads no slice out either, since none of them was drawn. The
      // words in the empty box join the chart's own name.
      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel(RegExp('^Chart')));

      expect(node.value, isEmpty);
    });

    testWidgets('puts the caller content in the hole of a donut', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlPieChart(
          data: <PlassChartDatum>[PlassChartDatum(40), PlassChartDatum(60)],
          shape: PlPieShape.donut,
          center: Text('100'),
        ),
      );

      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('opens a hole in a pie when `innerRadius` asks for one', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const PlPieChart(
          data: <PlassChartDatum>[PlassChartDatum(40), PlassChartDatum(60)],
          innerRadius: 0.5,
          center: Text('100'),
        ),
      );

      // A pie has no hole, so the caller content has nowhere to go — unless the
      // caller cuts one, which is a donut by another name.
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('widens the gap between slices when `padAngle` asks', (WidgetTester tester) async {
      /// How much of a ring through the middle of the disc is covered by a
      /// slice, out of 360 samples. The gaps are what the rest of it is, so a
      /// wider gap is a smaller number — and this asks the question without
      /// naming an angle or a radius the test would then be pinning.
      Future<int> covered(double? padAngle) async {
        await _pump(
          tester,
          PlPieChart(
            data: const <PlassChartDatum>[PlassChartDatum(40), PlassChartDatum(60)],
            padAngle: padAngle,
            legend: const PlChartLegend(hidden: true),
          ),
        );

        final canvas = RecordingCanvas();
        final Finder plot = find.byWidgetPredicate(
          (Widget widget) => widget is CustomPaint && widget.painter != null,
        );

        tester.widget<CustomPaint>(plot.first).painter!.paint(canvas, tester.getSize(plot.first));

        final Rect disc = canvas.paths.fold(
          canvas.paths.first.getBounds(),
          (Rect box, Path path) => box.expandToInclude(path.getBounds()),
        );
        final Offset centre = disc.center;
        final double radius = disc.width / 2 * 0.6;

        int hits = 0;

        for (int degree = 0; degree < 360; degree += 1) {
          final double radians = degree * math.pi / 180;
          final Offset at = centre + Offset(math.cos(radians), math.sin(radians)) * radius;

          if (canvas.paths.any((Path path) => path.contains(at))) {
            hits += 1;
          }
        }

        return hits;
      }

      expect(await covered(8), lessThan(await covered(0)));
    });

    testWidgets('leaves it out of a pie, which has no hole to put it in', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const PlPieChart(
          data: <PlassChartDatum>[PlassChartDatum(40), PlassChartDatum(60)],
          center: Text('100'),
        ),
      );

      expect(find.text('100'), findsNothing);
    });

    testWidgets('takes a slice out of the ring and shares its angle out again', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const PlPieChart(data: traffic, categories: sources));

      await tester.tap(find.bySemanticsLabel('Social'));
      await tester.pumpAndSettle();

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, isNot(contains('Social')));
      expect(node.value, contains('Search 40 · 53.3%'));
    });

    testWidgets('leaves the drawn slices alone while a hidden entry is pointed at', (
      WidgetTester tester,
    ) async {
      // An entry that is switched off has no arc on the disc to be highlighted,
      // so pointing at it must leave the slices that are drawn where they are.
      await _pump(tester, const PlPieChart(data: traffic, categories: sources, height: 240));

      await tester.tap(find.bySemanticsLabel('Social'));
      await tester.pumpAndSettle();

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.bySemanticsLabel('Social')));
      await tester.pump();

      final canvas = RecordingCanvas();
      final Finder disc = find.byWidgetPredicate(
        (Widget widget) =>
            widget is CustomPaint && widget.painter != null && widget.size.height > 40,
      );

      tester.widget<CustomPaint>(disc.first).painter!.paint(canvas, tester.getSize(disc.first));

      expect(canvas.fills.length, 3);
      expect(canvas.fills.every((Paint paint) => paint.color.a == 1), isTrue);
    });

    testWidgets('shows a readout for the slice under the press', (WidgetTester tester) async {
      await _pump(tester, const PlPieChart(data: traffic, categories: sources, height: 240));

      // Up and to the right of the middle: the first slice starts at twelve
      // o'clock and runs clockwise through forty percent of the turn.
      await tester.tapAt(tester.getCenter(find.byType(CustomPaint).first) + const Offset(30, -50));
      await tester.pumpAndSettle();

      expect(find.text('40 · 40%'), findsOneWidget);
    });

    testWidgets('writes a slice by its own label on its readout', (WidgetTester tester) async {
      await _pump(tester, const PlPieChart(data: labelled, categories: sources, height: 240));

      await tester.tapAt(tester.getCenter(find.byType(CustomPaint).first) + const Offset(30, -50));
      await tester.pumpAndSettle();

      expect(find.text('About two in five'), findsOneWidget);
      expect(find.text('40 · 40%'), findsNothing);
    });

    testWidgets('takes a second press on the same slice as a dismissal', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const PlPieChart(data: traffic, categories: sources, height: 240));

      final Offset inside =
          tester.getCenter(find.byType(CustomPaint).first) + const Offset(30, -50);

      await tester.tapAt(inside);
      await tester.pumpAndSettle();
      expect(find.text('40 · 40%'), findsOneWidget);

      await tester.tapAt(inside);
      await tester.pumpAndSettle();
      expect(find.text('40 · 40%'), findsNothing);
    });

    testWidgets('shows no readout at all when the mode is none', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlPieChart(
          data: traffic,
          categories: sources,
          height: 240,
          tooltip: PlChartTooltip(mode: PlassChartTooltipMode.none),
        ),
      );

      await tester.tapAt(tester.getCenter(find.byType(CustomPaint).first) + const Offset(30, -50));
      await tester.pumpAndSettle();

      expect(find.text('40 · 40%'), findsNothing);
    });

    testWidgets('says nothing when the press lands off the disc', (WidgetTester tester) async {
      await _pump(tester, const PlPieChart(data: traffic, categories: sources, height: 240));

      await tester.tapAt(tester.getCenter(find.byType(CustomPaint).first) + const Offset(0, -119));
      await tester.pumpAndSettle();

      expect(find.textContaining('·'), findsNothing);
    });

    group('the keyboard', () {
      /// Puts the chart after a focus stop of its own and arrives on it by Tab,
      /// having done [first] to it.
      Future<void> tabTo(
        WidgetTester tester,
        Widget chart, {
        Future<void> Function()? first,
        TextDirection textDirection = TextDirection.ltr,
      }) async {
        final FocusNode before = FocusNode();

        addTearDown(before.dispose);
        tester.view.physicalSize = const Size(500, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          host(afterFocusStop(before, chart), width: 500, textDirection: textDirection),
        );
        await tester.pumpAndSettle();
        await first?.call();

        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }

      /// What the live region is saying.
      String said(WidgetTester tester) {
        return find.semantics.byFlag(SemanticsFlag.isLiveRegion).evaluate().single.label;
      }

      /// Presses each key in turn and checks what is said after it.
      Future<void> walk(WidgetTester tester, List<(LogicalKeyboardKey, String)> steps) async {
        for (final (LogicalKeyboardKey key, String reading) in steps) {
          await tester.sendKeyEvent(key);
          await tester.pump();

          expect(said(tester), reading, reason: '$key');
        }
      }

      testWidgets('is a tab stop, and says nothing until a key moves', (WidgetTester tester) async {
        await tabTo(tester, const PlPieChart(data: traffic, categories: sources));

        final SemanticsNode chart = tester.getSemantics(find.bySemanticsLabel('Chart'));

        expect(chart, isSemantics(label: 'Chart', isFocusable: true, isFocused: true));
        expect(said(tester), isEmpty);
      });

      testWidgets('walks the slices with the arrow keys, round past either end', (
        WidgetTester tester,
      ) async {
        await tabTo(tester, const PlPieChart(data: traffic, categories: sources));

        await walk(tester, <(LogicalKeyboardKey, String)>[
          (LogicalKeyboardKey.arrowRight, 'Search, 40 · 40%'),
          (LogicalKeyboardKey.arrowRight, 'Social, 25 · 25%'),
          (LogicalKeyboardKey.arrowLeft, 'Search, 40 · 40%'),
          (LogicalKeyboardKey.arrowLeft, 'Referral, 15 · 15%'),
          (LogicalKeyboardKey.arrowRight, 'Search, 40 · 40%'),
        ]);

        // Home and End are not the pie's, as they are not the React pie's:
        // they go on to whatever the chart sits in and leave the reading.
        expect(await tester.sendKeyEvent(LogicalKeyboardKey.home), isFalse);
        expect(await tester.sendKeyEvent(LogicalKeyboardKey.end), isFalse);
        await tester.pump();
        expect(said(tester), 'Search, 40 · 40%');
      });

      testWidgets('starts from the last slice when the first key goes back', (
        WidgetTester tester,
      ) async {
        await tabTo(tester, const PlPieChart(data: traffic, categories: sources));

        await walk(tester, <(LogicalKeyboardKey, String)>[
          (LogicalKeyboardKey.arrowLeft, 'Referral, 15 · 15%'),
        ]);
      });

      testWidgets('walks the same way round in a right-to-left locale', (
        WidgetTester tester,
      ) async {
        await tabTo(
          tester,
          const PlPieChart(data: traffic, categories: sources),
          textDirection: TextDirection.rtl,
        );

        // The slices run clockwise whichever way the words do.
        await walk(tester, <(LogicalKeyboardKey, String)>[
          (LogicalKeyboardKey.arrowRight, 'Search, 40 · 40%'),
          (LogicalKeyboardKey.arrowRight, 'Social, 25 · 25%'),
        ]);
      });

      testWidgets('passes over a slice with no arc: a gap, a zero, and one switched off', (
        WidgetTester tester,
      ) async {
        await tabTo(
          tester,
          const PlPieChart(
            data: <PlassChartDatum>[
              PlassChartDatum(40),
              PlassChartDatum.gap(),
              PlassChartDatum(0),
              PlassChartDatum(60),
              PlassChartDatum(20),
            ],
            categories: <PlassChartCategory>[...sources, PlassChartCategory.text('Email')],
          ),
          first: () async {
            await tester.tap(find.bySemanticsLabel('Email'));
            await tester.pumpAndSettle();
          },
        );

        await walk(tester, <(LogicalKeyboardKey, String)>[
          (LogicalKeyboardKey.arrowRight, 'Search, 40 · 40%'),
          (LogicalKeyboardKey.arrowRight, 'Referral, 60 · 60%'),
          (LogicalKeyboardKey.arrowRight, 'Search, 40 · 40%'),
        ]);
      });

      testWidgets('says a slice by its own label when it carries one', (WidgetTester tester) async {
        await tabTo(tester, const PlPieChart(data: labelled, categories: sources));

        await walk(tester, <(LogicalKeyboardKey, String)>[
          (LogicalKeyboardKey.arrowRight, 'Search, About two in five'),
          (LogicalKeyboardKey.arrowRight, 'Social, 25 · 25%'),
        ]);
      });

      testWidgets('stands the card on the slice a key reached, and keeps it off the tree', (
        WidgetTester tester,
      ) async {
        // No legend, which is when the plot and the chart are one node and a
        // card on the tree would be read into its name.
        await tabTo(
          tester,
          const PlPieChart(data: traffic, categories: sources, legend: PlChartLegend(hidden: true)),
        );

        expect(find.byType(PlassChartTooltipCard), findsNothing);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        expect(find.byType(PlassChartTooltipCard), findsOneWidget);
        expect(find.text('Search'), findsOneWidget);
        expect(find.text('40 · 40%'), findsOneWidget);
        // Said once, by the live region, rather than read into the chart's
        // name as well.
        expect(said(tester), 'Search, 40 · 40%');
        expect(tester.getSemantics(find.bySemanticsLabel(RegExp('^Chart'))).label, 'Chart');
      });

      testWidgets('says the slice a press reached as well', (WidgetTester tester) async {
        await _pump(tester, const PlPieChart(data: traffic, categories: sources, height: 240));

        await tester.tapAt(
          tester.getCenter(find.byType(CustomPaint).first) + const Offset(30, -50),
        );
        await tester.pumpAndSettle();

        expect(said(tester), 'Search, 40 · 40%');
      });

      testWidgets('draws the ring only while the keyboard holds it', (WidgetTester tester) async {
        // No legend, so there is no entry whose own ring could be the one
        // found once the focus moves on.
        await tabTo(
          tester,
          const PlPieChart(data: traffic, categories: sources, legend: PlChartLegend(hidden: true)),
        );

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
        await tabTo(tester, const PlPieChart(data: traffic, categories: sources));

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

      testWidgets('fades the other slices over the house duration as a key reaches one', (
        WidgetTester tester,
      ) async {
        await tabTo(tester, const PlPieChart(data: traffic, categories: sources));

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        // The clock starts on the frame after the change, as an animation's
        // does.
        await tester.pump();
        await tester.pump(PlassTokens.duration ~/ 2);

        // The slice being read stays whole, and the other three are halfway
        // along the house curve to the fade.
        expect(_sliceAlphas(tester), <Matcher>[
          equals(1),
          for (int i = 0; i < 3; i += 1) closeTo(1 - 0.68 * PlassTokens.ease.transform(0.5), 1e-6),
        ]);

        await tester.pumpAndSettle();

        expect(_sliceAlphas(tester), <Matcher>[
          equals(1),
          for (int i = 0; i < 3; i += 1) closeTo(0.32, 1e-6),
        ]);

        // And back from where they stand once the reading is cleared.
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();
        await tester.pump();
        await tester.pump(PlassTokens.duration ~/ 2);

        expect(
          _sliceAlphas(tester).skip(1),
          everyElement(closeTo(0.32 + 0.68 * PlassTokens.ease.transform(0.5), 1e-6)),
        );

        await tester.pumpAndSettle();

        expect(_sliceAlphas(tester), everyElement(1));
      });

      testWidgets('fades the other slices at once under reduced motion', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();

        addTearDown(before.dispose);
        tester.view.physicalSize = const Size(500, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          host(
            afterFocusStop(before, const PlPieChart(data: traffic, categories: sources)),
            width: 500,
            disableAnimations: true,
          ),
        );
        await tester.pumpAndSettle();

        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        expect(_sliceAlphas(tester), <Matcher>[
          equals(1),
          for (int i = 0; i < 3; i += 1) closeTo(0.32, 1e-6),
        ]);
        expect(tester.binding.transientCallbackCount, 0);
      });

      testWidgets('lets go of a slice that is gone when it is built again with fewer', (
        WidgetTester tester,
      ) async {
        List<PlassChartDatum> data = traffic;
        late StateSetter setData;

        await tabTo(
          tester,
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              setData = setState;

              return PlPieChart(data: data, categories: sources);
            },
          ),
        );

        // The last slice, which the next build does not have.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();
        expect(said(tester), 'Referral, 15 · 15%');

        setData(() => data = traffic.sublist(0, 2));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(said(tester), isEmpty);
        expect(find.byType(PlassChartTooltipCard), findsNothing);

        // And the walk starts again from the slices that are there.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(said(tester), 'Search, 40 · 61.5%');

        await tester.pumpAndSettle();
      });

      testWidgets('keeps reading a slice that is still there when it is built again', (
        WidgetTester tester,
      ) async {
        List<PlassChartDatum> data = traffic;
        late StateSetter setData;

        await tabTo(
          tester,
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              setData = setState;

              return PlPieChart(data: data, categories: sources);
            },
          ),
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(said(tester), 'Search, 40 · 40%');

        setData(() => data = traffic.sublist(0, 2));
        await tester.pump();

        expect(said(tester), 'Search, 40 · 61.5%');

        await tester.pumpAndSettle();
      });

      testWidgets('clears what it was reading when the focus leaves', (WidgetTester tester) async {
        await tabTo(tester, const PlPieChart(data: traffic, categories: sources));

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(said(tester), isNotEmpty);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        expect(said(tester), isEmpty);
        expect(find.byType(PlassChartTooltipCard), findsNothing);
      });

      for (final (String name, PlChartTooltip tooltip) in <(String, PlChartTooltip)>[
        ('hidden', const PlChartTooltip(hidden: true)),
        ('in mode none', const PlChartTooltip(mode: PlassChartTooltipMode.none)),
      ]) {
        testWidgets('leaves the keys alone and says nothing when its tooltip is $name', (
          WidgetTester tester,
        ) async {
          await tabTo(tester, PlPieChart(data: traffic, categories: sources, tooltip: tooltip));

          // Neither arrow lights a slice, so both go on to whatever the chart
          // sits in, as on every other chart with its tooltip off.
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
          await tester.pump();

          expect(
            tester.getSemantics(find.bySemanticsLabel('Chart')),
            isSemantics(label: 'Chart', isFocusable: true, isFocused: true),
          );

          final canvas = RecordingCanvas();
          final Finder disc = find.byWidgetPredicate(
            (Widget widget) =>
                widget is CustomPaint && widget.painter != null && widget.size.height > 40,
          );

          tester.widget<CustomPaint>(disc.first).painter!.paint(canvas, tester.getSize(disc.first));

          expect(canvas.fills.length, 4);
          expect(canvas.fills.every((Paint paint) => paint.color.a == 1), isTrue);
          expect(find.semantics.byFlag(SemanticsFlag.isLiveRegion), findsNothing);
          expect(find.byType(PlassChartTooltipCard), findsNothing);
        });
      }

      testWidgets('is a tab stop only while there is something on it', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlPieChart(
            data: <PlassChartDatum>[PlassChartDatum(0), PlassChartDatum(0)],
            categories: sources,
          ),
        );

        expect(
          tester.getSemantics(find.bySemanticsLabel(RegExp('^Chart'))),
          isSemantics(isFocusable: false),
        );
      });
    });
  });
}
