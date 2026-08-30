/// The sheet at the end of a screen.
library;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// The measure, on [PlContainer]'s ladder so the two line up on one edge.
const Map<PlassSize, double> _maxWidth = <PlassSize, double>{
  PlassSize.xs: 480,
  PlassSize.sm: 640,
  PlassSize.md: 768,
  PlassSize.lg: 1024,
  PlassSize.xl: 1280,
};

/// The sheet at the end of a screen.
///
/// ```dart
/// PlFooter(child: const Text('© 2026 Acme'))
/// ```
///
/// It claims [SemanticsRole.contentInfo] — the landmark a screen reader offers
/// as "the app's own information" rather than "more of the content".
///
/// **It has no slots on purpose**, which is the difference between it and
/// [PlHeader]. A header's three regions are a fixed arrangement worth writing
/// once; a footer's content is four columns on one screen and one line on the
/// next, and a widget that guessed at the arrangement would be one every second
/// app fights. What it decides is the sheet: the surface, the gutter, the
/// hairline that says the content ended, and the measure.
class PlFooter extends StatelessWidget {
  /// Creates the sheet at the end of a screen.
  const PlFooter({
    this.child,
    this.divider = true,
    this.maxWidth,
    this.padded = true,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.elevation = 0,
    this.semanticLabel,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// Everything in it.
  ///
  /// A footer's content is columns of links, a copyright line, a logo — all of
  /// it the caller's, none of it something a widget could guess at, which is
  /// why this one has slots for nothing and space for anything.
  final Widget? child;

  /// Draws a hairline along the top edge.
  ///
  /// On by default: a footer is the one sheet on a screen with content directly
  /// above it and nothing below, so the line is the whole of what says the
  /// content ended.
  final bool divider;

  /// Holds the content to a measure and centres it, while the sheet itself
  /// still spans the width it was given. `null` is no measure.
  final PlassSize? maxWidth;

  /// The gutter and the air above and below.
  final bool padded;

  /// What the sheet is made of. Never dyed — what is on a footer is links and
  /// text, and they arrive with colours of their own.
  final PlassVariant variant;

  /// The gutter and the air above and below the content. As on [PlBox], `size`
  /// here is the size of the *sheet*.
  final PlassSize size;

  /// Semantic colour role. It reaches the focus rings inside and nothing else.
  final PlassColor color;

  /// Changes the padding and nothing else.
  final PlassDensity density;

  /// Drop shadow depth, `0`–`3`. `0` and flat.
  final PlassElevation elevation;

  /// The name a screen reader gives the region.
  ///
  /// Worth writing when a screen has two footers in it — a card's own and the
  /// app's — because a landmark list that says "contentInfo" twice has told the
  /// reader which is which not at all.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    Widget content = Padding(
      padding: padded
          ? EdgeInsets.symmetric(
              horizontal: sheetPaddingX[density]![size]!,
              vertical: sheetPaddingY[density]![size]!,
            )
          : EdgeInsets.zero,
      child: child ?? const SizedBox.shrink(),
    );

    if (maxWidth != null) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _maxWidth[maxWidth]!),
          // The box fills up to the measure rather than shrinking to its
          // content, which is what `max-width` plus `margin: auto` does on the
          // other side: a one-line copyright still sits at the measure's
          // leading edge rather than in the middle of the sheet.
          child: SizedBox(width: double.infinity, child: content),
        ),
      );
    }

    if (divider) {
      // The rule faces the content, which is *above* a footer rather than below
      // it. `divider` and not the sheet's own white edge line, for the reason
      // every internal rule in the package is the neutral ink.
      content = DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: tokens.divider, width: hairline),
          ),
        ),
        child: content,
      );
    }

    final Widget sheet = PlassSurfaceBox(
      // A footer spans an edge of the screen, and a rounded corner against the
      // edge of the screen is a gap with nothing behind it.
      surface: sheetSurface(tokens, variant: variant, elevation: elevation),
      borderRadius: BorderRadius.zero,
      duration: PlassTokens.durationSlow,
      child: SizedBox(width: double.infinity, child: content),
    );

    return Semantics(
      role: SemanticsRole.contentInfo,
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: sheet,
    );
  }
}
