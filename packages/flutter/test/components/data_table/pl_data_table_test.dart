import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

class Invoice {
  const Invoice(this.id, this.customer, this.total);

  final String id;
  final String customer;
  final int total;
}

const List<Invoice> rows = <Invoice>[
  Invoice('INV-03', 'Initech', 90),
  Invoice('INV-01', 'Acme', 340),
  Invoice('INV-02', 'Globex', 120),
];

List<PlDataTableColumn<Invoice>> columnsOf() => <PlDataTableColumn<Invoice>>[
  PlDataTableColumn<Invoice>(
    key: 'id',
    header: const Text('Invoice'),
    value: (Invoice row) => row.id,
    cell: (Invoice row, int _) => Text(row.id),
  ),
  PlDataTableColumn<Invoice>(
    key: 'customer',
    header: const Text('Customer'),
    sortable: true,
    value: (Invoice row) => row.customer,
    cell: (Invoice row, int _) => Text(row.customer),
  ),
  PlDataTableColumn<Invoice>(
    key: 'total',
    header: const Text('Total'),
    align: PlassAlign.end,
    sortable: true,
    value: (Invoice row) => row.total,
    cell: (Invoice row, int _) => Text('\$${row.total}'),
  ),
];

/// The customer column, top to bottom, as the reader sees it.
List<String> customers(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((Text one) => one.data ?? '')
      .where(
        (String one) =>
            one.startsWith('Acme') || one.startsWith('Globex') || one.startsWith('Initech'),
      )
      .toList();
}

Widget table({
  List<PlDataTableColumn<Invoice>>? columns,
  List<Invoice> data = rows,
  bool searchable = false,
  PlDataTableSelection selection = PlDataTableSelection.none,
  PlDataTablePaging paging = PlDataTablePaging.scroll,
  int pageSize = 10,
  PlDataTableSort? sort,
  ValueChanged<PlDataTableSort?>? onSortChanged,
  void Function(List<Object>, List<Invoice>)? onSelectedChanged,
  List<Object>? initialSelected,
  bool Function(Invoice, int)? isRowSelectable,
  List<PlDataTableStage> manual = const <PlDataTableStage>[],
  int? rowCount,
  bool loading = false,
  Widget? caption,
}) {
  return PlDataTable<Invoice>(
    columns: columns ?? columnsOf(),
    rows: data,
    rowKey: (Invoice row, int _) => row.id,
    searchable: searchable,
    selection: selection,
    paging: paging,
    pageSize: pageSize,
    sort: sort,
    onSortChanged: onSortChanged,
    onSelectedChanged: onSelectedChanged,
    initialSelected: initialSelected,
    isRowSelectable: isRowSelectable,
    manual: manual,
    rowCount: rowCount,
    loading: loading,
    caption: caption,
  );
}

