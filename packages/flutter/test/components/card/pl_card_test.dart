import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

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
    });
  });
}
