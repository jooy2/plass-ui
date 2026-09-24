// That an app can bring its own colours, glass, chart palette, corners and
// motion into the library.
//
// A test of a *contract* rather than of a widget, which is why it is here
// rather than under `test/components/`. What it asserts is that a set built
// with `copyWith` reaches the widgets that read it, that it compares equal to
// an identical set so a rebuild with the same values is not a rebuild of
// everything under the theme, and that no component reads the radius, the
// motion or a field's light as a static the theme cannot reach.
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/glow.dart';

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

  group('the scales', () {
    test('start from the statics in both shipped sets', () {
      for (final PlassTokens tokens in <PlassTokens>[PlassTokens.light(), PlassTokens.dark()]) {
        expect(tokens.radii, PlassTokens.radius);
        expect(tokens.motionDuration, PlassTokens.duration);
        expect(tokens.motionDurationSlow, PlassTokens.durationSlow);
        expect(tokens.motionEase, same(PlassTokens.ease));
        expect(tokens.fieldGlowStrength, PlassTokens.glowFieldStrength);
      }

      // And the statics are still the numbers they were, because they are
      // public and an app may be reading them.
      expect(PlassTokens.radius[PlassSize.md], 12);
      expect(PlassTokens.duration, const Duration(milliseconds: 150));
      expect(PlassTokens.durationSlow, const Duration(milliseconds: 260));
      expect(PlassTokens.glowFieldStrength, 55);
    });

    test('move through copyWith and keep what they were not given', () {
      final PlassTokens base = PlassTokens.light();
      final PlassTokens moved = base.copyWith(
        radii: _squareRadii,
        motionEase: Curves.linear,
        fieldGlowStrength: 30,
      );

      expect(moved.radii, _squareRadii);
      expect(moved.motionEase, Curves.linear);
      expect(moved.fieldGlowStrength, 30);
      expect(moved.motionDuration, base.motionDuration);
      expect(moved.motionDurationSlow, base.motionDurationSlow);
      expect(base.copyWith(blurSigma: 8).radii, base.radii);
      expect(base.copyWith(blurSigma: 8).fieldGlowStrength, base.fieldGlowStrength);
    });

    test('take part in equality, so a theme that moves one renotifies', () {
      expect(PlassTokens.light().copyWith(radii: _squareRadii), isNot(PlassTokens.light()));
      expect(
        PlassTokens.light().copyWith(motionDuration: const Duration(seconds: 1)),
        isNot(PlassTokens.light()),
      );
      expect(PlassTokens.light().copyWith(fieldGlowStrength: 30), isNot(PlassTokens.light()));
      expect(
        PlassTokens.light().copyWith(fieldGlowStrength: 30).hashCode,
        PlassTokens.light().copyWith(fieldGlowStrength: 30).hashCode,
      );
      expect(
        PlassTokens.light().copyWith(radii: Map<PlassSize, double>.of(_squareRadii)),
        PlassTokens.light().copyWith(radii: _squareRadii),
      );
      expect(
        PlassTokens.light().copyWith(radii: Map<PlassSize, double>.of(_squareRadii)).hashCode,
        PlassTokens.light().copyWith(radii: _squareRadii).hashCode,
      );
    });

    test('refuse a radius ladder that leaves a size out', () {
      expect(
        () => PlassTokens.light().copyWith(radii: const <PlassSize, double>{PlassSize.md: 4}),
        throwsAssertionError,
      );
    });

    test('refuse a field light strength outside a percentage', () {
      expect(() => PlassTokens.light().copyWith(fieldGlowStrength: 120), throwsAssertionError);
      expect(() => PlassTokens.light().copyWith(fieldGlowStrength: -1), throwsAssertionError);
    });

    testWidgets("light a field at the theme's strength", (WidgetTester tester) async {
      // What `--plass-glow-field-strength` does on a page: the field's bloom is
      // the family's wash mixed down to it.
      final PlassTokens full = PlassTokens.light().copyWith(fieldGlowStrength: 100);
      final PlassColorFamily primary = full.family(PlassColor.primary);

      await tester.pumpWidget(
        host(
          PlassTheme.tokens(tokens: full, child: const PlTextField(fullWidth: true)),
          width: 240,
        ),
      );

      final PlassGlowLayer bloom = tester
          .widgetList<PlassGlowLayer>(
            find.descendant(of: find.byType(PlTextField), matching: find.byType(PlassGlowLayer)),
          )
          .first;

      expect(bloom.color, full.fieldGlow(primary));
      expect(bloom.color, isNot(PlassTokens.light().fieldGlow(primary)));
    });

    testWidgets("reach a button's, a field's and a card's corners", (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlassTheme.tokens(
            tokens: _slowSquare,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                PlButton(onPressed: () {}, child: const Text('Save')),
                const SizedBox(width: 240, child: PlTextField(fullWidth: true)),
                const PlCard(child: Text('Plan')),
              ],
            ),
          ),
          width: 400,
        ),
      );

      final BorderRadius md = BorderRadius.circular(_squareRadii[PlassSize.md]!);

      expect(_cornersOf(tester, find.byType(PlButton)), <BorderRadius>{md});
      expect(_cornersOf(tester, find.byType(PlTextField)), <BorderRadius>{md});
      expect(_cornersOf(tester, find.byType(PlCard)), <BorderRadius>{md});
    });

    testWidgets('leave those corners where they were without a theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              PlButton(onPressed: () {}, child: const Text('Save')),
              const PlCard(child: Text('Plan')),
            ],
          ),
          width: 400,
        ),
      );

      final BorderRadius md = BorderRadius.circular(12);

      expect(_cornersOf(tester, find.byType(PlButton)), <BorderRadius>{md});
      expect(_cornersOf(tester, find.byType(PlCard)), <BorderRadius>{md});
    });

    testWidgets("fold an accordion on the theme's slow duration and curve", (
      WidgetTester tester,
    ) async {
      Widget accordion(Set<String> value) {
        return host(
          PlassTheme.tokens(
            tokens: _slowSquare,
            child: PlAccordion<String>(
              items: _sections,
              value: value,
              onChanged: (Set<String> _) {},
            ),
          ),
          width: 400,
        );
      }

      await tester.pumpWidget(accordion(const <String>{}));
      final double closed = _heightOf(tester, find.byType(PlAccordion<String>));

      await tester.pumpWidget(accordion(const <String>{'billing'}));
      await tester.pumpAndSettle();
      final double open = _heightOf(tester, find.byType(PlAccordion<String>));

      await tester.pumpWidget(accordion(const <String>{}));
      await tester.pump(_slow ~/ 2);

      // Half the time on a linear curve is half the travel. The house duration
      // would have finished long before, and the house curve would be most of
      // the way there.
      expect(_heightOf(tester, find.byType(PlAccordion<String>)), closeTo((open + closed) / 2, 1));
    });

    testWidgets('take a theme that changes under an accordion already built', (
      WidgetTester tester,
    ) async {
      // The same tree shape both times, so the section keeps its state and its
      // controller: what is under test is the controller being handed the new
      // duration, not a fresh one being made with it.
      Widget accordion(PlassTokens tokens, Set<String> value) {
        return host(
          PlassTheme.tokens(
            tokens: tokens,
            child: PlAccordion<String>(
              items: _sections,
              value: value,
              onChanged: (Set<String> _) {},
            ),
          ),
          width: 400,
        );
      }

      await tester.pumpWidget(accordion(PlassTokens.light(), const <String>{'billing'}));
      await tester.pumpAndSettle();
      final double open = _heightOf(tester, find.byType(PlAccordion<String>));
      final State section = tester.state(
        find.ancestor(of: find.text('Card on file'), matching: find.byWidgetPredicate(_isSection)),
      );

      await tester.pumpWidget(accordion(_slowSquare, const <String>{'billing'}));
      await tester.pumpWidget(accordion(_slowSquare, const <String>{}));
      await tester.pump(_slow ~/ 2);

      expect(
        tester.state(
          find.ancestor(
            of: find.text('Card on file'),
            matching: find.byWidgetPredicate(_isSection),
          ),
        ),
        same(section),
      );
      final double halfway = _heightOf(tester, find.byType(PlAccordion<String>));

      await tester.pumpAndSettle();
      final double closed = _heightOf(tester, find.byType(PlAccordion<String>));

      expect(halfway, closeTo((open + closed) / 2, 1));

      // And in one frame: the theme and `open` changing together.
      await tester.pumpWidget(accordion(PlassTokens.light(), const <String>{}));
      await tester.pumpWidget(accordion(_slowSquare, const <String>{'billing'}));
      await tester.pump(_slow ~/ 2);

      expect(_heightOf(tester, find.byType(PlAccordion<String>)), closeTo((open + closed) / 2, 1));
    });

    testWidgets("open a pill's details on the theme's slow duration and curve", (
      WidgetTester tester,
    ) async {
      Widget pill({required bool expanded}) {
        return host(
          PlassTheme.tokens(
            tokens: _slowSquare,
            child: PlPill(
              title: const Text('Two updates'),
              details: const Text('Billing moved.'),
              expanded: expanded,
            ),
          ),
          width: 320,
        );
      }

      await tester.pumpWidget(pill(expanded: false));
      await tester.pumpAndSettle();
      final double closed = _heightOf(tester, find.byType(PlPill));

      await tester.pumpWidget(pill(expanded: true));
      await tester.pumpAndSettle();
      final double open = _heightOf(tester, find.byType(PlPill));

      await tester.pumpWidget(pill(expanded: false));
      await tester.pumpAndSettle();
      await tester.pumpWidget(pill(expanded: true));
      await tester.pump(_slow ~/ 2);

      expect(_heightOf(tester, find.byType(PlPill)), closeTo((open + closed) / 2, 1));
    });

    testWidgets("fade a popover in on the theme's duration", (WidgetTester tester) async {
      Widget popover({required bool open}) {
        return host(
          PlassTheme.tokens(
            tokens: _slowSquare,
            child: PlPopover(
              open: open,
              trigger: PlButton(onPressed: () {}, child: const Text('Explain')),
              child: const Text('The base rate'),
            ),
          ),
          overlay: true,
        );
      }

      await tester.pumpWidget(popover(open: false));
      await tester.pumpWidget(popover(open: true));
      // The popup goes up once the frame that asked for it is over, and its
      // fade starts on the frame after.
      await tester.pump();
      await tester.pump(_fast ~/ 2);

      expect(_opacityOver(tester, find.text('The base rate')), closeTo(0.5, 0.02));
    });

    testWidgets("fade a modal in on the theme's slow duration", (WidgetTester tester) async {
      Widget modal({required bool open}) {
        return host(
          PlassTheme.tokens(
            tokens: _slowSquare,
            child: PlModal(open: open, title: const Text('Settings')),
          ),
          overlay: true,
        );
      }

      await tester.pumpWidget(modal(open: false));
      await tester.pumpWidget(modal(open: true));
      await tester.pump();
      await tester.pump(_slow ~/ 2);

      expect(_opacityOver(tester, find.text('Settings')), closeTo(0.5, 0.02));
    });

    testWidgets("fade a popover in on the theme's curve", (WidgetTester tester) async {
      Widget popover({required bool open}) {
        return host(
          PlassTheme.tokens(
            tokens: _slowSteep,
            child: PlPopover(
              open: open,
              trigger: PlButton(onPressed: () {}, child: const Text('Explain')),
              child: const Text('The base rate'),
            ),
          ),
          overlay: true,
        );
      }

      await tester.pumpWidget(popover(open: false));
      await tester.pumpWidget(popover(open: true));
      await tester.pump();
      await tester.pump(_fast ~/ 2);

      // Half the time on the steep curve is an eighth of the way in. A fade
      // that ignored the curve would be half the way in.
      expect(
        _opacityOver(tester, find.text('The base rate')),
        closeTo(_steep.transform(0.5), 0.02),
      );
    });

    testWidgets("fade a modal in on a theme's curve that changes as it opens", (
      WidgetTester tester,
    ) async {
      // The theme and `open` change in one frame, so the layer's fade has to be
      // handed the new curve by the build that opens it, not by one before.
      Widget modal(PlassTokens tokens, {required bool open}) {
        return host(
          PlassTheme.tokens(
            tokens: tokens,
            child: PlModal(open: open, title: const Text('Settings')),
          ),
          overlay: true,
        );
      }

      await tester.pumpWidget(modal(_slowSquare, open: false));
      await tester.pumpWidget(modal(_slowSteep, open: true));
      await tester.pump();
      await tester.pump(_slow ~/ 2);

      expect(_opacityOver(tester, find.text('Settings')), closeTo(_steep.transform(0.5), 0.02));
    });

    // A close that eases the way a CSS transition does runs the curve forwards
    // in time, so half the time into it on the steep curve is an eighth of the
    // way shut, as the open was an eighth of the way open at the same moment.
    // The curve read backwards would be seven eighths of the way shut.
    testWidgets("fold an accordion shut on the theme's curve run forwards", (
      WidgetTester tester,
    ) async {
      final double shut = await _shutHalfway(
        tester,
        ({required bool open}) => PlAccordion<String>(
          items: _sections,
          value: open ? const <String>{'billing'} : const <String>{},
          onChanged: (Set<String> _) {},
        ),
        find.byType(PlAccordion<String>),
      );

      expect(shut, closeTo(_steep.transform(0.5), 0.02));
    });

    testWidgets("fold a collapsible shut on the theme's curve run forwards", (
      WidgetTester tester,
    ) async {
      final double shut = await _shutHalfway(
        tester,
        ({required bool open}) => PlCollapsible(
          open: open,
          title: const Text('Billing'),
          child: const Text('Card on file'),
        ),
        find.byType(PlCollapsible),
      );

      expect(shut, closeTo(_steep.transform(0.5), 0.02));
    });

    testWidgets("fold a pill's details shut on the theme's curve run forwards", (
      WidgetTester tester,
    ) async {
      final double shut = await _shutHalfway(
        tester,
        ({required bool open}) => PlPill(
          title: const Text('Two updates'),
          details: const Text('Billing moved.'),
          expanded: open,
        ),
        find.byType(PlPill),
      );

      expect(shut, closeTo(_steep.transform(0.5), 0.02));
    });

    testWidgets("fold a tree branch shut on the theme's curve run forwards", (
      WidgetTester tester,
    ) async {
      final double shut = await _shutHalfway(
        tester,
        ({required bool open}) => PlTree(
          items: const <PlTreeNode>[
            PlTreeNode(
              id: 'src',
              label: Text('src'),
              children: <PlTreeNode>[PlTreeNode(id: 'index', label: Text('index.ts'))],
            ),
          ],
          expanded: open ? const <String>{'src'} : const <String>{},
        ),
        find.byType(PlTree),
      );

      expect(shut, closeTo(_steep.transform(0.5), 0.02));
    });

    testWidgets("fade a popover out on the theme's curve run forwards", (
      WidgetTester tester,
    ) async {
      Widget popover({required bool open}) {
        return host(
          PlassTheme.tokens(
            tokens: _slowSteep,
            child: PlPopover(
              open: open,
              trigger: PlButton(onPressed: () {}, child: const Text('Explain')),
              child: const Text('The base rate'),
            ),
          ),
          overlay: true,
        );
      }

      await tester.pumpWidget(popover(open: false));
      await tester.pumpWidget(popover(open: true));
      await tester.pumpAndSettle();
      await tester.pumpWidget(popover(open: false));
      await tester.pump(_fast ~/ 2);

      expect(
        _opacityOver(tester, find.text('The base rate')),
        closeTo(1 - _steep.transform(0.5), 0.02),
      );
    });

    testWidgets("fade a modal out on the theme's curve run forwards", (WidgetTester tester) async {
      Widget modal({required bool open}) {
        return host(
          PlassTheme.tokens(
            tokens: _slowSteep,
            child: PlModal(open: open, title: const Text('Settings')),
          ),
          overlay: true,
        );
      }

      await tester.pumpWidget(modal(open: false));
      await tester.pumpWidget(modal(open: true));
      await tester.pumpAndSettle();
      await tester.pumpWidget(modal(open: false));
      await tester.pump(_slow ~/ 2);

      expect(_opacityOver(tester, find.text('Settings')), closeTo(1 - _steep.transform(0.5), 0.02));
    });

    // The theme and `open` change in one frame, so the fade out has to be
    // handed the new duration before it starts rather than by the build after
    // it, which is too late for a fade already running.
    testWidgets("fade a popover out on a theme's duration that changes as it closes", (
      WidgetTester tester,
    ) async {
      Widget popover(PlassTokens tokens, {required bool open}) {
        return host(
          PlassTheme.tokens(
            tokens: tokens,
            child: PlPopover(
              open: open,
              trigger: PlButton(onPressed: () {}, child: const Text('Explain')),
              child: const Text('The base rate'),
            ),
          ),
          overlay: true,
        );
      }

      await tester.pumpWidget(popover(PlassTokens.light(), open: false));
      await tester.pumpWidget(popover(PlassTokens.light(), open: true));
      await tester.pumpAndSettle();
      await tester.pumpWidget(popover(_slowSquare, open: false));
      await tester.pump(_fast ~/ 2);

      // The house duration would have finished long before and taken it down.
      expect(find.text('The base rate'), findsOneWidget);
      expect(_opacityOver(tester, find.text('The base rate')), closeTo(0.5, 0.02));
    });

    testWidgets("fade a modal out on a theme's slow duration that changes as it closes", (
      WidgetTester tester,
    ) async {
      Widget modal(PlassTokens tokens, {required bool open}) {
        return host(
          PlassTheme.tokens(
            tokens: tokens,
            child: PlModal(open: open, title: const Text('Settings')),
          ),
          overlay: true,
        );
      }

      await tester.pumpWidget(modal(PlassTokens.light(), open: false));
      await tester.pumpWidget(modal(PlassTokens.light(), open: true));
      await tester.pumpAndSettle();
      await tester.pumpWidget(modal(_slowSquare, open: false));
      await tester.pump(_slow ~/ 2);

      expect(find.text('Settings'), findsOneWidget);
      expect(_opacityOver(tester, find.text('Settings')), closeTo(0.5, 0.02));
    });
  });

  group('every component reads the scales off the set', () {
    // The half that catches the next component. A static read compiles, runs
    // and looks right, and is a corner or a duration no theme can reach.
    final List<File> sources = Directory('lib/src')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.path.endsWith('.dart'))
        .toList(growable: false);

    /// Comments out, since the docs are allowed to name the defaults.
    String code(String source) {
      return source
          .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
          .replaceAll(RegExp(r'^\s*///?.*$', multiLine: true), '');
    }

    final RegExp static = RegExp(
      r'PlassTokens\.(?:radius|duration|durationSlow|ease|glowFieldStrength)\b',
    );

    test('lib/src is not empty (the scan below would pass vacuously)', () {
      expect(sources.length, greaterThan(40));
    });

    test('nothing outside the token file reads a scale the theme can move as a static', () {
      final List<String> offenders = <String>[
        for (final File file in sources)
          if (!file.path.replaceAll(r'\', '/').endsWith('lib/src/theme/tokens.dart') &&
              static.hasMatch(code(file.readAsStringSync())))
            file.path,
      ];

      expect(
        offenders,
        isEmpty,
        reason:
            'Read radii, motionDuration, motionDurationSlow, motionEase and '
            'fieldGlowStrength off PlassTheme.of(context), so an app that moves '
            'them moves this too.',
      );
    });
  });
}

