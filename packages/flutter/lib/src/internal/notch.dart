/// The label in the field's own top edge — [PlassFieldLabelPlacement.notch].
///
/// One module because every field-shaped control in the library draws the same
/// notch: a [PlTextField], a select's trigger, a combobox, a number field, a
/// file picker's drop zone and every picker that goes through `internal/picker`
/// have to be indistinguishable along their top edge or a form looks like two
/// forms stacked on each other.
///
/// **The cut is real.** The border is painted with a gap in it rather than
/// covered over where the label sits: a Plass field is translucent and the page
/// behind it belongs to the application, so a patch of flat colour laid over
/// the line would read as a patch of flat colour. The web package cuts the same
/// gap with a `<legend>` in a `<fieldset>`, which is the browser's own version
/// of this.
///
/// **The edge is painted here rather than by the surface.** A notched control
/// hands [PlassSurface.withoutBorder] to its surface box and lets this draw the
/// line instead, which is also why the focus ring goes: a ring is a rectangle
/// and the label is sitting on the edge it would be drawn along, so the edge
/// itself thickens and takes the family's colour.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// The air either side of the label, inside the cut. Tighter at the two small
/// sizes, where four pixels is a third of the word.
double notchPad(PlassSize size) {
  return size == PlassSize.xs || size == PlassSize.sm ? 2 : 4;
}

/// Where the cut starts, measured from the control's start edge.
///
/// `paddingX - notchPad`, so that the label's first letter lands on the same
/// line as the value under it — a name sitting over its own field rather than
/// over the corner. The floor is the corner radius: a notch that starts inside
/// the curve takes a bite out of the arc instead of out of a straight line,
/// which is what pushes the compact track's labels a few pixels past their
/// values at the small end. A corner is not a place a label can go.
double notchInset(PlassDensity density, PlassSize size) {
  final start = paddingX[density]![size]! - notchPad(size);
  final corner = PlassTokens.radius[size]!;

  return start < corner ? corner : start;
}

/// How far the label is lifted above the control, which is **half its line
/// box**: the cut is drawn across the label's middle, so lifting it by half its
/// own height puts that middle exactly on the control's top edge.
double notchRise(PlassSize size) => metaText[size]! / 2;

/// The line the notch is cut into: a colour and a width.
class PlassNotchEdge {
  /// Creates an edge.
  const PlassNotchEdge({required this.color, required this.width});

  /// What the line is drawn in. Transparent where the variant has no edge.
  final Color color;

  /// How thick it is — the hairline, or the focus ring's own width.
  final double width;
}

/// The edge a notched field draws, for every variant and state.
///
/// Only [PlassVariant.glass] has a hairline: `solid` is a well with no edge to
/// cut and `ghost` has no surface at all, so on those two the label rests on the
/// top of the box and nothing is taken out from under it. The alternative —
/// refusing the notch to two of the three variants — would give a form that
/// mixes them two different label baselines.
///
/// **Focus is the same line, thickened.** Every variant answers focus here,
/// including the two that are otherwise edgeless, because the ring this
/// replaces was the one thing on the control that said where the keyboard was.
PlassNotchEdge notchEdge(
  PlassTokens tokens,
  PlassColorFamily family, {
  required PlassVariant variant,
  bool hovered = false,
  bool focused = false,
  bool readOnly = false,
  bool disabled = false,
}) {
  const Color none = Color(0x00000000);
  final Color rest = variant == PlassVariant.glass ? tokens.border : none;

  if (disabled) {
    // Dimmed to the same degree the shell beside it is: the edge is painted
    // outside the state filter that dims the control, so it has to say it.
    return PlassNotchEdge(
      color: rest.withValues(alpha: rest.a * disabledOpacity),
      width: hairline,
    );
  }

  if (readOnly) {
    return PlassNotchEdge(color: rest, width: hairline);
  }

  if (focused) {
    return PlassNotchEdge(color: family.ring, width: focusRingWidth);
  }

  return PlassNotchEdge(
    color: hovered && variant == PlassVariant.glass ? family.line : rest,
    width: hairline,
  );
}

/// Paints a rounded rectangle, which is what a field's edge is when nothing
/// has been taken out of it yet.
///
/// The gap is not this painter's business: [PlassFieldNotch] clips it out of
/// whatever edge it is given, which is what lets a drop zone's dashed line be
/// notched by exactly the same machinery as a field's hairline.
class PlassEdgePainter extends CustomPainter {
  /// Creates an edge of [color] and [width] following [borderRadius].
  const PlassEdgePainter({required this.borderRadius, required this.color, required this.width});

  /// The control's corners, which the line follows.
  final BorderRadius borderRadius;

  /// The line's colour.
  final Color color;

  /// Its thickness.
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    if (color.a == 0 || width <= 0) {
      return;
    }

    // The stroke is centred on the path, so the path is half a stroke inside
    // the box — which puts the line entirely within the control's own bounds,
    // where a CSS border is.
    final RRect shape = borderRadius.toRRect((Offset.zero & size).deflate(width / 2));

    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(PlassEdgePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.width != width ||
        oldDelegate.borderRadius != borderRadius;
  }
}

/// The edge a notched control draws, or `null` where the variant has none.
///
/// A [PlassEdgePainter] over [notchEdge], which is the pair every field-shaped
/// control wants; a drop zone passes its own dashed painter instead.
CustomPainter? notchEdgePainter(
  PlassTokens tokens,
  PlassColorFamily family, {
  required PlassVariant variant,
  required BorderRadius borderRadius,
  bool hovered = false,
  bool focused = false,
  bool readOnly = false,
  bool disabled = false,
}) {
  final PlassNotchEdge edge = notchEdge(
    tokens,
    family,
    variant: variant,
    hovered: hovered,
    focused: focused,
    readOnly: readOnly,
    disabled: disabled,
  );

  if (edge.color.a == 0) {
    return null;
  }

  return PlassEdgePainter(borderRadius: borderRadius, color: edge.color, width: edge.width);
}

