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
