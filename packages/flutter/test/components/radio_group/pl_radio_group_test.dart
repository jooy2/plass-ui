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
