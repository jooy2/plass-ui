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
    });
  });
}
