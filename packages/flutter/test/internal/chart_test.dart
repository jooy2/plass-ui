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

  group('dimmedByHover', () {
    test('fades the others while an entry that is on the plot is pointed at', () {
      expect(dimmedByHover(0, 1, <bool>[true, true, true]), isTrue);
      expect(dimmedByHover(0, 0, <bool>[true, true, true]), isFalse);
    });

    test('fades nothing while the entry pointed at is switched off', () {
      // Otherwise the whole chart goes grey to make room for a series that is
      // not drawn, which reads as the picture breaking.
      expect(dimmedByHover(0, 1, <bool>[false, true, true]), isFalse);
      expect(dimmedByHover(2, 0, <bool>[true, true, false]), isFalse);
    });

    test('fades nothing while no entry is pointed at', () {
      expect(dimmedByHover(null, 1, <bool>[true, true]), isFalse);
    });
  });

  group('labelledPoints', () {
    List<bool> read(List<double?> values, PlassChartValueLabels which) {
      final bool Function(int) labelled = labelledPoints(<ChartValue>[
        for (final double? value in values) ChartValue(value: value),
      ], which);

      return <bool>[for (int i = 0; i < values.length; i += 1) labelled(i)];
    }

    test('names the last point that is there rather than the last slot', () {
      expect(read(<double?>[10, 20, null], PlassChartValueLabels.last), <bool>[false, true, false]);
    });

    test('names the high and the low, and nothing in a series of gaps', () {
      expect(read(<double?>[5, 30, null, 2], PlassChartValueLabels.extremes), <bool>[
        false,
        true,
        false,
        true,
      ]);
      expect(read(<double?>[null, null], PlassChartValueLabels.extremes), <bool>[false, false]);
    });

    test('names every point with all and none with none', () {
      expect(read(<double?>[1, 2], PlassChartValueLabels.all), <bool>[true, true]);
      expect(read(<double?>[1, 2], PlassChartValueLabels.none), <bool>[false, false]);
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

    test('opens a flat series only on the side the caller left free', () {
      final ValueScale above = valueScale(const ChartExtent(0, 0), min: 0);

      expect(above.min, 0);
      expect(above.max, greaterThan(0));
      // The same ticks the React build gives: the step is read off the band
      // that was opened, not off one opened on both sides and then cut.
      expect(above.ticks, <double>[0, 0.2, 0.4, 0.6, 0.8, 1]);

      final ValueScale below = valueScale(const ChartExtent(40, 40), max: 40, includeZero: false);

      expect(below.max, 40);
      expect(below.min, lessThan(40));
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

  group('compactNumber', () {
    test('writes the same figures the React default writes', () {
      // Every one of these is what `Intl` with `notation: 'compact'` and one
      // decimal place gives in `en-US`, which is the React default.
      expect(compactNumber(0), '0');
      expect(compactNumber(1.5), '1.5');
      expect(compactNumber(999), '999');
      expect(compactNumber(9999), '9999');
      expect(compactNumber(10000), '10K');
      expect(compactNumber(12345), '12.3K');
      expect(compactNumber(48300), '48.3K');
      expect(compactNumber(99900), '99.9K');
      expect(compactNumber(1234567), '1.2M');
      expect(compactNumber(1500000000), '1.5B');
      expect(compactNumber(1.5e12), '1.5T');
      expect(compactNumber(1.5e15), '1500T');
      expect(compactNumber(-48300), '-48.3K');
    });

    test('moves a unit along rather than writing a thousand of the one below', () {
      expect(compactNumber(999999), '1M');
    });
  });

  group('a time axis with no span', () {
    test('opens a day around the moment both ends name', () {
      final double at = DateTime(2026, 3, 1, 9, 30).millisecondsSinceEpoch.toDouble();
      final TimeScale scale = timeScale(null, min: at, max: at);

      // Without this the axis had no width, and a mark on it landed on the
      // origin here and a screen off the plot in the React build.
      expect(scale.max - scale.min, 24 * 60 * 60 * 1000);
      expect(scale.fraction(at), closeTo(0.5, 0.000001));
    });

    test('opens one around a single instant in the data too', () {
      final double at = DateTime(2026, 3, 1, 9, 30).millisecondsSinceEpoch.toDouble();
      final TimeScale scale = timeScale(ChartExtent(at, at));

      expect(scale.max, greaterThan(scale.min));
      expect(scale.fraction(at).isFinite, isTrue);
    });
  });

  group('the date on an axis of hours', () {
    double at(int day, int hour) => DateTime(2026, 1, day, hour).millisecondsSinceEpoch.toDouble();

    test('is left off an axis inside one day', () {
      final TimeScale scale = timeScale(ChartExtent(at(5, 9), at(5, 17)));

      expect(scale.unit, PlChartTimeUnit.hour);
      expect(timeNeedsDate(scale.ticks, scale.unit), isFalse);
      expect(
        formatTimeTicks(scale.ticks, scale.unit, PlDateNames.english).skip(1),
        everyElement(isNot(contains('Jan'))),
      );
    });

    test('is left off an axis that ends at the midnight after its day', () {
      expect(timeNeedsDate(<double>[at(5, 0), at(6, 0)], PlChartTimeUnit.hour), isFalse);
    });

    test('is written on every tick of an axis that crosses midnight', () {
      final TimeScale scale = timeScale(ChartExtent(at(5, 9), at(6, 17)));

      expect(scale.unit, PlChartTimeUnit.hour);
      expect(timeNeedsDate(scale.ticks, scale.unit), isTrue);
      expect(
        formatTimeTicks(scale.ticks, scale.unit, PlDateNames.english),
        everyElement(matches(RegExp(r'^Jan [56], .*\d{2}:00$'))),
      );
    });

    test('is written in front of one time when asked for', () {
      expect(formatTimeValue(at(6, 9), PlChartTimeUnit.hour, PlDateNames.english), '09:00');
      expect(
        formatTimeValue(at(6, 9), PlChartTimeUnit.hour, PlDateNames.english, withDate: true),
        'Jan 6, 2026, 09:00',
      );
    });

    test('never applies to a unit that already names the day', () {
      expect(timeNeedsDate(<double>[at(1, 0), at(31, 0)], PlChartTimeUnit.day), isFalse);
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

    test('cuts a long category name to its slot', () {
      const List<String> months = <String>['January', 'February', 'March'];

      expect(
        fitCategoryLabels(months, horizontal: false, slot: 40, fontSize: 10, ticks: false),
        <String>[for (final String month in months) truncateLabel(month, 34, 10)],
      );
    });

    test('leaves the names whole once a slot is too narrow for a cut to help', () {
      // 24 pixels is under 2.4 ems at 10px, so the stride thins the axis instead.
      const List<String> months = <String>['January', 'February', 'March'];

      expect(
        fitCategoryLabels(months, horizontal: false, slot: 20, fontSize: 10, ticks: false),
        months,
      );
    });

    test('cuts a horizontal chart’s names to a column rather than a slot', () {
      expect(
        fitCategoryLabels(
          <String>['A category name long enough to need cutting at all'],
          horizontal: true,
          slot: 1,
          fontSize: 10,
          ticks: false,
        ).single,
        endsWith('…'),
      );
    });

    test('never cuts the ticks of a value-scaled axis', () {
      expect(
        fitCategoryLabels(
          <String>['1,000,000'],
          horizontal: false,
          slot: 30,
          fontSize: 10,
          ticks: true,
        ),
        <String>['1,000,000'],
      );
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

  group('areaPath', () {
    // Two bands stacked on one floor, one over the other, sampled half a step
    // either side of the middle point so a straight floor and a curved or
    // stepped one would disagree there.
    const List<Offset?> top = <Offset?>[Offset(0, 10), Offset(100, 30), Offset(200, 10)];
    const List<Offset?> floor = <Offset?>[Offset(0, 50), Offset(100, 70), Offset(200, 50)];
    const List<Offset?> ground = <Offset?>[Offset(0, 90), Offset(100, 90), Offset(200, 90)];

    for (final PlChartCurve curve in PlChartCurve.values) {
      test('fills the whole band between its two edges, ${curve.name}', () {
        final Path band = areaPath(top, floor, curve);

        expect(band.contains(const Offset(100, 50)), isTrue);
        expect(band.contains(const Offset(20, 30)), isTrue);
        expect(band.contains(const Offset(100, 5)), isFalse);
        expect(band.contains(const Offset(100, 80)), isFalse);
      });

      test('meets the band under it with no gap and no overlap, ${curve.name}', () {
        final Path upper = areaPath(top, floor, curve);
        final Path lower = areaPath(floor, ground, curve);
        final Path edge = linePath(floor, curve);

        // Just above and just below the shared edge, at every tenth of the way.
        for (int x = 5; x < 200; x += 20) {
          final double y = _yAt(edge, x.toDouble());

          expect(upper.contains(Offset(x.toDouble(), y - 1)), isTrue, reason: 'above at $x');
          expect(lower.contains(Offset(x.toDouble(), y - 1)), isFalse, reason: 'above at $x');
          expect(lower.contains(Offset(x.toDouble(), y + 1)), isTrue, reason: 'below at $x');
          expect(upper.contains(Offset(x.toDouble(), y + 1)), isFalse, reason: 'below at $x');
        }
      });
    }
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

    test('draws each shape as one outline', () {
      // Two overlapping rectangles cover the same ink as a cross and stroke
      // very differently: outlined separately, the ring draws a hatch through
      // the middle of the mark.
      for (final PlChartMarkShape shape in markShapes) {
        expect(markPath(shape, 10, 10, 4).computeMetrics().length, 1, reason: shape.name);
      }
    });

    test('covers the same area whatever shape it is', () {
      // Equal area and not equal radius: on a bubble chart the area is already
      // carrying a magnitude, so a square covering a third more ink than the
      // circle beside it is a square reporting a value it was not given.
      final double circle = _area(markPath(PlChartMarkShape.circle, 0, 0, 40));

      for (final PlChartMarkShape shape in markShapes) {
        expect(_area(markPath(shape, 0, 0, 40)) / circle, closeTo(1, 0.02));
      }
    });
  });
}

/// How much ink a shape covers, by counting the grid points inside it.
///
/// A `Path` has no area to ask for, and working the area out from the corners
/// would be working it out from the same arithmetic the test is checking.
double _area(Path path) {
  const double step = 0.5;
  int inside = 0;

  for (double x = -80; x < 80; x += step) {
    for (double y = -80; y < 80; y += step) {
      if (path.contains(Offset(x, y))) {
        inside += 1;
      }
    }
  }

  return inside * step * step;
}

/// Where a line drawn left to right crosses the vertical at [x].
double _yAt(Path line, double x) {
  for (final PathMetric metric in line.computeMetrics()) {
    for (double d = 0; d <= metric.length; d += 0.25) {
      final Offset? at = metric.getTangentForOffset(d)?.position;

      if (at != null && (at.dx - x).abs() < 0.2) {
        return at.dy;
      }
    }
  }

  throw StateError('the line does not reach $x');
}
