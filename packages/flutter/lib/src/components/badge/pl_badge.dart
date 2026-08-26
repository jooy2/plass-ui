/// A small mark in the corner of something else.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// The shape of the thing underneath, which is what decides how far the marker
/// tucks in.
enum PlBadgeOverlap {
  /// A rectangle. The marker sits half outside the corner.
  square,

  /// A circle. Its corner is further from its centre than a square's, so a
  /// badge that looks right on an avatar hangs off an icon button — this pulls
  /// the marker back in.
  circle,
}

/// A badge is smaller than anything else in the library, so it has a ladder of
/// its own rather than a step off [controlHeight].
///
/// A control's height is the number a *row* lines up on; a badge lines up on
/// nothing — it hangs off the corner of something else. `md` is 18px, which is
/// the smallest a two-digit number stays legible at.
const Map<PlassSize, double> _badgeHeight = <PlassSize, double>{
  PlassSize.xs: 14,
  PlassSize.sm: 16,
  PlassSize.md: 18,
  PlassSize.lg: 20,
  PlassSize.xl: 24,
};

/// The dot: the same ladder with the digits taken out, so it goes square.
const Map<PlassSize, double> _dotSize = <PlassSize, double>{
  PlassSize.xs: 6,
  PlassSize.sm: 8,
  PlassSize.md: 10,
  PlassSize.lg: 10,
  PlassSize.xl: 12,
};

const Map<PlassSize, double> _badgeText = <PlassSize, double>{
  PlassSize.xs: 9,
  PlassSize.sm: 10,
  PlassSize.md: 11,
  PlassSize.lg: 12,
  PlassSize.xl: 13,
};

/// Horizontal breathing room around the digits. Density is what halves it.
const Map<PlassDensity, Map<PlassSize, double>> _badgePadding =
    <PlassDensity, Map<PlassSize, double>>{
      PlassDensity.standard: <PlassSize, double>{
        PlassSize.xs: 4,
        PlassSize.sm: 4,
        PlassSize.md: 6,
        PlassSize.lg: 6,
        PlassSize.xl: 8,
      },
      PlassDensity.compact: <PlassSize, double>{
        PlassSize.xs: 2,
        PlassSize.sm: 2,
        PlassSize.md: 4,
        PlassSize.lg: 4,
        PlassSize.xl: 6,
      },
    };

/// How far the marker is pulled out of the corner, per size.
///
/// Half the marker's own height, so the vertical overhang is exactly half — and
/// horizontally a wide `99+` tucks in a little further than half, which is what
/// you want anyway.
const Map<PlassSize, double> _cornerOffset = <PlassSize, double>{
  PlassSize.xs: 6,
  PlassSize.sm: 8,
  PlassSize.md: 8,
  PlassSize.lg: 10,
  PlassSize.xl: 12,
};

/// The same, for a dot.
const Map<PlassSize, double> _dotCornerOffset = <PlassSize, double>{
  PlassSize.xs: 2,
  PlassSize.sm: 4,
  PlassSize.md: 4,
  PlassSize.lg: 4,
  PlassSize.xl: 6,
};

/// The extra inset a round anchor needs, as a fraction of its box.
///
/// A circle's corner is `r·(1 − 1/√2)` — about 15% of its diameter — inside the
/// bounding box the badge is positioned against, so without this the marker
/// floats off an avatar with a gap under it.
const double _circleInset = 0.07;

/// A small mark in the corner of something else: unread mail on an inbox icon, a
/// status dot on an avatar, a count on a tab.
///
/// ```dart
/// PlBadge(content: const Text('3'), label: '3 unread', child: inbox)
/// ```
///
/// With no [child] the marker lays out on its own instead, which is what a
/// standalone status pill in a table cell is.
///
/// A badge has no interaction, no state and no keyboard contract. It is a mark.
/// What it does owe a screen reader is a sentence rather than a number, which is
/// what [label] is for — a `3` beside a bell reads out as "3".
class PlBadge extends StatelessWidget {
  /// Creates a badge.
  const PlBadge({
    this.content,
    this.count,
    this.max = 99,
    this.dot = false,
    this.showZero = false,
    this.invisible = false,
    this.placement = PlassCorner.topEnd,
    this.overlap = PlBadgeOverlap.square,
    this.variant = PlassVariant.solid,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.elevation = 0,
    this.label,
    this.child,
    super.key,
  }) : assert(content == null || count == null, 'give a badge either content or count, not both'),
       assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// What the badge says, when it is not a number.
  ///
  /// Leave both this and [count] out and the badge draws a dot instead, which is
  /// the honest thing when there is something to report but nothing to count.
  final Widget? content;

  /// What the badge counts.
  ///
  /// Separate from [content] because [max] and [showZero] only mean anything for
  /// a number, and React's single prop has to ask at runtime what it was handed.
  /// Here the type is the question.
  final int? count;

  /// Caps [count] and adds a `+`.
  final int max;

  /// Draws the marker as a dot even when there is content, keeping the content
  /// for screen readers only. For the corner that has to stay quiet.
  final bool dot;

  /// Whether a [count] of `0` is shown.
  ///
  /// Off by default — zero unread messages is not news, and a badge that never
  /// goes away stops meaning anything.
  final bool showZero;

  /// Hides the marker without taking it out of the layout. The badge keeps its
  /// box, so showing it again does not move what it sits on.
  final bool invisible;

