import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';

import '../../support/host.dart';

/// A glyph drawn in the ambient colour, recording the colour it is handed.
class _Glyph extends StatelessWidget {
  const _Glyph();

  static Color? seen;

  @override
  Widget build(BuildContext context) {
    seen = IconTheme.of(context).color;

    return const SizedBox.square(dimension: 16);
  }
}

/// A mark that is wider than it is tall, which is what a wordmark is.
class _Mark extends StatelessWidget {
  const _Mark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 96, height: 24);
  }
}

/// Content with a `State` of its own: built again from scratch, it is a
/// different object, where a picture would have been decoded again.
class _Probe extends StatefulWidget {
  const _Probe(this.text);

  final String text;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => Text(widget.text);
}

/// Whether the focus is on something inside the logo.
bool _holdsFocus(WidgetTester tester) {
  final BuildContext? focused = FocusManager.instance.primaryFocus?.context;

  return focused != null &&
      find
          .descendant(
            of: find.byType(PlAppLogo),
            matching: find.byElementPredicate((Element element) => element == focused),
          )
          .evaluate()
          .isNotEmpty;
}

/// Moves the focus to [before] and presses Tab once, as a keyboard reader
/// arriving at the logo does.
Future<void> _tabFrom(WidgetTester tester, FocusNode before) async {
  before.requestFocus();
  await tester.pump();
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pump();
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  // No width on the host: a tight constraint from outside would answer the
  // question these tests are asking, which is what the logo sizes itself to.
  await tester.pumpWidget(host(child));
  await tester.pumpAndSettle();
}

