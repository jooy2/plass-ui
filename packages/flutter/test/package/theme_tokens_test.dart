// That an app can bring its own colours, glass and chart palette into the
// library.
//
// A test of a *contract* rather than of a widget, which is why it is here
// rather than under `test/components/`. What it asserts is that a set built
// with `copyWith` reaches the widgets that read it, that it compares equal to
// an identical set so a rebuild with the same values is not a rebuild of
// everything under the theme, and that the scales the library keeps `static
// const` are not quietly per-theme.
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/host.dart';

/// A family nothing in the library ships, so a widget drawing in it can only
/// have read the set under test.
PlassColorFamily brand(PlassTokens tokens) {
  return tokens
      .family(PlassColor.primary)
      .copyWith(
        solid: const Color(0xFF7C3AED),
        solidTo: const Color(0xFF9333EA),
        accent: const Color(0xFF6D28D9),
      );
}

void main() {
  group('PlassColorFamily.copyWith', () {
    test('keeps every value it was not given', () {
      final PlassColorFamily base = PlassTokens.light().family(PlassColor.primary);
      final PlassColorFamily moved = base.copyWith(solid: const Color(0xFF7C3AED));

      expect(moved.solid, const Color(0xFF7C3AED));
      expect(moved.solidTo, base.solidTo);
      expect(moved.onSolid, base.onSolid);
      expect(moved.accent, base.accent);
      expect(moved.tintStrength, base.tintStrength);
      expect(moved.softSteps, base.softSteps);
    });

    test('derives the whole family from the values it was given', () {
      // The point of replacing `solid` at all: the fill, the washes and the
      // tint are computed from it, so moving the base moves all of them.
      final PlassColorFamily base = PlassTokens.light().family(PlassColor.primary);
      final PlassColorFamily moved = brand(PlassTokens.light());

      expect(moved.tint, isNot(base.tint));
      expect(moved.soft, isNot(base.soft));
      expect(moved.ring, const Color(0xFF6D28D9));
    });
  });

  group('PlassTokens.copyWith', () {
    test('keeps every value it was not given', () {
      final PlassTokens base = PlassTokens.light();
      final PlassTokens quiet = base.copyWith(blurSigma: 8);

      expect(quiet.blurSigma, 8);
      expect(quiet.brightness, base.brightness);
      expect(quiet.surface, base.surface);
      expect(quiet.families, base.families);
      expect(quiet.chart, base.chart);
    });

    test('replaces one family and keeps the other five', () {
      final PlassTokens base = PlassTokens.light();
      final PlassTokens branded = base.withFamily(PlassColor.primary, brand(base));

      expect(branded.family(PlassColor.primary).solid, const Color(0xFF7C3AED));
      for (final PlassColor color in PlassColor.values.where(
        (PlassColor color) => color != PlassColor.primary,
      )) {
        expect(branded.family(color), base.family(color));
      }
    });

    test('compares equal to a set built the same way, so a theme does not renotify', () {
      // `PlassTheme.updateShouldNotify` compares the two sets. Without value
      // equality, an app that builds its tokens in `build` would rebuild its
      // whole subtree on every frame.
      final PlassTokens one = PlassTokens.light().withFamily(
        PlassColor.primary,
        brand(PlassTokens.light()),
      );
      final PlassTokens two = PlassTokens.light().withFamily(
        PlassColor.primary,
        brand(PlassTokens.light()),
      );

      expect(one, two);
      expect(one.hashCode, two.hashCode);
      expect(one, isNot(PlassTokens.light()));
    });
  });

  testWidgets('a brand family reaches the widget that draws in it', (WidgetTester tester) async {
    final PlassTokens base = PlassTokens.light();

    await tester.pumpWidget(
      host(
        PlassTheme.tokens(
          tokens: base.withFamily(PlassColor.primary, brand(base)),
          child: const PlButton(child: Text('Save')),
        ),
      ),
    );

    final BuildContext context = tester.element(find.byType(PlButton));

    expect(PlassTheme.of(context).family(PlassColor.primary).solid, const Color(0xFF7C3AED));
  });

  testWidgets('a set scoped to a subtree reaches the layers that subtree lifts', (
    WidgetTester tester,
  ) async {
    // The one place the two packages differ: a React popup is portalled to the
    // end of `<body>` and leaves a scoped override behind, while a Flutter one
    // is an `OverlayPortal` child, which stays under the widget that opened it
    // and reads the theme around it. Worth a test rather than a sentence,
    // because it is a property of the framework this library builds on.
    final PlassTokens base = PlassTokens.light();

    await tester.pumpWidget(
      host(
        PlassTheme.tokens(
          tokens: base.withFamily(PlassColor.primary, brand(base)),
          child: PlTooltip(
            content: const Text('Hi'),
            child: const PlButton(child: Text('Save')),
          ),
        ),
        overlay: true,
      ),
    );

    final TestGesture pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);

    await pointer.addPointer(location: Offset.zero);
    addTearDown(pointer.removePointer);
    await pointer.moveTo(tester.getCenter(find.text('Save')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final BuildContext inside = tester.element(find.text('Hi'));

    expect(PlassTheme.of(inside).family(PlassColor.primary).solid, const Color(0xFF7C3AED));
  });

  testWidgets('a scale the library keeps static stays the same under any set', (
    WidgetTester tester,
  ) async {
    // `radius`, `duration` and `ease` are read as statics in the components, so
    // a token set cannot carry its own. Said out loud here, because the day
    // they move onto the set this test is what points at the call sites.
    await tester.pumpWidget(
      host(
        PlassTheme.tokens(
          tokens: PlassTokens.light().copyWith(blurSigma: 8),
          child: const PlButton(child: Text('Save')),
        ),
      ),
    );

    expect(PlassTokens.radius[PlassSize.md], 12);
    expect(PlassTokens.duration, const Duration(milliseconds: 150));
  });
}
