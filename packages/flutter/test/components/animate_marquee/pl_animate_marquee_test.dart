import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

List<Widget> get _three => const <Widget>[
  SizedBox(width: 60, height: 20),
  SizedBox(width: 60, height: 20),
];

Offset shiftOf(WidgetTester tester) {
  final Transform moved = tester.widget<Transform>(
    find.descendant(of: find.byType(PlAnimateMarquee), matching: find.byType(Transform)),
  );

  return Offset(moved.transform.storage[12], moved.transform.storage[13]);
}

void main() {
  group('PlAnimateMarquee', () {
    testWidgets('lays the content down twice, which is what closes the seam', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(PlAnimateMarquee(children: _three), width: 200, height: 40));

      // The outer flex holds the copies; each copy is a flex of the children.
      expect(find.byType(Flex), findsNWidgets(3));
    });

    testWidgets('takes more copies for content short enough to leave a hole', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(PlAnimateMarquee(copies: 4, children: _three), width: 200, height: 40),
      );

      expect(find.byType(Flex), findsNWidgets(5));
    });

    testWidgets('never draws fewer than one', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(PlAnimateMarquee(copies: 0, children: _three), width: 200, height: 40),
      );

      expect(find.byType(Flex), findsNWidgets(2));
    });

    testWidgets('reads out the first copy only', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(PlAnimateMarquee(copies: 3, children: _three), width: 200, height: 40),
      );

      expect(
        find.descendant(of: find.byType(PlAnimateMarquee), matching: find.byType(ExcludeSemantics)),
        findsNWidgets(2),
      );
    });

    testWidgets('reaches the focusable children of the first copy only', (
      WidgetTester tester,
    ) async {
      final FocusNode before = FocusNode();
      addTearDown(before.dispose);

      await tester.pumpWidget(
        host(
          afterFocusStop(
            before,
            const PlAnimateMarquee(
              copies: 3,
              children: <Widget>[
                Focus(child: SizedBox(width: 60, height: 20)),
                Focus(child: SizedBox(width: 60, height: 20)),
              ],
            ),
          ),
          width: 200,
        ),
      );

      before.requestFocus();
      await tester.pump();

      // Round the scope with Tab until the focus is back where it started. The
      // strip never settles, so each press is followed by one frame.
      int stops = 0;

      for (int press = 0; press < 12; press += 1) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        if (before.hasFocus) {
          break;
        }

        stops += 1;
      }

      expect(stops, 2);
    });

    testWidgets('lays the strip out unbounded and clips it', (WidgetTester tester) async {
      await tester.pumpWidget(host(PlAnimateMarquee(children: _three), width: 200, height: 40));

      final UnconstrainedBox box = tester.widget<UnconstrainedBox>(
        find.descendant(of: find.byType(PlAnimateMarquee), matching: find.byType(UnconstrainedBox)),
      );

      // A clip alone would clip the paint and leave the flex asserting that it
      // overflowed; the strip is longer than its box on purpose.
      expect(box.constrainedAxis, Axis.vertical);
      expect(box.clipBehavior, Clip.hardEdge);
    });

    testWidgets('travels along the strip', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlAnimateMarquee(gap: 0, speed: 100, curve: Curves.linear, children: _three),
          width: 200,
          height: 40,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(shiftOf(tester).dx, lessThan(0));
      expect(shiftOf(tester).dy, 0);
    });

    testWidgets('travels down it when it runs vertically', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlAnimateMarquee(
            orientation: PlassOrientation.vertical,
            gap: 0,
            speed: 100,
            curve: Curves.linear,
            children: _three,
          ),
          width: 200,
          height: 40,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(shiftOf(tester).dy, lessThan(0));
      expect(shiftOf(tester).dx, 0);
    });

    testWidgets('travels at the speed it was given rather than in a time', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          PlAnimateMarquee(gap: 0, speed: 60, curve: Curves.linear, children: _three),
          width: 200,
          height: 40,
        ),
      );

      // The first frame is what measures the strip; the second is what starts
      // the ticker's clock against the duration that measurement decided.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final double before = shiftOf(tester).dx;

      await tester.pump(const Duration(milliseconds: 500));

      // Half a second at 60 logical pixels a second.
      expect(before - shiftOf(tester).dx, closeTo(30, 3));
    });

    testWidgets('stands still at a speed of zero or less', (WidgetTester tester) async {
      for (final double speed in <double>[0, -60]) {
        await tester.pumpWidget(
          host(
            PlAnimateMarquee(gap: 0, speed: speed, curve: Curves.linear, children: _three),
            width: 200,
            height: 40,
          ),
        );

        // Rounding an infinite number of milliseconds threw before this. A
        // speed of nothing is not moving, so the strip is held where it is.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final double before = shiftOf(tester).dx;

        await tester.pump(const Duration(milliseconds: 500));

        expect(shiftOf(tester).dx, before);

        await tester.pumpWidget(host(const SizedBox.shrink()));
      }
    });

    testWidgets('scrolls along one copy where the platform has asked for less movement', (
      WidgetTester tester,
    ) async {
      final FocusNode before = FocusNode();
      addTearDown(before.dispose);

      await tester.pumpWidget(
        host(
          afterFocusStop(
            before,
            PlAnimateMarquee(
              gap: 0,
              children: List<Widget>.generate(10, (_) => const SizedBox(width: 60, height: 20)),
            ),
          ),
          width: 200,
          disableAnimations: true,
        ),
      );
      await tester.pump();

      expect(
        find.descendant(of: find.byType(PlAnimateMarquee), matching: find.byType(ExcludeSemantics)),
        findsNothing,
      );

      // Six hundred pixels of strip in a box two hundred wide, reached from the
      // keyboard: Tab onto the box, then End.
      before.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();

      final ScrollPosition position = tester
          .state<ScrollableState>(
            find.descendant(of: find.byType(PlAnimateMarquee), matching: find.byType(Scrollable)),
          )
          .position;

      expect(position.maxScrollExtent, 400);
      expect(position.pixels, 400);
    });

    testWidgets('scrolls down a vertical strip where the platform has asked for less movement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          PlAnimateMarquee(
            orientation: PlassOrientation.vertical,
            gap: 0,
            children: List<Widget>.generate(10, (_) => const SizedBox(width: 60, height: 20)),
          ),
          width: 200,
          height: 40,
          disableAnimations: true,
        ),
      );
      await tester.pump();

      final ScrollableState scrollable = tester.state<ScrollableState>(
        find.descendant(of: find.byType(PlAnimateMarquee), matching: find.byType(Scrollable)),
      );

      expect(scrollable.axisDirection, AxisDirection.down);
      expect(scrollable.position.maxScrollExtent, 160);
    });

    testWidgets('names the stop it becomes where the platform has asked for less movement', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final FocusNode before = FocusNode();
      addTearDown(before.dispose);

      await tester.pumpWidget(
        host(
          afterFocusStop(
            before,
            PlAnimateMarquee(
              label: 'Partners',
              gap: 0,
              children: List<Widget>.generate(10, (_) => const SizedBox(width: 60, height: 20)),
            ),
          ),
          width: 200,
          disableAnimations: true,
        ),
      );
      await tester.pump();

      before.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(
        tester.getSemantics(find.bySemanticsLabel('Partners')),
        isSemantics(label: 'Partners', isFocusable: true, isFocused: true),
      );
      handle.dispose();
    });

    testWidgets('names the strip while it moves as well', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(PlAnimateMarquee(label: 'Partners', children: _three), width: 200, height: 40),
      );

      expect(find.bySemanticsLabel('Partners'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('stands where it started where the platform has asked for less movement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(PlAnimateMarquee(children: _three), width: 200, height: 40, disableAnimations: true),
      );

      await tester.pump(const Duration(milliseconds: 600));

      expect(shiftOf(tester), Offset.zero);
    });

    group('measured on screen', () {
      /// Ten items of sixty, so one copy is 600 long and the strip of two is
      /// four times a box 300 wide.
      List<Widget> long() =>
          List<Widget>.generate(10, (_) => const SizedBox(width: 60, height: 20));

      testWidgets('starts once its box is in view, however much longer than the box the strip is', (
        WidgetTester tester,
      ) async {
        final ScrollController page = ScrollController();

        addTearDown(page.dispose);

        await tester.pumpWidget(
          scrollingPage(
            page,
            SizedBox(
              width: 300,
              height: 40,
              child: PlAnimateMarquee(
                trigger: PlassAnimateTrigger.visible,
                threshold: 0.5,
                gap: 0,
                children: long(),
              ),
            ),
          ),
        );
        await pumpScrolled(tester);
        await tester.pump(const Duration(milliseconds: 500));

        // The whole box is on screen. A quarter of the strip is, which is all
        // that was measured, so it waited for a half that could never come.
        expect(shiftOf(tester).dx, lessThan(0));
      });

      testWidgets('waits until its box is scrolled into view', (WidgetTester tester) async {
        final ScrollController page = ScrollController();

        addTearDown(page.dispose);

        await tester.pumpWidget(
          host(
            SingleChildScrollView(
              controller: page,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 600),
                  SizedBox(
                    width: 300,
                    height: 40,
                    child: PlAnimateMarquee(
                      trigger: PlassAnimateTrigger.visible,
                      gap: 0,
                      children: _three,
                    ),
                  ),
                  const SizedBox(height: 600),
                ],
              ),
            ),
            width: 300,
            height: 400,
          ),
        );
        await pumpScrolled(tester);
        await tester.pump(const Duration(milliseconds: 500));

        expect(shiftOf(tester), Offset.zero);

        page.jumpTo(400);
        await pumpScrolled(tester);
        await tester.pump(const Duration(milliseconds: 500));

        expect(shiftOf(tester).dx, lessThan(0));
      });

      testWidgets('rests once its box is scrolled out of view, where the strip still reaches', (
        WidgetTester tester,
      ) async {
        final ScrollController row = ScrollController();

        addTearDown(row.dispose);

        await tester.pumpWidget(
          host(
            SingleChildScrollView(
              controller: row,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 300,
                    height: 40,
                    child: PlAnimateMarquee(gap: 0, children: long()),
                  ),
                  const SizedBox(width: 1000, height: 40),
                ],
              ),
            ),
            width: 300,
            height: 40,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        row.jumpTo(400);
        await pumpScrolled(tester);

        // None of the box is left on screen. The strip past its end still
        // was, so it went on drawing a frame for a strip nobody could see.
        expect(await redrawsIn(tester), isFalse);
      });
    });

    testWidgets('keeps what it holds, and a strip that landed, as the setting comes and goes', (
      WidgetTester tester,
    ) async {
      Widget strip({bool still = false}) {
        return host(
          const PlAnimateMarquee(
            repeat: 1,
            duration: Duration(seconds: 1),
            children: <Widget>[_Held(), SizedBox(width: 60, height: 20)],
          ),
          width: 200,
          height: 40,
          disableAnimations: still,
        );
      }

      await tester.pumpWidget(strip());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      tester.state<_HeldState>(find.byType(_Held).first).note = 'typed';

      await tester.pumpWidget(strip(still: true));
      await tester.pump();

      expect(shiftOf(tester), Offset.zero);

      await tester.pumpWidget(strip());
      await tester.pump();

      expect(tester.state<_HeldState>(find.byType(_Held).first).note, 'typed');

      // It landed under the setting, and stays where it landed, where the
      // copy after the first stands where the first began. The run was built
      // again from scratch when the box around it changed, and set off on
      // its whole pass again.
      expect(await redrawsIn(tester), isFalse);
    });

    testWidgets('rests while it is scrolled out of view, and goes on from where the strip was', (
      WidgetTester tester,
    ) async {
      final ScrollController page = ScrollController();

      addTearDown(page.dispose);

      await tester.pumpWidget(
        scrollingPage(
          page,
          SizedBox(
            width: 200,
            height: 40,
            child: PlAnimateMarquee(curve: Curves.linear, children: _three),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final Offset before = shiftOf(tester);

      expect(before.dx, lessThan(0));

      page.jumpTo(600);
      await pumpScrolled(tester);

      // Nothing moves where nobody can see it. The strip used to be drawn again
      // for every frame the screen showed.
      expect(await redrawsIn(tester), isFalse);
      expect(shiftOf(tester), before);

      page.jumpTo(0);
      await pumpScrolled(tester);

      expect(shiftOf(tester), before);

      await tester.pump(const Duration(milliseconds: 100));

      // Six pixels on, at sixty a second, from where it stopped.
      expect(shiftOf(tester).dx, closeTo(before.dx - 6, 0.01));
    });
  });
}

/// Content with a state of its own, as a field or a list has.
class _Held extends StatefulWidget {
  const _Held();

  @override
  State<_Held> createState() => _HeldState();
}

class _HeldState extends State<_Held> {
  /// What it was given while it was on the screen.
  String? note;

  @override
  Widget build(BuildContext context) => const SizedBox(width: 60, height: 20);
}