void main() {
  group('PlAppLogo', () {
    group('the framing', () {
      testWidgets('draws the artwork as it was given', (WidgetTester tester) async {
        await _pump(tester, const PlAppLogo(semanticLabel: 'Acme', child: _Mark()));

        // A height and no width: cropping a wordmark to a square is the failure
        // this widget is here to avoid.
        final Size laid = tester.getSize(find.byType(PlAppLogo));

        expect(laid.height, 32);
        expect(laid.width, greaterThan(laid.height));
      });

      testWidgets('puts it on a square tile when it was asked to', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlAppLogo(semanticLabel: 'Acme', shape: PlAppLogoShape.plate, child: _Mark()),
        );

        expect(tester.getSize(find.byType(PlAppLogo)), const Size(32, 32));
      });

      testWidgets('insets the artwork inside a tile rather than filling it', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const PlAppLogo(semanticLabel: 'Acme', shape: PlAppLogoShape.plate, child: _Mark()),
        );

        // 70% of 32.
        expect(tester.getSize(find.byType(FittedBox)).width, closeTo(22.4, 0.1));
      });

      testWidgets('rounds the tile all the way for a disc', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlAppLogo(semanticLabel: 'Acme', shape: PlAppLogoShape.circle, child: _Mark()),
        );

        final BoxDecoration decoration = decorationWhere(
          tester,
          find.byType(PlAppLogo),
          (BoxDecoration box) => box.borderRadius != null,
        );

        expect((decoration.borderRadius! as BorderRadius).topLeft.x, _markSize);
      });

      testWidgets('takes the family on the tile', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlAppLogo(
            semanticLabel: 'Acme',
            shape: PlAppLogoShape.plate,
            color: PlassColor.success,
            child: _Mark(),
          ),
        );

        final BoxDecoration decoration = decorationWhere(
          tester,
          find.byType(PlAppLogo),
          (BoxDecoration box) => box.gradient != null,
        );

        expect(
          (decoration.gradient! as LinearGradient).colors.first,
          PlassTheme.of(tester.element(find.byType(PlAppLogo))).family(PlassColor.success).solid,
        );
      });
    });

    group('the ink', () {
      testWidgets('draws a glyph on a plate in the plate\'s ink', (WidgetTester tester) async {
        for (final PlassVariant variant in PlassVariant.values) {
          await _pump(
            tester,
            PlAppLogo(
              semanticLabel: 'Acme',
              key: ValueKey<PlassVariant>(variant),
              shape: PlAppLogoShape.plate,
              variant: variant,
              color: PlassColor.success,
              child: const _Glyph(),
            ),
          );

          final PlassColorFamily family = PlassTheme.of(
            tester.element(find.byType(PlAppLogo)),
          ).family(PlassColor.success);

          // The ink `currentColor` resolves to on the React plate: the one on
          // the fill on `solid`, and the family's accent on the other two.
          expect(
            _Glyph.seen,
            variant == PlassVariant.solid ? family.onSolid : family.accent,
            reason: variant.name,
          );
        }
      });

      testWidgets('draws a bare mark in the foreground the name is written in', (
        WidgetTester tester,
      ) async {
        for (final Brightness brightness in Brightness.values) {
          await tester.pumpWidget(
            host(
              PlAppLogo(
                semanticLabel: 'Acme',
                key: ValueKey<Brightness>(brightness),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[_Glyph(), Text('Acme')],
                ),
              ),
              brightness: brightness,
            ),
          );

          final Color fg = PlassTokens.of(brightness).fg;

          // The colour `currentColor` resolves to on the React logo, whose
          // root is written in `--plass-fg`, rather than whatever the app
          // around it has: the fallback black on the dark theme.
          expect(_Glyph.seen, fg, reason: brightness.name);
          expect(styleOf(tester, 'Acme').color, fg, reason: brightness.name);
        }
      });
    });

    group('the words', () {
      testWidgets('sets the name beside the mark', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlAppLogo(name: Text('Acme'), description: Text('Staging'), child: _Mark()),
        );

        expect(find.text('Acme'), findsOneWidget);
        expect(find.text('Staging'), findsOneWidget);
      });

      testWidgets('draws none of that when it was given none', (WidgetTester tester) async {
        await _pump(tester, const PlAppLogo(semanticLabel: 'Acme', child: _Mark()));

        expect(find.byType(Text), findsNothing);
      });
    });

    group('semantics', () {
      testWidgets('hides the mark once the name says it', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(
          tester,
          const PlAppLogo(semanticLabel: 'Acme', name: Text('Acme'), child: _Mark()),
        );

        // Once, not twice: the wordmark beside a picture of the wordmark is a
        // screen reader reading the product's name two times.
        expect(find.bySemanticsLabel('Acme'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('lets the mark speak when there is no name', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, const PlAppLogo(semanticLabel: 'Acme', child: _Mark()));

        expect(find.bySemanticsLabel('Acme'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('says its semanticLabel in place of what the mark says itself', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, const PlAppLogo(semanticLabel: 'Acme', child: Text('A')));

        // What the picture says, as an `alt` is on the web, and not "Acme"
        // followed by the letter the mark is drawn with.
        expect(semanticsLabels(tester), <String>['Acme']);
        expect(semanticsNodeLabelled(tester, 'Acme'), isSemantics(isImage: true));

        handle.dispose();
      });

      test('asks for a semanticLabel when there is no name', () {
        // A mark with neither is described by nothing, and as the way home it
        // is a button with no name.
        expect(() => PlAppLogo(child: const _Mark()), throwsAssertionError);
        expect(() => PlAppLogo(onPressed: () {}, child: const _Mark()), throwsAssertionError);

        // A name, a label, or an empty label each answer it.
        expect(PlAppLogo(name: const Text('Acme'), child: const _Mark()), isA<PlAppLogo>());
        expect(PlAppLogo(semanticLabel: 'Acme', child: const _Mark()), isA<PlAppLogo>());
        expect(PlAppLogo(semanticLabel: '', child: const _Mark()), isA<PlAppLogo>());
      });

      testWidgets('takes a mark with an empty semanticLabel off the tree', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, const PlAppLogo(semanticLabel: '', child: Text('A')));

        // An empty label is `alt=""`: decorative, so neither the letter the
        // mark is drawn with nor a picture with no name is left behind.
        bool image = false;

        bool visit(SemanticsNode node) {
          image = image || node.getSemanticsData().flagsCollection.isImage;
          node.visitChildren(visit);

          return true;
        }

        visit(tester.binding.renderViews.first.debugSemantics!);

        expect(semanticsLabels(tester), isEmpty);
        expect(image, isFalse);

        handle.dispose();
      });

      testWidgets('becomes a button when it is given something to do', (WidgetTester tester) async {
        int pressed = 0;

        await _pump(
          tester,
          PlAppLogo(semanticLabel: 'Acme', onPressed: () => pressed += 1, child: const _Mark()),
        );

        await tester.tap(find.byType(PlAppLogo));

        expect(pressed, 1);
      });

      testWidgets('is announced as one button, named by the words beside the mark', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        int pressed = 0;

        await _pump(
          tester,
          PlAppLogo(
            name: const Text('Acme'),
            description: const Text('Staging'),
            onPressed: () => pressed += 1,
            child: const _Mark(),
          ),
        );

        expect(
          tester.getSemantics(find.text('Acme')),
          isSemantics(isButton: true, hasTapAction: true, label: 'Acme\nStaging'),
        );

        // The action a screen reader, Switch Access or Voice Access fires.
        tester.semantics.tap(find.semantics.byLabel('Acme\nStaging'));

        expect(pressed, 1);

        handle.dispose();
      });
    });

    group('the keyboard', () {
      /// The focus rings drawn inside the logo.
      List<PlassFocusRingPainter> rings(WidgetTester tester) {
        return tester
            .widgetList<CustomPaint>(
              find.descendant(of: find.byType(PlAppLogo), matching: find.byType(CustomPaint)),
            )
            .map((CustomPaint paint) => paint.foregroundPainter)
            .whereType<PlassFocusRingPainter>()
            .toList();
      }

      testWidgets('reaches a pressable logo by Tab, and presses it with Enter and Space', (
        WidgetTester tester,
      ) async {
        final before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);
        int pressed = 0;

        await tester.pumpWidget(
          host(
            afterFocusStop(
              before,
              PlAppLogo(
                name: const Text('Acme'),
                onPressed: () => pressed += 1,
                child: const _Mark(),
              ),
            ),
          ),
        );

        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        expect(_holdsFocus(tester), isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(pressed, 1);

        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        expect(pressed, 2);
      });

      testWidgets('draws the focus ring only while a keyboard holds the focus', (
        WidgetTester tester,
      ) async {
        final before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);

        await tester.pumpWidget(
          host(
            afterFocusStop(
              before,
              PlAppLogo(
                semanticLabel: 'Acme',
                shape: PlAppLogoShape.plate,
                color: PlassColor.success,
                onPressed: () {},
                child: const _Mark(),
              ),
            ),
          ),
        );

        expect(rings(tester), isEmpty);

        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // The family's own ring, as on every other control.
        expect(
          rings(tester).single.color,
          PlassTheme.of(tester.element(find.byType(PlAppLogo))).family(PlassColor.success).ring,
        );

        before.requestFocus();
        await tester.pumpAndSettle();

        expect(rings(tester), isEmpty);
      });

      testWidgets('takes no focus when it has nothing to do', (WidgetTester tester) async {
        final before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);

        await tester.pumpWidget(
          host(afterFocusStop(before, const PlAppLogo(name: Text('Acme'), child: _Mark()))),
        );

        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        expect(_holdsFocus(tester), isFalse);
        expect(rings(tester), isEmpty);
      });

      testWidgets('takes no focus when it has nothing to do, on a remote either', (
        WidgetTester tester,
      ) async {
        final before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);

        // Directional navigation is where an unavailable control is still a
        // stop, so a reader can find it. A logo with nothing to do is not a
        // control, and there is nothing to find.
        await tester.pumpWidget(
          host(
            MediaQuery(
              data: const MediaQueryData(navigationMode: NavigationMode.directional),
              child: afterFocusStop(before, const PlAppLogo(name: Text('Acme'), child: _Mark())),
            ),
          ),
        );

        await _tabFrom(tester, before);

        expect(_holdsFocus(tester), isFalse);
      });
    });

    group('onPressed', () {
      testWidgets('keeps what the logo holds when it is handed onPressed, and loses it', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        final before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);

        Widget logo({VoidCallback? onPressed}) => host(
          afterFocusStop(
            before,
            PlAppLogo(
              name: const _Probe('Acme'),
              description: const _Probe('Staging'),
              onPressed: onPressed,
              child: const _Probe('A'),
            ),
          ),
        );

        await tester.pumpWidget(logo());

        final List<State<_Probe>> resting = tester
            .stateList<State<_Probe>>(find.byType(_Probe))
            .toList();

        expect(resting, hasLength(3));

        for (final bool pressable in <bool>[true, false, true, false]) {
          await tester.pumpWidget(logo(onPressed: pressable ? () {} : null));

          // Built again from scratch, a probe is a different object, and a
          // picture in its place would have been decoded again.
          final List<State<_Probe>> now = tester
              .stateList<State<_Probe>>(find.byType(_Probe))
              .toList();

          for (var index = 0; index < resting.length; index += 1) {
            expect(now[index], same(resting[index]), reason: 'probe $index, $pressable');
          }

          // Still a button only while there is something to press.
          expect(
            tester.getSemantics(find.text('Acme')),
            isSemantics(isButton: pressable, hasTapAction: pressable),
            reason: '$pressable',
          );

          await _tabFrom(tester, before);

          expect(_holdsFocus(tester), pressable, reason: '$pressable');
        }

        handle.dispose();
      });
    });
  });
}

/// The `md` mark height, which is also the radius a disc is cut to.
const double _markSize = 32;
