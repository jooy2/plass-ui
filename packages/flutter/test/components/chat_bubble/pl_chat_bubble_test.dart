import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/icons.dart';

import '../../support/host.dart';

Finder _glyph(PlassGlyphShape shape) =>
    find.byWidgetPredicate((Widget widget) => widget is PlassGlyph && widget.shape == shape);

void main() {
  group('PlChatBubble', () {
    group('shapes', () {
      testWidgets('is the message and nothing else by default', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlChatBubble(child: Text('On my way.')), width: 400));

        expect(find.text('On my way.'), findsOneWidget);
        expect(find.byType(PlassGlyph), findsNothing);
      });

      testWidgets('draws the name and the time above it', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlChatBubble(name: Text('Ada'), time: Text('09:12'), child: Text('On my way.')),
            width: 400,
          ),
        );

        expect(
          tester.getTopLeft(find.text('Ada')).dy,
          lessThan(tester.getTopLeft(find.text('On my way.')).dy),
        );
        expect(
          tester.getTopLeft(find.text('Ada')).dx,
          lessThan(tester.getTopLeft(find.text('09:12')).dx),
        );
      });

      testWidgets('cuts the corner nearest the speaker', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlChatBubble(child: Text('Hello')), width: 400));

        final start =
            decorationWhere(
                  tester,
                  find.byType(PlChatBubble),
                  (BoxDecoration decoration) => decoration.borderRadius != null,
                ).borderRadius!
                as BorderRadius;

        expect(start.topLeft.x, lessThan(start.topRight.x));
        expect(start.bottomLeft, start.bottomRight);
      });

      testWidgets('and the other one for the reader’s own message', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlChatBubble(side: PlChatBubbleSide.end, child: Text('Hello')), width: 400),
        );

        final end =
            decorationWhere(
                  tester,
                  find.byType(PlChatBubble),
                  (BoxDecoration decoration) => decoration.borderRadius != null,
                ).borderRadius!
                as BorderRadius;

        expect(end.topRight.x, lessThan(end.topLeft.x));
      });

      testWidgets('a solid bubble is the gradient with its own ink', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlChatBubble(variant: PlassVariant.solid, child: Text('Mine')), width: 400),
        );

        final family = PlassTokens.light().family(PlassColor.primary);
        final sheet = decorationWhere(
          tester,
          find.byType(PlChatBubble),
          (BoxDecoration decoration) => decoration.gradient != null,
        );

        expect((sheet.gradient! as LinearGradient).colors.first, family.solid);
        expect(styleOf(tester, 'Mine').color, family.onSolid);
      });

      testWidgets('the reader’s own message runs from the other end', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlChatBubble(
              side: PlChatBubbleSide.end,
              avatar: SizedBox(width: 24, height: 24, child: Text('A')),
              child: Text('Mine'),
            ),
            width: 400,
          ),
        );

        expect(
          tester.getCenter(find.text('A')).dx,
          greaterThan(tester.getCenter(find.text('Mine')).dx),
        );
      });
    });

    group('status', () {
      testWidgets('draws nothing without one', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlChatBubble(child: Text('Hi')), width: 400));

        expect(_glyph(PlassGlyphShape.check), findsNothing);
      });

      testWidgets('one mark per step, and the double tick for two of them', (
        WidgetTester tester,
      ) async {
        for (final (PlChatBubbleStatus status, PlassGlyphShape shape)
            in <(PlChatBubbleStatus, PlassGlyphShape)>[
              (PlChatBubbleStatus.sending, PlassGlyphShape.clock),
              (PlChatBubbleStatus.sent, PlassGlyphShape.check),
              (PlChatBubbleStatus.delivered, PlassGlyphShape.doubleCheck),
              (PlChatBubbleStatus.read, PlassGlyphShape.doubleCheck),
              (PlChatBubbleStatus.failed, PlassGlyphShape.dangerMark),
            ]) {
          await tester.pumpWidget(
            host(PlChatBubble(status: status, child: const Text('Hi')), width: 400),
          );

          expect(_glyph(shape), findsOneWidget, reason: '$status');
        }
      });

      testWidgets('only what arrived and what did not carry a colour', (WidgetTester tester) async {
        final tokens = PlassTokens.light();

        Future<Color?> tone(PlChatBubbleStatus status) async {
          await tester.pumpWidget(
            host(PlChatBubble(status: status, child: const Text('Hi')), width: 400),
          );

          return tester.widgetList<PlassGlyph>(find.byType(PlassGlyph)).first.color;
        }

        expect(await tone(PlChatBubbleStatus.sent), tokens.mutedFg);
        expect(await tone(PlChatBubbleStatus.read), tokens.family(PlassColor.primary).accent);
        expect(await tone(PlChatBubbleStatus.failed), tokens.family(PlassColor.danger).accent);
      });

      testWidgets('the mark says what it means', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const PlChatBubble(status: PlChatBubbleStatus.read, child: Text('Hi')), width: 400),
        );

        expect(find.bySemanticsLabel('Read'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('and says what it was told to instead', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            const PlChatBubble(
              status: PlChatBubbleStatus.read,
              statusLabel: '읽음',
              child: Text('Hi'),
            ),
            width: 400,
          ),
        );

        expect(find.bySemanticsLabel('읽음'), findsOneWidget);
        handle.dispose();
      });
    });

    group('typing', () {
      testWidgets('the dots take the message’s place without taking it away', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlChatBubble(typing: true, child: Text('Draft')), width: 400),
        );

        expect(find.text('Draft'), findsNothing);

        await tester.pumpWidget(host(const PlChatBubble(child: Text('Draft')), width: 400));

        expect(find.text('Draft'), findsOneWidget);
      });

      testWidgets('and say what they are', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlChatBubble(typing: true), width: 400));

        expect(find.bySemanticsLabel('Typing…'), findsOneWidget);
        handle.dispose();
      });
    });

    group('preview', () {
      testWidgets('unfurls under the message and answers a press', (WidgetTester tester) async {
        var opened = 0;
        await tester.pumpWidget(
          host(
            PlChatBubble(
              preview: PlChatBubbleLinkPreview(
                onPressed: () => opened += 1,
                site: const Text('plass.cdget.com'),
                title: const Text('Prop conventions'),
              ),
              child: const Text('Have a look'),
            ),
            width: 400,
          ),
        );

        expect(
          tester.getTopLeft(find.text('Prop conventions')).dy,
          greaterThan(tester.getTopLeft(find.text('Have a look')).dy),
        );

        await tester.tap(find.text('Prop conventions'));
        expect(opened, 1);
      });
    });
  });
}
