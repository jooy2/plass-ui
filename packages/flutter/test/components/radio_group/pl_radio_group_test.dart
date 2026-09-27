import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

const List<PlRadioOption<String>> plans = <PlRadioOption<String>>[
  PlRadioOption<String>(value: 'starter', label: Text('Starter')),
  PlRadioOption<String>(value: 'team', label: Text('Team')),
  PlRadioOption<String>(value: 'enterprise', label: Text('Enterprise')),
];

/// The same three with the last one closed, for the arrows to step past.
const List<PlRadioOption<String>> tiers = <PlRadioOption<String>>[
  PlRadioOption<String>(value: 'starter', label: Text('Starter')),
  PlRadioOption<String>(value: 'team', label: Text('Team')),
  PlRadioOption<String>(value: 'enterprise', label: Text('Enterprise'), disabled: true),
];

/// The option reading [label], found only while it holds the focus.
Finder focusedOption(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byWidgetPredicate(
      (Widget widget) => widget is Focus && (widget.focusNode?.hasPrimaryFocus ?? false),
    ),
  );
}

void main() {
  group('PlRadioGroup', () {
    group('rendering', () {
      testWidgets('draws every option', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlRadioGroup<String>(options: plans, value: 'team'), width: 320),
        );

        for (final label in <String>['Starter', 'Team', 'Enterprise']) {
          expect(find.text(label), findsOneWidget);
        }
      });

      testWidgets('draws the question and the help under it', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlRadioGroup<String>(
              options: plans,
              value: null,
              label: Text('Plan'),
              description: Text('Change it any time'),
            ),
            width: 320,
          ),
        );

        expect(styleOf(tester, 'Plan').fontWeight, FontWeight.w600);
        expect(styleOf(tester, 'Change it any time').color, PlassTokens.light().mutedFg);
      });
    });

    group('choosing', () {
      testWidgets('reports the option that was pressed', (WidgetTester tester) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            PlRadioGroup<String>(
              options: plans,
              value: 'starter',
              onChanged: (String next) => chosen = next,
            ),
            width: 320,
          ),
        );

        await tester.tap(find.text('Enterprise'));
        expect(chosen, 'enterprise');
      });

      testWidgets('does not fire for a disabled option', (WidgetTester tester) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            PlRadioGroup<String>(
              value: 'a',
              onChanged: (String next) => chosen = next,
              options: const <PlRadioOption<String>>[
                PlRadioOption<String>(value: 'a', label: Text('A')),
                PlRadioOption<String>(value: 'b', label: Text('B'), disabled: true),
              ],
            ),
            width: 320,
          ),
        );

        await tester.tap(find.text('B'));
        expect(chosen, isNull);
      });

      testWidgets('grows the dot out of the ring rather than switching it on', (
        WidgetTester tester,
      ) async {
        String plan = 'starter';

        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return PlRadioGroup<String>(
                  options: plans,
                  value: plan,
                  onChanged: (String next) => setState(() => plan = next),
                );
              },
            ),
            width: 320,
          ),
        );

        // The dot is the innermost box in an option, and it is a real size
        // rather than a scaled one — the ring centres it, so both ends of the
        // animation are laid out about the same point.
        double dotOf(String label) {
          return tester
              .getSize(
                find
                    .descendant(
                      of: find.ancestor(of: find.text(label), matching: find.byType(Row)).last,
                      matching: find.byType(AnimatedContainer),
                    )
                    .last,
              )
              .width;
        }

        expect(dotOf('Enterprise'), 0);

        await tester.tap(find.text('Enterprise'));
        await tester.pump();
        await tester.pump(PlassTokens.duration ~/ 2);

        final double halfway = dotOf('Enterprise');

        expect(halfway, greaterThan(0));

        await tester.pumpAndSettle();

        expect(dotOf('Enterprise'), greaterThan(halfway));
        expect(dotOf('Starter'), 0);
      });
    });

    group('the arrow keys', () {
      testWidgets('move the choice within the set', (WidgetTester tester) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            PlRadioGroup<String>(
              options: plans,
              value: 'starter',
              autofocus: true,
              onChanged: (String next) => chosen = next,
            ),
            width: 320,
          ),
        );
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        expect(chosen, 'team');
      });

      testWidgets('wrap, because a set of alternatives has no beginning', (
        WidgetTester tester,
      ) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            PlRadioGroup<String>(
              options: plans,
              value: 'starter',
              autofocus: true,
              onChanged: (String next) => chosen = next,
            ),
            width: 320,
          ),
        );
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        expect(chosen, 'enterprise');
      });

      testWidgets('skip an option that cannot be chosen', (WidgetTester tester) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            PlRadioGroup<String>(
              value: 'a',
              autofocus: true,
              onChanged: (String next) => chosen = next,
              options: const <PlRadioOption<String>>[
                PlRadioOption<String>(value: 'a', label: Text('A')),
                PlRadioOption<String>(value: 'b', label: Text('B'), disabled: true),
                PlRadioOption<String>(value: 'c', label: Text('C')),
              ],
            ),
            width: 320,
          ),
        );
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        expect(chosen, 'c');
      });

      testWidgets('keep focus on the option the value follows them to', (
        WidgetTester tester,
      ) async {
        String value = 'starter';
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => afterFocusStop(
                before,
                PlRadioGroup<String>(
                  options: plans,
                  value: value,
                  onChanged: (String next) => setState(() => value = next),
                ),
              ),
            ),
            width: 320,
          ),
        );
        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        expect(value, 'enterprise');
        expect(before.hasFocus, isFalse);
      });

      testWidgets('move the focus and not the choice while read-only, skipping and wrapping', (
        WidgetTester tester,
      ) async {
        String? chosen;
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);
        await tester.pumpWidget(
          host(
            afterFocusStop(
              before,
              PlRadioGroup<String>(
                options: tiers,
                value: 'starter',
                readOnly: true,
                onChanged: (String next) => chosen = next,
              ),
            ),
            width: 320,
          ),
        );
        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(focusedOption('Starter'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        expect(focusedOption('Team'), findsOneWidget);

        // Past the closed one and round to the start.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        expect(focusedOption('Starter'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();

        expect(focusedOption('Team'), findsOneWidget);
        expect(chosen, isNull);
        expect(before.hasFocus, isFalse);
      });

      testWidgets('follow the writing direction sideways while read-only', (
        WidgetTester tester,
      ) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            PlRadioGroup<String>(
              options: plans,
              value: 'starter',
              readOnly: true,
              orientation: PlassOrientation.horizontal,
              autofocus: true,
              onChanged: (String next) => chosen = next,
            ),
            width: 480,
            textDirection: TextDirection.rtl,
          ),
        );
        await tester.pump();

        // Under RTL the next option is to the left.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();

        expect(focusedOption('Team'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();

        expect(focusedOption('Starter'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();

        expect(focusedOption('Enterprise'), findsOneWidget);
        expect(chosen, isNull);
      });

      testWidgets('leave the stop where they moved it in a read-only set', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);
        await tester.pumpWidget(
          host(
            afterFocusStop(
              before,
              PlRadioGroup<String>(
                options: plans,
                value: 'starter',
                readOnly: true,
                onChanged: (String _) {},
              ),
            ),
            width: 320,
          ),
        );
        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pumpAndSettle();

        expect(before.hasFocus, isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(focusedOption('Team'), findsOneWidget);
      });

      testWidgets('give the stop back to the chosen option as the choice changes from outside', (
        WidgetTester tester,
      ) async {
        String value = 'starter';
        late StateSetter rebuild;
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                rebuild = setState;

                return PlRadioGroup<String>(
                  options: plans,
                  value: value,
                  readOnly: true,
                  autofocus: true,
                  onChanged: (String _) {},
                );
              },
            ),
            width: 320,
          ),
        );
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        expect(focusedOption('Team'), findsOneWidget);

        rebuild(() => value = 'enterprise');
        await tester.pumpAndSettle();

        expect(focusedOption('Enterprise'), findsOneWidget);
      });

      testWidgets('give the stop back to the chosen option as a read-only set turns live', (
        WidgetTester tester,
      ) async {
        bool readOnly = true;
        late StateSetter rebuild;
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                rebuild = setState;

                return PlRadioGroup<String>(
                  options: plans,
                  value: 'starter',
                  readOnly: readOnly,
                  autofocus: true,
                  onChanged: (String _) {},
                );
              },
            ),
            width: 320,
          ),
        );
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        expect(focusedOption('Team'), findsOneWidget);

        rebuild(() => readOnly = false);
        await tester.pumpAndSettle();

        expect(focusedOption('Starter'), findsOneWidget);
      });

      testWidgets('do nothing in a disabled set and hand the key on, read-only or not', (
        WidgetTester tester,
      ) async {
        for (final bool readOnly in <bool>[true, false]) {
          String? chosen;

          // Directional navigation is where a disabled option can still hold
          // the focus, so the arrows reach the set at all, and where they are
          // the only way out of it.
          await tester.pumpWidget(
            host(
              MediaQuery(
                data: const MediaQueryData(navigationMode: NavigationMode.directional),
                child: PlRadioGroup<String>(
                  key: ValueKey<bool>(readOnly),
                  options: plans,
                  value: 'starter',
                  readOnly: readOnly,
                  disabled: true,
                  autofocus: true,
                  onChanged: (String next) => chosen = next,
                ),
              ),
              width: 320,
            ),
          );
          await tester.pump();

          expect(focusedOption('Starter'), findsOneWidget);

          final bool handled = await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();

          expect(handled, isFalse);
          expect(focusedOption('Starter'), findsOneWidget);
          expect(chosen, isNull);
        }
      });

      for (final NavigationMode mode in NavigationMode.values) {
        testWidgets('go round past the first option only in traditional navigation, ${mode.name}', (
          WidgetTester tester,
        ) async {
          for (final bool readOnly in <bool>[false, true]) {
            String value = 'starter';
            final FocusNode before = FocusNode(debugLabel: 'before');
            addTearDown(before.dispose);

            // Under directional navigation the arrows are the only way out of
            // the set, so the one past the end goes on to the stop above
            // rather than round to the last option.
            await tester.pumpWidget(
              host(
                inNavigationMode(
                  mode,
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) => afterFocusStop(
                      before,
                      PlRadioGroup<String>(
                        key: ValueKey<bool>(readOnly),
                        options: plans,
                        value: value,
                        readOnly: readOnly,
                        onChanged: (String next) => setState(() => value = next),
                      ),
                    ),
                  ),
                ),
                width: 320,
              ),
            );
            before.requestFocus();
            await tester.pump();
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.pumpAndSettle();

            expect(focusedOption('Starter'), findsOneWidget);

            await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
            await tester.pumpAndSettle();

            final String reason = 'read-only $readOnly';

            if (mode == NavigationMode.traditional) {
              expect(focusedOption('Enterprise'), findsOneWidget, reason: reason);
              expect(value, readOnly ? 'starter' : 'enterprise', reason: reason);
            } else {
              expect(before.hasPrimaryFocus, isTrue, reason: reason);
              expect(value, 'starter', reason: reason);
            }
          }
        });
      }
    });

    group('error', () {
      testWidgets('turns the whole set over to danger', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlRadioGroup<String>(options: plans, value: 'team', error: Text('Pick one')),
            width: 320,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          styleOf(tester, 'Pick one').color,
          PlassTokens.light().family(PlassColor.danger).accent,
        );
      });
    });

    group('accessibility', () {
      testWidgets('the option that holds the set\'s stop says it can take the focus', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        String value = 'team';

        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return PlRadioGroup<String>(
                  options: plans,
                  value: value,
                  autofocus: true,
                  onChanged: (String next) => setState(() => value = next),
                );
              },
            ),
            width: 320,
          ),
        );
        await tester.pumpAndSettle();

        // On the option's own node, with its name, its state and its tap, and
        // only on the one option Tab reaches.
        for (final String chosen in <String>['Team', 'Enterprise']) {
          for (final String label in <String>['Starter', 'Team', 'Enterprise']) {
            expect(
              tester.getSemantics(find.text(label)),
              label == chosen
                  ? isSemantics(
                      label: label,
                      isChecked: true,
                      isFocusable: true,
                      isFocused: true,
                      hasTapAction: true,
                      hasFocusAction: true,
                    )
                  : isSemantics(label: label, isFocusable: false, hasFocusAction: false),
              reason: '$label, with $chosen chosen',
            );
          }

          expect(find.semantics.byFlag(SemanticsFlag.isFocusable), findsOne);

          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
        }

        handle.dispose();
      });

      testWidgets('an option says it is one of a set', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlRadioGroup<String>(options: plans, value: 'team', onChanged: (String _) {}),
            width: 320,
          ),
        );

        expect(
          tester.getSemantics(find.text('Team')),
          isSemantics(isInMutuallyExclusiveGroup: true, isChecked: true),
        );

        handle.dispose();
      });

      testWidgets('the set and its options are read-only rather than disabled while read-only', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlRadioGroup<String>(
              options: plans,
              value: 'team',
              readOnly: true,
              onChanged: (String _) {},
            ),
            width: 320,
          ),
        );

        // The set keeps its focus stop, so a screen reader has to hear options
        // that cannot be changed rather than options that are unavailable.
        final set = tester.getSemantics(
          find
              .descendant(
                of: find.byType(PlRadioGroup<String>),
                matching: find.byWidgetPredicate(
                  (Widget widget) => widget is Semantics && widget.container,
                ),
              )
              .first,
        );

        expect(set, isSemantics(hasEnabledState: true, isEnabled: true, isReadOnly: true));

        for (final label in <String>['Starter', 'Team']) {
          expect(
            tester.getSemantics(find.text(label)),
            isSemantics(
              hasEnabledState: true,
              isEnabled: true,
              isReadOnly: true,
              hasTapAction: false,
            ),
          );
        }

        handle.dispose();
      });

      testWidgets('an arrow in a read-only set moves the focus and changes nothing it says', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlRadioGroup<String>(
              options: plans,
              value: 'team',
              readOnly: true,
              autofocus: true,
              onChanged: (String _) {},
            ),
            width: 320,
          ),
        );
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        expect(focusedOption('Enterprise'), findsOneWidget);

        final set = tester.getSemantics(
          find
              .descendant(
                of: find.byType(PlRadioGroup<String>),
                matching: find.byWidgetPredicate(
                  (Widget widget) => widget is Semantics && widget.container,
                ),
              )
              .first,
        );

        expect(set, isSemantics(hasEnabledState: true, isEnabled: true, isReadOnly: true));

        for (final label in <String>['Starter', 'Team', 'Enterprise']) {
          expect(
            tester.getSemantics(find.text(label)),
            isSemantics(
              isInMutuallyExclusiveGroup: true,
              hasCheckedState: true,
              isChecked: label == 'Team',
              hasEnabledState: true,
              isEnabled: true,
              isReadOnly: true,
              hasTapAction: false,
            ),
          );
        }

        handle.dispose();
      });

      testWidgets('the set takes one focus stop rather than one per option', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlRadioGroup<String>(options: plans, value: 'team', onChanged: (String _) {}),
            width: 320,
          ),
        );

        // The roving tab index: every option answers the pointer, and exactly
        // one of them is in the tab order.
        final inOrder = tester
            .widgetList<ExcludeFocus>(find.byType(ExcludeFocus))
            .where((ExcludeFocus excluded) => !excluded.excluding)
            .length;

        expect(inOrder, 1);
      });
    });
  });
}
