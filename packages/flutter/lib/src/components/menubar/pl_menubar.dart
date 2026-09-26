/// The strip of words at the top of an app.
library;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/menu/pl_menu.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/ink.dart';
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
/// that only ever one of them is open. It is one thing to the keyboard as well:
/// one tab stop, with the arrow keys moving along the strip, because that is
/// what the role promises a reader who hears it. The React build also walks the
/// pointer through the strip once one is; this one does not, because an open
/// menu's dismiss layer is between the pointer and the words.
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
    this.size,
    this.color,
    this.density,
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
  final PlassSize? size;

  /// Semantic colour role. It reaches the hover, the open menu and the focus
  /// rings; the bar draws nothing.
  final PlassColor? color;

  /// The padding beside each word. Even the default uses the compact track: a
  /// strip is not a row of buttons.
  final PlassDensity? density;

  /// The name a screen reader gives the bar.
  final String? semanticLabel;

  @override
  State<PlMenubar> createState() => _PlMenubarState();
}

class _PlMenubarState extends State<PlMenubar> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  /// The bar's own node, where its keys are answered. It never takes focus.
  final FocusNode _bar = FocusNode(
    debugLabel: 'PlMenubar',
    canRequestFocus: false,
    skipTraversal: true,
  );

  /// One node per word, which the arrow keys hand the focus between.
  final List<FocusNode> _words = <FocusNode>[];

  /// The word that holds the bar's one tab stop.
  ///
  /// It follows the focus rather than leading it, so tabbing back onto the bar
  /// returns to the word the reader left.
  int _stop = 0;

  @override
  void initState() {
    super.initState();
    _fitWords();
  }

  @override
  void didUpdateWidget(PlMenubar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fitWords();
  }

  @override
  void dispose() {
    for (final FocusNode node in _words) {
      node.dispose();
    }
    _bar.dispose();
    super.dispose();
  }

  /// Keeps a node for every menu on the bar, and no more.
  void _fitWords() {
    while (_words.length < widget.menus.length) {
      _words.add(FocusNode(debugLabel: 'PlMenubar ${_words.length}'));
    }
    while (_words.length > widget.menus.length) {
      _words.removeLast().dispose();
    }
  }

  bool _enabled(int index) => !widget.disabled && !widget.menus[index].disabled;

  /// The word the tab stop is on: the one last focused, or the first that can
  /// take focus when that one has gone or been disabled. -1 when none can.
  int get _resolvedStop {
    if (_stop < widget.menus.length && _enabled(_stop)) {
      return _stop;
    }

    for (int index = 0; index < widget.menus.length; index += 1) {
      if (_enabled(index)) {
        return index;
      }
    }

    return -1;
  }

  /// Whether the focus is on the menu wrapped round the word at [index].
  ///
  /// An open menu takes the keys on a node of its own, between the word and
  /// the bar, and keeps the focus there once it closes until it is handed
  /// back. Bounded by the bar's own node, so a scope above the bar — which is
  /// an ancestor of every word too — never counts.
  bool _onMenuOf(int index) {
    final FocusNode? primary = FocusManager.instance.primaryFocus;

    return primary != null &&
        _words[index].ancestors.contains(primary) &&
        primary.ancestors.contains(_bar);
  }

  /// The word the keyboard is on, or -1 when the focus is not on the bar.
  int get _current {
    for (int index = 0; index < _words.length; index += 1) {
      if (_words[index].hasPrimaryFocus || _onMenuOf(index)) {
        return index;
      }
    }

    return -1;
  }

  void _focus(int index) {
    setState(() => _stop = index);
    _words[index].requestFocus();
  }

  /// Steps to the next word that can take focus, wrapping at either end, which
  /// is what the React bar does by default.
  void _move(int from, int by) {
    final int count = widget.menus.length;

    for (int step = 1; step < count; step += 1) {
      final int next = (from + by * step) % count;

      if (_enabled(next)) {
        _focus(next);
        return;
      }
    }
  }

  /// The first word that can take focus, or the last.
  void _edge({required bool toEnd}) {
    final int count = widget.menus.length;

    for (int step = 0; step < count; step += 1) {
      final int index = toEnd ? count - 1 - step : step;

      if (_enabled(index)) {
        _focus(index);
        return;
      }
    }
  }

  /// The keys a closed bar answers.
  ///
  /// An open menu is below this in the focus tree and answers its own arrow
  /// keys, <kbd>Home</kbd> and <kbd>End</kbd> first, so everything here only
  /// ever reaches a word whose menu is shut.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final int current = _current;
    if (current < 0) {
      return KeyEventResult.ignored;
    }

    // A row runs the way the text does, so under RTL the next word is the one
    // to the left. A column runs down in every direction.
    final bool vertical = widget.orientation == PlassOrientation.vertical;
    final bool rtl = !vertical && Directionality.of(context) == TextDirection.rtl;
    final LogicalKeyboardKey forward = vertical
        ? LogicalKeyboardKey.arrowDown
        : (rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight);
    final LogicalKeyboardKey back = vertical
        ? LogicalKeyboardKey.arrowUp
        : (rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft);

    if (event.logicalKey == forward) {
      _move(current, 1);
    } else if (event.logicalKey == back) {
      _move(current, -1);
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      _edge(toEnd: false);
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      _edge(toEnd: true);
    } else {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  /// Gives the focus back to the word once its menu closes.
  ///
  /// The open menu held the focus on the node wrapped round the word, which
  /// draws no ring and is not a stop; left there, the reader would lose sight
  /// of where they are, and the next Tab would land on the same word again.
  /// This is also where the React bar puts it.
  ///
  /// Checked after the frame rather than at once, because a row's own handler
  /// runs before the menu closes and may have sent the focus somewhere of its
  /// own — a "Find…" that opens a search field — and a request made now would
  /// win over that one.
  void _closed(int index) {
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted && index < _words.length && _onMenuOf(index)) {
        _words[index].requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool vertical = widget.orientation == PlassOrientation.vertical;
    final int stop = _resolvedStop;

    final List<Widget> words = <Widget>[
      for (int index = 0; index < widget.menus.length; index += 1) _menu(index, stop: stop),
    ];

    final Widget bar = vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: gap[_size]!,
            children: words,
          )
        : Row(mainAxisSize: MainAxisSize.min, spacing: gap[_size]!, children: words);

    return Focus(
      focusNode: _bar,
      onKeyEvent: _onKey,
      child: Semantics(
        role: SemanticsRole.menuBar,
        explicitChildNodes: true,
        label: widget.semanticLabel,
        child: bar,
      ),
    );
  }

  Widget _menu(int index, {required int stop}) {
    final PlMenubarMenu menu = widget.menus[index];
    final bool disabled = !_enabled(index);

    // One stop for the whole bar: every other word stays in the focus tree, so
    // the arrow keys can reach it, and out of the order Tab walks.
    _words[index].skipTraversal = index != stop;

    return PlMenu(
      items: menu.items,
      size: _size,
      color: _color,
      density: _density,
      disabled: disabled,
      sideOffset: 4,
      label: menu.label,
      onOpenChange: (bool open) {
        if (!open) {
          _closed(index);
        }
      },
      trigger: (BuildContext context, VoidCallback open, bool isOpen) => _Word(
        menu: menu,
        open: isOpen,
        disabled: disabled,
        size: _size,
        color: _color,
        density: _density,
        focusNode: _words[index],
        onFocusChange: (bool focused) {
          if (focused && _stop != index) {
            setState(() => _stop = index);
          }
        },
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
    required this.focusNode,
    required this.onFocusChange,
    required this.onPressed,
  });

  final PlMenubarMenu menu;
  final bool open;
  final bool disabled;
  final PlassSize size;
  final PlassColor color;
  final PlassDensity density;
  final FocusNode focusNode;
  final ValueChanged<bool> onFocusChange;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final PlassColorFamily family = tokens.family(color);
    final double fontSize = controlText[size]!;
    final BorderRadius radius = BorderRadius.circular(tokens.radii[size]!);
    // A word on a strip, not a key in a row: the compact track at every step,
    // because the default one would space three words like three buttons.
    final double padX = paddingX[PlassDensity.compact]![size]!;

    return PlassInteractive(
      enabled: !disabled,
      interactive: !disabled,
      focusNode: focusNode,
      onFocusChange: onFocusChange,
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
                // In the word's ink, as a glyph in the React trigger takes its
                // `currentColor`. A glyph handed a colour of its own keeps it.
                if (menu.startIcon != null) PlassInk(color: ink, child: menu.startIcon!),
                Center(
                  // Eased with the wash as the menu opens and closes, as the
                  // React trigger's `color` is.
                  child: PlassInk(
                    color: ink,
                    child: Text(
                      menu.label,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                        height: 1,
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
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

        word = CustomPaint(
          // Turned inward, because a word on a strip has a neighbour a hair
          // away on each side and a ring drawn outside it would overlap
          // them.
          foregroundPainter: state.focusVisible
              ? PlassFocusRingPainter(
                  color: family.ring,
                  borderRadius: radius,
                  offset: -focusRingWidth,
                )
              : null,
          child: word,
        );

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
