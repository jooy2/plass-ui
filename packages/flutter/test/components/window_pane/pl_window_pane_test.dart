import 'dart:math' as math;

import 'package:flutter/gestures.dart' show PointerDeviceKind, kDoubleTapTimeout, kPressTimeout;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/css.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/internal/window.dart';

import '../../support/host.dart';
import '../../support/ticking.dart';

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

/// How much of [control]'s mark is showing, as the fade over it stands.
///
/// A traffic light keeps its mark in the tree and fades it, so the mark is
/// always there to be found.
double _markShown(WidgetTester tester, PlWindowControl control) {
  final Finder mark = find.byWidgetPredicate(
    (Widget widget) =>
        widget is CustomPaint &&
        widget.painter is PlWindowGlyphPainter &&
        (widget.painter! as PlWindowGlyphPainter).control == control,
  );

  expect(mark, findsOneWidget, reason: '${control.name} keeps its mark');

  return tester
      .widget<FadeTransition>(find.ancestor(of: mark, matching: find.byType(FadeTransition)).first)
      .opacity
      .value;
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

    testWidgets('stops the tickers in the body while it is rolled up', (WidgetTester tester) async {
      Widget window({required bool minimized}) =>
          PlWindowPane(title: const Text('Notes'), minimized: minimized, child: const Ticking());

      await tester.pumpWidget(host(window(minimized: false), width: 420));
      await tester.pump(const Duration(milliseconds: 100));
      expect(ticksOf(tester), greaterThan(0));

      // Off stage, the loop is not drawn, and it is not handed a frame either.
      await tester.pumpWidget(host(window(minimized: true), width: 420));
      await tester.pump(const Duration(seconds: 1));
      final int rolled = ticksOf(tester);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(ticksOf(tester), rolled);
      expect(tester.binding.hasScheduledFrame, isFalse);

      // Brought back down, the same loop runs again.
      await tester.pumpWidget(host(window(minimized: false), width: 420));
      await tester.pump(const Duration(milliseconds: 16));
      expect(ticksOf(tester), greaterThan(rolled));
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

    testWidgets('fills the height a drag gives a window that was given none', (
      WidgetTester tester,
    ) async {
      final PlWindowMetrics metrics = windowMetrics(PlWindowOs.windows7, PlassSize.md);

      await _pumpFree(
        tester,
        const PlWindowPane(
          os: PlWindowOs.windows7,
          title: Text('Notes'),
          width: 300,
          resizable: true,
          child: Text('Body'),
        ),
      );

      /// The body, band margin included, which is what has to reach the frame.
      Rect body() =>
          tester.getRect(find.ancestor(of: find.text('Body'), matching: find.byType(Offstage)));

      await tester.dragFrom(_edge(tester, AxisDirection.down), const Offset(0, 120));
      await tester.pumpAndSettle();

      // Down to the frame, as the React body is, rather than at the height of
      // what is in it with the band showing underneath.
      expect(body().bottom, closeTo(_drawn(tester).bottom - metrics.frame, 0.5));
      expect(body().top, closeTo(_drawn(tester).top + metrics.frame + metrics.bar, 0.5));
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

    testWidgets('stops at its bar and the frame round it, whatever minHeight says', (
      WidgetTester tester,
    ) async {
      final PlWindowMetrics metrics = windowMetrics(PlWindowOs.windowsxp, PlassSize.md);
      final double shortest = metrics.bar + metrics.frame * 2;

      for (final double? floor in <double?>[null, 0]) {
        Size? sized;

        await _pumpFree(
          tester,
          PlWindowPane(
            // A window of its own each time, so the size one drag left behind
            // is not where the next one starts.
            key: ValueKey<double?>(floor),
            os: PlWindowOs.windowsxp,
            title: const Text('Notes'),
            width: 300,
            height: 200,
            resizable: true,
            minHeight: floor,
            onResize: (Size value) => sized = value,
            child: const Text('Body'),
          ),
        );

        await tester.dragFrom(_edge(tester, AxisDirection.down), const Offset(0, -400));
        await tester.pumpAndSettle();

        // Any shorter and the bar overflows the frame it is laid out in.
        expect(tester.takeException(), isNull);
        expect(sized!.height, closeTo(shortest, 0.5));
        expect(_drawn(tester).height, closeTo(shortest, 0.5));
      }
    });

    testWidgets('stops there from the keyboard too', (WidgetTester tester) async {
      final PlWindowMetrics metrics = windowMetrics(PlWindowOs.windowsxp, PlassSize.md);
      final double shortest = metrics.bar + metrics.frame * 2;
      Size? sized;

      await _pumpFree(
        tester,
        PlWindowPane(
          os: PlWindowOs.windowsxp,
          title: const Text('Notes'),
          width: 300,
          height: shortest + 4,
          resizable: true,
          minHeight: 0,
          onResize: (Size value) => sized = value,
          child: const Text('Body'),
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

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(sized!.height, closeTo(shortest, 0.5));
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

        // Traffic lights at rest are three dots with no mark on them.
        expect(rings, findsNothing);

        for (final PlWindowControl control in PlWindowControl.values) {
          expect(_markShown(tester, control), 0, reason: control.name);
        }

        await tabTo(tester, 'Close');
        await tester.pumpAndSettle();

        expect(rings, findsOneWidget);
        // The ring is on one light, and so is the mark. Lighting the other two
        // would say the pointer is over the set, which it is not.
        expect(_markShown(tester, PlWindowControl.close), 1);
        expect(_markShown(tester, PlWindowControl.minimize), 0);
        expect(_markShown(tester, PlWindowControl.maximize), 0);
      });
    });

    group('caption plates under the pointer', () {
      /// The caption button drawing [control]'s mark.
      Finder caption(PlWindowControl control) {
        return find.byWidgetPredicate(
          (Widget widget) =>
              widget is CustomPaint &&
              widget.painter is PlWindowGlyphPainter &&
              (widget.painter! as PlWindowGlyphPainter).control == control,
        );
      }

      /// The filter the button drawing [control]'s mark is painted through,
      /// or `null` while it is painted in its own colours.
      ColorFilter? filter(WidgetTester tester, PlWindowControl control) {
        final Finder filtered = find.ancestor(
          of: caption(control),
          matching: find.byType(PlassFiltered),
        );

        return filtered.evaluate().isEmpty
            ? null
            : tester.widget<PlassFiltered>(filtered.first).colorFilter;
      }

      /// A mouse, resting in the corner of the screen.
      Future<TestGesture> mouseInCorner(WidgetTester tester) async {
        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

        await mouse.addPointer(location: Offset.zero);
        addTearDown(mouse.removePointer);
        await tester.pump();

        return mouse;
      }

      testWidgets('brighten an XP plate, the close one too, and dim it under a press', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const PlWindowPane(os: PlWindowOs.windowsxp, title: Text('Notes')));

        final TestGesture mouse = await mouseInCorner(tester);

        for (final PlWindowControl control in PlWindowControl.values) {
          expect(filter(tester, control), isNull, reason: control.name);

          await mouse.moveTo(tester.getCenter(caption(control)));
          await tester.pump();
          // Eased, as the React plate's `filter` is.
          await tester.pump(PlassTokens.light().motionDuration ~/ 2);

          expect(filter(tester, control), isNotNull, reason: control.name);
          expect(filter(tester, control), isNot(brightnessFilter(1.1)), reason: control.name);

          await tester.pumpAndSettle();

          expect(filter(tester, control), brightnessFilter(1.1), reason: control.name);

          await mouse.down(tester.getCenter(caption(control)));
          await tester.pumpAndSettle();

          expect(filter(tester, control), brightnessFilter(pressBrightness), reason: control.name);

          // Let go without pressing it, and move off.
          await mouse.cancel();
          await mouse.moveTo(Offset.zero);
          await tester.pumpAndSettle();
        }
      });

      testWidgets('brighten Aero\'s minimize and maximize, and turn its close red instead', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const PlWindowPane(os: PlWindowOs.windows7, title: Text('Notes')));

        final TestGesture mouse = await mouseInCorner(tester);

        for (final PlWindowControl control in <PlWindowControl>[
          PlWindowControl.minimize,
          PlWindowControl.maximize,
        ]) {
          await mouse.moveTo(tester.getCenter(caption(control)));
          await tester.pumpAndSettle();

          expect(filter(tester, control), brightnessFilter(1.1), reason: control.name);
        }

        await mouse.moveTo(tester.getCenter(caption(PlWindowControl.close)));
        await tester.pumpAndSettle();

        expect(filter(tester, PlWindowControl.maximize), isNull);
        expect(filter(tester, PlWindowControl.close), isNull);
      });

      testWidgets('brighten a plate at once under reduced motion', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(600, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          host(
            const PlWindowPane(os: PlWindowOs.windowsxp, title: Text('Notes')),
            width: 420,
            disableAnimations: true,
          ),
        );
        await tester.pumpAndSettle();

        final TestGesture mouse = await mouseInCorner(tester);

        await mouse.moveTo(tester.getCenter(caption(PlWindowControl.minimize)));
        await tester.pump();

        expect(filter(tester, PlWindowControl.minimize), brightnessFilter(1.1));
      });
    });

    // Each face is checked against the React button's own values, from
    // `controlFace` and `closeHover` in `src/internal/window.tsx`.
    group('caption faces', () {
      /// The caption button drawing [control]'s mark.
      Finder captionMark(PlWindowControl control) {
        return find.byWidgetPredicate(
          (Widget widget) =>
              widget is CustomPaint &&
              widget.painter is PlWindowGlyphPainter &&
              (widget.painter! as PlWindowGlyphPainter).control == control,
        );
      }

      /// What the button drawing [control]'s mark paints under the mark: its
      /// face, then the finish over the face where it has one.
      List<BoxDecoration> captionFace(WidgetTester tester, PlWindowControl control) {
        final Finder button = find
            .ancestor(of: captionMark(control), matching: find.byType(PlassInteractive))
            .first;

        return tester
            .widgetList<DecoratedBox>(
              find.descendant(of: button, matching: find.byType(DecoratedBox)),
            )
            .map((DecoratedBox box) => box.decoration as BoxDecoration)
            .toList();
      }

      /// The colour [control]'s mark is drawn in.
      Color captionInk(WidgetTester tester, PlWindowControl control) {
        return (tester.widget<CustomPaint>(captionMark(control)).painter! as PlWindowGlyphPainter)
            .ink;
      }

      /// The button for [control], found by its name rather than by its mark,
      /// which a traffic light at rest does not draw.
      Finder lightNamed(PlWindowControl control) {
        const Map<PlWindowControl, String> names = <PlWindowControl, String>{
          PlWindowControl.close: 'Close',
          PlWindowControl.minimize: 'Minimize',
          PlWindowControl.maximize: 'Maximize',
        };

        return find
            .ancestor(
              of: find.bySemanticsLabel(names[control]!),
              matching: find.byType(PlassInteractive),
            )
            .first;
      }

      /// What the button for [control] paints under its mark, as [captionFace]
      /// reads it.
      List<BoxDecoration> lightFace(WidgetTester tester, PlWindowControl control) {
        return tester
            .widgetList<DecoratedBox>(
              find.descendant(of: lightNamed(control), matching: find.byType(DecoratedBox)),
            )
            .map((DecoratedBox box) => box.decoration as BoxDecoration)
            .toList();
      }

      /// The shades cast inside the button for [control] past its edge, or
      /// `null` where it casts none.
      List<PlassInsetShadow>? lightInsets(WidgetTester tester, PlWindowControl control) {
        final Finder painted = find.descendant(
          of: lightNamed(control),
          matching: find.byWidgetPredicate(
            (Widget widget) => widget is CustomPaint && widget.painter is PlassInsetShadowPainter,
          ),
        );

        return painted.evaluate().isEmpty
            ? null
            : (tester.widget<CustomPaint>(painted).painter! as PlassInsetShadowPainter).shadows;
      }

      // `linear-gradient(180deg, rgb(255 255 255 / 0.6), rgb(255 255 255 /
      // 0.08) 52%, rgb(255 255 255 / 0.3))` and `inset 0 0 0 1px rgb(255 255
      // 255 / 0.55)`.
      const Gradient aeroGloss = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0x99FFFFFF), Color(0x14FFFFFF), Color(0x4DFFFFFF)],
        stops: <double>[0, 0.52, 1],
      );
      final Border aeroEdge = Border.all(color: const Color(0x8CFFFFFF));

      // `linear-gradient(180deg, rgb(255 255 255 / 0.5), rgb(255 255 255 /
      // 0.05) 55%, rgb(0 0 0 / 0.14))` and `inset 0 0 0 1px rgb(255 255 255 /
      // 0.4)`.
      const Gradient plateGloss = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0x80FFFFFF), Color(0x0DFFFFFF), Color(0x24000000)],
        stops: <double>[0, 0.55, 1],
      );
      final Border plateEdge = Border.all(color: const Color(0x66FFFFFF));

      testWidgets('draw each of Aero\'s buttons as white glass with a gloss and an edge', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const PlWindowPane(os: PlWindowOs.windows7, title: Text('Notes')));

        for (final PlWindowControl control in PlWindowControl.values) {
          final List<BoxDecoration> face = captionFace(tester, control);

          expect(face, hasLength(2), reason: control.name);
          // `rgb(255 255 255 / 0.3)`, rounded `0 0 3px 3px`.
          expect(face.first.color, const Color(0x4DFFFFFF), reason: control.name);
          expect(
            face.first.borderRadius,
            const BorderRadius.vertical(bottom: Radius.circular(3)),
            reason: control.name,
          );
          expect(face.last.gradient, aeroGloss, reason: control.name);
          expect(face.last.border, aeroEdge, reason: control.name);
        }
      });

      testWidgets('keep the face of Aero\'s minimize and maximize under the pointer, '
          'and turn its close red under the gloss', (WidgetTester tester) async {
        await _pump(tester, const PlWindowPane(os: PlWindowOs.windows7, title: Text('Notes')));

        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

        await mouse.addPointer(location: Offset.zero);
        addTearDown(mouse.removePointer);

        for (final PlWindowControl control in <PlWindowControl>[
          PlWindowControl.minimize,
          PlWindowControl.maximize,
        ]) {
          await mouse.moveTo(tester.getCenter(captionMark(control)));
          await tester.pumpAndSettle();

          // What the pointer changes on these two is how bright they are.
          expect(captionFace(tester, control).first.color, const Color(0x4DFFFFFF));
        }

        await mouse.moveTo(tester.getCenter(captionMark(PlWindowControl.close)));
        await tester.pumpAndSettle();

        final List<BoxDecoration> close = captionFace(tester, PlWindowControl.close);

        // `#e04a45`, with the mark white on it.
        expect(close.first.color, const Color(0xFFE04A45));
        expect(close.last.gradient, aeroGloss);
        expect(captionInk(tester, PlWindowControl.close), const Color(0xFFFFFFFF));
      });

      testWidgets(
        'draw XP\'s plates with a gloss and an edge, washed out behind the front window',
        (WidgetTester tester) async {
          // `#4b85d4` for minimize and maximize, and `#cf4b36` for close.
          const Map<PlWindowControl, Color> own = <PlWindowControl, Color>{
            PlWindowControl.minimize: Color(0xFF4B85D4),
            PlWindowControl.maximize: Color(0xFF4B85D4),
            PlWindowControl.close: Color(0xFFCF4B36),
          };

          await _pump(tester, const PlWindowPane(os: PlWindowOs.windowsxp, title: Text('Notes')));

          for (final PlWindowControl control in PlWindowControl.values) {
            final List<BoxDecoration> face = captionFace(tester, control);

            expect(face, hasLength(2), reason: control.name);
            expect(face.first.color, own[control], reason: control.name);
            // One more than the box in the glyph, as the React plate is.
            expect(face.first.borderRadius, BorderRadius.circular(4), reason: control.name);
            expect(face.last.gradient, plateGloss, reason: control.name);
            expect(face.last.border, plateEdge, reason: control.name);
          }

          await _pump(
            tester,
            const PlWindowPane(os: PlWindowOs.windowsxp, title: Text('Notes'), active: false),
          );

          for (final PlWindowControl control in PlWindowControl.values) {
            final List<BoxDecoration> face = captionFace(tester, control);

            // `color-mix(in oklab, <plate> 45%, #c6c9ce)`, mixed the way the bar
            // under it is washed out.
            expect(
              face.first.color,
              Color.lerp(own[control], const Color(0xFFC6C9CE), 0.55),
              reason: control.name,
            );
            expect(face.last.gradient, plateGloss, reason: control.name);
          }
        },
      );

      testWidgets('turn a square close button the red its own system turns it', (
        WidgetTester tester,
      ) async {
        // `#c42b1c` on Windows 11, and `#e81123` on 10 and 8, which draw the
        // same square button.
        const Map<PlWindowOs, Color> red = <PlWindowOs, Color>{
          PlWindowOs.windows11: Color(0xFFC42B1C),
          PlWindowOs.windows10: Color(0xFFE81123),
          PlWindowOs.windows8: Color(0xFFE81123),
        };

        for (final MapEntry<PlWindowOs, Color> system in red.entries) {
          await _pump(tester, PlWindowPane(os: system.key, title: const Text('Notes')));

          final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

          await mouse.addPointer(location: Offset.zero);
          await mouse.moveTo(tester.getCenter(captionMark(PlWindowControl.close)));
          await tester.pumpAndSettle();

          expect(
            captionFace(tester, PlWindowControl.close).first.color,
            system.value,
            reason: system.key.name,
          );
          expect(
            captionInk(tester, PlWindowControl.close),
            const Color(0xFFFFFFFF),
            reason: system.key.name,
          );

          await mouse.removePointer();
          await tester.pumpAndSettle();
        }
      });

      testWidgets('turn a close button red under a press with no pointer over it', (
        WidgetTester tester,
      ) async {
        const Map<PlWindowOs, Color> red = <PlWindowOs, Color>{
          PlWindowOs.windows10: Color(0xFFE81123),
          PlWindowOs.windows7: Color(0xFFE04A45),
        };

        for (final MapEntry<PlWindowOs, Color> system in red.entries) {
          await _pump(tester, PlWindowPane(os: system.key, title: const Text('Notes')));

          final Color? rest = captionFace(tester, PlWindowControl.close).first.color;

          expect(rest, isNot(system.value), reason: system.key.name);

          // A finger, which brings no hover with it, held down long enough to
          // count as a press.
          final TestGesture finger = await tester.startGesture(
            tester.getCenter(captionMark(PlWindowControl.close)),
          );

          await tester.pump(kPressTimeout);
          await tester.pumpAndSettle();

          expect(
            captionFace(tester, PlWindowControl.close).first.color,
            system.value,
            reason: system.key.name,
          );
          expect(
            captionInk(tester, PlWindowControl.close),
            const Color(0xFFFFFFFF),
            reason: system.key.name,
          );

          // Taken off without pressing it.
          await finger.cancel();
          await tester.pumpAndSettle();

          expect(
            captionFace(tester, PlWindowControl.close).first.color,
            rest,
            reason: system.key.name,
          );
        }
      });

      testWidgets('grey the traffic lights of a window that is not in front', (
        WidgetTester tester,
      ) async {
        for (final PlWindowOs os in <PlWindowOs>[PlWindowOs.macos, PlWindowOs.macosx]) {
          await _pump(tester, PlWindowPane(os: os, title: const Text('Notes')));

          for (final PlWindowControl control in PlWindowControl.values) {
            expect(
              lightFace(tester, control).first.color,
              trafficColors[control],
              reason: '${os.name} ${control.name}',
            );
          }

          await _pump(tester, PlWindowPane(os: os, title: const Text('Notes'), active: false));

          final Color ink = PlassTheme.of(tester.element(find.byType(PlWindowPane))).fg;

          for (final PlWindowControl control in PlWindowControl.values) {
            // `color-mix(in oklab, var(--plass-fg) 22%, transparent)`.
            expect(
              lightFace(tester, control).first.color,
              ink.withValues(alpha: 0.22),
              reason: '${os.name} ${control.name}',
            );
          }
        }
      });

      testWidgets('draw a traffic light\'s mark in black at 55%', (WidgetTester tester) async {
        for (final PlWindowOs os in <PlWindowOs>[PlWindowOs.macos, PlWindowOs.macosx]) {
          await _pump(tester, PlWindowPane(os: os, title: const Text('Notes')));

          final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

          await mouse.addPointer(location: Offset.zero);
          await mouse.moveTo(tester.getCenter(lightNamed(PlWindowControl.close)));
          await tester.pumpAndSettle();

          // `rgb(0 0 0 / 0.55)`.
          expect(
            captionInk(tester, PlWindowControl.close),
            const Color(0x8C000000),
            reason: os.name,
          );

          await mouse.removePointer();
          await tester.pumpAndSettle();
        }
      });

      testWidgets('draw Aqua\'s lights with a highlight, a ring and a shade in the foot', (
        WidgetTester tester,
      ) async {
        // `radial-gradient(circle at 50% 26%, rgb(255 255 255 / 0.8), rgb(255
        // 255 255 / 0) 62%)`, which reaches the corner of the light's square
        // farthest from its centre, √(0.5² + 0.74²) of its side away.
        final Gradient aquaGloss = RadialGradient(
          center: const Alignment(0, -0.48),
          radius: math.sqrt(0.5 * 0.5 + 0.74 * 0.74),
          colors: const <Color>[Color(0xCCFFFFFF), Color(0x00FFFFFF)],
          stops: const <double>[0, 0.62],
        );
        // `inset 0 0 0 1px rgb(0 0 0 / 0.22)`.
        final Border aquaRing = Border.all(color: const Color(0x38000000));
        // `inset 0 -1px 1px rgb(0 0 0 / 0.15)`.
        const List<PlassInsetShadow> aquaFoot = <PlassInsetShadow>[
          PlassInsetShadow(color: Color(0x26000000), offset: Offset(0, -1), blur: 1),
        ];

        for (final bool active in <bool>[true, false]) {
          await _pump(
            tester,
            PlWindowPane(os: PlWindowOs.macosx, title: const Text('Notes'), active: active),
          );

          for (final PlWindowControl control in PlWindowControl.values) {
            final String reason = '${control.name}, ${active ? 'in front' : 'behind'}';
            final List<BoxDecoration> face = lightFace(tester, control);

            expect(face, hasLength(2), reason: reason);
            expect(face.last.gradient, aquaGloss, reason: reason);
            expect(face.last.border, aquaRing, reason: reason);
            expect(lightInsets(tester, control), aquaFoot, reason: reason);
          }
        }

        // The flat lights have none of it.
        await _pump(tester, const PlWindowPane(os: PlWindowOs.macos, title: Text('Notes')));

        for (final PlWindowControl control in PlWindowControl.values) {
          expect(lightFace(tester, control), hasLength(1), reason: control.name);
          expect(lightInsets(tester, control), isNull, reason: control.name);
        }
      });

      testWidgets(
        'light every traffic light\'s mark while the pointer is over the set, easing it',
        (WidgetTester tester) async {
          await _pump(tester, const PlWindowPane(os: PlWindowOs.macos, title: Text('Notes')));

          final PlassTokens tokens = PlassTheme.of(tester.element(find.byType(PlWindowPane)));
          final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

          await mouse.addPointer(location: Offset.zero);
          addTearDown(mouse.removePointer);
          await tester.pump();

          for (final PlWindowControl control in PlWindowControl.values) {
            expect(_markShown(tester, control), 0, reason: control.name);
          }

          // On one light, and all three answer, part of the way at half the
          // house duration, as the React marks' `opacity` eases.
          await mouse.moveTo(tester.getCenter(lightNamed(PlWindowControl.close)));
          await tester.pump();
          await tester.pump(tokens.motionDuration ~/ 2);

          for (final PlWindowControl control in PlWindowControl.values) {
            expect(
              _markShown(tester, control),
              moreOrLessEquals(tokens.motionEase.transform(0.5), epsilon: 0.01),
              reason: control.name,
            );
          }

          await tester.pumpAndSettle();

          for (final PlWindowControl control in PlWindowControl.values) {
            expect(_markShown(tester, control), 1, reason: control.name);
          }

          // Between two lights is still over the set.
          final Rect close = tester.getRect(lightNamed(PlWindowControl.close));
          final Rect minimize = tester.getRect(lightNamed(PlWindowControl.minimize));

          await mouse.moveTo(Offset((close.right + minimize.left) / 2, close.center.dy));
          await tester.pumpAndSettle();

          for (final PlWindowControl control in PlWindowControl.values) {
            expect(_markShown(tester, control), 1, reason: control.name);
          }

          // Off the set, and all three go again.
          await mouse.moveTo(Offset.zero);
          await tester.pumpAndSettle();

          for (final PlWindowControl control in PlWindowControl.values) {
            expect(_markShown(tester, control), 0, reason: control.name);
          }
        },
      );

      testWidgets('light the traffic lights\' marks at once under reduced motion', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = const Size(600, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          host(
            const PlWindowPane(os: PlWindowOs.macosx, title: Text('Notes')),
            width: 420,
            disableAnimations: true,
          ),
        );
        await tester.pumpAndSettle();

        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

        await mouse.addPointer(location: Offset.zero);
        addTearDown(mouse.removePointer);
        await tester.pump();

        await mouse.moveTo(tester.getCenter(lightNamed(PlWindowControl.maximize)));
        await tester.pump();

        for (final PlWindowControl control in PlWindowControl.values) {
          expect(_markShown(tester, control), 1, reason: control.name);
        }

        await mouse.moveTo(Offset.zero);
        await tester.pump();

        for (final PlWindowControl control in PlWindowControl.values) {
          expect(_markShown(tester, control), 0, reason: control.name);
        }
      });

      testWidgets(
        'rest a GNOME button at the hover wash and deepen it under the pointer and a press',
        (WidgetTester tester) async {
          for (final bool accent in <bool>[false, true]) {
            await _pump(
              tester,
              PlWindowPane(os: PlWindowOs.linux, title: const Text('Notes'), accent: accent),
            );

            final Color ink = PlassTheme.of(tester.element(find.byType(PlWindowPane))).fg;
            // `--p-window-hover` and `--p-window-press`: the page's ink at 9% and
            // 16%, or white at 0.18 and 0.28 on an `accent` bar.
            final Color hover = accent ? const Color(0x2EFFFFFF) : ink.withValues(alpha: 0.09);
            final Color press = accent ? const Color(0x47FFFFFF) : ink.withValues(alpha: 0.16);

            for (final PlWindowControl control in PlWindowControl.values) {
              final String reason = '${control.name}${accent ? ', accent' : ''}';

              expect(lightFace(tester, control).first.color, hover, reason: reason);

              final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

              await mouse.addPointer(location: Offset.zero);
              await mouse.moveTo(tester.getCenter(lightNamed(control)));
              await tester.pumpAndSettle();

              expect(lightFace(tester, control).first.color, press, reason: reason);

              await mouse.removePointer();
              await tester.pumpAndSettle();

              expect(lightFace(tester, control).first.color, hover, reason: reason);

              // A finger, which brings no hover with it.
              final TestGesture finger = await tester.startGesture(
                tester.getCenter(lightNamed(control)),
              );

              await tester.pump(kPressTimeout);
              await tester.pumpAndSettle();

              expect(lightFace(tester, control).first.color, press, reason: reason);

              await finger.cancel();
              await tester.pumpAndSettle();
            }
          }
        },
      );

      testWidgets(
        'wash a square minimize and maximize deeper under a press than under the pointer',
        (WidgetTester tester) async {
          for (final bool accent in <bool>[false, true]) {
            await _pump(
              tester,
              PlWindowPane(os: PlWindowOs.windows11, title: const Text('Notes'), accent: accent),
            );

            final Color ink = PlassTheme.of(tester.element(find.byType(PlWindowPane))).fg;
            final Color hover = accent ? const Color(0x2EFFFFFF) : ink.withValues(alpha: 0.09);
            final Color press = accent ? const Color(0x47FFFFFF) : ink.withValues(alpha: 0.16);

            for (final PlWindowControl control in <PlWindowControl>[
              PlWindowControl.minimize,
              PlWindowControl.maximize,
            ]) {
              final String reason = '${control.name}${accent ? ', accent' : ''}';
              final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

              await mouse.addPointer(location: Offset.zero);
              await mouse.moveTo(tester.getCenter(captionMark(control)));
              await tester.pumpAndSettle();

              expect(captionFace(tester, control).first.color, hover, reason: reason);

              // Pressed with the pointer on it: the press is what shows, as the
              // React button's `active:` comes after its `hover:`.
              await mouse.down(tester.getCenter(captionMark(control)));
              await tester.pump(kPressTimeout);
              await tester.pumpAndSettle();

              expect(captionFace(tester, control).first.color, press, reason: reason);

              await mouse.cancel();
              await mouse.removePointer();
              await tester.pumpAndSettle();

              // And by a finger, which brings no hover with it.
              final TestGesture finger = await tester.startGesture(
                tester.getCenter(captionMark(control)),
              );

              await tester.pump(kPressTimeout);
              await tester.pumpAndSettle();

              expect(captionFace(tester, control).first.color, press, reason: reason);

              await finger.cancel();
              await tester.pumpAndSettle();

              expect(
                captionFace(tester, control).first.color,
                const Color(0x00000000),
                reason: reason,
              );
            }
          }
        },
      );
    });

    group('a double tap on the title bar', () {
      const Set<PlWindowControl> all = <PlWindowControl>{
        PlWindowControl.minimize,
        PlWindowControl.maximize,
        PlWindowControl.close,
      };

      /// What the window last asked to be, and how often its minimize button
      /// was pressed.
      late bool maximized;
      late int minimizes;

      /// A window whose `maximized` is fed back, inside whatever [wrap] puts it
      /// in.
      Future<void> pumpWindow(
        WidgetTester tester, {
        bool draggable = false,
        Set<PlWindowControl> controls = all,
        Widget Function(Widget pane) wrap = _asIs,
      }) async {
        maximized = false;
        minimizes = 0;

        await _pumpFree(
          tester,
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => wrap(
              PlWindowPane(
                title: const Text('Notes'),
                width: 300,
                draggable: draggable,
                controls: controls,
                maximized: maximized,
                onMaximizedChanged: (bool value) => setState(() => maximized = value),
                onMinimizedChanged: (bool value) => minimizes += 1,
              ),
            ),
          ),
        );
      }

      /// Two taps on [target], as close together as a hand makes them.
      Future<void> doubleTap(WidgetTester tester, Finder target) async {
        await tester.tap(target);
        await tester.pump(const Duration(milliseconds: 80));
        await tester.tap(target);
        await tester.pumpAndSettle();
      }

      testWidgets('maximizes the window and restores it, whether or not the bar drags', (
        WidgetTester tester,
      ) async {
        for (final bool draggable in <bool>[false, true]) {
          await pumpWindow(tester, draggable: draggable);
          await doubleTap(tester, find.text('Notes'));

          expect(maximized, isTrue, reason: 'draggable: $draggable');
          expect(find.bySemanticsLabel('Restore'), findsOneWidget);

          await doubleTap(tester, find.text('Notes'));

          expect(maximized, isFalse, reason: 'draggable: $draggable');
        }
      });

      testWidgets('takes two taps too far apart as two taps', (WidgetTester tester) async {
        await pumpWindow(tester);

        await tester.tap(find.text('Notes'));
        await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 50));
        await tester.tap(find.text('Notes'));
        await tester.pumpAndSettle();

        expect(maximized, isFalse);
      });

      testWidgets('does nothing on a window with no maximize button', (WidgetTester tester) async {
        await pumpWindow(
          tester,
          controls: const <PlWindowControl>{PlWindowControl.minimize, PlWindowControl.close},
        );
        await doubleTap(tester, find.text('Notes'));

        expect(maximized, isFalse);
      });

      testWidgets('leaves a press on a bar button to the button, at once and every time', (
        WidgetTester tester,
      ) async {
        await pumpWindow(tester, draggable: true);

        // Pressed the moment the finger lifts, rather than once the time for a
        // second tap has run out.
        await tester.tap(find.bySemanticsLabel('Minimize'));
        await tester.pump();

        expect(minimizes, 1);

        // And a button pressed twice is pressed twice, not a double tap on the
        // bar under it.
        await doubleTap(tester, find.bySemanticsLabel('Minimize'));

        expect(minimizes, 3);
        expect(maximized, isFalse);

        // The gap between two lights belongs to the set as well.
        final Rect minimize = tester.getRect(find.bySemanticsLabel('Minimize'));
        final Rect maximize = tester.getRect(find.bySemanticsLabel('Maximize'));
        final Offset gap = Offset((minimize.right + maximize.left) / 2, minimize.center.dy);

        expect(maximize.left, greaterThan(minimize.right));

        await tester.tapAt(gap);
        await tester.pump(const Duration(milliseconds: 80));
        await tester.tapAt(gap);
        await tester.pumpAndSettle();

        expect(maximized, isFalse);
      });

      testWidgets('leaves the drag moving the window from the first pixel', (
        WidgetTester tester,
      ) async {
        await pumpWindow(tester, draggable: true);

        final Offset before = tester.getTopLeft(find.text('Notes'));
        final TestGesture gesture = await tester.startGesture(tester.getCenter(find.text('Notes')));

        await gesture.moveBy(const Offset(6, 0));
        await tester.pump();

        expect(tester.getTopLeft(find.text('Notes')) - before, const Offset(6, 0));

        await gesture.up();
        await tester.pumpAndSettle();
      });

      testWidgets('maximizes a window that drags inside a scrolling column', (
        WidgetTester tester,
      ) async {
        await pumpWindow(
          tester,
          draggable: true,
          wrap: (Widget pane) => SizedBox(
            height: 400,
            child: SingleChildScrollView(
              child: Column(children: <Widget>[pane, const SizedBox(height: 800)]),
            ),
          ),
        );
        await doubleTap(tester, find.text('Notes'));

        expect(maximized, isTrue);
      });
    });
  });
}

Widget _asIs(Widget pane) => pane;
