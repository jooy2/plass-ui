import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

void main() {
  group('PlAspectRatio', () {
    group('the proportion', () {
      testWidgets('holds a square by default', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAspectRatio(), width: 200));

        expect(tester.getSize(find.byType(PlAspectRatio)), const Size(200, 200));
      });

      testWidgets('takes the height from the width it was given', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAspectRatio(ratio: 16 / 9), width: 320));

        expect(tester.getSize(find.byType(PlAspectRatio)), const Size(320, 180));
      });

      testWidgets('reserves the space with nothing in it', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAspectRatio(ratio: 2), width: 200));

        expect(tester.getSize(find.byType(PlAspectRatio)), const Size(200, 100));
      });

      testWidgets('refuses a ratio that is not one', (WidgetTester tester) async {
        expect(() => PlAspectRatio(ratio: 0), throwsAssertionError);
      });
    });

    group('the content', () {
      testWidgets('lays the child out to the whole box', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlAspectRatio(ratio: 2, child: SizedBox.shrink()), width: 200),
        );

        expect(tester.getSize(find.byType(SizedBox).last), const Size(200, 100));
      });

      testWidgets('renders what it was given', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAspectRatio(child: Text('Held')), width: 200));

        expect(find.text('Held'), findsOneWidget);
      });

      testWidgets('clips whatever overflows the proportion', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAspectRatio(child: SizedBox.shrink()), width: 200));

        expect(
          find.descendant(of: find.byType(PlAspectRatio), matching: find.byType(ClipRect)),
          findsOneWidget,
        );
      });

      testWidgets('adds no clip at all with nothing to hold', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAspectRatio(), width: 200));

        expect(
          find.descendant(of: find.byType(PlAspectRatio), matching: find.byType(ClipRect)),
          findsNothing,
        );
      });
    });

    group('fit', () {
      testWidgets('lays the child out normally when it is not asked for', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlAspectRatio(child: SizedBox.shrink()), width: 200));

        expect(find.byType(FittedBox), findsNothing);
      });

      testWidgets('fits the child when it is', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlAspectRatio(fit: PlAspectFit.contain, child: SizedBox.shrink()), width: 200),
        );

        expect(tester.widget<FittedBox>(find.byType(FittedBox)).fit, BoxFit.contain);
      });

      testWidgets('lands each name on the BoxFit that means the same thing', (
        WidgetTester tester,
      ) async {
        const Map<PlAspectFit, BoxFit> expected = <PlAspectFit, BoxFit>{
          PlAspectFit.cover: BoxFit.cover,
          PlAspectFit.contain: BoxFit.contain,
          PlAspectFit.fill: BoxFit.fill,
          PlAspectFit.none: BoxFit.none,
        };

        for (final MapEntry<PlAspectFit, BoxFit> entry in expected.entries) {
          await tester.pumpWidget(
            host(PlAspectRatio(fit: entry.key, child: const SizedBox.shrink()), width: 200),
          );

          expect(tester.widget<FittedBox>(find.byType(FittedBox)).fit, entry.value);
        }
      });
    });

    group('rounded', () {
      testWidgets('cuts no corners unless it is asked to', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAspectRatio(child: SizedBox.shrink()), width: 200));

        expect(find.byType(ClipRRect), findsNothing);
      });

      testWidgets('takes the size step of the house ladder', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlAspectRatio(rounded: true, size: PlassSize.lg, child: SizedBox.shrink()),
            width: 200,
          ),
        );

        expect(
          tester.widget<ClipRRect>(find.byType(ClipRRect)).borderRadius,
          BorderRadius.circular(14),
        );
      });
    });
  });
}
