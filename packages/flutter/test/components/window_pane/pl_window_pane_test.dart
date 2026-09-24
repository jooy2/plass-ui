import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/window.dart';

import '../../support/host.dart';

/// A body that says whether it was kept or built again.
class _Kept extends StatefulWidget {
  const _Kept();

  @override
  State<_Kept> createState() => _KeptState();
}

class _KeptState extends State<_Kept> {
  @override
  Widget build(BuildContext context) => const Text('Body');
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(600, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: 420));
  await tester.pumpAndSettle();
}

/// A window that is free to be whatever size it is told to be.
///
/// The shared [_pump] hands its child a *tight* width, which is what the layout
/// tests want and exactly what a resize test cannot have: a window whose width
/// the parent has already decided cannot be dragged any wider.
Future<void> _pumpFree(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(900, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child));
  await tester.pumpAndSettle();
}

/// The window as it is drawn: its frame, after the offset has moved it.
Rect _drawn(WidgetTester tester) {
  return tester.getRect(
    find.descendant(of: find.byType(PlWindowPane), matching: find.byType(Container)).first,
  );
}

/// The middle of the handle on one side of the window.
Offset _edge(WidgetTester tester, AxisDirection side) {
  final Rect rect = tester.getRect(find.byType(PlWindowPane));

  switch (side) {
    case AxisDirection.left:
      return Offset(rect.left + 3, rect.center.dy);
    case AxisDirection.right:
      return Offset(rect.right - 3, rect.center.dy);
    case AxisDirection.up:
      return Offset(rect.center.dx, rect.top + 3);
    case AxisDirection.down:
      return Offset(rect.center.dx, rect.bottom - 3);
  }
}

/// Whether the focus is on the caption button called [name].
///
/// Asked of the pressable around the button rather than of the named node
/// itself, which sits above the button's own focus node rather than under it.
bool _focusIsOn(String name) {
  final BuildContext? focused = FocusManager.instance.primaryFocus?.context;

  return focused != null &&
      find
          .descendant(
            of: find.ancestor(
              of: find.bySemanticsLabel(name),
              matching: find.byType(PlassInteractive),
            ),
            matching: find.byElementPredicate((Element element) => element == focused),
          )
          .evaluate()
          .isNotEmpty;
}

