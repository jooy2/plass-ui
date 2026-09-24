import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';

import '../../support/host.dart';

const List<Widget> _slides = <Widget>[Text('Alpha'), Text('Bravo'), Text('Charlie')];

/// A carousel wired to a variable, which is how every caller uses one.
class _Harness extends StatefulWidget {
  const _Harness({
    this.loop = true,
    this.autoPlay = false,
    this.arrows = true,
    this.indicators = true,
    this.frozen = false,
    this.children = _slides,
    this.playLabel,
    this.stopLabel,
  });

  final bool loop;
  final bool autoPlay;
  final bool arrows;
  final bool indicators;
  final bool frozen;
  final List<Widget> children;
  final String? playLabel;
  final String? stopLabel;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  int _value = 0;

  int get value => _value;

  @override
  Widget build(BuildContext context) {
    return PlCarousel(
      value: _value,
      onChanged: widget.frozen ? null : (int next) => setState(() => _value = next),
      loop: widget.loop,
      autoPlay: widget.autoPlay,
      interval: const Duration(milliseconds: 200),
      arrows: widget.arrows,
      indicators: widget.indicators,
      aspectRatio: 2,
      label: 'Gallery',
      playLabel: widget.playLabel,
      stopLabel: widget.stopLabel,
      children: widget.children,
    );
  }
}

/// Where the harness has got to.
int _valueOf(WidgetTester tester) => tester.state<_HarnessState>(find.byType(_Harness)).value;

/// The `autoPlay` button, found by what it is called right now.
Finder _toggle(String label) =>
    find.byWidgetPredicate((Widget widget) => widget is PlIconButton && widget.label == label);

/// Lets [time] pass on a playing carousel, and the travel of any turn it took.
Future<void> _wait(WidgetTester tester, [Duration time = const Duration(milliseconds: 500)]) async {
  await tester.pump(time);
  await tester.pump(PlassTokens.durationSlow);
}