/// Takes the label's segment out of whatever the edge painted.
///
/// A clip rather than a path with a piece missing: a stroke follows the path it
/// is given, and a path with a gap in it is still stroked along the two ends it
/// now has. Clipping takes the line out and leaves the corners alone — and it
/// works the same on a dashed line, which is why the drop zone needs no notch
/// of its own.
class _NotchClipper extends CustomClipper<Path> {
  _NotchClipper({
    required this.gap,
    required this.inset,
    required this.pad,
    required this.rise,
    required this.width,
    required this.textDirection,
  }) : super(reclip: gap);

  final ValueListenable<double> gap;
  final double inset;
  final double pad;
  final double rise;
  final double width;
  final TextDirection textDirection;

  Rect cut(Size size) {
    final double extent = gap.value + pad * 2;
    final double start = textDirection == TextDirection.rtl ? size.width - inset - extent : inset;

    // Tall enough to take the whole top line out and nothing else: down to just
    // past the stroke, and up past the label so a tall one is never crossed.
    return Rect.fromLTRB(start, -rise - width, start + extent, width);
  }

  @override
  Path getClip(Size size) {
    return Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRect(cut(size)),
    );
  }

  @override
  bool shouldReclip(_NotchClipper oldClipper) {
    return oldClipper.inset != inset ||
        oldClipper.pad != pad ||
        oldClipper.rise != rise ||
        oldClipper.width != width ||
        oldClipper.textDirection != textDirection;
  }
}

/// Lays the notched edge over a control's shell.
///
/// The shell is drawn exactly as it is without a notch, minus its own border —
/// a notch is a decision about the label, not a second way of drawing a field.
class PlassFieldNotch extends StatefulWidget {
  /// Creates a notch around [child].
  const PlassFieldNotch({
    required this.size,
    required this.density,
    required this.edge,
    required this.label,
    required this.child,
    this.edgeWidth = focusRingWidth,
    this.disabled = false,
    super.key,
  });

  /// The rung the label's type scale and the cut's geometry come from.
  final PlassSize size;

  /// Which horizontal track the cut starts on.
  final PlassDensity density;

  /// The control's own edge, from [notchEdgePainter] or a caller's own painter,
  /// or `null` where the variant draws no line. Whatever it paints, the label's
  /// segment is clipped out of it.
  final CustomPainter? edge;

  /// How thick that edge is, which is how far down the cut has to reach to take
  /// the whole of it out.
  final double edgeWidth;

  /// The name of what the control holds, styled by the control itself — the
  /// same widget the stacked placement renders, so the two cannot drift.
  final Widget label;

  /// Unavailable, which mutes the label the way the stacked one is muted.
  final bool disabled;

  /// The control's shell.
  final Widget child;

  @override
  State<PlassFieldNotch> createState() => _PlassFieldNotchState();
}

class _PlassFieldNotchState extends State<PlassFieldNotch> {
  /// The label's width, written during its layout and read during the edge's
  /// paint — which is the frame after, in the same frame, because painting
  /// happens once every layout is done. A rebuild would be a frame late and
  /// would show the gap at the wrong width until it arrived.
  final ValueNotifier<double> _gap = ValueNotifier<double>(0);

  @override
  void dispose() {
    _gap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final PlassSize size = widget.size;
    final double rise = notchRise(size);
    final double inset = notchInset(widget.density, size);
    final double pad = notchPad(size);

    return Padding(
      // The lift, kept in the layout so the label does not run into whatever is
      // above it.
      padding: EdgeInsets.only(top: rise),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          widget.child,
          if (widget.edge != null)
            Positioned.fill(
              child: IgnorePointer(
                child: ClipPath(
                  clipper: _NotchClipper(
                    gap: _gap,
                    inset: inset,
                    pad: pad,
                    rise: rise,
                    width: widget.edgeWidth,
                    textDirection: Directionality.of(context),
                  ),
                  child: CustomPaint(painter: widget.edge),
                ),
              ),
            ),
          PositionedDirectional(
            top: -rise,
            start: inset + pad,
            child: _MeasuredWidth(
              gap: _gap,
              child: DefaultTextStyle.merge(
                // The line box is the font size and nothing else, which is what
                // makes half of it the right lift.
                style: TextStyle(
                  height: 1,
                  fontSize: metaText[size]!,
                  color: widget.disabled ? tokens.mutedFg : tokens.fg,
                ),
                child: widget.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reports its child's width to [gap] as it is laid out.
///
/// The gap in the edge is as wide as the label, and the label is a widget
/// rather than a string — there is nothing to measure it with but a layout.
/// Writing during layout rather than after it is what keeps the edge and the
/// label in step: paint runs once the whole tree is laid out, so the value is
/// there before the line is drawn.
class _MeasuredWidth extends SingleChildRenderObjectWidget {
  const _MeasuredWidth({required this.gap, required Widget super.child});

  final ValueNotifier<double> gap;

  @override
  _RenderMeasuredWidth createRenderObject(BuildContext context) {
    return _RenderMeasuredWidth(gap);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderMeasuredWidth renderObject) {
    renderObject.gap = gap;
  }
}

class _RenderMeasuredWidth extends RenderProxyBox {
  _RenderMeasuredWidth(this.gap);

  ValueNotifier<double> gap;

  @override
  void performLayout() {
    super.performLayout();
    gap.value = size.width;
  }
}
