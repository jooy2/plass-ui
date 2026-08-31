/// A sheet of glass with content on it.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// A sheet of glass with content on it. The plainest surface in the library: it
/// groups things, and that is all it does.
///
/// ```dart
/// PlBox(child: Text('Everything in here is grouped, and nothing else is claimed.'))
/// ```
///
/// Everything structural — a title, a subtitle, a footer, hairlines between
/// sections — belongs to [PlCard], which is a box with those sections laid out
/// on it. What is left here is the sheet itself, and the reason it is worth
/// having on its own is that most of what a screen groups has no heading: a well
/// behind a form, a tile in a shelf, a panel round a chart.
///
/// [size] means something different here from what it means on a control, and
/// this is the one place in the library where that is true. A box is as tall as
/// what it holds, and its children bring their own typography — a container that
/// reset the type scale would render the same paragraph at two sizes depending
/// on what it was wrapped in. So [size] is the size of the **sheet**: its radius
/// and its padding, and nothing else.
///
/// The three materials say what they say everywhere else, read as a container's:
/// the sheet is never dyed, because what a box holds arrives with its own
/// colours and tinting the pane under them puts every one on a background it was
/// not chosen against. [PlassVariant.ghost] is the one to reach for inside
/// another surface, where a second bordered rectangle is a second rectangle.
class PlBox extends StatelessWidget {
  /// Creates a box.
  const PlBox({
    this.child,
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    this.padded = true,
    this.clipped = false,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// What is on the sheet.
  final Widget? child;

  /// What the sheet is made of. None of the three is dyed.
  final PlassVariant variant;

  /// The size of the **sheet** — its radius and its padding. Never a height,
  /// never the type scale.
  final PlassSize? size;

  /// Semantic colour role. It reaches the hairline and the focus rings inside
  /// and nothing else.
  final PlassColor? color;

  /// Changes the padding and nothing else.
  final PlassDensity? density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` and flat: the glass edge is what separates the box from the page.
  /// Raise it only for a surface that genuinely floats above the content around
  /// it.
  final PlassElevation elevation;

  /// Inner padding. Turn it off for content that should reach the edges — an
  /// image, a table, a list that draws its own rows.
  final bool padded;

  /// Clips what is on the sheet to the sheet's own corners.
  ///
  /// The React build has no such parameter: a browser's `overflow: hidden` is
  /// one class a caller adds, and full-bleed content that is not cut by the
  /// corner is a rectangle poking out of a rounded one. Here the clip is a
  /// widget rather than a property, so it has to be somebody's decision — and
  /// it is off by default because a clip also cuts off anything a child draws
  /// outside itself, a focus ring included.
  final bool clipped;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final density = this.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

    final tokens = PlassTheme.of(context);
    final radius = BorderRadius.circular(PlassTokens.radius[size]!);

    Widget content = child ?? const SizedBox.shrink();

    if (padded) {
      // The **sheet** track and not the control one. What sits inside a box is
      // a paragraph rather than a word, and that is a different measurement —
      // the same one a card keeps around its own body.
      content = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sheetPaddingX[density]![size]!,
          vertical: sheetPaddingY[density]![size]!,
        ),
        child: content,
      );
    }

    if (clipped) {
      content = ClipRRect(borderRadius: radius, child: content);
    }

    return PlassSurfaceBox(
      surface: sheetSurface(tokens, variant: variant, elevation: elevation),
      borderRadius: radius,
      // A sheet rather than a control, so it settles at the slower of the two
      // house durations — the same one a card and an accordion take.
      duration: PlassTokens.durationSlow,
      child: content,
    );
  }
}
