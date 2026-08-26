import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/icons.dart';

import '../../support/host.dart';

List<PlBreadcrumbItem> trail(int steps) {
  return <PlBreadcrumbItem>[
    for (var index = 0; index < steps; index += 1)
      PlBreadcrumbItem(label: Text('Step $index'), onPressed: () {}),
  ];
}

void main() {
  group('PlBreadcrumb', () {
    group('rendering', () {
      testWidgets('draws every step', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlBreadcrumb(items: trail(3)), width: 480));

        for (var index = 0; index < 3; index += 1) {
          expect(find.text('Step $index'), findsOneWidget);
        }
      });

      testWidgets('draws a mark between two steps and not before the first', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(PlBreadcrumb(items: trail(3)), width: 480));

        expect(find.byType(PlassGlyph), findsNWidgets(2));
      });

      testWidgets('takes a mark of its own', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlBreadcrumb(items: trail(3), separator: PlBreadcrumbSeparator.slash), width: 480),
        );

        expect(find.text('/'), findsNWidgets(2));
      });
    });

    group('the current step', () {
      testWidgets('is the last one, and stops answering', (WidgetTester tester) async {
        var pressed = 0;
        await tester.pumpWidget(
          host(
            PlBreadcrumb(
              items: <PlBreadcrumbItem>[
                PlBreadcrumbItem(label: const Text('Home'), onPressed: () {}),
                PlBreadcrumbItem(label: const Text('Billing'), onPressed: () => pressed += 1),
              ],
            ),
            width: 480,
          ),
        );

        await tester.tap(find.text('Billing'));
        expect(pressed, 0);
      });

      testWidgets('moves when a step claims it', (WidgetTester tester) async {
        var pressed = 0;
        await tester.pumpWidget(
          host(
            PlBreadcrumb(
              items: <PlBreadcrumbItem>[
                const PlBreadcrumbItem(label: Text('Home'), current: true),
                PlBreadcrumbItem(label: const Text('Billing'), onPressed: () => pressed += 1),
              ],
            ),
            width: 480,
          ),
        );

        await tester.tap(find.text('Billing'));
        expect(pressed, 1);
      });

      testWidgets('is announced as the place the reader is', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlBreadcrumb(
              items: <PlBreadcrumbItem>[
                PlBreadcrumbItem(label: const Text('Home'), onPressed: () {}),
                const PlBreadcrumbItem(label: Text('Billing')),
              ],
            ),
            width: 480,
          ),
        );

        expect(tester.getSemantics(find.text('Billing')), isSemantics(isHeader: true));
        handle.dispose();
      });
    });

    group('folding', () {
      testWidgets('folds the middle away past maxItems', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlBreadcrumb(items: trail(6), maxItems: 3), width: 640));

        expect(find.text('Step 0'), findsOneWidget);
        expect(find.text('Step 5'), findsOneWidget);
        expect(find.text('Step 2'), findsNothing);
      });

      testWidgets('does not fold when the fold would remove one step', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlBreadcrumb(items: trail(3), maxItems: 2), width: 640));

        expect(find.text('Step 1'), findsOneWidget);
      });

      testWidgets('unfolds in place when the mark is pressed', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(PlBreadcrumb(items: trail(6), maxItems: 3), width: 640));

        await tester.tap(find.bySemanticsLabel('Show the hidden steps'));
        await tester.pump();

        expect(find.text('Step 2'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('leaves the fold as a plain mark when it is not expandable', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(PlBreadcrumb(items: trail(6), maxItems: 3, expandable: false), width: 640),
        );

        expect(find.bySemanticsLabel('Show the hidden steps'), findsNothing);
        handle.dispose();
      });
    });

    group('accessibility', () {
      testWidgets('names the trail', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(PlBreadcrumb(items: trail(2)), width: 480));

        expect(find.bySemanticsLabel('Breadcrumb'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('a step that goes somewhere is a link', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(PlBreadcrumb(items: trail(2)), width: 480));

        expect(tester.getSemantics(find.text('Step 0')), isSemantics(isLink: true));
        handle.dispose();
      });
    });
  });
}
