/// A box that keeps a proportion whatever width it is given.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How the content inside is fitted to the box.
///
/// The same four words CSS's `object-fit` uses, because the React build is
/// those four values and a nicer set of names would only make a reader map one
/// onto the other. They land on Flutter's own [BoxFit] one for one.
enum PlAspectFit {
  /// Fills the box and crops whatever does not fit. The right default for a
  /// thumbnail: one that letterboxed itself would be a thumbnail with two grey
  /// bands in it.
  cover,

  /// Fits entirely inside the box, letterboxing what is left over. For the
  /// picture whose whole subject matters — a diagram, a logo, a scan.
  contain,

  /// Stretches to the box on both axes, proportion abandoned.
  fill,

  /// Drawn at its own size, centred, and cropped by the box.
  none,
}

/// A box that keeps a proportion whatever width it is given.
///
/// It draws nothing — no sheet, no hairline, no shadow, no colour family. What
/// it does is reserve the space: a card whose picture arrives late does not
/// reflow the screen around it, and a row of thumbnails is a row of one shape.
///
/// ```dart
/// PlAspectRatio(
///   ratio: 16 / 9,
///   rounded: true,
///   child: Image(image: cover),
/// )
/// ```
///
/// [size] is the only shared axis it takes, and here it is the size of the
/// *sheet* — which step of the house radius ladder [rounded] cuts to. There is
/// no height and no type scale on a box whose whole job is a proportion, and
/// there is no `variant`, no `color` and no `elevation` either: a layout widget
/// that drew a surface would make a proportion a visual decision.
class PlAspectRatio extends StatelessWidget {
  /// Creates a box that holds [ratio].
  const PlAspectRatio({
    this.child,
    this.ratio = 1,
    this.fit,
    this.rounded = false,
    this.size,
    super.key,
  }) : assert(ratio > 0, 'ratio must be greater than zero');

  /// What the proportion holds. It is laid out to the full box.
  final Widget? child;

  /// The proportion, as width over height. `1` is a square; `16 / 9` is a
  /// video frame — written as the division, which is how Flutter states an
  /// aspect ratio everywhere else.
  final double ratio;

  /// How [child] is fitted to the box, or `null` to lay it out normally.
  ///
  /// **Null by default, where the React build defaults to `cover`.** In a
  /// browser `object-fit` is a property only a replaced element answers, so
  /// React can default it and have it quietly not reach a `<div>` full of text.
  /// Flutter has no such distinction — a fit here is a [FittedBox] around
  /// whatever the child happens to be, and one applied by default would scale a
  /// column of prose. So it is opt-in, and it applies to everything.
  ///
  /// An [Image] that already carries its own [BoxFit] needs nothing here.
  final PlAspectFit? fit;

  /// Rounds the corners to the [size] step of the house radius ladder.
  ///
  /// Off by default. A photograph with its corners cut is a decision about the
  /// photograph rather than about the box holding it — but it is such a common
  /// one that making the caller wrap this in a [ClipRRect] would be perverse.
  final bool rounded;

  /// Which step of the radius ladder [rounded] cuts to.
  final PlassSize? size;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;

    Widget? held = child;

    if (held != null && fit != null) {
      held = FittedBox(fit: boxFit(fit!), child: held);
    }

    // The box clips whatever it holds, rounded or not. Without that a `cover`
    // child spills straight out of the proportion it was just given, and the
    // widget would only be reserving space rather than holding anything to it.
    if (held != null) {
      held = rounded
          ? ClipRRect(borderRadius: BorderRadius.circular(PlassTokens.radius[size]!), child: held)
          : ClipRect(child: held);
    }

    return AspectRatio(aspectRatio: ratio, child: held);
  }

  /// The [BoxFit] a [PlAspectFit] names.
  ///
  /// Public because [PlImage] answers the same five words and must answer them
  /// the same way — two copies of a five-arm switch are two copies that drift.
  static BoxFit boxFit(PlAspectFit fit) {
    switch (fit) {
      case PlAspectFit.cover:
        return BoxFit.cover;
      case PlAspectFit.contain:
        return BoxFit.contain;
      case PlAspectFit.fill:
        return BoxFit.fill;
      case PlAspectFit.none:
        return BoxFit.none;
    }
  }
}
