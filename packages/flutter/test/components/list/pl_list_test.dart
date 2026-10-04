import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// Content with a `State` of its own: built again from scratch, it is a
/// different object, where a field would have lost what was typed into it.
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

/// Whether the focus is on something inside the list.
bool _holdsFocus(WidgetTester tester) {
  final BuildContext? focused = FocusManager.instance.primaryFocus?.context;

  return focused != null &&
      find
          .descendant(
            of: find.byType(PlList),
            matching: find.byElementPredicate((Element element) => element == focused),
          )
          .evaluate()
          .isNotEmpty;
}

/// Moves the focus to [before] and presses Tab once, as a keyboard reader
/// arriving at the list does.
Future<void> _tabFrom(WidgetTester tester, FocusNode before) async {
  before.requestFocus();
  await tester.pump();
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pump();
}

void main() {
  group('PlList', () {
    group('rendering', () {
      testWidgets('stacks its rows', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlList(
              children: <Widget>[
                PlListItem(child: Text('Billing')),
                PlListItem(child: Text('Members')),
              ],
            ),
            width: 320,
          ),
        );

        expect(find.text('Billing'), findsOneWidget);
        expect(
          tester.getRect(find.text('Members')).top,
          greaterThan(tester.getRect(find.text('Billing')).top),
        );
      });

      testWidgets('sets a description under the label, muted', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlList(
              children: <Widget>[
                PlListItem(description: Text('Visa 4242'), child: Text('Billing')),
              ],
            ),
            width: 320,
          ),
        );

        expect(styleOf(tester, 'Visa 4242').color, PlassTokens.light().mutedFg);
      });
    });

    group('the sheet', () {
      testWidgets('is glass and is never dyed', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlList(
              color: PlassColor.danger,
              children: <Widget>[PlListItem(child: Text('One'))],
            ),
            width: 320,
          ),
        );

        expect(
          decorationWhere(
            tester,
            find.byType(PlList),
            (BoxDecoration decoration) => decoration.border != null,
          ).color,
          PlassTokens.light().glass,
        );
      });
    });

    group('dividers', () {
      testWidgets('rules the rows with the neutral ink', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlList(
              dividers: true,
              children: <Widget>[
                PlListItem(child: Text('One')),
                PlListItem(child: Text('Two')),
              ],
            ),
            width: 320,
          ),
        );

        final ruled = decorationsOf(tester, find.byType(PlList))
            .where((BoxDecoration decoration) => decoration.border is Border)
            .map((BoxDecoration decoration) => (decoration.border! as Border).top.color)
            .toList();

        expect(ruled, contains(PlassTokens.light().divider));
      });

      testWidgets('takes the sheet padding away, so the rules reach both edges', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlList(children: <Widget>[PlListItem(child: Text('One'))]), width: 320),
        );
        final tiled = tester.getRect(find.text('One')).left;

        await tester.pumpWidget(
          host(
            const PlList(dividers: true, children: <Widget>[PlListItem(child: Text('One'))]),
            width: 320,
          ),
        );

        expect(tester.getRect(find.text('One')).left, lessThan(tiled));
      });
    });

    group('rows', () {
      testWidgets('is not a focus stop until it can be pressed', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const PlList(children: <Widget>[PlListItem(child: Text('One'))]), width: 320),
        );

        expect(tester.getSemantics(find.text('One')), isSemantics(isButton: false));
        handle.dispose();
      });

      testWidgets('fires when pressed', (WidgetTester tester) async {
        var pressed = 0;
        await tester.pumpWidget(
          host(
            PlList(
              children: <Widget>[
                PlListItem(onPressed: () => pressed += 1, child: const Text('One')),
              ],
            ),
            width: 320,
          ),
        );

        await tester.tap(find.text('One'));
        expect(pressed, 1);
      });

      testWidgets('wears the family when it is the chosen one', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlList(
              children: <Widget>[
                PlListItem(selected: true, onPressed: () {}, child: const Text('One')),
              ],
            ),
            width: 320,
          ),
        );

        expect(styleOf(tester, 'One').color, PlassTokens.light().family(PlassColor.primary).accent);
      });

      testWidgets('keeps an action outside the pressable area', (WidgetTester tester) async {
        var rowPressed = 0;
        var actionPressed = 0;

        await tester.pumpWidget(
          host(
            PlList(
              children: <Widget>[
                PlListItem(
                  onPressed: () => rowPressed += 1,
                  action: PlButton(
                    size: PlassSize.xs,
                    onPressed: () => actionPressed += 1,
                    child: const Text('Go'),
                  ),
                  child: const Text('One'),
                ),
              ],
            ),
            width: 320,
          ),
        );

        await tester.tap(find.text('Go'));
        expect(actionPressed, 1);
        expect(rowPressed, 0);
      });

      testWidgets('does not fire while disabled', (WidgetTester tester) async {
        var pressed = 0;
        await tester.pumpWidget(
          host(
            PlList(
              children: <Widget>[
                PlListItem(disabled: true, onPressed: () => pressed += 1, child: const Text('One')),
              ],
            ),
            width: 320,
          ),
        );

        await tester.tap(find.text('One'));
        expect(pressed, 0);
      });

      testWidgets('is a button that is unavailable while disabled with onPressed', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            PlList(
              children: <Widget>[
                PlListItem(disabled: true, onPressed: () {}, child: const Text('One')),
                const PlListItem(disabled: true, child: Text('Two')),
              ],
            ),
            width: 320,
          ),
        );

        expect(
          tester.getSemantics(find.text('One')),
          isSemantics(isButton: true, hasEnabledState: true, isEnabled: false, hasTapAction: false),
        );
        // With nothing to press, it stays a row that says it is unavailable.
        expect(
          tester.getSemantics(find.text('Two')),
          isSemantics(isButton: false, hasEnabledState: true, isEnabled: false),
        );
        handle.dispose();
      });

      testWidgets('is not announced as selected while disabled', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            PlList(
              children: <Widget>[
                PlListItem(
                  selected: true,
                  disabled: true,
                  onPressed: () {},
                  child: const Text('One'),
                ),
                const PlListItem(selected: true, disabled: true, child: Text('Two')),
              ],
            ),
            width: 320,
          ),
        );

        // Drawn with no tint, a disabled row says what an unchosen row says,
        // whether it is a button or not, as the React row drops
        // `aria-current`.
        expect(
          tester.getSemantics(find.text('One')),
          isSemantics(
            isButton: true,
            hasEnabledState: true,
            isEnabled: false,
            hasSelectedState: true,
            isSelected: false,
          ),
        );
        expect(
          tester.getSemantics(find.text('Two')),
          isSemantics(
            isButton: false,
            hasEnabledState: true,
            isEnabled: false,
            hasSelectedState: true,
            isSelected: false,
          ),
        );
        handle.dispose();
      });

      testWidgets('sets its label at the weight of an unchosen row while disabled', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlList(
              children: <Widget>[
                PlListItem(
                  selected: true,
                  disabled: true,
                  onPressed: () {},
                  child: const Text('One'),
                ),
                const PlListItem(selected: true, disabled: true, child: Text('Two')),
                const PlListItem(child: Text('Three')),
                const PlListItem(selected: true, child: Text('Four')),
              ],
            ),
            width: 320,
          ),
        );

        final FontWeight? unchosen = styleOf(tester, 'Three').fontWeight;

        expect(styleOf(tester, 'Four').fontWeight, FontWeight.w500);
        expect(unchosen, isNot(FontWeight.w500));
        // Drawn with no tint, a disabled row is set as an unchosen row is, as
        // the React row drops `font-medium` with the tint. It used to keep the
        // chosen row's weight.
        expect(styleOf(tester, 'One').fontWeight, unchosen);
        expect(styleOf(tester, 'Two').fontWeight, unchosen);
      });

      testWidgets('keeps what it holds as onPressed, disabled and selected change', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        final before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);

        Widget list({bool pressable = false, bool disabled = false, bool selected = false}) {
          return host(
            afterFocusStop(
              before,
              PlList(
                children: <Widget>[
                  PlListItem(
                    onPressed: pressable ? () {} : null,
                    disabled: disabled,
                    selected: selected,
                    startIcon: const _Probe('S'),
                    endIcon: const _Probe('E'),
                    description: const _Probe('Visa 4242'),
                    child: const _Probe('Billing'),
                  ),
                ],
              ),
            ),
            width: 320,
          );
        }

        await tester.pumpWidget(list());

        final List<State<_Probe>> resting = tester
            .stateList<State<_Probe>>(find.byType(_Probe))
            .toList();

        expect(resting, hasLength(4));

        // Every way a row can change what it does, and back.
        for (final (bool pressable, bool disabled, bool selected) in <(bool, bool, bool)>[
          (true, false, false),
          (true, true, false),
          (true, false, true),
          (true, true, true),
          (false, false, true),
          (false, true, true),
          (false, true, false),
          (true, false, false),
          (false, false, false),
        ]) {
          final String reason = 'pressable $pressable, disabled $disabled, selected $selected';
          final bool interactive = pressable && !disabled;

          await tester.pumpWidget(
            list(pressable: pressable, disabled: disabled, selected: selected),
          );

          // Built again from scratch, a probe is a different object, and a
          // field in its place would have lost what was typed into it.
          final List<State<_Probe>> now = tester
              .stateList<State<_Probe>>(find.byType(_Probe))
              .toList();

          for (var index = 0; index < resting.length; index += 1) {
            expect(now[index], same(resting[index]), reason: 'probe $index, $reason');
          }

          // A button with its tap only while it can be pressed, a button that
          // is unavailable while it is disabled, and otherwise a row that says
          // whether it is available, as it always said. Chosen only while it
          // is not disabled.
          expect(
            tester.getSemantics(find.text('Billing')),
            interactive
                ? isSemantics(
                    isButton: true,
                    hasTapAction: true,
                    hasEnabledState: false,
                    hasSelectedState: true,
                    isSelected: selected,
                  )
                : isSemantics(
                    isButton: pressable,
                    hasTapAction: false,
                    hasEnabledState: true,
                    isEnabled: !disabled,
                    hasSelectedState: true,
                    isSelected: selected && !disabled,
                  ),
            reason: reason,
          );

          await _tabFrom(tester, before);

          expect(_holdsFocus(tester), interactive, reason: reason);
        }

        handle.dispose();
      });

      testWidgets('is a focus stop on a remote only while it can be pressed, on any focus node', (
        WidgetTester tester,
      ) async {
        final before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);
        final given = FocusNode(debugLabel: 'given');
        addTearDown(given.dispose);

        // Directional navigation is where an unavailable control is still a
        // stop, so a reader can find it. A row that cannot be pressed was never
        // one, whether it has nothing to do or is disabled, and whether it
        // makes its own focus node or is handed one.
        for (final bool handed in <bool>[false, true]) {
          // Each way the row can be, in turn, on one row.
          for (final (bool onPressed, bool disabled) in <(bool, bool)>[
            (false, false),
            (true, true),
            (true, false),
            (true, true),
            (false, false),
          ]) {
            await tester.pumpWidget(
              host(
                MediaQuery(
                  data: const MediaQueryData(navigationMode: NavigationMode.directional),
                  child: afterFocusStop(
                    before,
                    PlList(
                      children: <Widget>[
                        PlListItem(
                          onPressed: onPressed ? () {} : null,
                          disabled: disabled,
                          focusNode: handed ? given : null,
                          child: const Text('Billing'),
                        ),
                      ],
                    ),
                  ),
                ),
                width: 320,
              ),
            );

            await _tabFrom(tester, before);

            expect(
              _holdsFocus(tester),
              onPressed && !disabled,
              reason: 'handed $handed, onPressed $onPressed, disabled $disabled',
            );
          }
        }
      });
    });
  });
}
