import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

const List<PlTransferItem> items = <PlTransferItem>[
  PlTransferItem(value: 'name', label: 'Name'),
  PlTransferItem(value: 'email', label: 'Email'),
  PlTransferItem(value: 'role', label: 'Role'),
  PlTransferItem(value: 'id', label: 'Identifier', disabled: true),
];

void main() {
  group('PlTransfer', () {
    group('the two lists', () {
      testWidgets('puts everything on the leading side to begin with', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlTransfer(items: items, height: 160), width: 700, height: 400),
        );

        expect(find.text('Available'), findsOneWidget);
        expect(find.text('Selected'), findsOneWidget);
        expect(find.text('0/4'), findsOneWidget);
        expect(find.text('0/0'), findsOneWidget);
      });

      testWidgets('shows what has already been chosen on the trailing side', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlTransfer(items: items, defaultValue: <String>['email'], height: 160),
            width: 700,
            height: 400,
          ),
        );

        expect(find.text('0/3'), findsOneWidget);
        expect(find.text('0/1'), findsOneWidget);
      });

      testWidgets('takes headings of its own', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlTransfer(
              items: items,
              sourceLabel: 'Columns',
              targetLabel: 'In the report',
              height: 160,
            ),
            width: 700,
            height: 400,
          ),
        );

        expect(find.text('Columns'), findsOneWidget);
        expect(find.text('In the report'), findsOneWidget);
      });

      testWidgets('says so when a list is empty', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlTransfer(items: items, emptyLabel: 'Nothing yet', height: 160),
            width: 700,
            height: 400,
          ),
        );

        expect(find.text('Nothing yet'), findsOneWidget);
      });
    });

    group('moving', () {
      testWidgets('sends the ticked rows across and drops their ticks', (
        WidgetTester tester,
      ) async {
        final List<List<String>> seen = <List<String>>[];

        await tester.pumpWidget(
          host(
            PlTransfer(items: items, onValueChanged: seen.add, height: 160),
            width: 700,
            height: 400,
          ),
        );

        await tester.tap(find.text('Email'));
        await tester.pumpAndSettle();

        await tester.tap(find.bySemanticsLabel('Move to selected'));
        await tester.pumpAndSettle();

        expect(seen.single, <String>['email']);
        // The row arrived; it is not still waiting to be sent.
        expect(find.text('0/1'), findsOneWidget);
      });

      testWidgets('keeps the order of items on both sides', (WidgetTester tester) async {
        final List<List<String>> seen = <List<String>>[];

        await tester.pumpWidget(
          host(
            PlTransfer(
              items: items,
              defaultValue: const <String>['role'],
              onValueChanged: seen.add,
              height: 160,
            ),
            width: 700,
            height: 400,
          ),
        );

        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Move to selected'));
        await tester.pumpAndSettle();

        // `name` comes before `role` in `items`, so it comes before it here.
        expect(seen.single, <String>['name', 'role']);
      });

      testWidgets('sends them back again', (WidgetTester tester) async {
        final List<List<String>> seen = <List<String>>[];

        await tester.pumpWidget(
          host(
            PlTransfer(
              items: items,
              defaultValue: const <String>['email'],
              onValueChanged: seen.add,
              height: 160,
            ),
            width: 700,
            height: 400,
          ),
        );

        await tester.tap(find.text('Email'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Move to available'));
        await tester.pumpAndSettle();

        expect(seen.single, isEmpty);
      });

      testWidgets('leaves the arrows unpressable until something is ticked', (
        WidgetTester tester,
      ) async {
        final List<List<String>> seen = <List<String>>[];

        await tester.pumpWidget(
          host(
            PlTransfer(items: items, onValueChanged: seen.add, height: 160),
            width: 700,
            height: 400,
          ),
        );

        await tester.tap(find.bySemanticsLabel('Move to selected'));
        await tester.pumpAndSettle();

        expect(seen, isEmpty);
      });

      testWidgets('never moves a disabled row', (WidgetTester tester) async {
        final List<List<String>> seen = <List<String>>[];

        await tester.pumpWidget(
          host(
            PlTransfer(items: items, onValueChanged: seen.add, height: 160),
            width: 700,
            height: 400,
          ),
        );

        await tester.tap(find.text('Identifier'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Move to selected'));
        await tester.pumpAndSettle();

        expect(seen, isEmpty);
      });

      testWidgets('answers with what a controlled pair is given', (WidgetTester tester) async {
        final List<List<String>> seen = <List<String>>[];

        await tester.pumpWidget(
          host(
            PlTransfer(
              items: items,
              value: const <String>[],
              onValueChanged: seen.add,
              height: 160,
            ),
            width: 700,
            height: 400,
          ),
        );

        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Move to selected'));
        await tester.pumpAndSettle();

        expect(seen.single, <String>['name']);
        // All four rows are still on the leading side: the value is the
        // caller's now.
        expect(find.text('0/4'), findsOneWidget);
      });
    });

    group('the heading tick', () {
      testWidgets('ticks every movable row in its own list', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlTransfer(items: items, height: 160), width: 700, height: 400),
        );

        await tester.tap(find.bySemanticsLabel('Select all').first);
        await tester.pumpAndSettle();

        // Three movable rows; the disabled one is not one of them.
        expect(find.text('3/4'), findsOneWidget);
      });
    });

    group('searching', () {
      testWidgets('is off until it is asked for', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlTransfer(items: items, height: 160), width: 700, height: 400),
        );

        expect(find.byType(PlTextField), findsNothing);
      });

      testWidgets('narrows one list without touching the other', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlTransfer(
              items: items,
              searchable: true,
              defaultValue: <String>['role'],
              height: 160,
            ),
            width: 700,
            height: 400,
          ),
        );

        await tester.tap(find.byType(PlTextField).first);
        await tester.pump();
        await tester.enterText(find.byType(EditableText).first, 'ema');
        await tester.pumpAndSettle();

        expect(find.text('Name'), findsNothing);
        expect(find.text('Email'), findsOneWidget);
        // The trailing list still holds its own row.
        expect(find.text('Role'), findsOneWidget);
      });

      testWidgets('folds case, so SEOUL finds Seoul', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlTransfer(
              items: <PlTransferItem>[PlTransferItem(value: 'seoul', label: 'Seoul')],
              searchable: true,
              height: 160,
            ),
            width: 700,
            height: 400,
          ),
        );

        await tester.tap(find.byType(PlTextField).first);
        await tester.pump();
        await tester.enterText(find.byType(EditableText).first, 'SEOUL');
        await tester.pumpAndSettle();

        expect(find.text('Seoul'), findsOneWidget);
      });
    });

    group('the shell', () {
      testWidgets('is never dyed, whatever colour it is given', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlTransfer(items: items, color: PlassColor.danger, height: 160),
            width: 700,
            height: 400,
          ),
        );

        expect(
          decorationsOf(
            tester,
            find.byType(PlTransfer),
          ).every((BoxDecoration decoration) => decoration.gradient is! LinearGradient),
          isTrue,
        );
      });

      testWidgets('takes a height for each list', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlTransfer(items: items, height: 120), width: 700, height: 400),
        );

        final Iterable<SingleChildScrollView> lists = tester.widgetList<SingleChildScrollView>(
          find.byType(SingleChildScrollView),
        );

        expect(lists.length, 2);
      });

      testWidgets('stops everything at once when it is disabled', (WidgetTester tester) async {
        final List<List<String>> seen = <List<String>>[];

        await tester.pumpWidget(
          host(
            PlTransfer(items: items, disabled: true, onValueChanged: seen.add, height: 160),
            width: 700,
            height: 400,
          ),
        );

        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Move to selected'));
        await tester.pumpAndSettle();

        expect(seen, isEmpty);
        expect(find.text('0/4'), findsOneWidget);
      });
    });
  });
}
