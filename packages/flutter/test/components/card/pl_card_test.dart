import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
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
