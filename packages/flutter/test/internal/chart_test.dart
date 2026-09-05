/// The arithmetic every chart is built out of.
///
/// `internal/chart.dart` knows nothing about a `Canvas` — it is scales, paths
/// and estimates — and that is exactly why it is tested here rather than
/// through a rendered chart. A flat series, an empty range and a gap in the
/// middle of a line are one call each; reaching the same cases through a widget
/// means laying a chart out and reading the answer back off a `Path`.
///
/// The rules asserted hardest are the load-bearing ones: a gap is never a zero,
/// a series' colour follows its index in the list it was passed, and the
/// palette is handed out in order.
library;

import 'dart:ui' show Color, Offset, Path, PathMetric, Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/chart.dart';

const List<Color> _palette = <Color>[Color(0xFF000001), Color(0xFF000002), Color(0xFF000003)];

void main() {
  group('toValue', () {
    test('reads a bare number', () {
      expect(toValue(const PlassChartDatum(12)).value, 12);
    });

    test('reads a gap as a gap and never as a zero', () {
      expect(toValue(const PlassChartDatum.gap()).value, isNull);
      expect(toValue(const PlassChartDatum(null)).value, isNull);
    });

    test('folds a NaN and an infinity into the same gap', () {
      expect(toValue(PlassChartDatum(double.nan)).value, isNull);
      expect(toValue(const PlassChartDatum(double.infinity)).value, isNull);
    });

    test('reads a point, and everything on it', () {
      final ChartValue value = toValue(
        PlassChartDatum.point(
          PlassChartPoint(
            y: 3,
            x: const PlassChartCategory.text('Jan'),
            z: 9,
            color: const Color(0xFFAABBCC),
            label: 'January',
          ),
        ),
      );

      expect(value.value, 3);
      expect(value.x, const PlassChartCategory.text('Jan'));
      expect(value.z, 9);
      expect(value.color, const Color(0xFFAABBCC));
      expect(value.label, 'January');
    });
  });

  group('seriesColor', () {
    test('hands the palette out in the order it is written', () {
      expect(seriesColor(null, 0, _palette), _palette[0]);
      expect(seriesColor(null, 1, _palette), _palette[1]);
      expect(seriesColor(null, 2, _palette), _palette[2]);
    });

    test('follows the index rather than the visible position', () {
      // A legend that hid series two must not repaint series three.
      expect(seriesColor(null, 2, _palette), _palette[2]);
    });

    test('wraps past the end rather than running out', () {
      expect(seriesColor(null, 3, _palette), _palette[0]);
    });

    test('lets a series name its own', () {
      expect(seriesColor(const Color(0xFF123456), 1, _palette), const Color(0xFF123456));
    });
  });

  group('extentOf', () {
    List<List<ChartValue>> unpack(List<List<double?>> rows) {
      return rows
          .map((List<double?> row) => row.map((double? v) => ChartValue(value: v)).toList())
          .toList();
    }

    test('spans the values it was given', () {
      final ChartExtent? extent = extentOf(
        unpack(<List<double?>>[
          <double?>[1, 5, 3],
        ]),
        stacked: false,
      );

      expect(extent!.min, 1);
      expect(extent.max, 5);
    });

    test('skips the gaps rather than counting them as zero', () {
      final ChartExtent? extent = extentOf(
        unpack(<List<double?>>[
          <double?>[4, null, 6],
        ]),
        stacked: false,
      );

      expect(extent!.min, 4);
    });

    test('measures the totals when it is stacked', () {
      final ChartExtent? extent = extentOf(
        unpack(<List<double?>>[
          <double?>[2, 3],
          <double?>[4, 1],
        ]),
        stacked: true,
      );

      expect(extent!.max, 6);
    });

    test('accumulates the two arms apart, so a negative does not shorten a positive', () {
      final ChartExtent? extent = extentOf(
        unpack(<List<double?>>[
          <double?>[5],
          <double?>[-3],
        ]),
        stacked: true,
      );

      expect(extent!.min, -3);
      expect(extent.max, 5);
    });

    test('has no extent at all when everything is a gap', () {
      expect(
        extentOf(
          unpack(<List<double?>>[
            <double?>[null, null],
          ]),
          stacked: false,
        ),
        isNull,
      );
    });
  });

  group('valueScale', () {
    test('rounds the ends outward to a clean number', () {
      final ValueScale scale = valueScale(const ChartExtent(0, 4830));

      expect(scale.max, 5000);
      expect(scale.ticks.first, 0);
      expect(scale.ticks.last, 5000);
    });

    test('keeps zero in range unless it is told not to', () {
      expect(valueScale(const ChartExtent(98, 99)).min, 0);
      expect(valueScale(const ChartExtent(98, 99), includeZero: false).min, lessThan(98.1));
    });

    test('opens a band around a flat series rather than dividing by zero', () {
      final ValueScale scale = valueScale(const ChartExtent(7, 7), includeZero: false);

      expect(scale.min, lessThan(7));
      expect(scale.max, greaterThan(7));
    });

    test('lands on both ends when the caller pinned them', () {
      final ValueScale scale = valueScale(null, min: 99.5, max: 100);

      expect(scale.min, 99.5);
      expect(scale.max, 100);
      expect(scale.ticks.last, 100);
    });

    test('gives a fraction of nought at the bottom and one at the top', () {
      final ValueScale scale = valueScale(const ChartExtent(0, 100), min: 0, max: 100);

      expect(scale.fraction(0), 0);
      expect(scale.fraction(100), 1);
      expect(scale.fraction(50), 0.5);
    });

    test('writes no tick as 0.30000000000000004', () {
      final ValueScale scale = valueScale(const ChartExtent(0, 0.5));

      for (final double tick in scale.ticks) {
        expect(tick.toString().length, lessThan(6));
      }
    });
  });

  group('bandScale', () {
    test('centres a mark in its slot', () {
      final band = BandScale(4, 400, 0.5);

      expect(band.step, 100);
      expect(band.band, 50);
      expect(band.centre(0), 50);
      expect(band.centre(3), 350);
    });
  });

  group('labels', () {
    test('estimates a wide script as a whole em and a narrow one as 0.6', () {
      expect(textWidth('abc', 10), closeTo(18, 0.001));
      expect(textWidth('한글', 10), closeTo(20, 0.001));
    });

    test('cuts a label to the room it has rather than dropping it', () {
      final String cut = truncateLabel('Onboarding flow', 40, 10);

      expect(cut.endsWith('…'), isTrue);
      expect(cut.length, lessThan('Onboarding flow'.length));
    });

    test('leaves a label that fits alone', () {
      expect(truncateLabel('Jan', 100, 10), 'Jan');
    });

    test('keeps the first label and every nth after it', () {
      final int stride = tickStride(30, 300, 40);

      expect(stride, greaterThan(1));
      expect(showsTick(0, 30, stride, roomForLast: false), isTrue);
      expect(showsTick(1, 30, stride, roomForLast: false), isFalse);
    });

    test('keeps the last one when there is room for it', () {
      expect(showsTick(13, 14, 2, roomForLast: true), isTrue);
      expect(showsTick(13, 14, 2, roomForLast: false), isFalse);
    });
  });

  group('linePath', () {
    /// The drawn length of a path, which is what says whether two points were
    /// actually joined. A gap leaves two zero-length strokes — a round cap
    /// renders each as the dot it is — and those measure nothing.
    double drawn(Path path) =>
        path.computeMetrics().fold<double>(0, (double sum, PathMetric m) => sum + m.length);

    test('breaks at a gap rather than interpolating across it', () {
      final Path path = linePath(<Offset?>[
        const Offset(0, 0),
        null,
        const Offset(20, 0),
      ], PlChartCurve.linear);

      expect(drawn(path), closeTo(0, 0.001));
      // Both points are still on the page — they are dots, not nothing.
      expect(path.getBounds().width, 20);
    });

    test('joins a run with no gaps in it', () {
      final Path path = linePath(<Offset?>[
        const Offset(0, 0),
        const Offset(10, 0),
        const Offset(20, 0),
      ], PlChartCurve.linear);

      expect(drawn(path), closeTo(20, 0.001));
    });

    test('never overshoots a value both neighbours are above', () {
      // Fritsch–Carlson clamps the tangent to zero where the slopes disagree,
      // which is what stops a smooth curve dipping below a local minimum.
      final path = linePath(<Offset?>[
        const Offset(0, 100),
        const Offset(10, 0),
        const Offset(20, 100),
      ], PlChartCurve.smooth);

      expect(path.getBounds().top, greaterThanOrEqualTo(-0.001));
    });

    test('holds a step at each value until the next one', () {
      final path = linePath(<Offset?>[const Offset(0, 0), const Offset(10, 20)], PlChartCurve.step);

      // The step's corner reaches the far y before the far x.
      expect(path.getBounds().height, 20);
      expect(path.getBounds().width, 10);
    });
  });

  group('markPath', () {
    test('draws every shape it names', () {
      for (final PlChartMarkShape shape in markShapes) {
        expect(markPath(shape, 10, 10, 4).getBounds().isEmpty, isFalse);
      }
    });

    test('centres the mark on the point', () {
      final Rect bounds = markPath(PlChartMarkShape.circle, 10, 20, 4).getBounds();

      expect(bounds.center.dx, closeTo(10, 0.001));
      expect(bounds.center.dy, closeTo(20, 0.001));
    });
  });
}
