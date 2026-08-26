import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// Something in each pane to measure.
PlPane pane(String name, {PlPaneSize? defaultSize, PlPaneSize? minSize, PlPaneSize? maxSize}) {
  return PlPane(
    defaultSize: defaultSize,
    minSize: minSize,
    maxSize: maxSize,
    child: SizedBox.expand(key: ValueKey<String>(name)),
  );
}

double widthOf(WidgetTester tester, String name) =>
    tester.getSize(find.byKey(ValueKey<String>(name))).width;

double heightOf(WidgetTester tester, String name) =>
    tester.getSize(find.byKey(ValueKey<String>(name))).height;

/// The handle between the panes, of which every test here has one or two.
Finder handles() => find.byType(GestureDetector);

void main() {
  group('PlPanes', () {
    group('the split', () {
      testWidgets('puts a handle between every pair of panes and none at the ends', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(PlPanes(panes: <PlPane>[pane('a'), pane('b'), pane('c')]), width: 408, height: 200),
        );

        expect(handles(), findsNWidgets(2));
      });

      testWidgets('needs no handle at all for one pane', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlPanes(panes: <PlPane>[pane('a')]), width: 400, height: 200));

        expect(handles(), findsNothing);
      });

      testWidgets('splits what is left over evenly between the panes that named nothing', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(PlPanes(panes: <PlPane>[pane('a'), pane('b')]), width: 408, height: 200),
        );

        // 408 less the 8px handle is 400, halved.
        expect(widthOf(tester, 'a'), 200);
        expect(widthOf(tester, 'b'), 200);
      });

      testWidgets('turns a length into a share of the space', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlPanes(
              panes: <PlPane>[
                pane('a', defaultSize: const PlPaneSize.pixels(100)),
                pane('b'),
              ],
            ),
            width: 408,
            height: 200,
          ),
        );

        expect(widthOf(tester, 'a'), 100);
        expect(widthOf(tester, 'b'), 300);
      });

      testWidgets('reads a percentage against what the panes divide', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlPanes(
              panes: <PlPane>[
                pane('a', defaultSize: const PlPaneSize.percent(25)),
                pane('b'),
              ],
            ),
            width: 408,
            height: 200,
          ),
        );

        expect(widthOf(tester, 'a'), 100);
      });

      testWidgets('stacks the panes when it is told to', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlPanes(orientation: PlassOrientation.vertical, panes: <PlPane>[pane('a'), pane('b')]),
            width: 400,
            height: 208,
          ),
        );

        expect(heightOf(tester, 'a'), 100);
        expect(widthOf(tester, 'a'), 400);
      });
    });

    group('dragging', () {
      testWidgets('moves the boundary the way the pointer went', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlPanes(panes: <PlPane>[pane('a'), pane('b')]), width: 408, height: 200),
        );

        await tester.drag(handles().first, const Offset(50, 0));
        await tester.pump();

        expect(widthOf(tester, 'a'), closeTo(250, 0.001));
        expect(widthOf(tester, 'b'), closeTo(150, 0.001));
      });

      testWidgets('reports every step and then the one it settled at', (WidgetTester tester) async {
        final List<List<double>> during = <List<double>>[];
        final List<List<double>> settled = <List<double>>[];

        await tester.pumpWidget(
          host(
            PlPanes(
              panes: <PlPane>[pane('a'), pane('b')],
              onResize: during.add,
              onResizeEnd: settled.add,
            ),
            width: 408,
            height: 200,
          ),
        );

        await tester.drag(handles().first, const Offset(40, 0));
        await tester.pump();

        expect(during, isNotEmpty);
        expect(settled, hasLength(1));
        expect(settled.single.first, closeTo(60, 0.001));
      });

      testWidgets('never drags a pane past its minimum', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlPanes(
              panes: <PlPane>[
                pane('a', minSize: const PlPaneSize.percent(50)),
                pane('b'),
              ],
            ),
            width: 408,
            height: 200,
          ),
        );

        await tester.drag(handles().first, const Offset(-200, 0));
        await tester.pump();

        expect(widthOf(tester, 'a'), closeTo(200, 0.001));
      });

      testWidgets('never drags a pane past its maximum', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlPanes(
              panes: <PlPane>[
                pane('a', maxSize: const PlPaneSize.pixels(240)),
                pane('b'),
              ],
            ),
            width: 408,
            height: 200,
          ),
        );

        await tester.drag(handles().first, const Offset(200, 0));
        await tester.pump();

        expect(widthOf(tester, 'a'), closeTo(240, 0.001));
      });

      testWidgets("respects the neighbour's minimum as its own ceiling", (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlPanes(
              panes: <PlPane>[
                pane('a'),
                pane('b', minSize: const PlPaneSize.pixels(150)),
              ],
            ),
            width: 408,
            height: 200,
          ),
        );

        await tester.drag(handles().first, const Offset(200, 0));
        await tester.pump();

        expect(widthOf(tester, 'a'), closeTo(250, 0.001));
        expect(widthOf(tester, 'b'), closeTo(150, 0.001));
      });

      testWidgets('takes no drag at all when the split is a layout', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlPanes(resizable: false, panes: <PlPane>[pane('a'), pane('b')]),
            width: 408,
            height: 200,
          ),
        );

        await tester.drag(handles().first, const Offset(50, 0));
        await tester.pump();

        expect(widthOf(tester, 'a'), 200);
      });
    });

    group('accessibility', () {
      testWidgets('is a control with a value rather than a line', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            PlPanes(
              label: 'Sidebar width',
              panes: <PlPane>[
                pane('a', defaultSize: const PlPaneSize.percent(30)),
                pane('b'),
              ],
            ),
            width: 408,
            height: 200,
          ),
        );

        expect(
          tester.getSemantics(find.bySemanticsLabel('Sidebar width')),
          isSemantics(label: 'Sidebar width', value: '30%', isSlider: true, isEnabled: true),
        );

        handle.dispose();
      });

      testWidgets('says so when it cannot be moved', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            PlPanes(
              label: 'Sidebar width',
              resizable: false,
              panes: <PlPane>[pane('a'), pane('b')],
            ),
            width: 408,
            height: 200,
          ),
        );

        expect(
          tester.getSemantics(find.bySemanticsLabel('Sidebar width')),
          isSemantics(label: 'Sidebar width', isSlider: true, isEnabled: false),
        );

        handle.dispose();
      });
    });
  });
}