void main() {
  group('PlWindowPane', () {
    testWidgets('names the window after its title', (WidgetTester tester) async {
      await _pump(tester, const PlWindowPane(title: Text('Notes'), child: Text('Body')));

      // Twice over, and both are right: the window is a container named after
      // its title, and the title itself is text in the bar.
      expect(find.bySemanticsLabel('Notes'), findsWidgets);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('draws the three buttons with real names', (WidgetTester tester) async {
      await _pump(tester, const PlWindowPane(title: Text('Notes')));

      for (final String name in <String>['Minimize', 'Maximize', 'Close']) {
        expect(find.bySemanticsLabel(name), findsOneWidget);
      }
    });

    testWidgets('draws only the buttons it was given', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlWindowPane(
          title: Text('Notes'),
          controls: <PlWindowControl>{PlWindowControl.close},
        ),
      );

      expect(find.bySemanticsLabel('Close'), findsOneWidget);
      expect(find.bySemanticsLabel('Minimize'), findsNothing);
    });

    testWidgets('takes every system it names', (WidgetTester tester) async {
      for (final PlWindowOs os in PlWindowOs.values) {
        await _pump(tester, PlWindowPane(os: os, title: const Text('Notes')));

        expect(find.byType(PlWindowPane), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('puts the buttons where the system puts them', (WidgetTester tester) async {
      await _pump(tester, const PlWindowPane(os: PlWindowOs.macos, title: Text('Notes')));

      final double macClose = tester.getCenter(find.bySemanticsLabel('Close')).dx;

      await _pump(tester, const PlWindowPane(os: PlWindowOs.windows11, title: Text('Notes')));

      final double winClose = tester.getCenter(find.bySemanticsLabel('Close')).dx;

      // macOS puts close first and Windows puts it last, whichever order the
      // caller wrote the set in.
      expect(macClose, lessThan(winClose));
    });

    testWidgets('tells the caller when a button is pressed', (WidgetTester tester) async {
      bool? closed;
      bool? minimized;
      bool? maximized;

      await _pump(
        tester,
        PlWindowPane(
          title: const Text('Notes'),
          onOpenChanged: (bool value) => closed = value,
          onMinimizedChanged: (bool value) => minimized = value,
          onMaximizedChanged: (bool value) => maximized = value,
        ),
      );

      await tester.tap(find.bySemanticsLabel('Minimize'));
      await tester.tap(find.bySemanticsLabel('Maximize'));
      await tester.tap(find.bySemanticsLabel('Close'));
      await tester.pumpAndSettle();

      expect(minimized, isTrue);
      expect(maximized, isTrue);
      expect(closed, isFalse);
    });

    testWidgets('offers to restore once it is maximized', (WidgetTester tester) async {
      await _pump(tester, const PlWindowPane(title: Text('Notes'), maximized: true));

      expect(find.bySemanticsLabel('Restore'), findsOneWidget);
      expect(find.bySemanticsLabel('Maximize'), findsNothing);
    });

    testWidgets('fills the box it is laid out in while it is maximized', (
      WidgetTester tester,
    ) async {
      const Key box = ValueKey<String>('box');

      Widget window({required bool maximized}) {
        return SizedBox(
          key: box,
          width: 500,
          height: 400,
          child: Align(
            alignment: Alignment.topLeft,
            child: PlWindowPane(
              title: const Text('Notes'),
              width: 300,
              height: 200,
              offset: const Offset(30, 20),
              maximized: maximized,
              child: const Text('Body'),
            ),
          ),
        );
      }

      await _pumpFree(tester, window(maximized: false));

      final Rect held = tester.getRect(find.byKey(box));

      expect(_drawn(tester), (held.topLeft + const Offset(30, 20)) & const Size(300, 200));

      await _pumpFree(tester, window(maximized: true));

      // The whole box, from its corner: the offset and the size wait for the
      // window to be restored.
      expect(_drawn(tester), held);

      await _pumpFree(tester, window(maximized: false));

      expect(_drawn(tester), (held.topLeft + const Offset(30, 20)) & const Size(300, 200));
    });

    testWidgets('keeps its own height while maximized where the box has none to give', (
      WidgetTester tester,
    ) async {
      await _pumpFree(
        tester,
        const SizedBox(
          width: 500,
          height: 400,
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topLeft,
              child: PlWindowPane(
                title: Text('Notes'),
                width: 300,
                height: 200,
                maximized: true,
                child: Text('Body'),
              ),
            ),
          ),
        ),
      );

      expect(_drawn(tester).size, const Size(500, 200));
    });

    testWidgets('neither drags nor offers its bar to the keyboard while it is maximized', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      Offset? moved;

      await _pump(
        tester,
        PlWindowPane(
          title: const Text('Notes'),
          draggable: true,
          maximized: true,
          width: 300,
          onOffsetChanged: (Offset value) => moved = value,
        ),
      );

      await tester.drag(find.text('Notes'), const Offset(40, 20));
      await tester.pumpAndSettle();

      expect(moved, isNull);
      expect(find.bySemanticsLabel('Move window'), findsNothing);

      handle.dispose();
    });

    testWidgets('rolls up to its bar whatever height it was given, and comes back down', (
      WidgetTester tester,
    ) async {
      final PlWindowMetrics metrics = windowMetrics(PlWindowOs.macos, PlassSize.md);

      Widget window({required bool minimized}) {
        return PlWindowPane(
          title: const Text('Notes'),
          width: 300,
          height: 200,
          minimized: minimized,
          child: const Text('Body'),
        );
      }

      await _pumpFree(tester, window(minimized: true));

      expect(_drawn(tester).size, Size(300, metrics.bar + metrics.frame * 2));

      await _pumpFree(tester, window(minimized: false));

      expect(_drawn(tester).size, const Size(300, 200));
    });

    testWidgets('rolls up in a scrolling column with content that needs a height', (
      WidgetTester tester,
    ) async {
      final PlWindowMetrics metrics = windowMetrics(PlWindowOs.macos, PlassSize.md);

      await _pumpFree(
        tester,
        const SizedBox(
          width: 500,
          height: 400,
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topLeft,
              child: PlWindowPane(
                title: Text('Notes'),
                width: 300,
                height: 200,
                minimized: true,
                child: Column(children: <Widget>[Expanded(child: Text('Body'))]),
              ),
            ),
          ),
        ),
      );

      // Laid out off stage at the height it had, so the `Expanded` is not
      // handed an unbounded one.
      expect(tester.takeException(), isNull);
      expect(_drawn(tester).height, metrics.bar + metrics.frame * 2);
    });

    testWidgets('keeps what it holds, and the focus, through a maximize and a roll-up', (
      WidgetTester tester,
    ) async {
      final FocusNode before = FocusNode();
      addTearDown(before.dispose);

      bool maximized = false;
      bool minimized = false;

      await _pumpFree(
        tester,
        afterFocusStop(
          before,
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => PlWindowPane(
              title: const Text('Notes'),
              width: 300,
              height: 200,
              draggable: true,
              resizable: true,
              maximized: maximized,
              minimized: minimized,
              onMaximizedChanged: (bool value) => setState(() => maximized = value),
              onMinimizedChanged: (bool value) => setState(() => minimized = value),
              child: const _Kept(),
            ),
          ),
        ),
      );

      final _KeptState state = tester.state<_KeptState>(find.byType(_Kept));

      before.requestFocus();
      await tester.pump();

      // Past the bar's own stop to the button, however the system orders them.
      for (int i = 0; i < 5 && !_focusIsOn('Maximize'); i += 1) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // The bar and the body are the ones they were, so the button that was
      // pressed still holds the focus under its new name.
      expect(maximized, isTrue);
      expect(_focusIsOn('Restore'), isTrue);
      expect(tester.state<_KeptState>(find.byType(_Kept)), same(state));

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(maximized, isFalse);
      expect(_focusIsOn('Maximize'), isTrue);
      expect(tester.state<_KeptState>(find.byType(_Kept)), same(state));

      await tester.tap(find.bySemanticsLabel('Minimize'));
      await tester.pumpAndSettle();

      expect(minimized, isTrue);
      expect(tester.state<_KeptState>(find.byType(_Kept, skipOffstage: false)), same(state));

      await tester.tap(find.bySemanticsLabel('Minimize'));
      await tester.pumpAndSettle();

      expect(minimized, isFalse);
      expect(tester.state<_KeptState>(find.byType(_Kept)), same(state));
    });

    testWidgets('rolls up to its bar rather than sending itself anywhere', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const PlWindowPane(title: Text('Notes'), minimized: true, child: Text('Body')),
      );

      // The bar stays where it is — a page has nowhere to send a window.
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('keeps the rolled-up body in the tree, out of reach', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await _pump(tester, const PlWindowPane(title: Text('Notes'), child: _Kept()));

      final _KeptState state = tester.state<_KeptState>(find.byType(_Kept));

      await _pump(
        tester,
        const PlWindowPane(title: Text('Notes'), minimized: true, child: _Kept()),
      );

      // Still there, and the same one: a form half filled in is still half
      // filled in when the window comes back down.
      expect(find.byType(_Kept, skipOffstage: false), findsOneWidget);
      expect(tester.state<_KeptState>(find.byType(_Kept, skipOffstage: false)), same(state));

      // And out of reach while it is rolled up: nothing drawn, nothing read,
      // nothing to tab into.
      expect(find.text('Body'), findsNothing);
      expect(find.bySemanticsLabel('Body'), findsNothing);
      expect(
        tester
            .widget<ExcludeFocus>(
              find.ancestor(
                of: find.byType(_Kept, skipOffstage: false),
                matching: find.byType(ExcludeFocus),
              ),
            )
            .excluding,
        isTrue,
      );

      handle.dispose();
    });

    testWidgets('renders nothing when it is closed', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlWindowPane(title: Text('Notes'), open: false, child: Text('Body')),
      );

      expect(find.text('Body'), findsNothing);
      expect(find.text('Notes'), findsNothing);
    });

    testWidgets('takes an override for each button name', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlWindowPane(
          title: Text('Notes'),
          minimizeLabel: 'Roll up',
          maximizeLabel: 'Fill',
          closeLabel: 'Dismiss',
        ),
      );

      for (final String name in <String>['Roll up', 'Fill', 'Dismiss']) {
        expect(find.bySemanticsLabel(name), findsOneWidget);
      }
    });

    testWidgets('drags by its bar when it is allowed to', (WidgetTester tester) async {
      Offset? moved;

      await _pump(
        tester,
        PlWindowPane(
          title: const Text('Notes'),
          draggable: true,
          width: 300,
          onOffsetChanged: (Offset value) => moved = value,
        ),
      );

      await tester.drag(find.text('Notes'), const Offset(40, 20));
      await tester.pumpAndSettle();

      expect(moved, isNotNull);
      expect(moved!.dx, greaterThan(0));
    });

    testWidgets('moves by the pointer and no further when the offset is fed back', (
      WidgetTester tester,
    ) async {
      Offset at = Offset.zero;

      await _pumpFree(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => PlWindowPane(
            title: const Text('Notes'),
            draggable: true,
            width: 300,
            offset: at,
            onOffsetChanged: (Offset value) => setState(() => at = value),
          ),
        ),
      );

      final Offset before = tester.getTopLeft(find.text('Notes'));
      final TestGesture gesture = await tester.startGesture(tester.getCenter(find.text('Notes')));

      // Past the slop first, then in steps with a rebuild between each, which is
      // where a travel that was counted again on every rebuild would show.
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();

      final Offset started = tester.getTopLeft(find.text('Notes'));

      for (int i = 0; i < 4; i += 1) {
        await gesture.moveBy(const Offset(10, 5));
        await tester.pump();
      }

      await gesture.up();
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.text('Notes')) - started, const Offset(40, 20));
      expect(tester.getTopLeft(find.text('Notes')) - before, at);
    });

    testWidgets('moves on its own when nothing is told the offset', (WidgetTester tester) async {
      await _pumpFree(
        tester,
        const PlWindowPane(title: Text('Notes'), draggable: true, width: 300),
      );

      final Offset before = tester.getTopLeft(find.text('Notes'));
      final TestGesture gesture = await tester.startGesture(tester.getCenter(find.text('Notes')));

      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();

      final Offset started = tester.getTopLeft(find.text('Notes'));

      await gesture.moveBy(const Offset(40, 20));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(started.dx, greaterThan(before.dx));
      expect(tester.getTopLeft(find.text('Notes')) - started, const Offset(40, 20));
    });

    testWidgets('stays where it is when it is not', (WidgetTester tester) async {
      Offset? moved;

      await _pump(
        tester,
        PlWindowPane(
          title: const Text('Notes'),
          width: 300,
          onOffsetChanged: (Offset value) => moved = value,
        ),
      );

      await tester.drag(find.text('Notes'), const Offset(40, 20));
      await tester.pumpAndSettle();

      expect(moved, isNull);
    });

    testWidgets('takes an icon and actions in the bar', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlWindowPane(title: Text('Notes'), icon: Text('◆'), actions: Text('Share')),
      );

      expect(find.text('◆'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('climbs the size ladder without touching the content', (WidgetTester tester) async {
      double? small;

      for (final PlassSize size in <PlassSize>[PlassSize.xs, PlassSize.xl]) {
        await _pump(tester, PlWindowPane(title: const Text('Notes'), size: size));

        final double height = tester.getSize(find.byType(PlWindowPane)).height;

        if (small == null) {
          small = height;
        } else {
          expect(height, greaterThan(small));
        }
      }
    });

    testWidgets('offers no handle until it is resizable', (WidgetTester tester) async {
      await _pumpFree(tester, const PlWindowPane(title: Text('Notes'), width: 300, height: 200));

      expect(find.bySemanticsLabel('Resize window'), findsNothing);

      await _pumpFree(
        tester,
        const PlWindowPane(title: Text('Notes'), width: 300, height: 200, resizable: true),
      );

      // One of the eight, and one only: the corner that changes both axes.
      expect(find.bySemanticsLabel('Resize window'), findsOneWidget);
    });

    testWidgets('widens from its trailing edge', (WidgetTester tester) async {
      Size? sized;

      await _pumpFree(
        tester,
        PlWindowPane(
          title: const Text('Notes'),
          width: 300,
          height: 200,
          resizable: true,
          onResize: (Size value) => sized = value,
        ),
      );

      await tester.dragFrom(_edge(tester, AxisDirection.right), const Offset(60, 0));
      await tester.pumpAndSettle();

      expect(sized!.width, closeTo(360, 0.5));
      expect(sized!.height, closeTo(200, 0.5));
      expect(tester.getSize(find.byType(PlWindowPane)).width, closeTo(360, 0.5));
    });

    testWidgets('moves as it widens from its leading edge', (WidgetTester tester) async {
      Size? sized;
      Offset? moved;

      await _pumpFree(
        tester,
        PlWindowPane(
          title: const Text('Notes'),
          width: 300,
          height: 200,
          resizable: true,
          onResize: (Size value) => sized = value,
          onOffsetChanged: (Offset value) => moved = value,
        ),
      );

      await tester.dragFrom(_edge(tester, AxisDirection.left), const Offset(-40, 0));
      await tester.pumpAndSettle();

      expect(sized!.width, closeTo(340, 0.5));
      // The edge went left, so the window has to have gone left with it. A
      // window that grew from its left edge without moving would have grown out
      // of its right one.
      expect(moved!.dx, closeTo(-40, 0.5));
    });

    testWidgets('moves with a leading edge by the pointer and no further when fed back', (
      WidgetTester tester,
    ) async {
      Offset at = Offset.zero;

      await _pumpFree(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => PlWindowPane(
            title: const Text('Notes'),
            width: 300,
            height: 200,
            resizable: true,
            offset: at,
            onOffsetChanged: (Offset value) => setState(() => at = value),
          ),
        ),
      );

      final TestGesture gesture = await tester.startGesture(_edge(tester, AxisDirection.left));

      for (int i = 0; i < 5; i += 1) {
        await gesture.moveBy(const Offset(-10, 0));
        await tester.pump();
      }

      await gesture.up();
      await tester.pumpAndSettle();

      // However much of the travel the slop took, the window went left by what
      // it reported, once.
      expect(at.dx, lessThan(0));
      expect(at.dx, greaterThanOrEqualTo(-50));
    });

    testWidgets('stops at the floor it was given', (WidgetTester tester) async {
      Size? sized;

      await _pumpFree(
        tester,
        PlWindowPane(
          title: const Text('Notes'),
          width: 300,
          height: 200,
          resizable: true,
          minWidth: 200,
          onResize: (Size value) => sized = value,
        ),
      );

      await tester.dragFrom(_edge(tester, AxisDirection.right), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(sized!.width, 200);
    });

    testWidgets('keeps the window under the pointer at the floor', (WidgetTester tester) async {
      Offset? moved;

      await _pumpFree(
        tester,
        PlWindowPane(
          title: const Text('Notes'),
          width: 300,
          height: 200,
          resizable: true,
          minWidth: 200,
          onOffsetChanged: (Offset value) => moved = value,
        ),
      );

      // Dragged a hundred pixels past the floor. The window is a hundred
      // narrower and no more, so it has moved a hundred and not four hundred.
      await tester.dragFrom(_edge(tester, AxisDirection.left), const Offset(400, 0));
      await tester.pumpAndSettle();

      expect(moved!.dx, closeTo(100, 0.5));
    });

    testWidgets('takes an arrow key on the reachable corner', (WidgetTester tester) async {
      Size? sized;

      await _pumpFree(
        tester,
        PlWindowPane(
          title: const Text('Notes'),
          width: 300,
          height: 200,
          resizable: true,
          onResize: (Size value) => sized = value,
        ),
      );

      Focus.of(
        tester.element(
          find
              .descendant(
                of: find.byType(FocusableActionDetector),
                matching: find.byType(MouseRegion),
              )
              .last,
        ),
      ).requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(sized!.width, closeTo(316, 0.5));
    });

    testWidgets('puts its handles away while it is maximized', (WidgetTester tester) async {
      await _pumpFree(
        tester,
        const PlWindowPane(
          title: Text('Notes'),
          width: 300,
          height: 200,
          resizable: true,
          maximized: true,
        ),
      );

      expect(find.bySemanticsLabel('Resize window'), findsNothing);
    });

    testWidgets('and while it is rolled up', (WidgetTester tester) async {
      await _pumpFree(
        tester,
        const PlWindowPane(title: Text('Notes'), width: 300, resizable: true, minimized: true),
      );

      expect(find.bySemanticsLabel('Resize window'), findsNothing);
    });

    group('moving from the keyboard', () {
      /// The window as it is drawn, after the offset has moved it.
      Rect drawn(WidgetTester tester) {
        return tester.getRect(
          find.descendant(of: find.byType(PlWindowPane), matching: find.byType(Container)).first,
        );
      }

      /// Gives the focus to the stop the bar offers the keyboard.
      Future<void> focusBar(WidgetTester tester, {String name = 'Move window'}) async {
        Focus.of(
          tester.element(
            find.descendant(of: find.bySemanticsLabel(name), matching: find.byType(SizedBox)).last,
          ),
        ).requestFocus();
        await tester.pump();
      }

      /// Presses [key], with Shift held when [far] is.
      Future<void> press(WidgetTester tester, LogicalKeyboardKey key, {bool far = false}) async {
        if (far) {
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        }

        await tester.sendKeyEvent(key);

        if (far) {
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        }

        await tester.pump();
      }

      testWidgets('offers the bar to the keyboard only while the bar drags', (
        WidgetTester tester,
      ) async {
        await _pumpFree(tester, const PlWindowPane(title: Text('Notes'), width: 300));

        expect(find.bySemanticsLabel('Move window'), findsNothing);

        await _pumpFree(
          tester,
          const PlWindowPane(title: Text('Notes'), width: 300, draggable: true),
        );

        expect(
          tester.getSemantics(find.bySemanticsLabel('Move window')),
          isSemantics(label: 'Move window', isButton: true),
        );
      });

      testWidgets('takes its name from moveLabel', (WidgetTester tester) async {
        await _pumpFree(
          tester,
          const PlWindowPane(
            title: Text('Notes'),
            width: 300,
            draggable: true,
            moveLabel: 'Drag Notes',
          ),
        );

        expect(find.bySemanticsLabel('Drag Notes'), findsOneWidget);
      });

      testWidgets('is reached by Tab ahead of the buttons, with a ring', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        await _pump(
          tester,
          afterFocusStop(before, const PlWindowPane(title: Text('Notes'), draggable: true)),
        );

        before.requestFocus();
        await tester.pump();

        final Finder rings = find.byWidgetPredicate(
          (Widget widget) =>
              widget is CustomPaint && widget.foregroundPainter is PlassFocusRingPainter,
        );

        expect(rings, findsNothing);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        final BuildContext? focused = FocusManager.instance.primaryFocus?.context;

        expect(
          find
              .descendant(
                of: find.bySemanticsLabel('Move window'),
                matching: find.byElementPredicate((Element element) => element == focused),
              )
              .evaluate(),
          isNotEmpty,
        );
        expect(rings, findsOneWidget);
      });

      testWidgets('moves a step for each arrow key, and four steps with Shift', (
        WidgetTester tester,
      ) async {
        await _pumpFree(
          tester,
          const PlWindowPane(title: Text('Notes'), width: 300, draggable: true),
        );

        final Offset start = drawn(tester).topLeft;

        await focusBar(tester);
        await press(tester, LogicalKeyboardKey.arrowRight);

        expect(drawn(tester).topLeft - start, const Offset(16, 0));

        await press(tester, LogicalKeyboardKey.arrowDown, far: true);

        expect(drawn(tester).topLeft - start, const Offset(16, 64));

        await press(tester, LogicalKeyboardKey.arrowLeft);
        await press(tester, LogicalKeyboardKey.arrowUp);

        expect(drawn(tester).topLeft - start, const Offset(0, 48));
      });

      testWidgets('stops where the title bar would leave the screen', (WidgetTester tester) async {
        final PlWindowMetrics metrics = windowMetrics(PlWindowOs.macos, PlassSize.md);

        await _pumpFree(
          tester,
          const PlWindowPane(title: Text('Notes'), width: 300, height: 200, draggable: true),
        );

        await focusBar(tester);

        for (int i = 0; i < 12; i += 1) {
          await press(tester, LogicalKeyboardKey.arrowLeft, far: true);
          await press(tester, LogicalKeyboardKey.arrowUp, far: true);
        }

        expect(drawn(tester).topLeft.dx, closeTo(0, 0.5));
        expect(drawn(tester).topLeft.dy, closeTo(0, 0.5));

        for (int i = 0; i < 20; i += 1) {
          await press(tester, LogicalKeyboardKey.arrowRight, far: true);
          await press(tester, LogicalKeyboardKey.arrowDown, far: true);
        }

        // The whole width stays on the screen, and of the height the bar does:
        // the body may go past the bottom edge, but never what is being held.
        expect(drawn(tester).right, closeTo(900, 0.5));
        expect(drawn(tester).top + metrics.frame + metrics.bar, closeTo(900, 0.5));
      });

      testWidgets('moves the way the arrow points under RTL', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(900, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          host(
            const PlWindowPane(title: Text('Notes'), width: 300, draggable: true),
            textDirection: TextDirection.rtl,
          ),
        );
        await tester.pumpAndSettle();

        final Offset start = drawn(tester).topLeft;

        await focusBar(tester);
        await press(tester, LogicalKeyboardKey.arrowRight);

        expect(drawn(tester).topLeft - start, const Offset(16, 0));
      });

      testWidgets('reports rather than moves when the offset is controlled', (
        WidgetTester tester,
      ) async {
        Offset? moved;

        await _pumpFree(
          tester,
          PlWindowPane(
            title: const Text('Notes'),
            width: 300,
            draggable: true,
            offset: const Offset(10, 10),
            onOffsetChanged: (Offset value) => moved = value,
          ),
        );

        final Offset start = drawn(tester).topLeft;

        await focusBar(tester);
        await press(tester, LogicalKeyboardKey.arrowRight);

        expect(moved, const Offset(26, 10));
        // Still where the caller put it, because the caller holds the offset.
        expect(drawn(tester).topLeft, start);
      });
    });

    group('caption buttons from the keyboard', () {
      const List<String> names = <String>['Minimize', 'Maximize', 'Close'];

      /// Puts [window] after a focus stop of its own and gives that stop the focus.
      Future<void> pumpAfterStop(WidgetTester tester, Widget window) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        await _pump(tester, afterFocusStop(before, window));

        before.requestFocus();
        await tester.pump();
      }

      /// Tabs forward until the focus is on the button called [name]. Four
      /// presses go once round the stop before the window and its three buttons.
      Future<void> tabTo(WidgetTester tester, String name) async {
        for (int i = 0; i < 4 && !_focusIsOn(name); i += 1) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
        }

        expect(_focusIsOn(name), isTrue, reason: 'Tab reached $name');
      }

      testWidgets('reaches every button with Tab', (WidgetTester tester) async {
        await pumpAfterStop(tester, const PlWindowPane(title: Text('Notes')));

        final Set<String> reached = <String>{};

        for (int i = 0; i < names.length; i += 1) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();

          for (final String name in names) {
            if (_focusIsOn(name)) {
              reached.add(name);
            }
          }
        }

        expect(reached, names.toSet());
      });

      testWidgets('presses the focused button with Enter and with Space', (
        WidgetTester tester,
      ) async {
        for (final LogicalKeyboardKey key in <LogicalKeyboardKey>[
          LogicalKeyboardKey.enter,
          LogicalKeyboardKey.space,
        ]) {
          final Map<String, int> presses = <String, int>{for (final String name in names) name: 0};

          await pumpAfterStop(
            tester,
            PlWindowPane(
              title: const Text('Notes'),
              onMinimizedChanged: (bool value) => presses.update('Minimize', (int n) => n + 1),
              onMaximizedChanged: (bool value) => presses.update('Maximize', (int n) => n + 1),
              onOpenChanged: (bool value) => presses.update('Close', (int n) => n + 1),
            ),
          );

          for (final String name in names) {
            await tabTo(tester, name);
            await tester.sendKeyEvent(key);
            await tester.pump();

            expect(presses[name], 1, reason: '$name by ${key.keyLabel}');
          }

          // Each key pressed one button once, and never the others.
          expect(presses.values, everyElement(1), reason: key.keyLabel);
        }
      });

      testWidgets('keeps each button one node, named and pressable', (WidgetTester tester) async {
        await _pump(tester, const PlWindowPane(title: Text('Notes'), maximized: true));

        for (final String name in <String>['Minimize', 'Restore', 'Close']) {
          expect(find.bySemanticsLabel(name), findsOneWidget);
          expect(
            tester.getSemantics(find.bySemanticsLabel(name)),
            isSemantics(label: name, isButton: true, hasTapAction: true),
          );
        }
      });

      testWidgets('rings the button the keyboard is on and shows a traffic light its mark', (
        WidgetTester tester,
      ) async {
        await pumpAfterStop(tester, const PlWindowPane(title: Text('Notes')));

        final Finder rings = find.byWidgetPredicate(
          (Widget widget) =>
              widget is CustomPaint && widget.foregroundPainter is PlassFocusRingPainter,
        );
        final Finder marks = find.byWidgetPredicate(
          (Widget widget) => widget is CustomPaint && widget.painter is PlWindowGlyphPainter,
        );

        // Traffic lights at rest are three dots with no mark on them.
        expect(rings, findsNothing);
        expect(marks, findsNothing);

        await tabTo(tester, 'Close');

        expect(rings, findsOneWidget);
        expect(marks, findsOneWidget);
      });
    });
  });
}
