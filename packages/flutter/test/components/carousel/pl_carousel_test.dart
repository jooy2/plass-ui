import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

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
  });

  final bool loop;
  final bool autoPlay;
  final bool arrows;
  final bool indicators;
  final bool frozen;
  final List<Widget> children;

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
      children: widget.children,
    );
  }
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

      testWidgets('does not start at all for a reader who asked for stillness', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const _Harness(autoPlay: true), width: 360, disableAnimations: true),
        );
        await tester.pump();

        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 0);
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
    });
  });
}
