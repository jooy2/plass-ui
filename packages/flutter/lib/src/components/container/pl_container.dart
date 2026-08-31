/// Horizontal breathing room, and optionally a measure.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// Horizontal breathing room, and optionally a measure.
///
/// Two questions, and deliberately only two: how far the content sits from the
/// edge of the window, and how wide it is allowed to get. How the content then
/// divides itself up is a grid's question — a container holds one as happily as
/// it holds a single paragraph, and a grid needs no container around it.
///
/// ```dart
/// PlContainer(maxWidth: PlassSize.lg, child: page)
/// ```
///
/// It draws nothing, and there is no `variant`, `color` or `elevation` to make
/// it. The outermost widget on a screen is the one thing that must not decide
/// what the screen looks like: a container carrying a sheet would put a second
/// pane behind every card on it. A `PlCard` is where a sheet comes from.
class PlContainer extends StatelessWidget {
  /// Creates a container.
  const PlContainer({
    this.child,
    this.maxWidth,
    this.padded = true,
    this.size,
    this.density,
    this.centered = true,
    super.key,
  });

  /// The page.
  final Widget? child;

  /// How wide the content is allowed to get, on the same ladder the
  /// breakpoints use — `xs` 480 · `sm` 640 · `md` 768 · `lg` 1024 · `xl` 1280.
  ///
  /// **Null is the default, and it means no limit.** The React package spells
  /// that `'none'`, because a TypeScript union can carry an extra word and a
  /// missing prop already means "take the default"; Dart has `null` for exactly
  /// this and a `PlassSize` with a sixth value in it would be a second size
  /// ladder.
  ///
  /// A container's job is the gutter. A measure is a second decision, and a
  /// screen should have to ask for one.
  final PlassSize? maxWidth;

  /// The gutter. Turn it off to keep the centring and the measure without the
  /// padding — which is what a container nested inside one that already pads
  /// wants.
  final bool padded;

  /// The gutter's scale.
  ///
  /// The size of the *sheet* — it never touches a height or the type scale —
  /// and it is independent of [maxWidth], which is how wide the content gets
  /// rather than how far it sits from the edge.
  final PlassSize? size;

  /// Changes the gutter and nothing else.
  final PlassDensity? density;

  /// Centres the content once [maxWidth] is narrower than the screen. No effect
  /// while [maxWidth] is null, because there is nothing left over to centre in.
  final bool centered;

  /// The measure ladder, in logical pixels.
  ///
  /// The React package writes these in `rem` against a 16px root, and a logical
  /// pixel is that same unit — so `40rem` is 640 and a container's `sm` and a
  /// `sm:` utility in the other package are the same width.
  static const Map<PlassSize, double> _measure = <PlassSize, double>{
    PlassSize.xs: 480,
    PlassSize.sm: 640,
    PlassSize.md: 768,
    PlassSize.lg: 1024,
    PlassSize.xl: 1280,
  };

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final density = this.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

    Widget content = child ?? const SizedBox.shrink();

    if (padded) {
      // The **sheet** track and not the control one. What sits inside a
      // container is a page, and the margin a page keeps from the edge of a
      // window is the margin a card keeps around a paragraph — not the room a
      // label needs beside the edge of the key it is printed on.
      content = Padding(
        padding: EdgeInsets.symmetric(horizontal: sheetPaddingX[density]![size]!),
        child: content,
      );
    }

    // `w-full`: the content fills the width it is offered rather than
    // shrink-wrapping, which is what makes the measure a *limit* and not a
    // width. Inside the limit, so the padding is part of what is measured —
    // the same thing `box-sizing: border-box` does in the other package.
    content = SizedBox(width: double.infinity, child: content);

    if (maxWidth != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _measure[maxWidth]!),
        child: content,
      );
    }

    // `mx-auto`, and the height factor with it: a container is as tall as what
    // it holds, and an `Align` left to itself would take the whole screen.
    return Align(
      alignment: centered ? AlignmentDirectional.topCenter : AlignmentDirectional.topStart,
      heightFactor: 1,
      child: content,
    );
  }
}
