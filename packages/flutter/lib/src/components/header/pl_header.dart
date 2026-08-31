/// The bar across the top of a screen.
library;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// The bar's floor: a control of the same size with air above and below it.
///
/// Its own ladder rather than [controlHeight], because a header is not a
/// control — it *holds* controls, and a bar the height of the button in it is a
/// bar with no air. `md` is 64, which is a 40 control with 12 either side. The
/// air is 8 · 8 · 12 · 16 · 20, and [_barPaddingY] is the same numbers again so
/// that a bar taller than its floor keeps breathing.
const Map<PlassSize, double> _barMinHeight = <PlassSize, double>{
  PlassSize.xs: 40,
  PlassSize.sm: 48,
  PlassSize.md: 64,
  PlassSize.lg: 80,
  PlassSize.xl: 96,
};

const Map<PlassSize, double> _barPaddingY = <PlassSize, double>{
  PlassSize.xs: 8,
  PlassSize.sm: 8,
  PlassSize.md: 12,
  PlassSize.lg: 16,
  PlassSize.xl: 20,
};

/// Between the brand, the middle and the actions — about twice the gap *inside*
/// a slot, and a separate ladder for that reason.
///
/// The three slots are three regions, and a region needs to read as one. With a
/// single gap doing both jobs the first navigation link sits as far from the
/// logo as the logo sits from its own name, so the eye groups the wrong things
/// and the bar reads as one undifferentiated row.
const Map<PlassSize, double> _barGap = <PlassSize, double>{
  PlassSize.xs: 12,
  PlassSize.sm: 16,
  PlassSize.md: 24,
  PlassSize.lg: 28,
  PlassSize.xl: 32,
};

/// The measure, on [PlContainer]'s ladder so the two line up on one edge.
const Map<PlassSize, double> _maxWidth = <PlassSize, double>{
  PlassSize.xs: 480,
  PlassSize.sm: 640,
  PlassSize.md: 768,
  PlassSize.lg: 1024,
  PlassSize.xl: 1280,
};

