import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// A list taller than itself, with the button watching it.
class _Screen extends StatefulWidget {
  const _Screen({this.visibilityHeight = 400, this.onPressed});

  final double visibilityHeight;
  final VoidCallback? onPressed;

  @override
  State<_Screen> createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ListView(
          controller: _controller,
          children: <Widget>[
            for (int i = 0; i < 60; i += 1) SizedBox(height: 50, child: Text('$i')),
          ],
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: PlBackTop(
            controller: _controller,
            visibilityHeight: widget.visibilityHeight,
            onPressed: widget.onPressed,
          ),
        ),
      ],
    );
  }
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(host(child, width: 300, height: 400));
  await tester.pumpAndSettle();
}

/// The button's own fade, which is the outermost of several: a `PlIconButton`
/// has animated boxes of its own inside it.
double _opacity(WidgetTester tester) {
  return tester
      .widgetList<AnimatedOpacity>(
        find.descendant(of: find.byType(PlBackTop), matching: find.byType(AnimatedOpacity)),
      )
      .first
      .opacity;
}

/// The same, for the two widgets that take it out of reach.
T _firstUnder<T extends Widget>(WidgetTester tester) {
  return tester
      .widgetList<T>(find.descendant(of: find.byType(PlBackTop), matching: find.byType(T)))
      .first;
}

Future<void> _scrollTo(WidgetTester tester, double offset) async {
  tester.widget<ListView>(find.byType(ListView)).controller!.jumpTo(offset);
  await tester.pumpAndSettle();
}

void main() {
  group('PlBackTop', () {
    group('when it appears', () {
      testWidgets('is out of reach at the top of the screen', (WidgetTester tester) async {
        await _pump(tester, const _Screen());

        // Not merely faded: a control a reader can reach and cannot see is worse
        // than one that is not there.
        expect(_opacity(tester), equals(0));
        expect(_firstUnder<IgnorePointer>(tester).ignoring, isTrue);
        expect(_firstUnder<ExcludeSemantics>(tester).excluding, isTrue);
        expect(_firstUnder<ExcludeFocus>(tester).excluding, isTrue);
      });

      testWidgets('arrives once the reader is far enough down', (WidgetTester tester) async {
        await _pump(tester, const _Screen());
        await _scrollTo(tester, 500);

        expect(_opacity(tester), equals(1));
      });

      testWidgets('goes away again on the way back up', (WidgetTester tester) async {
        await _pump(tester, const _Screen());
        await _scrollTo(tester, 500);

        expect(_opacity(tester), equals(1));

        await _scrollTo(tester, 100);

        expect(_opacity(tester), equals(0));
      });

      testWidgets('takes its own threshold', (WidgetTester tester) async {
        await _pump(tester, const _Screen(visibilityHeight: 50));
        await _scrollTo(tester, 100);

        expect(_opacity(tester), equals(1));
      });
    });

    group('what it does', () {
      testWidgets('takes the list back to the top', (WidgetTester tester) async {
        await _pump(tester, const _Screen(visibilityHeight: 100));
        await _scrollTo(tester, 900);

        await tester.tap(find.byType(PlBackTop));
        await tester.pumpAndSettle();

        expect(tester.widget<ListView>(find.byType(ListView)).controller!.offset, equals(0));
      });

      testWidgets('runs a caller’s own press instead of scrolling', (WidgetTester tester) async {
        var pressed = false;

        await _pump(tester, _Screen(visibilityHeight: 100, onPressed: () => pressed = true));
        await _scrollTo(tester, 900);

        await tester.tap(find.byType(PlBackTop));
        await tester.pumpAndSettle();

        expect(pressed, isTrue);
        // For the screen whose "up" is somewhere other than offset zero.
        expect(tester.widget<ListView>(find.byType(ListView)).controller!.offset, equals(900));
      });
    });

    group('without a controller', () {
      /// A list with no controller of its own and the button beside it, both
      /// under the primary controller a route would put above them.
      ///
      /// [list] is the list's own `primary`, which desktop leaves off.
      Widget primary(ScrollController controller, {bool? list}) {
        return PrimaryScrollController(
          controller: controller,
          child: Stack(
            children: <Widget>[
              ListView(
                primary: list,
                children: <Widget>[
                  for (int i = 0; i < 60; i += 1) SizedBox(height: 50, child: Text('$i')),
                ],
              ),
              const Positioned(right: 8, bottom: 8, child: PlBackTop()),
            ],
          ),
        );
      }

      testWidgets('watches the primary controller on a phone', (WidgetTester tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        final ScrollController controller = ScrollController();
        addTearDown(controller.dispose);

        await _pump(tester, primary(controller));

        expect(tester.takeException(), isNull);

        controller.jumpTo(500);
        await tester.pumpAndSettle();

        expect(_opacity(tester), equals(1));

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('says so on desktop, where nothing takes that controller by itself', (
        WidgetTester tester,
      ) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

        final ScrollController controller = ScrollController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(host(primary(controller), width: 300, height: 400));

        // Silent, the list scrolls and the button never appears, because the
        // list is not attached to the controller the button is watching.
        final Object? error = tester.takeException();

        expect(error, isA<AssertionError>());
        expect(error.toString(), contains('`controller`'));

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('is quiet on desktop when a scroll view takes the primary controller itself', (
        WidgetTester tester,
      ) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

        final ScrollController controller = ScrollController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(host(primary(controller, list: true), width: 300, height: 400));
        await tester.pump();

        expect(tester.takeException(), isNull);

        controller.jumpTo(500);
        await tester.pumpAndSettle();

        expect(_opacity(tester), equals(1));

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('is quiet on desktop once it is given one', (WidgetTester tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

        await _pump(tester, const _Screen());

        expect(tester.takeException(), isNull);

        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('the name', () {
      testWidgets('says what pressing it does', (WidgetTester tester) async {
        await _pump(tester, const _Screen(visibilityHeight: 100));
        await _scrollTo(tester, 500);

        expect(find.bySemanticsLabel('Back to top'), findsOneWidget);
      });
    });
  });
}
