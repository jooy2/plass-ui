/// That the layers and the filters a surface wears for its state leave what it
/// holds alone.
///
/// A hover and a press change how bright a lit surface is, and `readOnly` and
/// `disabled` how drained and how faint, whether a glass surface has its gloss
/// and whether it takes the light, and nothing else about it. A layer or a
/// filter that came and went with them would change the shape of the tree above
/// the content, and Flutter builds a changed shape from scratch, so what is
/// checked here is the content's own state, kept across all four.
library;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/css.dart';
import 'package:plass_ui/src/internal/glow.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';

import '../support/host.dart';

/// Content with a `State` of its own: rebuilt from scratch, it is a different
/// object, where a field would have lost what was typed into it.
class _Probe extends StatefulWidget {
  const _Probe();

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => const Text('Content');
}

void main() {
  group('PlassSurfaceBox', () {
    testWidgets('keeps what it holds as its gloss and its light come and go', (
      WidgetTester tester,
    ) async {
      // What `readOnly` and `disabled` do to a glass field: the gloss goes, and
      // the bloom and the flash are put out.
      Widget box({required bool available}) {
        final PlassTokens tokens = PlassTokens.light();

        return host(
          SizedBox(
            width: 200,
            height: 40,
            child: PlassSurfaceBox(
              surface: PlassSurface(
                fill: tokens.glass,
                ink: tokens.fg,
                blur: true,
                insets: <PlassInsetShadow>[if (available) tokens.glossGlass],
              ),
              borderRadius: BorderRadius.circular(12),
              glow: available ? const Color(0x33FFFFFF) : null,
              flash: available ? const Color(0x66FFFFFF) : null,
              child: const _Probe(),
            ),
          ),
        );
      }

      await tester.pumpWidget(box(available: true));
      final State<_Probe> resting = tester.state(find.byType(_Probe));

      for (final (String reason, bool available) in <(String, bool)>[
        ('unavailable', false),
        ('available again', true),
      ]) {
        await tester.pumpWidget(box(available: available));
        await tester.pumpAndSettle();

        expect(tester.state(find.byType(_Probe)), same(resting), reason: reason);
        expect(
          find.byType(PlassGlowLayer),
          available ? findsNWidgets(2) : findsNothing,
          reason: reason,
        );
      }
    });
  });

  group('plassStateFilter', () {
    Widget lit({bool hovered = false, bool pressed = false}) {
      return host(plassStateFilter(hovered: hovered, pressed: pressed, child: const _Probe()));
    }

    testWidgets('keeps what a lit surface holds across a hover and a press', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(lit());
      final State<_Probe> resting = tester.state(find.byType(_Probe));

      for (final Widget next in <Widget>[
        lit(hovered: true),
        lit(hovered: true, pressed: true),
        lit(hovered: true),
        lit(),
      ]) {
        await tester.pumpWidget(next);
        await tester.pumpAndSettle();

        expect(tester.state(find.byType(_Probe)), same(resting));
      }
    });

    testWidgets('adds a filter layer only while it has a brightness to apply', (
      WidgetTester tester,
    ) async {
      // In the tree at rest, but painting straight through: a layer applying a
      // brightness of 1 would be one more layer on every control for nothing.
      Iterable<ColorFilterLayer> filters() => tester.layers.whereType<ColorFilterLayer>();

      await tester.pumpWidget(lit());

      expect(filters(), isEmpty, reason: 'at rest');

      await tester.pumpWidget(lit(hovered: true));
      await tester.pumpAndSettle();

      expect(filters(), hasLength(1), reason: 'hovered');

      await tester.pumpWidget(lit(hovered: true, pressed: true));
      await tester.pumpAndSettle();

      expect(filters(), hasLength(1), reason: 'pressed');

      await tester.pumpWidget(lit());
      await tester.pumpAndSettle();

      expect(filters(), isEmpty, reason: 'at rest again');
    });

    for (final bool isLit in <bool>[true, false]) {
      final String name = isLit ? 'a lit' : 'an unlit';

      Widget surface({bool disabled = false, bool readOnly = false, bool hovered = false}) {
        return host(
          plassStateFilter(
            disabled: disabled,
            readOnly: readOnly,
            hovered: hovered,
            lit: isLit,
            child: const _Probe(),
          ),
        );
      }

      testWidgets('keeps what $name surface holds as it is made read-only and disabled', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(surface(hovered: true));
        final State<_Probe> resting = tester.state(find.byType(_Probe));

        for (final (String reason, Widget next) in <(String, Widget)>[
          ('read-only', surface(readOnly: true, hovered: true)),
          ('writable again', surface(hovered: true)),
          ('disabled', surface(disabled: true, hovered: true)),
          ('enabled again', surface(hovered: true)),
          ('at rest', surface()),
        ]) {
          await tester.pumpWidget(next);
          await tester.pumpAndSettle();

          expect(tester.state(find.byType(_Probe)), same(resting), reason: reason);
        }
      });

      testWidgets('adds a layer to $name surface only for what its state applies', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(surface(disabled: true));

        // Dimmed over its drained colours, as CSS applies `opacity` after
        // `filter`.
        final OpacityLayer dim = tester.layers.whereType<OpacityLayer>().single;

        expect(dim.alpha, Color.getAlphaFromOpacity(disabledOpacity));
        expect(
          (dim.firstChild! as ColorFilterLayer).colorFilter,
          saturationFilter(disabledSaturation),
        );
        expect(tester.layers.whereType<ColorFilterLayer>(), hasLength(1));

        await tester.pumpWidget(surface(readOnly: true));
        await tester.pumpAndSettle();

        expect(tester.layers.whereType<OpacityLayer>(), isEmpty, reason: 'read-only');
        expect(
          tester.layers.whereType<ColorFilterLayer>().single.colorFilter,
          saturationFilter(readOnlySaturation),
        );

        await tester.pumpWidget(surface());
        await tester.pumpAndSettle();

        // An opacity of 1 and no filter are nothing to apply, and a layer
        // applying them would be one more on every control for nothing.
        expect(tester.layers.whereType<OpacityLayer>(), isEmpty, reason: 'available');
        expect(tester.layers.whereType<ColorFilterLayer>(), isEmpty, reason: 'available');
      });
    }
  });
}
