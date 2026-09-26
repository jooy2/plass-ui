// That Escape on the trigger of a closed popup reaches the modal it sits in.
//
// Every popup here binds Escape while it is open, to close itself before the
// modal round it hears the key. Closed, the key is the modal's. The search for
// an intent's action stops at the first action that maps it, enabled or not,
// so a popup that kept a disabled action in its map while closed would keep
// the key from the modal, and a reader in a dialog with a menu in it could not
// leave the dialog from the keyboard.
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/host.dart';

/// A popup's trigger, as it is used in a modal.
class _Popup {
  const _Popup(this.build, this.trigger, {this.opensOnFocus = false});

  final Widget Function() build;

  /// Words on the trigger, which the focus is put on.
  final String trigger;

  /// Whether the focus alone opens the popup, as it does a tooltip's and a
  /// hover card's, so the first Escape is the popup's.
  final bool opensOnFocus;
}

final Map<String, _Popup> _popups = <String, _Popup>{
  'PlPopover': _Popup(
    () => PlPopover(
      open: false,
      onOpenChanged: (bool _) {},
      title: const Text('Explain'),
      trigger: PlButton(onPressed: () {}, child: const Text('Why?')),
    ),
    'Why?',
  ),
  'PlHoverCard': _Popup(
    () => PlHoverCard(
      delay: Duration.zero,
      title: const Text('Ada Lovelace'),
      trigger: const Focus(child: Text('Ada')),
    ),
    'Ada',
    opensOnFocus: true,
  ),
  'PlTooltip': _Popup(
    () => const PlTooltip(
      content: Text('Copy'),
      delay: Duration.zero,
      child: Focus(child: Text('Trigger')),
    ),
    'Trigger',
    opensOnFocus: true,
  ),
  'PlMenu': _Popup(
    () => PlMenu(
      items: const <PlMenuEntry>[PlMenuItem(label: 'Cut')],
      trigger: (BuildContext context, VoidCallback open, bool isOpen) =>
          PlButton(onPressed: open, child: const Text('Edit')),
    ),
    'Edit',
  ),
  'PlNavigationMenu': _Popup(
    () => const PlNavigationMenu(
      items: <PlNavigationMenuItem>[
        PlNavigationMenuItem(
          label: 'Products',
          links: <PlNavigationMenuLink>[PlNavigationMenuLink(title: 'Analytics')],
        ),
      ],
    ),
    'Products',
  ),
  'PlSelect': _Popup(
    () => PlSelect<String>(
      value: null,
      onChanged: (String? _) {},
      placeholder: const Text('City'),
      options: const <PlSelectOption<String>>[
        PlSelectOption<String>(value: 'kr-11', label: Text('Seoul')),
      ],
    ),
    'City',
  ),
  'PlDatePicker': _Popup(
    () => PlDatePicker(
      value: null,
      onChanged: (DateTime? _) {},
      placeholder: const Text('Departure'),
    ),
    'Departure',
  ),
};

/// Puts the focus on the trigger that says [words], and checks that it holds it.
///
/// A field lays out every word it could say, unseen, to be as wide as the
/// longest, and those copies are kept out of the focus: the words drawn are the
/// ones whose focus can be taken.
Future<void> _focus(WidgetTester tester, String words) async {
  final FocusNode node = find
      .text(words)
      .evaluate()
      .map(Focus.of)
      .firstWhere((FocusNode node) => node.canRequestFocus);

  node.requestFocus();
  await tester.pumpAndSettle();

  expect(node.hasPrimaryFocus, isTrue, reason: 'the trigger holds the focus');
}

void main() {
  group('Escape on a closed popup trigger', () {
    for (final MapEntry<String, _Popup> entry in _popups.entries) {
      testWidgets('reaches a modal round a ${entry.key}', (WidgetTester tester) async {
        final List<bool> modal = <bool>[];

        await tester.pumpWidget(
          host(
            PlModal(
              open: true,
              onOpenChanged: modal.add,
              title: const Text('Settings'),
              child: entry.value.build(),
            ),
            overlay: true,
          ),
        );
        await tester.pumpAndSettle();

        await _focus(tester, entry.value.trigger);

        if (entry.value.opensOnFocus) {
          // Open, the popup takes the key and the modal stays.
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();

          expect(modal, isEmpty, reason: 'the open popup closes first');
        }

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(modal, <bool>[false]);
      });
    }
  });

  testWidgets('stops at an open popover that refuses to be dismissed', (WidgetTester tester) async {
    final List<bool> modal = <bool>[];

    await tester.pumpWidget(
      host(
        PlModal(
          open: true,
          onOpenChanged: modal.add,
          title: const Text('Settings'),
          child: PlPopover(
            open: true,
            dismissible: false,
            title: const Text('Explain'),
            trigger: PlButton(onPressed: () {}, child: const Text('Why?')),
          ),
        ),
        overlay: true,
      ),
    );
    await tester.pumpAndSettle();

    await _focus(tester, 'Why?');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    // The popover is on top, and the key is its to refuse.
    expect(find.text('Explain'), findsOneWidget);
    expect(modal, isEmpty);
  });
}
