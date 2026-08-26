import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// The page numbers the row is showing, in order.
List<String> pagesOf(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.descendant(of: find.byType(PlPagination), matching: find.byType(Text)))
      .map((Text text) => text.data!)
      .toList();
}

void main() {
  group('PlPagination', () {
    group('the window', () {
      testWidgets('shows every page while they all fit', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlPagination(count: 5, page: 1), width: 640));

        expect(pagesOf(tester), <String>['1', '2', '3', '4', '5']);
      });

      testWidgets('folds the middle away and keeps the row one length', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlPagination(count: 20, page: 1), width: 640));
        final atStart = pagesOf(tester);

        await tester.pumpWidget(host(const PlPagination(count: 20, page: 10), width: 640));
        final inMiddle = pagesOf(tester);

        expect(atStart, <String>['1', '2', '3', '4', '5', '20']);
        expect(inMiddle, <String>['1', '9', '10', '11', '20']);
      });

      testWidgets('fills a one-page gap with the page rather than an ellipsis', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlPagination(count: 7, page: 4), width: 640));

        // `1 2 3 4 5 6 7` — nothing is hidden, so nothing is folded.
        expect(pagesOf(tester), <String>['1', '2', '3', '4', '5', '6', '7']);
      });

      testWidgets('draws nothing at all for one page', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlPagination(count: 1, page: 1), width: 640));

        expect(find.byType(PlButton), findsNothing);
      });
    });

    group('the steppers', () {
      testWidgets('shows the arrows and not the edges by default', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlPagination(count: 9, page: 5), width: 640));

        expect(find.bySemanticsLabel('Previous page'), findsOneWidget);
        expect(find.bySemanticsLabel('First page'), findsNothing);
        handle.dispose();
      });

      testWidgets('shows the edges when asked', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const PlPagination(count: 9, page: 5, showEdges: true), width: 640),
        );

        expect(find.bySemanticsLabel('First page'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('goes back and forward a page', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        int? went;
        await tester.pumpWidget(
          host(
            PlPagination(count: 9, page: 5, onPageChanged: (int next) => went = next),
            width: 640,
          ),
        );

        await tester.tap(find.bySemanticsLabel('Next page'));
        expect(went, 6);
        handle.dispose();
      });

      testWidgets('is inert at the end of the row', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        int? went;
        await tester.pumpWidget(
          host(
            PlPagination(count: 9, page: 9, onPageChanged: (int next) => went = next),
            width: 640,
          ),
        );

        await tester.tap(find.bySemanticsLabel('Next page'));
        expect(went, isNull);
        handle.dispose();
      });
    });

    group('choosing a page', () {
      testWidgets('reports the number that was pressed', (WidgetTester tester) async {
        int? went;
        await tester.pumpWidget(
          host(
            PlPagination(count: 9, page: 1, onPageChanged: (int next) => went = next),
            width: 640,
          ),
        );

        await tester.tap(find.text('3'));
        expect(went, 3);
      });

      testWidgets('does not report the page it is already on', (WidgetTester tester) async {
        int? went;
        await tester.pumpWidget(
          host(
            PlPagination(count: 9, page: 3, onPageChanged: (int next) => went = next),
            width: 640,
          ),
        );

        await tester.tap(find.text('3'));
        expect(went, isNull);
      });
    });

    group('accessibility', () {
      testWidgets('names the row and every page in it', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlPagination(count: 9, page: 3), width: 640));

        expect(find.bySemanticsLabel('Pagination'), findsOneWidget);
        expect(find.bySemanticsLabel('Page 3'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('leaves the ellipsis out of what is read', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlPagination(count: 20, page: 10), width: 640));

        expect(find.bySemanticsLabel('…'), findsNothing);
        handle.dispose();
      });
    });
  });
}
