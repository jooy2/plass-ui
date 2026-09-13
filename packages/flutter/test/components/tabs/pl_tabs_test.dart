import 'package:flutter/gestures.dart';
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

      testWidgets('keep focus on the tab the value follows them to', (WidgetTester tester) async {
        String value = 'overview';
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => afterFocusStop(
                before,
                PlTabs<String>(
                  tabs: panes,
                  value: value,
                  onChanged: (String next) => setState(() => value = next),
                ),
              ),
            ),
            width: 480,
          ),
        );
        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();

        expect(value, 'settings');
        expect(before.hasFocus, isFalse);
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

      /// And two, which the same box has room for.
      const List<PlTab<String>> few = <PlTab<String>>[
        PlTab<String>(value: 'a', label: Text('A'), panel: Text('A')),
        PlTab<String>(value: 'b', label: Text('B'), panel: Text('B')),
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

      group('the wheel', () {
        /// The bar's own scroller, which is not the only one on screen once the
        /// bar is inside something that scrolls.
        Finder bar() {
          return find.descendant(
            of: find.byType(PlTabs<String>),
            matching: find.byType(SingleChildScrollView),
          );
        }

        /// A mouse parked on the bar, and one turn of its wheel.
        ///
        /// [at] is when the turn happened, which the bar reads: a wheel that
        /// arrives while the last one is still being acted on belongs to the
        /// same gesture.
        Future<void> spin(WidgetTester tester, Offset delta, {Duration at = Duration.zero}) async {
          final pointer = TestPointer(1, PointerDeviceKind.mouse);

          pointer.hover(tester.getCenter(bar()));
          await tester.sendEventToBinding(pointer.scroll(delta, timeStamp: at));
          await tester.pump();
        }

        /// A bar inside something that scrolls the other way, which is the only
        /// arrangement in which chaining is observable at all.
        Widget nested({
          required ScrollController outer,
          List<PlTab<String>> tabs = many,
          PlassOverscroll overscroll = PlassOverscroll.contain,
        }) {
          return host(
            SingleChildScrollView(
              controller: outer,
              child: Column(
                children: <Widget>[
                  PlTabs<String>(tabs: tabs, value: 'a', overscroll: overscroll),
                  const SizedBox(height: 600),
                ],
              ),
            ),
            width: 240,
            height: 200,
          );
        }

        testWidgets('moves the bar along on a vertical wheel', (WidgetTester tester) async {
          await tester.pumpWidget(host(const PlTabs<String>(tabs: many, value: 'a'), width: 240));
          await tester.pumpAndSettle();

          // A mouse has one wheel and it points down the page, which is the one
          // direction the bar does not run in.
          await spin(tester, const Offset(0, 100));

          expect(tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels, 100);
        });

        testWidgets('leaves the wheel alone when it is turned off', (WidgetTester tester) async {
          await tester.pumpWidget(
            host(const PlTabs<String>(tabs: many, value: 'a', wheel: false), width: 240),
          );
          await tester.pumpAndSettle();

          await spin(tester, const Offset(0, 100));

          expect(tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels, 0);
        });

        testWidgets('keeps the wheel once the bar has reached its end', (
          WidgetTester tester,
        ) async {
          final outer = ScrollController();
          addTearDown(outer.dispose);

          await tester.pumpWidget(nested(outer: outer));
          await tester.pumpAndSettle();

          await spin(tester, const Offset(0, 10000));
          await spin(tester, const Offset(0, 100), at: const Duration(seconds: 5));

          // A reader working along a long bar is not thrown down the page by the
          // notch that arrives after the last tab.
          expect(outer.offset, 0);
        });

        testWidgets('hands it back at the end when the page is left to chain', (
          WidgetTester tester,
        ) async {
          final outer = ScrollController();
          addTearDown(outer.dispose);

          await tester.pumpWidget(nested(outer: outer, overscroll: PlassOverscroll.auto));
          await tester.pumpAndSettle();

          await spin(tester, const Offset(0, 10000));

          // Five seconds later, which is the reader having stopped rather than
          // the same flick carrying on.
          await spin(tester, const Offset(0, 100), at: const Duration(seconds: 5));

          expect(outer.offset, 100);
        });

        testWidgets('leaves a bar whose tabs all fit alone', (WidgetTester tester) async {
          final outer = ScrollController();
          addTearDown(outer.dispose);

          await tester.pumpWidget(nested(outer: outer, tabs: few));
          await tester.pumpAndSettle();

          await spin(tester, const Offset(0, 100));

          // Not a scroller, so not a place on the page the reader cannot scroll
          // past. This is the whole of what keeps the containment honest.
          expect(outer.offset, 100);
        });
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
