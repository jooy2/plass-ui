import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

const List<PlTab<String>> panes = <PlTab<String>>[
  PlTab<String>(value: 'overview', label: Text('Overview'), panel: Text('The overview')),
  PlTab<String>(value: 'activity', label: Text('Activity'), panel: Text('The activity')),
  PlTab<String>(value: 'settings', label: Text('Settings'), panel: Text('The settings')),
];

void main() {
  group('PlTabs', () {
    group('rendering', () {
      testWidgets('draws every tab', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlTabs<String>(tabs: panes, value: 'overview'), width: 480),
        );

        for (final label in <String>['Overview', 'Activity', 'Settings']) {
          expect(find.text(label), findsOneWidget);
        }
      });

      testWidgets('builds only the chosen panel', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlTabs<String>(tabs: panes, value: 'activity'), width: 480),
        );

        expect(find.text('The activity'), findsOneWidget);
        expect(find.text('The overview'), findsNothing);
      });

      testWidgets('rules the bar on one edge when it is glass', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlTabs<String>(tabs: panes, value: 'overview'), width: 480),
        );

        final ruled = decorationsOf(tester, find.byType(PlTabs<String>))
            .where((BoxDecoration one) => one.border is Border)
            .map((BoxDecoration one) => (one.border! as Border).bottom.color)
            .toList();

        expect(ruled, contains(PlassTokens.light().border));
      });

      testWidgets('takes the rule away when it is ghost', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlTabs<String>(tabs: panes, value: 'overview', variant: PlassVariant.ghost),
            width: 480,
          ),
        );

        final ruled = decorationsOf(
          tester,
          find.byType(PlTabs<String>),
        ).where((BoxDecoration one) => one.border != null).toList();

        expect(ruled, isEmpty);
      });
    });

    group('the indicator', () {
      testWidgets('is measured onto the chosen tab', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlTabs<String>(tabs: panes, value: 'activity'), width: 480),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AnimatedPositioned), findsOneWidget);
      });

      testWidgets('is nowhere when no tab is chosen', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlTabs<String>(tabs: panes, value: null), width: 480));
        await tester.pumpAndSettle();

        expect(find.byType(AnimatedPositioned), findsNothing);
      });
    });

    group('choosing', () {
      testWidgets('reports the tab that was pressed', (WidgetTester tester) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            PlTabs<String>(
              tabs: panes,
              value: 'overview',
              onChanged: (String next) => chosen = next,
            ),
            width: 480,
          ),
        );

        await tester.tap(find.text('Settings'));
        expect(chosen, 'settings');
      });

      testWidgets('the arrow keys move within the bar, wrapping', (WidgetTester tester) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            PlTabs<String>(
              tabs: panes,
              value: 'overview',
              autofocus: true,
              onChanged: (String next) => chosen = next,
            ),
            width: 480,
          ),
        );
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        expect(chosen, 'settings');
      });
    });

    group('a bar with more tabs than room', () {
      /// Eight tabs, so a narrow box genuinely runs out of room for them.
      const List<PlTab<String>> many = <PlTab<String>>[
        PlTab<String>(value: 'a', label: Text('Overview'), panel: Text('A')),
        PlTab<String>(value: 'b', label: Text('Activity'), panel: Text('B')),
        PlTab<String>(value: 'c', label: Text('Settings'), panel: Text('C')),
        PlTab<String>(value: 'd', label: Text('Members'), panel: Text('D')),
        PlTab<String>(value: 'e', label: Text('Billing'), panel: Text('E')),
        PlTab<String>(value: 'f', label: Text('Integrations'), panel: Text('F')),
        PlTab<String>(value: 'g', label: Text('Notifications'), panel: Text('G')),
        PlTab<String>(value: 'h', label: Text('Danger zone'), panel: Text('H')),
      ];

      testWidgets('scrolls rather than overflowing its box', (WidgetTester tester) async {
        // A tab bar on two lines has stopped being a bar and the indicator has
        // nowhere sensible to sit, so the strip scrolls. What it used to do was
        // neither: eight tabs in a 240px box was a `RenderFlex overflowed`.
        await tester.pumpWidget(host(const PlTabs<String>(tabs: many, value: 'a'), width: 240));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        final ScrollableState scroller = tester.state(find.byType(Scrollable));

        expect(scroller.position.maxScrollExtent, greaterThan(0));
        expect(tester.getSize(find.byType(SingleChildScrollView)).width, 240);
      });

      testWidgets('fades the end that still has tabs behind it', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlTabs<String>(tabs: many, value: 'a'), width: 240));
        await tester.pumpAndSettle();

        // The mask is the signal. A scroll bar under a row of labels is
        // furniture on Windows and invisible on a Mac, and the moment a reader
        // wants to know whether there is more is the moment nothing is moving.
        expect(find.byType(ShaderMask), findsOneWidget);
      });

      testWidgets('says nothing at all while every tab fits', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlTabs<String>(tabs: panes, value: 'overview'), width: 640),
        );
        await tester.pumpAndSettle();

        final ScrollableState scroller = tester.state(find.byType(Scrollable));

        // A bar with a faded end that goes nowhere is a bar that lies — and a
        // bar that fits pays for no compositing layer either.
        expect(scroller.position.maxScrollExtent, 0);
        expect(find.byType(ShaderMask), findsNothing);
      });

      testWidgets('leaves a vertical bar alone, which runs down the side', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlTabs<String>(
              tabs: panes,
              value: 'overview',
              orientation: PlassResponsive<PlassOrientation>(PlassOrientation.vertical),
            ),
            width: 480,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SingleChildScrollView), findsNothing);
      });
    });

    testWidgets('turns at the rung it was named', (WidgetTester tester) async {
      Future<void> at(double width) async {
        await tester.pumpWidget(
          host(
            Builder(
              builder: (BuildContext context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(size: Size(width, 800)),
                child: const PlTabs<String>(
                  tabs: panes,
                  value: 'overview',
                  orientation: PlassResponsive<PlassOrientation>(
                    PlassOrientation.vertical,
                    md: PlassOrientation.horizontal,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      /// Which way the bar and its panel are laid out against each other — the
      /// one thing the orientation decides that is visible from outside.
      Axis axis() {
        return tester
            .widget<Flex>(
              find.descendant(of: find.byType(PlTabs<String>), matching: find.byType(Flex)).first,
            )
            .direction;
      }

      // A bar that is a column on a phone and a row on a laptop, from one prop.
      // The orientation is the *window's* answer rather than this bar's own box,
      // so two of them side by side agree about which rung they are on.
      //
      // A vertical bar puts its tabs beside the panel, so the outer flex runs
      // the other way from the bar itself.
      await at(500);
      expect(axis(), Axis.horizontal);

      await at(900);
      expect(axis(), Axis.vertical);
    });

    group('accessibility', () {
      testWidgets('a tab says it is one of a set', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlTabs<String>(tabs: panes, value: 'activity', onChanged: (String _) {}),
            width: 480,
          ),
        );

        expect(
          tester.getSemantics(find.text('Activity')),
          isSemantics(isInMutuallyExclusiveGroup: true, isSelected: true),
        );

        handle.dispose();
      });

      testWidgets('the bar takes one focus stop', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlTabs<String>(tabs: panes, value: 'activity', onChanged: (String _) {}),
            width: 480,
          ),
        );

        final inOrder = tester
            .widgetList<ExcludeFocus>(find.byType(ExcludeFocus))
            .where((ExcludeFocus excluded) => !excluded.excluding)
            .length;

        expect(inOrder, 1);
      });
    });
  });
}
