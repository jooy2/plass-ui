import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/scales.dart';

import '../../support/host.dart';

/// How many words on the bar are drawing a focus ring.
int _rings(WidgetTester tester) {
  return tester
      .widgetList<CustomPaint>(
        find.descendant(of: find.byType(PlMenubar), matching: find.byType(CustomPaint)),
      )
      .where((CustomPaint paint) => paint.foregroundPainter is PlassFocusRingPainter)
      .length;
}

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

    testWidgets('draws a startIcon at 1.2× the type size of its word', (WidgetTester tester) async {
      for (final PlassSize size in PlassSize.values) {
        await tester.pumpWidget(
          host(
            loose(
              PlMenubar(
                size: size,
                menus: const <PlMenubarMenu>[
                  PlMenubarMenu(
                    label: 'File',
                    startIcon: Icon(IconData(0x41)),
                    items: <PlMenuEntry>[PlMenuItem(label: 'New')],
                  ),
                ],
              ),
            ),
            width: 500,
            height: 300,
            overlay: true,
          ),
        );

        // As the React trigger's `1.2em` sizes a glyph off its label, rather
        // than at the 24 an icon is drawn at with nothing around it.
        final double side = controlText[size]! * iconScale;

        expect(tester.getSize(find.byType(Icon)), Size(side, side), reason: size.name);
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

    group('the keyboard', () {
      /// Three words, so a step from the middle has somewhere to go both ways.
      const List<PlMenubarMenu> three = <PlMenubarMenu>[
        PlMenubarMenu(
          label: 'File',
          items: <PlMenuEntry>[PlMenuItem(label: 'New')],
        ),
        PlMenubarMenu(
          label: 'Edit',
          items: <PlMenuEntry>[PlMenuItem(label: 'Copy')],
        ),
        PlMenubarMenu(
          label: 'View',
          items: <PlMenuEntry>[PlMenuItem(label: 'Zoom')],
        ),
      ];

      /// The word the focus is on, by its position on the bar.
      String? focused() => FocusManager.instance.primaryFocus?.debugLabel;

      Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
        await tester.sendKeyEvent(key);
        await tester.pumpAndSettle();
      }

      /// Tabs onto the bar from a stop in front of it.
      Future<void> reach(
        WidgetTester tester,
        PlMenubar menubar, {
        TextDirection textDirection = TextDirection.ltr,
      }) async {
        final FocusNode before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);

        await tester.pumpWidget(
          host(
            afterFocusStop(before, menubar),
            width: 500,
            height: 300,
            overlay: true,
            textDirection: textDirection,
          ),
        );
        before.requestFocus();
        await tester.pump();
        await press(tester, LogicalKeyboardKey.tab);
      }

      testWidgets('is one tab stop', (WidgetTester tester) async {
        await reach(tester, const PlMenubar(menus: three));

        // The role promises a reader one stop and the arrows, so Tab lands on
        // the first word and then leaves the bar — here, round to the stop in
        // front of it, since there is nothing after it.
        expect(focused(), 'PlMenubar 0');

        await press(tester, LogicalKeyboardKey.tab);

        expect(focused(), 'before');
      });

      testWidgets('moves along the strip with the arrows, wrapping at the ends', (
        WidgetTester tester,
      ) async {
        await reach(tester, const PlMenubar(menus: three));

        await press(tester, LogicalKeyboardKey.arrowRight);
        expect(focused(), 'PlMenubar 1');

        await press(tester, LogicalKeyboardKey.arrowRight);
        await press(tester, LogicalKeyboardKey.arrowRight);
        expect(focused(), 'PlMenubar 0');

        await press(tester, LogicalKeyboardKey.arrowLeft);
        expect(focused(), 'PlMenubar 2');
      });

      testWidgets('goes to either end with Home and End', (WidgetTester tester) async {
        await reach(tester, const PlMenubar(menus: three));

        await press(tester, LogicalKeyboardKey.end);
        expect(focused(), 'PlMenubar 2');

        await press(tester, LogicalKeyboardKey.home);
        expect(focused(), 'PlMenubar 0');
      });

      testWidgets('steps over a disabled word', (WidgetTester tester) async {
        await reach(
          tester,
          const PlMenubar(
            menus: <PlMenubarMenu>[
              PlMenubarMenu(
                label: 'File',
                items: <PlMenuEntry>[PlMenuItem(label: 'New')],
              ),
              PlMenubarMenu(
                label: 'Edit',
                disabled: true,
                items: <PlMenuEntry>[PlMenuItem(label: 'Copy')],
              ),
              PlMenubarMenu(
                label: 'View',
                items: <PlMenuEntry>[PlMenuItem(label: 'Zoom')],
              ),
            ],
          ),
        );

        await press(tester, LogicalKeyboardKey.arrowRight);

        expect(focused(), 'PlMenubar 2');
      });

      testWidgets('runs the way the text does under RTL', (WidgetTester tester) async {
        await reach(tester, const PlMenubar(menus: three), textDirection: TextDirection.rtl);

        await press(tester, LogicalKeyboardKey.arrowLeft);

        expect(focused(), 'PlMenubar 1');
      });

      testWidgets('moves with up and down when it runs down the page', (WidgetTester tester) async {
        await reach(tester, const PlMenubar(orientation: PlassOrientation.vertical, menus: three));

        await press(tester, LogicalKeyboardKey.arrowDown);
        expect(focused(), 'PlMenubar 1');

        await press(tester, LogicalKeyboardKey.arrowUp);
        expect(focused(), 'PlMenubar 0');
      });

      testWidgets('keeps the stop on the word the reader left', (WidgetTester tester) async {
        await reach(tester, const PlMenubar(menus: three));

        await press(tester, LogicalKeyboardKey.arrowRight);
        await press(tester, LogicalKeyboardKey.tab);
        expect(focused(), 'before');

        await press(tester, LogicalKeyboardKey.tab);

        expect(focused(), 'PlMenubar 1');
      });

      testWidgets('leaves the arrows to a menu while it is open', (WidgetTester tester) async {
        await reach(tester, const PlMenubar(menus: three));

        await press(tester, LogicalKeyboardKey.enter);
        expect(find.text('New'), findsOneWidget);

        // Right has no submenu to open here, so the open menu keeps it and the
        // bar does not move on underneath.
        await press(tester, LogicalKeyboardKey.arrowRight);

        expect(find.text('New'), findsOneWidget);
        expect(find.text('Copy'), findsNothing);
      });

      testWidgets('hands the focus back to the word when its menu closes', (
        WidgetTester tester,
      ) async {
        await reach(tester, const PlMenubar(menus: three));

        await press(tester, LogicalKeyboardKey.arrowRight);
        await press(tester, LogicalKeyboardKey.enter);
        expect(find.text('Copy'), findsOneWidget);

        await press(tester, LogicalKeyboardKey.escape);

        expect(find.text('Copy'), findsNothing);
        expect(focused(), 'PlMenubar 1');
        expect(_rings(tester), 1);

        // And the bar is still one stop from there.
        await press(tester, LogicalKeyboardKey.tab);

        expect(focused(), 'before');
      });
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

        // What is drawn rather than what the `Text` was handed: the word takes
        // its ink from the style around it, which eases as the menu opens.
        expect(
          tester
              .renderObject<RenderParagraph>(
                find.descendant(of: find.byType(PlMenubar), matching: find.text('File')),
              )
              .text
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

        // Pressing another word on the bar puts the open one away and opens the
        // one that was pressed.
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        expect(find.text('New'), findsNothing);
        expect(find.text('Copy'), findsOneWidget);
      });

      group('hands the focus back to a word a pointer pressed', () {
        /// The bar with File opened by a tap, which leaves the focus highlight
        /// mode the touch screen's.
        Future<void> openWithTap(WidgetTester tester) async {
          await tester.pumpWidget(
            host(PlMenubar(menus: bar()), width: 500, height: 300, overlay: true),
          );

          await tester.tap(find.text('File'));
          await tester.pumpAndSettle();

          expect(find.text('New'), findsOneWidget);
          expect(FocusManager.instance.highlightMode, FocusHighlightMode.touch);
        }

        String? focused() => FocusManager.instance.primaryFocus?.debugLabel;

        testWidgets('when a row is picked, with no ring on it', (WidgetTester tester) async {
          await openWithTap(tester);

          await tester.tap(find.text('New'));
          await tester.pumpAndSettle();

          expect(find.text('New'), findsNothing);
          expect(focused(), 'PlMenubar 0');
          expect(_rings(tester), 0);
        });

        testWidgets('when a press outside closes it, with no ring on it', (
          WidgetTester tester,
        ) async {
          await openWithTap(tester);

          await tester.tapAt(const Offset(4, 4));
          await tester.pumpAndSettle();

          expect(find.text('New'), findsNothing);
          expect(focused(), 'PlMenubar 0');
          expect(_rings(tester), 0);
        });

        testWidgets('when it is closed with escape, with a ring only for the keyboard', (
          WidgetTester tester,
        ) async {
          // Escape is a key, and a key makes the highlight mode the keyboard's
          // on its own. Held to the touch screen's here, the word takes the
          // focus back without a ring.
          FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTouch;
          await openWithTap(tester);

          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();

          expect(find.text('New'), findsNothing);
          expect(focused(), 'PlMenubar 0');
          expect(_rings(tester), 0);

          FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
          await tester.pump();

          expect(_rings(tester), 1);
        });
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
