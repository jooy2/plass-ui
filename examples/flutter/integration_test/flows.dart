/// What a person does in the app, written once.
///
/// `test/app_test.dart` runs these on the host at a phone's and a tablet's size,
/// and `integration_test/app_test.dart` runs them on a device, where they also
/// leave a screenshot of every step.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plass_showcase/app/app.dart';

/// Takes a picture of the screen under a name.
typedef Shot = Future<void> Function(WidgetTester tester, String name);

/// Draws enough frames for a sheet or a popup to finish arriving.
Future<void> settle(WidgetTester tester) async {
  for (var frame = 0; frame < 12; frame += 1) {
    await tester.pump(const Duration(milliseconds: 40));
  }
}

Future<void> _open(WidgetTester tester) async {
  await tester.pumpWidget(const ShowcaseApp());
  await settle(tester);
}

Future<void> _go(WidgetTester tester, String destination) async {
  await tester.tap(find.text(destination).last);
  await settle(tester);
}

Future<void> _press(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label).last);
  await settle(tester);
  await tester.tap(find.text(label).last);
  await settle(tester);
}

Future<void> _pressLabelled(WidgetTester tester, String label) async {
  await tester.tap(find.bySemanticsLabel(label).first);
  await settle(tester);
}

Future<void> _back(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await settle(tester);
}

