import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/progress.dart';
import 'package:plass_ui/src/types.dart';

void main() {
  group('ringStrokeFor', () {
    test('draws every rung of the ladder at that rung’s own stroke', () {
      for (final PlassSize size in PlassSize.values) {
        expect(ringStrokeFor(ringDiameter[size]!), ringStroke[size]);
      }
    });

    test('runs straight between two rungs', () {
      // Halfway from `md` (20, 2) to `lg` (26, 2.5).
      expect(ringStrokeFor(23), closeTo(2.25, 1e-9));
    });

    test('keeps the proportion of `xl` past the end of the ladder', () {
      // The same answers `internal/progress.ts` gives.
      expect(ringStrokeFor(64), closeTo(6, 1e-9));
      expect(ringStrokeFor(96), closeTo(9, 1e-9));
    });

    test('keeps the proportion of `xs` below the start of the ladder', () {
      expect(ringStrokeFor(14), ringStroke[PlassSize.xs]);
      expect(ringStrokeFor(7), closeTo(0.75, 1e-9));
      expect(ringStrokeFor(0.5), closeTo(0.5 * (1.5 / 14), 1e-9));
    });

    test('leaves a radius above zero however small the ring', () {
      for (final double diameter in <double>[0.5, 0.01, 1e-6]) {
        expect((diameter - ringStrokeFor(diameter)) / 2, greaterThan(0));
      }
    });
  });

  group('ringMetrics', () {
    test('is the rung when there is no diameter', () {
      for (final PlassSize size in PlassSize.values) {
        final ({double diameter, double stroke}) metrics = ringMetrics(size, null);

        expect(metrics.diameter, ringDiameter[size]);
        expect(metrics.stroke, ringStroke[size]);
      }
    });

    test('takes the diameter over the rung, and the stroke follows it', () {
      final ({double diameter, double stroke}) metrics = ringMetrics(PlassSize.sm, 96);

      expect(metrics.diameter, 96);
      expect(metrics.stroke, ringStrokeFor(96));
    });

    test('ignores a diameter that is not a finite number above zero', () {
      for (final double diameter in <double>[
        0,
        -40,
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        final ({double diameter, double stroke}) metrics = ringMetrics(PlassSize.lg, diameter);

        expect(metrics.diameter, ringDiameter[PlassSize.lg]);
        expect(metrics.stroke, ringStroke[PlassSize.lg]);
      }
    });
  });
}
