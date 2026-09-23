import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/locales.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/icons.dart';

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

      testWidgets('hands the focus to the first row that arrived and says how many moved', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlTransfer(items: items, height: 160), width: 700, height: 400),
        );

        await tester.tap(find.text('Email'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Role'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Move to selected'));
        await tester.pumpAndSettle();

        // The arrow is disabled by the move, and would have let the focus go.
        expect(Focus.of(tester.element(find.text('Email'))).hasPrimaryFocus, isTrue);

        final List<CapturedAccessibilityAnnouncement> said = tester.takeAnnouncements();

        expect(said.single.message, '2 items moved to Selected');
        expect(said.single.assertiveness, Assertiveness.polite);
      });

      testWidgets('keeps the focus in the list the rows were sent to when they are refused', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlTransfer(
              items: items,
              value: const <String>[],
              onValueChanged: (List<String> next) {},
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

        // The list on the trailing side is still empty, and it holds the focus.
        expect(Focus.of(tester.element(find.text('Nothing here'))).hasPrimaryFocus, isTrue);
        // Nothing moved, so nothing is said.
        expect(tester.takeAnnouncements(), isEmpty);
      });

      testWidgets('says the count in the words it was given', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlTransfer(
              items: items,
              targetLabel: 'In the report',
              movedLabel: (int count, String list) => '$list: +$count',
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

        expect(tester.takeAnnouncements().single.message, 'In the report: +1');
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

      testWidgets('turns both arrows towards their own lists under RTL', (
        WidgetTester tester,
      ) async {
        for (final TextDirection direction in TextDirection.values) {
          await tester.pumpWidget(
            host(
              Directionality(
                textDirection: direction,
                child: const PlTransfer(items: items, height: 160),
              ),
              width: 700,
              height: 400,
            ),
          );

          // The arrow to the selected list, then the one back.
          final List<int> turns = tester
              .widgetList<PlassGlyph>(find.byType(PlassGlyph))
              .where((PlassGlyph glyph) => glyph.shape == PlassGlyphShape.arrowRight)
              .map((PlassGlyph glyph) => glyph.quarterTurns)
              .toList();

          expect(
            turns,
            direction == TextDirection.rtl ? <int>[2, 0] : <int>[0, 2],
            reason: '$direction',
          );
        }
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

        await tester.tap(find.bySemanticsLabel('Select all in Available'));
        await tester.pumpAndSettle();

        // Three movable rows; the disabled one is not one of them.
        expect(find.text('3/4'), findsOneWidget);
      });

      testWidgets("is named by a sentence with its own list's heading in it", (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlTransfer(items: items, height: 160), width: 700, height: 400),
        );

        expect(find.bySemanticsLabel('Select all in Available'), findsOneWidget);
        expect(find.bySemanticsLabel('Select all in Selected'), findsOneWidget);
      });

      testWidgets('puts `selectAllLabel` before the heading', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlTransfer(
              items: items,
              selectAllLabel: 'Tick all of',
              sourceLabel: 'Columns',
              targetLabel: 'Shown',
              height: 160,
            ),
            width: 700,
            height: 400,
          ),
        );

        expect(find.bySemanticsLabel('Tick all of Columns'), findsOneWidget);
        expect(find.bySemanticsLabel('Tick all of Shown'), findsOneWidget);
      });

      testWidgets("lets the theme's labels put the list's name where its language puts it", (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlassTheme.merge(
              defaults: const PlassDefaults(labels: ko),
              child: const PlTransfer(items: items, height: 160),
            ),
            width: 700,
            height: 400,
          ),
        );

        // Korean says the list before the verb. Joining the pack's `selectAll`
        // and the heading used to read "전체 선택 사용 가능".
        expect(find.bySemanticsLabel('‘사용 가능’ 목록 전체 선택'), findsOneWidget);
        expect(find.bySemanticsLabel('‘선택됨’ 목록 전체 선택'), findsOneWidget);
      });

      testWidgets("calls a heading with no words by the theme's name for its list", (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlTransfer(items: items, targetLabel: '', height: 160),
            width: 700,
            height: 400,
          ),
        );

        expect(find.bySemanticsLabel('Select all in Selected'), findsOneWidget);
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

    group('items that change', () {
      testWidgets('lets go of the focus node of a row whose item is gone', (
        WidgetTester tester,
      ) async {
        Widget transfer(List<PlTransferItem> shown) {
          return host(PlTransfer(items: shown, height: 160), width: 700, height: 400);
        }

        FocusNode nodeOf(String label) {
          return tester.widget<PlCheckbox>(find.widgetWithText(PlCheckbox, label)).focusNode!;
        }

        await tester.pumpWidget(transfer(items));

        final FocusNode role = nodeOf('Role');
        final FocusNode email = nodeOf('Email');

        role.requestFocus();
        await tester.pumpAndSettle();
        expect(role.hasPrimaryFocus, isTrue);

        // The row goes while it holds the focus, which is where a node disposed
        // before its row left the tree would break the frame.
        await tester.pumpWidget(
          transfer(items.where((PlTransferItem item) => item.value != 'role').toList()),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(() => ChangeNotifier.debugAssertNotDisposed(role), throwsFlutterError);
        // A row that is still there keeps the node it had.
        expect(nodeOf('Email'), same(email));
        expect(ChangeNotifier.debugAssertNotDisposed(email), isTrue);

        // An item that comes back is given a node of its own, and takes the focus.
        await tester.pumpWidget(transfer(items));
        await tester.pumpAndSettle();

        final FocusNode again = nodeOf('Role');

        again.requestFocus();
        await tester.pumpAndSettle();

        expect(again, isNot(same(role)));
        expect(again.hasPrimaryFocus, isTrue);
      });

      testWidgets('drops the tick of a row whose item is gone', (WidgetTester tester) async {
        Widget transfer(List<PlTransferItem> shown) {
          return host(PlTransfer(items: shown, height: 160), width: 700, height: 400);
        }

        await tester.pumpWidget(transfer(items));

        await tester.tap(find.text('Role'));
        await tester.pumpAndSettle();

        expect(find.text('1/4'), findsOneWidget);

        await tester.pumpWidget(
          transfer(items.where((PlTransferItem item) => item.value != 'role').toList()),
        );
        await tester.pumpAndSettle();

        await tester.pumpWidget(transfer(items));
        await tester.pumpAndSettle();

        // The row is back, and it is not still waiting to be moved.
        expect(find.text('0/4'), findsOneWidget);
        expect(tester.widget<PlCheckbox>(find.widgetWithText(PlCheckbox, 'Role')).value, isFalse);
      });
    });

    group('a long list', () {
      /// Two hundred rows, far more than a list 160 pixels tall shows at once.
      final List<PlTransferItem> many = <PlTransferItem>[
        for (int index = 0; index < 200; index += 1)
          PlTransferItem(value: 'row-$index', label: 'Row $index'),
      ];

      testWidgets('builds the rows near what it shows rather than every row', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(PlTransfer(items: many, height: 160), width: 700, height: 400),
        );

        // The two heading ticks and a screenful of rows, give or take the
        // rows built just past each edge.
        expect(find.byType(PlCheckbox, skipOffstage: false).evaluate().length, lessThan(40));
      });

      testWidgets('builds again only the row a tick changed', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlTransfer(items: many, height: 160), width: 700, height: 400),
        );

        final Set<String> built = <String>{};

        // Every element Flutter builds again passes through this hook, and a
        // row is the one checkbox with a label drawn beside it.
        debugOnRebuildDirtyWidget = (Element element, bool builtOnce) {
          final Widget widget = element.widget;

          if (widget is PlCheckbox && widget.label is Text) {
            built.add((widget.label! as Text).data!);
          }
        };
        addTearDown(() => debugOnRebuildDirtyWidget = null);

        await tester.tap(find.text('Row 2'));
        await tester.pumpAndSettle();

        debugOnRebuildDirtyWidget = null;

        expect(find.text('1/200'), findsOneWidget);
        // Every row of both lists used to be built again for one tick.
        expect(built, <String>{'Row 2'});
      });

      testWidgets('keeps the focus on a row its list is scrolled away from', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(PlTransfer(items: many, height: 160), width: 700, height: 400),
        );

        final FocusNode row = tester
            .widget<PlCheckbox>(find.widgetWithText(PlCheckbox, 'Row 1'))
            .focusNode!;

        row.requestFocus();
        await tester.pump();

        final ScrollableState list = tester.state<ScrollableState>(
          find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)),
        );

        list.position.jumpTo(list.position.maxScrollExtent);
        await tester.pumpAndSettle();

        // The row is far past what the list builds, and still holds the focus.
        expect(find.text('Row 1'), findsNothing);
        expect(row.hasPrimaryFocus, isTrue);
      });

      testWidgets('hands the focus to a row that arrived below what its list shows', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlTransfer(
              items: many,
              defaultValue: <String>[for (int index = 0; index < 150; index += 1) 'row-$index'],
              height: 160,
            ),
            width: 700,
            height: 400,
          ),
        );

        await tester.tap(find.text('Row 150'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Move to selected'));
        await tester.pumpAndSettle();

        // It lands a hundred and fifty rows down a list that has not built
        // them, and is scrolled to rather than left for the list to hold.
        expect(Focus.of(tester.element(find.text('Row 150'))).hasPrimaryFocus, isTrue);
        expect(tester.takeAnnouncements().single.message, '1 item moved to Selected');
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

        // One list with rows in it and one empty, and both the height asked for.
        final Finder lists = find.byType(ListView);

        expect(lists, findsNWidgets(2));
        expect(tester.getSize(lists.first).height, 120);
        expect(tester.getSize(lists.last).height, 120);
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
