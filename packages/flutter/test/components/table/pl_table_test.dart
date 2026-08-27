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
  bool stickyHeader = false,
  double? maxHeight,
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
      stickyHeader: stickyHeader,
      maxHeight: maxHeight,
      onRowPressed: onRowPressed,
    ),
    width: 420,
  );
}

/// Twenty-four rows, which is more than any cap in this suite.
final List<_Build> _many = <_Build>[
  for (var index = 0; index < 24; index += 1) _Build('#${400 + index}', 'topic/$index'),
];

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

    group('a capped height', () {
      testWidgets('is as tall as its rows until it is capped', (WidgetTester tester) async {
        await tester.pumpWidget(_table(rows: _many));

        final Size uncapped = tester.getSize(find.byType(PlTable<_Build>));

        await tester.pumpWidget(_table(rows: _many, maxHeight: 200));

        expect(uncapped.height, greaterThan(200));
        expect(tester.getSize(find.byType(PlTable<_Build>)).height, 200);
      });

      testWidgets('scrolls the rows inside the sheet', (WidgetTester tester) async {
        await tester.pumpWidget(_table(rows: _many, maxHeight: 200));

        final double before = tester.getTopLeft(find.text('#400')).dy;

        await tester.drag(find.text('#400'), const Offset(0, -120));
        await tester.pumpAndSettle();

        expect(tester.getTopLeft(find.text('#400')).dy, lessThan(before));
      });

      testWidgets('lays out where nothing bounds its height', (WidgetTester tester) async {
        // A table inside the page's own scroll view is handed an unbounded
        // height, and a column with a flexible child in one of those is not a
        // layout — it is an assertion.
        await tester.pumpWidget(
          host(
            SingleChildScrollView(
              child: PlTable<_Build>(rows: _many, columns: _columns()),
            ),
            width: 420,
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('#400'), findsOneWidget);
      });

      testWidgets('leaves the caption above what scrolls', (WidgetTester tester) async {
        await tester.pumpWidget(
          _table(rows: _many, maxHeight: 200, caption: const Text('Recent builds')),
        );

        final double caption = tester.getTopLeft(find.text('Recent builds')).dy;

        await tester.drag(find.text('#400'), const Offset(0, -120));
        await tester.pumpAndSettle();

        // A title that slid away would take the table's name with it.
        expect(tester.getTopLeft(find.text('Recent builds')).dy, caption);
      });
    });

    group('a pinned header', () {
      testWidgets('draws no band until it is asked for one', (WidgetTester tester) async {
        await tester.pumpWidget(_table(rows: _many, maxHeight: 200));
        await tester.pumpAndSettle();

        expect(find.text('Build'), findsOneWidget);
      });

      testWidgets('repeats the header over the top of the scroll', (WidgetTester tester) async {
        await tester.pumpWidget(_table(rows: _many, maxHeight: 200, stickyHeader: true));
        await tester.pumpAndSettle();

        // The real header inside the grid, and the band laid over it.
        expect(find.text('Build'), findsNWidgets(2));
      });

      testWidgets('gives the band the widths the grid laid out', (WidgetTester tester) async {
        await tester.pumpWidget(_table(rows: _many, maxHeight: 200, stickyHeader: true));
        await tester.pumpAndSettle();

        final List<Element> headers = find.text('Build').evaluate().toList();

        // One grid still decides every column; the band only repeats what it
        // decided, so the two cannot disagree about where a column starts.
        expect(
          tester.getTopLeft(find.byElementPredicate((Element e) => e == headers.first)).dx,
          tester.getTopLeft(find.byElementPredicate((Element e) => e == headers.last)).dx,
        );
      });

      testWidgets('stays put while the rows go under it', (WidgetTester tester) async {
        await tester.pumpWidget(_table(rows: _many, maxHeight: 200, stickyHeader: true));
        await tester.pumpAndSettle();

        final double band = tester.getTopLeft(find.byType(IntrinsicHeight)).dy;
        final double row = tester.getTopLeft(find.text('#400')).dy;

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -120));
        await tester.pumpAndSettle();

        expect(tester.getTopLeft(find.byType(IntrinsicHeight)).dy, band);
        expect(tester.getTopLeft(find.text('#400')).dy, lessThan(row));
      });

      testWidgets('is opaque, because rows pass underneath it', (WidgetTester tester) async {
        await tester.pumpWidget(_table(rows: _many, maxHeight: 200, stickyHeader: true));
        await tester.pumpAndSettle();

        final BoxDecoration band = decorationWhere(
          tester,
          find
              .ancestor(of: find.byType(IntrinsicHeight), matching: find.byType(DecoratedBox))
              .first,
          (BoxDecoration decoration) => decoration.color != null,
        );

        expect(band.color!.a, 1.0);
      });

      testWidgets('names every column once, not twice', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_table(rows: _many, maxHeight: 200, stickyHeader: true));
        await tester.pumpAndSettle();

        // Two of them are drawn and one of them is read: the band is a copy, and
        // a copy that spoke would name every column twice.
        expect(find.bySemanticsLabel('Build'), findsOneWidget);

        handle.dispose();
      });
    });
  });
}
