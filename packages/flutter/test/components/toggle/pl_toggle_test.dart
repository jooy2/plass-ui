import 'package:flutter/gestures.dart';
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

      testWidgets('never reaches for the family while it is off, under the pointer either', (
        WidgetTester tester,
      ) async {
        // The rule a two-state control lives by, and the one a hover can undo
        // without anybody noticing: `soft` is the family's wash and it is what
        // an on `ghost` toggle is painted with, so an off one that reached for
        // it under the pointer drew itself as an on toggle — with the ink as
        // the only thing still carrying the state.
        final PlassTokens tokens = PlassTokens.light();
        final PlassColorFamily family = tokens.family(PlassColor.primary);

        await tester.pumpWidget(
          host(const PlToggle(variant: PlassVariant.ghost, child: Text('Bold'))),
        );

        final TestGesture pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);

        await pointer.addPointer(location: Offset.zero);
        addTearDown(pointer.removePointer);

        await pointer.moveTo(tester.getCenter(find.byType(PlToggle)));
        await tester.pumpAndSettle();

        final Iterable<Color?> hovered = decorationsOf(
          tester,
          find.byType(PlToggle),
        ).map((BoxDecoration decoration) => decoration.color);

        expect(hovered, isNot(contains(family.soft)));
        expect(hovered, contains(tokens.glassHover));

        // And the other half, so neutralising both states is not a way to pass.
        // The pointer goes back to the corner first: `on` under the pointer is
        // `softHover`, and what is being asserted here is the resting state.
        await pointer.moveTo(Offset.zero);
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          host(const PlToggle(variant: PlassVariant.ghost, pressed: true, child: Text('Bold'))),
        );
        await tester.pumpAndSettle();

        expect(
          decorationsOf(
            tester,
            find.byType(PlToggle),
          ).map((BoxDecoration decoration) => decoration.color),
          contains(family.soft),
        );
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

      testWidgets('eases between the glass and the gradient on solid, and keeps what it holds', (
        WidgetTester tester,
      ) async {
        // Off, a `solid` toggle is glass, and on it is the gradient with no
        // glass behind it. The blur coming and going with the state used to
        // build the fill again, so the gradient arrived in one frame.
        final PlassTokens tokens = PlassTokens.light();
        final double opaque = tokens.family(PlassColor.primary).fill.colors.first.a;

        Widget toggle({required bool on}) {
          return host(PlToggle(variant: PlassVariant.solid, pressed: on, child: const _Probe()));
        }

        await tester.pumpWidget(toggle(on: false));
        final State<_Probe> content = tester.state(find.byType(_Probe));

        for (final (String reason, bool on) in <(String, bool)>[('on', true), ('off', false)]) {
          await tester.pumpWidget(toggle(on: on));
          await tester.pump(tokens.motionDuration ~/ 2);

          expect(_gradientAlpha(tester), inExclusiveRange(0, opaque), reason: reason);

          await tester.pumpAndSettle();

          expect(_gradientAlpha(tester), on ? opaque : 0, reason: reason);
          expect(tester.state(find.byType(_Probe)), same(content), reason: reason);
        }
      });

      testWidgets('eases its label to the new ink with the fill on solid', (
        WidgetTester tester,
      ) async {
        // The label used to take its new ink in one frame while the fill under
        // it was still easing, so a toggle going on wrote its white label over
        // the pale glass it was leaving, and going off wrote grey on the
        // gradient.
        final PlassTokens tokens = PlassTokens.light();
        final Color off = tokens.mutedFg;
        final Color on = tokens.family(PlassColor.primary).onSolid;

        Widget toggle({required bool pressed}) {
          return host(
            PlToggle(variant: PlassVariant.solid, pressed: pressed, child: const Text('Bold')),
          );
        }

        await tester.pumpWidget(toggle(pressed: false));

        for (final (Color from, Color to, bool pressed) in <(Color, Color, bool)>[
          (off, on, true),
          (on, off, false),
        ]) {
          await tester.pumpWidget(toggle(pressed: pressed));
          await tester.pump(tokens.motionDuration ~/ 2);

          expect(
            styleOf(tester, 'Bold').color,
            Color.lerp(from, to, tokens.motionEase.transform(0.5)),
            reason: pressed ? 'on' : 'off',
          );

          await tester.pumpAndSettle();

          expect(styleOf(tester, 'Bold').color, to, reason: pressed ? 'on' : 'off');
        }
      });

      testWidgets('changes its label ink at once under reduced motion', (
        WidgetTester tester,
      ) async {
        final PlassTokens tokens = PlassTokens.light();

        Widget toggle({required bool pressed}) {
          return host(
            PlToggle(variant: PlassVariant.solid, pressed: pressed, child: const Text('Bold')),
            disableAnimations: true,
          );
        }

        await tester.pumpWidget(toggle(pressed: false));
        await tester.pumpWidget(toggle(pressed: true));

        expect(styleOf(tester, 'Bold').color, tokens.family(PlassColor.primary).onSolid);
      });

      testWidgets('changes between the glass and the gradient at once under reduced motion', (
        WidgetTester tester,
      ) async {
        final double opaque = PlassTokens.light().family(PlassColor.primary).fill.colors.first.a;

        Widget toggle({required bool on}) {
          return host(
            PlToggle(variant: PlassVariant.solid, pressed: on, child: const Text('Bold')),
            disableAnimations: true,
          );
        }

        await tester.pumpWidget(toggle(on: false));

        for (final bool on in <bool>[true, false]) {
          await tester.pumpWidget(toggle(on: on));

          expect(_gradientAlpha(tester), on ? opaque : 0, reason: on ? 'on' : 'off');
        }
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

/// How opaque the gradient the toggle paints on this frame is, or `0` for none.
///
/// Read off the `DecoratedBox` the fill's `AnimatedContainer` builds, which
/// holds the value of the frame rather than the one it is easing towards. The
/// pointer light is a `RadialGradient`, so it is not counted.
double _gradientAlpha(WidgetTester tester) {
  final Iterable<LinearGradient> painted = tester
      .widgetList<DecoratedBox>(
        find.descendant(of: find.byType(PlToggle), matching: find.byType(DecoratedBox)),
      )
      .map((DecoratedBox box) => box.decoration)
      .whereType<BoxDecoration>()
      .map((BoxDecoration decoration) => decoration.gradient)
      .whereType<LinearGradient>();

  return painted.isEmpty ? 0 : painted.single.colors.first.a;
}

/// Content with a `State` of its own: built again from scratch, it is a
/// different object.
class _Probe extends StatefulWidget {
  const _Probe();

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => const Text('Bold');
}
