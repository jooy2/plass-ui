import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/scales.dart';

import '../../support/host.dart';

/// A menu with a plain trigger, which is how every caller uses one.
Widget menu(
  List<PlMenuEntry> items, {
  String? label,
  bool disabled = false,
  ValueChanged<bool>? onOpenChange,
}) {
  return PlMenu(
    items: items,
    label: label,
    disabled: disabled,
    onOpenChange: onOpenChange,
    trigger: (BuildContext context, VoidCallback open, bool isOpen) =>
        PlButton(onPressed: open, child: const Text('Open')),
  );
}

Future<void> openMenu(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

/// Whether the trigger is drawing its focus ring.
bool _ringed(WidgetTester tester) {
  return tester
      .widgetList<CustomPaint>(
        find.descendant(of: find.byType(PlButton), matching: find.byType(CustomPaint)),
      )
      .any((CustomPaint paint) => paint.foregroundPainter is PlassFocusRingPainter);
}

void main() {
  group('PlMenu', () {
    group('opening', () {
      testWidgets('is shut until the trigger is pressed', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(menu(const <PlMenuEntry>[PlMenuItem(label: 'Cut')]), overlay: true),
        );

        expect(find.text('Cut'), findsNothing);
      });

      testWidgets('opens on the trigger', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(menu(const <PlMenuEntry>[PlMenuItem(label: 'Cut')]), overlay: true),
        );
        await openMenu(tester);

        expect(find.text('Cut'), findsOneWidget);
      });

      testWidgets('reports the open state', (WidgetTester tester) async {
        final List<bool> seen = <bool>[];

        await tester.pumpWidget(
          host(
            menu(const <PlMenuEntry>[PlMenuItem(label: 'Cut')], onOpenChange: seen.add),
            overlay: true,
          ),
        );
        await openMenu(tester);

        expect(seen, <bool>[true]);
      });

      testWidgets('does not open while it is disabled', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(menu(const <PlMenuEntry>[PlMenuItem(label: 'Cut')], disabled: true), overlay: true),
        );
        await openMenu(tester);

        expect(find.text('Cut'), findsNothing);
      });

      testWidgets('closes on escape', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(menu(const <PlMenuEntry>[PlMenuItem(label: 'Cut')]), overlay: true),
        );
        await openMenu(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(find.text('Cut'), findsNothing);
      });
    });

    group('a row', () {
      testWidgets('fires when it is picked, and closes behind it', (WidgetTester tester) async {
        int pressed = 0;

        await tester.pumpWidget(
          host(
            menu(<PlMenuEntry>[PlMenuItem(label: 'Cut', onPressed: () => pressed++)]),
            overlay: true,
          ),
        );
        await openMenu(tester);
        await tester.tap(find.text('Cut'));
        await tester.pumpAndSettle();

        expect(pressed, 1);
        expect(find.text('Cut'), findsNothing);
      });

      testWidgets('fires from a screen reader too', (WidgetTester tester) async {
        int pressed = 0;

        await tester.pumpWidget(
          host(
            menu(<PlMenuEntry>[PlMenuItem(label: 'Cut', onPressed: () => pressed++)]),
            overlay: true,
          ),
        );
        await openMenu(tester);
        tester.semantics.tap(find.semantics.byLabel('Cut'));
        await tester.pumpAndSettle();

        expect(pressed, 1);
      });

      testWidgets('does not fire while it is unavailable', (WidgetTester tester) async {
        int pressed = 0;

        await tester.pumpWidget(
          host(
            menu(<PlMenuEntry>[
              PlMenuItem(label: 'Cut', disabled: true, onPressed: () => pressed++),
            ]),
            overlay: true,
          ),
        );
        await openMenu(tester);
        await tester.tap(find.text('Cut'));
        await tester.pumpAndSettle();

        expect(pressed, 0);
        // Still listed: a row that vanishes when it is unavailable is a menu
        // that changes length.
        expect(find.text('Cut'), findsOneWidget);
      });

      testWidgets('adds an opacity layer only for a row that is unavailable', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            menu(<PlMenuEntry>[
              const PlMenuItem(label: 'Cut', disabled: true),
              PlMenuItem(label: 'Copy', onPressed: () {}),
              PlMenuItem(label: 'Paste', onPressed: () {}),
            ]),
            overlay: true,
          ),
        );
        await openMenu(tester);

        final Iterable<int> alphas = tester.layers.whereType<OpacityLayer>().map(
          (OpacityLayer layer) => layer.alpha!,
        );

        // The menu fades in as one, which is the one layer at full strength.
        // A row that can be picked is not painted through an opacity of 1 as
        // well, which would be a layer on every row for nothing.
        expect(alphas.where((int alpha) => alpha == 255), hasLength(1));
        expect(alphas.where((int alpha) => alpha != 255), <int>[
          Color.getAlphaFromOpacity(disabledOpacity),
        ]);
      });

      testWidgets('draws an unavailable row in the ink of one that is available', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            menu(<PlMenuEntry>[
              const PlMenuItem(label: 'Cut', disabled: true),
              const PlMenuItem(label: 'Delete', color: PlassColor.danger, disabled: true),
              PlMenuItem(label: 'Copy', onPressed: () {}),
            ]),
            overlay: true,
          ),
        );
        await openMenu(tester);

        final PlassTokens tokens = PlassTokens.light();

        // The half opacity round it says it cannot be chosen, as it does on
        // every disabled control, and the words keep their own colour.
        expect(styleOf(tester, 'Cut').color, tokens.fg);
        expect(styleOf(tester, 'Cut').color, styleOf(tester, 'Copy').color);
        expect(styleOf(tester, 'Delete').color, tokens.family(PlassColor.danger).accent);
      });

      testWidgets('carries a shortcut and a description', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            menu(const <PlMenuEntry>[
              PlMenuItem(label: 'Cut', shortcut: '⌘X', description: 'Takes it out'),
            ]),
            overlay: true,
          ),
        );
        await openMenu(tester);

        expect(find.text('⌘X'), findsOneWidget);
        expect(find.text('Takes it out'), findsOneWidget);
      });
    });

    group('ticking and choosing', () {
      testWidgets('reports a tick and stays open', (WidgetTester tester) async {
        bool? next;

        await tester.pumpWidget(
          host(
            menu(<PlMenuEntry>[
              PlMenuCheckboxItem(
                label: 'Word wrap',
                checked: false,
                onChanged: (bool value) => next = value,
              ),
            ]),
            overlay: true,
          ),
        );
        await openMenu(tester);
        await tester.tap(find.text('Word wrap'));
        await tester.pumpAndSettle();

        expect(next, isTrue);
        expect(find.text('Word wrap'), findsOneWidget);
      });

      testWidgets('reports a choice out of a set', (WidgetTester tester) async {
        int chosen = 0;

        await tester.pumpWidget(
          host(
            menu(<PlMenuEntry>[
              PlMenuRadioItem(label: 'List', selected: true, onPressed: () {}),
              PlMenuRadioItem(label: 'Grid', selected: false, onPressed: () => chosen++),
            ]),
            overlay: true,
          ),
        );
        await openMenu(tester);
        await tester.tap(find.text('Grid'));
        await tester.pumpAndSettle();

        expect(chosen, 1);
      });
    });

    group('the structure', () {
      testWidgets('names a group without making it pickable', (WidgetTester tester) async {
        int pressed = 0;

        await tester.pumpWidget(
          host(
            menu(<PlMenuEntry>[
              PlMenuGroup(
                label: 'Edit',
                items: <PlMenuEntry>[PlMenuItem(label: 'Cut', onPressed: () => pressed++)],
              ),
            ]),
            overlay: true,
          ),
        );
        await openMenu(tester);

        expect(find.text('EDIT'), findsOneWidget);

        await tester.tap(find.text('EDIT'));
        await tester.pumpAndSettle();

        expect(pressed, 0);
      });

      testWidgets('opens a submenu from a row that is still a row', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            menu(const <PlMenuEntry>[
              PlMenuSubmenu(
                label: 'Share',
                items: <PlMenuEntry>[PlMenuItem(label: 'By email')],
              ),
            ]),
            overlay: true,
          ),
        );
        await openMenu(tester);

        expect(find.text('Share'), findsOneWidget);
        expect(find.text('By email'), findsNothing);

        await tester.tap(find.text('Share'));
        await tester.pumpAndSettle();

        expect(find.text('By email'), findsOneWidget);
      });
    });

    group('the keyboard', () {
      testWidgets('puts no stop of its own in front of the trigger', (WidgetTester tester) async {
        final FocusNode before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);

        await tester.pumpWidget(
          host(
            afterFocusStop(before, menu(const <PlMenuEntry>[PlMenuItem(label: 'Cut')])),
            overlay: true,
          ),
        );
        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // The node the menu takes its keys on wraps the trigger. As a stop of
        // its own it was a Tab with nothing drawn on it before the button.
        bool onButton = false;
        FocusManager.instance.primaryFocus!.context!.visitAncestorElements((Element element) {
          onButton = element.widget is PlButton;
          return !onButton;
        });

        expect(onButton, isTrue);
      });

      group('hands the focus back to the trigger', () {
        /// A menu whose trigger holds the focus, opened from the keyboard, with
        /// [elsewhere] beside it when a row needs somewhere else to send it.
        Future<FocusNode> openFromTrigger(
          WidgetTester tester,
          List<PlMenuEntry> items, {
          FocusNode? elsewhere,
        }) async {
          final FocusNode before = FocusNode(debugLabel: 'before');
          final FocusNode button = FocusNode(debugLabel: 'trigger');
          addTearDown(before.dispose);
          addTearDown(button.dispose);

          await tester.pumpWidget(
            host(
              afterFocusStop(
                before,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    PlMenu(
                      items: items,
                      trigger: (BuildContext context, VoidCallback open, bool isOpen) =>
                          PlButton(onPressed: open, focusNode: button, child: const Text('Open')),
                    ),
                    if (elsewhere != null)
                      Focus(focusNode: elsewhere, child: const SizedBox.square(dimension: 1)),
                  ],
                ),
              ),
              overlay: true,
            ),
          );
          button.requestFocus();
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();

          expect(find.text('Cut'), findsOneWidget);

          return button;
        }

        testWidgets('when it is closed with escape', (WidgetTester tester) async {
          final FocusNode button = await openFromTrigger(tester, const <PlMenuEntry>[
            PlMenuItem(label: 'Cut'),
          ]);

          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();

          // Left on the node the menu took its keys on, which draws no ring,
          // the reader could no longer see where they were.
          expect(find.text('Cut'), findsNothing);
          expect(button.hasPrimaryFocus, isTrue);
          expect(_ringed(tester), isTrue);
        });

        testWidgets('when a row is picked', (WidgetTester tester) async {
          final FocusNode button = await openFromTrigger(tester, const <PlMenuEntry>[
            PlMenuItem(label: 'Cut'),
          ]);

          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();

          expect(find.text('Cut'), findsNothing);
          expect(button.hasPrimaryFocus, isTrue);
        });

        testWidgets('unless the row sent it somewhere of its own', (WidgetTester tester) async {
          final FocusNode field = FocusNode(debugLabel: 'field');
          addTearDown(field.dispose);

          final FocusNode button = await openFromTrigger(tester, <PlMenuEntry>[
            PlMenuItem(label: 'Cut', onPressed: field.requestFocus),
          ], elsewhere: field);

          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();

          expect(field.hasPrimaryFocus, isTrue);
          expect(button.hasFocus, isFalse);
        });
      });

      group('hands the focus back to a trigger a pointer pressed', () {
        /// A menu opened with a tap, which leaves the focus highlight mode the
        /// touch screen's.
        Future<FocusNode> openWithTap(WidgetTester tester) async {
          final FocusNode button = FocusNode(debugLabel: 'trigger');
          addTearDown(button.dispose);

          await tester.pumpWidget(
            host(
              PlMenu(
                items: const <PlMenuEntry>[PlMenuItem(label: 'Cut')],
                trigger: (BuildContext context, VoidCallback open, bool isOpen) =>
                    PlButton(onPressed: open, focusNode: button, child: const Text('Open')),
              ),
              overlay: true,
            ),
          );
          await openMenu(tester);

          expect(find.text('Cut'), findsOneWidget);
          expect(FocusManager.instance.highlightMode, FocusHighlightMode.touch);

          return button;
        }

        testWidgets('when a row is picked, with no ring on it', (WidgetTester tester) async {
          final FocusNode button = await openWithTap(tester);

          await tester.tap(find.text('Cut'));
          await tester.pumpAndSettle();

          // As the React menu does. Left on the menu's own node, the next Tab
          // started from a stop the reader cannot see.
          expect(find.text('Cut'), findsNothing);
          expect(button.hasPrimaryFocus, isTrue);
          expect(_ringed(tester), isFalse);
        });

        testWidgets('when a press outside closes it, with no ring on it', (
          WidgetTester tester,
        ) async {
          final FocusNode button = await openWithTap(tester);

          await tester.tapAt(const Offset(4, 4));
          await tester.pumpAndSettle();

          expect(find.text('Cut'), findsNothing);
          expect(button.hasPrimaryFocus, isTrue);
          expect(_ringed(tester), isFalse);
        });

        testWidgets('when it is closed with escape, with a ring only for the keyboard', (
          WidgetTester tester,
        ) async {
          // Escape is a key, and a key makes the highlight mode the keyboard's
          // on its own. Held to the touch screen's here, the trigger takes the
          // focus back without a ring.
          FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTouch;
          final FocusNode button = await openWithTap(tester);

          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();

          expect(find.text('Cut'), findsNothing);
          expect(button.hasPrimaryFocus, isTrue);
          expect(_ringed(tester), isFalse);

          FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
          await tester.pump();

          expect(_ringed(tester), isTrue);
        });
      });

      testWidgets('walks the rows and picks one', (WidgetTester tester) async {
        final List<String> pressed = <String>[];

        await tester.pumpWidget(
          host(
            menu(<PlMenuEntry>[
              PlMenuItem(label: 'Cut', onPressed: () => pressed.add('Cut')),
              PlMenuItem(label: 'Copy', onPressed: () => pressed.add('Copy')),
            ]),
            overlay: true,
          ),
        );
        await openMenu(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(pressed, <String>['Copy']);
      });

      testWidgets('walks past an unavailable row rather than landing on it', (
        WidgetTester tester,
      ) async {
        final List<String> pressed = <String>[];

        await tester.pumpWidget(
          host(
            menu(<PlMenuEntry>[
              PlMenuItem(label: 'Cut', disabled: true, onPressed: () => pressed.add('Cut')),
              PlMenuItem(label: 'Copy', onPressed: () => pressed.add('Copy')),
            ]),
            overlay: true,
          ),
        );
        await openMenu(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(pressed, <String>['Copy']);
      });

      testWidgets('jumps to the last row', (WidgetTester tester) async {
        final List<String> pressed = <String>[];

        await tester.pumpWidget(
          host(
            menu(<PlMenuEntry>[
              PlMenuItem(label: 'Cut', onPressed: () => pressed.add('Cut')),
              PlMenuItem(label: 'Copy', onPressed: () => pressed.add('Copy')),
              PlMenuItem(label: 'Paste', onPressed: () => pressed.add('Paste')),
            ]),
            overlay: true,
          ),
        );
        await openMenu(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(pressed, <String>['Paste']);
      });

      testWidgets('opens a submenu towards the end of the line, and turns its chevron there', (
        WidgetTester tester,
      ) async {
        for (final TextDirection direction in TextDirection.values) {
          await tester.pumpWidget(
            host(
              Directionality(
                textDirection: direction,
                child: menu(<PlMenuEntry>[
                  PlMenuSubmenu(
                    label: 'Share',
                    items: <PlMenuEntry>[PlMenuItem(label: 'By email', onPressed: () {})],
                  ),
                ]),
              ),
              overlay: true,
            ),
          );
          await openMenu(tester);

          await tester.tap(find.text('Share'));
          await tester.pumpAndSettle();

          final Rect row = tester.getRect(find.text('Share'));
          final Rect nested = tester.getRect(find.text('By email'));
          final int turns = tester
              .widget<PlassGlyph>(
                find.byWidgetPredicate(
                  (Widget widget) =>
                      widget is PlassGlyph && widget.shape == PlassGlyphShape.chevron,
                ),
              )
              .quarterTurns;

          if (direction == TextDirection.rtl) {
            expect(nested.right, lessThan(row.left), reason: '$direction');
            expect(turns, 1);
          } else {
            expect(nested.left, greaterThan(row.right), reason: '$direction');
            expect(turns, -1);
          }

          await tester.pumpWidget(const SizedBox.shrink());
        }
      });

      testWidgets('opens and closes a submenu with the arrow keys', (WidgetTester tester) async {
        final List<String> pressed = <String>[];

        await tester.pumpWidget(
          host(
            menu(<PlMenuEntry>[
              PlMenuSubmenu(
                label: 'Share',
                items: <PlMenuEntry>[
                  PlMenuItem(label: 'By email', onPressed: () => pressed.add('By email')),
                ],
              ),
            ]),
            overlay: true,
          ),
        );
        await openMenu(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();

        expect(find.text('By email'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();

        expect(find.text('By email'), findsNothing);
      });

      testWidgets('jumps to a row by what was typed', (WidgetTester tester) async {
        final List<String> pressed = <String>[];

        await tester.pumpWidget(
          host(
            menu(<PlMenuEntry>[
              PlMenuItem(label: 'Cut', onPressed: () => pressed.add('Cut')),
              PlMenuItem(label: 'Paste', onPressed: () => pressed.add('Paste')),
            ]),
            overlay: true,
          ),
        );
        await openMenu(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(pressed, <String>['Paste']);
      });

      testWidgets('passes over an unavailable row when jumping by what was typed', (
        WidgetTester tester,
      ) async {
        final List<String> pressed = <String>[];

        await tester.pumpWidget(
          host(
            menu(<PlMenuEntry>[
              PlMenuItem(label: 'Cut', onPressed: () => pressed.add('Cut')),
              PlMenuItem(label: 'Paste', disabled: true, onPressed: () => pressed.add('Paste')),
              PlMenuItem(label: 'Print', onPressed: () => pressed.add('Print')),
            ]),
            overlay: true,
          ),
        );
        await openMenu(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(pressed, <String>['Print']);
      });
    });

    group('accessibility', () {
      testWidgets('names the popup', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            menu(const <PlMenuEntry>[PlMenuItem(label: 'Cut')], label: 'Actions'),
            overlay: true,
          ),
        );
        await openMenu(tester);

        expect(find.bySemanticsLabel('Actions'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('marks a ticked row as checked and a chosen one as selected', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            menu(const <PlMenuEntry>[
              PlMenuCheckboxItem(label: 'Word wrap', checked: true),
              PlMenuRadioItem(label: 'Grid', selected: true),
            ]),
            overlay: true,
          ),
        );
        await openMenu(tester);

        expect(
          tester.getSemantics(find.bySemanticsLabel('Word wrap')),
          isSemantics(label: 'Word wrap', isChecked: true),
        );
        expect(
          tester.getSemantics(find.bySemanticsLabel('Grid')),
          isSemantics(label: 'Grid', isSelected: true, isInMutuallyExclusiveGroup: true),
        );

        handle.dispose();
      });
    });
  });
}
