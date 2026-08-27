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
    this.size = PlassSize.md,
    this.color = PlassColor.secondary,
    this.density = PlassDensity.standard,
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
  final PlassSize size;

  /// Semantic colour role.
  final PlassColor color;

  /// Halves the air either side of the middle.
  final PlassDensity density;

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
  late final AnimationController _open = AnimationController(
    vsync: this,
    duration: PlassTokens.durationSlow,
    value: widget.expanded ? 1 : 0,
  );

  late final Animation<double> _reveal = CurvedAnimation(parent: _open, curve: PlassTokens.ease);

  @override
  void didUpdateWidget(PlPill oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.expanded != oldWidget.expanded) {
      widget.expanded ? _open.forward() : _open.reverse();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _open.duration = (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
        ? Duration.zero
        : PlassTokens.durationSlow;
  }

  @override
  void dispose() {
    _open.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(widget.color);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final text = controlText[widget.size]!;
    final padX = paddingX[widget.density]![widget.size]!;
    final interactive = widget.onPressed != null;

    // Exactly half the row's minimum height, so a collapsed pill is a true
    // stadium — and the same number once it has grown, which is what keeps a
    // two-line pill from having a corner that eats its own text.
    final corner = BorderRadius.circular(_rowMinHeight[widget.size]! / 2);

    return PlassInteractive(
      onTap: widget.onPressed,
      enabled: interactive,
      interactive: interactive,
      cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
      builder: (BuildContext context, PlassInteraction state) {
        final surface = _surface(tokens, family, state, interactive: interactive);

        Widget row = Padding(
          padding: EdgeInsets.only(
            left: widget.startIcon != null || !interactive ? padX : 0,
            right: widget.endIcon != null ? 4 : (interactive ? 0 : padX),
            top: _rowPaddingY,
            bottom: _rowPaddingY,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: gap[widget.size]!,
            children: <Widget>[
              if (widget.startIcon != null)
                // A square the size of a standalone glyph, clipped round: an
                // image fills the box and is cropped rather than letterboxed,
                // which is what a 20px portrait wants.
                ClipOval(
                  child: SizedBox(
                    width: iconSize[widget.size]!,
                    height: iconSize[widget.size]!,
                    child: IconTheme.merge(
                      data: IconThemeData(color: surface.ink, size: iconSize[widget.size]!),
                      child: Center(child: widget.startIcon!),
                    ),
                  ),
                ),
              if (widget.title != null || widget.description != null || widget.child != null)
                Flexible(child: _middle(tokens, surface.ink)),
              if (widget.endIcon != null) widget.endIcon!,
            ],
          ),
        );

        row = ConstrainedBox(
          constraints: BoxConstraints(minHeight: _rowMinHeight[widget.size]!),
          child: row,
        );

        if (interactive) {
          // The middle is the pressable part and `endIcon` is not, so the
          // trailing slot is not inside what answers a press — the same shape a
          // chip uses, and for the same reason: a control inside another
          // control's gesture takes one tap twice.
          row = Semantics(button: true, enabled: true, onTap: widget.onPressed, child: row);
        }

        Widget pill = DefaultTextStyle.merge(
          style: TextStyle(
            color: surface.ink,
            fontSize: text,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              row,
              if (widget.details != null)
                PlassFold(
                  factor: _reveal,
                  child: ExcludeFocus(
                    excluding: !widget.expanded,
                    child: ExcludeSemantics(
                      excluding: !widget.expanded,
                      child: Padding(
                        padding: EdgeInsets.only(left: padX, right: padX, bottom: 8),
                        child: DefaultTextStyle.merge(
                          style: TextStyle(
                            fontSize: sheetBody[widget.size]!.size,
                            height: sheetBody[widget.size]!.height,
                            fontWeight: FontWeight.w400,
                          ),
                          child: widget.details!,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );

        pill = PlassSurfaceBox(
          surface: surface,
          borderRadius: corner,
          pointer: state.pointer,
          glow: interactive ? _glow(tokens, family) : null,
          glowVisible: state.hovered,
          flash: interactive ? _flash(tokens, family) : null,
          flashVisible: state.pressed,
          reduceMotion: reduceMotion,
          child: pill,
        );

        pill = plassStateFilter(
          child: pill,
          hovered: state.hovered,
          pressed: state.pressed,
          reduceMotion: reduceMotion,
          lit: interactive && widget.variant == PlassVariant.solid,
        );

        if (state.focusVisible) {
          pill = CustomPaint(
            foregroundPainter: PlassFocusRingPainter(
              color: family.ring,
              borderRadius: corner,
              offset: focusRingOffset,
            ),
            child: pill,
          );
        }

        return pill;
      },
    );
  }

  /// The middle: centred in its own column rather than run on from the glyph,
  /// and padded well clear of both neighbours — the pill is a frame and this is
  /// what is in it.
  Widget _middle(PlassTokens tokens, Color ink) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _centerPadding[widget.density]![widget.size]!),
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
                fontSize: metaText[widget.size]!,
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
