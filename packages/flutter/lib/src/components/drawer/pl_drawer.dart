/// A panel attached to one edge of the screen.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/dismiss.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/portal.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How the panel relates to the screen.
enum PlDrawerMode {
  /// It is opened, it floats over the screen on a scrim, it holds the focus,
  /// and it is dismissed. The navigation drawer behind a hamburger, the filter
  /// panel beside a table.
  overlay,

  /// It is part of the layout and the screen is laid out around it. No scrim,
  /// no portal, no focus trap, nothing to dismiss. The sidebar that is simply
  /// there.
  inline,
}

/// How far the scrim behind an overlay drawer blurs the screen. The same
/// whisper a modal's does, and it has to be: the two are the same layer.
const double _scrimBlur = 2;

/// How much of the screen a `top` or `bottom` panel is allowed to take when it
/// has not been given an extent.
///
/// A bottom sheet holding three rows should be three rows tall, so the height
/// is the content's — this is only the ceiling.
const double _crossExtent = 0.85;

/// How wide a `left` or `right` panel is when nothing says otherwise.
///
/// Its own ladder rather than a modal's max width, and deliberately narrower at
/// every step: a modal is measured by how long a line of text is comfortable
/// inside it, and a drawer is measured by how much of the screen it is willing
/// to take away from what it is a drawer *for*.
const Map<PlassSize, double> _extent = <PlassSize, double>{
  PlassSize.xs: 224,
  PlassSize.sm: 256,
  PlassSize.md: 320,
  PlassSize.lg: 384,
  PlassSize.xl: 448,
};

/// How large the × is drawn against the title beside it.
const double _closeScale = 1.6;

/// The gap between the header and the × in the corner.
const double _closeGap = 12;

/// The gap between two buttons in the actions row.
const double _actionsGap = 8;

/// A panel attached to one edge of the screen.
///
/// ```dart
/// PlDrawer(
///   side: PlassSide.right,
///   open: filtering,
///   onOpenChanged: (bool next) => setState(() => filtering = next),
///   title: const Text('Filters'),
///   child: const FilterForm(),
/// )
/// ```
///
/// Two things in one widget, because they are the same panel: [PlDrawerMode
/// .overlay] is the drawer you open — a scrim, a focus trap, <kbd>Escape</kbd> —
/// and [PlDrawerMode.inline] is the drawer that is simply part of the screen.
/// Everything else about them is identical, which is exactly why they should not
/// be two widgets a caller has to switch between when a sidebar becomes a
/// hamburger at a breakpoint.
///
/// The sections are parameters rather than sub-widgets, as on a [PlCard] and a
/// [PlModal]: the arrangement is fixed — heading, description, body, actions —
/// and what a caller wants to decide is what goes in each slot. The body is the
/// only part that scrolls, so the heading and the actions stay put.
///
/// There is no `variant` and no `elevation`. The three materials answer "how
/// much does this surface assert itself against the screen", and a panel that
/// has taken an **edge** of it has answered: an overlay drawer floats and
/// carries a shadow at the top of the ladder, an inline one is part of the
/// layout and carries none.
///
/// Nothing slides. A drawer that slid in would be dragging its own text across
/// the screen for the length of the transition, and a panel is nothing *but*
/// text and controls — this is the case the no-transform rule was written for,
/// not the exception to it. What says the panel came from an edge is that it is
/// **attached** to one.
///
/// An overlay drawer needs an [Overlay] above it, which `WidgetsApp` with a
/// navigator and `MaterialApp` both provide.
class PlDrawer extends StatelessWidget {
  /// Creates a drawer.
  const PlDrawer({
    required this.open,
    this.onOpenChanged,
    this.child,
    this.side = PlassSide.left,
    this.mode = PlDrawerMode.overlay,
    this.title,
    this.description,
    this.actions,
    this.dividers = false,
    this.showClose,
    this.closeLabel = 'Close',
    this.extent,
    this.rounded = true,
    this.modal = true,
    this.dismissible = true,
    this.size,
    this.color,
    this.density,
    super.key,
  });

  /// Whether the drawer is shown.
  ///
  /// In [PlDrawerMode.inline] a closed drawer is **not in the layout at all**:
  /// the screen around it is what moves, and moving the screen is not this
  /// widget's to do.
  final bool open;

  /// Called with what the open state should become.
  ///
  /// This is the only way a drawer closes itself: it is **controlled**, like
  /// every other stateful thing in the package, so the × and a press outside
  /// both report rather than act.
  final ValueChanged<bool>? onOpenChanged;

