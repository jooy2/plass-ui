/// A floating lozenge holding a small amount of live information.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/fold.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// The row's floor, as a minimum rather than as a height.
///
/// The numbers are [controlHeight]'s — a collapsed pill lines up with a
/// [PlButton] of the same size beside it — but a pill carrying a description is
/// two lines tall and a fixed height would clip the second.
const Map<PlassSize, double> _rowMinHeight = <PlassSize, double>{
  PlassSize.xs: 22,
  PlassSize.sm: 26,
  PlassSize.md: 32,
  PlassSize.lg: 40,
  PlassSize.xl: 48,
};

/// The air either side of the middle, and the thing that makes this shape read
/// as the lozenge it is rather than as a wide [PlChip].
///
/// Roughly double the control padding at every step. The leading glyph and the
/// trailing slot are the pill's furniture; what it is *about* is the column
/// between them, and giving that column noticeably more room than either
/// neighbour is what puts the eye there first.
const Map<PlassDensity, Map<PlassSize, double>> _centerPadding =
    <PlassDensity, Map<PlassSize, double>>{
      PlassDensity.standard: <PlassSize, double>{
        PlassSize.xs: 12,
        PlassSize.sm: 16,
        PlassSize.md: 20,
        PlassSize.lg: 24,
        PlassSize.xl: 32,
      },
      PlassDensity.compact: <PlassSize, double>{
        PlassSize.xs: 6,
        PlassSize.sm: 8,
        PlassSize.md: 10,
        PlassSize.lg: 12,
        PlassSize.xl: 16,
      },
    };

/// The room the row keeps above and below a second line.
///
/// It costs nothing in the one-line case — the row's minimum is taller than a
/// line plus this — and is what keeps two lines off the edges.
const double _rowPaddingY = 4;

/// How much of the ink the description keeps.
///
/// Mixed toward transparent rather than pointed at a fixed grey: the middle of a
/// pill sits on the colour family's own fill as often as on a bare surface, and
/// a grey that reads as secondary on white reads as dirt on `primary`. Taking
/// the ink that is already there and letting some of the surface through is the
/// one form of "one step quieter" that holds on all three materials.
const double _descriptionInk = 0.72;

