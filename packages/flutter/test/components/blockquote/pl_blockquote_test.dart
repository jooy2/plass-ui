import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

void main() {
  group('PlBlockquote', () {
    group('rendering', () {
      testWidgets('renders what was said', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlBlockquote(child: Text('Less, but better')), width: 400),
        );

        expect(find.text('Less, but better'), findsOneWidget);
      });

      testWidgets('sets the quote above body copy', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlBlockquote(child: Text('Less, but better')), width: 400),
        );

        expect(styleOf(tester, 'Less, but better').fontSize, 15);
      });

      testWidgets('draws the house mark by default', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlBlockquote(child: Text('Less')), width: 400));

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('takes the mark away when asked', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlBlockquote(showIcon: false, child: Text('Less')), width: 400),
        );

        expect(find.byType(CustomPaint), findsNothing);
      });
    });

    group('attribution', () {
      testWidgets('sets an author after an em dash', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlBlockquote(author: Text('Dieter Rams'), child: Text('Less')), width: 400),
        );

        expect(find.text('Dieter Rams'), findsOneWidget);
        expect(find.text('— '), findsOneWidget);
      });

      testWidgets('sets a source without one', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlBlockquote(source: Text('Ten Principles'), child: Text('Less')), width: 400),
        );

        expect(find.text('Ten Principles'), findsOneWidget);
        expect(find.text('— '), findsNothing);
      });

      testWidgets('has no attribution row at all without either', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlBlockquote(child: Text('Less')), width: 400));

        expect(find.byType(Wrap), findsNothing);
      });
    });

    group('variant', () {
      testWidgets('is ghost by default — a rule in the margin and nothing else', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlBlockquote(child: Text('Less')), width: 400));

        final surfaces = decorationsOf(tester, find.byType(PlBlockquote));

        expect(surfaces.every((BoxDecoration decoration) => decoration.border == null), isTrue);
      });

      testWidgets('a glass quote gets the sheet, undyed', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlBlockquote(variant: PlassVariant.glass, child: Text('Less')), width: 400),
        );

        final tokens = PlassTokens.light();
        final sheet = decorationWhere(
          tester,
          find.byType(PlBlockquote),
          (BoxDecoration decoration) => decoration.border != null,
        );

        expect(sheet.color, tokens.glass);
      });
    });

    group('the rule', () {
      testWidgets('wears the family and is 2px at every size', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlBlockquote(color: PlassColor.danger, size: PlassSize.xl, child: Text('Less')),
            width: 400,
          ),
        );

        final rule = tester.getSize(
          find.descendant(of: find.byType(PositionedDirectional), matching: find.byType(SizedBox)),
        );

        expect(rule.width, 2);
      });
    });
  });
}
