import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// What a screen reader is actually handed. See the bar's test for why.
SemanticsData _merged(WidgetTester tester, Finder finder) {
  return tester.getSemantics(finder).getSemanticsData();
}

/// The painter the ring is currently drawn by.
CustomPainter _painter(WidgetTester tester) {
  return tester
      .widget<CustomPaint>(
        find
            .descendant(of: find.byType(PlProgressCircular), matching: find.byType(CustomPaint))
            .first,
      )
      .painter!;
}

/// The box the ring paints into.
Size _ringSize(WidgetTester tester) {
  return tester.getSize(
    find.descendant(of: find.byType(PlProgressCircular), matching: find.byType(CustomPaint)).first,
  );
}

/// The render object the ring is painted by, for the `paints` matcher.
RenderObject _ring(WidgetTester tester) {
  return tester.renderObject(
    find.descendant(of: find.byType(PlProgressCircular), matching: find.byType(CustomPaint)).first,
  );
}

/// The size of the text a label is drawn at.
double? _fontSize(WidgetTester tester, String label) {
  return tester
      .widget<RichText>(find.descendant(of: find.text(label), matching: find.byType(RichText)))
      .text
      .style
      ?.fontSize;
}

void main() {
  group('PlProgressCircular', () {
    group('the ring', () {
      testWidgets('is square, and grows with the size', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlProgressCircular(value: 40, size: PlassSize.xs), width: 320),
        );

        expect(_ringSize(tester), equals(const Size(14, 14)));

        await tester.pumpWidget(
          host(const PlProgressCircular(value: 40, size: PlassSize.xl), width: 320),
        );

        expect(_ringSize(tester), equals(const Size(32, 32)));
      });

      testWidgets('never makes the row it is in taller than a control', (
        WidgetTester tester,
      ) async {
        // A `md` ring is 20 inside a 40px control, and the same holds at every
        // step — which is what lets one be dropped into a table row.
        const Map<PlassSize, double> control = <PlassSize, double>{
          PlassSize.xs: 24,
          PlassSize.sm: 32,
          PlassSize.md: 40,
          PlassSize.lg: 48,
          PlassSize.xl: 56,
        };

        for (final PlassSize size in PlassSize.values) {
          await tester.pumpWidget(host(PlProgressCircular(value: 40, size: size), width: 320));

          expect(_ringSize(tester).height, lessThan(control[size]!));
        }
      });

      testWidgets('keeps the ladder’s diameter and stroke at every size', (
        WidgetTester tester,
      ) async {
        const Map<PlassSize, (double, double)> ladder = <PlassSize, (double, double)>{
          PlassSize.xs: (14, 1.5),
          PlassSize.sm: (16, 1.75),
          PlassSize.md: (20, 2),
          PlassSize.lg: (26, 2.5),
          PlassSize.xl: (32, 3),
        };

        for (final MapEntry<PlassSize, (double, double)> rung in ladder.entries) {
          final (double diameter, double stroke) = rung.value;

          await tester.pumpWidget(host(PlProgressCircular(value: 40, size: rung.key), width: 320));

          expect(_ringSize(tester), equals(Size(diameter, diameter)));
          expect(
            _ring(tester),
            paints
              ..circle(strokeWidth: stroke)
              ..arc(strokeWidth: stroke),
          );
        }
      });

      testWidgets('draws the ring at diameter instead of the rung, and the stroke follows', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlProgressCircular(value: 40, size: PlassSize.sm, diameter: 96), width: 320),
        );

        expect(_ringSize(tester), equals(const Size(96, 96)));
        // `xl`'s proportion, 3 in 32, carried on past the end of the ladder;
        // and the stroke straddles the path, so the radius is in by half of it.
        // The same numbers the React build draws.
        expect(
          _ring(tester),
          paints
            ..circle(x: 48, y: 48, radius: 43.5, strokeWidth: 9)
            ..arc(
              rect: Rect.fromCircle(center: const Offset(48, 48), radius: 43.5),
              strokeWidth: 9,
            ),
        );
      });

      testWidgets('draws a diameter of 14 exactly as the xs ring', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlProgressCircular(value: 40, size: PlassSize.xl, diameter: 14), width: 320),
        );

        expect(_ringSize(tester), equals(const Size(14, 14)));
        expect(
          _ring(tester),
          paints
            ..circle(x: 7, y: 7, radius: 6.25, strokeWidth: 1.5)
            ..arc(strokeWidth: 1.5),
        );
      });

      testWidgets('keeps the radius above zero on a ring smaller than the ladder', (
        WidgetTester tester,
      ) async {
        const double stroke = 0.5 * 1.5 / 14;
        const double radius = (0.5 - stroke) / 2;

        await tester.pumpWidget(
          host(const PlProgressCircular(value: 40, diameter: 0.5), width: 320),
        );

        expect(radius, greaterThan(0));
        expect(_ringSize(tester), equals(const Size(0.5, 0.5)));
        // The radius rather than the stroke: a `Paint` keeps its width in single
        // precision, while the radius is worked out from the stroke in double.
        expect(
          _ring(tester),
          paints
            ..circle(x: 0.25, y: 0.25, radius: radius)
            ..arc(
              rect: Rect.fromCircle(center: const Offset(0.25, 0.25), radius: radius),
            ),
        );
      });

      testWidgets('still takes the gap and the text size from size beside a diameter', (
        WidgetTester tester,
      ) async {
        for (final (PlassSize size, double text, double gap) in <(PlassSize, double, double)>[
          (PlassSize.xs, 10, 4),
          (PlassSize.xl, 14, 12),
        ]) {
          await tester.pumpWidget(
            host(
              PlProgressCircular(value: 40, size: size, diameter: 96, label: const Text('Loading')),
              width: 320,
            ),
          );

          final double ringEnd = tester
              .getTopRight(
                find
                    .descendant(
                      of: find.byType(PlProgressCircular),
                      matching: find.byType(CustomPaint),
                    )
                    .first,
              )
              .dx;

          expect(_ringSize(tester), equals(const Size(96, 96)));
          expect(_fontSize(tester, 'Loading'), equals(text));
          expect(tester.getTopLeft(find.text('Loading')).dx - ringEnd, equals(gap));
        }
      });

      test('asserts on a diameter that is not a finite number above zero', () {
        for (final double diameter in <double>[0, -24, double.nan, double.infinity]) {
          expect(() => PlProgressCircular(diameter: diameter), throwsAssertionError);
        }
      });

      testWidgets('repaints when the colour family changes', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlProgressCircular(value: 40, color: PlassColor.primary), width: 320),
        );

        final CustomPainter first = _painter(tester);

        await tester.pumpWidget(
          host(const PlProgressCircular(value: 40, color: PlassColor.danger), width: 320),
        );

        // Which is the observable half of "the arc is the family's own
        // gradient": change the family and the arc has to be repainted.
        expect(_painter(tester).shouldRepaint(first), isTrue);
      });
    });

    group('indeterminate', () {
      testWidgets('turns when it has no value', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressCircular(), width: 320));
        await tester.pump(const Duration(milliseconds: 100));

        final CustomPainter first = _painter(tester);

        await tester.pump(const Duration(milliseconds: 300));

        expect(_painter(tester).shouldRepaint(first), isTrue);

        await tester.pumpWidget(host(const SizedBox.shrink()));
      });

      testWidgets('holds still once it is given a value', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressCircular(), width: 320));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.pumpWidget(host(const PlProgressCircular(value: 50), width: 320));
        await tester.pumpAndSettle();

        // Settling at all is the assertion: a ring that was still turning would
        // never let `pumpAndSettle` return.
        expect(find.byType(PlProgressCircular), findsOneWidget);
      });
    });

    group('the value', () {
      testWidgets('draws a percentage of the range rather than of 100', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlProgressCircular(value: 3, max: 4, showValue: true), width: 320),
        );

        expect(find.text('75%'), findsOneWidget);
      });

      testWidgets('draws nothing while there is nothing to say', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressCircular(showValue: true), width: 320));

        expect(find.textContaining('%'), findsNothing);

        await tester.pumpWidget(host(const SizedBox.shrink()));
      });

      testWidgets('writes the value the caller’s own way when told how', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlProgressCircular(
              value: 148,
              max: 512,
              showValue: true,
              formatValue: (double value) => '${value.round()} MB',
            ),
            width: 320,
          ),
        );

        expect(find.text('148 MB'), findsOneWidget);
      });

      testWidgets('writes infinity as the top of the range', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlProgressCircular(
              value: double.infinity,
              max: 512,
              showValue: true,
              formatValue: (double value) => '${value.round()} MB',
            ),
            width: 320,
          ),
        );

        expect(find.text('512 MB'), findsOneWidget);
      });

      testWidgets('sits beside the ring rather than inside it', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlProgressCircular(value: 40, label: Text('Syncing'), showValue: true),
            width: 320,
          ),
        );

        final double ringEnd = tester
            .getBottomRight(
              find
                  .descendant(
                    of: find.byType(PlProgressCircular),
                    matching: find.byType(CustomPaint),
                  )
                  .first,
            )
            .dx;

        expect(tester.getTopLeft(find.text('Syncing')).dx, greaterThanOrEqualTo(ringEnd));
        expect(
          tester.getTopLeft(find.text('Syncing')).dx,
          lessThan(tester.getTopLeft(find.text('40%')).dx),
        );
      });
    });

    group('accessibility', () {
      testWidgets('is a progress bar carrying its value', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const PlProgressCircular(value: 3, max: 4, label: Text('Syncing')), width: 320),
        );

        final SemanticsData node = _merged(tester, find.byType(PlProgressCircular));

        expect(node.role, equals(SemanticsRole.progressBar));
        expect(node.value, equals('75%'));
        expect(node.label, equals('Syncing'));

        handle.dispose();
      });

      testWidgets('says it is indeterminate rather than saying zero', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlProgressCircular(label: Text('Loading')), width: 320));

        final SemanticsData node = _merged(tester, find.byType(PlProgressCircular));

        expect(node.role, equals(SemanticsRole.loadingSpinner));
        expect(node.value, isEmpty);

        handle.dispose();
        await tester.pumpWidget(host(const SizedBox.shrink()));
      });

      testWidgets('reads the drawn value once, not twice', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const PlProgressCircular(value: 40, showValue: true), width: 320),
        );

        final SemanticsData node = _merged(tester, find.byType(PlProgressCircular));

        expect(node.value, equals('40%'));
        expect(node.label, isEmpty);

        handle.dispose();
      });

      testWidgets('is named by semanticLabel in the label\'s place, and by its label without one', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const PlProgressCircular(value: 62, semanticLabel: 'Syncing contacts'),
                PlProgressCircular(
                  value: 3,
                  max: 5,
                  label: const Text('Syncing'),
                  showValue: true,
                  formatValue: (double value) => '${value.toStringAsFixed(0)} of 5 folders',
                  semanticLabel: 'Syncing contacts',
                ),
                const PlProgressCircular(value: 40, label: Text('Syncing')),
              ],
            ),
            width: 320,
          ),
        );

        // With no visible label, the ring has no other name.
        final SemanticsData alone = _merged(tester, find.byType(PlProgressCircular).at(0));

        expect(alone.label, equals('Syncing contacts'));
        expect(alone.value, equals('62%'));
        expect(alone.role, equals(SemanticsRole.progressBar));

        // The label's words are not read a second time after the name that took
        // their place, and the value is the one that is drawn.
        final SemanticsData beside = _merged(tester, find.byType(PlProgressCircular).at(1));

        expect(beside.label, equals('Syncing contacts'));
        expect(beside.value, equals('3 of 5 folders'));
        expect(beside.role, equals(SemanticsRole.progressBar));

        final SemanticsData unnamed = _merged(tester, find.byType(PlProgressCircular).at(2));

        expect(unnamed.label, equals('Syncing'));
        expect(unnamed.value, equals('40%'));

        handle.dispose();
      });

      testWidgets('is named by semanticLabel while it is indeterminate', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            const PlProgressCircular(label: Text('Loading'), semanticLabel: 'Loading the inbox'),
            width: 320,
          ),
        );

        final SemanticsData node = _merged(tester, find.byType(PlProgressCircular));

        expect(node.label, equals('Loading the inbox'));
        expect(node.role, equals(SemanticsRole.loadingSpinner));
        expect(node.value, isEmpty);

        handle.dispose();
        await tester.pumpWidget(host(const SizedBox.shrink()));
      });
    });
  });
}
