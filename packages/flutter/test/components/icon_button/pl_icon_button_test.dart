import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// Something to press. Any widget will do; the button never looks inside it.
const Widget _glyph = SizedBox(key: ValueKey<String>('glyph'), width: 16, height: 16);

void main() {
  group('PlIconButton', () {
    group('the name', () {
      testWidgets('is the label, because the glyph is not one', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(PlIconButton(icon: _glyph, label: 'Add an item', onPressed: () {})),
        );

        expect(find.bySemanticsLabel('Add an item'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('draws the glyph it was given', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlIconButton(icon: _glyph, label: 'Add', onPressed: () {})));

        expect(find.byKey(const ValueKey<String>('glyph')), findsOneWidget);
      });
    });

    group('the shape', () {
      testWidgets('is a disc rather than the house fillet', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlIconButton(icon: _glyph, label: 'Add', onPressed: () {})));

        expect(
          tester.widget<PlButton>(find.byType(PlButton)).borderRadius,
          BorderRadius.circular(20),
        );
      });

      testWidgets('follows the size ladder down to half the height', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlIconButton(icon: _glyph, label: 'Add', size: PlassSize.xs, onPressed: () {})),
        );

        expect(
          tester.widget<PlButton>(find.byType(PlButton)).borderRadius,
          BorderRadius.circular(12),
        );
      });

      testWidgets('is square, because a disc in a rectangle is an ellipse', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(PlIconButton(icon: _glyph, label: 'Add', onPressed: () {})));

        expect(tester.getSize(find.byType(PlIconButton)), const Size(40, 40));
      });
    });

    group('what it takes from PlButton', () {
      testWidgets('presses', (WidgetTester tester) async {
        int presses = 0;

        await tester.pumpWidget(
          host(PlIconButton(icon: _glyph, label: 'Add', onPressed: () => presses++)),
        );
        await tester.tap(find.byType(PlIconButton));

        expect(presses, 1);
      });

      testWidgets('does not press while it is loading', (WidgetTester tester) async {
        int presses = 0;

        await tester.pumpWidget(
          host(PlIconButton(icon: _glyph, label: 'Add', loading: true, onPressed: () => presses++)),
        );
        await tester.tap(find.byType(PlIconButton));

        expect(presses, 0);
      });

      testWidgets('swaps the glyph for a spinner while it is loading', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlIconButton(icon: _glyph, label: 'Add', loading: true, onPressed: () {})),
        );

        expect(find.byKey(const ValueKey<String>('glyph')), findsNothing);
      });

      testWidgets('is unavailable with no callback at all', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlIconButton(icon: _glyph, label: 'Add')));

        expect(tester.widget<PlButton>(find.byType(PlButton)).onPressed, isNull);
      });

      testWidgets('carries the variant and the colour it was given', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlIconButton(
              icon: _glyph,
              label: 'Add',
              variant: PlassVariant.ghost,
              color: PlassColor.danger,
              onPressed: () {},
            ),
          ),
        );

        final PlButton button = tester.widget<PlButton>(find.byType(PlButton));

        expect(button.variant, PlassVariant.ghost);
        expect(button.color, PlassColor.danger);
      });

      testWidgets('refuses an elevation off the ladder', (WidgetTester tester) async {
        expect(() => PlIconButton(icon: _glyph, label: 'Add', elevation: 9), throwsAssertionError);
      });
    });
  });
}
