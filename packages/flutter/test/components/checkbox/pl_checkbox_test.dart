import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// The tick's own box — the one decoration with a border radius on the tick
/// ladder rather than the control one.
BoxDecoration tickOf(WidgetTester tester) {
  return decorationsOf(tester, find.byType(PlCheckbox)).firstWhere(
    (BoxDecoration decoration) => decoration.gradient != null || decoration.border != null,
  );
}

void main() {
  group('PlCheckbox', () {
    group('rendering', () {
      testWidgets('is a tick of the size asked for', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlCheckbox(value: false, size: PlassSize.lg), width: 200),
        );

        expect(tester.getSize(find.byType(AnimatedContainer).first), const Size(20, 20));
      });

      testWidgets('renders its label and description', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlCheckbox(
              value: false,
              label: Text('I agree'),
              description: Text('To everything'),
            ),
            width: 300,
          ),
        );

        expect(find.text('I agree'), findsOneWidget);
        expect(styleOf(tester, 'To everything').color, PlassTokens.light().mutedFg);
      });
    });

    group('the tick', () {
      testWidgets('is clear glass with a hairline when it is off', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlCheckbox(value: false), width: 200));

        final tick = tickOf(tester);

        expect(tick.color, PlassTokens.light().glass);
        expect(tick.gradient, isNull);
        expect(tick.border, isNotNull);
      });

      testWidgets('swaps the whole surface when it is on', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlCheckbox(value: true), width: 200));
        await tester.pumpAndSettle();

        final tick = tickOf(tester);

        expect(tick.gradient, isNotNull);
        expect(tick.border, isNull);
      });

      testWidgets('draws a dash rather than a tick when it is indeterminate', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlCheckbox(value: false, indeterminate: true), width: 200),
        );

        expect(tickOf(tester).gradient, isNotNull);
        expect(find.byType(CustomPaint), findsWidgets);
      });
    });

    group('toggling', () {
      testWidgets('reports what the value should become', (WidgetTester tester) async {
        bool? reported;
        await tester.pumpWidget(
          host(PlCheckbox(value: false, onChanged: (bool next) => reported = next), width: 200),
        );

        await tester.tap(find.byType(PlCheckbox));
        expect(reported, isTrue);
      });

      testWidgets('toggles from the label as well as the tick', (WidgetTester tester) async {
        bool? reported;
        await tester.pumpWidget(
          host(
            PlCheckbox(
              value: true,
              onChanged: (bool next) => reported = next,
              label: const Text('I agree'),
            ),
            width: 300,
          ),
        );

        await tester.tap(find.text('I agree'));
        expect(reported, isFalse);
      });

      testWidgets('does not fire while read-only', (WidgetTester tester) async {
        bool? reported;
        await tester.pumpWidget(
          host(
            PlCheckbox(value: false, readOnly: true, onChanged: (bool next) => reported = next),
            width: 200,
          ),
        );

        await tester.tap(find.byType(PlCheckbox));
        expect(reported, isNull);
      });

      testWidgets('is disabled by a null callback', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlCheckbox(value: false), width: 200));

        expect(
          semanticsOf(tester, find.byType(PlCheckbox)),
          isSemantics(hasEnabledState: true, isEnabled: false),
        );

        handle.dispose();
      });
    });

    group('error', () {
      testWidgets('turns the whole control over to danger', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlCheckbox(value: true, error: Text('Required')), width: 300),
        );
        await tester.pumpAndSettle();

        final family = PlassTokens.light().family(PlassColor.danger);

        expect((tickOf(tester).gradient! as LinearGradient).colors.first, family.solid);
        expect(styleOf(tester, 'Required').color, family.accent);
      });

      testWidgets('can be turned on without a message', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlCheckbox(value: true, invalid: true), width: 200));
        await tester.pumpAndSettle();

        expect(
          (tickOf(tester).gradient! as LinearGradient).colors.first,
          PlassTokens.light().family(PlassColor.danger).solid,
        );
      });
    });

    group('accessibility', () {
      testWidgets('reports what it is checked as', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(PlCheckbox(value: true, onChanged: (bool _) {}), width: 200));

        expect(
          semanticsOf(tester, find.byType(PlCheckbox)),
          isSemantics(hasCheckedState: true, isChecked: true),
        );

        handle.dispose();
      });

      testWidgets('is named by its label', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlCheckbox(value: false, onChanged: (bool _) {}, label: const Text('I agree')),
            width: 300,
          ),
        );

        expect(find.bySemanticsLabel('I agree'), findsOneWidget);
        handle.dispose();
      });
    });
  });
}
