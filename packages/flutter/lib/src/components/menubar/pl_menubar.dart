/// The strip of words at the top of an app.
library;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/menu/pl_menu.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// One menu on the bar: the word, and the rows behind it.
///
/// It has no `size`, `color` or `density` of its own — all three belong to the
/// bar, which is the only place they can be set once and hold for every menu on
/// it. The rows are the same [PlMenuEntry]s a [PlMenu] takes, because it *is*
/// the same menu.
@immutable
class PlMenubarMenu {
  /// Creates one menu on a bar.
  const PlMenubarMenu({
    required this.label,
    required this.items,
    this.startIcon,
    this.disabled = false,
  });

  /// The word on the bar.
  final String label;

  /// The rows, written exactly as they are inside a [PlMenu].
  final List<PlMenuEntry> items;

  /// Content before the label.
  final Widget? startIcon;

  /// Unavailable. The word stays on the bar and opens nothing.
  final bool disabled;
}

/// A menu bar's own row height, one rung below the control ladder at every step.
///
/// A menu bar is not a row of buttons — it is a strip of words, and the strip
/// is usually inside something that already has a height of its own: a
/// [PlToolbar], a [PlHeader]. Sized as controls, `File Edit View` would be
/// three buttons in a row and would make the bar taller than the thing it is
/// drawn on.
const Map<PlassSize, double> _triggerHeight = <PlassSize, double>{
  PlassSize.xs: 18,
  PlassSize.sm: 22,
  PlassSize.md: 26,
  PlassSize.lg: 32,
  PlassSize.xl: 40,
};

/// The strip of words at the top of an application — File, Edit, View — each of
/// which opens a menu.
///
/// ```dart
/// PlMenubar(
///   menus: <PlMenubarMenu>[
///     PlMenubarMenu(
///       label: 'File',
///       items: <PlMenuEntry>[PlMenuItem(label: 'New', onPressed: newFile)],
///     ),
///   ],
/// )
/// ```
///
/// What makes it a *bar* rather than a row of separate menus is that it is one
/// thing to a screen reader — a `menuBar` whose words are `menuItem`s — and
/// that only ever one of them is open. The React build also walks the pointer
/// through the strip once one is; this one does not, because an open menu's
/// dismiss layer is between the pointer and the words.
///
/// It draws **no surface of its own**. A menu bar sits *on* something — a
/// [PlToolbar], a [PlHeader] — and a sheet under a strip that is already on a
/// sheet is two sheets.
class PlMenubar extends StatefulWidget {
  /// Creates a menu bar.
  const PlMenubar({
    required this.menus,
    this.orientation = PlassOrientation.horizontal,
    this.disabled = false,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.semanticLabel,
    super.key,
  });

  /// The menus.
  final List<PlMenubarMenu> menus;

  /// Which way the bar runs.
  final PlassOrientation orientation;

  /// Disables every menu on the bar at once.
  final bool disabled;

  /// The strip's height and type scale — a rung below the control ladder.
  final PlassSize size;

  /// Semantic colour role. It reaches the hover, the open menu and the focus
  /// rings; the bar draws nothing.
  final PlassColor color;

  /// The padding beside each word. Even the default uses the compact track: a
  /// strip is not a row of buttons.
  final PlassDensity density;

  /// The name a screen reader gives the bar.
  final String? semanticLabel;

  @override
  State<PlMenubar> createState() => _PlMenubarState();
}

class _PlMenubarState extends State<PlMenubar> {
  @override
  Widget build(BuildContext context) {
    final bool vertical = widget.orientation == PlassOrientation.vertical;

    final List<Widget> words = <Widget>[
      for (int index = 0; index < widget.menus.length; index += 1) _menu(index),
    ];

    final Widget bar = vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: gap[widget.size]!,
            children: words,
          )
        : Row(mainAxisSize: MainAxisSize.min, spacing: gap[widget.size]!, children: words);

    return Semantics(
      role: SemanticsRole.menuBar,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: bar,
    );
  }

  Widget _menu(int index) {
    final PlMenubarMenu menu = widget.menus[index];
    final bool disabled = widget.disabled || menu.disabled;

    return PlMenu(
      items: menu.items,
      size: widget.size,
      color: widget.color,
      density: widget.density,
      disabled: disabled,
      sideOffset: 4,
      label: menu.label,
      trigger: (BuildContext context, VoidCallback open, bool isOpen) => _Word(
        menu: menu,
        open: isOpen,
        disabled: disabled,
        size: widget.size,
        color: widget.color,
        density: widget.density,
        onPressed: open,
      ),
    );
  }
}

/// One word on the strip.
class _Word extends StatelessWidget {
  const _Word({
    required this.menu,
    required this.open,
    required this.disabled,
    required this.size,
    required this.color,
    required this.density,
    required this.onPressed,
  });

  final PlMenubarMenu menu;
  final bool open;
  final bool disabled;
  final PlassSize size;
  final PlassColor color;
  final PlassDensity density;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final PlassColorFamily family = tokens.family(color);
    final double fontSize = controlText[size]!;
    final BorderRadius radius = BorderRadius.circular(PlassTokens.radius[size]!);
    // A word on a strip, not a key in a row: the compact track at every step,
    // because the default one would space three words like three buttons.
    final double padX = paddingX[PlassDensity.compact]![size]!;

    return PlassInteractive(
      enabled: !disabled,
      interactive: !disabled,
      onTap: onPressed,
      builder: (BuildContext context, PlassInteraction state) {
        final bool hovered = !disabled && state.hovered;
        // A menu bar is the one place where "this one is open" has to be
        // legible from across the bar, and it is still colour and nothing
        // else: the word does not move and the strip does not change height.
        final Color ink = open ? family.accent : tokens.fg;

        Widget word = SizedBox(
          height: _triggerHeight[size]!,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padX),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: gap[size]!,
              children: <Widget>[
                ?menu.startIcon,
                Center(
                  child: Text(
                    menu.label,
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
                ),
              ],
            ),
          ),
        );

        word = PlassSurfaceBox(
          surface: PlassSurface(
            fill: open
                ? family.softHover
                : hovered
                ? family.soft
                : null,
            ink: ink,
          ),
          borderRadius: radius,
          child: word,
        );

        word = plassStateFilter(child: word, disabled: disabled, lit: false);

        if (state.focusVisible) {
          word = CustomPaint(
            // Turned inward, because a word on a strip has a neighbour a hair
            // away on each side and a ring drawn outside it would overlap
            // them.
            foregroundPainter: PlassFocusRingPainter(
              color: family.ring,
              borderRadius: radius,
              offset: -focusRingWidth,
            ),
            child: word,
          );
        }

        return Semantics(
          role: SemanticsRole.menuItem,
          button: true,
          enabled: !disabled,
          expanded: open,
          label: menu.label,
          onTap: disabled ? null : onPressed,
          // The label is said once, by the node — the word under it would
          // otherwise arrive as a second copy of itself.
          child: ExcludeSemantics(child: word),
        );
      },
    );
  }
}
