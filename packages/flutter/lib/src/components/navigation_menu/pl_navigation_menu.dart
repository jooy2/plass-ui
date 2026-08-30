/// A site's navigation: a row of destinations.
library;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/anchored.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// One row inside a panel: where it goes, what it is called, and a line saying
/// what is there.
@immutable
class PlNavigationMenuLink {
  /// Creates a row in a panel.
  const PlNavigationMenuLink({
    required this.title,
    this.description,
    this.startIcon,
    this.onPressed,
  });

  /// The row's name.
  final String title;

  /// A second line under it, one step down the scale and muted.
  final String? description;

  /// A glyph before the title.
  final Widget? startIcon;

  /// Where it goes.
  ///
  /// There is no `href` here and there is no navigator in this package: where a
  /// destination *is* belongs to the app's own router. This is where that is
  /// decided, exactly as on [PlTextLink].
  final VoidCallback? onPressed;
}

/// One word in the row, and what opens under it.
@immutable
class PlNavigationMenuItem {
  /// Creates an item.
  ///
  /// With [links] it is a trigger and a panel; with an [onPressed] and no links
  /// it is a destination, and the difference is not cosmetic — the second is
  /// announced as a link and the first as something that expands.
  const PlNavigationMenuItem({
    required this.label,
    this.value,
    this.onPressed,
    this.startIcon,
    this.disabled = false,
    this.columns = 1,
    this.links = const <PlNavigationMenuLink>[],
  });

  /// The word in the row.
  final String label;

  /// Identifies the item, for a controlled menu. Left out, the label is used.
  final String? value;

  /// Makes the item a destination rather than something that opens a panel.
  final VoidCallback? onPressed;

  /// Content before the label.
  final Widget? startIcon;

  /// Unavailable. The word stays in the row and opens nothing.
  final bool disabled;

  /// How many columns the panel lays its links out in.
  final int columns;

  /// The panel's contents.
  final List<PlNavigationMenuLink> links;

  /// What identifies this item in the menu's value.
  String get key => value ?? label;

  /// Whether it opens a panel at all.
  bool get opensPanel => links.isNotEmpty;
}

/// How much room the panel keeps around its links, per step.
const Map<PlassSize, double> _panelPadding = <PlassSize, double>{
  PlassSize.xs: 4,
  PlassSize.sm: 6,
  PlassSize.md: 8,
  PlassSize.lg: 10,
  PlassSize.xl: 12,
};

/// A site's navigation: a row of destinations, some of which open a panel of
/// more of them.
///
/// ```dart
/// PlNavigationMenu(
///   items: <PlNavigationMenuItem>[
///     PlNavigationMenuItem(
///       label: 'Product',
///       columns: 2,
///       links: <PlNavigationMenuLink>[
///         PlNavigationMenuLink(title: 'Analytics', onPressed: openAnalytics),
///       ],
///     ),
///     PlNavigationMenuItem(label: 'Pricing', onPressed: openPricing),
///   ],
/// )
/// ```
///
/// The difference from a [PlMenu] is what the rows *are*. A menu holds actions;
/// this holds destinations, and it says so — an item that goes somewhere is
/// announced as a link, an item that opens a panel as something that expands.
///
/// The row carries **no surface at rest**: the words are the screen's own, and
/// five bordered boxes across the top of an app is a toolbar rather than a
/// navigation. The family arrives with the pointer and with the open panel.
class PlNavigationMenu extends StatefulWidget {
  /// Creates a navigation row.
  const PlNavigationMenu({
    required this.items,
    this.initialValue,
    this.onValueChanged,
    this.orientation = PlassOrientation.horizontal,
    this.delay = const Duration(milliseconds: 50),
    this.closeDelay = const Duration(milliseconds: 100),
    this.sideOffset = 8,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.semanticLabel,
    super.key,
  });

  /// The items.
  final List<PlNavigationMenuItem> items;

  /// Which item's panel starts open, by its key. `null` is closed, which is
  /// what a navigation almost always wants.
  ///
  /// There is no controlled mode here, and that is the one thing the React
  /// build offers that this does not. Which panel is open is transient state
  /// belonging to the pointer and the keyboard rather than to the app — unlike
  /// a `PlSelect`'s value, which is the app's data — and `String?` has no way
  /// to tell "the caller did not say" from "the caller says closed", so a
  /// controlled mode would be a mode that could never be closed from outside.
  final String? initialValue;

  /// Called when the open panel changes.
  final ValueChanged<String?>? onValueChanged;

  /// Which way the row runs. [PlassOrientation.vertical] is a nav rail whose
  /// panels open beside it.
  final PlassOrientation orientation;

  /// How long the pointer rests before a panel opens.
  final Duration delay;

  /// How long a panel stays after the pointer leaves.
  final Duration closeDelay;

