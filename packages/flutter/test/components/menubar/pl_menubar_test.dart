import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// Lets the bar be as tall as it wants to be.
///
/// [host] hands its child a tight box, and a menu bar's whole claim is that it
/// is shorter than a row of buttons — which is unmeasurable inside one.
Widget loose(Widget child) {
  return Align(alignment: Alignment.topLeft, heightFactor: 1, child: child);
}

List<PlMenubarMenu> bar({VoidCallback? onNew}) {
  return <PlMenubarMenu>[
    PlMenubarMenu(
      label: 'File',
      items: <PlMenuEntry>[
        PlMenuItem(label: 'New', onPressed: onNew),
        const PlMenuSeparator(),
        const PlMenuItem(label: 'Save'),
      ],
    ),
    const PlMenubarMenu(
      label: 'Edit',
      items: <PlMenuEntry>[PlMenuItem(label: 'Copy')],
    ),
  ];
}

void main() {
  group('PlMenubar', () {
    testWidgets('is a menu bar with a word per menu', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(PlMenubar(menus: bar()), width: 500, height: 300, overlay: true),
      );

      expect(
        semanticsOf(tester, find.byType(PlMenubar)).getSemanticsData().role,
        SemanticsRole.menuBar,
      );
      expect(find.text('File'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('draws no surface of its own', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(PlMenubar(menus: bar()), width: 500, height: 300, overlay: true),
      );

      for (final BoxDecoration decoration in decorationsOf(tester, find.byType(PlMenubar))) {
        expect(decoration.color, isNull);
        expect(decoration.border, isNull);
        expect(decoration.boxShadow ?? const <BoxShadow>[], isEmpty);
      }
    });

    testWidgets('sits a rung below the control ladder', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(loose(PlMenubar(menus: bar())), width: 500, height: 300, overlay: true),
      );

      // A strip of words, not a row of buttons: `md` is 26 rather than 40.
      expect(tester.getSize(find.byType(PlMenubar)).height, 26);
    });

    testWidgets('walks that height up the size ladder', (WidgetTester tester) async {
      for (final MapEntry<PlassSize, double> entry in <PlassSize, double>{
        PlassSize.xs: 18,
        PlassSize.sm: 22,
        PlassSize.md: 26,
        PlassSize.lg: 32,
        PlassSize.xl: 40,
      }.entries) {
        await tester.pumpWidget(
          host(
            loose(PlMenubar(size: entry.key, menus: bar())),
            width: 500,
            height: 300,
            overlay: true,
          ),
        );

        expect(tester.getSize(find.byType(PlMenubar)).height, entry.value);
      }
    });

    testWidgets('runs the other way when it is told to', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlMenubar(orientation: PlassOrientation.vertical, menus: bar()),
          width: 500,
          height: 300,
          overlay: true,
        ),
      );

      expect(
        tester.getTopLeft(find.text('File')).dy,
        lessThan(tester.getTopLeft(find.text('Edit')).dy),
      );
    });

    group('a menu on it', () {
      testWidgets('opens on a press and holds the same rows a PlMenu does', (
        WidgetTester tester,
      ) async {
        int pressed = 0;

        await tester.pumpWidget(
          host(
            PlMenubar(menus: bar(onNew: () => pressed += 1)),
            width: 500,
            height: 300,
            overlay: true,
          ),
        );

        await tester.tap(find.text('File'));
        await tester.pumpAndSettle();

        expect(find.text('New'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);

        await tester.tap(find.text('New'));
        await tester.pumpAndSettle();

        expect(pressed, 1);
        expect(find.text('New'), findsNothing);
      });

      testWidgets('says which one is open', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(PlMenubar(menus: bar()), width: 500, height: 300, overlay: true),
        );

        expect(
          tester
              .getSemantics(find.bySemanticsLabel('File'))
              .getSemanticsData()
              .flagsCollection
              .isExpanded,
          Tristate.isFalse,
        );

        await tester.tap(find.text('File'));
        await tester.pumpAndSettle();

        // The open menu takes the page's semantics away with it, so the word's
        // own node is no longer reachable — which is exactly why the strip says
        // it in colour too: a menu bar is the one place where "this one is
        // open" has to be legible from across the bar.
        final PlassColorFamily family = PlassTokens.light().family(PlassColor.primary);

        expect(
          tester
              .widget<Text>(
                find.descendant(of: find.byType(PlMenubar), matching: find.text('File')),
              )
              .style!
              .color,
          family.accent,
        );
        expect(
          decorationsOf(tester, find.byType(PlMenubar)).map((BoxDecoration d) => d.color),
          contains(family.softHover),
        );

        handle.dispose();
      });

      testWidgets('only ever has one of them open', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlMenubar(menus: bar()), width: 500, height: 300, overlay: true),
        );

        await tester.tap(find.text('File'));
        await tester.pumpAndSettle();
        expect(find.text('New'), findsOneWidget);

        // Pressing elsewhere on the bar puts the open one away. It does not open
        // the one that was pressed — see the differences table on the page.
        await tester.tap(find.text('Edit'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.text('New'), findsNothing);
        expect(find.text('Copy'), findsNothing);
      });

      testWidgets('opens nothing while it is disabled', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlMenubar(
              menus: <PlMenubarMenu>[
                PlMenubarMenu(
                  label: 'File',
                  disabled: true,
                  items: <PlMenuEntry>[PlMenuItem(label: 'New')],
                ),
              ],
            ),
            width: 500,
            height: 300,
            overlay: true,
          ),
        );

        await tester.tap(find.text('File'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.text('New'), findsNothing);
      });

      testWidgets('disables every menu on the bar at once', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlMenubar(disabled: true, menus: bar()), width: 500, height: 300, overlay: true),
        );

        await tester.tap(find.text('File'), warnIfMissed: false);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Edit'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.text('New'), findsNothing);
        expect(find.text('Copy'), findsNothing);
      });
    });
  });
}
