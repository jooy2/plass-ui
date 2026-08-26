import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

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
    });
  });
}