/// Every flow, as tests.
void defineFlows({required Shot shot}) {
  testWidgets('Overview shows its figures and answers the bell', (WidgetTester tester) async {
    await _open(tester);
    await shot(tester, 'overview');

    expect(find.text('£48,120'), findsOneWidget);

    await _pressLabelled(tester, 'Notifications');
    expect(find.text('Three new messages'), findsOneWidget);
    await shot(tester, 'overview-toast');

    await _press(tester, 'Month');
    await shot(tester, 'overview-month');
  });

  testWidgets('Inbox searches, opens a conversation and sends a reply', (
    WidgetTester tester,
  ) async {
    await _open(tester);
    await _go(tester, 'Inbox');

    await tester.enterText(find.byType(EditableText).first, 'invoice');
    await settle(tester);
    expect(find.text('Theo Quinn'), findsOneWidget);
    expect(find.text('Anya Sol'), findsNothing);

    await tester.enterText(find.byType(EditableText).first, 'nobody at all');
    await settle(tester);
    expect(find.text('Nothing found'), findsOneWidget);
    await shot(tester, 'inbox-empty');

    await _press(tester, 'Clear the search');
    await _press(tester, 'Nadia Rowan');
    await shot(tester, 'thread');

    await tester.enterText(find.byType(EditableText).last, 'On my way');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    expect(find.text('On my way'), findsOneWidget);

    await _back(tester);
    expect(find.text('6 conversations'), findsOneWidget);
  });

  testWidgets('Orders filters, and deletes an order through a menu and a question', (
    WidgetTester tester,
  ) async {
    await _open(tester);
    await _go(tester, 'Orders');
    await shot(tester, 'orders');

    await _press(tester, 'Filters');
    await shot(tester, 'orders-filters');

    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;

    // A side drawer starts at the top of the screen.
    expect(tester.getTopLeft(find.text('Show orders that are:')).dy, lessThan(screen.height / 4));

    await _press(tester, 'Paid');
    expect(find.text('11 shown'), findsOneWidget);
    await _press(tester, 'Paid');
    await _press(tester, 'Done');

    final actions = find.bySemanticsLabel('Actions for INV-0104');

    await tester.ensureVisible(actions.first);
    await settle(tester);
    await tester.tap(actions.first, warnIfMissed: false);
    await settle(tester);
    await shot(tester, 'orders-menu');

    // A popup stays on the screen, however close to the edge its button is.
    expect(tester.getTopRight(find.text('Delete')).dx, lessThanOrEqualTo(screen.width));

    await tester.tap(find.text('Delete'));
    await settle(tester);
    expect(find.text('Delete INV-0104?'), findsOneWidget);
    await shot(tester, 'orders-confirm');

    await tester.tap(find.text('Delete').last);
    await settle(tester);
    expect(find.text('Deleted INV-0104'), findsOneWidget);
    expect(find.text('22 shown'), findsOneWidget);
    await shot(tester, 'orders-deleted');

    await tester.tap(find.text('Undo'));
    await settle(tester);
    expect(find.text('23 shown'), findsOneWidget);
  });

  testWidgets('Request walks three steps and checks the name', (WidgetTester tester) async {
    await _open(tester);
    await _go(tester, 'Request');
    await shot(tester, 'request-1');

    await _press(tester, 'Next');
    await shot(tester, 'request-2');

    await _press(tester, 'Departure');
    await _press(tester, 'Pick a day');
    await shot(tester, 'request-calendar');
    await tester.binding.handlePopRoute();
    await settle(tester);

    await _press(tester, 'Next');
    await shot(tester, 'request-3');

    await _press(tester, 'Send request');
    expect(find.text('Enter your name'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).first, 'Ada');
    await settle(tester);
    await _press(tester, 'Next');
    await _press(tester, 'Next');
    await _press(tester, 'Send request');
    expect(find.text('Request sent for Ada'), findsOneWidget);
  });

  testWidgets('More changes the theme and the direction of the whole app', (
    WidgetTester tester,
  ) async {
    await _open(tester);
    await _go(tester, 'More');
    await shot(tester, 'more');

    await _press(tester, 'Dark mode');
    await shot(tester, 'more-dark');
    await _go(tester, 'Overview');
    await shot(tester, 'overview-dark');
    await _go(tester, 'More');
    await _press(tester, 'Dark mode');

    await _press(tester, 'Right to left');
    await _go(tester, 'Inbox');
    await shot(tester, 'inbox-rtl');
    await _go(tester, 'More');
    await _press(tester, 'Right to left');
  });

  testWidgets('Overlays open, and close on the system back', (WidgetTester tester) async {
    await _open(tester);
    await _go(tester, 'More');
    await _press(tester, 'Overlays');
    await shot(tester, 'overlays');

    for (final (String button, String inside) in const <(String, String)>[
      ('Modal', 'Rename project'),
      ('Full-screen modal', 'Terms'),
      ('Bottom drawer', 'Share'),
      ('Side drawer', 'Projects'),
      ('Popover', 'Effective rate'),
      ('Menu', 'Paste'),
      ('Command palette', 'Invite a colleague'),
      ('Confirm', 'Delete this project?'),
    ]) {
      await _press(tester, button);
      expect(find.text(inside), findsOneWidget, reason: button);
      await shot(tester, 'overlay-$button');
      await _back(tester);
      expect(find.text(inside), findsNothing, reason: button);
    }

    await _press(tester, 'Toast');
    expect(find.text('Your changes are live.'), findsOneWidget);
    await shot(tester, 'overlay-toast');

    await _back(tester);
    expect(find.text('Components'), findsOneWidget);
  });

  testWidgets('Components finds a component and shows its demos', (WidgetTester tester) async {
    await _open(tester);
    await _go(tester, 'More');
    await _press(tester, 'Components');
    await shot(tester, 'components');

    await tester.enterText(find.byType(EditableText).first, 'butt');
    await settle(tester);
    await _press(tester, 'button');
    await shot(tester, 'component-button');
    await _press(tester, 'sizes');
    await shot(tester, 'component-button-sizes');
  });

  testWidgets('Media shows its pictures', (WidgetTester tester) async {
    await _open(tester);
    await _go(tester, 'More');
    await _press(tester, 'Media');
    await tester.pump(const Duration(milliseconds: 400));
    await shot(tester, 'media');

    expect(find.text('Gallery'), findsOneWidget);
  });
}
