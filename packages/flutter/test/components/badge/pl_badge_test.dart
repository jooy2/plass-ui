import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// Something to pin a badge to, at a size the tests can measure against.
const Widget anchor = SizedBox.square(dimension: 40);

void main() {
  group('PlBadge', () {
    group('content', () {
      testWidgets('draws the count it was given', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlBadge(count: 3, child: anchor)));

        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('caps a count and adds a plus', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlBadge(count: 128, child: anchor)));

        expect(find.text('99+'), findsOneWidget);
      });

      testWidgets('takes the cap it was given', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlBadge(count: 12, max: 9, child: anchor)));

        expect(find.text('9+'), findsOneWidget);
      });

      testWidgets('draws arbitrary content uncapped', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlBadge(content: Text('NEW'), child: anchor)));

        expect(find.text('NEW'), findsOneWidget);
      });
    });

    group('the dot', () {
      testWidgets('is what a badge with nothing to count draws', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlBadge(dot: true, child: anchor)));

        // A dot is the badge ladder with the digits taken out, so it goes
        // square: 10px at `md`.
        final marker = tester.getSize(find.byType(ClipRRect).first);

        expect(marker, const Size(10, 10));
      });
    });

    group('zero', () {
      testWidgets('is not news, so it is not shown', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlBadge(count: 0, child: anchor)));

        expect(find.text('0'), findsNothing);
      });

      testWidgets('is shown when it was asked for', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlBadge(count: 0, showZero: true, child: anchor)));

        expect(find.text('0'), findsOneWidget);
      });
    });

    group('invisible', () {
      testWidgets('keeps the anchor exactly where it was', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlBadge(count: 3, child: anchor)));
        final shown = tester.getSize(find.byType(PlBadge));

        await tester.pumpWidget(host(const PlBadge(count: 3, invisible: true, child: anchor)));

        expect(tester.getSize(find.byType(PlBadge)), shown);
      });

      testWidgets('says nothing while it is hidden', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const PlBadge(count: 3, invisible: true, label: '3 unread', child: anchor)),
        );

        expect(find.bySemanticsLabel('3 unread'), findsNothing);
        handle.dispose();
      });
    });

    group('anchoring', () {
      testWidgets('is measured by the anchor alone', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlBadge(count: 3, child: anchor)));

        expect(tester.getSize(find.byType(PlBadge)), const Size(40, 40));
      });

      testWidgets('lays out on its own with nothing to pin to', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlBadge(count: 3)));

        expect(tester.getSize(find.byType(PlBadge)).height, 18);
      });

      testWidgets('sits in the corner it was told to', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlBadge(count: 3, placement: PlassCorner.bottomStart, child: anchor)),
        );

        final marker = tester.getRect(find.text('3'));
        final box = tester.getRect(find.byType(PlBadge));

        expect(marker.center.dy, greaterThan(box.center.dy));
        expect(marker.center.dx, lessThan(box.center.dx));
      });

      testWidgets('tucks further in on a round anchor', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlBadge(count: 3, child: anchor)));
        final square = tester.getRect(find.text('3'));

        await tester.pumpWidget(
          host(const PlBadge(count: 3, overlap: PlBadgeOverlap.circle, child: anchor)),
        );
        final circle = tester.getRect(find.text('3'));

        expect(circle.right, lessThan(square.right));
      });
    });

    group('accessibility', () {
      testWidgets('reads the sentence rather than the number', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const PlBadge(count: 3, label: '3 unread notifications', child: anchor)),
        );

        expect(find.bySemanticsLabel('3 unread notifications'), findsOneWidget);
        expect(find.bySemanticsLabel('3'), findsNothing);
        handle.dispose();
      });

      testWidgets('a quiet corner is not a silent one', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const PlBadge(count: 3, dot: true, label: '3 unread', child: anchor)),
        );

        expect(find.bySemanticsLabel('3 unread'), findsOneWidget);
        handle.dispose();
      });
    });
  });
}
