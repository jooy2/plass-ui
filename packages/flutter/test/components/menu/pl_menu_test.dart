import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

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
