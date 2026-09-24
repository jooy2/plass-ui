import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/animate.dart';

import '../support/host.dart';

/// The opacity the fade under test is painting with.
double opacityOf(WidgetTester tester) {
  return tester
      .widget<Opacity>(
        find.descendant(of: find.byType(PlAnimateFade), matching: find.byType(Opacity)),
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
}) {
  final Widget fade = PlAnimateFade(
    trigger: PlassAnimateTrigger.visible,
    once: once,
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
          .widgetList<Opacity>(find.descendant(of: of, matching: find.byType(Opacity)))
          .any((Opacity opacity) => opacity.opacity == 0);
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