/// A radius ladder nothing in the library ships, so a corner drawn with it can
/// only have come from the set under test.
const Map<PlassSize, double> _squareRadii = <PlassSize, double>{
  PlassSize.xs: 3,
  PlassSize.sm: 4,
  PlassSize.md: 5,
  PlassSize.lg: 6,
  PlassSize.xl: 7,
};

const Duration _fast = Duration(milliseconds: 1000);
const Duration _slow = Duration(milliseconds: 2000);

/// Square corners, slow motion and a linear curve, which is what makes a
/// half-way measurement exact.
final PlassTokens _slowSquare = PlassTokens.light().copyWith(
  radii: _squareRadii,
  motionDuration: _fast,
  motionDurationSlow: _slow,
  motionEase: Curves.linear,
);

/// A curve that is far from both the linear one and the house one half way
/// through, so a fade measured there can only have run on it.
const Curve _steep = Curves.easeInCubic;

/// [_slowSquare] on [_steep].
final PlassTokens _slowSteep = _slowSquare.copyWith(motionEase: _steep);

const List<PlAccordionItem<String>> _sections = <PlAccordionItem<String>>[
  PlAccordionItem<String>(value: 'billing', title: Text('Billing'), child: Text('Card on file')),
];

/// Every corner a surface under [finder] was drawn with.
Set<BorderRadius> _cornersOf(WidgetTester tester, Finder finder) {
  return <BorderRadius>{
    for (final BoxDecoration decoration in decorationsOf(tester, finder))
      if (decoration.borderRadius case final BorderRadius radius) radius,
  };
}