void main() {
  group('PlDataTable', () {
    group('rendering', () {
      testWidgets('draws one heading per column', (WidgetTester tester) async {
        await tester.pumpWidget(host(table(), width: 640));

        // `findsWidgets` rather than one each: the pinned band is a copy of
        // the header row, so a settled table draws every name twice.
        expect(find.text('Invoice'), findsWidgets);
        expect(find.text('Customer'), findsWidgets);
        expect(find.text('Total'), findsWidgets);
      });

      testWidgets('draws each cell the way its column asked for', (WidgetTester tester) async {
        await tester.pumpWidget(host(table(), width: 640));

        expect(find.text(r'$340'), findsOneWidget);
      });

      testWidgets('leaves the rows in the order they arrived in until it is asked', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(table(), width: 640));

        expect(customers(tester), <String>['Initech', 'Acme', 'Globex']);
      });

      testWidgets('draws the caption above the grid', (WidgetTester tester) async {
        await tester.pumpWidget(host(table(caption: const Text('Open invoices')), width: 640));

        expect(
          tester.getRect(find.text('Open invoices')).top,
          lessThan(tester.getRect(find.text('Customer').first).top),
        );
      });

      testWidgets('says so when there is nothing to show', (WidgetTester tester) async {
        await tester.pumpWidget(host(table(data: const <Invoice>[]), width: 640));

        expect(find.text('Nothing here'), findsOneWidget);
      });
    });

    group('sorting', () {
      testWidgets('sorts a column ascending on the first press', (WidgetTester tester) async {
        await tester.pumpWidget(host(table(), width: 640));

        await tester.tap(find.text('Customer').first);
        await tester.pumpAndSettle();

        expect(customers(tester), <String>['Acme', 'Globex', 'Initech']);
      });

      testWidgets('turns it round on the second and puts it back on the third', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(table(), width: 640));

        await tester.tap(find.text('Customer').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Customer').first);
        await tester.pumpAndSettle();
        expect(customers(tester), <String>['Initech', 'Globex', 'Acme']);

        await tester.tap(find.text('Customer').first);
        await tester.pumpAndSettle();
        expect(customers(tester), <String>['Initech', 'Acme', 'Globex']);
      });

      testWidgets('sorts numbers as numbers rather than as the text the cell drew', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(table(), width: 640));

        await tester.tap(find.text('Total').first);
        await tester.pumpAndSettle();

        // 90 before 120 before 340, which sorting `$90` as a string would not.
        expect(customers(tester), <String>['Initech', 'Globex', 'Acme']);
      });

      testWidgets('says out loud which way a sorted column runs', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(host(table(), width: 640));
        await tester.tap(find.text('Customer').first);
        await tester.pumpAndSettle();

        // Flutter's semantics have no sort direction, so the heading carries the
        // word the React build gets from `aria-sort`.
        expect(
          tester.getSemantics(find.text('Customer').first).value,
          PlassLabels.english.sortedAscending,
        );

        handle.dispose();
      });

      testWidgets('leaves a column that did not ask to be sortable alone', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(table(), width: 640));

        await tester.tap(find.text('Invoice').first);
        await tester.pumpAndSettle();

        expect(customers(tester), <String>['Initech', 'Acme', 'Globex']);
      });

      testWidgets('uses a column comparator when it has one, and reverses what it said', (
        WidgetTester tester,
      ) async {
        final columns = <PlDataTableColumn<Invoice>>[
          PlDataTableColumn<Invoice>(
            key: 'customer',
            header: const Text('Customer'),
            sortable: true,
            compare: (Invoice a, Invoice b) => a.customer.length - b.customer.length,
            cell: (Invoice row, int _) => Text(row.customer),
          ),
        ];

        await tester.pumpWidget(host(table(columns: columns), width: 400));

        await tester.tap(find.text('Customer').first);
        await tester.pumpAndSettle();
        expect(customers(tester), <String>['Acme', 'Globex', 'Initech']);

        await tester.tap(find.text('Customer').first);
        await tester.pumpAndSettle();
        expect(customers(tester), <String>['Initech', 'Globex', 'Acme']);
      });

      testWidgets('reports the sort and draws what it is told when it is controlled', (
        WidgetTester tester,
      ) async {
        PlDataTableSort? reported;
        var called = false;

        await tester.pumpWidget(
          host(
            table(
              sort: const PlDataTableSort(
                key: 'customer',
                direction: PlDataTableSortDirection.desc,
              ),
              onSortChanged: (PlDataTableSort? next) {
                reported = next;
                called = true;
              },
            ),
            width: 640,
          ),
        );

        expect(customers(tester), <String>['Initech', 'Globex', 'Acme']);

        await tester.tap(find.text('Customer').first);
        await tester.pumpAndSettle();

        expect(called, isTrue);
        expect(reported, isNull);
        // Still descending: the sort belongs to whoever passed it.
        expect(customers(tester), <String>['Initech', 'Globex', 'Acme']);
      });

      testWidgets('leaves the rows alone when the sort is being done elsewhere', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(table(manual: const <PlDataTableStage>[PlDataTableStage.sort]), width: 640),
        );

        await tester.tap(find.text('Customer').first);
        await tester.pumpAndSettle();

        expect(customers(tester), <String>['Initech', 'Acme', 'Globex']);
      });
    });

    group('search', () {
      testWidgets('narrows the rows to what was typed', (WidgetTester tester) async {
        await tester.pumpWidget(host(table(searchable: true), width: 640));

        await tester.tap(find.byType(PlTextField));
        await tester.pump();
        await tester.enterText(find.byType(EditableText), 'glob');
        await tester.pumpAndSettle();

        expect(customers(tester), <String>['Globex']);
      });

      testWidgets('ignores case', (WidgetTester tester) async {
        await tester.pumpWidget(host(table(searchable: true), width: 640));

        await tester.tap(find.byType(PlTextField));
        await tester.pump();
        await tester.enterText(find.byType(EditableText), 'ACME');
        await tester.pumpAndSettle();

        expect(customers(tester), <String>['Acme']);
      });

      testWidgets('matches on the column value rather than on what was drawn', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(table(searchable: true), width: 640));

        await tester.tap(find.byType(PlTextField));
        await tester.pump();
        await tester.enterText(find.byType(EditableText), '340');
        await tester.pumpAndSettle();

        expect(customers(tester), <String>['Acme']);
      });

      testWidgets('keeps an unsearchable column out of the match', (WidgetTester tester) async {
        final columns = <PlDataTableColumn<Invoice>>[
          PlDataTableColumn<Invoice>(
            key: 'id',
            header: const Text('Invoice'),
            unsearchable: true,
            value: (Invoice row) => row.id,
            cell: (Invoice row, int _) => Text(row.id),
          ),
          PlDataTableColumn<Invoice>(
            key: 'customer',
            header: const Text('Customer'),
            value: (Invoice row) => row.customer,
            cell: (Invoice row, int _) => Text(row.customer),
          ),
        ];

        await tester.pumpWidget(host(table(columns: columns, searchable: true), width: 640));

        await tester.tap(find.byType(PlTextField));
        await tester.pump();
        await tester.enterText(find.byType(EditableText), 'INV-01');
        await tester.pumpAndSettle();

        // The identifier is on the screen and is not what the row is found by.
        expect(find.text('Nothing here'), findsOneWidget);
      });

      testWidgets('draws no field at all unless it was asked for', (WidgetTester tester) async {
        await tester.pumpWidget(host(table(), width: 640));

        expect(find.byType(EditableText), findsNothing);
      });
    });

    group('selection', () {
      testWidgets('draws no tick column until there is a selection to make', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(table(), width: 640));

        expect(find.byType(PlCheckbox), findsNothing);
      });

      testWidgets('ticks a row and hands back its key and its row', (WidgetTester tester) async {
        List<Object>? keys;
        List<Invoice>? picked;

        await tester.pumpWidget(
          host(
            table(
              selection: PlDataTableSelection.multiple,
              onSelectedChanged: (List<Object> next, List<Invoice> chosen) {
                keys = next;
                picked = chosen;
              },
            ),
            width: 640,
          ),
        );

        // The first box is the header's tick-everything, so the first row's is
        // the one after it.
        await tester.tap(find.byType(PlCheckbox).at(1));
        await tester.pumpAndSettle();

        expect(keys, <Object>['INV-03']);
        expect(picked!.single.customer, 'Initech');
      });

      testWidgets('keeps one row at a time in single mode', (WidgetTester tester) async {
        List<Object>? keys;

        await tester.pumpWidget(
          host(
            table(
              selection: PlDataTableSelection.single,
              onSelectedChanged: (List<Object> next, List<Invoice> _) => keys = next,
            ),
            width: 640,
          ),
        );

        // No tick-everything box in single mode, so the rows start at zero.
        await tester.tap(find.byType(PlCheckbox).at(0));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(PlCheckbox).at(1));
        await tester.pumpAndSettle();

        expect(keys, <Object>['INV-01']);
      });

      testWidgets('ticks everything from the header, and unticks it again', (
        WidgetTester tester,
      ) async {
        List<Object>? keys;

        await tester.pumpWidget(
          host(
            table(
              selection: PlDataTableSelection.multiple,
              onSelectedChanged: (List<Object> next, List<Invoice> _) => keys = next,
            ),
            width: 640,
          ),
        );

        await tester.tap(find.byType(PlCheckbox).first);
        await tester.pumpAndSettle();
        expect(keys, hasLength(3));

        await tester.tap(find.byType(PlCheckbox).first);
        await tester.pumpAndSettle();
        expect(keys, isEmpty);
      });

      testWidgets('says the header box is neither ticked nor empty when some rows are', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            table(
              selection: PlDataTableSelection.multiple,
              initialSelected: const <Object>['INV-01'],
            ),
            width: 640,
          ),
        );

        expect(tester.widget<PlCheckbox>(find.byType(PlCheckbox).first).indeterminate, isTrue);
      });

      testWidgets('leaves a row that cannot be chosen out of the tick-all', (
        WidgetTester tester,
      ) async {
        List<Object>? keys;

        await tester.pumpWidget(
          host(
            table(
              selection: PlDataTableSelection.multiple,
              isRowSelectable: (Invoice row, int _) => row.customer != 'Globex',
              onSelectedChanged: (List<Object> next, List<Invoice> _) => keys = next,
            ),
            width: 640,
          ),
        );

        await tester.tap(find.byType(PlCheckbox).first);
        await tester.pumpAndSettle();

        expect(keys, hasLength(2));
        expect(keys, isNot(contains('INV-02')));
      });

      testWidgets('tints the rows that are chosen', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            table(
              selection: PlDataTableSelection.multiple,
              initialSelected: const <Object>['INV-01'],
            ),
            width: 640,
          ),
        );

        final Iterable<TableRow> rows = tester
            .widget<Table>(find.byType(Table))
            .children
            // The header row has no tint of its own.
            .skip(1);
        final List<Color?> fills = rows
            .map((TableRow row) => (row.decoration as BoxDecoration?)?.color)
            .toList();

        // The second row is Acme, which is the one that was chosen.
        expect(fills[0], isNull);
        expect(fills[1], PlassTokens.light().family(PlassColor.primary).soft);
      });
    });

    group('paging', () {
      List<Invoice> many() => <Invoice>[
        for (var index = 0; index < 25; index += 1) Invoice('INV-$index', 'Customer $index', index),
      ];

      testWidgets('hands out a page at a time', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(table(data: many(), paging: PlDataTablePaging.pages), width: 640, height: 900),
        );

        expect(find.text('Customer 0'), findsOneWidget);
        expect(find.text('Customer 10'), findsNothing);
      });

      testWidgets('steps to the next page', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(table(data: many(), paging: PlDataTablePaging.pages), width: 640, height: 900),
        );

        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        expect(find.text('Customer 10'), findsOneWidget);
        expect(find.text('Customer 0'), findsNothing);
      });

      testWidgets('goes back to the first page when the rows underneath change', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            table(data: many(), paging: PlDataTablePaging.pages, searchable: true),
            width: 640,
            height: 900,
          ),
        );

        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(PlTextField));
        await tester.pump();
        // Not a row's own label, so the only thing on screen holding it is the
        // field the reader typed it into.
        await tester.enterText(find.byType(EditableText), 'ustomer 2');
        await tester.pumpAndSettle();

        // Page two of a different set of rows is not where the reader was, and
        // this row is only on the first page of the narrowed set.
        expect(find.text('Customer 2'), findsOneWidget);
      });

      testWidgets('draws no pager at all when it is scrolling', (WidgetTester tester) async {
        await tester.pumpWidget(host(table(data: many()), width: 640, height: 600));

        expect(find.byType(PlPagination), findsNothing);
      });

      testWidgets('counts against `rowCount` when the pages are being cut elsewhere', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            table(
              data: many().sublist(0, 10),
              paging: PlDataTablePaging.pages,
              manual: const <PlDataTableStage>[PlDataTableStage.pages],
              rowCount: 90,
            ),
            width: 640,
            height: 900,
          ),
        );

        // Nine pages from a table holding ten rows: the other eighty are the
        // server's, and the pager has to say they are there.
        expect(tester.widget<PlPagination>(find.byType(PlPagination)).count, 9);
      });
    });

    group('loading', () {
      testWidgets('draws bars in place of the rows', (WidgetTester tester) async {
        await tester.pumpWidget(host(table(loading: true), width: 640));

        expect(find.byType(PlSkeleton), findsWidgets);
        expect(find.text('Acme'), findsNothing);
      });
    });

    group('the theme', () {
      testWidgets('takes its words from the labels in scope', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            PlassTheme.merge(
              defaults: const PlassDefaults(labels: PlassLabels(selectAll: '전체 선택')),
              child: table(selection: PlDataTableSelection.multiple),
            ),
            width: 640,
          ),
        );

        expect(find.bySemanticsLabel('전체 선택'), findsOneWidget);

        handle.dispose();
      });
    });
  });
}
