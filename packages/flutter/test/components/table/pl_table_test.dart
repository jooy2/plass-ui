import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

class _Build {
  const _Build(this.id, this.branch);

  final String id;
  final String branch;
}

const List<_Build> _rows = <_Build>[
  _Build('#412', 'main'),
  _Build('#411', 'fix/glass-edge'),
  _Build('#410', 'topic/table'),
];

List<PlTableColumn<_Build>> _columns() {
  return <PlTableColumn<_Build>>[
    PlTableColumn<_Build>(
      header: const Text('Build'),
      cell: (_Build row, int index) => Text(row.id),
    ),
    PlTableColumn<_Build>(
      header: const Text('Branch'),
      align: PlassAlign.end,
      cell: (_Build row, int index) => Text(row.branch),
    ),
  ];
}

Widget _table({
  List<_Build> rows = _rows,
  bool striped = false,
  bool hoverable = false,
  Widget? caption,
  Widget? empty,
  void Function(_Build row, int index)? onRowPressed,
}) {
  return host(
    PlTable<_Build>(
      rows: rows,
      columns: _columns(),
      striped: striped,
      hoverable: hoverable,
      caption: caption,
      empty: empty,
      onRowPressed: onRowPressed,
    ),
    width: 420,
  );
}

/// The decoration [TableRow] number [index] paints — the header is row `0`.
BoxDecoration _rowDecoration(WidgetTester tester, int index) {
  return tester.widget<Table>(find.byType(Table)).children[index].decoration! as BoxDecoration;
}

void main() {
  group('PlTable', () {
    group('shapes', () {
      testWidgets('draws a heading per column and a cell per row', (WidgetTester tester) async {
        await tester.pumpWidget(_table());

        expect(find.text('Build'), findsOneWidget);
        expect(find.text('Branch'), findsOneWidget);
        expect(find.text('#412'), findsOneWidget);
        expect(find.text('topic/table'), findsOneWidget);
      });

      testWidgets('still draws its headings with no rows at all', (WidgetTester tester) async {
        await tester.pumpWidget(_table(rows: const <_Build>[]));

        expect(find.text('Build'), findsOneWidget);
        expect(find.text('No data'), findsOneWidget);
      });

      testWidgets('takes the empty line it was given', (WidgetTester tester) async {
        await tester.pumpWidget(
          _table(rows: const <_Build>[], empty: const Text('Nothing built yet.')),
        );

        expect(find.text('Nothing built yet.'), findsOneWidget);
        expect(find.text('No data'), findsNothing);
      });

      testWidgets('draws the caption above the grid', (WidgetTester tester) async {
        await tester.pumpWidget(_table(caption: const Text('Recent builds')));

        final caption = tester.getTopLeft(find.text('Recent builds'));
        final heading = tester.getTopLeft(find.text('Build'));

        expect(caption.dy, lessThan(heading.dy));
      });
    });

    group('columns', () {
      testWidgets('measures a column from its content and shares what is left', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_table());

        final widths = tester.widget<Table>(find.byType(Table)).columnWidths!;

        expect(widths[0], isA<IntrinsicColumnWidth>());
        expect(widths[1], isA<IntrinsicColumnWidth>());
      });

      testWidgets('a stated width is the width', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlTable<_Build>(
              rows: _rows,
              columns: <PlTableColumn<_Build>>[
                PlTableColumn<_Build>(
                  header: const Text('Build'),
                  width: 120,
                  cell: (_Build row, int index) => Text(row.id),
                ),
              ],
            ),
            width: 420,
          ),
        );

        expect(tester.widget<Table>(find.byType(Table)).columnWidths![0], isA<FixedColumnWidth>());
        expect(tester.getSize(find.text('#412')).width, lessThanOrEqualTo(120));
      });

      testWidgets('align moves the cell to the trailing edge', (WidgetTester tester) async {
        await tester.pumpWidget(_table());

        final aligned = tester.widget<Align>(
          find.ancestor(of: find.text('main'), matching: find.byType(Align)).first,
        );
        final start = tester.widget<Align>(
          find.ancestor(of: find.text('#412'), matching: find.byType(Align)).first,
        );

        expect(aligned.alignment, AlignmentDirectional.centerEnd);
        expect(start.alignment, AlignmentDirectional.centerStart);
      });
    });

    group('rules', () {
      testWidgets('the header sits on the firmer of the two rules', (WidgetTester tester) async {
        await tester.pumpWidget(_table());

        final tokens = PlassTokens.light();

        expect(_rowDecoration(tester, 0).border!.bottom.color, tokens.border);
        expect(_rowDecoration(tester, 2).border!.top.color, tokens.divider);
      });

      testWidgets('the first row has no rule of its own', (WidgetTester tester) async {
        await tester.pumpWidget(_table());

        expect(_rowDecoration(tester, 1).border, isNull);
      });

      testWidgets('striped tints every other row and leaves the rest bare', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_table(striped: true));

        expect(_rowDecoration(tester, 1).color, isNull);
        expect(_rowDecoration(tester, 2).color, PlassTokens.light().stripe);
      });
    });

    group('rows', () {
      testWidgets('a press reports the row and where it was', (WidgetTester tester) async {
        final pressed = <String>[];
        await tester.pumpWidget(
          _table(onRowPressed: (_Build row, int index) => pressed.add('${row.id}@$index')),
        );

        await tester.tap(find.text('#411'));
        expect(pressed, <String>['#411@1']);
      });

      testWidgets('a row nothing listens to is not pressable', (WidgetTester tester) async {
        await tester.pumpWidget(_table());

        expect(find.byType(GestureDetector), findsNothing);
      });

      testWidgets('the pointer lights the row it is over, not the cell', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_table(hoverable: true));

        final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(pointer.removePointer);
        await pointer.addPointer(location: Offset.zero);
        await pointer.moveTo(tester.getCenter(find.text('main')));
        await tester.pump();

        // Hovered on the branch cell, lit on the row the build number is in.
        expect(
          _rowDecoration(tester, 1).color,
          PlassTokens.light().family(PlassColor.primary).soft,
        );
        expect(_rowDecoration(tester, 2).color, isNull);
      });

      testWidgets('keyboard focus rings the whole row', (WidgetTester tester) async {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
        await tester.pumpWidget(_table(onRowPressed: (_Build row, int index) {}));

        Focus.of(tester.element(find.text('#412'))).requestFocus();
        await tester.pumpAndSettle();

        final ring = _rowDecoration(tester, 1).border!;

        expect(ring.top.color, PlassTokens.light().family(PlassColor.primary).ring);
        expect(ring.bottom.color, PlassTokens.light().family(PlassColor.primary).ring);
      });

      testWidgets('the focused row answers Enter', (WidgetTester tester) async {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
        final pressed = <String>[];
        await tester.pumpWidget(
          _table(onRowPressed: (_Build row, int index) => pressed.add(row.id)),
        );

        Focus.of(tester.element(find.text('#412'))).requestFocus();
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(pressed, <String>['#412']);
      });
    });

    group('accessibility', () {
      testWidgets('is announced as a table', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_table());

        expect(tester.getSemantics(find.byType(Table)).role, SemanticsRole.table);

        handle.dispose();
      });

      testWidgets('a heading is announced as one', (WidgetTester tester) async {
        await tester.pumpWidget(_table());

        final heading = tester.widget<Semantics>(
          find.ancestor(of: find.text('Build'), matching: find.byType(Semantics)).first,
        );

        expect(heading.properties.role, SemanticsRole.columnHeader);
      });
    });
  });
}
