import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';

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

/// A focus ring being drawn.
final Finder _ring = find.byWidgetPredicate(
  (Widget widget) => widget is CustomPaint && widget.foregroundPainter is PlassFocusRingPainter,
);

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
            PlPanes(
              orientation: const PlassResponsive<PlassOrientation>(PlassOrientation.vertical),
              panes: <PlPane>[pane('a'), pane('b')],
            ),
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

    group('the keyboard', () {
      setUp(() {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      });

      tearDown(() {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
      });

      /// A split after a focus stop of its own, which the test starts from.
      Widget split(FocusNode before, {required bool resizable}) {
        return host(
          afterFocusStop(
            before,
            SizedBox(
              width: 408,
              height: 200,
              child: PlPanes(resizable: resizable, panes: <PlPane>[pane('a'), pane('b')]),
            ),
          ),
          width: 408,
        );
      }

      testWidgets('moves the boundary a step at a time with the arrows', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        await tester.pumpWidget(split(before, resizable: true));
        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        expect(_ring, findsOneWidget);
        expect(widthOf(tester, 'a'), closeTo(216, 0.001));
      });

      testWidgets('lets the focus go, and its ring with it, once the split is a layout', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        await tester.pumpWidget(split(before, resizable: true));
        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(_ring, findsOneWidget);

        await tester.pumpWidget(split(before, resizable: false));
        await tester.pumpAndSettle();

        expect(_ring, findsNothing);

        // Out of the tab order, so Tab from the stop before it does not land
        // on it, and the arrows move nothing.
        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        expect(_ring, findsNothing);
        expect(widthOf(tester, 'a'), 200);
      });

      testWidgets('takes the focus again once it can be resized again', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        await tester.pumpWidget(split(before, resizable: false));
        await tester.pumpWidget(split(before, resizable: true));
        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        expect(_ring, findsOneWidget);
        expect(widthOf(tester, 'a'), closeTo(216, 0.001));
      });

      for (final NavigationMode mode in NavigationMode.values) {
        testWidgets('keeps an arrow that moves nothing only in traditional navigation, '
            '${mode.name}', (WidgetTester tester) async {
          await tester.pumpWidget(
            host(
              inNavigationMode(
                mode,
                PlPanes(
                  panes: <PlPane>[
                    pane('a', minSize: const PlPaneSize.percent(50)),
                    pane('b'),
                  ],
                ),
              ),
              width: 408,
              height: 200,
            ),
          );
          Focus.of(tester.element(handles().first)).requestFocus();
          await tester.pump();

          expect(holdsFocus(tester, find.byType(PlPanes)), isTrue);

          // The first pane at its minimum. Under directional navigation the
          // arrows are the only way off the handle, so one that moves nothing
          // goes on to the focus system.
          final bool traditional = mode == NavigationMode.traditional;

          expect(await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft), traditional);
          expect(await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp), traditional);
          await tester.pump();

          expect(widthOf(tester, 'a'), closeTo(200, 0.001));

          // An arrow that moves the boundary is kept in both.
          expect(await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight), isTrue);
          await tester.pump();

          expect(widthOf(tester, 'a'), closeTo(216, 0.001));
        });

        testWidgets('moves with the arrows across the line\'s travel only in traditional '
            'navigation, ${mode.name}', (WidgetTester tester) async {
          for (final PlassOrientation orientation in PlassOrientation.values) {
            final bool horizontal = orientation == PlassOrientation.horizontal;

            await tester.pumpWidget(
              host(
                inNavigationMode(
                  mode,
                  PlPanes(
                    key: ValueKey<PlassOrientation>(orientation),
                    orientation: PlassResponsive<PlassOrientation>(orientation),
                    panes: <PlPane>[pane('a'), pane('b')],
                  ),
                ),
                width: 408,
                height: 408,
              ),
            );
            Focus.of(tester.element(handles().first)).requestFocus();
            await tester.pump();

            expect(holdsFocus(tester, find.byType(PlPanes)), isTrue);

            double first() => horizontal ? widthOf(tester, 'a') : heightOf(tester, 'a');
            final double start = first();

            // Under directional navigation the arrows across the line's travel
            // are how a remote moves on to the control beside it, so they go on
            // to the focus system with the line where it was.
            final bool traditional = mode == NavigationMode.traditional;
            final LogicalKeyboardKey across = horizontal
                ? LogicalKeyboardKey.arrowDown
                : LogicalKeyboardKey.arrowRight;
            final LogicalKeyboardKey along = horizontal
                ? LogicalKeyboardKey.arrowRight
                : LogicalKeyboardKey.arrowDown;

            expect(await tester.sendKeyEvent(across), traditional, reason: orientation.name);
            await tester.pump();

            expect(first() > start, traditional, reason: orientation.name);

            // The arrows along it move the line in both.
            final double before = first();

            expect(await tester.sendKeyEvent(along), isTrue, reason: orientation.name);
            await tester.pump();

            expect(first(), greaterThan(before), reason: orientation.name);
          }
        });
      }
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
