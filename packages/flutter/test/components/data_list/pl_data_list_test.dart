import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(host(child, width: 400));
  await tester.pumpAndSettle();
}

void main() {
  group('PlDataList', () {
    group('the rows', () {
      testWidgets('draws each label with its value', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlDataList(
            children: <Widget>[
              PlDataListItem(label: Text('Owner'), value: Text('Ada Lovelace')),
              PlDataListItem(label: Text('Plan'), value: Text('Team')),
            ],
          ),
        );

        expect(find.text('Owner'), findsOneWidget);
        expect(find.text('Ada Lovelace'), findsOneWidget);
        expect(find.text('Plan'), findsOneWidget);
        expect(find.text('Team'), findsOneWidget);
      });

      testWidgets('takes a widget for the value', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlDataList(
            children: <Widget>[
              PlDataListItem(
                label: Text('Status'),
                value: PlChip(child: Text('Active')),
              ),
            ],
          ),
        );

        expect(find.byType(PlChip), findsOneWidget);
      });
    });

    group('orientation', () {
      testWidgets('puts the label in a column of its own by default', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlDataList(
            children: <Widget>[PlDataListItem(label: Text('Owner'), value: Text('Ada'))],
          ),
        );

        // A fixed label column rather than the longest label, so two panels on
        // one screen line up with each other.
        expect(
          tester.getTopLeft(find.text('Ada')).dx - tester.getTopLeft(find.text('Owner')).dx,
          160 + 16,
        );
      });

      testWidgets('takes a width for that column', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlDataList(
            labelWidth: 80,
            children: <Widget>[PlDataListItem(label: Text('Owner'), value: Text('Ada'))],
          ),
        );

        expect(
          tester.getTopLeft(find.text('Ada')).dx - tester.getTopLeft(find.text('Owner')).dx,
          80 + 16,
        );
      });

      testWidgets('stacks them when it was told to', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlDataList(
            orientation: PlassOrientation.vertical,
            children: <Widget>[PlDataListItem(label: Text('Owner'), value: Text('Ada'))],
          ),
        );

        expect(tester.getTopLeft(find.text('Ada')).dx, tester.getTopLeft(find.text('Owner')).dx);
        expect(
          tester.getTopLeft(find.text('Ada')).dy,
          greaterThan(tester.getTopLeft(find.text('Owner')).dy),
        );
      });
    });

    group('divider', () {
      testWidgets('draws none unless it was asked for one', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlDataList(
            children: <Widget>[
              PlDataListItem(label: Text('Owner'), value: Text('Ada')),
              PlDataListItem(label: Text('Plan'), value: Text('Team')),
            ],
          ),
        );

        expect(find.byType(ColoredBox), findsNothing);
      });

      testWidgets('rules between the rows and not at either end', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlDataList(
            divider: true,
            children: <Widget>[
              PlDataListItem(label: Text('Owner'), value: Text('Ada')),
              PlDataListItem(label: Text('Plan'), value: Text('Team')),
              PlDataListItem(label: Text('Region'), value: Text('eu-west')),
            ],
          ),
        );

        // Three rows, two lines. A line above the first or below the last would
        // be a box drawn around a list that has no box.
        expect(find.byType(ColoredBox), findsNWidgets(2));
      });
    });

    group('semantics', () {
      testWidgets('announces a label and its value as one pair', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(
          tester,
          const PlDataList(
            children: <Widget>[PlDataListItem(label: Text('Owner'), value: Text('Ada Lovelace'))],
          ),
        );

        // A label read on its own is a word, and a value read on its own is a
        // fact nobody can place.
        expect(find.bySemanticsLabel('Owner\nAda Lovelace'), findsOneWidget);

        handle.dispose();
      });
    });
  });
}