  /// Distance from the row, in logical pixels.
  final double sideOffset;

  /// The row's height and type scale, and the panel's radius and padding.
  final PlassSize size;

  /// Semantic colour role. It reaches the hover, the open item and the focus
  /// rings; the sheet is never dyed.
  final PlassColor color;

  /// Changes the padding and nothing else.
  final PlassDensity density;

  /// The name the navigation region is announced by.
  ///
  /// Worth writing when a screen has more than one, because a landmark list
  /// that says "navigation" twice has told the reader which is which not at
  /// all — and Flutter refuses a duplicated landmark with no label outright.
  final String? semanticLabel;

  @override
  State<PlNavigationMenu> createState() => _PlNavigationMenuState();
}

class _PlNavigationMenuState extends State<PlNavigationMenu> {
  late String? _value = widget.initialValue;
  Timer? _openTimer;
  Timer? _closeTimer;

  @override
  void dispose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    super.dispose();
  }

  void _set(String? next) {
    _openTimer?.cancel();
    _closeTimer?.cancel();

    if (_value == next) return;

    setState(() => _value = next);
    widget.onValueChanged?.call(next);
  }

  /// The pointer arriving over an item.
  ///
  /// Crossing from one open panel to the next is **immediate**: the reader has
  /// already asked for a panel, and a delay there reads as the row lagging.
  /// Opening the first one waits, so a pointer travelling past the row on its
  /// way somewhere else does not drop a panel over the screen.
  void _hover(PlNavigationMenuItem item) {
    _closeTimer?.cancel();

    if (!item.opensPanel || item.disabled) {
      return;
    }

    if (_value != null) {
      _set(item.key);
      return;
    }

    _openTimer?.cancel();
    _openTimer = Timer(widget.delay, () => _set(item.key));
  }

  void _leave() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _closeTimer = Timer(widget.closeDelay, () => _set(null));
  }

  @override
  Widget build(BuildContext context) {
    final bool vertical = widget.orientation == PlassOrientation.vertical;

    final List<Widget> row = <Widget>[
      for (final PlNavigationMenuItem item in widget.items) _item(item),
    ];

    final Widget band = vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: gap[widget.size]!,
            children: row,
          )
        : Row(mainAxisSize: MainAxisSize.min, spacing: gap[widget.size]!, children: row);

    return Semantics(
      role: SemanticsRole.navigation,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: MouseRegion(onExit: (PointerExitEvent event) => _leave(), child: band),
    );
  }

  Widget _item(PlNavigationMenuItem item) {
    final bool open = item.opensPanel && _value == item.key;

    final Widget trigger = _Trigger(
      item: item,
      open: open,
      size: widget.size,
      color: widget.color,
      density: widget.density,
      onHover: () => _hover(item),
      onPressed: item.disabled
          ? null
          : item.opensPanel
          ? () => _set(open ? null : item.key)
          : item.onPressed,
    );

    if (!item.opensPanel) {
      return trigger;
    }

    return PlassAnchoredPortal(
      open: open,
      side: widget.orientation == PlassOrientation.vertical ? PlassSide.right : PlassSide.bottom,
      align: PlassAlign.start,
      offset: widget.sideOffset,
      onDismiss: () => _set(null),
      popup: _Panel(
        item: item,
        size: widget.size,
        color: widget.color,
        density: widget.density,
        onEnter: () => _closeTimer?.cancel(),
        onExit: _leave,
        onChosen: () => _set(null),
      ),
      child: trigger,
    );
  }
}

/// One word in the row.
class _Trigger extends StatelessWidget {
  const _Trigger({
    required this.item,
    required this.open,
    required this.size,
    required this.color,
    required this.density,
    required this.onHover,
    required this.onPressed,
  });

  final PlNavigationMenuItem item;
  final bool open;
  final PlassSize size;
  final PlassColor color;
  final PlassDensity density;
  final VoidCallback onHover;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final PlassColorFamily family = tokens.family(color);
    final bool reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final double fontSize = controlText[size]!;
    final BorderRadius radius = BorderRadius.circular(PlassTokens.radius[size]!);

