/// One section that folds, standing on its own.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// The space between the header and the body it opened.
///
/// The header's own padding does not pay for it, which is the correction
/// [PlAccordion] already carries: an open header is a tinted band with its own
/// bottom edge, the body begins at that edge, and its first line lands against
/// it with only half a leading in between.
const Map<PlassDensity, Map<PlassSize, double>> _panelPaddingTop =
    <PlassDensity, Map<PlassSize, double>>{
      PlassDensity.standard: <PlassSize, double>{
        PlassSize.xs: 6,
        PlassSize.sm: 8,
        PlassSize.md: 12,
        PlassSize.lg: 14,
        PlassSize.xl: 16,
      },
      PlassDensity.compact: <PlassSize, double>{
        PlassSize.xs: 4,
        PlassSize.sm: 6,
        PlassSize.md: 8,
        PlassSize.lg: 10,
        PlassSize.xl: 12,
      },
    };

/// And the space under it, on the same two tracks.
const Map<PlassDensity, Map<PlassSize, double>> _panelPaddingBottom =
    <PlassDensity, Map<PlassSize, double>>{
      PlassDensity.standard: <PlassSize, double>{
        PlassSize.xs: 10,
        PlassSize.sm: 12,
        PlassSize.md: 20,
        PlassSize.lg: 24,
        PlassSize.xl: 28,
      },
      PlassDensity.compact: <PlassSize, double>{
        PlassSize.xs: 8,
        PlassSize.sm: 10,
        PlassSize.md: 14,
        PlassSize.lg: 16,
        PlassSize.xl: 20,
      },
    };

