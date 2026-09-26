import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';

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

/// The Customer heading a press can reach. That is the pinned band's copy,
/// which is built after the grid and lies over the grid's own heading once
/// the table has measured its columns, and the grid's own before then, while
/// it is the only one.
Finder customerHeading() => find.text('Customer').last;

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

        await tester.tap(customerHeading());
        await tester.pumpAndSettle();

        expect(customers(tester), <String>['Acme', 'Globex', 'Initech']);
      });

      testWidgets('sorts from the keyboard, on a heading Tab reaches', (WidgetTester tester) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        await tester.pumpWidget(host(afterFocusStop(before, table()), width: 640));
        before.requestFocus();
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(customers(tester), <String>['Acme', 'Globex', 'Initech']);
      });

      testWidgets('turns it round on the second and puts it back on the third', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(table(), width: 640));

        await tester.tap(customerHeading());
        await tester.pumpAndSettle();
        await tester.tap(customerHeading());
        await tester.pumpAndSettle();
        expect(customers(tester), <String>['Initech', 'Globex', 'Acme']);

        await tester.tap(customerHeading());
        await tester.pumpAndSettle();
        expect(customers(tester), <String>['Initech', 'Acme', 'Globex']);
      });

      testWidgets('keeps a blank cell last when the column is turned round', (
        WidgetTester tester,
      ) async {
        List<String> invoices() => tester
            .widgetList<Text>(find.byType(Text))
            .map((Text one) => one.data ?? '')
            .where((String one) => one.startsWith('INV-'))
            .toList();

        await tester.pumpWidget(
          host(table(data: const <Invoice>[Invoice('INV-04', '', 10), ...rows]), width: 640),
        );

        await tester.tap(customerHeading());
        await tester.pumpAndSettle();
        expect(invoices(), <String>['INV-01', 'INV-02', 'INV-03', 'INV-04']);

        await tester.tap(customerHeading());
        await tester.pumpAndSettle();
        expect(invoices(), <String>['INV-03', 'INV-02', 'INV-01', 'INV-04']);
      });

      testWidgets('keeps rows that compare the same in the order they came in', (
        WidgetTester tester,
      ) async {
        // Past a few dozen rows, where `List.sort` stops keeping ties in order.
        const statuses = <String>['Paid', 'Open', 'Void'];
        final data = <Invoice>[
          for (var index = 0; index < 60; index += 1)
            Invoice('INV-${index.toString().padLeft(2, '0')}', statuses[index % 3], index),
        ];

        await tester.pumpWidget(host(table(data: data), width: 640));
        await tester.tap(customerHeading());
        await tester.pumpAndSettle();

        final List<String> ids = tester
            .widgetList<Text>(find.byType(Text))
            .map((Text one) => one.data ?? '')
            .where((String one) => one.startsWith('INV-'))
            .toList();

        expect(ids, <String>[
          for (final status in <String>['Open', 'Paid', 'Void'])
            for (final one in data)
              if (one.customer == status) one.id,
        ]);
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
        await tester.tap(customerHeading());
        await tester.pumpAndSettle();

        // Flutter's semantics have no sort direction, so the heading carries the
        // word the React build gets from `aria-sort`.
        expect(
          tester.getSemantics(find.text('Customer').first).value,
          PlassLabels.english.sortedAscending,
        );

        handle.dispose();
      });

      testWidgets('fades the chevron of a column that is not sorted, and only that one', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            table(
              sort: const PlDataTableSort(key: 'customer', direction: PlDataTableSortDirection.asc),
              onSortChanged: (PlDataTableSort? _) {},
            ),
            width: 640,
          ),
        );

        // The total's chevron is faint. The customer's is not, and is not
        // painted through an opacity of 1 either, which would be a layer for
        // nothing.
        expect(
          tester.layers.whereType<OpacityLayer>().map((OpacityLayer layer) => layer.alpha),
          <int>[Color.getAlphaFromOpacity(0.3)],
        );
      });

      testWidgets(
        'turns the mark of the column it sorts and brings it up over the house duration',
        (WidgetTester tester) async {
          await tester.pumpWidget(host(table(), width: 640));
          await tester.pumpAndSettle();

          /// How opaque every sort mark is and how far it has turned, heading by
          /// heading, the pinned band's copy included.
          List<(double, double)> sortMarks() {
            return <(double, double)>[
              for (final Element mark in find.byType(AnimatedRotation).evaluate())
                (
                  mark.findAncestorWidgetOfExactType<PlassFiltered>()!.opacity,
                  tester
                      .widget<RotationTransition>(
                        find.descendant(
                          of: find.byElementPredicate((Element one) => one == mark),
                          matching: find.byType(RotationTransition),
                        ),
                      )
                      .turns
                      .value,
                ),
            ];
          }

          // Customer and Total, both faint and pointing down.
          expect(sortMarks().toSet(), <(double, double)>{(0.3, 0)});

          // The pinned band's copy, which is the heading on top once the table
          // has settled.
          await tester.tap(find.text('Customer').last);
          await tester.pump();
          // The clock starts on the frame after the change, as an animation's
          // does.
          await tester.pump();
          await tester.pump(PlassTokens.duration ~/ 2);

          final double along = PlassTokens.ease.transform(0.5);
          final List<(double, double)> halfway = sortMarks();

          // The customer's mark halfway to whole and halfway round to point up,
          // and the total's where it was.
          expect(halfway.where(((double, double) one) => one != (0.3, 0.0)), isNotEmpty);

          for (final (double opacity, double turns) in halfway) {
            if (opacity == 0.3) {
              expect(turns, 0);

              continue;
            }

            expect(opacity, closeTo(0.3 + 0.7 * along, 1e-9));
            expect(turns, closeTo(0.5 * along, 1e-9));
          }

          await tester.pumpAndSettle();

          expect(sortMarks().toSet(), <(double, double)>{(1, 0.5), (0.3, 0)});
        },
      );

      testWidgets('turns the mark of the column it sorts at once under reduced motion', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(table(), width: 640, disableAnimations: true));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Customer').last);
        await tester.pump();

        final List<double> opacities = <double>[
          for (final Element mark in find.byType(AnimatedRotation).evaluate())
            mark.findAncestorWidgetOfExactType<PlassFiltered>()!.opacity,
        ];

        expect(opacities, contains(1));
        expect(tester.binding.transientCallbackCount, 0);
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

        await tester.tap(customerHeading());
        await tester.pumpAndSettle();
        expect(customers(tester), <String>['Acme', 'Globex', 'Initech']);

        await tester.tap(customerHeading());
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

        await tester.tap(customerHeading());
        await tester.pumpAndSettle();

        expect(called, isTrue);
        expect(reported, isNull);
        // Still descending: the sort belongs to whoever passed it.
        expect(customers(tester), <String>['Initech', 'Globex', 'Acme']);
      });

      testWidgets('puts the rows back when a parent that holds the sort clears it', (
        WidgetTester tester,
      ) async {
        PlDataTableSort? sort;
        late StateSetter setSort;

        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                setSort = setState;

                return table(
                  sort: sort,
                  onSortChanged: (PlDataTableSort? next) => setState(() => sort = next),
                );
              },
            ),
            width: 640,
          ),
        );

        // Ascending, descending, and then off, fed back through the parent.
        for (var press = 0; press < 3; press += 1) {
          await tester.tap(customerHeading());
          await tester.pumpAndSettle();
        }

        expect(sort, isNull);
        expect(customers(tester), <String>['Initech', 'Acme', 'Globex']);

        await tester.tap(customerHeading());
        await tester.pumpAndSettle();
        expect(customers(tester), <String>['Acme', 'Globex', 'Initech']);

        // Cleared by the parent itself, with no press.
        setSort(() => sort = null);
        await tester.pumpAndSettle();
        expect(customers(tester), <String>['Initech', 'Acme', 'Globex']);
      });

      testWidgets('leaves the rows alone when the sort is being done elsewhere', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(table(manual: const <PlDataTableStage>[PlDataTableStage.sort]), width: 640),
        );

        await tester.tap(customerHeading());
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

        // The pinned band's box by now, which is built after every row and lies
        // over the grid's own.
        await tester.tap(find.byType(PlCheckbox).last);
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

      testWidgets('keys a row by its place in `rows` without `rowKey`, after a sort', (
        WidgetTester tester,
      ) async {
        List<Object>? keys;
        List<Invoice>? picked;

        await tester.pumpWidget(
          host(
            PlDataTable<Invoice>(
              columns: columnsOf(),
              rows: rows,
              selection: PlDataTableSelection.multiple,
              onSelectedChanged: (List<Object> next, List<Invoice> chosen) {
                keys = next;
                picked = chosen;
              },
            ),
            width: 640,
          ),
        );

        await tester.tap(customerHeading());
        await tester.pumpAndSettle();
        // Acme, drawn first and second in `rows`.
        await tester.tap(find.byType(PlCheckbox).at(1));
        await tester.pumpAndSettle();

        expect(keys, <Object>[1]);
        expect(picked!.single.customer, 'Acme');
        expect(tester.widget<PlCheckbox>(find.byType(PlCheckbox).at(1)).value, isTrue);
        expect(tester.widget<PlCheckbox>(find.byType(PlCheckbox).at(2)).value, isFalse);
        expect(tester.widget<PlCheckbox>(find.byType(PlCheckbox).at(3)).value, isFalse);
      });

      testWidgets('keys a row by its place in `rows` without `rowKey`, on page two', (
        WidgetTester tester,
      ) async {
        final data = <Invoice>[
          for (var index = 0; index < 15; index += 1)
            Invoice('INV-$index', 'Customer $index', index),
        ];
        List<Object>? keys;
        List<Invoice>? picked;

        await tester.pumpWidget(
          host(
            PlDataTable<Invoice>(
              columns: columnsOf(),
              rows: data,
              selection: PlDataTableSelection.multiple,
              paging: PlDataTablePaging.pages,
              onSelectedChanged: (List<Object> next, List<Invoice> chosen) {
                keys = next;
                picked = chosen;
              },
            ),
            width: 640,
            height: 900,
          ),
        );

        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(PlCheckbox).at(1));
        await tester.pumpAndSettle();

        expect(keys, <Object>[10]);
        expect(picked!.single.id, 'INV-10');

        // The first row of page one sits in the same place and is not the one
        // that was ticked.
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();

        expect(find.text('Customer 0'), findsOneWidget);
        expect(tester.widget<PlCheckbox>(find.byType(PlCheckbox).at(1)).value, isFalse);
      });

      testWidgets('hands every callback the row’s place in `rows` rather than on the screen', (
        WidgetTester tester,
      ) async {
        final asked = <(String, int)>[];
        (Invoice, int)? pressed;

        await tester.pumpWidget(
          host(
            PlDataTable<Invoice>(
              columns: <PlDataTableColumn<Invoice>>[
                PlDataTableColumn<Invoice>(
                  key: 'customer',
                  header: const Text('Customer'),
                  sortable: true,
                  value: (Invoice row) => row.customer,
                  cell: (Invoice row, int index) => Text('${row.customer} $index'),
                ),
              ],
              rows: rows,
              rowKey: (Invoice row, int _) => row.id,
              selection: PlDataTableSelection.multiple,
              isRowSelectable: (Invoice row, int index) {
                asked.add((row.customer, index));

                return true;
              },
              onRowPressed: (Invoice row, int index) => pressed = (row, index),
            ),
            width: 640,
          ),
        );

        await tester.tap(customerHeading());
        await tester.pumpAndSettle();
        asked.clear();
        // A rebuild, so the sorted rows are asked about again.
        await tester.tap(find.byType(PlCheckbox).at(1));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Acme 1'));
        await tester.pumpAndSettle();

        // Acme, Globex, Initech: second, third and first in `rows`.
        expect(customers(tester), <String>['Acme 1', 'Globex 2', 'Initech 0']);
        expect(pressed?.$1.customer, 'Acme');
        expect(pressed?.$2, 1);
        expect(asked, isNotEmpty);
        expect(
          asked,
          everyElement(isIn(<(String, int)>[('Initech', 0), ('Acme', 1), ('Globex', 2)])),
        );
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

        // The rows are painted behind the grid, by the painter around it.
        final dynamic bands = tester
            .widget<CustomPaint>(
              find.ancestor(of: find.byType(Table), matching: find.byType(CustomPaint)).first,
            )
            .painter;
        final List<Color?> fills = <Color?>[
          for (var index = 0; index < 3; index += 1)
            (bands.decorationOf(index) as BoxDecoration).color,
        ];

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

      testWidgets('reports the page it moved to when nobody controls it', (
        WidgetTester tester,
      ) async {
        final reported = <int>[];

        await tester.pumpWidget(
          host(
            PlDataTable<Invoice>(
              columns: columnsOf(),
              rows: many(),
              rowKey: (Invoice row, int _) => row.id,
              paging: PlDataTablePaging.pages,
              onPageChanged: reported.add,
            ),
            width: 640,
            height: 900,
          ),
        );

        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        expect(find.text('Customer 10'), findsOneWidget);
        // Once, because the second press asked for the page it was already on.
        expect(reported, <int>[2]);
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

      testWidgets('keys a row by its place in the whole set when the pages arrive one at a time', (
        WidgetTester tester,
      ) async {
        List<Object>? reported;

        // No `rowKey`, which is the case this is about.
        Widget server(int page) => PlDataTable<Invoice>(
          columns: columnsOf(),
          rows: many().sublist((page - 1) * 10, page * 10),
          paging: PlDataTablePaging.pages,
          page: page,
          manual: const <PlDataTableStage>[PlDataTableStage.pages],
          rowCount: 25,
          selection: PlDataTableSelection.multiple,
          onSelectedChanged: (List<Object> keys, List<Invoice> _) => reported = keys,
        );

        await tester.pumpWidget(host(server(1), width: 640, height: 900));
        // The header's tick first, then one per row.
        await tester.tap(find.byType(PlCheckbox).at(1));
        await tester.pumpAndSettle();

        expect(reported, <Object>[0]);

        await tester.pumpWidget(host(server(2), width: 640, height: 900));
        await tester.pumpAndSettle();

        // The first row of page two is not the row ticked on page one, although
        // both are the first row of the `rows` they arrived in.
        expect(find.text('Customer 10'), findsOneWidget);
        expect(tester.widget<PlCheckbox>(find.byType(PlCheckbox).at(1)).value, isFalse);

        await tester.tap(find.byType(PlCheckbox).at(1));
        await tester.pumpAndSettle();

        expect(reported, <Object>[0, 10]);
      });
    });

    group('the keyboard', () {
      /// One plain column, so nothing in the grid takes the focus.
      final List<PlDataTableColumn<Invoice>> plain = <PlDataTableColumn<Invoice>>[
        PlDataTableColumn<Invoice>(
          key: 'id',
          header: const Text('Invoice'),
          cell: (Invoice row, int _) => Text(row.id),
        ),
      ];
      final List<Invoice> many = <Invoice>[
        for (var index = 0; index < 24; index += 1) Invoice('INV-${10 + index}', 'Acme', index),
      ];

      Future<void> tabInto(
        WidgetTester tester,
        List<Invoice> data, {
        List<PlDataTableColumn<Invoice>>? columns,
        Widget? caption,
        String? semanticLabel = 'Open invoices',
      }) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        await tester.pumpWidget(
          host(
            afterFocusStop(
              before,
              PlDataTable<Invoice>(
                columns: columns ?? plain,
                rows: data,
                rowKey: (Invoice row, int _) => row.id,
                maxHeight: 200,
                caption: caption,
                semanticLabel: semanticLabel,
              ),
            ),
            width: 640,
          ),
        );
        await tester.pumpAndSettle();

        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
      }

      testWidgets('scrolls a grid past its cap from a stop named by `semanticLabel`', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tabInto(tester, many);

        expect(
          tester.getSemantics(find.bySemanticsLabel('Open invoices')),
          isSemantics(label: 'Open invoices', isFocusable: true, isFocused: true),
        );

        final ScrollController controller = tester
            .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
            .controller!;

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(controller.offset, 40);

        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pumpAndSettle();
        expect(controller.offset, controller.position.maxScrollExtent);

        handle.dispose();
      });

      testWidgets('names the stop with the words of a caption, and reads them only there', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tabInto(tester, many, caption: const Text('Unpaid'), semanticLabel: null);

        expect(
          tester.getSemantics(find.bySemanticsLabel('Unpaid')),
          isSemantics(label: 'Unpaid', isFocusable: true, isFocused: true),
        );
        expect(semanticsLabels(tester).where((String label) => label == 'Unpaid'), hasLength(1));

        handle.dispose();
      });

      testWidgets('is no stop while every row fits', (WidgetTester tester) async {
        await tabInto(tester, rows);

        expect(tester.binding.focusManager.primaryFocus?.debugLabel, isNot('PlassKeyboardScroll'));
      });

      testWidgets('rings the grid while it holds the focus itself, and not for a heading in it', (
        WidgetTester tester,
      ) async {
        // Every ring on screen, told apart by where it sits: the grid's inside
        // the sheet, a heading's outside itself.
        List<double> rings() => tester
            .widgetList<CustomPaint>(find.byType(CustomPaint))
            .map((CustomPaint paint) => paint.foregroundPainter)
            .whereType<PlassFocusRingPainter>()
            .map((PlassFocusRingPainter ring) => ring.offset)
            .toList();

        // A grid that fits is no stop, so Tab goes straight to the heading,
        // which is the one ring drawn.
        await tabInto(tester, rows, columns: columnsOf());

        expect(tester.binding.focusManager.primaryFocus?.debugLabel, isNot('PlassKeyboardScroll'));
        expect(rings(), <double>[focusRingOffset]);

        // A grid past its cap is a stop, ringed when Tab reaches it.
        await tabInto(tester, many, columns: columnsOf());

        expect(tester.binding.focusManager.primaryFocus?.debugLabel, 'PlassKeyboardScroll');
        expect(rings(), <double>[-focusRingWidth]);

        // And the ring moves to the heading the next Tab reaches, rather than
        // staying round the grid as well.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(tester.binding.focusManager.primaryFocus?.debugLabel, isNot('PlassKeyboardScroll'));
        expect(rings(), <double>[focusRingOffset]);

        // Back on the grid, it is ringed again.
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();

        expect(tester.binding.focusManager.primaryFocus?.debugLabel, 'PlassKeyboardScroll');
        expect(rings(), <double>[-focusRingWidth]);
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
