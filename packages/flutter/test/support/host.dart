/// The tree a Plass widget is put under to be tested.
///
/// Deliberately no `MaterialApp` and no `WidgetsApp`: the package imports
/// neither Material nor Cupertino, so the tests must not either. A suite that
/// passes only inside a `MaterialApp` is not testing what a consumer of this
/// package gets.
///
/// A browser test can read a class name off an element; a widget test reads the
/// render tree. So `expect(element).toHaveClass('h-10')` becomes a measurement
/// of the laid-out box and `--p-fill` becomes the [BoxDecoration] the widget
/// actually built. The *questions* stay the same questions, which is the point:
/// the two packages are one design language, and a rule that holds in one of
/// them has to hold in the other.
library;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] in the minimum a Plass widget needs: a direction to run in and
/// a brightness to read.
Widget host(
  Widget child, {
  Brightness brightness = Brightness.light,
  double? width,
  double? height,
  bool disableAnimations = false,
  TextDirection textDirection = TextDirection.ltr,
}) {
  return Directionality(
    textDirection: textDirection,
    child: MediaQuery(
      data: MediaQueryData(platformBrightness: brightness, disableAnimations: disableAnimations),
      child: Center(
        child: SizedBox(width: width, height: height, child: child),
      ),
    ),
  );
}

/// Every [BoxDecoration] under [finder], outermost first.
///
/// A Plass surface is two boxes — the one carrying the drop shadows and the one
/// carrying the fill — plus whatever the component stacked on top. Asking for
/// them as a list rather than by index keeps a test that wants "the one with a
/// gradient" from having to know how many there are.
List<BoxDecoration> decorationsOf(WidgetTester tester, Finder finder) {
  return <BoxDecoration>[
    ...tester
        .widgetList<AnimatedContainer>(
          find.descendant(of: finder, matching: find.byType(AnimatedContainer), matchRoot: true),
        )
        .map((AnimatedContainer container) => container.decoration)
        .whereType<BoxDecoration>(),
    ...tester
        .widgetList<DecoratedBox>(
          find.descendant(of: finder, matching: find.byType(DecoratedBox), matchRoot: true),
        )
        .map((DecoratedBox box) => box.decoration)
        .whereType<BoxDecoration>(),
  ];
}

/// The first decoration under [finder] that [test] accepts.
BoxDecoration decorationWhere(
  WidgetTester tester,
  Finder finder,
  bool Function(BoxDecoration decoration) test,
) {
  return decorationsOf(tester, finder).firstWhere(test);
}

/// The `TextStyle` the text reading [data] was actually laid out with.
TextStyle styleOf(WidgetTester tester, String data) {
  return tester.renderObject<RenderParagraph>(find.text(data)).text.style!;
}