  /// Which corner of the anchor it sits on.
  final PlassCorner placement;

  /// The shape of the thing underneath. See [PlBadgeOverlap].
  final PlBadgeOverlap overlap;

  /// What the marker is made of.
  ///
  /// Said the way a *control* says it: the marker is the thing being coloured,
  /// so its sheet takes the tint. [PlassVariant.ghost] is the one to reach for on
  /// a busy surface — a soft tinted mark that reports without shouting.
  final PlassVariant variant;

  /// The marker's own ladder — 14 to 24px, well below the control heights.
  final PlassSize size;

  /// Semantic colour role.
  final PlassColor color;

  /// Halves the horizontal padding around the digits.
  final PlassDensity density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` is the default — a marker lies on the thing it is marking rather than
  /// floating above it.
  final PlassElevation elevation;

  /// What a screen reader hears instead of the raw content.
  ///
  /// `count: 3` on a bell is "3" to a reader and means nothing;
  /// `label: '3 unread notifications'` is the sentence.
  final String? label;

  /// What the badge is pinned to.
  final Widget? child;

  /// `99+`, but only for a value a `+` means anything on.
  String? get _text {
    if (count == null) {
      return null;
    }

    return count! > max ? '$max+' : '$count';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);

    // A count of nothing is not news, which is the one place the library asks a
    // second question about whether a slot is filled.
    final empty = content == null && (count == null || (count == 0 && !showZero));
    final asDot = dot || empty;
    final hidden = invisible || (empty && !dot);

    final surface = controlSurface(tokens, family, variant: variant, elevation: elevation);

    Widget marker = _marker(tokens, surface, asDot: asDot, hidden: hidden);

    // Visibility rather than opacity: a half-faded badge is a badge you have to
    // squint at to find out whether it is there. The marker keeps its box either
    // way, so nothing around it moves when it comes back.
    if (hidden) {
      marker = Visibility(
        visible: false,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: marker,
      );
    }

    marker = ExcludeSemantics(excluding: hidden, child: marker);

    if (child == null) {
      return marker;
    }

    // The shell is exactly as wide and as tall as what it wraps — sized by the
    // anchor alone — or a badged icon button stops lining up with the bare one
    // beside it.
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child!,
        Positioned.fill(
          child: _Corner(
            placement: placement,
            offset: asDot ? _dotCornerOffset[size]! : _cornerOffset[size]!,
            inset: overlap == PlBadgeOverlap.circle ? _circleInset : 0,
            child: marker,
          ),
        ),
      ],
    );
  }

  Widget _marker(
    PlassTokens tokens,
    PlassSurface surface, {
    required bool asDot,
    required bool hidden,
  }) {
    // A badge sits well below the radius ladder — at 18px tall, `xs` (8px) is
    // already most of the way to a pill, and a badge *is* the one thing in the
    // library allowed to be one. That is not a hole in the design language, it
    // is the exception the language names: a Plass corner is a moulded fillet on
    // a *surface*, and a badge is a mark laid on one.
    final radius = BorderRadius.circular(_badgeHeight[size]!);

    if (asDot) {
      final diameter = _dotSize[size]!;

      return Semantics(
        label: hidden ? null : label ?? _text,
        container: !hidden && (label != null || _text != null),
        child: SizedBox.square(
          dimension: diameter,
          child: PlassSurfaceBox(
            surface: surface,
            borderRadius: BorderRadius.circular(diameter),
            child: const SizedBox.shrink(),
          ),
        ),
      );
    }

    final text = _text;

    Widget body = DefaultTextStyle.merge(
      style: TextStyle(
        color: surface.ink,
        fontSize: _badgeText[size]!,
        fontWeight: FontWeight.w600,
        height: 1,
        leadingDistribution: TextLeadingDistribution.even,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
      maxLines: 1,
      softWrap: false,
      child: content ?? Text(text ?? ''),
    );

    if (label != null) {
      // The count is still drawn; it is the sentence that is read.
      body = ExcludeSemantics(child: body);
    }

    return Semantics(
      label: hidden ? null : label,
      container: !hidden && label != null,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: _badgeHeight[size]!, minHeight: _badgeHeight[size]!),
        child: PlassSurfaceBox(
          surface: surface,
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _badgePadding[density]![size]!),
            child: Center(widthFactor: 1, heightFactor: 1, child: body),
          ),
        ),
      ),
    );
  }
}

/// Pins the marker to one corner of the anchor, pulled [offset] logical pixels
/// out of it and [inset] of the anchor's own box back in.
///
/// A [Stack] with a directional alignment rather than a `transform`: the house
/// rule against moving a control with one is absolute, and a corner is two
/// alignments and a pair of insets either way.
class _Corner extends StatelessWidget {
  const _Corner({
    required this.placement,
    required this.offset,
    required this.inset,
    required this.child,
  });

  final PlassCorner placement;
  final double offset;
  final double inset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final top = placement == PlassCorner.topStart || placement == PlassCorner.topEnd;
    final start = placement == PlassCorner.topStart || placement == PlassCorner.bottomStart;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final pull = offset - constraints.biggest.shortestSide * inset;

        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            PositionedDirectional(
              top: top ? -pull : null,
              bottom: top ? null : -pull,
              start: start ? -pull : null,
              end: start ? null : -pull,
              child: child,
            ),
          ],
        );
      },
    );
  }
}
