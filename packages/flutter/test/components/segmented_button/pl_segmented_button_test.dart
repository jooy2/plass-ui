import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

const List<PlSegment<String>> views = <PlSegment<String>>[
  PlSegment<String>(value: 'list', label: Text('List')),
  PlSegment<String>(value: 'board', label: Text('Board')),
  PlSegment<String>(value: 'calendar', label: Text('Calendar')),
];

void main() {
  group('PlSegmentedButton', () {
    group('rendering', () {
      testWidgets('draws every segment', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlSegmentedButton<String>(segments: views, value: 'list'), width: 480),
        );

        for (final label in <String>['List', 'Board', 'Calendar']) {
          expect(find.text(label), findsOneWidget);
        }
      });

      testWidgets('is one control-height row', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlSegmentedButton<String>(segments: views, value: 'list'), width: 480),
        );

        // A control height plus the groove's own inset, top and bottom.
        expect(tester.getSize(find.byType(PlSegmentedButton<String>)).height, 48);
      });

      testWidgets('a ghost set keeps no groove', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlSegmentedButton<String>(
              segments: views,
              value: 'list',
              variant: PlassVariant.ghost,
            ),
            width: 480,
          ),
        );

        expect(tester.getSize(find.byType(PlSegmentedButton<String>)).height, 40);
      });
    });

    group('the tile', () {
      testWidgets('is measured onto the chosen segment', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlSegmentedButton<String>(segments: views, value: 'board'), width: 480),
        );
        await tester.pumpAndSettle();

        final tile = tester.widgetList<AnimatedPositioned>(find.byType(AnimatedPositioned));

        expect(tile, hasLength(1));
        expect(tile.first.width, greaterThan(0));
      });

      testWidgets('draws no tile when nothing is chosen', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlSegmentedButton<String>(segments: views, value: null), width: 480),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AnimatedPositioned), findsNothing);
      });
    });

    group('choosing', () {
      testWidgets('reports the segment that was pressed', (WidgetTester tester) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            PlSegmentedButton<String>(
              segments: views,
              value: 'list',
              onChanged: (String next) => chosen = next,
            ),
            width: 480,
          ),
        );

        await tester.tap(find.text('Calendar'));
        expect(chosen, 'calendar');
      });

      testWidgets('does not fire for a disabled segment', (WidgetTester tester) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            PlSegmentedButton<String>(
              value: 'a',
              onChanged: (String next) => chosen = next,
              segments: const <PlSegment<String>>[
                PlSegment<String>(value: 'a', label: Text('A')),
                PlSegment<String>(value: 'b', label: Text('B'), disabled: true),
              ],
            ),
            width: 480,
          ),
        );

        await tester.tap(find.text('B'));
        expect(chosen, isNull);
      });

      testWidgets('does not fire while read-only', (WidgetTester tester) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            PlSegmentedButton<String>(
              segments: views,
              value: 'list',
              readOnly: true,
              onChanged: (String next) => chosen = next,
            ),
            width: 480,
          ),
        );

        await tester.tap(find.text('Board'));
        expect(chosen, isNull);
      });
    });

    group('the arrow keys', () {
      testWidgets('move the choice within the set, wrapping', (WidgetTester tester) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            PlSegmentedButton<String>(
              segments: views,
              value: 'list',
              autofocus: true,
              onChanged: (String next) => chosen = next,
            ),
            width: 480,
          ),
        );
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        expect(chosen, 'calendar');
      });
    });

    group('accessibility', () {
      testWidgets('a segment says it is one of a set', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlSegmentedButton<String>(segments: views, value: 'board', onChanged: (String _) {}),
            width: 480,
          ),
        );

        expect(
          tester.getSemantics(find.text('Board')),
          isSemantics(isInMutuallyExclusiveGroup: true, isChecked: true),
        );

        handle.dispose();
      });

      testWidgets('the set takes one focus stop', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlSegmentedButton<String>(segments: views, value: 'board', onChanged: (String _) {}),
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
