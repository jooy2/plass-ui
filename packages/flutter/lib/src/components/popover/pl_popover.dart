/// A sheet that opens beside the thing that opened it.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/anchored.dart';
import 'package:plass_ui/src/internal/dismiss.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/internal/wedge.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How wide the popup is allowed to get, per [PlassSize].
///
/// The same axis a modal folds its width into, one rung narrower at every step
/// because a popover is a detail beside a control rather than a sheet in the
/// middle of the screen.
const Map<PlassSize, double> _maxWidth = <PlassSize, double>{
  PlassSize.xs: 224,
  PlassSize.sm: 256,
  PlassSize.md: 320,
  PlassSize.lg: 384,
  PlassSize.xl: 512,
};

/// The wedge, at roughly a third of the sheet's corner radius per step.
const Map<PlassSize, double> _arrowSize = <PlassSize, double>{
  PlassSize.xs: 8,
  PlassSize.sm: 9,
  PlassSize.md: 10,
  PlassSize.lg: 11,
  PlassSize.xl: 12,
};

/// How large the × is drawn against the title beside it.
const double _closeScale = 1.6;

/// The gap between the header and the × in the corner.
const double _closeGap = 12;

/// A sheet that opens beside the thing that opened it.
///
/// ```dart
/// PlPopover(
///   open: explaining,
///   onOpenChanged: (bool next) => setState(() => explaining = next),
///   title: const Text('Effective rate'),
///   child: const Text('The base rate plus whatever your plan adds to it.'),
///   trigger: PlButton(
///     onPressed: () => setState(() => explaining = true),
///     child: const Text('How is this worked out?'),
///   ),
/// )
/// ```
///
/// Three floating surfaces, three different jobs, and what separates them is
/// what a reader can *do* with them. A [PlTooltip] is a **note** about something
/// else — it appears while the pointer is there and nothing in it can be
/// reached. A [PlModal] takes the screen away until it is answered. A popover is
/// the middle one: it stays up until it is dismissed, it can be entered, and
/// what is inside it can be pressed and typed into while the screen behind goes
/// on working.
///
/// There is no `variant` and no `elevation`. The three materials answer "how
/// much does this surface assert itself against the screen", and a popup that
/// had to be **asked for** has already answered it; a popover genuinely floats,
/// which is the one case the elevation ladder exists for.
///
/// Needs an [Overlay] above it, which `WidgetsApp` with a navigator and
/// `MaterialApp` both provide.
class PlPopover extends StatefulWidget {
  /// Creates a popover.
  const PlPopover({
    required this.open,
    required this.trigger,
    this.onOpenChanged,
    this.child,
    this.title,
    this.description,
    this.side = PlassSide.bottom,
    this.align = PlassAlign.center,
    this.offset = 6,
    this.arrow = false,
    this.dismissible = true,
    this.showClose = false,
    this.closeLabel,
    this.width,
    this.size,
    this.color,
    this.density,
    super.key,
  });

  /// Whether the popup is up.
  final bool open;

  /// The element the popup hangs off.
  ///
  /// Required here where the React build makes it optional: a browser can
  /// position a popup against the viewport when it has no anchor, and a
  /// [LayerLink] has nothing to follow without one.
  final Widget trigger;

  /// Called with what the open state should become.
  final ValueChanged<bool>? onOpenChanged;

  /// The body.
  final Widget? child;

  /// The heading, and the popup's name.
  final Widget? title;

  /// A line under the title.
  final Widget? description;

  /// Which edge of the trigger it appears on.
  ///
  /// Flips to the opposite side when there is no room there. It never *slides*
  /// along the edge it is on, which is what keeps an arrow pointing at the thing
  /// it belongs to.
  final PlassSide side;

  /// Where it sits along that edge.
  final PlassAlign align;

  /// How far it stands off the trigger, in logical pixels.
  final double offset;

  /// Draws the little wedge pointing at the trigger.
  ///
  /// Off by default, unlike on a [PlTooltip]. A tooltip is a filled plate and
  /// its wedge is the same solid colour; this surface is translucent over a
  /// blurred backdrop, and a wedge sticking out past the popup's own box cannot
  /// carry that backdrop with it.
  final bool arrow;