    return MouseRegion(
      onEnter: (PointerEnterEvent event) => onHover(),
      child: PlassInteractive(
        enabled: !item.disabled,
        interactive: !item.disabled,
        onTap: onPressed,
        builder: (BuildContext context, PlassInteraction state) {
          final bool hovered = !item.disabled && state.hovered;
          final Color ink = open ? family.accent : tokens.fg;

          Widget content = Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingX[density]![size]!),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: gap[size]!,
              children: <Widget>[
                ?item.startIcon,
                Text(
                  item.label,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    color: ink,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    height: 1,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                ),
                if (item.opensPanel)
                  // Drawn pointing down and turned when the panel is open, which
                  // is the one allowance the no-transform rule makes: a glyph
                  // rotating is not a control moving.
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: reduceMotion ? Duration.zero : PlassTokens.duration,
                    curve: PlassTokens.ease,
                    child: PlassGlyph(
                      PlassGlyphShape.chevron,
                      size: fontSize * iconScale,
                      color: ink,
                    ),
                  ),
              ],
            ),
          );

          content = SizedBox(
            height: controlHeight[size]!,
            child: Center(child: content),
          );

          // No surface at rest: the words are the screen's own. The family
          // arrives with the pointer and with the open panel.
          Widget trigger = PlassSurfaceBox(
            surface: PlassSurface(
              fill: open
                  ? family.softHover
                  : hovered
                  ? family.soft
                  : null,
              ink: ink,
            ),
            borderRadius: radius,
            reduceMotion: reduceMotion,
            child: content,
          );

          trigger = plassStateFilter(child: trigger, disabled: item.disabled, lit: false);

          if (state.focusVisible) {
            trigger = CustomPaint(
              foregroundPainter: PlassFocusRingPainter(color: family.ring, borderRadius: radius),
              child: trigger,
            );
          }

          return trigger;
        },
      ),
    );
  }
}

/// What opens under a word.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.item,
    required this.size,
    required this.color,
    required this.density,
    required this.onEnter,
    required this.onExit,
    required this.onChosen,
  });

  final PlNavigationMenuItem item;
  final PlassSize size;
  final PlassColor color;
  final PlassDensity density;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final VoidCallback onChosen;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final double pad = _panelPadding[size]!;

    final List<Widget> rows = <Widget>[
      for (final PlNavigationMenuLink link in item.links)
        _Link(link: link, size: size, color: color, density: density, onChosen: onChosen),
    ];

    // One column is a column; more than one is a grid of equal columns, which
    // `Wrap` cannot promise — so the rows are dealt into that many `Column`s.
    final Widget body = item.columns > 1
        ? Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: <Widget>[
              for (int column = 0; column < item.columns; column += 1)
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 4,
                    children: <Widget>[
                      for (int index = column; index < rows.length; index += item.columns)
                        rows[index],
                    ],
                  ),
                ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 4,
            children: rows,
          );

    return MouseRegion(
      onEnter: (PointerEnterEvent event) => onEnter(),
      onExit: (PointerExitEvent event) => onExit(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: PlassSurfaceBox(
          // The same frosted sheet a `PlMenu` and a `PlPopover` draw.
          surface: PlassSurface(
            fill: tokens.glassPress,
            border: Border.all(color: tokens.glassLine, width: hairline),
            ink: tokens.fg,
            blur: true,
            insets: <PlassInsetShadow>[tokens.glossGlass],
            shadows: tokens.elevation(3),
          ),
          borderRadius: BorderRadius.circular(PlassTokens.radius[size]!),
          child: Padding(padding: EdgeInsets.all(pad), child: body),
        ),
      ),
    );
  }
}

/// One row in a panel.
class _Link extends StatelessWidget {
  const _Link({
    required this.link,
    required this.size,
    required this.color,
    required this.density,
    required this.onChosen,
  });

  final PlNavigationMenuLink link;
  final PlassSize size;
  final PlassColor color;
  final PlassDensity density;
  final VoidCallback onChosen;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final PlassColorFamily family = tokens.family(color);
    final PlassTextScale title = controlTextLeading[size]!;
    final BorderRadius radius = BorderRadius.circular(PlassTokens.radius[size]!);

    return PlassInteractive(
      onTap: link.onPressed == null
          ? null
          : () {
              onChosen();
              link.onPressed!();
            },
      interactive: link.onPressed != null,
      builder: (BuildContext context, PlassInteraction state) {
        Widget row = Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingX[density]![size]!, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: gap[size]!,
            children: <Widget>[
              ?link.startIcon,
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: <Widget>[
                    Text(
                      link.title,
                      style: TextStyle(
                        color: tokens.fg,
                        fontSize: title.size,
                        height: title.height,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (link.description != null)
                      Text(
                        link.description!,
                        style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );

        row = PlassSurfaceBox(
          surface: PlassSurface(fill: state.hovered ? family.soft : null, ink: tokens.fg),
          borderRadius: radius,
          child: row,
        );

        if (state.focusVisible) {
          row = CustomPaint(
            // Turned inward: the panel clips, so a ring drawn outside a row
            // would have its top or its bottom sliced off by the sheet's own
            // corners.
            foregroundPainter: PlassFocusRingPainter(
              color: family.ring,
              borderRadius: radius,
              offset: -focusRingWidth,
            ),
            child: row,
          );
        }

        return Semantics(link: true, button: false, child: row);
      },
    );
  }
}
