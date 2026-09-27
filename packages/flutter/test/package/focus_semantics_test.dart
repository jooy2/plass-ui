// Whether a control built inside a `PlassInteractive` builder tells a screen
// reader that it can take the focus.
//
// Each of these controls names itself on a `Semantics` inside the builder,
// where `PlassInteractive.focusSemantics` cannot reach: said from round the
// surface, the focus would land above the node that names the control. So
// each node reads `plassFocusSemanticsOf` itself, and a node that does not
// offers a tap and no way to move the focus there. One test per control, each
// finding the node by the name a screen reader reads.
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/host.dart';

/// Checks that the node named [name] can take the focus and does not hold it,
/// with the action that moves the focus there beside its tap, that no node
/// round it says so as well, and that the action moves the focus there.
///
/// [alone] is `false` for a control that sits inside another focus stop of
/// its own, whose node is round it and says so for itself.
Future<void> _expectFocusStop(WidgetTester tester, String name, {bool alone = true}) async {
  final SemanticsNode? node = semanticsNodeLabelled(tester, name);

  expect(node, isNotNull, reason: name);
  expect(
    node,
    isSemantics(
      label: name,
      isFocusable: true,
      isFocused: false,
      hasTapAction: true,
      hasFocusAction: true,
    ),
    reason: name,
  );

  for (SemanticsNode? around = node!.parent; alone && around != null; around = around.parent) {
    expect(around, isSemantics(isFocusable: false, hasFocusAction: false), reason: 'round $name');
  }

  node.owner!.performAction(node.id, SemanticsAction.focus);
  await tester.pumpAndSettle();

  expect(
    semanticsNodeLabelled(tester, name),
    isSemantics(label: name, isFocusable: true, isFocused: true),
    reason: name,
  );
}

/// Checks that the node named [name] says nothing about the focus, which is
/// what a control that cannot take it says.
void _expectNoFocus(WidgetTester tester, String name) {
  final SemanticsNode? node = semanticsNodeLabelled(tester, name);

  expect(node, isNotNull, reason: name);
  expect(node, isSemantics(label: name, isFocusable: false, hasFocusAction: false), reason: name);
}

/// A test with the semantics tree built for its length.
void _testSemantics(String description, Future<void> Function(WidgetTester tester) body) {
  testWidgets(description, (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();

    await body(tester);

    handle.dispose();
  });
}

