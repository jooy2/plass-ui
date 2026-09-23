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

      testWidgets('lets a title longer than the header wrap', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlAccordion<String>(
              items: <PlAccordionItem<String>>[
                PlAccordionItem<String>(
                  value: 'q',
                  title: Text('A question long enough to need a second line'),
                  child: Text('Body'),
                ),
              ],
              value: <String>{},
            ),
            width: 260,
          ),
        );

        final DefaultTextStyle wrapped = tester.widget<DefaultTextStyle>(
          find
              .ancestor(
                of: find.text('A question long enough to need a second line'),
                matching: find.byType(DefaultTextStyle),
              )
              .first,
        );

        expect(wrapped.maxLines, isNull);
        expect(wrapped.softWrap, isTrue);
        expect(wrapped.overflow, TextOverflow.clip);
      });

      testWidgets('holds the title to one line with truncate', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlAccordion<String>(
              items: <PlAccordionItem<String>>[
                PlAccordionItem<String>(
                  value: 'q',
                  title: Text('A question long enough to need a second line'),
                  truncate: true,
                  child: Text('Body'),
                ),
              ],
              value: <String>{},
            ),
            width: 260,
          ),
        );

        final DefaultTextStyle clipped = tester.widget<DefaultTextStyle>(
          find
              .ancestor(
                of: find.text('A question long enough to need a second line'),
                matching: find.byType(DefaultTextStyle),
              )
              .first,
        );

        expect(clipped.maxLines, 1);
        expect(clipped.softWrap, isFalse);
        expect(clipped.overflow, TextOverflow.ellipsis);
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

      testWidgets('keeps the body drawn while the panel closes', (WidgetTester tester) async {
        Widget accordion(Set<String> value) => host(
          PlAccordion<String>(items: sections, value: value, onChanged: (Set<String> _) {}),
          width: 400,
        );

        await tester.pumpWidget(accordion(const <String>{}));
        final closed = tester.getSize(find.byType(PlAccordion<String>)).height;

        await tester.pumpWidget(accordion(const <String>{'billing'}));
        await tester.pumpAndSettle();
        final open = tester.getSize(find.byType(PlAccordion<String>)).height;

        await tester.pumpWidget(accordion(const <String>{}));
        await tester.pump(PlassTokens.durationSlow ~/ 2);

        // Part way through, the body is still there, clipped by a panel that is
        // between its open and its closed height.
        final closing = tester.getSize(find.byType(PlAccordion<String>)).height;

        expect(find.text('Card on file'), findsOneWidget);
        expect(closing, lessThan(open));
        expect(closing, greaterThan(closed));

        await tester.pumpAndSettle();

        expect(find.text('Card on file'), findsNothing);
        expect(tester.getSize(find.byType(PlAccordion<String>)).height, closed);
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

      testWidgets('opens and closes two sections that share a value together', (
        WidgetTester tester,
      ) async {
        var open = <String>{};
        const shared = <PlAccordionItem<String>>[
          PlAccordionItem<String>(value: 'faq', title: Text('Delivery'), child: Text('Five days')),
          PlAccordionItem<String>(value: 'faq', title: Text('Returns'), child: Text('Thirty days')),
          PlAccordionItem<String>(value: 'other', title: Text('Duties'), child: Text('On arrival')),
        ];

        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => PlAccordion<String>(
                items: shared,
                value: open,
                onChanged: (Set<String> next) => setState(() => open = next),
              ),
            ),
            width: 400,
          ),
        );

        // Two siblings keyed by one value used to be a duplicate-key error
        // before anything was drawn.
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Returns'));
        await tester.pumpAndSettle();

        expect(open, <String>{'faq'});
        expect(find.text('Five days'), findsOneWidget);
        expect(find.text('Thirty days'), findsOneWidget);
        expect(find.text('On arrival'), findsNothing);

        await tester.tap(find.text('Delivery'));
        await tester.pumpAndSettle();

        expect(open, isEmpty);
        expect(find.text('Five days'), findsNothing);
        expect(find.text('Thirty days'), findsNothing);
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

      testWidgets('each header is inside a heading of level 3', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlAccordion<String>(
              items: sections,
              value: const <String>{},
              onChanged: (Set<String> _) {},
            ),
            width: 400,
          ),
        );

        for (final title in <String>['Billing', 'Members']) {
          final button = tester.getSemantics(find.text(title));
          var heading = button.parent;

          while (heading != null && heading.getSemanticsData().headingLevel == 0) {
            heading = heading.parent;
          }

          // The button keeps its own role: a node that is both is drawn as the
          // heading alone on the web.
          expect(button, isSemantics(isButton: true, isHeader: false, label: title));
          expect(heading, isNotNull);
          expect(heading, isSemantics(isHeader: true));
          expect(heading!.getSemanticsData().headingLevel, 3);
        }

        handle.dispose();
      });

      testWidgets('each header is inside a heading of the level headingLevel names', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();

        for (final level in <int>[2, 5]) {
          await tester.pumpWidget(
            host(
              PlAccordion<String>(
                items: sections,
                value: const <String>{},
                onChanged: (Set<String> _) {},
                headingLevel: level,
              ),
              width: 400,
            ),
          );

          for (final title in <String>['Billing', 'Members']) {
            var heading = tester.getSemantics(find.text(title)).parent;

            while (heading != null && heading.getSemanticsData().headingLevel == 0) {
              heading = heading.parent;
            }

            expect(heading?.getSemanticsData().headingLevel, level, reason: '$title at $level');
          }
        }

        handle.dispose();
      });

      test('refuses a level no heading has', () {
        expect(
          () => PlAccordion<String>(items: sections, value: const <String>{}, headingLevel: 7),
          throwsAssertionError,
        );
        expect(
          () => PlAccordion<String>(items: sections, value: const <String>{}, headingLevel: 0),
          throwsAssertionError,
        );
      });
    });
  });
}
