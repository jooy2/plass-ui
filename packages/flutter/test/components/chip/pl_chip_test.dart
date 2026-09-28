import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/scales.dart';

import '../../support/host.dart';

/// A pack's remove button name, which puts the verb after the name.
String _removeInKorean(String name) => '$name 삭제';

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

void main() {
  group('PlChip', () {
    group('rendering', () {
      testWidgets('renders its label', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlChip(child: Text('Unread'))));

        expect(find.text('Unread'), findsOneWidget);
      });

      testWidgets('sits one step down the control ladder', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlChip(child: Text('Unread'))));

        // An `md` chip is an `sm` control: 32px, not 40.
        expect(tester.getSize(find.byType(PlChip)).height, 32);
      });

      testWidgets('keeps `xs` from falling off the bottom of the ladder', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlChip(size: PlassSize.xs, child: Text('Tag'))));

        expect(tester.getSize(find.byType(PlChip)).height, 24);
      });

      testWidgets('sets a count on its own plate', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlChip(count: Text('12'), child: Text('Errors'))));

        expect(find.text('12'), findsOneWidget);
        expect(find.text('Errors'), findsOneWidget);
      });

      testWidgets('keeps each of its parts as the others come and go around it', (
        WidgetTester tester,
      ) async {
        Widget chip((bool, bool, bool) parts) {
          final (bool start, bool end, bool counted) = parts;

          return host(
            PlChip(
              onPressed: () {},
              selected: start,
              startIcon: start ? const _Probe('S') : null,
              endIcon: end ? const _Probe('E') : null,
              count: counted ? const _Probe('12') : null,
              child: const _Probe('Unread'),
            ),
          );
        }

        Map<String, State<_Probe>> probes() {
          return <String, State<_Probe>>{
            for (final State<_Probe> state in tester.stateList<State<_Probe>>(find.byType(_Probe)))
              state.widget.text: state,
          };
        }

        final List<(bool, bool, bool)> combinations = <(bool, bool, bool)>[
          for (final bool start in <bool>[false, true])
            for (final bool end in <bool>[false, true])
              for (final bool counted in <bool>[false, true]) (start, end, counted),
        ];

        // Every change between two sets of parts in one build, as a filter
        // chip that gains a mark in front of the label and a count behind it
        // when it is chosen makes.
        for (final (bool, bool, bool) from in combinations) {
          for (final (bool, bool, bool) to in combinations) {
            await tester.pumpWidget(chip(from));

            final Map<String, State<_Probe>> before = probes();

            await tester.pumpWidget(chip(to));

            final Map<String, State<_Probe>> after = probes();

            // Built again from scratch, a part that stayed is a different
            // object.
            for (final MapEntry<String, State<_Probe>> part in before.entries) {
              if (after.containsKey(part.key)) {
                expect(after[part.key], same(part.value), reason: '${part.key}, $from to $to');
              }
            }
          }
        }
      });
    });

    group('pressing', () {
      testWidgets('is not a focus stop until it can be pressed', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlChip(child: Text('Tag'))));

        // Asked from inside: a chip that can be removed is two nodes, so the one
        // that is the chip is the one its label sits in.
        expect(tester.getSemantics(find.text('Tag')), isSemantics(isButton: false));

        handle.dispose();
      });

      testWidgets('fires when pressed', (WidgetTester tester) async {
        var pressed = 0;
        await tester.pumpWidget(
          host(PlChip(onPressed: () => pressed += 1, child: const Text('Tag'))),
        );

        await tester.tap(find.byType(PlChip));
        expect(pressed, 1);
      });

      testWidgets('does not fire while disabled', (WidgetTester tester) async {
        var pressed = 0;
        await tester.pumpWidget(
          host(PlChip(onPressed: () => pressed += 1, disabled: true, child: const Text('Tag'))),
        );

        await tester.tap(find.byType(PlChip));
        expect(pressed, 0);
      });

      testWidgets('says it is disabled, with the not-allowed cursor, with nothing to press', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlChip(disabled: true, child: Text('Tag'))));

        // As the React chip's shell carries `aria-disabled` and
        // `cursor-not-allowed` without an `onClick`. Not a button, and no stop.
        expect(
          tester.getSemantics(find.text('Tag')),
          isSemantics(isButton: false, hasEnabledState: true, isEnabled: false, isFocusable: false),
        );
        expect(
          tester
              .widgetList<MouseRegion>(
                find.descendant(of: find.byType(PlChip), matching: find.byType(MouseRegion)),
              )
              .first
              .cursor,
          SystemMouseCursors.forbidden,
        );

        handle.dispose();
      });

      testWidgets('stays a button that cannot be used while disabled', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(PlChip(onPressed: () {}, disabled: true, selected: true, child: const Text('Tag'))),
        );

        // Announced as a disabled `PlButton` is, with nothing to press.
        expect(
          tester.getSemantics(find.text('Tag')),
          isSemantics(
            isButton: true,
            hasEnabledState: true,
            isEnabled: false,
            isSelected: true,
            hasTapAction: false,
          ),
        );

        handle.dispose();
      });

      testWidgets('holds on to a tap while disabled, as a disabled button does', (
        WidgetTester tester,
      ) async {
        var around = 0;
        var pressed = 0;

        Widget chip({required bool pressable}) {
          return host(
            GestureDetector(
              onTap: () => around += 1,
              child: PlChip(
                onPressed: pressable ? () => pressed += 1 : null,
                disabled: true,
                child: const Text('Tag'),
              ),
            ),
          );
        }

        await tester.pumpWidget(chip(pressable: true));
        await tester.tap(find.byType(PlChip));

        // Whatever is around it does not answer someone who tried the
        // disabled chip, as nothing around the React chip's disabled
        // `<button>` hears the click.
        expect(pressed, 0);
        expect(around, 0);

        // A chip with nothing to press is not a button, and leaves the tap
        // to what is around it.
        await tester.pumpWidget(chip(pressable: false));
        await tester.tap(find.byType(PlChip));

        expect(around, 1);
      });

      testWidgets('leaves the focus order while disabled, and a remote still finds it', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);

        int rings() {
          return tester
              .widgetList<CustomPaint>(find.byType(CustomPaint))
              .where((CustomPaint paint) => paint.foregroundPainter is PlassFocusRingPainter)
              .length;
        }

        for (final NavigationMode mode in NavigationMode.values) {
          await tester.pumpWidget(
            host(
              MediaQuery(
                data: MediaQueryData(navigationMode: mode),
                child: afterFocusStop(
                  before,
                  PlChip(onPressed: () {}, disabled: true, child: const Text('Tag')),
                ),
              ),
            ),
          );

          before.requestFocus();
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();

          final BuildContext? focused = FocusManager.instance.primaryFocus?.context;
          final bool inChip =
              focused != null &&
              find
                  .ancestor(
                    of: find.byElementPredicate((Element element) => element == focused),
                    matching: find.byType(PlChip),
                  )
                  .evaluate()
                  .isNotEmpty;
          final bool directional = mode == NavigationMode.directional;

          // As a disabled `PlButton` is: no stop for a keyboard, and one a
          // remote can find, ringed while it is there.
          expect(inChip, directional, reason: '$mode');
          expect(rings(), directional ? 1 : 0, reason: '$mode');
        }
      });

      testWidgets('reports whether it is chosen', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(PlChip(onPressed: () {}, selected: true, child: const Text('Tag'))),
        );

        expect(tester.getSemantics(find.text('Tag')), isSemantics(isSelected: true));
        handle.dispose();
      });
    });

    group('selected', () {
      testWidgets('moves a glass chip one step up its own ladder', (WidgetTester tester) async {
        final tokens = PlassTokens.light();

        await tester.pumpWidget(host(const PlChip(child: Text('Tag'))));
        expect(
          decorationWhere(
            tester,
            find.byType(PlChip),
            (BoxDecoration decoration) => decoration.border != null,
          ).color,
          tokens.glass,
        );

        await tester.pumpWidget(host(const PlChip(selected: true, child: Text('Tag'))));
        await tester.pumpAndSettle();

        expect(
          decorationWhere(
            tester,
            find.byType(PlChip),
            (BoxDecoration decoration) => decoration.border != null,
          ).color,
          tokens.glassPress,
        );
      });

      testWidgets('lifts a solid chip rather than recolouring it', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlChip(variant: PlassVariant.solid, child: Text('Tag'))),
        );

        final flat = decorationWhere(
          tester,
          find.byType(PlChip),
          (BoxDecoration decoration) => decoration.gradient != null,
        );

        await tester.pumpWidget(
          host(const PlChip(variant: PlassVariant.solid, selected: true, child: Text('Tag'))),
        );
        await tester.pumpAndSettle();

        final lifted = decorationsOf(
          tester,
          find.byType(PlChip),
        ).firstWhere((BoxDecoration decoration) => decoration.boxShadow?.isNotEmpty ?? false);

        expect(flat.gradient, isNotNull);
        expect(lifted.boxShadow!.last.color, PlassTokens.light().family(PlassColor.primary).tint);
      });
    });

    group('delete', () {
      testWidgets('has no affordance until one is asked for', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlChip(child: Text('Tag'))));

        expect(find.bySemanticsLabel(RegExp('^Remove')), findsNothing);
        handle.dispose();
      });

      testWidgets('keeps the label and its icons as onDeleted comes and goes', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();

        Widget chip({bool deletable = false, bool pressable = false, bool disabled = false}) {
          return host(
            PlChip(
              onPressed: pressable ? () {} : null,
              onDeleted: deletable ? () {} : null,
              disabled: disabled,
              startIcon: const _Probe('S'),
              endIcon: const _Probe('E'),
              child: const _Probe('Tag'),
            ),
          );
        }

        await tester.pumpWidget(chip());

        final List<State<_Probe>> resting = tester
            .stateList<State<_Probe>>(find.byType(_Probe))
            .toList();
        final Size bare = tester.getSize(find.byType(PlChip));

        expect(resting, hasLength(3));

        for (final (bool deletable, bool pressable, bool disabled) in <(bool, bool, bool)>[
          (true, false, false),
          (false, false, false),
          (true, true, false),
          (false, true, false),
          (true, true, true),
          (false, false, false),
        ]) {
          final String reason = 'deletable $deletable, pressable $pressable, disabled $disabled';

          await tester.pumpWidget(
            chip(deletable: deletable, pressable: pressable, disabled: disabled),
          );

          // Built again from scratch, a probe is a different object, and an
          // avatar in its place would have been decoded again.
          final List<State<_Probe>> now = tester
              .stateList<State<_Probe>>(find.byType(_Probe))
              .toList();

          for (var index = 0; index < resting.length; index += 1) {
            expect(now[index], same(resting[index]), reason: 'probe $index, $reason');
          }

          // The label is not words, so the × is named by the word alone.
          expect(
            find.bySemanticsLabel('Remove'),
            deletable ? findsOneWidget : findsNothing,
            reason: reason,
          );
        }

        // With nothing beside it, as wide as it was before there was ever a ×.
        expect(tester.getSize(find.byType(PlChip)), bare);
        handle.dispose();
      });

      testWidgets('leaves no room for a × it does not have', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlChip(child: Text('Tag'))));

        // An `md` chip pads its label by an `sm` control's padding.
        expect(
          tester.getSize(find.byType(PlChip)).width,
          tester.getSize(find.text('Tag')).width +
              2 * paddingX[PlassDensity.standard]![PlassSize.sm]!,
        );
      });

      testWidgets('fires on its own, without the chip', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        var removed = 0;
        var pressed = 0;

        await tester.pumpWidget(
          host(
            PlChip(
              onPressed: () => pressed += 1,
              onDeleted: () => removed += 1,
              child: const Text('Tag'),
            ),
          ),
        );

        // The × is its own focus stop and its own hit target, which is the
        // whole reason it is not inside the chip's own gesture recogniser.
        await tester.tap(find.bySemanticsLabel('Remove Tag'));
        expect(removed, 1);
        expect(pressed, 0);
        handle.dispose();
      });

      testWidgets('is pressed from 24px square, and leaves the rest to the chip', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        var removed = 0;
        var pressed = 0;

        await tester.pumpWidget(
          host(
            PlChip(
              // The smallest chip, where the × is drawn furthest below 24px.
              size: PlassSize.xs,
              onPressed: () => pressed += 1,
              onDeleted: () => removed += 1,
              child: const Text('Tag'),
            ),
          ),
        );

        final Rect mark = tester.getRect(find.bySemanticsLabel('Remove Tag'));
        final double across = mark.width / 2 + 3;
        final double down = mark.height / 2 + 3;

        // Just outside the drawn × on every side, and inside the square.
        for (final Offset offset in <Offset>[
          Offset(-across, 0),
          Offset(across, 0),
          Offset(0, -down),
          Offset(0, down),
        ]) {
          await tester.tapAt(mark.center + offset);
        }

        expect(removed, 4);
        expect(pressed, 0);

        await tester.tapAt(mark.center - const Offset(14, 0));

        expect(removed, 4);
        expect(pressed, 1);
        expect(tester.getSize(find.byType(PlChip)).height, 24);
        handle.dispose();
      });

      testWidgets('names each affordance after its own chip', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                PlChip(onDeleted: () {}, child: const Text('Design')),
                PlChip(onDeleted: () {}, child: const Text('Research')),
              ],
            ),
          ),
        );

        expect(find.bySemanticsLabel('Remove Design'), findsOneWidget);
        expect(find.bySemanticsLabel('Remove Research'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('takes the label pack s sentence, or a whole name of its own', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            PlassTheme.merge(
              defaults: const PlassDefaults(
                labels: PlassLabels(remove: '삭제', removeItem: _removeInKorean),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  PlChip(onDeleted: () {}, child: const Text('Design')),
                  PlChip(onDeleted: () {}, deleteLabel: '지우기', child: const Text('Research')),
                  PlChip(onDeleted: () {}, child: const Icon(IconData(0xe000))),
                ],
              ),
            ),
          ),
        );

        // The pack's word in front of the text was English's order in every
        // language, so a Korean screen read "삭제 Design".
        expect(find.bySemanticsLabel('Design 삭제'), findsOneWidget);
        expect(find.bySemanticsLabel('지우기'), findsOneWidget);
        // A chip that is not words is named by the word alone.
        expect(find.bySemanticsLabel('삭제'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('rings the × on its own while it holds the focus', (WidgetTester tester) async {
        final FocusNode before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);
        var removed = 0;

        int rings() {
          return tester
              .widgetList<CustomPaint>(find.byType(CustomPaint))
              .where((CustomPaint paint) => paint.foregroundPainter is PlassFocusRingPainter)
              .length;
        }

        await tester.pumpWidget(
          host(
            afterFocusStop(
              before,
              PlChip(onPressed: () {}, onDeleted: () => removed += 1, child: const Text('Tag')),
            ),
          ),
        );

        before.requestFocus();
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(rings(), 1);

        // On to the ×, with the chip round it no longer ringed too.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(rings(), 1);

        // Still holding the focus it was given.
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();

        expect(removed, 1);
      });
    });
  });
}