/// One section that folds, standing on its own.
///
/// ```dart
/// PlCollapsible(
///   open: showing,
///   onOpenChanged: (bool next) => setState(() => showing = next),
///   title: const Text('Advanced'),
///   subtitle: const Text('Nine settings'),
///   child: const Text('Everything the form does not need to ask on the first pass.'),
/// )
/// ```
///
/// A [PlAccordion] is a *set* of these and owns which one of them is open; this
/// is the same fold with nothing else beside it, so what it needs is an [open]
/// of its own rather than a place in somebody's list. Reach for it for a "Show
/// more" on a form, an optional block of settings, the details under a row.
///
/// The panel's height *is* animated, which looks like an exception to the rule
/// against moving things and is not: nothing is transformed, no text is
/// resampled, and the content does not shift relative to the panel it is in —
/// the panel is a window opening onto it. Content that appears instantly is a
/// screen that jumps, which is the failure the rule exists to prevent.
///
/// **Controlled**, like every other stateful widget in the package.
class PlCollapsible extends StatefulWidget {
  /// Creates a fold.
  const PlCollapsible({
    required this.open,
    this.onOpenChanged,
    this.child,
    this.title,
    this.subtitle,
    this.startIcon,
    this.action,
    this.triggerBuilder,
    this.indicator = true,
    this.disabled = false,
    this.padded = true,
    this.keepMounted = false,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.elevation = 0,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// Whether the panel is showing.
  final bool open;

  /// Called with what the open state should become.
  final ValueChanged<bool>? onOpenChanged;

  /// The body.
  final Widget? child;

  /// The heading on the trigger.
  final Widget? title;

  /// A second line under the title, one step down the type scale and muted.
  final Widget? subtitle;

  /// Content before the title — an icon, a status dot, a count.
  final Widget? startIcon;

  /// A control pinned to the end of the header, outside the trigger.
  ///
  /// Deliberately outside it: a header that both folds and holds a switch has
  /// two things to press, and a gesture inside another recogniser takes one tap
  /// twice. The same shape a [PlAccordion]'s section uses.
  final Widget? action;

  /// Replaces the header entirely with a control of your own.
  ///
  /// A **builder** rather than a widget, which is where this parts company with
  /// the React build. There the element passed in *becomes* the trigger, because
  /// a React element can be cloned with new props; a Dart widget cannot be
  /// handed a tap handler after it was made. So the builder is given the state
  /// and the callback and wires up whatever it likes:
  ///
  /// ```dart
  /// triggerBuilder: (BuildContext context, bool open, VoidCallback toggle) =>
  ///     PlButton(onPressed: toggle, child: Text(open ? 'Less' : 'More')),
  /// ```
  final Widget Function(BuildContext context, bool open, VoidCallback toggle)? triggerBuilder;

  /// The chevron at the end of the header, turned to report the state.
  final bool indicator;

  /// Unavailable. The trigger stops answering and the panel stays as it is.
  final bool disabled;

  /// Inner padding around the panel's content.
  final bool padded;

  /// Keeps a closed panel in the tree.
  ///
  /// For content that is expensive to build, or that holds state which should
  /// survive being folded away — a Flutter [State] goes with the widget when it
  /// leaves the tree, so without this a folded-away field forgets what was
  /// typed into it. While it is closed the content is clipped to nothing and
  /// taken out of the focus order and off the semantics tree, because a panel
  /// nobody can see is not one a keyboard should be able to tab into.
  final bool keepMounted;

  /// What the sheet is made of. Never dyed — a fold holds other people's
  /// content. [PlassVariant.ghost] is the one for running prose or a card.
  final PlassVariant variant;

  /// The radius, the padding and the header's type scale.
  final PlassSize size;

  /// Semantic colour role. It reaches the open header's ink and the focus ring.
  final PlassColor color;

  /// How tightly the header and the body pack.
  final PlassDensity density;

  /// Drop shadow depth, `0`–`3`. `0` — a fold is set into the screen rather
  /// than floating over it.
  final PlassElevation elevation;

  @override
  State<PlCollapsible> createState() => _PlCollapsibleState();
}

class _PlCollapsibleState extends State<PlCollapsible> with SingleTickerProviderStateMixin {
  late final AnimationController _fold = AnimationController(
    vsync: this,
    duration: PlassTokens.durationSlow,
    value: widget.open ? 1 : 0,
  );

  late final Animation<double> _size = CurvedAnimation(parent: _fold, curve: PlassTokens.ease);

  bool get _interactive => !widget.disabled && widget.onOpenChanged != null;

  @override
  void initState() {
    super.initState();
    // The panel is dropped from the tree once it has finished closing, and
    // nothing else would rebuild at that moment — a fold that stayed built
    // after it closed would be a fold that never gave its content back.
    _fold.addStatusListener(_onFold);
  }

  void _onFold(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && !widget.keepMounted && mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(PlCollapsible oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.open != oldWidget.open) {
      widget.open ? _fold.forward() : _fold.reverse();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fold.duration = (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
        ? Duration.zero
        : PlassTokens.durationSlow;
  }

  @override
  void dispose() {
    _fold.removeStatusListener(_onFold);
    _fold.dispose();
    super.dispose();
  }

  void _toggle() => widget.onOpenChanged?.call(!widget.open);

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(widget.color);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final radius = BorderRadius.circular(PlassTokens.radius[widget.size]!);
    final padX = sheetPaddingX[widget.density]![widget.size]!;
    final padY = sheetPaddingY[widget.density]![widget.size]!;
    final body = sheetBody[widget.size]!;

    final header = widget.triggerBuilder != null
        ? widget.triggerBuilder!(context, widget.open, _toggle)
        : _header(tokens, family, reduceMotion: reduceMotion, padX: padX, padY: padY);

    // Kept in the tree only while there is something to see, unless the caller
    // asked otherwise: a `State` goes with its widget when it leaves the tree,
    // so a folded-away field forgets what was typed into it.
    final built = widget.keepMounted || widget.open || _fold.value > 0;

    Widget panel = built && widget.child != null
        ? DefaultTextStyle.merge(
            style: TextStyle(
              color: tokens.mutedFg,
              fontSize: body.size,
              height: body.height,
              leadingDistribution: TextLeadingDistribution.even,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: widget.padded ? padX : 0,
                right: widget.padded ? padX : 0,
                top: widget.padded && widget.triggerBuilder != null
                    ? _panelPaddingTop[widget.density]![widget.size]!
                    : 0,
                bottom: widget.padded ? _panelPaddingBottom[widget.density]![widget.size]! : 0,
              ),
              child: widget.child!,
            ),
          )
        : const SizedBox(width: double.infinity);

    if (widget.keepMounted && !widget.open) {
      // Clipped to nothing *and* out of the way: a panel nobody can see is not
      // one a keyboard should be able to tab into, and not one a screen reader
      // should be reading out.
      panel = ExcludeSemantics(child: ExcludeFocus(child: panel));
    }

    // The body is clipped rather than squashed while the panel moves, which is
    // what makes it a window opening onto the content rather than the content
    // being scaled.
    panel = SizeTransition(sizeFactor: _size, alignment: Alignment.topCenter, child: panel);

    return PlassSurfaceBox(
      surface: sheetSurface(tokens, variant: widget.variant, elevation: widget.elevation),
      borderRadius: radius,
      duration: PlassTokens.durationSlow,
      // The sheet clips, which is what makes the panel a window rather than
      // something that spills past the corners while it moves.
      child: ClipRRect(
        borderRadius: radius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.action == null)
              header
            else
              Row(
                children: <Widget>[
                  Expanded(child: header),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padX),
                    child: widget.action!,
                  ),
                ],
              ),
            panel,
          ],
        ),
      ),
    );
  }

  Widget _header(
    PlassTokens tokens,
    PlassColorFamily family, {
    required bool reduceMotion,
    required double padX,
    required double padY,
  }) {
    final title = sheetTitle[widget.size]!;

    return PlassInteractive(
      onTap: _toggle,
      interactive: _interactive,
      enabled: _interactive,
      cursor: _interactive ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      builder: (BuildContext context, PlassInteraction state) {
        final lit = widget.open || state.hovered;
        final ink = widget.disabled
            ? tokens.mutedFg
            : widget.open
            ? family.accent
            : tokens.fg;

        Widget row = AnimatedContainer(
          duration: reduceMotion ? Duration.zero : PlassTokens.duration,
          curve: PlassTokens.ease,
          decoration: BoxDecoration(color: lit && !widget.disabled ? family.soft : null),
          padding: EdgeInsets.symmetric(horizontal: padX, vertical: padY),
          child: Row(
            spacing: gap[widget.size]!,
            children: <Widget>[
              if (widget.startIcon != null)
                IconTheme.merge(
                  data: IconThemeData(color: tokens.mutedFg, size: title.size * iconScale),
                  child: widget.startIcon!,
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: sheetHeaderGap[widget.size]!,
                  children: <Widget>[
                    if (widget.title != null)
                      DefaultTextStyle.merge(
                        style: TextStyle(
                          color: ink,
                          fontSize: title.size,
                          height: title.height,
                          fontWeight: FontWeight.w600,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        child: widget.title!,
                      ),
                    if (widget.subtitle != null)
                      DefaultTextStyle.merge(
                        style: TextStyle(color: tokens.mutedFg, fontSize: metaText[widget.size]!),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        child: widget.subtitle!,
                      ),
                  ],
                ),
              ),
              // Turned, not moved. It is also the only thing on the header that
              // reports the open state by moving, which is why the header itself
              // only changes colour.
              if (widget.indicator)
                AnimatedRotation(
                  turns: widget.open ? 0.5 : 0,
                  duration: reduceMotion ? Duration.zero : PlassTokens.duration,
                  curve: PlassTokens.ease,
                  child: PlassGlyph(
                    PlassGlyphShape.chevron,
                    size: title.size * iconScale,
                    color: tokens.mutedFg,
                  ),
                ),
            ],
          ),
        );

        row = plassStateFilter(child: row, disabled: !_interactive, lit: false);

        if (state.focusVisible) {
          row = CustomPaint(
            // Inset, because the sheet clips its children so the panel can be a
            // window — and a clip takes a descendant's ring with it.
            foregroundPainter: PlassFocusRingPainter(
              color: family.ring,
              borderRadius: BorderRadius.zero,
              offset: -focusRingWidth,
            ),
            child: row,
          );
        }

        return Semantics(
          container: true,
          button: true,
          expanded: widget.open,
          enabled: _interactive,
          onTap: _interactive ? _toggle : null,
          child: row,
        );
      },
    );
  }
}
