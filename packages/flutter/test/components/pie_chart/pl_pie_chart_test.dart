import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

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

      expect(node.value, contains('Search'));
      expect(node.value, isNot(contains('Social')));
    });

    testWidgets('says nothing is there when the total is zero', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlPieChart(data: <PlassChartDatum>[PlassChartDatum(0), PlassChartDatum(0)]),
      );

      expect(find.text('Nothing here'), findsOneWidget);
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
  });
}
