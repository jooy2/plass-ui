import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/canvas.dart';
import '../../support/host.dart';

const List<PlassChartDatum> trend = <PlassChartDatum>[
  PlassChartDatum(12),
  PlassChartDatum(19),
  PlassChartDatum(15),
  PlassChartDatum(22),
  PlassChartDatum(18),
  PlassChartDatum(26),
];

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(host(child, width: 300));
  await tester.pumpAndSettle();
}

void main() {
  group('PlSparkline', () {
    testWidgets('draws a strip sized against the text beside it', (WidgetTester tester) async {
      await _pump(tester, const PlSparkline(data: trend, semanticLabel: 'Signups'));

      final Size size = tester.getSize(find.byType(PlSparkline));

      // Short enough to sit in a line of text rather than to be a picture.
      expect(size.height, lessThan(48));
    });

    testWidgets('reads out the numbers rather than describing the shape', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const PlSparkline(
          data: <PlassChartDatum>[PlassChartDatum(1), PlassChartDatum.gap(), PlassChartDatum(3)],
          semanticLabel: 'Signups',
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Signups'));

      expect(node.value, '1, —, 3');
    });

    testWidgets('says nothing at all when it carries no name', (WidgetTester tester) async {
      await _pump(tester, const PlSparkline(data: trend));

      expect(find.bySemanticsLabel('Signups'), findsNothing);
      expect(find.byType(ExcludeSemantics), findsOneWidget);
    });

    testWidgets('takes every shape it names', (WidgetTester tester) async {
      for (final PlSparklineShape shape in PlSparklineShape.values) {
        await _pump(tester, PlSparkline(data: trend, shape: shape));

        expect(find.byType(PlSparkline), findsOneWidget);
      }
    });

    testWidgets('takes every curve it names', (WidgetTester tester) async {
      for (final PlChartCurve curve in PlChartCurve.values) {
        await _pump(tester, PlSparkline(data: trend, curve: curve));

        expect(find.byType(PlSparkline), findsOneWidget);
      }
    });

    testWidgets('takes a width rather than filling its parent', (WidgetTester tester) async {
      // Under an `Align`, because the host hands its child a tight width and a
      // widget cannot be narrower than a tight constraint.
      await _pump(tester, const Align(child: PlSparkline(data: trend, width: 120)));

      expect(tester.getSize(find.byType(PlSparkline)).width, 120);
    });

    testWidgets('climbs the size ladder', (WidgetTester tester) async {
      double? shorter;

      for (final PlassSize size in <PlassSize>[PlassSize.xs, PlassSize.xl]) {
        await _pump(tester, PlSparkline(data: trend, size: size));

        final double height = tester.getSize(find.byType(PlSparkline)).height;

        if (shorter == null) {
          shorter = height;
        } else {
          expect(height, greaterThan(shorter));
        }
      }
    });

    testWidgets('draws nothing rather than throwing on an empty series', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const PlSparkline(data: <PlassChartDatum>[]));

      expect(find.byType(PlSparkline), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('takes a baseline, a floor and a ceiling together', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlSparkline(data: trend, baseline: 20, min: 0, max: 40, endDot: true),
      );

      expect(find.byType(PlSparkline), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hangs the bars of a series that is all below zero inside the strip', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const PlSparkline(
          data: <PlassChartDatum>[PlassChartDatum(-3), PlassChartDatum(-1), PlassChartDatum(-2)],
          shape: PlSparklineShape.bar,
        ),
      );

      final _Bars bars = _Bars.of(tester);

      expect(bars.boxes, hasLength(3));

      for (final Rect box in bars.boxes) {
        expect(box.top, greaterThan(-0.5));
        expect(box.bottom, lessThan(bars.height + 0.5));
      }
    });

    testWidgets('still grows bars up from the bottom, and a mixed series from zero', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const PlSparkline(
          data: <PlassChartDatum>[PlassChartDatum(2), PlassChartDatum(4)],
          shape: PlSparklineShape.bar,
        ),
      );

      // The tallest bar runs the whole height of a strip scaled to its own range.
      final _Bars up = _Bars.of(tester);

      expect(up.boxes[1].top, closeTo(0, 0.5));
      expect(up.boxes[1].bottom, closeTo(up.height, 0.5));

      await _pump(
        tester,
        const PlSparkline(
          data: <PlassChartDatum>[PlassChartDatum(-2), PlassChartDatum(3)],
          shape: PlSparklineShape.bar,
        ),
      );

      // Below zero and above it, the two bars meet where zero is.
      final _Bars swings = _Bars.of(tester);

      expect(swings.boxes[0].top, closeTo(swings.boxes[1].bottom, 0.5));
    });

    testWidgets('keeps the lowest bar of a series above zero inside the strip', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const PlSparkline(
          data: <PlassChartDatum>[PlassChartDatum(2), PlassChartDatum(4), PlassChartDatum(3)],
          shape: PlSparklineShape.bar,
        ),
      );

      final _Bars bars = _Bars.of(tester);

      expect(bars.boxes, hasLength(3));

      for (final Rect box in bars.boxes) {
        expect(box.top, greaterThan(-0.5));
        expect(box.bottom, lessThan(bars.height + 0.5));
      }

      // The lowest value is still a mark, a pixel tall on the bottom edge.
      expect(bars.boxes[0].height, closeTo(1, 0.01));
      expect(bars.boxes[0].bottom, closeTo(bars.height, 0.01));
    });

    testWidgets('takes a family or an exact colour', (WidgetTester tester) async {
      await _pump(tester, const PlSparkline(data: trend, color: PlassColor.danger));
      expect(find.byType(PlSparkline), findsOneWidget);

      await _pump(tester, const PlSparkline(data: trend, tint: Color(0xFF00FF00)));
      expect(find.byType(PlSparkline), findsOneWidget);
    });
  });
}

/// The box of every bar a sparkline paints, with the height of its strip.
class _Bars {
  _Bars.of(WidgetTester tester) {
    final Finder strip = find.descendant(
      of: find.byType(PlSparkline),
      matching: find.byType(CustomPaint),
    );
    final canvas = _PathCanvas();

    height = tester.getSize(strip).height;
    tester.widget<CustomPaint>(strip).painter!.paint(canvas, tester.getSize(strip));
    boxes = canvas.boxes;
  }

  late final double height;
  late final List<Rect> boxes;
}

/// Keeps the bounds of every path a painter fills, in the order it drew them.
class _PathCanvas extends RecordingCanvas {
  final List<Rect> boxes = <Rect>[];

  @override
  void drawPath(Path path, Paint paint) {
    boxes.add(path.getBounds());
    super.drawPath(path, paint);
  }
}
