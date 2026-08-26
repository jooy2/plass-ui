import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/icons.dart';

import '../../support/host.dart';

void main() {
  group('PlTextLink', () {
    group('rendering', () {
      testWidgets('renders its label', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlTextLink(onPressed: () {}, child: const Text('the changelog'))),
        );

        expect(find.text('the changelog'), findsOneWidget);
      });

      testWidgets('fires when followed', (WidgetTester tester) async {
        var followed = 0;
        await tester.pumpWidget(
          host(PlTextLink(onPressed: () => followed += 1, child: const Text('go'))),
        );

        await tester.tap(find.text('go'));
        expect(followed, 1);
      });
    });

    group('underline', () {
      testWidgets('draws the line by default', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlTextLink(onPressed: () {}, child: const Text('go'))));

        expect(styleOf(tester, 'go').decoration, TextDecoration.underline);
      });

      testWidgets('holds it back until the pointer arrives', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlTextLink(
              onPressed: () {},
              underline: PlTextLinkUnderline.hover,
              child: const Text('go'),
            ),
          ),
        );

        expect(styleOf(tester, 'go').decoration, TextDecoration.none);
      });

      testWidgets('leaves it off entirely when asked', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlTextLink(
              onPressed: () {},
              underline: PlTextLinkUnderline.none,
              child: const Text('go'),
            ),
          ),
        );

        expect(styleOf(tester, 'go').decoration, TextDecoration.none);
      });
    });

    group('colour', () {
      testWidgets('inherits rather than arriving pre-dyed', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            DefaultTextStyle(
              style: const TextStyle(color: Color(0xFF00FF00)),
              child: PlTextLink(onPressed: () {}, child: const Text('go')),
            ),
          ),
        );

        expect(styleOf(tester, 'go').color, const Color(0xFF00FF00));
      });

      testWidgets('wears a family accent when one is asked for', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlTextLink(onPressed: () {}, color: PlassColor.danger, child: const Text('go'))),
        );

        expect(styleOf(tester, 'go').color, PlassTokens.light().family(PlassColor.danger).accent);
      });

      testWidgets('rests the line short of the full colour', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlTextLink(onPressed: () {}, child: const Text('go'))));

        final style = styleOf(tester, 'go');

        expect(style.decorationColor, isNot(style.color));
      });
    });

    group('the mark', () {
      testWidgets('is off for a link that stays put', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlTextLink(onPressed: () {}, child: const Text('go'))));

        expect(find.byType(PlassGlyph), findsNothing);
      });

      testWidgets('follows external without being asked', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlTextLink(onPressed: () {}, external: true, child: const Text('go'))),
        );

        expect(find.byType(PlassGlyph), findsOneWidget);
      });

      testWidgets('can be asked for on a link that stays put', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlTextLink(onPressed: () {}, showIcon: true, child: const Text('go'))),
        );

        expect(find.byType(PlassGlyph), findsOneWidget);
      });

      testWidgets('can be silenced on an external one', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlTextLink(onPressed: () {}, external: true, showIcon: false, child: const Text('go')),
          ),
        );

        expect(find.byType(PlassGlyph), findsNothing);
      });
    });

    group('accessibility', () {
      testWidgets('is a link rather than a button', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(PlTextLink(onPressed: () {}, child: const Text('go'))));

        final node = tester.getSemantics(find.text('go'));

        expect(node.flagsCollection.isLink, isTrue);
        expect(node.flagsCollection.isButton, isFalse);
        handle.dispose();
      });

      testWidgets('says an external link leaves', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(PlTextLink(onPressed: () {}, external: true, child: const Text('go'))),
        );

        expect(tester.getSemantics(find.text('go')).hint, '(opens elsewhere)');
        handle.dispose();
      });
    });
  });
}