  /// Whether a press outside closes the popup.
  ///
  /// Turn it off only for a popup with its own way out, because there will be
  /// no other.
  final bool dismissible;

  /// Shows the × in the corner.
  final bool showClose;

  /// The name a screen reader gives the ×. Never drawn.
  final String? closeLabel;

  /// A hard cap on the popup's width, overriding the one [size] implies.
  final double? width;

  /// The radius, the padding and how wide the popup is allowed to get.
  final PlassSize? size;

  /// Semantic colour role. It reaches the focus rings inside and nothing else.
  final PlassColor? color;

  /// The popup's inner padding.
  final PlassDensity? density;

  @override
  State<PlPopover> createState() => _PlPopoverState();
}

class _PlPopoverState extends State<PlPopover> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  /// The side the popup actually ended up on, once a flip has been resolved.
  late PlassSide _side = widget.side;

  @override
  void didUpdateWidget(PlPopover oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.side != oldWidget.side) {
      _side = widget.side;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(_color);
    final insetX = sheetPaddingX[_density]![_size]!;
    final insetY = sheetPaddingY[_density]![_size]!;
    final body = sheetBody[_size]!;
    final radius = BorderRadius.circular(PlassTokens.radius[_size]!);
    final hasHeader = widget.title != null || widget.description != null;

    void close() => widget.onOpenChanged?.call(false);

    // The same frosted panel a select's list and a modal draw, and for the same
    // reason it carries the top of the shadow ladder: it is one of the few
    // surfaces in the library that is genuinely meant to float.
    final surface = PlassSurface(
      fill: tokens.glassPress,
      border: Border.all(color: tokens.glassLine, width: hairline),
      ink: tokens.fg,
      blur: true,
      insets: <PlassInsetShadow>[tokens.glossGlass],
      shadows: tokens.elevation(plassElevationMax),
    );

    Widget popup = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.width ?? _maxWidth[_size]!),
      child: PlassSurfaceBox(
        surface: surface,
        borderRadius: radius,
        duration: PlassTokens.durationSlow,
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: tokens.fg,
            fontSize: body.size,
            height: body.height,
            leadingDistribution: TextLeadingDistribution.even,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: insetX, vertical: insetY),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              spacing: sheetSectionGap[_size]!,
              children: <Widget>[
                if (hasHeader || widget.showClose)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: _closeGap,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          spacing: sheetHeaderGap[_size]!,
                          children: <Widget>[
                            if (widget.title != null)
                              DefaultTextStyle.merge(
                                style: TextStyle(
                                  color: tokens.fg,
                                  fontSize: sheetTitle[_size]!.size,
                                  height: sheetTitle[_size]!.height,
                                  fontWeight: FontWeight.w600,
                                  leadingDistribution: TextLeadingDistribution.even,
                                ),
                                // The heading is what names the popup, so it is
                                // announced as one rather than read as the first
                                // line of the body.
                                child: Semantics(header: true, child: widget.title!),
                              ),
                            if (widget.description != null)
                              DefaultTextStyle.merge(
                                style: TextStyle(color: tokens.mutedFg, fontSize: metaText[_size]!),
                                child: widget.description!,
                              ),
                          ],
                        ),
                      ),
                      if (widget.showClose)
                        PlassDismissButton(
                          label: widget.closeLabel ?? PlassTheme.labelsOf(context).close,
                          onPressed: close,
                          size: sheetTitle[_size]!.size * _closeScale,
                          color: tokens.mutedFg,
                          ring: family.ring,
                        ),
                    ],
                  ),
                if (widget.child != null) widget.child!,
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.arrow) {
      popup = PlassWedged(
        side: _side,
        size: _arrowSize[_size]!,
        fill: tokens.glassPress,
        line: tokens.glassLine,
        child: popup,
      );
    }

    return PlassAnchoredPortal(
      open: widget.open,
      side: widget.side,
      align: widget.align,
      offset: widget.offset,
      onDismiss: widget.dismissible ? close : null,
      onSideResolved: (PlassSide side) {
        if (mounted && side != _side) {
          setState(() => _side = side);
        }
      },
      popup: popup,
      child: widget.trigger,
    );
  }
}
