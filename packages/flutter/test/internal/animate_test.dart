import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/internal/surface.dart';

import '../support/host.dart';

/// The opacity the fade under test is painting with.
double opacityOf(WidgetTester tester) {
  return tester
      .widget<PlassFiltered>(
        find.descendant(of: find.byType(PlAnimateFade), matching: find.byType(PlassFiltered)),
      )
      .opacity;
}

/// Whether the gate under the fade has let it go.
bool startedOf(WidgetTester tester) {
  return tester.state<PlassAnimateGateState>(find.byType(PlassAnimateGate)).started;
}

/// A page that scrolls down, 400 tall, with a row that scrolls sideways at its
/// far end and a fade [along] pixels into that row.
///
/// The row is 1000 pixels down, so the page has to scroll 700 to bring all of
/// it up. The row shows 300 pixels of itself.
Widget pageWithRow({
  required ScrollController page,
  ScrollController? row,
  double along = 0,
  bool once = true,
  double threshold = defaultVisibleThreshold,
}) {
  final Widget fade = PlAnimateFade(
    trigger: PlassAnimateTrigger.visible,
    once: once,
    threshold: threshold,
    duration: const Duration(milliseconds: 200),
    child: const SizedBox.square(dimension: 100),
  );

  return host(
    SingleChildScrollView(
      controller: page,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 1000),
          SizedBox(
            height: 100,
            child: SingleChildScrollView(
              controller: row,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  SizedBox(width: along),
                  fade,
                  const SizedBox(width: 600),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    width: 300,
    height: 400,
  );
}

/// The turn the rotation under test is carrying, in degrees.
double turnOf(WidgetTester tester) {
  final Matrix4 m = tester
      .widget<Transform>(
        find.descendant(
          of: find.byType(PlAnimateRotate, skipOffstage: false),
          matching: find.byType(Transform, skipOffstage: false),
        ),
      )
      .transform;

  return math.atan2(m.storage[1], m.storage[0]) * 180 / math.pi;
}

/// The gate under the rotation.
PlassAnimateGateState gateOf(WidgetTester tester) {
  return tester.state<PlassAnimateGateState>(find.byType(PlassAnimateGate, skipOffstage: false));
}

/// A quarter turn a second, at an even pace, for ever unless [repeat] says
/// otherwise, and back again on every other pass with [alternate].
Widget spin({
  int? repeat,
  bool alternate = false,
  bool paused = false,
  PlassAnimateTrigger trigger = PlassAnimateTrigger.mount,
  bool once = true,
  Duration duration = const Duration(seconds: 1),
}) {
  return PlAnimateRotate(
    from: 0,
    to: 90,
    fade: false,
    curve: Curves.linear,
    duration: duration,
    repeat: repeat,
    alternate: alternate,
    paused: paused,
    trigger: trigger,
    once: once,
    child: const SizedBox.square(dimension: 100),
  );
}

void main() {
  group('the hover trigger', () {
    testWidgets('adds no stop to the tab order around content that takes no focus', (
      WidgetTester tester,
    ) async {
      final FocusNode before = FocusNode();
      final FocusNode after = FocusNode();

      addTearDown(before.dispose);
      addTearDown(after.dispose);

      await tester.pumpWidget(
        host(
          afterFocusStop(
            before,
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const PlAnimateFade(
                  trigger: PlassAnimateTrigger.hover,
                  child: SizedBox.square(dimension: 40),
                ),
                Focus(focusNode: after, child: const SizedBox.square(dimension: 1)),
              ],
            ),
          ),
        ),
      );

      before.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // A picture with a hover effect is still a picture. One Tab goes past it.
      expect(after.hasPrimaryFocus, isTrue);
    });

    testWidgets('puts no focusable node on the semantics tree', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          const PlAnimateFade(
            trigger: PlassAnimateTrigger.hover,
            child: SizedBox.square(dimension: 40),
          ),
        ),
      );

      // A focusable node with nothing inside to name it is read out as an
      // unlabelled stop.
      expect(find.semantics.byFlag(SemanticsFlag.isFocusable), findsNothing);

      handle.dispose();
    });

    testWidgets('starts when the focus lands on something inside it', (WidgetTester tester) async {
      final FocusNode inside = FocusNode();

      addTearDown(inside.dispose);

      await tester.pumpWidget(
        host(
          PlAnimateFade(
            trigger: PlassAnimateTrigger.hover,
            duration: const Duration(milliseconds: 200),
            child: Focus(focusNode: inside, child: const SizedBox.square(dimension: 40)),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 400));

      expect(opacityOf(tester), 0);

      inside.requestFocus();
      await tester.pumpAndSettle();

      expect(opacityOf(tester), 1);
    });

    testWidgets('still starts under a mouse', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateFade(
            trigger: PlassAnimateTrigger.hover,
            duration: Duration(milliseconds: 200),
            child: SizedBox.square(dimension: 40),
          ),
        ),
      );

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

      addTearDown(mouse.removePointer);

      await mouse.addPointer(location: Offset.zero);
      await tester.pump();

      expect(opacityOf(tester), 0);

      await mouse.moveTo(tester.getCenter(find.byType(PlAnimateFade)));
      await tester.pumpAndSettle();

      expect(opacityOf(tester), 1);
    });
  });

  group('the visible trigger', () {
    testWidgets('waits for the page to bring up a row that already shows it', (
      WidgetTester tester,
    ) async {
      final ScrollController page = ScrollController();

      addTearDown(page.dispose);

      await tester.pumpWidget(pageWithRow(page: page));
      await tester.pump();

      // In view along the row, and still 600 pixels below the bottom of the
      // page. A counter here would already be counting where nobody can see it.
      //
      // Asked of the gate rather than read off the opacity: a run let go at the
      // end of this frame has not drawn anything yet.
      expect(startedOf(tester), isFalse);

      page.jumpTo(700);
      await tester.pumpAndSettle();

      expect(opacityOf(tester), 1);
    });

    testWidgets('waits for the row as well, once the page has brought it up', (
      WidgetTester tester,
    ) async {
      final ScrollController page = ScrollController();
      final ScrollController row = ScrollController();

      addTearDown(page.dispose);
      addTearDown(row.dispose);

      await tester.pumpWidget(pageWithRow(page: page, row: row, along: 400));

      page.jumpTo(700);
      await tester.pump();

      expect(startedOf(tester), isFalse);

      row.jumpTo(300);
      await tester.pumpAndSettle();

      expect(opacityOf(tester), 1);
    });

    testWidgets('waits with a threshold of 0 until a pixel of it is in view', (
      WidgetTester tester,
    ) async {
      final ScrollController page = ScrollController();

      addTearDown(page.dispose);

      await tester.pumpWidget(pageWithRow(page: page, threshold: 0));
      await tester.pump();

      // None of it is on the screen, which is a share of 0, and 0 is not a
      // reason to start something 600 pixels below the bottom of the page.
      expect(startedOf(tester), isFalse);

      page.jumpTo(601);
      await tester.pump();

      expect(startedOf(tester), isTrue);
    });

    testWidgets('lets go again when the page takes it out of view, with once off', (
      WidgetTester tester,
    ) async {
      final ScrollController page = ScrollController();

      addTearDown(page.dispose);

      await tester.pumpWidget(pageWithRow(page: page, once: false));

      page.jumpTo(700);
      await tester.pump();

      expect(startedOf(tester), isTrue);

      page.jumpTo(0);
      await tester.pump();

      expect(startedOf(tester), isFalse);
    });

    testWidgets('holds the frame it was on while it is out of view, with once off', (
      WidgetTester tester,
    ) async {
      final ScrollController page = ScrollController();

      addTearDown(page.dispose);

      await tester.pumpWidget(pageWithRow(page: page, once: false));

      page.jumpTo(700);
      await tester.pumpAndSettle();

      expect(opacityOf(tester), 1);

      page.jumpTo(0);
      await tester.pumpAndSettle();

      // As a keyframe that is let go of holds its frame in the React build.
      // Only the effects that draw their frames themselves, a counter and a
      // scramble, go back to their first frame there.
      expect(startedOf(tester), isFalse);
      expect(opacityOf(tester), 1);
    });

    testWidgets('starts in a list once the last step of a scroll has been laid out', (
      WidgetTester tester,
    ) async {
      final ScrollController page = ScrollController();

      addTearDown(page.dispose);

      await tester.pumpWidget(
        host(
          ListView(
            controller: page,
            children: <Widget>[
              const SizedBox(height: 1000),
              PlAnimateFade(
                trigger: PlassAnimateTrigger.visible,
                threshold: 0,
                duration: const Duration(milliseconds: 200),
                child: const SizedBox.square(dimension: 100),
              ),
              const SizedBox(height: 1000),
            ],
          ),
          width: 300,
          height: 400,
        ),
      );

      // Built by the list ahead of the screen, 50 pixels below the bottom of it.
      page.jumpTo(550);
      await pumpScrolled(tester);

      expect(gateOf(tester).started, isFalse);

      page.jumpTo(700);
      await pumpScrolled(tester);

      // A list places its items when it lays out, after it has told its
      // listeners it moved. Measured as it moved, this step was read where the
      // step before had left it, and the fade waited for the next scroll.
      expect(gateOf(tester).started, isTrue);
    });

    testWidgets('follows the scrollables above it when it is moved under others', (
      WidgetTester tester,
    ) async {
      final GlobalKey key = GlobalKey();
      final ScrollController first = ScrollController();
      final ScrollController second = ScrollController();

      addTearDown(first.dispose);
      addTearDown(second.dispose);

      Widget pages({required bool moved}) {
        final Widget fade = PlAnimateFade(
          key: key,
          trigger: PlassAnimateTrigger.visible,
          duration: const Duration(milliseconds: 200),
          child: const SizedBox.square(dimension: 100),
        );
        const Widget gap = SizedBox.square(dimension: 100);

        Widget page(ScrollController controller, Widget end) {
          return SizedBox(
            width: 150,
            height: 400,
            child: SingleChildScrollView(
              controller: controller,
              child: Column(children: <Widget>[const SizedBox(height: 1000), end]),
            ),
          );
        }

        return host(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[page(first, moved ? gap : fade), page(second, moved ? fade : gap)],
          ),
        );
      }

      await tester.pumpWidget(pages(moved: false));
      await tester.pumpWidget(pages(moved: true));
      await tester.pump(const Duration(milliseconds: 400));

      expect(opacityOf(tester), 0);

      second.jumpTo(700);
      await tester.pumpAndSettle();

      expect(opacityOf(tester), 1);
    });
  });

  group('an endless effect off screen', () {
    testWidgets('rests while it is scrolled out of view, and goes on from the frame it was on', (
      WidgetTester tester,
    ) async {
      final ScrollController page = ScrollController();

      addTearDown(page.dispose);

      await tester.pumpWidget(scrollingPage(page, spin()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      final double before = turnOf(tester);

      expect(before, closeTo(22.5, 0.01));

      page.jumpTo(600);
      await pumpScrolled(tester);

      // Nothing is drawn for a turn nobody can see. It used to ask for every
      // frame the screen showed, for as long as the page was open.
      expect(gateOf(tester).resting, isTrue);
      expect(await redrawsIn(tester), isFalse);
      expect(turnOf(tester), before);

      page.jumpTo(0);
      await pumpScrolled(tester);

      expect(gateOf(tester).resting, isFalse);
      expect(turnOf(tester), before);

      await tester.pump(const Duration(milliseconds: 100));

      // From the frame it stopped on, at the pace it was going.
      expect(turnOf(tester), closeTo(before + 9, 0.01));
    });

    testWidgets('keeps a finite effect running off screen, so it finishes', (
      WidgetTester tester,
    ) async {
      final ScrollController page = ScrollController();

      addTearDown(page.dispose);

      await tester.pumpWidget(scrollingPage(page, spin(repeat: 1)));
      await tester.pump();

      page.jumpTo(600);
      await pumpScrolled(tester);
      await tester.pump(const Duration(milliseconds: 500));

      expect(gateOf(tester).resting, isFalse);
      expect(tester.binding.hasScheduledFrame, isTrue);

      await tester.pumpAndSettle();

      expect(turnOf(tester), closeTo(90, 0.01));
    });

    testWidgets('rests once it is scrolled away after the visible trigger has seen it', (
      WidgetTester tester,
    ) async {
      final ScrollController page = ScrollController();

      addTearDown(page.dispose);

      await tester.pumpWidget(scrollingPage(page, spin(trigger: PlassAnimateTrigger.visible)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(gateOf(tester).started, isTrue);

      page.jumpTo(600);
      await pumpScrolled(tester);

      expect(gateOf(tester).resting, isTrue);
      expect(await redrawsIn(tester), isFalse);
    });

    testWidgets('leaves one with a visible trigger that is not once to that trigger', (
      WidgetTester tester,
    ) async {
      final ScrollController page = ScrollController();

      addTearDown(page.dispose);

      await tester.pumpWidget(
        scrollingPage(page, spin(trigger: PlassAnimateTrigger.visible, once: false)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      page.jumpTo(600);
      await pumpScrolled(tester);

      // Taken back by its trigger rather than resting, as before.
      expect(gateOf(tester).started, isFalse);
      expect(gateOf(tester).resting, isFalse);
      expect(await redrawsIn(tester), isFalse);
    });

    testWidgets('watches nothing while it is paused, and rests once it is let go off screen', (
      WidgetTester tester,
    ) async {
      final ScrollController page = ScrollController();

      addTearDown(page.dispose);

      await tester.pumpWidget(scrollingPage(page, spin(paused: true)));
      await tester.pump();

      page.jumpTo(600);
      await pumpScrolled(tester);

      // Already still, so there is nothing to rest from.
      expect(gateOf(tester).resting, isFalse);

      await tester.pumpWidget(scrollingPage(page, spin()));
      await pumpScrolled(tester);

      expect(gateOf(tester).resting, isTrue);
      expect(await redrawsIn(tester), isFalse);
    });

    testWidgets('measures a list once the last step of a scroll has been laid out', (
      WidgetTester tester,
    ) async {
      final ScrollController page = ScrollController();

      addTearDown(page.dispose);

      await tester.pumpWidget(
        host(
          ListView(
            controller: page,
            children: <Widget>[const SizedBox(height: 600), spin(), const SizedBox(height: 1000)],
          ),
          width: 300,
          height: 400,
        ),
      );
      await pumpScrolled(tester);

      // Below the bottom of the list from the start.
      expect(gateOf(tester).resting, isTrue);

      page.jumpTo(150);
      await pumpScrolled(tester);

      expect(gateOf(tester).resting, isTrue);

      page.jumpTo(300);
      await pumpScrolled(tester);

      // A list places its items when it lays out, after it has told its
      // listeners it moved. Measured as it moved, this step was read where the
      // step before had left it, and the turn rested on the screen.
      expect(gateOf(tester).resting, isFalse);
      expect(tester.binding.hasScheduledFrame, isTrue);

      page.jumpTo(0);
      await pumpScrolled(tester);

      expect(gateOf(tester).resting, isTrue);
    });
  });

  group('an alternating run on its way back', () {
    /// Turns the endless [spin] that turns back on every other pass out to 90°
    /// and a quarter of the way back again, to 67.5°.
    ///
    /// A pass ends on the first frame after its last moment rather than on it,
    /// and the next one starts on the frame after that.
    Future<void> turnBack(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1001));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(turnOf(tester), closeTo(67.5, 0.01));
    }

    testWidgets('goes on back once a pause is let go, and turns at the end of the pass', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(spin(alternate: true)));
      await turnBack(tester);

      await tester.pumpWidget(host(spin(alternate: true, paused: true)));
      await tester.pump(const Duration(milliseconds: 500));

      expect(turnOf(tester), closeTo(67.5, 0.01));

      await tester.pumpWidget(host(spin(alternate: true)));
      await tester.pump();

      expect(turnOf(tester), closeTo(67.5, 0.01));

      await tester.pump(const Duration(milliseconds: 100));

      // As a paused keyframe goes on the way it was going. It used to turn
      // round and go out again, to 76.5°.
      expect(turnOf(tester), closeTo(58.5, 0.01));

      await tester.pump(const Duration(milliseconds: 651));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // Back at the start, the next pass goes out again.
      expect(turnOf(tester), closeTo(22.5, 0.01));
    });

    testWidgets('goes on back once it is scrolled into view again', (WidgetTester tester) async {
      final ScrollController page = ScrollController();

      addTearDown(page.dispose);

      await tester.pumpWidget(scrollingPage(page, spin(alternate: true)));
      await turnBack(tester);

      page.jumpTo(600);
      await pumpScrolled(tester);

      expect(gateOf(tester).resting, isTrue);

      page.jumpTo(0);
      await pumpScrolled(tester);

      expect(turnOf(tester), closeTo(67.5, 0.01));

      await tester.pump(const Duration(milliseconds: 100));

      expect(turnOf(tester), closeTo(58.5, 0.01));
    });

    testWidgets('goes on back at the new pace when its duration changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(spin(alternate: true)));
      await turnBack(tester);

      await tester.pumpWidget(host(spin(alternate: true, duration: const Duration(seconds: 2))));
      await tester.pump();

      expect(turnOf(tester), closeTo(67.5, 0.01));

      await tester.pump(const Duration(milliseconds: 100));

      // What is left of the way back, over what is left of the new duration. It
      // used to turn round and go out again, to 72°.
      expect(turnOf(tester), closeTo(63, 0.01));

      await tester.pump(const Duration(milliseconds: 1401));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Back at the start, the next pass goes out again, at the new pace.
      expect(turnOf(tester), closeTo(22.5, 0.01));
    });
  });

  group('a run built again', () {
    /// A fade at an even pace, a pass every 200ms, built anew on every call so
    /// that pumping it builds the run again.
    Widget fade({
      required int repeat,
      required bool alternate,
      Duration delay = Duration.zero,
      bool paused = false,
    }) {
      return PlAnimateFade(
        repeat: repeat,
        alternate: alternate,
        delay: delay,
        paused: paused,
        curve: Curves.linear,
        duration: const Duration(milliseconds: 200),
        child: const SizedBox.square(dimension: 100),
      );
    }

    for (final (int repeat, bool alternate, double end) in <(int, bool, double)>[
      (2, true, 0),
      (2, false, 1),
      (3, true, 1),
      (3, false, 1),
    ]) {
      final String name = 'repeat: $repeat${alternate ? ' and alternate' : ''}';

      testWidgets('stays where it ended once it has finished, with $name', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(fade(repeat: repeat, alternate: alternate)));
        await tester.pumpAndSettle();

        expect(opacityOf(tester), end);

        await tester.pumpWidget(host(fade(repeat: repeat, alternate: alternate)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // An alternating run with an even number of passes ends at 0, where a
        // run that has not started stands, and it used to be run again from
        // there and stop at the other end.
        expect(opacityOf(tester), end);
        expect(tester.binding.hasScheduledFrame, isFalse);
      });

      testWidgets('still starts when a pause during its delay is let go, with $name', (
        WidgetTester tester,
      ) async {
        const Duration delay = Duration(milliseconds: 200);

        await tester.pumpWidget(host(fade(repeat: repeat, alternate: alternate, delay: delay)));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.pumpWidget(
          host(fade(repeat: repeat, alternate: alternate, delay: delay, paused: true)),
        );
        await tester.pump(const Duration(milliseconds: 500));

        expect(opacityOf(tester), 0);

        await tester.pumpWidget(host(fade(repeat: repeat, alternate: alternate, delay: delay)));

        // The rest of the wait, and then halfway through the first pass.
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(opacityOf(tester), closeTo(0.5, 0.01));

        await tester.pumpAndSettle();

        expect(opacityOf(tester), end);
      });
    }
  });

  group('under reduced motion', () {
    /// The turn the rotation under test is carrying, in degrees.
    double degreesOf(WidgetTester tester) {
      final Matrix4 m = tester
          .widget<Transform>(
            find.descendant(of: find.byType(PlAnimateRotate), matching: find.byType(Transform)),
          )
          .transform;

      return math.atan2(m.storage[1], m.storage[0]) * 180 / math.pi;
    }

    /// Whether anything under [of] is drawn: nothing over it is faded away and
    /// nothing is clipped away. A reveal leaves by its clip and keeps its ink.
    bool drawn(WidgetTester tester, Finder of) {
      final bool faded = tester
          .widgetList<PlassFiltered>(find.descendant(of: of, matching: find.byType(PlassFiltered)))
          .any((PlassFiltered opacity) => opacity.opacity == 0);
      final bool clipped = tester
          .widgetList<ClipRect>(find.descendant(of: of, matching: find.byType(ClipRect)))
          .any((ClipRect clip) => clip.clipper?.getClip(const Size(100, 100)).isEmpty ?? false);

      return !faded && !clipped;
    }

    testWidgets('turns to the angle it was asked to end at', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateRotate(from: 0, to: 90, fade: false, child: Text('Turning')),
          disableAnimations: true,
        ),
      );
      await tester.pump();

      expect(degreesOf(tester), closeTo(90, 0.001));
    });

    testWidgets('ends one pass of an endless turn', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateRotate(from: 0, to: 90, fade: false, repeat: null, child: Text('Turning')),
          disableAnimations: true,
        ),
      );
      await tester.pump();

      expect(degreesOf(tester), closeTo(90, 0.001));
    });

    testWidgets('shows an entrance that is waiting for its trigger', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateFade(trigger: PlassAnimateTrigger.manual, child: Text('Arriving')),
          disableAnimations: true,
        ),
      );
      await tester.pump();

      expect(opacityOf(tester), 1);
    });

    for (final (String name, Widget exit) in <(String, Widget)>[
      ('PlAnimateFade', const PlAnimateFade(mode: PlassAnimateMode.exit, child: Text('Leaving'))),
      ('PlAnimateGrow', const PlAnimateGrow(mode: PlassAnimateMode.exit, child: Text('Leaving'))),
      ('PlAnimateZoom', const PlAnimateZoom(mode: PlassAnimateMode.exit, child: Text('Leaving'))),
      ('PlAnimateSlide', const PlAnimateSlide(mode: PlassAnimateMode.exit, child: Text('Leaving'))),
      (
        'PlAnimateRotate',
        const PlAnimateRotate(mode: PlassAnimateMode.exit, child: Text('Leaving')),
      ),
      (
        'PlAnimateReveal',
        const PlAnimateReveal(mode: PlassAnimateMode.exit, child: Text('Leaving')),
      ),
    ]) {
      testWidgets('hides a $name that leaves', (WidgetTester tester) async {
        await tester.pumpWidget(host(exit, disableAnimations: true));
        await tester.pump();

        expect(drawn(tester, find.byWidget(exit)), isFalse);
      });
    }

    testWidgets('leaves an exit in place until it is let go', (WidgetTester tester) async {
      Widget fade({required bool play}) {
        return host(
          PlAnimateFade(
            mode: PlassAnimateMode.exit,
            trigger: PlassAnimateTrigger.manual,
            play: play,
            child: const Text('Leaving'),
          ),
          disableAnimations: true,
        );
      }

      await tester.pumpWidget(fade(play: false));
      await tester.pump();

      expect(opacityOf(tester), 1);

      await tester.pumpWidget(fade(play: true));
      await tester.pump();

      expect(opacityOf(tester), 0);
    });

    testWidgets('keeps an exit on screen for its delay', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateFade(
            mode: PlassAnimateMode.exit,
            delay: Duration(milliseconds: 400),
            child: Text('Leaving'),
          ),
          disableAnimations: true,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(opacityOf(tester), 1);

      await tester.pump(const Duration(milliseconds: 200));

      expect(opacityOf(tester), 0);
    });

    testWidgets('ends where an alternating run ends', (WidgetTester tester) async {
      // Out and back: the second pass runs backwards, so it finishes faded out.
      await tester.pumpWidget(
        host(
          const PlAnimateFade(alternate: true, repeat: 2, child: Text('Blinking once')),
          disableAnimations: true,
        ),
      );
      await tester.pump();

      expect(opacityOf(tester), 0);
    });

    testWidgets('stays gone when the setting arrives after an exit has run', (
      WidgetTester tester,
    ) async {
      const Widget exit = PlAnimateFade(mode: PlassAnimateMode.exit, child: Text('Leaving'));

      await tester.pumpWidget(host(exit));
      await tester.pumpAndSettle();

      expect(opacityOf(tester), 0);

      await tester.pumpWidget(host(exit, disableAnimations: true));
      await tester.pump();

      expect(opacityOf(tester), 0);

      // And when it is taken away again, nothing comes back.
      await tester.pumpWidget(host(exit));
      await tester.pumpAndSettle();

      expect(opacityOf(tester), 0);
    });
  });
}
