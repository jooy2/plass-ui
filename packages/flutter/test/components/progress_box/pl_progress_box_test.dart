import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// What a screen reader is actually handed. See the bar's test for why.
SemanticsData _merged(WidgetTester tester, Finder finder) {
  return tester.getSemantics(finder).getSemanticsData();
}

/// The plates, as the boxes the row clips.
Finder _plates() {
  return find.descendant(of: find.byType(PlProgressBox), matching: find.byType(ClipRRect));
}

/// How much of each plate is covered by its fill, `0`…`1`.
List<double> _filled(WidgetTester tester) {
  return tester
      .widgetList<AnimatedFractionallySizedBox>(
        find.descendant(
          of: find.byType(PlProgressBox),
          matching: find.byType(AnimatedFractionallySizedBox),
        ),
      )
      .map((AnimatedFractionallySizedBox box) => box.widthFactor!)
      .toList();
}

void main() {
  group('PlProgressBox', () {
    group('the plates', () {
      testWidgets('draws four of them by default', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressBox(value: 40), width: 320));

        expect(_plates(), findsNWidgets(4));
      });

      testWidgets('draws as many as it was asked for', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressBox(value: 40, count: 7), width: 320));

        expect(_plates(), findsNWidgets(7));
      });

      testWidgets('never draws none', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressBox(value: 40, count: 0), width: 320));

        expect(_plates(), findsOneWidget);
      });

      testWidgets('are square, and grow with the size', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlProgressBox(value: 40, size: PlassSize.xs), width: 320),
        );

        expect(tester.getSize(_plates().first), equals(const Size(8, 8)));

        await tester.pumpWidget(
          host(const PlProgressBox(value: 40, size: PlassSize.xl), width: 320),
        );

        expect(tester.getSize(_plates().first), equals(const Size(20, 20)));
      });

      testWidgets('are cut in the neutral groove ink', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressBox(value: 40), width: 320));

        final PlassTokens tokens = PlassTheme.of(tester.element(find.byType(PlProgressBox)));
        final BoxDecoration groove = decorationWhere(
          tester,
          find.byType(PlProgressBox),
          (BoxDecoration decoration) => decoration.color != null,
        );

        expect(groove.color, equals(tokens.track));
      });

      testWidgets('light with the family gradient', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlProgressBox(value: 40, color: PlassColor.warning), width: 320),
        );

        final PlassTokens tokens = PlassTheme.of(tester.element(find.byType(PlProgressBox)));
        final BoxDecoration fill = decorationWhere(
          tester,
          find.byType(PlProgressBox),
          (BoxDecoration decoration) => decoration.gradient != null,
        );

        expect(fill.gradient, equals(tokens.family(PlassColor.warning).fill));
      });
    });

    group('the value', () {
      testWidgets('fills in order, the leading plate partially', (WidgetTester tester) async {
        // 30% of four plates is the first one full and the second three tenths
        // of the way across — which is the whole reason a plate is a groove of
        // its own.
        await tester.pumpWidget(host(const PlProgressBox(value: 30), width: 320));
        await tester.pumpAndSettle();

        expect(
          _filled(tester),
          pairwiseCompare<double, double>(
            <double>[1, 0.2, 0, 0],
            (double actual, double expected) => (actual - expected).abs() < 0.0001,
            'is within a rounding error of',
          ),
        );
      });

      testWidgets('fills every plate when it is done', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressBox(value: 100, count: 3), width: 320));
        await tester.pumpAndSettle();

        expect(_filled(tester), equals(<double>[1, 1, 1]));
      });

      testWidgets('reads the value against its own range', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressBox(value: 3, max: 5, count: 5), width: 320));
        await tester.pumpAndSettle();

        expect(_filled(tester), equals(<double>[1, 1, 1, 0, 0]));
      });

      testWidgets('clamps a value past either end of the range', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressBox(value: 180, count: 2), width: 320));
        await tester.pumpAndSettle();

        expect(_filled(tester), equals(<double>[1, 1]));

        await tester.pumpWidget(host(const PlProgressBox(value: -40, count: 2), width: 320));
        await tester.pumpAndSettle();

        expect(_filled(tester), equals(<double>[0, 0]));
      });

      testWidgets('draws a percentage of the range rather than of 100', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlProgressBox(value: 3, max: 5, count: 5, showValue: true), width: 320),
        );

        expect(find.text('60%'), findsOneWidget);
      });

      testWidgets('writes the value the caller’s own way when told how', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlProgressBox(
              value: 3,
              max: 5,
              count: 5,
              showValue: true,
              formatValue: (double value) => 'Step ${value.round()}',
            ),
            width: 320,
          ),
        );

        expect(find.text('Step 3'), findsOneWidget);
      });

      testWidgets('writes infinity as the top of the range', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlProgressBox(
              value: double.infinity,
              max: 5,
              count: 5,
              showValue: true,
              formatValue: (double value) => 'Step ${value.round()}',
            ),
            width: 320,
          ),
        );

        expect(find.text('Step 5'), findsOneWidget);
      });
    });

    group('indeterminate', () {
      testWidgets('cycles when it has no value', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressBox(), width: 320));
        await tester.pump(const Duration(milliseconds: 100));

        final double first = tester
            .widgetList<Opacity>(
              find.descendant(of: find.byType(PlProgressBox), matching: find.byType(Opacity)),
            )
            .first
            .opacity;

        await tester.pump(const Duration(milliseconds: 200));

        final double later = tester
            .widgetList<Opacity>(
              find.descendant(of: find.byType(PlProgressBox), matching: find.byType(Opacity)),
            )
            .first
            .opacity;

        expect(later, isNot(closeTo(first, 0.001)));

        await tester.pumpWidget(host(const SizedBox.shrink()));
      });

      testWidgets('holds each plate back by its own index', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressBox(count: 4), width: 320));
        await tester.pump(const Duration(milliseconds: 120));

        final List<double> opacities = tester
            .widgetList<Opacity>(
              find.descendant(of: find.byType(PlProgressBox), matching: find.byType(Opacity)),
            )
            .map((Opacity opacity) => opacity.opacity)
            .toList();

        // A wave rather than a row of lamps blinking together.
        expect(opacities.toSet().length, greaterThan(1));

        await tester.pumpWidget(host(const SizedBox.shrink()));
      });

      testWidgets('stops cycling once it is given a value', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressBox(), width: 320));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.pumpWidget(host(const PlProgressBox(value: 50, count: 2), width: 320));
        await tester.pumpAndSettle();

        expect(_filled(tester), equals(<double>[1, 0]));
      });
    });

    group('accessibility', () {
      testWidgets('is a progress bar carrying its value', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            const PlProgressBox(value: 3, max: 5, count: 5, label: Text('Deploying')),
            width: 320,
          ),
        );

        final SemanticsData node = _merged(tester, find.byType(PlProgressBox));

        expect(node.role, equals(SemanticsRole.progressBar));
        expect(node.value, equals('60%'));
        expect(node.label, equals('Deploying'));

        handle.dispose();
      });

      testWidgets('says it is indeterminate rather than saying zero', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlProgressBox(label: Text('Working')), width: 320));

        final SemanticsData node = _merged(tester, find.byType(PlProgressBox));

        expect(node.role, equals(SemanticsRole.loadingSpinner));
        expect(node.value, isEmpty);

        handle.dispose();
        await tester.pumpWidget(host(const SizedBox.shrink()));
      });

      testWidgets('reads the drawn value once, not twice', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlProgressBox(value: 40, showValue: true), width: 320));

        final SemanticsData node = _merged(tester, find.byType(PlProgressBox));

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
                const PlProgressBox(value: 62, semanticLabel: 'Deploying the site'),
                PlProgressBox(
                  value: 3,
                  max: 5,
                  count: 5,
                  label: const Text('Deploying'),
                  showValue: true,
                  formatValue: (double value) => 'Step ${value.toStringAsFixed(0)} of 5',
                  semanticLabel: 'Deploying the site',
                ),
                const PlProgressBox(value: 40, label: Text('Deploying')),
              ],
            ),
            width: 320,
          ),
        );

        // With no visible label, the row has no other name.
        final SemanticsData alone = _merged(tester, find.byType(PlProgressBox).at(0));

        expect(alone.label, equals('Deploying the site'));
        expect(alone.value, equals('62%'));
        expect(alone.role, equals(SemanticsRole.progressBar));

        // The label's words are not read a second time after the name that took
        // their place, and the value is the one that is drawn.
        final SemanticsData beside = _merged(tester, find.byType(PlProgressBox).at(1));

        expect(beside.label, equals('Deploying the site'));
        expect(beside.value, equals('Step 3 of 5'));
        expect(beside.role, equals(SemanticsRole.progressBar));

        final SemanticsData unnamed = _merged(tester, find.byType(PlProgressBox).at(2));

        expect(unnamed.label, equals('Deploying'));
        expect(unnamed.value, equals('40%'));

        handle.dispose();
      });

      testWidgets('is named by semanticLabel while it is indeterminate', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            const PlProgressBox(label: Text('Working'), semanticLabel: 'Building the bundle'),
            width: 320,
          ),
        );

        final SemanticsData node = _merged(tester, find.byType(PlProgressBox));

        expect(node.label, equals('Building the bundle'));
        expect(node.role, equals(SemanticsRole.loadingSpinner));
        expect(node.value, isEmpty);

        handle.dispose();
        await tester.pumpWidget(host(const SizedBox.shrink()));
      });
    });
  });
}
