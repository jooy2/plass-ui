import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

const List<PlAccordionItem<String>> sections = <PlAccordionItem<String>>[
  PlAccordionItem<String>(value: 'billing', title: Text('Billing'), child: Text('Card on file')),
  PlAccordionItem<String>(value: 'members', title: Text('Members'), child: Text('Three seats')),
];

void main() {
  group('PlAccordion', () {
    group('rendering', () {
      testWidgets('draws every header', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlAccordion<String>(items: sections, value: <String>{}), width: 400),
        );

        expect(find.text('Billing'), findsOneWidget);
        expect(find.text('Members'), findsOneWidget);
      });

      testWidgets('builds only the open panel', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlAccordion<String>(items: sections, value: <String>{'billing'}), width: 400),
        );

        expect(find.text('Card on file'), findsOneWidget);
        expect(find.text('Three seats'), findsNothing);
      });

      testWidgets('scores the sheet between sections by default', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlAccordion<String>(items: sections, value: <String>{}), width: 400),
        );

        final ruled = decorationsOf(tester, find.byType(PlAccordion<String>))
            .where((BoxDecoration one) => one.border is Border)
            .map((BoxDecoration one) => (one.border! as Border).top.color)
            .toList();

        expect(ruled, contains(PlassTokens.light().divider));
      });
    });

    group('folding', () {
      testWidgets('opens a section that was closed', (WidgetTester tester) async {
        Set<String>? next;
        await tester.pumpWidget(
          host(
            PlAccordion<String>(
              items: sections,
              value: const <String>{},
              onChanged: (Set<String> value) => next = value,
            ),
            width: 400,
          ),
        );

        await tester.tap(find.text('Billing'));
        expect(next, <String>{'billing'});
      });

      testWidgets('closes the last one as the next opens', (WidgetTester tester) async {
        Set<String>? next;
        await tester.pumpWidget(
          host(
            PlAccordion<String>(
              items: sections,
              value: const <String>{'billing'},
              onChanged: (Set<String> value) => next = value,
            ),
            width: 400,
          ),
        );

        await tester.tap(find.text('Members'));
        expect(next, <String>{'members'});
      });

      testWidgets('keeps both open when more than one is allowed', (WidgetTester tester) async {
        Set<String>? next;
        await tester.pumpWidget(
          host(
            PlAccordion<String>(
              items: sections,
              multiple: true,
              value: const <String>{'billing'},
              onChanged: (Set<String> value) => next = value,
            ),
            width: 400,
          ),
        );

        await tester.tap(find.text('Members'));
        expect(next, <String>{'billing', 'members'});
      });

      testWidgets('closes an open section when it is pressed again', (WidgetTester tester) async {
        Set<String>? next;
        await tester.pumpWidget(
          host(
            PlAccordion<String>(
              items: sections,
              value: const <String>{'billing'},
              onChanged: (Set<String> value) => next = value,
            ),
            width: 400,
          ),
        );

        await tester.tap(find.text('Billing'));
        expect(next, isEmpty);
      });

      testWidgets('does not fold a disabled section', (WidgetTester tester) async {
        Set<String>? next;
        await tester.pumpWidget(
          host(
            PlAccordion<String>(
              value: const <String>{},
              onChanged: (Set<String> value) => next = value,
              items: const <PlAccordionItem<String>>[
                PlAccordionItem<String>(value: 'a', title: Text('A'), disabled: true),
              ],
            ),
            width: 400,
          ),
        );

        await tester.tap(find.text('A'));
        expect(next, isNull);
      });
    });

    group('the action', () {
      testWidgets('is outside the part that folds', (WidgetTester tester) async {
        Set<String>? folded;
        var pressed = 0;

        await tester.pumpWidget(
          host(
            PlAccordion<String>(
              value: const <String>{},
              onChanged: (Set<String> value) => folded = value,
              items: <PlAccordionItem<String>>[
                PlAccordionItem<String>(
                  value: 'a',
                  title: const Text('A'),
                  action: PlButton(
                    size: PlassSize.xs,
                    onPressed: () => pressed += 1,
                    child: const Text('Go'),
                  ),
                ),
              ],
            ),
            width: 400,
          ),
        );

        await tester.tap(find.text('Go'));
        expect(pressed, 1);
        expect(folded, isNull);
      });
    });

    group('accessibility', () {
      testWidgets('a header says whether it is open', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlAccordion<String>(
              items: sections,
              value: const <String>{'billing'},
              onChanged: (Set<String> _) {},
            ),
            width: 400,
          ),
        );

        expect(
          tester.getSemantics(find.text('Billing')),
          isSemantics(isButton: true, hasExpandedState: true, isExpanded: true),
        );

        handle.dispose();
      });
    });
  });
}