void main() {
  group('a control named inside its surface says it can take the focus', () {
    _testSemantics('PlChip', (WidgetTester tester) async {
      await tester.pumpWidget(host(PlChip(onPressed: () {}, child: const Text('Design'))));

      await _expectFocusStop(tester, 'Design');

      // A chip that cannot be pressed takes no focus and says nothing of it.
      await tester.pumpWidget(host(const PlChip(child: Text('Design'))));

      expect(find.semantics.byFlag(SemanticsFlag.isFocusable), findsNothing);
    });

    _testSemantics('PlListItem', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlList(
            children: <Widget>[
              PlListItem(onPressed: () {}, child: const Text('Billing')),
              const PlListItem(child: Text('Members')),
            ],
          ),
          width: 320,
        ),
      );

      await _expectFocusStop(tester, 'Billing');
      _expectNoFocus(tester, 'Members');
    });

    _testSemantics('PlTabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlTabs<String>(
            tabs: const <PlTab<String>>[
              PlTab<String>(value: 'overview', label: Text('Overview'), panel: Text('One')),
              PlTab<String>(value: 'activity', label: Text('Activity'), panel: Text('Two')),
            ],
            value: 'overview',
            onChanged: (String next) {},
          ),
          width: 480,
        ),
      );

      // Only the tab that holds the list's stop can take the focus.
      _expectNoFocus(tester, 'Activity');
      await _expectFocusStop(tester, 'Overview');
    });

    _testSemantics('PlSegmentedButton', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlSegmentedButton<String>(
            segments: const <PlSegment<String>>[
              PlSegment<String>(value: 'list', label: Text('List')),
              PlSegment<String>(value: 'board', label: Text('Board')),
            ],
            value: 'list',
            onChanged: (String next) {},
          ),
          width: 480,
        ),
      );

      // Only the segment that holds the set's stop can take the focus.
      _expectNoFocus(tester, 'Board');
      await _expectFocusStop(tester, 'List');
    });

    _testSemantics('PlAccordion', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlAccordion<String>(
            items: const <PlAccordionItem<String>>[
              PlAccordionItem<String>(value: 'billing', title: Text('Billing'), child: Text('A')),
              PlAccordionItem<String>(
                value: 'members',
                title: Text('Members'),
                disabled: true,
                child: Text('B'),
              ),
            ],
            value: const <String>{},
            onChanged: (Set<String> next) {},
          ),
          width: 400,
        ),
      );

      await _expectFocusStop(tester, 'Billing');
      _expectNoFocus(tester, 'Members');
    });

    _testSemantics('PlCollapsible', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlCollapsible(
            open: false,
            onOpenChanged: (bool next) {},
            title: const Text('Advanced'),
            child: const Text('Nine settings'),
          ),
          width: 360,
        ),
      );

      await _expectFocusStop(tester, 'Advanced');
    });

    _testSemantics('PlSelect', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlSelect<String>(
            options: const <PlSelectOption<String>>[
              PlSelectOption<String>(value: 'seoul', label: Text('Seoul')),
            ],
            value: null,
            label: const Text('City'),
            onChanged: (String? next) {},
          ),
          width: 320,
          overlay: true,
        ),
      );

      await _expectFocusStop(tester, 'City');
    });

    _testSemantics('a picker, through PlDatePicker', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlDatePicker(value: null, label: const Text('Due'), onChanged: (DateTime? next) {}),
          width: 320,
          overlay: true,
        ),
      );

      await _expectFocusStop(tester, 'Due');
    });

    _testSemantics('PlNumberField steppers', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(PlNumberField(value: 10, max: 10, onChanged: (double? next) {}), width: 320),
      );

      // Inside the field's own node, which takes the focus for the editor.
      await _expectFocusStop(tester, 'Decrease', alone: false);

      // A stepper at the end of the range has no step to take, and no focus.
      _expectNoFocus(tester, 'Increase');
    });

    _testSemantics('PlBottomNavigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlBottomNavigation<String>(
            items: const <PlBottomNavigationItem<String>>[
              PlBottomNavigationItem<String>(value: 'home', label: 'Home'),
              PlBottomNavigationItem<String>(value: 'search', label: 'Search'),
            ],
            value: 'home',
            onChanged: (String next) {},
          ),
          width: 360,
        ),
      );

      await _expectFocusStop(tester, 'Search');
    });

    _testSemantics('PlFloatingBottomNavigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlFloatingBottomNavigation<String>(
            items: const <PlFloatingBottomNavigationItem<String>>[
              PlFloatingBottomNavigationItem<String>(value: 'home', label: 'Home'),
              PlFloatingBottomNavigationItem<String>(value: 'search', label: 'Search'),
            ],
            value: 'home',
            onChanged: (String next) {},
          ),
          width: 360,
        ),
      );

      await _expectFocusStop(tester, 'Search');
    });

    _testSemantics('PlMenubar', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlMenubar(
            menus: <PlMenubarMenu>[
              PlMenubarMenu(
                label: 'File',
                items: <PlMenuEntry>[PlMenuItem(label: 'New')],
              ),
              PlMenubarMenu(
                label: 'Edit',
                items: <PlMenuEntry>[PlMenuItem(label: 'Copy')],
              ),
            ],
          ),
          width: 500,
          height: 300,
          overlay: true,
        ),
      );

      // Tab skips the words that are not the bar's stop, but the arrow keys
      // move the focus onto them, so each says it can take it. Each word is
      // inside the node of its `PlMenu`, which takes the focus while the menu
      // is open.
      await _expectFocusStop(tester, 'Edit', alone: false);

      // The word says the focus its own node holds, which is where the arrow
      // keys put it, and not the focus of its menu's node round it.
      Focus.of(tester.element(find.text('File'))).requestFocus();
      await tester.pumpAndSettle();

      expect(
        semanticsNodeLabelled(tester, 'File'),
        isSemantics(label: 'File', isFocusable: true, isFocused: true),
      );
    });

    _testSemantics('PlWindowPane caption buttons', (WidgetTester tester) async {
      await tester.pumpWidget(host(const PlWindowPane(title: Text('Notes')), width: 420));

      for (final String name in <String>['Minimize', 'Maximize', 'Close']) {
        await _expectFocusStop(tester, name);
      }
    });

    _testSemantics('PlAppLogo', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlAppLogo(
            name: const Text('Acme'),
            description: const Text('Staging'),
            onPressed: () {},
            child: const SizedBox.square(dimension: 24),
          ),
        ),
      );

      await _expectFocusStop(tester, 'Acme\nStaging');
    });

    _testSemantics('PlNavigationMenu links', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlNavigationMenu(
            items: <PlNavigationMenuItem>[
              PlNavigationMenuItem(
                label: 'Product',
                links: <PlNavigationMenuLink>[
                  PlNavigationMenuLink(title: 'Analytics', onPressed: () {}),
                ],
              ),
            ],
          ),
          width: 600,
          height: 400,
          overlay: true,
        ),
      );

      await tester.tap(find.text('Product'));
      await tester.pumpAndSettle();

      await _expectFocusStop(tester, 'Analytics');
    });

    _testSemantics('PlChatBubble preview', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlChatBubble(
            preview: PlChatBubbleLinkPreview(
              onPressed: () {},
              title: const Text('Prop conventions'),
            ),
            child: const Text('Have a look'),
          ),
          width: 400,
        ),
      );

      await _expectFocusStop(tester, 'Prop conventions');

      // A card with nothing to open takes no focus and says nothing of it.
      await tester.pumpWidget(
        host(
          const PlChatBubble(
            preview: PlChatBubbleLinkPreview(title: Text('Prop conventions')),
            child: Text('Have a look'),
          ),
          width: 400,
        ),
      );

      _expectNoFocus(tester, 'Prop conventions');
      expect(find.semantics.byFlag(SemanticsFlag.isFocusable), findsNothing);
    });

    _testSemantics('PlToast action', (WidgetTester tester) async {
      late PlToastController toasts;

      await tester.pumpWidget(
        host(
          PlToastProvider(
            child: Builder(
              builder: (BuildContext context) {
                toasts = PlToastProvider.of(context);

                return const SizedBox.shrink();
              },
            ),
          ),
          width: 600,
          height: 500,
        ),
      );

      toasts.show(
        PlToast(
          title: const Text('Deleted'),
          actionLabel: const Text('Undo'),
          onAction: () {},
          timeout: Duration.zero,
        ),
      );
      await tester.pumpAndSettle();

      await _expectFocusStop(tester, 'Undo');
    });

    _testSemantics('PlPill', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(PlPill(title: const Text('Recording'), onPressed: () {}), width: 320),
      );

      await _expectFocusStop(tester, 'Recording');

      // A pill that cannot be pressed takes no focus and says nothing of it.
      await tester.pumpWidget(host(const PlPill(title: Text('Recording')), width: 320));

      expect(find.semantics.byFlag(SemanticsFlag.isFocusable), findsNothing);
    });

    _testSemantics('PlTextLink', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(PlTextLink(onPressed: () {}, child: const Text('the changelog'))),
      );

      await _expectFocusStop(tester, 'the changelog');
    });

    _testSemantics('PlBreadcrumb steps', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlBreadcrumb(
            items: <PlBreadcrumbItem>[
              PlBreadcrumbItem(label: const Text('Home'), onPressed: () {}),
              const PlBreadcrumbItem(label: Text('Billing'), current: true),
            ],
          ),
          width: 640,
        ),
      );

      await _expectFocusStop(tester, 'Home');

      // The page the reader is on cannot be followed, and takes no focus.
      _expectNoFocus(tester, 'Billing');
    });

    _testSemantics('PlBreadcrumb fold', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlBreadcrumb(
            items: <PlBreadcrumbItem>[
              for (int index = 0; index < 6; index += 1)
                PlBreadcrumbItem(label: Text('Step $index'), onPressed: () {}),
            ],
            maxItems: 3,
          ),
          width: 640,
        ),
      );

      await _expectFocusStop(tester, 'Show the hidden steps');
    });

    _testSemantics('the × that dismisses, through PlAlert', (WidgetTester tester) async {
      await tester.pumpWidget(host(PlAlert(onClose: () {}, child: const Text('Note')), width: 400));

      await _expectFocusStop(tester, 'Dismiss');
    });
  });
}
