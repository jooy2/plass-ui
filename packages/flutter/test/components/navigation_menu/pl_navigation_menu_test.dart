import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/icons.dart';

import '../../support/host.dart';

List<PlNavigationMenuItem> menu({VoidCallback? onPricing, VoidCallback? onAnalytics}) {
  return <PlNavigationMenuItem>[
    PlNavigationMenuItem(
      label: 'Product',
      links: <PlNavigationMenuLink>[
        PlNavigationMenuLink(
          title: 'Analytics',
          description: 'Numbers over time',
          onPressed: onAnalytics,
        ),
        const PlNavigationMenuLink(title: 'Billing'),
      ],
    ),
    PlNavigationMenuItem(label: 'Pricing', onPressed: onPricing),
  ];
}

void main() {
  group('PlNavigationMenu', () {
    group('the row', () {
      testWidgets('claims the navigation landmark', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(PlNavigationMenu(items: menu()), width: 600, height: 400, overlay: true),
        );

        expect(
          semanticsOf(tester, find.byType(PlNavigationMenu)).getSemanticsData().role,
          SemanticsRole.navigation,
        );

        handle.dispose();
      });

      testWidgets('takes a name of its own', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            PlNavigationMenu(items: menu(), semanticLabel: 'Main'),
            width: 600,
            height: 400,
            overlay: true,
          ),
        );

        expect(semanticsOf(tester, find.byType(PlNavigationMenu)).getSemanticsData().label, 'Main');

        handle.dispose();
      });

      testWidgets('draws every item as a word in the row', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlNavigationMenu(items: menu()), width: 600, height: 400, overlay: true),
        );

        expect(find.text('Product'), findsOneWidget);
        expect(find.text('Pricing'), findsOneWidget);
        // The panel is not in the tree until it is opened.
        expect(find.text('Analytics'), findsNothing);
      });

      testWidgets('runs the other way when it is told to', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlNavigationMenu(items: menu(), orientation: PlassOrientation.vertical),
            width: 600,
            height: 400,
            overlay: true,
          ),
        );

        expect(
          tester.getTopLeft(find.text('Product')).dy,
          lessThan(tester.getTopLeft(find.text('Pricing')).dy),
        );
      });
    });

    group('destinations and panels', () {
      testWidgets('an item with no links goes somewhere when it is pressed', (
        WidgetTester tester,
      ) async {
        int pressed = 0;

        await tester.pumpWidget(
          host(
            PlNavigationMenu(items: menu(onPricing: () => pressed += 1)),
            width: 600,
            height: 400,
            overlay: true,
          ),
        );

        await tester.tap(find.text('Pricing'));
        await tester.pumpAndSettle();

        expect(pressed, 1);
        expect(find.text('Analytics'), findsNothing);
      });

      testWidgets('marks the destination the reader is on, in the accent', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            PlNavigationMenu(
              items: <PlNavigationMenuItem>[
                PlNavigationMenuItem(label: 'Pricing', selected: true, onPressed: () {}),
                PlNavigationMenuItem(label: 'Blog', onPressed: () {}),
              ],
            ),
            width: 600,
            height: 400,
            overlay: true,
          ),
        );

        expect(
          tester.getSemantics(find.text('Pricing')),
          isSemantics(isLink: true, isSelected: true),
        );
        expect(
          tester.getSemantics(find.text('Blog')),
          isSemantics(isLink: true, isSelected: false),
        );
        expect(
          styleOf(tester, 'Pricing').color,
          PlassTokens.light().family(PlassColor.primary).accent,
        );
        expect(styleOf(tester, 'Blog').color, PlassTokens.light().fg);

        handle.dispose();
      });

      testWidgets('an item with links opens a panel instead', (WidgetTester tester) async {
        final List<String?> seen = <String?>[];

        await tester.pumpWidget(
          host(
            PlNavigationMenu(items: menu(), onValueChanged: seen.add),
            width: 600,
            height: 400,
            overlay: true,
          ),
        );

        await tester.tap(find.text('Product'));
        await tester.pumpAndSettle();

        expect(seen, <String?>['Product']);
        expect(find.text('Analytics'), findsOneWidget);
        expect(find.text('Numbers over time'), findsOneWidget);
      });

      testWidgets('and closes it again on a second press', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlNavigationMenu(items: menu()), width: 600, height: 400, overlay: true),
        );

        await tester.tap(find.text('Product'));
        await tester.pumpAndSettle();
        expect(find.text('Analytics'), findsOneWidget);

        await tester.tap(find.text('Product'));
        await tester.pumpAndSettle();
        expect(find.text('Analytics'), findsNothing);
      });

      testWidgets('a row in the panel goes somewhere and closes it', (WidgetTester tester) async {
        int chosen = 0;

        await tester.pumpWidget(
          host(
            PlNavigationMenu(items: menu(onAnalytics: () => chosen += 1)),
            width: 600,
            height: 400,
            overlay: true,
          ),
        );

        await tester.tap(find.text('Product'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Analytics'));
        await tester.pumpAndSettle();

        expect(chosen, 1);
        expect(find.text('Analytics'), findsNothing);
      });

      testWidgets('opens a panel and follows a link from a screen reader', (
        WidgetTester tester,
      ) async {
        int chosen = 0;

        await tester.pumpWidget(
          host(
            PlNavigationMenu(items: menu(onAnalytics: () => chosen += 1)),
            width: 600,
            height: 400,
            overlay: true,
          ),
        );

        expect(
          tester.getSemantics(find.text('Product')),
          isSemantics(isButton: true, isExpanded: false, hasTapAction: true),
        );

        tester.semantics.tap(find.semantics.byLabel('Product'));
        await tester.pumpAndSettle();
        expect(find.text('Analytics'), findsOneWidget);

        tester.semantics.tap(find.semantics.byLabel(RegExp('^Analytics')));
        await tester.pumpAndSettle();
        expect(chosen, 1);
      });

      testWidgets('reports the panel closing as well as opening', (WidgetTester tester) async {
        final List<String?> seen = <String?>[];

        await tester.pumpWidget(
          host(
            PlNavigationMenu(items: menu(), onValueChanged: seen.add),
            width: 600,
            height: 400,
            overlay: true,
          ),
        );

        await tester.tap(find.text('Product'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Product'));
        await tester.pumpAndSettle();

        expect(seen, <String?>['Product', null]);
      });

      testWidgets('opens the one it starts on', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlNavigationMenu(items: menu(), initialValue: 'Product'),
            width: 600,
            height: 400,
            overlay: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Analytics'), findsOneWidget);
      });

      testWidgets('opens nothing for a disabled item', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlNavigationMenu(
              items: <PlNavigationMenuItem>[
                PlNavigationMenuItem(
                  label: 'Product',
                  disabled: true,
                  links: <PlNavigationMenuLink>[PlNavigationMenuLink(title: 'Analytics')],
                ),
              ],
            ),
            width: 600,
            height: 400,
            overlay: true,
          ),
        );

        await tester.tap(find.text('Product'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.text('Analytics'), findsNothing);
      });
    });

    group('the chevron', () {
      Finder chevron() => find.byWidgetPredicate(
        (Widget widget) => widget is PlassGlyph && widget.shape == PlassGlyphShape.chevron,
      );

      /// Which way the glyph is drawn: a quarter turn from pointing down.
      int pointing(WidgetTester tester) => tester.widget<PlassGlyph>(chevron()).quarterTurns;

      /// How far it is turned over on top of that, in whole turns.
      double turnedOver(WidgetTester tester) => tester
          .widget<AnimatedRotation>(
            find.ancestor(of: chevron(), matching: find.byType(AnimatedRotation)),
          )
          .turns;

      testWidgets('points down on a row, and turns over while its panel is open', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(PlNavigationMenu(items: menu()), width: 600, height: 400, overlay: true),
        );

        expect(pointing(tester), 0);
        expect(turnedOver(tester), 0);

        await tester.tap(find.text('Product'));
        await tester.pumpAndSettle();

        expect(pointing(tester), 0);
        expect(turnedOver(tester), 0.5);
      });

      testWidgets('points where a rail s panel opens, and stays there while it is open', (
        WidgetTester tester,
      ) async {
        for (final TextDirection direction in TextDirection.values) {
          await tester.pumpWidget(
            host(
              PlNavigationMenu(items: menu(), orientation: PlassOrientation.vertical),
              width: 600,
              height: 400,
              overlay: true,
              textDirection: direction,
            ),
          );

          // The end of the line: right, and left under RTL.
          final int end = direction == TextDirection.rtl ? 1 : -1;

          expect(pointing(tester), end, reason: '$direction');
          expect(turnedOver(tester), 0, reason: '$direction');

          await tester.tap(find.text('Product'));
          await tester.pumpAndSettle();

          final Rect word = tester.getRect(find.text('Product'));
          final Rect link = tester.getRect(find.text('Analytics'));

          if (direction == TextDirection.rtl) {
            expect(link.right, lessThan(word.left), reason: '$direction');
          } else {
            expect(link.left, greaterThan(word.right), reason: '$direction');
          }

          expect(pointing(tester), end, reason: '$direction');
          expect(turnedOver(tester), 0, reason: '$direction');

          await tester.pumpWidget(const SizedBox.shrink());
        }
      });
    });

    group('the surface', () {
      testWidgets('carries nothing at rest, because the words are the screen s', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(PlNavigationMenu(items: menu()), width: 600, height: 400, overlay: true),
        );

        // Every box the row draws is empty: no fill, no border, no shadow. The
        // family arrives with the pointer and with the open panel.
        for (final BoxDecoration decoration in decorationsOf(
          tester,
          find.byType(PlNavigationMenu),
        )) {
          expect(decoration.color, isNull);
          expect(decoration.border, isNull);
          expect(decoration.boxShadow ?? const <BoxShadow>[], isEmpty);
        }
      });

      testWidgets('is never dyed, whatever colour it is given', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlNavigationMenu(items: menu(), color: PlassColor.danger, initialValue: 'Product'),
            width: 600,
            height: 400,
            overlay: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          decorationsOf(
            tester,
            find.byType(PlNavigationMenu),
          ).every((BoxDecoration decoration) => decoration.gradient is! LinearGradient),
          isTrue,
        );
      });
    });
  });
}
