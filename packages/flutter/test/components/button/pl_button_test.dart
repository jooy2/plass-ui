import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
// Reached directly rather than through the barrel: these are the library
// talking to itself, and the tests are the one caller allowed to listen in.
import 'package:plass_ui/src/internal/css.dart';
import 'package:plass_ui/src/internal/icons.dart';

/// The same suite the React package runs, asked the way Flutter asks it.
///
/// A browser test can read a class name off an element; a widget test reads the
/// render tree. So `expect(element).toHaveClass('h-10')` becomes a measurement
/// of the laid-out box, and `--p-fill` becomes the [BoxDecoration] the button
/// actually built. The *questions* are the same questions, which is the point:
/// the two packages are one design language, and a rule that holds in one of
/// them has to hold in the other.

/// A button under a bare [WidgetsApp]-free tree.
///
/// Deliberately no `MaterialApp`: the package does not import Material, so the
/// tests must not either — a suite that passes only inside a `MaterialApp` is
/// not testing what a consumer of this package gets.
Widget host(Widget child, {Brightness brightness = Brightness.light, double? width}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: MediaQueryData(platformBrightness: brightness),
      child: Center(
        child: SizedBox(width: width, child: child),
      ),
    ),
  );
}

/// The box the button laid itself out in.
Size boxOf(WidgetTester tester) => tester.getSize(find.byType(PlButton));

/// The decoration the surface is painted with — the fill, the gradient and the
/// hairline all live here.
///
/// A button builds exactly two `AnimatedContainer`s, and only the outer one
/// carries `boxShadow` — so that is what tells them apart, whether or not the
/// inner one happens to be painting anything. Which is what lets a `ghost`
/// button at rest be asserted about at all.
BoxDecoration surfaceOf(WidgetTester tester) => _decoration(tester, shadowed: false);

/// The outermost box, which is the one carrying the drop shadows.
BoxDecoration shellOf(WidgetTester tester) => _decoration(tester, shadowed: true);

BoxDecoration _decoration(WidgetTester tester, {required bool shadowed}) {
  final container = tester
      .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
      .firstWhere(
        (AnimatedContainer candidate) =>
            ((candidate.decoration! as BoxDecoration).boxShadow != null) == shadowed,
      );

  return container.decoration! as BoxDecoration;
}