void main() {
  group('PlCarousel', () {
    group('the frame', () {
      testWidgets('names itself and every slide', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const _Harness(), width: 360));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Gallery'), findsOneWidget);
        expect(find.bySemanticsLabel('Slide 1 of 3'), findsWidgets);

        handle.dispose();
      });

      testWidgets('shows one slide at a time', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(), width: 360));
        await tester.pumpAndSettle();

        expect(find.text('Alpha'), findsOneWidget);
        // A page view builds the page beside the one in view and no more, so
        // the last of three is not in the tree at all.
        expect(find.text('Charlie'), findsNothing);
      });

      testWidgets('takes a name of its own for a slide', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlCarousel(
              value: 0,
              slideLabel: (int index, int count) => 'Photo $index',
              aspectRatio: 2,
              children: _slides,
            ),
            width: 360,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Photo 1'), findsWidgets);

        handle.dispose();
      });
    });

    group('the chrome', () {
      testWidgets('draws arrows and dots by default', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const _Harness(), width: 360));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Previous slide'), findsOneWidget);
        expect(find.bySemanticsLabel('Next slide'), findsOneWidget);
        expect(find.bySemanticsLabel('Slide 2 of 3'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('drops them when it is asked to', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const _Harness(arrows: false, indicators: false), width: 360));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Next slide'), findsNothing);
        expect(find.bySemanticsLabel('Slide 2 of 3'), findsNothing);

        handle.dispose();
      });

      testWidgets('has nothing to steer with a single slide', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const _Harness(children: <Widget>[Text('Only')]), width: 360));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Next slide'), findsNothing);

        handle.dispose();
      });
    });

    group('navigation', () {
      testWidgets('moves to the next slide', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(), width: 360));
        await tester.pumpAndSettle();

        await tester.tap(find.bySemanticsLabel('Next slide'));
        await tester.pumpAndSettle();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 1);
        expect(find.text('Bravo'), findsOneWidget);
      });

      testWidgets('jumps straight to a slide from its dot', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(), width: 360));
        await tester.pumpAndSettle();

        await tester.tap(find.bySemanticsLabel('Slide 3 of 3'));
        await tester.pumpAndSettle();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 2);
      });

      testWidgets('wraps at the ends while looping', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(), width: 360));
        await tester.pumpAndSettle();

        await tester.tap(find.bySemanticsLabel('Previous slide'));
        await tester.pumpAndSettle();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 2);
      });

      testWidgets('goes inert at the ends when it does not loop', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const _Harness(loop: false), width: 360));
        await tester.pumpAndSettle();

        expect(
          tester.getSemantics(find.bySemanticsLabel('Previous slide')),
          isNot(matchesSemantics(hasEnabledState: true, isEnabled: true)),
        );

        handle.dispose();
      });

      testWidgets('a swipe reports where the reader went', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(), width: 360));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(PageView), const Offset(-300, 0));
        await tester.pumpAndSettle();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 1);
      });
    });

    group('autoPlay', () {
      testWidgets('advances on its own', (WidgetTester tester) async {
        // No `pumpAndSettle` anywhere in here: a repeating timer never settles,
        // and the test would time out waiting for a carousel that is doing
        // exactly what it was asked to.
        await tester.pumpWidget(host(const _Harness(autoPlay: true), width: 360));
        await tester.pump();

        await tester.pump(const Duration(milliseconds: 250));
        await tester.pump(PlassTokens.durationSlow);

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 1);

        // And stopped, so nothing is left ticking past the end of the test.
        await tester.pumpWidget(host(const SizedBox.shrink(), width: 360));
      });

      testWidgets('keeps advancing inside a parent that rebuilds more often than the interval', (
        WidgetTester tester,
      ) async {
        int value = 0;
        late StateSetter rebuild;

        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                rebuild = setState;

                // A new `onChanged` on every rebuild, as an inline closure is.
                return PlCarousel(
                  value: value,
                  onChanged: (int next) => setState(() => value = next),
                  autoPlay: true,
                  interval: const Duration(milliseconds: 200),
                  aspectRatio: 2,
                  label: 'Gallery',
                  children: _slides,
                );
              },
            ),
            width: 360,
          ),
        );

        // Rebuilt every 50ms for twice the interval, with no quiet stretch in
        // which a timer restarted on every rebuild could still fire.
        for (var step = 0; step < 10; step += 1) {
          rebuild(() {});
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(value, greaterThan(0));

        await tester.pumpWidget(host(const SizedBox.shrink(), width: 360));
      });

      testWidgets('starts stopped for a reader who asked for stillness', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const _Harness(autoPlay: true), width: 360, disableAnimations: true),
        );
        await tester.pump();

        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 0);

        // Stopped rather than unable to start: the button says so, and pressing
        // it is the reader asking for the motion anyway.
        await tester.tap(_toggle('Start slide show'));
        await _wait(tester);

        expect(_valueOf(tester), greaterThan(0));

        await tester.pumpWidget(host(const SizedBox.shrink(), width: 360));
      });

      testWidgets('draws a button that stops it and starts it again', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(autoPlay: true), width: 360));
        await tester.pump();

        await tester.tap(_toggle('Stop slide show'));
        await tester.pump();

        expect(_toggle('Start slide show'), findsOneWidget);

        await _wait(tester);

        expect(_valueOf(tester), 0);

        await tester.tap(_toggle('Start slide show'));
        await _wait(tester);

        expect(_toggle('Stop slide show'), findsOneWidget);
        expect(_valueOf(tester), greaterThan(0));

        await tester.pumpWidget(host(const SizedBox.shrink(), width: 360));
      });

      testWidgets('names the button through playLabel and stopLabel', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const _Harness(autoPlay: true, playLabel: 'Play', stopLabel: 'Pause'), width: 360),
        );
        await tester.pump();

        expect(find.bySemanticsLabel('Pause'), findsOneWidget);

        await tester.tap(find.bySemanticsLabel('Pause'));
        await tester.pump();

        expect(find.bySemanticsLabel('Play'), findsOneWidget);

        handle.dispose();
        await tester.pumpWidget(host(const SizedBox.shrink(), width: 360));
      });

      testWidgets('stops once the focus comes in, and stays stopped after it leaves', (
        WidgetTester tester,
      ) async {
        final slide = FocusNode();
        addTearDown(slide.dispose);

        await tester.pumpWidget(
          host(
            _Harness(
              autoPlay: true,
              children: <Widget>[
                Focus(focusNode: slide, child: const Text('Alpha')),
                const Text('Bravo'),
                const Text('Charlie'),
              ],
            ),
            width: 360,
          ),
        );
        await tester.pump();

        // One frame for the focus to move, and one for the carousel to answer.
        slide.requestFocus();
        await tester.pump();
        await tester.pump();

        expect(_toggle('Start slide show'), findsOneWidget);

        await _wait(tester);

        expect(_valueOf(tester), 0);

        // The focus leaving is not the reader asking for it to move again.
        slide.unfocus();
        await _wait(tester);

        expect(_valueOf(tester), 0);
        expect(_toggle('Start slide show'), findsOneWidget);
      });

      testWidgets('does not start again when the pointer leaves while the focus is inside', (
        WidgetTester tester,
      ) async {
        final slide = FocusNode();
        addTearDown(slide.dispose);

        await tester.pumpWidget(
          host(
            _Harness(
              autoPlay: true,
              children: <Widget>[
                Focus(focusNode: slide, child: const Text('Alpha')),
                const Text('Bravo'),
                const Text('Charlie'),
              ],
            ),
            width: 360,
          ),
        );
        await tester.pump();

        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: tester.getCenter(find.byType(PageView)));
        await tester.pump();

        slide.requestFocus();
        await tester.pump();

        await mouse.moveTo(Offset.zero);
        await _wait(tester);

        expect(_valueOf(tester), 0);

        await mouse.removePointer();
      });

      testWidgets('keeps playing while the focus is on its own button, and once play is pressed', (
        WidgetTester tester,
      ) async {
        final slide = FocusNode();
        addTearDown(slide.dispose);

        await tester.pumpWidget(
          host(
            _Harness(
              autoPlay: true,
              children: <Widget>[
                Focus(focusNode: slide, child: const Text('Alpha')),
                const Text('Bravo'),
                const Text('Charlie'),
              ],
            ),
            width: 360,
          ),
        );
        await tester.pump();

        // The first thing a keyboard reader reaches, and landing on it stops
        // nothing: it is where they stop it from.
        tester.widget<PlIconButton>(_toggle('Stop slide show')).focusNode!.requestFocus();
        await tester.pump();
        await _wait(tester);

        expect(_valueOf(tester), greaterThan(0));

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();

        expect(_toggle('Start slide show'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();

        // Started again from inside, so moving on into a slide does not stop it.
        slide.requestFocus();
        await tester.pump();

        final before = _valueOf(tester);
        await _wait(tester);

        expect(_valueOf(tester), isNot(before));
        expect(_toggle('Stop slide show'), findsOneWidget);

        await tester.pumpWidget(host(const SizedBox.shrink(), width: 360));
      });

      testWidgets('has no button when it does not play, or cannot', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(), width: 360));
        await tester.pump();

        expect(_toggle('Stop slide show'), findsNothing);

        await tester.pumpWidget(host(const _Harness(autoPlay: true, frozen: true), width: 360));
        await tester.pump();

        expect(_toggle('Stop slide show'), findsNothing);
        expect(_toggle('Start slide show'), findsNothing);
      });

      testWidgets('has nothing to advance while it is frozen', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(autoPlay: true, frozen: true), width: 360));
        await tester.pump();

        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 0);
      });
    });

    group('the dots', () {
      testWidgets('gives each dot a 24px press target around the dot it draws', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const _Harness(), width: 360));
        await tester.pumpAndSettle();

        for (final String name in <String>['Slide 1 of 3', 'Slide 2 of 3', 'Slide 3 of 3']) {
          final Size target = tester.getSize(
            find.byWidgetPredicate(
              (Widget widget) =>
                  widget is Semantics &&
                  widget.properties.button == true &&
                  widget.properties.label == name,
            ),
          );

          expect(target.width, greaterThanOrEqualTo(24), reason: name);
          expect(target.height, greaterThanOrEqualTo(24), reason: name);
        }

        // And a press on the edge of a target, well away from the dot, still
        // takes the reader there.
        final Rect third = tester.getRect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is Semantics &&
                widget.properties.button == true &&
                widget.properties.label == 'Slide 3 of 3',
          ),
        );
        await tester.tapAt(third.topCenter + const Offset(0, 2));
        await tester.pumpAndSettle();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 2);
      });

      testWidgets('grows the current one along the row rather than scaling it', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const _Harness(), width: 360));
        await tester.pumpAndSettle();

        // `AnimatedContainer` folds a width and a height into tight
        // constraints, so that is where a dot's size is read from.
        final Iterable<BoxConstraints> dots = tester
            .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
            .map((AnimatedContainer box) => box.constraints)
            .whereType<BoxConstraints>()
            .where((BoxConstraints box) => box.maxHeight == 6);

        // Every dot is the same height; only the current one is longer. The row
        // never changes height and nothing beside the current dot moves.
        expect(dots, hasLength(3));
        expect(dots.map((BoxConstraints box) => box.maxWidth).toList(), <double>[16, 6, 6]);
      });

      testWidgets('is a tab stop each, named after its slide, pressed with Enter or Space', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);

        await tester.pumpWidget(
          host(afterFocusStop(before, const _Harness(arrows: false)), width: 360),
        );
        await tester.pumpAndSettle();

        before.requestFocus();
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        expect(_focusedDot(), 'Slide 1 of 3');
        expect(_rings(tester), 1);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        expect(_focusedDot(), 'Slide 3 of 3');

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(_valueOf(tester), 2);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();

        // Still on the dot it was pressed from, with the ring still round it.
        expect(_focusedDot(), 'Slide 2 of 3');
        expect(_valueOf(tester), 1);
        expect(_rings(tester), 1);
      });

      testWidgets('leaves the tab order while the carousel is frozen', (WidgetTester tester) async {
        final FocusNode before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);

        await tester.pumpWidget(
          host(afterFocusStop(before, const _Harness(arrows: false, frozen: true)), width: 360),
        );
        await tester.pumpAndSettle();

        before.requestFocus();
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        expect(_focusedDot(), isNull);
      });
    });
  });
}

/// The name of the dot holding the focus, read off the button `Semantics` it is
/// wrapped in, or `null` when the focus is on something else.
String? _focusedDot() {
  String? name;

  FocusManager.instance.primaryFocus?.context?.visitAncestorElements((Element element) {
    final Widget widget = element.widget;

    if (widget is Semantics && widget.properties.button == true) {
      name = widget.properties.label;

      return false;
    }

    return widget is! PlCarousel;
  });

  return name;
}

/// How many focus rings are drawn.
int _rings(WidgetTester tester) {
  return tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .where((CustomPaint paint) => paint.foregroundPainter is PlassFocusRingPainter)
      .length;
}
