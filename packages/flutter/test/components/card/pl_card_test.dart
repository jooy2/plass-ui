import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// Content with a `State` of its own, standing in for an entry animation or a
/// picture fading in: rebuilt from scratch, it is a different object.
class _Probe extends StatefulWidget {
  const _Probe();

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => const Text('Body');
}

/// The vertical middle of the first line of [text]: the middle of its first
/// glyph's box, taken as tall as the line it sits on.
///
/// The paragraph rounds a line to whole pixels and leaves the glyph's box as it
/// is, so where the line is not a whole number of pixels the two middles are a
/// fraction of a pixel apart, which [expectNear] allows for.
double firstLineMiddleOf(WidgetTester tester, Finder text) {
  final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(text);
  final TextBox glyph = paragraph
      .getBoxesForSelection(
        const TextSelection(baseOffset: 0, extentOffset: 1),
        boxHeightStyle: ui.BoxHeightStyle.max,
      )
      .first;

  return tester.getRect(text).top + (glyph.top + glyph.bottom) / 2;
}

/// Within a pixel either way.
void expectNear(double actual, double expected) {
  expect((actual - expected).abs(), lessThanOrEqualTo(1));
}

/// The action sits wholly inside the header row, so every part of it takes a
/// press.
void expectInside(WidgetTester tester, Finder action) {
  final Rect box = tester.getRect(action);
  final Rect row = tester.getRect(find.ancestor(of: action, matching: find.byType(Row)).first);

  expect(box.top, greaterThanOrEqualTo(row.top - 1));
  expect(box.bottom, lessThanOrEqualTo(row.bottom + 1));
}