/// A floating lozenge holding a small amount of live information.
///
/// ```dart
/// PlPill(
///   color: PlassColor.danger,
///   title: const Text('Recording'),
///   description: const Text('00:41'),
///   startIcon: const RecordingDot(),
/// )
/// ```
///
/// The shape is a **stadium**, which the house radius rule otherwise forbids:
/// every control is held just short of the 50% that would make it a pill,
/// because the flat run along its top and bottom edge is what still reads as a
/// sheet with the corners cut off it. A pill is the exception the rule is drawn
/// against, and the exception works for the same reason the rule does — this is
/// not a sheet lying on the screen. It is an object hovering over one, and an
/// object hovering over the screen should not look as though it was cut from the
/// same material.
///
/// The radius is pinned to the **row** rather than being "half of whatever this
/// is", and the difference only shows once the pill grows: a corner half the
/// height of a box that has taken a second line eats the first two words of
/// every line.
///
/// [details] is revealed by clipping a body that never changes size, exactly as
/// a [PlCollapsible]'s panel is: nothing is transformed and no text is
/// resampled — the pill is simply a window that opens.
///
/// **A pill fills the width it is given, and takes its own where it is given
/// none.** Offered a bounded width it spans it, so a pill in a column of cards
/// lines up with them — and a [Wrap] counts, since a loose constraint is still
/// a bounded one. Offered an unbounded width — inside a [Row], or a
/// [Positioned] that named only its top and its start, which is how a lozenge
/// floating over a screen is placed — it is as wide as its widest part and no
/// wider. Neither case needs an [Expanded] or a [SizedBox] around it.
class PlPill extends StatefulWidget {
  /// Creates a pill.
  const PlPill({
    this.title,
    this.description,
    this.startIcon,
    this.endIcon,
    this.details,
    this.expanded = false,
    this.onPressed,
    this.child,
    this.variant = PlassVariant.solid,
    this.size,
    this.color,
    this.density,
    this.elevation = 2,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The headline in the middle — what the pill is currently about.
  ///
  /// A parameter rather than something to compose, for the reason a [PlCard]'s
  /// title is one: the arrangement is fixed and what a caller wants to decide is
  /// what goes in each slot.
  final Widget? title;

  /// The second line, under the title. One step down and quieter.
  final Widget? description;

  /// The leading slot — a glyph, an avatar, a status dot, a photo.
  ///
  /// It is given a square box of its own and clipped to a circle, so an image
  /// lands in it as readily as a glyph does.
  final Widget? startIcon;

  /// The trailing slot. Outside the pressable area, so it can be a control.
  final Widget? endIcon;

  /// The second half, revealed when [expanded].
  ///
  /// The pill grows downward into it rather than swapping to a different shape:
  /// one object saying more.
  final Widget? details;

  /// Whether [details] is showing.
  final bool expanded;

  /// Passing it makes the middle a real button.
  final VoidCallback? onPressed;

  /// Anything the middle needs that [title] and [description] cannot say — a
  /// pair of small readouts, a live counter. Drawn under them, in the same
  /// centred column.
  final Widget? child;

  /// What the surface is made of, said the way a *control* says it: the surface
  /// takes the tint, because a pill is the thing being coloured rather than a
  /// sheet holding somebody else's content.
  final PlassVariant variant;

  /// The row's minimum height and the type scale.
  final PlassSize? size;

  /// Semantic colour role.
  final PlassColor? color;

  /// Halves the air either side of the middle.
  final PlassDensity? density;

  /// Drop shadow depth, `0`–`3`. `2`, against the `0` almost everything else
  /// takes.
  ///
  /// Not an inconsistency: a pill is defined by **not** being part of the
  /// screen. Every other surface rests on it and earns its separation from the
  /// glass edge, so a shadow is opt-in. This one hovers over whatever is
  /// underneath it, and a lozenge lying flat on the content it is floating over
  /// reads as a mistake.
  final PlassElevation elevation;

  @override
  State<PlPill> createState() => _PlPillState();
}

class _PlPillState extends State<PlPill> with SingleTickerProviderStateMixin {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.secondary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  // No duration here and a stand-in curve: `_syncMotion` gives both the
  // theme's before the first frame, and again whenever the theme changes, so a
  // pill that is already built takes a new duration without being rebuilt.
  late final AnimationController _open = AnimationController(
    vsync: this,
    value: widget.expanded ? 1 : 0,
  );

  late final CurvedAnimation _reveal = CurvedAnimation(parent: _open, curve: Curves.linear);

  @override
  void didUpdateWidget(PlPill oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.expanded != oldWidget.expanded) {
      // Read here as well as below: an update runs before the dependencies
      // are refreshed, and a theme that changed in the same frame as
      // `expanded` would otherwise open on the old duration.
      _syncMotion();
      widget.expanded ? _open.forward() : _open.reverse();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  /// Hands the reveal the theme's slow duration and curve, or no duration at
  /// all for a reader who asked for less movement.
  void _syncMotion() {
    final tokens = PlassTheme.of(context);

    _open.duration = (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
        ? Duration.zero
        : tokens.motionDurationSlow;
    _reveal.curve = tokens.motionEase;
  }

  @override
  void dispose() {
    _open.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(_color);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final text = controlText[_size]!;
    final padX = paddingX[_density]![_size]!;
    final interactive = widget.onPressed != null;

    // Exactly half the row's minimum height, so a collapsed pill is a true
    // stadium — and the same number once it has grown, which is what keeps a
    // two-line pill from having a corner that eats its own text.
    final corner = BorderRadius.circular(_rowMinHeight[_size]! / 2);

    return PlassInteractive(
      onTap: widget.onPressed,
      enabled: interactive,
      interactive: interactive,
      cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
      builder: (BuildContext context, PlassInteraction state) {
        final surface = _surface(tokens, family, state, interactive: interactive);

        Widget row = Padding(
          padding: EdgeInsetsDirectional.only(
            start: widget.startIcon != null || !interactive ? padX : 0,
            end: widget.endIcon != null ? 4 : (interactive ? 0 : padX),
            top: _rowPaddingY,
            bottom: _rowPaddingY,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: gap[_size]!,
            children: <Widget>[
              if (widget.startIcon != null)
                // A square the size of a standalone glyph, clipped round: an
                // image fills the box and is cropped rather than letterboxed,
                // which is what a 20px portrait wants.
                ClipOval(
                  child: SizedBox(
                    width: iconSize[_size]!,
                    height: iconSize[_size]!,
                    child: IconTheme.merge(
                      data: IconThemeData(color: surface.ink, size: iconSize[_size]!),
                      child: Center(child: widget.startIcon!),
                    ),
                  ),
                ),
              if (widget.title != null || widget.description != null || widget.child != null)
                Flexible(child: _middle(tokens, surface.ink)),
              if (widget.endIcon != null) _outsidePress(widget.endIcon!, interactive: interactive),
            ],
          ),
        );

        row = ConstrainedBox(
          constraints: BoxConstraints(minHeight: _rowMinHeight[_size]!),
          child: row,
        );

        // The middle is the pressable part and `endIcon` is not, so the
        // trailing slot is not inside what answers a press — the same shape a
        // chip uses, and for the same reason: a control inside another
        // control's gesture takes one tap twice.
        //
        // With `details` the button is almost always what opens them, so it
        // says whether they are open. Left out otherwise: a pill with nothing
        // to reveal has no expanded state to report.
        //
        // Wrapped whether or not the pill is pressable, with every property
        // left empty when it is not, which is a `Semantics` that adds nothing.
        // Every wrapper in here stays put when `onPressed` comes or goes: a
        // wrapper that comes and goes changes the shape of the tree above the
        // content, and Flutter builds a changed shape from scratch, so a field
        // in `details` lost what was typed into it.
        row = Semantics(
          button: interactive ? true : null,
          enabled: interactive ? true : null,
          expanded: interactive && widget.details != null ? widget.expanded : null,
          onTap: widget.onPressed,
          child: row,
        );

        Widget pill = DefaultTextStyle.merge(
          style: TextStyle(
            color: surface.ink,
            fontSize: text,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
          // Stretched so the row and the panel under it are one width — and
          // the constraints are asked first, because there is not always a
          // width to stretch to.
          //
          // A pill is offered an unbounded one more often than most things
          // here: a `Row` hands its children an unbounded main axis, and so
          // does a `Positioned` that named only its top and its start, which is
          // exactly how a lozenge that floats over a screen is placed.
          // `stretch` against an unbounded constraint asks for a *tight
          // infinite* width, which is a layout error rather than a wide pill.
          // So where there is nothing to fill, the pill takes the width of its
          // own widest part and centres the rest on it.
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: constraints.hasBoundedWidth
                  ? CrossAxisAlignment.stretch
                  : CrossAxisAlignment.center,
              children: <Widget>[
                row,
                if (widget.details != null)
                  PlassFold(
                    factor: _reveal,
                    child: _outsidePress(
                      interactive: interactive,
                      ExcludeFocus(
                        excluding: !widget.expanded,
                        child: ExcludeSemantics(
                          excluding: !widget.expanded,
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(start: padX, end: padX, bottom: 8),
                            child: DefaultTextStyle.merge(
                              style: TextStyle(
                                fontSize: sheetBody[_size]!.size,
                                height: sheetBody[_size]!.height,
                                fontWeight: FontWeight.w400,
                              ),
                              child: widget.details!,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );

        pill = PlassSurfaceBox(
          surface: surface,
          borderRadius: corner,
          pointer: state.pointer,
          // Both layers are kept and only lit on a pressable pill, whose
          // hover and press are the only ones that are ever reported. A layer
          // left out shifts the content along the surface's stack, which is
          // one more change of shape.
          glow: _glow(tokens, family),
          glowVisible: interactive && state.hovered,
          flash: _flash(tokens, family),
          flashVisible: interactive && state.pressed,
          reduceMotion: reduceMotion,
          child: pill,
        );

        pill = plassStateFilter(
          child: pill,
          hovered: state.hovered,
          pressed: state.pressed,
          reduceMotion: reduceMotion,
          // Not narrowed to a pressable pill: the filter is a wrapper, and on a
          // pill that is not pressable it is handed no hover and no press, so
          // it stays at full brightness.
          lit: widget.variant == PlassVariant.solid,
        );

        // Switched off by leaving out its painter rather than the widget that
        // paints it, for the same reason.
        return CustomPaint(
          foregroundPainter: state.focusVisible
              ? PlassFocusRingPainter(
                  color: family.ring,
                  borderRadius: corner,
                  offset: focusRingOffset,
                )
              : null,
          child: pill,
        );
      },
    );
  }

  /// Keeps a press on [child] from pressing the pill.
  ///
  /// The row is what answers a press, as the React build's `<button>` is, but
  /// the gesture detector is around the whole pill, because the light and the
  /// hover belong to the whole lozenge, as they do on the React build's shell.
  /// Without this, a press on the open [details] reached [PlPill.onPressed],
  /// and a pill whose press opens its details folded them away the moment
  /// someone touched what they were reading.
  ///
  /// A detector of its own under [child] enters the same tap and, being deeper,
  /// wins it, so the pill's recogniser never fires. A control inside [child] is
  /// deeper still and wins over both. The cursor goes back to the arrow, because
  /// nothing here is pressed.
  ///
  /// On a pill that is not pressable the two are kept and do nothing — no
  /// recogniser and no cursor of their own — so [child] keeps its place in the
  /// tree when `onPressed` comes or goes.
  Widget _outsidePress(Widget child, {required bool interactive}) {
    return MouseRegion(
      cursor: interactive ? SystemMouseCursors.basic : MouseCursor.defer,
      child: GestureDetector(
        behavior: interactive ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
        excludeFromSemantics: true,
        onTap: interactive ? () {} : null,
        child: child,
      ),
    );
  }

  /// The middle: centred in its own column rather than run on from the glyph,
  /// and padded well clear of both neighbours — the pill is a frame and this is
  /// what is in it.
  Widget _middle(PlassTokens tokens, Color ink) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _centerPadding[_density]![_size]!),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (widget.title != null)
            DefaultTextStyle.merge(
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              child: widget.title!,
            ),
          if (widget.description != null)
            DefaultTextStyle.merge(
              style: TextStyle(
                color: ink.withValues(alpha: ink.a * _descriptionInk),
                fontSize: metaText[_size]!,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              child: widget.description!,
            ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }

  /// The pill's own surface, which is a control's rather than a container's.
  PlassSurface _surface(
    PlassTokens tokens,
    PlassColorFamily family,
    PlassInteraction state, {
    required bool interactive,
  }) {
    return controlSurface(
      tokens,
      family,
      variant: widget.variant,
      elevation: widget.elevation,
      hovered: interactive && state.hovered,
      pressed: interactive && state.pressed,
    );
  }

  Color _glow(PlassTokens tokens, PlassColorFamily family) =>
      widget.variant == PlassVariant.solid ? tokens.glowOnFill : family.soft;

  Color _flash(PlassTokens tokens, PlassColorFamily family) =>
      widget.variant == PlassVariant.solid ? tokens.flashOnFill : family.softHover;
}