/// The bar across the top of a screen.
///
/// ```dart
/// PlHeader(
///   brand: const <Widget>[Text('Acme')],
///   actions: <Widget>[PlButton(onPressed: signIn, child: const Text('Sign in'))],
///   child: navigation,
/// )
/// ```
///
/// Its three slots are parameters rather than sub-widgets, for [PlCard]'s
/// reason: the arrangement is fixed — brand, middle, actions — and what a
/// caller wants to decide is what goes in each. That the middle can be centred
/// on the bar's **own midline** is only possible because the ends are the
/// widget's to measure.
///
/// It is not a [PlToolbar] with a different name. A toolbar is a row of
/// controls anywhere on a screen and takes its height from its padding alone; a
/// header is the top of a screen, and it has a height floor, a measure, a brand
/// slot and a place in a [PlPageLayout] — none of which mean anything on a row
/// of controls beside a table.
class PlHeader extends StatelessWidget {
  /// Creates a bar.
  const PlHeader({
    this.child,
    this.brand,
    this.actions,
    this.align = PlassAlign.start,
    this.divider = true,
    this.maxWidth,
    this.padded = true,
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    this.semanticLabel,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The middle slot.
  final Widget? child;

  /// The leading slot: the logo, the product's name, the thing that is the same
  /// on every screen.
  ///
  /// A list rather than one widget because a slot is a row: the gap between a
  /// logo and the name beside it is the bar's to decide, not the caller's.
  final List<Widget>? brand;

  /// The trailing slot: the account menu, the theme switch, the call to action.
  /// End-aligned, so a pair of buttons needs no `Row` of its own.
  final List<Widget>? actions;

  /// Where the middle slot sits.
  ///
  /// [PlassAlign.center] gives **both ends an equal share** rather than centring
  /// the middle in the space left over — a logo one character longer would
  /// otherwise move the navigation, which is exactly what a reader notices
  /// between two screens of the same app.
  final PlassAlign align;

  /// Draws a hairline along the bottom edge, against the content the bar is
  /// over. On by default: a bar over a scrolling screen has content passing
  /// underneath it at every moment, and a translucent sheet with nothing
  /// marking its edge reads as part of that.
  final bool divider;

  /// Holds the row of slots to a measure and centres it, while the sheet itself
  /// still spans the width it was given.
  ///
  /// `null` is no measure, which is the default. The ladder is [PlContainer]'s,
  /// so a header and the container under it line up on the same edge.
  final PlassSize? maxWidth;

  /// The gutter down each side of the row.
  final bool padded;

  /// What the sheet is made of. Never dyed — what is on the bar arrives with
  /// colours of its own.
  final PlassVariant variant;

  /// The bar's height floor, its gutter and the air around its slots. As on
  /// [PlBox], `size` here is the size of the *sheet*.
  final PlassSize? size;

  /// Semantic colour role. It reaches the focus rings inside and nothing else.
  final PlassColor? color;

  /// Changes the gutter and nothing else.
  final PlassDensity? density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` and flat: a header is attached to the top of the screen rather than
  /// floating over the middle of it, and [divider] is what separates it from
  /// the content.
  final PlassElevation elevation;

  /// The name a screen reader gives the bar.
  ///
  /// Naming it also makes it a landmark: with a name the bar is a
  /// [SemanticsRole.region], and without one it claims nothing. That is the
  /// framework's rule rather than this package's — a region with no label
  /// describes nothing, and Flutter has no `banner` role to fall back on.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final density = this.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

    final PlassTokens tokens = PlassTheme.of(context);
    final double slotGap = sheetSectionGap[size]!;
    final bool centred = align == PlassAlign.center;

    Widget slot(List<Widget> children, MainAxisAlignment alignment) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        spacing: slotGap,
        children: children,
      );
    }

    final bool hasBrand = brand != null && brand!.isNotEmpty;
    final bool hasActions = actions != null && actions!.isNotEmpty;
    final Widget middle = child ?? const SizedBox.shrink();

    // Centred, both ends take an equal share by construction and the middle
    // takes its own width in the space between them — so the middle lands on
    // the bar's own midline whatever is in the ends, and an empty end still
    // takes its half. `MainAxisAlignment.center` is what splits whatever the
    // middle did not use evenly across the two sides, which is the whole of why
    // the arrangement is exact rather than nearly right.
    //
    // Packed, the ends are as wide as they are and the middle takes the rest,
    // which is the arrangement of an application's bar.
    final Widget row = centred
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: _barGap[size]!,
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  // `heightFactor` so the end is as tall as what is in it: an
                  // `Align` left to itself fills the cross axis, and a bar with
                  // three of those in it is as tall as the screen.
                  heightFactor: 1,
                  child: hasBrand ? slot(brand!, MainAxisAlignment.start) : const SizedBox.shrink(),
                ),
              ),
              Flexible(child: middle),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  heightFactor: 1,
                  child: hasActions
                      ? slot(actions!, MainAxisAlignment.end)
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          )
        : Row(
            spacing: _barGap[size]!,
            children: <Widget>[
              if (hasBrand) slot(brand!, MainAxisAlignment.start),
              Expanded(
                child: Align(
                  alignment: align == PlassAlign.end
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  heightFactor: 1,
                  child: middle,
                ),
              ),
              if (hasActions) slot(actions!, MainAxisAlignment.end),
            ],
          );

    Widget bar = ConstrainedBox(
      constraints: BoxConstraints(minHeight: _barMinHeight[size]!),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: padded ? sheetPaddingX[density]![size]! : 0,
          vertical: _barPaddingY[size]!,
        ),
        child: row,
      ),
    );

    if (maxWidth != null) {
      bar = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _maxWidth[maxWidth]!),
          child: bar,
        ),
      );
    }

    if (divider) {
      // The rule faces the content. `divider` and not the sheet's own white
      // edge line: this is a mark the sheet makes on *itself*, and white light
      // on a cut edge only reads when the screen wash is behind it.
      bar = DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: tokens.divider, width: hairline),
          ),
        ),
        child: bar,
      );
    }

    bar = PlassSurfaceBox(
      // A bar spans an edge of the screen, and a rounded corner against the
      // edge of the screen is a gap with nothing behind it.
      surface: sheetSurface(tokens, variant: variant, elevation: elevation),
      borderRadius: BorderRadius.zero,
      duration: PlassTokens.durationSlow,
      child: bar,
    );

    if (semanticLabel == null) {
      return bar;
    }

    return Semantics(
      role: SemanticsRole.region,
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: bar,
    );
  }
}