double _heightOf(WidgetTester tester, Finder finder) => tester.getSize(finder).height;

/// The opacity of the nearest fade over [finder].
double _opacityOver(WidgetTester tester, Finder finder) {
  return tester
      .widgetList<FadeTransition>(find.ancestor(of: finder, matching: find.byType(FadeTransition)))
      .first
      .opacity
      .value;
}

/// How far the fold [build] draws has shut half way through its close, as a
/// share of the way from open to shut, measured by the height of [finder].
///
/// It opens on the linear set and is handed the steep one while it is open, so
/// the curve it shuts on is one a theme change brought to a fold already on
/// screen.
Future<double> _shutHalfway(
  WidgetTester tester,
  Widget Function({required bool open}) build,
  Finder finder,
) async {
  Widget fold(PlassTokens tokens, {required bool open}) {
    return host(
      PlassTheme.tokens(
        tokens: tokens,
        child: build(open: open),
      ),
      width: 400,
    );
  }

  await tester.pumpWidget(fold(_slowSquare, open: false));
  final double closed = _heightOf(tester, finder);

  await tester.pumpWidget(fold(_slowSquare, open: true));
  await tester.pumpAndSettle();
  final double open = _heightOf(tester, finder);

  await tester.pumpWidget(fold(_slowSteep, open: true));
  await tester.pumpWidget(fold(_slowSteep, open: false));
  await tester.pump(_slow ~/ 2);

  return (open - _heightOf(tester, finder)) / (open - closed);
}

/// The private state that owns one accordion section's fold, found by its
/// runtime type's name because it is not exported.
bool _isSection(Widget widget) => widget.runtimeType.toString().startsWith('_Section');