  /// The body — the only part that scrolls.
  final Widget? child;

  /// Which edge the panel is attached to.
  ///
  /// Physical rather than logical, the way [PlassSide] is everywhere: a drawer
  /// along the top of the screen is along the top in every writing direction.
  final PlassSide side;

  /// Whether the panel is opened over the screen or is part of it.
  final PlDrawerMode mode;

  /// The heading, and the drawer's name.
  final Widget? title;

  /// A line under the title.
  final Widget? description;

  /// The bottom row, held against the foot of the panel while the body scrolls.
  final List<Widget>? actions;

  /// Scores the panel between the header, the body and the actions instead of
  /// separating them with space.
  ///
  /// Worth turning on the moment the body scrolls: the lines are what say the
  /// header stayed put.
  final bool dividers;

  /// Shows the × in the corner.
  ///
  /// On in [PlDrawerMode.overlay], where the panel has taken the screen and the
  /// way out should not have to be remembered; off in [PlDrawerMode.inline],
  /// where a × that closes a fixed sidebar with nothing to reopen it is a
  /// one-way door.
  final bool? showClose;

  /// The name a screen reader gives the ×. Never drawn.
  final String closeLabel;

  /// How far the panel reaches in from its edge: a **width** for
  /// [PlassSide.left] and [PlassSide.right], a **height** for [PlassSide.top]
  /// and [PlassSide.bottom], in logical pixels.
  ///
  /// Left out, a side panel takes the width its [size] implies and a top or
  /// bottom panel is as tall as what is in it, up to 85% of the screen.
  final double? extent;

  /// Rounds the two corners on the edge that faces the screen.
  ///
  /// The corners against the screen's edge are always square, because a corner
  /// cut off something that has no visible end is a corner cut off nothing.
  final bool rounded;

  /// Whether the screen behind is taken away for the pointer as well as the
  /// keyboard. [PlDrawerMode.overlay] only.
  final bool modal;

  /// Whether <kbd>Escape</kbd> or a press on the scrim closes the drawer.
  ///
  /// Turn it off for the drawer that has to be answered — and then give it
  /// actions that answer it, because there will be no other way out.
  /// [PlDrawerMode.overlay] only.
  final bool dismissible;

  /// The panel's width, radius and padding.
  final PlassSize? size;

  /// Semantic colour role. It reaches the focus rings inside and nothing else:
  /// what a drawer holds arrives with its own colours.
  final PlassColor? color;

  /// How tightly the sections pack.
  final PlassDensity? density;

  bool get _along => side == PlassSide.left || side == PlassSide.right;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final overlay = mode == PlDrawerMode.overlay;

    void close() => onOpenChanged?.call(false);

    if (!overlay) {
      // An inline drawer is in the flow, so "closed" is "not in the layout".
      // There is nothing to animate on the way out: the screen around it is
      // what moves.
      if (!open) {
        return const SizedBox.shrink();
      }

      return _panel(context, tokens, close, floating: false);
    }

