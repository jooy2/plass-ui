import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';

import '../../support/host.dart';

/// A control with a `State` of its own: built again from scratch, it is a
/// different object.
class _Probe extends StatefulWidget {
  const _Probe();

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => const Text('Street');
}

void main() {
  group('PlFieldset', () {
    testWidgets('draws the legend and the description above the controls', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const PlFieldset(
            legend: Text('Billing address'),
            description: Text('Where the invoice goes'),
            children: <Widget>[Text('Street')],
          ),
          width: 400,
          height: 300,
        ),
      );

      expect(
        tester.getTopLeft(find.text('Billing address')).dy,
        lessThan(tester.getTopLeft(find.text('Where the invoice goes')).dy),
      );
      expect(
        tester.getTopLeft(find.text('Where the invoice goes')).dy,
        lessThan(tester.getTopLeft(find.text('Street')).dy),
      );
    });

    testWidgets('draws no heading block when there is nothing to say', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PlFieldset(children: <Widget>[Text('Street')]), width: 400, height: 300),
      );

      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('draws no surface, because a grouping is not a sheet', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlFieldset(legend: Text('Group'), children: <Widget>[Text('Street')]),
          width: 400,
          height: 300,
        ),
      );

      expect(decorationsOf(tester, find.byType(PlFieldset)), isEmpty);
    });

    testWidgets('stands its controls apart on the sheet ladder', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlFieldset(size: PlassSize.xs, children: <Widget>[Text('One'), Text('Two')]),
          width: 400,
          height: 300,
        ),
      );

      final Column column = tester.widget<Column>(
        find.descendant(of: find.byType(PlFieldset), matching: find.byType(Column)).first,
      );

      expect(column.spacing, 6);
    });

    group('disabled', () {
      testWidgets('takes the pointer away from everything inside', (WidgetTester tester) async {
        int pressed = 0;

        await tester.pumpWidget(
          host(
            PlFieldset(
              disabled: true,
              legend: const Text('Billing address'),
              children: <Widget>[
                PlButton(onPressed: () => pressed += 1, child: const Text('Save')),
              ],
            ),
            width: 400,
            height: 300,
          ),
        );

        await tester.tap(find.text('Save'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(pressed, 0);
      });

      testWidgets('reaches one it never heard of, three levels down', (WidgetTester tester) async {
        int pressed = 0;

        await tester.pumpWidget(
          host(
            PlFieldset(
              disabled: true,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        PlButton(onPressed: () => pressed += 1, child: const Text('Save')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            width: 400,
            height: 300,
          ),
        );

        await tester.tap(find.text('Save'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(pressed, 0);
      });

      testWidgets('takes the focus away as well', (WidgetTester tester) async {
        final FocusNode save = FocusNode();
        addTearDown(save.dispose);

        Widget group({bool disabled = false}) {
          return host(
            PlFieldset(
              disabled: disabled,
              children: <Widget>[
                PlButton(onPressed: () {}, focusNode: save, child: const Text('Save')),
              ],
            ),
            width: 400,
            height: 300,
          );
        }

        await tester.pumpWidget(group(disabled: true));
        save.requestFocus();
        await tester.pump();

        expect(save.hasFocus, isFalse, reason: 'disabled');

        await tester.pumpWidget(group());
        save.requestFocus();
        await tester.pump();

        expect(save.hasFocus, isTrue, reason: 'enabled');
      });

      testWidgets('keeps what the group holds as it is disabled and enabled again', (
        WidgetTester tester,
      ) async {
        Widget group({bool disabled = false}) {
          return host(
            PlFieldset(
              disabled: disabled,
              legend: const Text('Billing address'),
              children: const <Widget>[_Probe()],
            ),
            width: 400,
            height: 300,
          );
        }

        await tester.pumpWidget(group());
        final State<_Probe> held = tester.state(find.byType(_Probe));

        for (final (String reason, Widget next) in <(String, Widget)>[
          ('disabled', group(disabled: true)),
          ('enabled again', group()),
        ]) {
          await tester.pumpWidget(next);
          await tester.pumpAndSettle();

          // A field built again from scratch would have lost what was typed
          // into it.
          expect(tester.state(find.byType(_Probe)), same(held), reason: reason);
        }
      });

      testWidgets('drains the group the way every disabled surface is drained', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlFieldset(
              disabled: true,
              children: <Widget>[PlButton(onPressed: () {}, child: const Text('Save'))],
            ),
            width: 400,
            height: 300,
          ),
        );

        expect(
          find.descendant(
            of: find.byType(PlFieldset),
            matching: find.byWidgetPredicate(
              (Widget widget) => widget is PlassFiltered && widget.opacity == disabledOpacity,
            ),
          ),
          findsWidgets,
        );
      });

      testWidgets('leaves them alone when it is off', (WidgetTester tester) async {
        int pressed = 0;

        await tester.pumpWidget(
          host(
            PlFieldset(
              children: <Widget>[
                PlButton(onPressed: () => pressed += 1, child: const Text('Save')),
              ],
            ),
            width: 400,
            height: 300,
          ),
        );

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(pressed, 1);
      });
    });
  });
}
