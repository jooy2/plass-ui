import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

void main() {
  group('PlToggle', () {
    group('the control', () {
      testWidgets('reports whether it is on', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(host(const PlToggle(child: Text('Bold'))));

        expect(
          semanticsOf(tester, find.byType(PlToggle)),
          isSemantics(hasToggledState: true, isToggled: false, isButton: true),
        );

        handle.dispose();
      });

      testWidgets('goes on when it is pressed, and off again', (WidgetTester tester) async {
        final List<bool> seen = <bool>[];

        await tester.pumpWidget(
          host(PlToggle(onPressedChanged: seen.add, child: const Text('Bold'))),
        );

        await tester.tap(find.byType(PlToggle));
        await tester.pumpAndSettle();

        expect(seen, <bool>[true]);

        await tester.tap(find.byType(PlToggle));
        await tester.pumpAndSettle();

        expect(seen, <bool>[true, false]);
      });

      testWidgets('starts on when it is told to', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(host(const PlToggle(defaultPressed: true, child: Text('Bold'))));

        expect(semanticsOf(tester, find.byType(PlToggle)), isSemantics(isToggled: true));

        handle.dispose();
      });

      testWidgets('answers with what a controlled toggle is given', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        final List<bool> seen = <bool>[];

        await tester.pumpWidget(
          host(PlToggle(pressed: false, onPressedChanged: seen.add, child: const Text('Bold'))),
        );

        await tester.tap(find.byType(PlToggle));
        await tester.pumpAndSettle();

        expect(seen, <bool>[true]);
        expect(semanticsOf(tester, find.byType(PlToggle)), isSemantics(isToggled: false));

        handle.dispose();
      });

      testWidgets('does nothing while it is disabled', (WidgetTester tester) async {
        final List<bool> seen = <bool>[];

        await tester.pumpWidget(
          host(PlToggle(disabled: true, onPressedChanged: seen.add, child: const Text('Bold'))),
        );

        await tester.tap(find.byType(PlToggle), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(seen, isEmpty);
      });
    });

    group('the surface', () {
      testWidgets('is neutral while it is off, because off is a state that is false', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlToggle(child: Text('Bold'))));

        final PlassTokens tokens = PlassTokens.light();

        expect(styleOf(tester, 'Bold').color, tokens.mutedFg);
      });

      testWidgets('takes the family only once it is on', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlToggle(defaultPressed: true, child: Text('Bold'))));

        final PlassTokens tokens = PlassTokens.light();

        expect(styleOf(tester, 'Bold').color, tokens.family(PlassColor.primary).accent);
      });

      testWidgets('fills with the gradient on solid, and wears the on-fill ink', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlToggle(variant: PlassVariant.solid, defaultPressed: true, child: Text('Bold')),
          ),
        );

        final PlassTokens tokens = PlassTokens.light();

        // A `LinearGradient` and not just any gradient: the pointer light is a
        // `RadialGradient` layer, and it is on every variant.
        expect(
          decorationsOf(
            tester,
            find.byType(PlToggle),
          ).any((BoxDecoration decoration) => decoration.gradient is LinearGradient),
          isTrue,
        );
        expect(styleOf(tester, 'Bold').color, tokens.family(PlassColor.primary).onSolid);
      });

      testWidgets('is not dyed while it is off, whatever colour it is given', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlToggle(variant: PlassVariant.solid, child: Text('Bold'))),
        );

        expect(
          decorationsOf(
            tester,
            find.byType(PlToggle),
          ).every((BoxDecoration decoration) => decoration.gradient is! LinearGradient),
          isTrue,
        );
      });

      testWidgets('keeps the control ladder', (WidgetTester tester) async {
        for (final MapEntry<PlassSize, double> entry in <PlassSize, double>{
          PlassSize.xs: 24,
          PlassSize.sm: 32,
          PlassSize.md: 40,
          PlassSize.lg: 48,
          PlassSize.xl: 56,
        }.entries) {
          await tester.pumpWidget(host(PlToggle(size: entry.key, child: const Text('B'))));

          expect(tester.getSize(find.byType(PlToggle)).height, entry.value);
        }
      });

      testWidgets('goes square around an icon with no label', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlToggle(semanticLabel: 'Bold', startIcon: SizedBox(width: 12, height: 12))),
        );

        final Size size = tester.getSize(find.byType(PlToggle));

        expect(size.width, size.height);
      });
    });

    group('inside a group', () {
      testWidgets('takes the axes a PlButtonGroup sets', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlButtonGroup(
              size: PlassSize.sm,
              children: <Widget>[PlToggle(child: Text('Bold'))],
            ),
          ),
        );

        expect(tester.getSize(find.byType(PlToggle)).height, 32);
      });

      testWidgets('and its own value still wins', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlButtonGroup(
              size: PlassSize.sm,
              children: <Widget>[PlToggle(size: PlassSize.lg, child: Text('Bold'))],
            ),
          ),
        );

        expect(tester.getSize(find.byType(PlToggle)).height, 48);
      });
    });
  });

  group('PlToggleGroup', () {
    testWidgets('turns the last one off when a second goes on', (WidgetTester tester) async {
      final List<List<String>> seen = <List<String>>[];

      await tester.pumpWidget(
        host(
          PlToggleGroup(
            defaultValue: const <String>['left'],
            onValueChanged: seen.add,
            children: const <Widget>[
              PlToggle(value: 'left', child: Text('Left')),
              PlToggle(value: 'center', child: Text('Center')),
            ],
          ),
          width: 400,
        ),
      );

      await tester.tap(find.text('Center'));
      await tester.pumpAndSettle();

      expect(seen.single, <String>['center']);
    });

    testWidgets('keeps both on when more than one is allowed', (WidgetTester tester) async {
      final List<List<String>> seen = <List<String>>[];

      await tester.pumpWidget(
        host(
          PlToggleGroup(
            multiple: true,
            defaultValue: const <String>['bold'],
            onValueChanged: seen.add,
            children: const <Widget>[
              PlToggle(value: 'bold', child: Text('Bold')),
              PlToggle(value: 'italic', child: Text('Italic')),
            ],
          ),
          width: 400,
        ),
      );

      await tester.tap(find.text('Italic'));
      await tester.pumpAndSettle();

      expect(seen.single, <String>['bold', 'italic']);
    });

    testWidgets('turns one off again when it is pressed a second time', (
      WidgetTester tester,
    ) async {
      final List<List<String>> seen = <List<String>>[];

      await tester.pumpWidget(
        host(
          PlToggleGroup(
            multiple: true,
            defaultValue: const <String>['bold'],
            onValueChanged: seen.add,
            children: const <Widget>[PlToggle(value: 'bold', child: Text('Bold'))],
          ),
          width: 400,
        ),
      );

      await tester.tap(find.text('Bold'));
      await tester.pumpAndSettle();

      expect(seen.single, isEmpty);
    });

    testWidgets('answers with what a controlled set is given', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final List<List<String>> seen = <List<String>>[];

      await tester.pumpWidget(
        host(
          PlToggleGroup(
            value: const <String>[],
            onValueChanged: seen.add,
            children: const <Widget>[PlToggle(value: 'bold', child: Text('Bold'))],
          ),
          width: 400,
        ),
      );

      await tester.tap(find.text('Bold'));
      await tester.pumpAndSettle();

      expect(seen.single, <String>['bold']);
      expect(semanticsOf(tester, find.byType(PlToggle)), isSemantics(isToggled: false));

      handle.dispose();
    });

    testWidgets('sets the axes once for the whole set', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlToggleGroup(
            size: PlassSize.lg,
            children: <Widget>[PlToggle(value: 'bold', child: Text('Bold'))],
          ),
          width: 400,
        ),
      );

      expect(tester.getSize(find.byType(PlToggle)).height, 48);
    });

    testWidgets('disables every toggle at once', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          const PlToggleGroup(
            disabled: true,
            children: <Widget>[
              PlToggle(value: 'bold', child: Text('Bold')),
              PlToggle(value: 'italic', child: Text('Italic')),
            ],
          ),
          width: 400,
        ),
      );

      expect(semanticsOf(tester, find.byType(PlToggle).first), isSemantics(isEnabled: false));
      expect(semanticsOf(tester, find.byType(PlToggle).last), isSemantics(isEnabled: false));

      handle.dispose();
    });

    testWidgets('squares off the corners that face a neighbour', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlToggleGroup(
            children: <Widget>[
              PlToggle(value: 'a', child: Text('A')),
              PlToggle(value: 'b', child: Text('B')),
            ],
          ),
          width: 400,
        ),
      );

      final List<BorderRadius> radii = decorationsOf(tester, find.byType(PlToggle).first)
          .map((BoxDecoration decoration) => decoration.borderRadius)
          .whereType<BorderRadius>()
          .toList();

      // The leading toggle keeps its leading corners and gives up the trailing
      // pair to the seam.
      expect(radii.first.topRight, Radius.zero);
      expect(radii.first.topLeft, isNot(Radius.zero));
    });

    testWidgets('runs the other way when it is told to', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlToggleGroup(
            orientation: PlassOrientation.vertical,
            children: <Widget>[
              PlToggle(value: 'a', child: Text('A')),
              PlToggle(value: 'b', child: Text('B')),
            ],
          ),
          width: 400,
        ),
      );

      expect(tester.getTopLeft(find.text('A')).dy, lessThan(tester.getTopLeft(find.text('B')).dy));
    });
  });
}
