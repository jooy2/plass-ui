import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

const List<PlTimelineItem> steps = <PlTimelineItem>[
  PlTimelineItem(title: Text('Ordered'), meta: Text('Mon')),
  PlTimelineItem(title: Text('Shipped'), meta: Text('Tue')),
  PlTimelineItem(title: Text('Delivered')),
];

/// The bullets, in order, as the decoration each one was painted with.
List<BoxDecoration> bulletsOf(WidgetTester tester) {
  return tester
      .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
      .map((AnimatedContainer container) => container.decoration)
      .whereType<BoxDecoration>()
      .where((BoxDecoration decoration) => decoration.shape == BoxShape.circle)
      .toList();
}

void main() {
  group('PlTimeline', () {
    group('rendering', () {
      testWidgets('draws every step in order', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlTimeline(items: steps), width: 400));

        expect(
          tester.getRect(find.text('Shipped')).top,
          greaterThan(tester.getRect(find.text('Ordered')).top),
        );
      });

      testWidgets('sets the meta beside the title, muted', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlTimeline(items: steps), width: 400));

        expect(styleOf(tester, 'Mon').color, PlassTokens.light().mutedFg);
      });
    });

    group('active', () {
      testWidgets('makes everything before it complete and everything after upcoming', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlTimeline(items: steps, active: 1), width: 400));

        final bullets = bulletsOf(tester);

        // complete: the gradient and nothing else.
        expect(bullets[0].gradient, isNotNull);
        expect(bullets[0].boxShadow, isNull);
        // current: the gradient with a halo round it.
        expect(bullets[1].gradient, isNotNull);
        expect(bullets[1].boxShadow, isNotNull);
        // upcoming: a hairline ring on the page's own surface.
        expect(bullets[2].gradient, isNull);
        expect(bullets[2].border, isNotNull);
      });

      testWidgets('leaves every step upcoming when it is not given', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlTimeline(items: steps), width: 400));

        expect(bulletsOf(tester).every((BoxDecoration one) => one.gradient == null), isTrue);
      });

      testWidgets('marks the whole sequence done at the step count', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlTimeline(items: steps, active: 3), width: 400));

        expect(bulletsOf(tester).every((BoxDecoration one) => one.gradient != null), isTrue);
      });

      testWidgets('a step can override what active computed', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlTimeline(
              active: 2,
              items: <PlTimelineItem>[
                PlTimelineItem(title: Text('One')),
                PlTimelineItem(title: Text('Two'), status: PlTimelineStatus.upcoming),
                PlTimelineItem(title: Text('Three')),
              ],
            ),
            width: 400,
          ),
        );

        expect(bulletsOf(tester)[1].gradient, isNull);
      });
    });

    group('the current title', () {
      testWidgets('wears the family', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlTimeline(items: steps, active: 1), width: 400));

        expect(
          styleOf(tester, 'Shipped').color,
          PlassTokens.light().family(PlassColor.primary).accent,
        );
      });
    });

    group('connectors', () {
      testWidgets('does not draw one after the last step', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlTimeline(items: steps), width: 400));

        expect(find.byType(CustomPaint), findsNWidgets(2));
      });

      testWidgets('leaves the gap open when asked', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlTimeline(
              items: <PlTimelineItem>[
                PlTimelineItem(title: Text('One'), connector: PlTimelineConnector.none),
                PlTimelineItem(title: Text('Two')),
              ],
            ),
            width: 400,
          ),
        );

        expect(find.byType(CustomPaint), findsNothing);
      });
    });

    group('orientation', () {
      testWidgets('runs across when asked', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlTimeline(items: steps, orientation: PlassOrientation.horizontal),
            width: 600,
          ),
        );

        expect(
          tester.getRect(find.text('Shipped')).left,
          greaterThan(tester.getRect(find.text('Ordered')).left),
        );
      });
    });
  });
}