    return PlassPortal(
      open: open,
      modal: modal,
      barrierColor: tokens.scrim,
      barrierBlur: _scrimBlur,
      onDismiss: dismissible ? close : null,
      child: Align(
        alignment: switch (side) {
          PlassSide.left => Alignment.centerLeft,
          PlassSide.right => Alignment.centerRight,
          PlassSide.top => Alignment.topCenter,
          PlassSide.bottom => Alignment.bottomCenter,
        },
        child: GestureDetector(
          // A press on the panel is not a press outside it.
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: _panel(context, tokens, close, floating: true),
        ),
      ),
    );
  }

  Widget _panel(
    BuildContext context,
    PlassTokens tokens,
    VoidCallback close, {
    required bool floating,
  }) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
    final density = this.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

    final family = tokens.family(color);
    final insetX = sheetPaddingX[density]![size]!;
    final insetY = sheetPaddingY[density]![size]!;
    final body = sheetBody[size]!;
    final radius = PlassTokens.radius[size]!;
    final hasHeader = title != null || description != null;
    final hasActions = actions != null && actions!.isNotEmpty;
    final drawClose = showClose ?? floating;
    final screen = MediaQuery.sizeOf(context);

    // Square against the screen and cut on the free side: the corners that face
    // the screen take the house fillet, the two against the edge do not.
    final corners = !rounded
        ? BorderRadius.zero
        : switch (side) {
            PlassSide.left => BorderRadius.horizontal(right: Radius.circular(radius)),
            PlassSide.right => BorderRadius.horizontal(left: Radius.circular(radius)),
            PlassSide.top => BorderRadius.vertical(bottom: Radius.circular(radius)),
            PlassSide.bottom => BorderRadius.vertical(top: Radius.circular(radius)),
          };

    // The hairline on the free edge only. A border all round would draw a line
    // along the screen's own edge, where there is nothing on the other side of
    // it to be separated from.
    final edge = BorderSide(color: tokens.glassLine, width: hairline);
    final border = switch (side) {
      PlassSide.left => Border(right: edge),
      PlassSide.right => Border(left: edge),
      PlassSide.top => Border(bottom: edge),
      PlassSide.bottom => Border(top: edge),
    };

    final surface = PlassSurface(
      fill: tokens.glassPress,
      border: border,
      ink: tokens.fg,
      blur: true,
      insets: <PlassInsetShadow>[tokens.glossGlass],
      // One past the ladder any other component can ask for while it floats,
      // and nothing at all while it is part of the layout.
      shadows: floating ? tokens.elevation(plassElevationMax + 1) : const <BoxShadow>[],
    );

    final sections = <({Widget child, bool flexible})>[
      if (hasHeader || drawClose)
        (
          flexible: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: _closeGap,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: sheetHeaderGap[size]!,
                  children: <Widget>[
                    if (title != null)
                      DefaultTextStyle.merge(
                        style: TextStyle(
                          color: tokens.fg,
                          fontSize: sheetTitle[size]!.size,
                          height: sheetTitle[size]!.height,
                          fontWeight: FontWeight.w600,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                        // The heading is what names the drawer, so it is
                        // announced as one rather than read as the first line of
                        // the body.
                        child: Semantics(header: true, child: title!),
                      ),
                    if (description != null)
                      DefaultTextStyle.merge(
                        style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                        child: description!,
                      ),
                  ],
                ),
              ),
              if (drawClose)
                PlassDismissButton(
                  label: closeLabel,
                  onPressed: close,
                  size: sheetTitle[size]!.size * _closeScale,
                  color: tokens.mutedFg,
                  ring: family.ring,
                ),
            ],
          ),
        ),
      if (child != null)
        // The one part that scrolls, and the only one allowed to give way when
        // the panel runs out of screen: a header that scrolled away would take
        // the drawer's name with it.
        (flexible: true, child: SingleChildScrollView(child: child)),
      if (hasActions)
        (
          flexible: false,
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: _actionsGap,
            runSpacing: _actionsGap,
            children: actions!,
          ),
        ),
    ];

    Widget panel = DefaultTextStyle.merge(
      style: TextStyle(
        color: tokens.fg,
        fontSize: body.size,
        height: body.height,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: dividers ? 0 : insetY),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: dividers ? 0 : sheetSectionGap[size]!,
          children: <Widget>[
            for (var index = 0; index < sections.length; index += 1)
              switch (sections[index]) {
                (:final bool flexible, :final Widget child) => () {
                  final band = _Section(
                    ruled: dividers && index > 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: insetX,
                      vertical: dividers ? insetY : 0,
                    ),
                    rule: tokens.divider,
                    child: child,
                  );

                  return flexible ? Flexible(child: band) : band;
                }(),
              },
          ],
        ),
      ),
    );

    panel = PlassSurfaceBox(surface: surface, borderRadius: corners, child: panel);

    // A side panel is as tall as the screen and as wide as its extent; a top or
    // bottom one is the other way round, and as tall as what is in it up to a
    // ceiling.
    return ConstrainedBox(
      constraints: _along
          ? BoxConstraints.tightFor(width: extent ?? _extent[size]!, height: double.infinity)
          : BoxConstraints(
              minWidth: double.infinity,
              maxWidth: double.infinity,
              maxHeight: extent ?? screen.height * _crossExtent,
            ),
      child: panel,
    );
  }
}

/// One band of the panel, with the rule above it when the panel is scored.
///
/// A `Flexible` section has to stay flexible, and wrapping it in a
/// `DecoratedBox` inside the column would hand the scroll view an unbounded
/// height — so the decoration goes *around* the padding and the flex stays where
/// the column can see it. The same shape a modal's sections take.
class _Section extends StatelessWidget {
  const _Section({
    required this.ruled,
    required this.padding,
    required this.rule,
    required this.child,
  });

  final bool ruled;
  final EdgeInsets padding;
  final Color rule;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: ruled
            ? Border(
                top: BorderSide(color: rule, width: hairline),
              )
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
