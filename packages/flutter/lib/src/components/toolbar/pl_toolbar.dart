/// A bar of controls.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// Between two controls inside one slot.
const double _slotGap = 8;

/// A bar of controls: an application header, a screen's action row, the strip
/// along the bottom of an editor.
///
/// ```dart
/// PlToolbar(
///   start: const PlTypography('Reports', level: PlTypographyLevel.h6),
///   end: <Widget>[PlButton(onPressed: create, child: const Text('New'))],
/// )
/// ```
///
/// Three slots and a row. [start] and [end] are pinned to their ends and [child]
/// takes what is left, which is the arrangement every toolbar has ever had — so
/// it is laid out here rather than left to a caller and a spacer they have to
/// remember.
///
/// The one thing it does not do is take a height. A toolbar is as tall as the
/// controls in it plus its padding, and that padding is the [size] / [density]
/// pair every other surface uses — so [PlassDensity.compact] gives the dense bar
/// without a second parameter meaning the same thing, and without the type scale
/// moving.
///
/// It claims no toolbar semantics, deliberately. That role is a promise about
/// keyboard behaviour — one focus stop for the whole bar, arrow keys between the
/// controls in it — and a bar that claims it without implementing it is worse
/// for a keyboard reader than one that never claimed anything. What a genuine
/// roving-focus set of choices wants is a [PlSegmentedButton], which is one.
class PlToolbar extends StatelessWidget {
  /// Creates a bar.
  const PlToolbar({
    this.child,
    this.start,
    this.end,
    this.divider = false,
    this.side = PlassSide.top,
    this.rounded = true,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.elevation = 0,
    this.semanticLabel,
    super.key,
  }) : assert(
         side == PlassSide.top || side == PlassSide.bottom,
         'a toolbar is held against the top or the bottom, never a side',
       ),
       assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The middle. Takes whatever width [start] and [end] leave.
  final Widget? child;

  /// Pinned to the start of the bar: a logo, a title, a back button.
  final List<Widget>? start;

  /// Pinned to the end: the actions.
  final List<Widget>? end;

  /// Draws a hairline along the edge that faces the content — under a `top`
  /// bar, over a `bottom` one.
  final bool divider;

  /// Which way the bar is facing, and the one thing that depends on it: which
  /// edge the [divider] is drawn along.
  ///
  /// There is no `position` here, for the reason a floating bottom bar has none:
  /// a `fixed` element has to span something, and a Flutter widget goes exactly
  /// where the screen puts it. A bar that has to stay put belongs in the
  /// screen's own layout — this only needs to know which way it is facing.
  final PlassSide side;

  /// Whether the bar is a sheet with corners.
  ///
  /// On for a bar sitting in the layout. Turn it off for one held against an
  /// edge of the screen: a rounded corner against the edge of the screen is a
  /// gap with nothing behind it. It is the same call the React build makes off
  /// `position`, which this has no need of.
  final bool rounded;

  /// What the bar is made of. Never dyed — a toolbar holds other people's
  /// controls, and those arrive with colours of their own.
  final PlassVariant variant;

  /// The bar's padding and radius. The height is whatever the controls need.
  final PlassSize size;

  /// Semantic colour role. It reaches the focus rings inside and nothing else.
  final PlassColor color;

  /// Changes the padding and nothing else.
  final PlassDensity density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` and flat, which is right even for a bar held against an edge: a shadow
  /// under a header is a way of saying "there is content beneath this", and that
  /// is only true once the screen has been scrolled. Raise it yourself at that
  /// moment, or leave it flat and turn on [divider].
  final PlassElevation elevation;

  /// The name a screen reader gives the bar, if it needs one of its own.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final radius = PlassTokens.radius[size]!;

    // Only a bar sitting in the flow is a sheet with corners: one spanning an
    // edge of the screen has nothing behind the gap a rounded corner leaves.
    final corners = rounded ? BorderRadius.circular(radius) : BorderRadius.zero;

    final rule = BorderSide(color: tokens.divider, width: hairline);
    final surface = sheetSurface(tokens, variant: variant, elevation: elevation);

    Widget bar = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sheetPaddingX[density]![size]!,
        vertical: sheetPaddingY[density]![size]!,
      ),
      child: Row(
        spacing: sheetSectionGap[size]!,
        children: <Widget>[
          if (start != null && start!.isNotEmpty)
            Row(mainAxisSize: MainAxisSize.min, spacing: _slotGap, children: start!),
          // Expanded even when empty, so `start` and `end` stay at their ends
          // rather than collapsing together in the middle of the bar.
          Expanded(child: child ?? const SizedBox.shrink()),
          if (end != null && end!.isNotEmpty)
            Row(mainAxisSize: MainAxisSize.min, spacing: _slotGap, children: end!),
        ],
      ),
    );

    if (divider) {
      // The rule faces the content, so it moves to the other edge on a bottom
      // bar. `divider` and not the sheet's own white edge line: this is a mark
      // the sheet makes on *itself*, and white light on a cut edge only reads
      // when the screen wash is behind it.
      bar = DecoratedBox(
        decoration: BoxDecoration(
          border: side == PlassSide.top ? Border(bottom: rule) : Border(top: rule),
        ),
        child: bar,
      );
    }

    bar = PlassSurfaceBox(
      surface: surface,
      borderRadius: corners,
      duration: PlassTokens.durationSlow,
      child: bar,
    );

    return semanticLabel == null
        ? bar
        : Semantics(container: true, explicitChildNodes: true, label: semanticLabel, child: bar);
  }
}