void main() {
  group('PlCard', () {
    group('slots', () {
      testWidgets('lays out its title, subtitle, body and footer', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlCard(
              title: Text('Billing'),
              subtitle: Text('Visa ending 4242'),
              footer: Text('Change'),
              child: Text('Next invoice on 1 March.'),
            ),
            width: 360,
          ),
        );

        for (final line in <String>[
          'Billing',
          'Visa ending 4242',
          'Next invoice on 1 March.',
          'Change',
        ]) {
          expect(find.text(line), findsOneWidget);
        }
      });

      testWidgets('has no header row at all without one', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlCard(child: Text('Body')), width: 360));

        expect(find.byType(Row), findsNothing);
      });

      testWidgets('pins a header action to the end of the title line', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlCard(title: Text('Billing'), headerAction: Text('•••')), width: 360),
        );

        expect(
          tester.getRect(find.text('•••')).left,
          greaterThan(tester.getRect(find.text('Billing')).left),
        );
      });

      testWidgets('sets the title above the body on the sheet ladder', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlCard(title: Text('Billing'), child: Text('Body')), width: 360),
        );

        expect(styleOf(tester, 'Billing').fontSize, 15);
        expect(styleOf(tester, 'Body').fontSize, 13);
      });

      testWidgets('mutes the subtitle', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlCard(title: Text('Billing'), subtitle: Text('Visa')), width: 360),
        );

        expect(styleOf(tester, 'Visa').color, PlassTokens.light().mutedFg);
      });
    });

    group('the header action', () {
      final more = find.byType(PlIconButton);

      for (final size in PlassSize.values) {
        testWidgets('centres on a one-line title, and the header holds it, at ${size.name}', (
          WidgetTester tester,
        ) async {
          var pressed = 0;

          await tester.pumpWidget(
            host(
              PlCard(
                size: size,
                title: const Text('Billing'),
                headerAction: PlIconButton(
                  size: size,
                  icon: const Text('•'),
                  label: 'More',
                  onPressed: () => pressed += 1,
                ),
                child: const Text('Body'),
              ),
              width: 320,
            ),
          );

          expectNear(tester.getCenter(more).dy, firstLineMiddleOf(tester, find.text('Billing')));
          expectInside(tester, more);
          expect(
            tester.getRect(find.text('Body')).top,
            greaterThanOrEqualTo(tester.getRect(more).bottom),
          );

          // Pressed just inside its top edge and just inside its bottom one.
          await tester.tapAt(tester.getRect(more).topCenter + const Offset(0, 1));
          await tester.tapAt(tester.getRect(more).bottomCenter - const Offset(0, 1));

          expect(pressed, 2);
        });

        testWidgets('moves itself rather than the title when it is shorter, at ${size.name}', (
          WidgetTester tester,
        ) async {
          const dot = Key('dot');

          await tester.pumpWidget(
            host(
              PlCard(
                size: size,
                title: const Text('Billing'),
                headerAction: const SizedBox.square(key: dot, dimension: 8),
              ),
              width: 320,
            ),
          );

          final title = find.text('Billing');
          final Rect row = tester.getRect(
            find.ancestor(of: title, matching: find.byType(Row)).first,
          );

          expectNear(tester.getCenter(find.byKey(dot)).dy, firstLineMiddleOf(tester, title));
          expectNear(tester.getRect(title).top, row.top);
          expectInside(tester, find.byKey(dot));
        });

        testWidgets('centres on the subtitle when there is no title, at ${size.name}', (
          WidgetTester tester,
        ) async {
          await tester.pumpWidget(
            host(
              PlCard(
                size: size,
                subtitle: const Text('Visa ending 4242'),
                headerAction: PlIconButton(
                  size: size,
                  icon: const Text('•'),
                  label: 'More',
                  onPressed: () {},
                ),
              ),
              width: 320,
            ),
          );

          expectNear(
            tester.getCenter(more).dy,
            firstLineMiddleOf(tester, find.text('Visa ending 4242')),
          );
          expectInside(tester, more);
        });

        testWidgets('centres on a title that is a heading, at ${size.name}', (
          WidgetTester tester,
        ) async {
          await tester.pumpWidget(
            host(
              PlCard(
                size: size,
                title: const Text('Billing'),
                headingLevel: 2,
                headerAction: PlIconButton(
                  size: size,
                  icon: const Text('•'),
                  label: 'More',
                  onPressed: () {},
                ),
              ),
              width: 320,
            ),
          );

          expectNear(tester.getCenter(more).dy, firstLineMiddleOf(tester, find.text('Billing')));
          expectInside(tester, more);
        });
      }

      testWidgets('stays on the first line of a title that wraps', (WidgetTester tester) async {
        const words = 'Quarterly billing summary for the whole team';

        await tester.pumpWidget(
          host(
            PlCard(
              title: const Text(words),
              headerAction: PlIconButton(icon: const Text('•'), label: 'More', onPressed: () {}),
            ),
            width: 200,
          ),
        );

        final title = find.text(words);

        // Wrapped, or the test is not about a wrapping title.
        expect(
          tester.getSize(title).height,
          greaterThan((firstLineMiddleOf(tester, title) - tester.getRect(title).top) * 3),
        );
        expectNear(tester.getCenter(more).dy, firstLineMiddleOf(tester, title));
      });

      testWidgets('centres a labelled button on the title rather than lining up its label', (
        WidgetTester tester,
      ) async {
        final edit = find.byType(PlButton);

        await tester.pumpWidget(
          host(
            PlCard(
              title: const Text('Billing'),
              headerAction: PlButton(
                size: PlassSize.sm,
                onPressed: () {},
                child: const Text('Edit'),
              ),
            ),
            width: 320,
          ),
        );

        expectNear(tester.getCenter(edit).dy, firstLineMiddleOf(tester, find.text('Billing')));
        expectInside(tester, edit);
      });

      testWidgets('centres on the title when a subtitle is under it', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlCard(
              title: const Text('Billing'),
              subtitle: const Text('Visa ending 4242'),
              headerAction: PlIconButton(icon: const Text('•'), label: 'More', onPressed: () {}),
            ),
            width: 320,
          ),
        );

        expectNear(tester.getCenter(more).dy, firstLineMiddleOf(tester, find.text('Billing')));
        expectInside(tester, more);
      });

      testWidgets('follows the title when the text is scaled', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            Builder(
              builder: (BuildContext context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.5)),
                child: PlCard(
                  title: const Text('Billing'),
                  headerAction: PlIconButton(
                    icon: const Text('•'),
                    label: 'More',
                    onPressed: () {},
                  ),
                ),
              ),
            ),
            width: 320,
          ),
        );

        expectNear(tester.getCenter(more).dy, firstLineMiddleOf(tester, find.text('Billing')));
        expectInside(tester, more);
      });

      testWidgets('sits at the top of a header that holds nothing else', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlCard(
              headerAction: PlIconButton(icon: const Text('•'), label: 'More', onPressed: () {}),
            ),
            width: 320,
          ),
        );

        final Rect row = tester.getRect(find.ancestor(of: more, matching: find.byType(Row)).first);

        expectNear(tester.getRect(more).top, row.top);
        expectInside(tester, more);
      });

      testWidgets('keeps its own state when a title comes or goes', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlCard(headerAction: _Probe()), width: 320));

        final State<_Probe> before = tester.state(find.byType(_Probe));

        await tester.pumpWidget(
          host(const PlCard(title: Text('Billing'), headerAction: _Probe()), width: 320),
        );

        expect(tester.state(find.byType(_Probe)), same(before));
      });
    });

    group('the title in the outline', () {
      testWidgets('is not a heading until it is given a level', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(host(const PlCard(title: Text('Billing')), width: 360));

        expect(tester.getSemantics(find.text('Billing')), isSemantics(isHeader: false));

        handle.dispose();
      });

      testWidgets('is a heading of the level it is given', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(const PlCard(title: Text('Billing'), headingLevel: 2), width: 360),
        );

        final SemanticsData title = tester.getSemantics(find.text('Billing')).getSemanticsData();

        expect(tester.getSemantics(find.text('Billing')), isSemantics(isHeader: true));
        expect(title.headingLevel, 2);

        handle.dispose();
      });

      testWidgets('stays the name of a pressable card rather than a heading inside it', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(PlCard(title: const Text('Billing'), headingLevel: 2, onPressed: () {}), width: 360),
        );

        expect(
          tester.getSemantics(find.text('Billing')),
          isSemantics(isButton: true, isHeader: false, label: 'Billing'),
        );

        handle.dispose();
      });
    });

    group('the sheet', () {
      testWidgets('is glass and is never dyed', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlCard(color: PlassColor.danger, child: Text('Body')), width: 360),
        );

        final tokens = PlassTokens.light();
        final sheet = decorationWhere(
          tester,
          find.byType(PlCard),
          (BoxDecoration decoration) => decoration.border != null,
        );

        expect(sheet.color, tokens.glass);
        expect(sheet.gradient, isNull);
      });

      testWidgets('rests on the page rather than printed into it', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlCard(child: Text('Body')), width: 360));

        final shell = decorationWhere(
          tester,
          find.byType(PlCard),
          (BoxDecoration decoration) => decoration.boxShadow != null,
        );

        expect(shell.boxShadow, PlassTokens.light().elevation(1));
      });
    });

    group('padded', () {
      testWidgets('insets its content on the sheet ladder', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlCard(child: Text('Body')), width: 360));

        final body = tester.getRect(find.text('Body'));
        final card = tester.getRect(find.byType(PlCard));

        expect(body.left - card.left, 20);
      });

      testWidgets('goes full-bleed when asked', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlCard(padded: false, child: Text('Body')), width: 360));

        final body = tester.getRect(find.text('Body'));
        final card = tester.getRect(find.byType(PlCard));

        expect(body.left - card.left, 0);
      });
    });

    group('dividers', () {
      testWidgets('scores the sheet instead of spacing it', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlCard(dividers: true, title: Text('Billing'), child: Text('Body')),
            width: 360,
          ),
        );

        final scored = decorationsOf(
          tester,
          find.byType(PlCard),
        ).where((BoxDecoration decoration) => decoration.border is Border).toList();

        expect(
          scored.any(
            (BoxDecoration decoration) =>
                (decoration.border! as Border).top.color == PlassTokens.light().divider,
          ),
          isTrue,
        );
      });
    });

    group('pressing', () {
      testWidgets('is not a focus stop until it can be pressed', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlCard(child: Text('Body')), width: 360));

        expect(tester.getSemantics(find.text('Body')), isSemantics(isButton: false));

        handle.dispose();
      });

      testWidgets('is a focus stop on a remote only once it can be pressed, on any focus node', (
        WidgetTester tester,
      ) async {
        final before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);
        final given = FocusNode(debugLabel: 'given');
        addTearDown(given.dispose);

        for (final bool handed in <bool>[false, true]) {
          for (final bool pressable in <bool>[false, true, false]) {
            await tester.pumpWidget(
              host(
                MediaQuery(
                  data: const MediaQueryData(navigationMode: NavigationMode.directional),
                  child: afterFocusStop(
                    before,
                    PlCard(
                      onPressed: pressable ? () {} : null,
                      focusNode: handed ? given : null,
                      child: const Text('Body'),
                    ),
                  ),
                ),
                width: 360,
              ),
            );

            before.requestFocus();
            await tester.pump();
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.pump();

            final BuildContext? focused = FocusManager.instance.primaryFocus?.context;

            expect(
              focused != null &&
                  find
                      .ancestor(
                        of: find.byElementPredicate((Element element) => element == focused),
                        matching: find.byType(PlCard),
                      )
                      .evaluate()
                      .isNotEmpty,
              pressable,
              reason: 'handed $handed, pressable $pressable',
            );
          }
        }
      });

      testWidgets('is a real button once it can be', (WidgetTester tester) async {
        var pressed = 0;
        await tester.pumpWidget(
          host(
            PlCard(
              onPressed: () => pressed += 1,
              semanticLabel: 'Open billing',
              child: const Text('Body'),
            ),
            width: 360,
          ),
        );

        await tester.tap(find.byType(PlCard));
        expect(pressed, 1);
      });

      testWidgets('is named by its semanticLabel alone, and keeps what it holds beside it', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlCard(
              onPressed: () {},
              semanticLabel: 'Team plan',
              title: const Text('Team'),
              child: const Text('Shared projects'),
            ),
            width: 360,
          ),
        );

        // The name, and not the name with the title and the body run on after
        // it as one long one. What the card holds is still read, as nodes of
        // its own inside the button.
        final SemanticsNode card = semanticsNodeLabelled(tester, 'Team plan')!;

        expect(card, isSemantics(label: 'Team plan', isButton: true, hasTapAction: true));
        expect(semanticsNodeLabelled(tester, 'Team'), isNotNull);
        expect(semanticsNodeLabelled(tester, 'Shared projects'), isNotNull);

        handle.dispose();
      });

      testWidgets('says on the node that names it that it can take the focus', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();

        for (final String? semanticLabel in <String?>[null, 'Team plan']) {
          final String name = semanticLabel ?? 'Team\nShared projects';

          await tester.pumpWidget(
            host(
              PlCard(
                onPressed: () {},
                semanticLabel: semanticLabel,
                title: const Text('Team'),
                child: const Text('Shared projects'),
              ),
              width: 360,
            ),
          );

          // Beside the name and the tap, as a `PlButton` has them, whether the
          // card is named by what it holds or keeps that apart under a name
          // of its own. Nothing round it or inside it says it too.
          expect(
            semanticsNodeLabelled(tester, name),
            isSemantics(
              label: name,
              isButton: true,
              isFocusable: true,
              isFocused: false,
              hasTapAction: true,
              hasFocusAction: true,
            ),
            reason: name,
          );
          expect(find.semantics.byFlag(SemanticsFlag.isFocusable), findsOne, reason: name);

          tester.semantics.performAction(find.semantics.byLabel(name), SemanticsAction.focus);
          await tester.pumpAndSettle();

          expect(
            semanticsNodeLabelled(tester, name),
            isSemantics(label: name, isFocusable: true, isFocused: true),
            reason: name,
          );

          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
        }

        // A card that cannot be pressed takes no focus and does not say it can.
        await tester.pumpWidget(
          host(const PlCard(title: Text('Team'), child: Text('Shared projects')), width: 360),
        );

        expect(find.semantics.byFlag(SemanticsFlag.isFocusable), findsNothing);

        handle.dispose();
      });

      testWidgets('is named by what it holds when it has no semanticLabel', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlCard(
              onPressed: () {},
              title: const Text('Team'),
              child: const Text('Shared projects'),
            ),
            width: 360,
          ),
        );

        expect(
          tester.getSemantics(find.text('Shared projects')),
          isSemantics(label: 'Team\nShared projects', isButton: true),
        );

        handle.dispose();
      });

      testWidgets(
        'keeps what it holds when it is handed onPressed or interactive, and loses them',
        (WidgetTester tester) async {
          Widget card({VoidCallback? onPressed, bool interactive = false}) => host(
            PlCard(
              title: const _Probe(),
              headingLevel: 2,
              onPressed: onPressed,
              interactive: interactive,
              child: const _Probe(),
            ),
            width: 360,
          );

          await tester.pumpWidget(card());

          final List<State<_Probe>> resting = tester
              .stateList<State<_Probe>>(find.byType(_Probe))
              .toList();

          expect(resting, hasLength(2));

          // Every way the card can change what it does, and back. Rebuilt from
          // scratch, a probe is a different object, and a field in its place
          // would have lost what was typed into it.
          for (final Widget next in <Widget>[
            card(onPressed: () {}),
            card(),
            card(interactive: true),
            card(onPressed: () {}, interactive: true),
            card(),
          ]) {
            await tester.pumpWidget(next);

            final List<State<_Probe>> now = tester
                .stateList<State<_Probe>>(find.byType(_Probe))
                .toList();

            expect(now[0], same(resting[0]));
            expect(now[1], same(resting[1]));
          }
        },
      );

      testWidgets('lets a press on a card that cannot be pressed reach what is around it', (
        WidgetTester tester,
      ) async {
        var around = 0;

        for (final bool interactive in <bool>[false, true]) {
          await tester.pumpWidget(
            host(
              GestureDetector(
                onTap: () => around += 1,
                child: PlCard(interactive: interactive, child: const Text('Body')),
              ),
              width: 360,
            ),
          );

          await tester.tap(find.text('Body'));
        }

        expect(around, 2);
      });
    });

    group('hovering', () {
      testWidgets('keeps what the card holds through a hover in and out', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(PlCard(onPressed: () {}, child: const _Probe()), width: 360));

        final State<_Probe> resting = tester.state(find.byType(_Probe));
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: const Offset(1, 1));
        addTearDown(mouse.removePointer);

        await mouse.moveTo(tester.getCenter(find.byType(PlCard)));
        await tester.pumpAndSettle();

        // Lifted, so the hover really did land.
        expect(
          decorationWhere(
            tester,
            find.byType(PlCard),
            (BoxDecoration decoration) => decoration.boxShadow != null,
          ).boxShadow,
          PlassTokens.light().elevation(2),
        );
        expect(tester.state(find.byType(_Probe)), same(resting));

        await mouse.moveTo(const Offset(1, 1));
        await tester.pumpAndSettle();

        expect(tester.state(find.byType(_Probe)), same(resting));
      });

      testWidgets('lifts a card that is only interactive', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlCard(interactive: true, child: Text('Body')), width: 360),
        );

        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: const Offset(1, 1));
        addTearDown(mouse.removePointer);

        await mouse.moveTo(tester.getCenter(find.byType(PlCard)));
        await tester.pumpAndSettle();

        // The same lift a pressable card gives, with nothing to press: a level
        // of shadow and the sheet raised by two pixels.
        expect(
          decorationWhere(
            tester,
            find.byType(PlCard),
            (BoxDecoration decoration) => decoration.boxShadow != null,
          ).boxShadow,
          PlassTokens.light().elevation(2),
        );
        expect(
          tester
              .widget<Transform>(
                find.descendant(of: find.byType(PlCard), matching: find.byType(Transform)).first,
              )
              .transform
              .getTranslation()
              .y,
          -2,
        );

        await mouse.moveTo(const Offset(1, 1));
        await tester.pumpAndSettle();

        expect(
          decorationWhere(
            tester,
            find.byType(PlCard),
            (BoxDecoration decoration) => decoration.boxShadow != null,
          ).boxShadow,
          PlassTokens.light().elevation(1),
        );
      });
    });
  });
}