void main() {
  group('PlButton', () {
    group('rendering', () {
      testWidgets('renders its child as the label', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlButton(onPressed: () {}, child: const Text('Save'))));

        expect(find.text('Save'), findsOneWidget);
      });

      testWidgets('is a button to the semantics tree, named by its label', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(PlButton(onPressed: () {}, child: const Text('Save'))));

        expect(
          tester.getSemantics(find.byType(PlButton)),
          isSemantics(label: 'Save', isButton: true, isEnabled: true, hasTapAction: true),
        );

        handle.dispose();
      });

      testWidgets('reflects a changed child', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlButton(onPressed: () {}, child: const Text('Before'))));
        await tester.pumpWidget(host(PlButton(onPressed: () {}, child: const Text('After'))));

        expect(find.text('After'), findsOneWidget);
        expect(find.text('Before'), findsNothing);
      });

      testWidgets('names an icon-only button from semanticLabel', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlButton(onPressed: () {}, semanticLabel: 'Add', startIcon: const Icon(IconData(0x2b))),
          ),
        );

        expect(find.bySemanticsLabel('Add'), findsOneWidget);
        handle.dispose();
      });
    });

    group('style props', () {
      testWidgets('fills a solid button with its family gradient', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlButton(onPressed: () {}, color: PlassColor.danger, child: const Text('Delete'))),
        );

        final gradient = surfaceOf(tester).gradient;
        final tokens = PlassTokens.light();

        expect(gradient, isNotNull);
        expect((gradient! as LinearGradient).colors.first, tokens.family(PlassColor.danger).solid);
      });

      testWidgets('defaults to the primary family', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlButton(onPressed: () {}, child: const Text('Save'))));

        expect(
          (surfaceOf(tester).gradient! as LinearGradient).colors.first,
          PlassTokens.light().family(PlassColor.primary).solid,
        );
      });

      testWidgets('sweeps the gradient at 135° in CSS terms, not corner to corner', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(PlButton(onPressed: () {}, child: const Text('Save'))));

        // The gradient survives as the CSS-geometry subclass rather than being
        // flattened into a plain `LinearGradient` by a decoration lerp.
        expect(surfaceOf(tester).gradient, isA<PlassCssGradient>());
      });

      testWidgets('changes height with size but not with density', (WidgetTester tester) async {
        for (final entry in <PlassSize, double>{
          PlassSize.xs: 24,
          PlassSize.sm: 32,
          PlassSize.md: 40,
          PlassSize.lg: 48,
          PlassSize.xl: 56,
        }.entries) {
          await tester.pumpWidget(
            host(PlButton(onPressed: () {}, size: entry.key, child: const Text('Save'))),
          );

          expect(
            boxOf(tester).height,
            entry.value,
            reason: '${entry.key} is ${entry.value}px tall',
          );
        }

        await tester.pumpWidget(
          host(
            PlButton(
              onPressed: () {},
              size: PlassSize.md,
              density: PlassDensity.compact,
              child: const Text('Save'),
            ),
          ),
        );

        expect(boxOf(tester).height, 40);
      });

      testWidgets('changes horizontal padding with density', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlButton(onPressed: () {}, size: PlassSize.lg, child: const Text('Save'))),
        );
        final standard = boxOf(tester).width;

        await tester.pumpWidget(
          host(
            PlButton(
              onPressed: () {},
              size: PlassSize.lg,
              density: PlassDensity.compact,
              child: const Text('Save'),
            ),
          ),
        );

        // 24px each side against 14px each side — a legible difference rather
        // than a two-pixel nudge.
        expect(standard - boxOf(tester).width, 20);
      });

      testWidgets('rests one level off the sheet by default', (WidgetTester tester) async {
        final tokens = PlassTokens.light();

        await tester.pumpWidget(host(PlButton(onPressed: () {}, child: const Text('Save'))));

        // A key rests *on* the sheet, so the default is 1 and not 0.
        expect(shellOf(tester).boxShadow, isNotEmpty);
        expect(shellOf(tester).boxShadow!.first.blurRadius, tokens.elevation(1).first.blurRadius);

        await tester.pumpWidget(
          host(PlButton(onPressed: () {}, elevation: 0, child: const Text('Save'))),
        );
        await tester.pumpAndSettle();

        // Level 0 is flat, so all that is left is the tinted lift.
        expect(shellOf(tester).boxShadow, hasLength(1));
      });

      testWidgets('keeps the tinted lift out of the elevation ladder', (WidgetTester tester) async {
        // The lift says what the surface is made of; elevation says how far off
        // the page it is. A `danger` button one level higher is not a redder
        // piece of glass, so the two do not move together.
        await tester.pumpWidget(host(PlButton(onPressed: () {}, child: const Text('Save'))));
        final atOne = shellOf(tester).boxShadow!.last;

        await tester.pumpWidget(
          host(PlButton(onPressed: () {}, elevation: 3, child: const Text('Save'))),
        );
        await tester.pumpAndSettle();

        expect(shellOf(tester).boxShadow!.last.color, atOne.color);
        expect(shellOf(tester).boxShadow!.last.blurRadius, atOne.blurRadius);
      });

      testWidgets('rejects an elevation off the ladder', (WidgetTester tester) async {
        expect(
          () => PlButton(onPressed: () {}, elevation: 4, child: const Text('Save')),
          throwsAssertionError,
        );
      });

      testWidgets('draws a hairline for the glass variant only', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButton(onPressed: () {}, variant: PlassVariant.glass, child: const Text('Cancel')),
          ),
        );

        expect(surfaceOf(tester).border, isNotNull);
        expect(surfaceOf(tester).gradient, isNull);
        // Glass is the one variant that blurs what is behind it.
        expect(find.byType(BackdropFilter), findsOneWidget);

        await tester.pumpWidget(
          host(
            PlButton(onPressed: () {}, variant: PlassVariant.ghost, child: const Text('Details')),
          ),
        );

        expect(find.byType(BackdropFilter), findsNothing);
      });

      testWidgets('gives a ghost button no surface at rest', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButton(onPressed: () {}, variant: PlassVariant.ghost, child: const Text('Details')),
          ),
        );

        final surface = surfaceOf(tester);

        expect(surface.gradient, isNull);
        expect(surface.color, isNull);
        expect(surface.border, isNull);
        expect(shellOf(tester).boxShadow ?? const <BoxShadow>[], isEmpty);
      });

      testWidgets('stretches to the container when fullWidth is set', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButton(onPressed: () {}, fullWidth: true, child: const Text('Continue')),
            width: 320,
          ),
        );

        expect(boxOf(tester).width, 320);
      });

      testWidgets('renders as a square when there is no label', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButton(onPressed: () {}, semanticLabel: 'Add', startIcon: const Icon(IconData(0x2b))),
          ),
        );

        expect(boxOf(tester), const Size(40, 40));
      });

      testWidgets('never scales or moves the label', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlButton(onPressed: () {}, elevation: 3, child: const Text('Save'))),
        );
        final atRest = tester.getTopLeft(find.text('Save'));

        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: tester.getCenter(find.byType(PlButton)));
        addTearDown(gesture.removePointer);
        await tester.pumpAndSettle();

        // Scaling a key resamples its label, and text that shimmers under the
        // cursor undoes the restraint everything else is spending effort on.
        expect(tester.getTopLeft(find.text('Save')), atRest);
      });
    });

    group('icons', () {
      testWidgets('places startIcon before and endIcon after the label', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlButton(
              onPressed: () {},
              startIcon: const Text('['),
              endIcon: const Text(']'),
              child: const Text('Save'),
            ),
          ),
        );

        expect(
          tester.getCenter(find.text('[')).dx,
          lessThan(tester.getCenter(find.text('Save')).dx),
        );
        expect(
          tester.getCenter(find.text(']')).dx,
          greaterThan(tester.getCenter(find.text('Save')).dx),
        );
      });
    });

    group('states', () {
      testWidgets('fires onPressed when idle', (WidgetTester tester) async {
        var taps = 0;
        await tester.pumpWidget(
          host(PlButton(onPressed: () => taps += 1, child: const Text('Save'))),
        );

        await tester.tap(find.byType(PlButton));

        expect(taps, 1);
      });

      testWidgets('activates from the keyboard', (WidgetTester tester) async {
        var taps = 0;
        await tester.pumpWidget(
          host(PlButton(autofocus: true, onPressed: () => taps += 1, child: const Text('Save'))),
        );
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();

        expect(taps, 1);
      });

      testWidgets('is disabled by a null onPressed, the way Flutter expects', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlButton(child: Text('Save'))));

        expect(
          tester.getSemantics(find.byType(PlButton)),
          isSemantics(isButton: true, isEnabled: false),
        );

        handle.dispose();
      });

      testWidgets('does not fire onPressed when disabled', (WidgetTester tester) async {
        var taps = 0;
        await tester.pumpWidget(
          host(PlButton(disabled: true, onPressed: () => taps += 1, child: const Text('Save'))),
        );

        await tester.tap(find.byType(PlButton));

        expect(taps, 0);
      });

      testWidgets('lets the page through a disabled key rather than greying it', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(PlButton(disabled: true, onPressed: () {}, child: const Text('Save'))),
        );

        final opacity = tester.widget<Opacity>(find.byType(Opacity));

        expect(opacity.opacity, 0.5);
        // It keeps its shape and its colour; what it loses is the light.
        expect(surfaceOf(tester).gradient, isNotNull);
        expect(shellOf(tester).boxShadow ?? const <BoxShadow>[], isEmpty);
      });

      testWidgets('swaps in a spinner while loading', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlButton(
              loading: true,
              onPressed: () {},
              startIcon: const Text('ICON'),
              child: const Text('Save'),
            ),
          ),
        );

        expect(find.byType(PlassSpinner), findsOneWidget);
        expect(find.text('ICON'), findsNothing);
        expect(find.text('Save'), findsOneWidget);
      });

      testWidgets('stays focusable but does not fire while loading', (WidgetTester tester) async {
        var taps = 0;
        final node = FocusNode();
        addTearDown(node.dispose);

        await tester.pumpWidget(
          host(
            PlButton(
              loading: true,
              focusNode: node,
              onPressed: () => taps += 1,
              child: const Text('Save'),
            ),
          ),
        );

        node.requestFocus();
        await tester.pump();

        // Not out of the focus order — dropping out of it costs keyboard users
        // their sense of the page.
        expect(node.hasFocus, isTrue);

        await tester.tap(find.byType(PlButton));

        expect(taps, 0);
      });

      testWidgets('does not fire onPressed when read-only', (WidgetTester tester) async {
        var taps = 0;
        await tester.pumpWidget(
          host(PlButton(readOnly: true, onPressed: () => taps += 1, child: const Text('Save'))),
        );

        await tester.tap(find.byType(PlButton));

        expect(taps, 0);
      });

      testWidgets('keeps its colour but goes flat when read-only', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlButton(elevation: 2, onPressed: () {}, child: const Text('Save'))),
        );

        expect(shellOf(tester).boxShadow, isNotEmpty);

        await tester.pumpWidget(
          host(PlButton(elevation: 2, readOnly: true, onPressed: () {}, child: const Text('Save'))),
        );
        await tester.pumpAndSettle();

        // Still the same family and still the same gradient...
        expect(surfaceOf(tester).gradient, isNotNull);
        // ...but no elevation and no tinted lift.
        expect(shellOf(tester).boxShadow ?? const <BoxShadow>[], isEmpty);
        // And not dimmed: the label is still there to be read, which is the
        // whole difference from `disabled`.
        expect(find.byType(Opacity), findsNothing);
      });

      testWidgets('does not let an unavailable tap reach a parent', (WidgetTester tester) async {
        var parentTaps = 0;

        await tester.pumpWidget(
          host(
            GestureDetector(
              onTap: () => parentTaps += 1,
              child: PlButton(readOnly: true, onPressed: () {}, child: const Text('Save')),
            ),
          ),
        );

        await tester.tap(find.byType(PlButton));

        expect(parentTaps, 0);
      });
    });

    group('theme', () {
      testWidgets('follows the platform brightness with no theme in the tree', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlButton(onPressed: () {}, variant: PlassVariant.glass, child: const Text('Cancel')),
            brightness: Brightness.dark,
          ),
        );

        expect(surfaceOf(tester).color, PlassTokens.dark().glass);
      });

      testWidgets('is pinned by an ancestor PlassTheme', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlassTheme(
              brightness: Brightness.dark,
              child: PlButton(
                onPressed: () {},
                variant: PlassVariant.glass,
                child: const Text('Cancel'),
              ),
            ),
          ),
        );

        expect(surfaceOf(tester).color, PlassTokens.dark().glass);
      });

      testWidgets('does not move a key\'s own colour between themes', (WidgetTester tester) async {
        // The one place Plass departs hardest from the libraries it was learned
        // from: what changes with the theme is the sheet a key rests on, not
        // the key.
        expect(
          PlassTokens.light().family(PlassColor.primary).solid,
          PlassTokens.dark().family(PlassColor.primary).solid,
        );
        expect(
          PlassTokens.light().family(PlassColor.primary).accent,
          isNot(PlassTokens.dark().family(PlassColor.primary).accent),
        );
      });
    });
  });
}
