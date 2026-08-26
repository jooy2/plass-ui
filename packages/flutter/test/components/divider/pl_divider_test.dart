import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

void main() {
  group('PlDivider', () {
    group('rendering', () {
      testWidgets('is a hairline the width of its container', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlDivider(), width: 200));

        expect(tester.getSize(find.byType(PlDivider)), const Size(200, 1));
      });

      testWidgets('a vertical one is a hairline the height of its container', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlDivider(orientation: PlassOrientation.vertical), height: 120),
        );

        expect(tester.getSize(find.byType(PlDivider)), const Size(1, 120));
      });

      testWidgets('takes the thickness asked for', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlDivider(thickness: 3), width: 200));

        expect(tester.getSize(find.byType(PlDivider)).height, 3);
      });

      testWidgets('runs only as far as length says, tight parent or not', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlDivider(length: 80), width: 200));

        expect(tester.getSize(find.byType(DecoratedBox)).width, 80);
      });
    });

    group('colour', () {
      testWidgets('is the neutral hairline with no family asked for', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlDivider(), width: 200));

        expect(
          decorationWhere(
            tester,
            find.byType(PlDivider),
            (BoxDecoration decoration) => decoration.color != null,
          ).color,
          PlassTokens.light().border,
        );
      });

      testWidgets('tints the rule when a family is asked for', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlDivider(color: PlassColor.danger), width: 200));

        expect(
          decorationWhere(
            tester,
            find.byType(PlDivider),
            (BoxDecoration decoration) => decoration.color != null,
          ).color,
          PlassTokens.light().family(PlassColor.danger).line,
        );
      });
    });

    group('label', () {
      testWidgets('breaks the line around a label', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlDivider(child: Text('OR')), width: 200));

        expect(find.text('OR'), findsOneWidget);
      });

      testWidgets('leaves a short stub on the near side when set to start', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlDivider(textAlign: PlassAlign.start, child: Text('OR')), width: 300),
        );

        final label = tester.getRect(find.text('OR'));
        final divider = tester.getRect(find.byType(PlDivider));

        // The stub is 16 plus the gap; what matters is that the label is near
        // the leading edge rather than in the middle.
        expect(label.left - divider.left, lessThan(60));
      });

      testWidgets('centres the label by default', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlDivider(child: Text('OR')), width: 300));

        final label = tester.getRect(find.text('OR'));
        final divider = tester.getRect(find.byType(PlDivider));

        expect(label.center.dx, closeTo(divider.center.dx, 1));
      });
    });

    group('accessibility', () {
      testWidgets('says nothing unless it was given a name', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlDivider(semanticLabel: 'Or'), width: 200));

        expect(find.bySemanticsLabel('Or'), findsOneWidget);
        handle.dispose();
      });
    });
  });
}
