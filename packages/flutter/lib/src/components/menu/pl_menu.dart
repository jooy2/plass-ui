/// A list of actions that appears when something is pressed.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/anchored.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How tall a menu is allowed to get before it scrolls.
const double _maxPopupHeight = 384;

/// The room a popup keeps around its rows.
const double _popupInset = 4;

/// How far a menu stands off its trigger.
const double _standoff = 6;

/// How far a submenu stands off the row that opened it.
const double _submenuStandoff = 4;

/// How long a typeahead run stays open before the next key starts a new one.
const Duration _typeaheadWindow = Duration(milliseconds: 900);

/* ---------------------------------------------------------------------------
 * The rows
 *
 * **Descriptions rather than composed widgets**, which is the one place this
 * package and the React one disagree about a component's shape — and it is
 * forced. The React build composes because Base UI reads the DOM the rows are
 * written into: it finds them, counts them, moves a roving highlight through
 * them and matches typeahead against them without anybody handing it a list.
 * There is no tree to walk here, so the menu has to be told.
 *
 * Which is the same reason `PlAccordion`, `PlTabs` and `PlSelect` take
 * descriptions, and this is the sealed hierarchy that lets a row be a different
 * *kind* of thing rather than a widget with a discriminator on it.
 * ------------------------------------------------------------------------ */

/// One entry in a menu: a row, a group of rows, a separator or a submenu.
sealed class PlMenuEntry {
  /// Creates an entry.
  const PlMenuEntry();
}

/// One row of a menu.
final class PlMenuItem extends PlMenuEntry {
  /// Creates a row.
  const PlMenuItem({
    required this.label,
    this.onPressed,
    this.startIcon,
    this.endIcon,
    this.shortcut,
    this.description,
    this.color,
    this.closeOnPress = true,
    this.disabled = false,
  });

  /// The label.
  ///
  /// A `String` rather than a widget, and required. It is what is drawn, what a
  /// screen reader announces, and what typeahead matches against — and only a
  /// string can be all three.
  final String label;

  /// What the row does. Left out, the row is a label rather than an action.
  final VoidCallback? onPressed;

  /// Content before the label — an icon, a swatch.
  final Widget? startIcon;

  /// Content after the label, before any [shortcut].
  final Widget? endIcon;

  /// The keystroke that does the same thing, set at the end of the row and
  /// muted. Text only — the row does not bind it, the application does.
  final String? shortcut;

  /// A second line under the label, one step down the type scale and muted.
  final String? description;

  /// Re-points the row's colour family — [PlassColor.danger] for the one that
  /// deletes. Defaults to the menu's own.
  final PlassColor? color;

  /// Whether picking the row closes the menu.
  final bool closeOnPress;

  /// Unavailable. Still listed, and still found by typeahead.
  final bool disabled;
}

/// A row that ticks. The tick lands in the same slot a `startIcon` would.
final class PlMenuCheckboxItem extends PlMenuEntry {
  /// Creates a ticking row. It is **controlled**, like every other input in
  /// this package.
  const PlMenuCheckboxItem({
    required this.label,
    required this.checked,
    this.onChanged,
    this.endIcon,
    this.shortcut,
    this.description,
    this.color,
    this.closeOnPress = false,
    this.disabled = false,
  });

  /// The label. See [PlMenuItem.label].
  final String label;

  /// Whether the row is ticked.
  final bool checked;

  /// Called with what the tick should become.
  final ValueChanged<bool>? onChanged;

  /// Content after the label, before any [shortcut].
  final Widget? endIcon;

  /// The keystroke that does the same thing.
  final String? shortcut;

  /// A second line under the label.
  final String? description;

  /// Re-points the row's colour family.
  final PlassColor? color;

  /// Whether ticking closes the menu. `false`, against the `true` a plain row
  /// takes: a list of things to tick is a list you tick more than one of.
  final bool closeOnPress;

  /// Unavailable. Still listed.
  final bool disabled;
}

/// One choice out of a set.
///
/// Marked with a dot rather than a tick, which is the distinction [PlCheckbox]
/// and [PlRadioGroup] make everywhere else: a tick says "and", a dot says
/// "instead of".
final class PlMenuRadioItem extends PlMenuEntry {
  /// Creates a row that is one of a set.
  const PlMenuRadioItem({
    required this.label,
    required this.selected,
    this.onPressed,
    this.endIcon,
    this.shortcut,
    this.description,
    this.color,
    this.closeOnPress = false,
    this.disabled = false,
  });

  /// The label. See [PlMenuItem.label].
  final String label;

  /// Whether this is the chosen one.
  ///
  /// **The row is told, rather than a group being asked.** The React build has
  /// a `PlMenuRadioGroup` holding the value; every input in this package is
  /// controlled instead, and a group that owned a value would be the one thing
  /// in the library that did not report and forget.
  final bool selected;

  /// What choosing it does.
  final VoidCallback? onPressed;

  /// Content after the label, before any [shortcut].
  final Widget? endIcon;

  /// The keystroke that does the same thing.
  final String? shortcut;

  /// A second line under the label.
  final String? description;

  /// Re-points the row's colour family.
  final PlassColor? color;

  /// Whether choosing closes the menu.
  final bool closeOnPress;

  /// Unavailable. Still listed.
  final bool disabled;
}

/// A named run of rows. The label is a heading, not a row — it cannot be
/// picked, and typeahead never lands on it.
final class PlMenuGroup extends PlMenuEntry {
  /// Creates a group.
  const PlMenuGroup({required this.items, this.label});

  /// The rows in it.
  final List<PlMenuEntry> items;

  /// The heading over them.
  final String? label;
}

/// The hairline between two runs of rows.
final class PlMenuSeparator extends PlMenuEntry {
  /// Creates a rule.
  const PlMenuSeparator();
}

/// A menu inside a menu.
///
/// The row that opens it is the same row every other item is, wearing a
/// chevron. Nesting is unlimited: a submenu holds entries, and one of them can
/// be a submenu.
final class PlMenuSubmenu extends PlMenuEntry {
  /// Creates a submenu.
  const PlMenuSubmenu({
    required this.label,
    required this.items,
    this.startIcon,
    this.disabled = false,
  });

  /// The label on the row that opens it.
  final String label;

  /// The nested rows.
  final List<PlMenuEntry> items;

  /// Content before the label.
  final Widget? startIcon;

  /// Unavailable. The row stops opening anything.
  final bool disabled;
}

/* ---------------------------------------------------------------------------
 * The scales
 * ------------------------------------------------------------------------ */

/// A row's padding, and a ladder of its own rather than the sheet track.
///
/// A `PlList` row spans a sheet something else decided the width of; a menu row
/// is inside a popup exactly as wide as its longest label, and the sheet
/// track's 20 at `md` would add 40 to a menu that says "Cut" — which is how a
/// five-row menu ends up the width of a dialog.
const Map<PlassDensity, Map<PlassSize, EdgeInsets>> _rowPadding =
    <PlassDensity, Map<PlassSize, EdgeInsets>>{
      PlassDensity.standard: <PlassSize, EdgeInsets>{
        PlassSize.xs: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        PlassSize.sm: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        PlassSize.md: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        PlassSize.lg: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        PlassSize.xl: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      },
      PlassDensity.compact: <PlassSize, EdgeInsets>{
        PlassSize.xs: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        PlassSize.sm: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        PlassSize.md: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        PlassSize.lg: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        PlassSize.xl: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      },
    };

/// A row sits one step down the radius ladder from the popup it is inside: a
/// tile cut out of a sheet cannot carry the sheet's own corner, or the two
/// curves fight along the edge.
const Map<PlassSize, PlassSize> _rowRadiusStep = <PlassSize, PlassSize>{
  PlassSize.xs: PlassSize.xs,
  PlassSize.sm: PlassSize.xs,
  PlassSize.md: PlassSize.sm,
  PlassSize.lg: PlassSize.sm,
  PlassSize.xl: PlassSize.md,
};

/* ---------------------------------------------------------------------------
 * The menu
 * ------------------------------------------------------------------------ */

/// A list of actions that appears when something is pressed.
///
/// ```dart
/// PlMenu(
///   trigger: (BuildContext context, VoidCallback open, bool isOpen) =>
///       PlButton(onPressed: open, variant: PlassVariant.glass, child: const Text('Actions')),
///   items: <PlMenuEntry>[
///     PlMenuItem(label: 'Cut', shortcut: '⌘X', onPressed: cut),
///     PlMenuItem(label: 'Copy', shortcut: '⌘C', onPressed: copy),
///     const PlMenuSeparator(),
///     PlMenuItem(label: 'Delete', color: PlassColor.danger, onPressed: remove),
///   ],
/// )
/// ```
///
/// The popup is `PlSelect`'s popup to the pixel — deliberately, because a
/// select *is* a menu that remembers what you picked, and two floating lists of
/// rows that do not match are two lists the eye has to learn separately.
///
/// There is no `variant`, for the reason `PlModal` has none: the three
/// materials answer "how much does this surface assert itself against the
/// screen", and a popup that has taken the pointer has already answered it.
/// There is no `elevation` either — a menu genuinely floats, which is the one
/// case the ladder exists for, so it is fixed at its top rung.
class PlMenu extends StatefulWidget {
  /// Creates a menu.
  const PlMenu({
    required this.items,
    required this.trigger,
    this.size,
    this.color,
    this.density,
    this.side = PlassSide.bottom,
    this.align = PlassAlign.start,
    this.sideOffset = _standoff,
    this.loopFocus = true,
    this.disabled = false,
    this.onOpenChange,
    this.label,
    super.key,
  });

  /// The rows.
  final List<PlMenuEntry> items;

  /// What opens the menu, built with the callback that opens it.
  ///
  /// A builder rather than a widget, because the trigger almost always wants to
  /// know: a button that stays lit while its menu is open is the difference
  /// between a menu bar and four buttons.
  final Widget Function(BuildContext context, VoidCallback open, bool isOpen) trigger;

  /// The popup's radius, type scale and row padding.
  final PlassSize? size;

  /// Semantic colour role. A row can override it.
  final PlassColor? color;

  /// Changes a row's padding and nothing else.
  final PlassDensity? density;

  /// Which edge of the trigger the menu hangs off.
  final PlassSide side;

  /// Where it sits along that edge.
  final PlassAlign align;

  /// How far it stands off the trigger, in logical pixels.
  final double sideOffset;

  /// Whether the arrow keys wrap from the last row back to the first.
  final bool loopFocus;

  /// Unavailable. The trigger stops opening anything.
  final bool disabled;

  /// Told whenever the menu opens or closes.
  final ValueChanged<bool>? onOpenChange;

  /// The name a screen reader gives the popup.
  final String? label;

  @override
  State<PlMenu> createState() => _PlMenuState();
}

class _PlMenuState extends State<PlMenu> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  final FocusNode _focusNode = FocusNode(debugLabel: 'PlMenu');

  bool _open = false;

  /// Which row of the deepest open menu is lit.
  int _highlighted = -1;

  /// Which submenu row was opened on each level above it.
  final List<int> _path = <int>[];

  String _typed = '';
  DateTime _typedAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// The entries of the deepest open menu, flattened out of their groups.
  List<PlMenuEntry> get _rows => _flatten(_itemsAt(_path));

  List<PlMenuEntry> _itemsAt(List<int> path) {
    List<PlMenuEntry> items = widget.items;

    for (final int index in path) {
      final List<PlMenuEntry> flat = _flatten(items);
      final PlMenuEntry entry = flat[index];
      items = entry is PlMenuSubmenu ? entry.items : const <PlMenuEntry>[];
    }

    return items;
  }

  /// Groups are containers rather than rows, so the highlight walks through
  /// them: a heading is not something the arrow keys can land on.
  static List<PlMenuEntry> _flatten(List<PlMenuEntry> items) {
    return <PlMenuEntry>[
      for (final PlMenuEntry entry in items)
        if (entry is PlMenuGroup) ..._flatten(entry.items) else entry,
    ];
  }

  static bool _pickable(PlMenuEntry entry) {
    return switch (entry) {
      PlMenuItem(disabled: final bool off) => !off,
      PlMenuCheckboxItem(disabled: final bool off) => !off,
      PlMenuRadioItem(disabled: final bool off) => !off,
      PlMenuSubmenu(disabled: final bool off) => !off,
      PlMenuGroup() || PlMenuSeparator() => false,
    };
  }

  static String _labelOf(PlMenuEntry entry) {
    return switch (entry) {
      PlMenuItem(label: final String text) => text,
      PlMenuCheckboxItem(label: final String text) => text,
      PlMenuRadioItem(label: final String text) => text,
      PlMenuSubmenu(label: final String text) => text,
      PlMenuGroup() || PlMenuSeparator() => '',
    };
  }

  void _openMenu() {
    if (widget.disabled || _open) {
      return;
    }

    setState(() {
      _open = true;
      _path.clear();
      _highlighted = -1;
    });
    _focusNode.requestFocus();
    widget.onOpenChange?.call(true);
  }

  void _close() {
    if (!_open) {
      return;
    }

    setState(() {
      _open = false;
      _path.clear();
      _highlighted = -1;
    });
    widget.onOpenChange?.call(false);
  }

  void _move(int by) {
    final List<PlMenuEntry> rows = _rows;
    if (rows.isEmpty) {
      return;
    }

    int next = _highlighted;

    for (int step = 0; step < rows.length; step++) {
      next += by;

      if (next < 0) {
        if (!widget.loopFocus) {
          return;
        }
        next = rows.length - 1;
      } else if (next >= rows.length) {
        if (!widget.loopFocus) {
          return;
        }
        next = 0;
      }

      if (_pickable(rows[next])) {
        setState(() => _highlighted = next);
        return;
      }
    }
  }

  void _edge(bool toEnd) {
    final List<PlMenuEntry> rows = _rows;
    setState(() => _highlighted = toEnd ? rows.length : -1);
    _move(toEnd ? -1 : 1);
  }

  /// Opens the submenu the highlight is on, and lights its first row.
  void _descend() {
    final List<PlMenuEntry> rows = _rows;
    if (_highlighted < 0 || _highlighted >= rows.length) {
      return;
    }

    final PlMenuEntry entry = rows[_highlighted];
    if (entry is! PlMenuSubmenu || entry.disabled) {
      return;
    }

    setState(() {
      _path.add(_highlighted);
      _highlighted = -1;
    });
    _move(1);
  }

  /// Closes the deepest submenu and lights the row that opened it.
  void _ascend() {
    if (_path.isEmpty) {
      _close();
      return;
    }

    setState(() {
      _highlighted = _path.removeLast();
    });
  }

  /// Lights a row, closing whatever was open below the level it is on.
  ///
  /// A submenu opens on hover as well as on a press, which is what a menu bar
  /// and a nested menu have both done since long before either was a component.
  void _light(int index, int level) {
    if (!_open) {
      return;
    }

    final List<PlMenuEntry> rows = _flatten(_itemsAt(_path.take(level).toList()));
    final PlMenuEntry entry = rows[index];

    setState(() {
      _path.removeRange(level, _path.length);
      _highlighted = index;

      if (entry is PlMenuSubmenu && !entry.disabled) {
        _path.add(index);
        _highlighted = -1;
      }
    });

    if (entry is PlMenuSubmenu && !entry.disabled) {
      _move(1);
    }
  }

  void _activate() {
    final List<PlMenuEntry> rows = _rows;
    if (_highlighted < 0 || _highlighted >= rows.length) {
      return;
    }

    _press(rows[_highlighted], _highlighted);
  }

  void _press(PlMenuEntry entry, int index) {
    switch (entry) {
      case PlMenuItem(disabled: false):
        entry.onPressed?.call();
        if (entry.closeOnPress) {
          _close();
        }
      case PlMenuCheckboxItem(disabled: false):
        entry.onChanged?.call(!entry.checked);
        if (entry.closeOnPress) {
          _close();
        }
      case PlMenuRadioItem(disabled: false):
        entry.onPressed?.call();
        if (entry.closeOnPress) {
          _close();
        }
      case PlMenuSubmenu(disabled: false):
        setState(() {
          _highlighted = index;
          _path.add(index);
        });
        _move(1);
      case _:
        break;
    }
  }

  /// Jumps the highlight to the next row starting with what was typed.
  void _typeahead(String character) {
    final DateTime now = DateTime.now();
    _typed = now.difference(_typedAt) > _typeaheadWindow ? character : _typed + character;
    _typedAt = now;

    final List<PlMenuEntry> rows = _rows;
    final String needle = _typed.toLowerCase();

    for (int step = 1; step <= rows.length; step++) {
      final int index = (_highlighted + step) % rows.length;

      if (_pickable(rows[index]) && _labelOf(rows[index]).toLowerCase().startsWith(needle)) {
        setState(() => _highlighted = index);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    // Focus stays on the trigger while the popup is up, which is what `PlSelect`
    // does and for the same reason: the rows are painted in an overlay, and a
    // focus scope lifted with them would take the keyboard away from the widget
    // that knows what to do with it.
    final Widget trigger = Focus(
      focusNode: _focusNode,
      onKeyEvent: _onKey,
      child: Builder(builder: (BuildContext context) => widget.trigger(context, _openMenu, _open)),
    );

    return PlassAnchoredPortal(
      open: _open,
      side: widget.side,
      align: widget.align,
      offset: widget.sideOffset,
      onDismiss: _close,
      popup: _popup(tokens, level: 0),
      child: trigger,
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!_open || event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }

    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        _move(1);
      case LogicalKeyboardKey.arrowUp:
        _move(-1);
      case LogicalKeyboardKey.arrowRight:
        rtl ? _ascend() : _descend();
      case LogicalKeyboardKey.arrowLeft:
        rtl ? _descend() : _ascend();
      case LogicalKeyboardKey.home:
        _edge(false);
      case LogicalKeyboardKey.end:
        _edge(true);
      case LogicalKeyboardKey.escape:
        _close();
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
      case LogicalKeyboardKey.space:
        _activate();
      case _:
        final String? character = event.character;

        if (character != null && character.trim().isNotEmpty && character.length == 1) {
          _typeahead(character);
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  /// One popup: the surface, its rows, and the submenu hanging off whichever
  /// row opened one.
  Widget _popup(PlassTokens tokens, {required int level}) {
    final bool deepest = level == _path.length;

    final Widget sheet = IntrinsicWidth(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _maxPopupHeight, minWidth: 160),
        child: PlassSurfaceBox(
          surface: PlassSurface(
            fill: tokens.glassPress,
            border: Border.all(color: tokens.glassLine, width: hairline),
            ink: tokens.fg,
            blur: true,
            insets: <PlassInsetShadow>[tokens.glossGlass],
            shadows: tokens.elevation(plassElevationMax),
          ),
          borderRadius: BorderRadius.circular(PlassTokens.radius[_size]!),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(_popupInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: _rowsOf(tokens, level: level, deepest: deepest),
            ),
          ),
        ),
      ),
    );

    return Semantics(container: true, label: level == 0 ? widget.label : null, child: sheet);
  }

  /// The rows of one popup, with headings and rules put back between them.
  List<Widget> _rowsOf(PlassTokens tokens, {required int level, required bool deepest}) {
    final List<PlMenuEntry> raw = _itemsAt(_path.take(level).toList());
    final List<Widget> built = <Widget>[];
    int index = 0;

    void walk(List<PlMenuEntry> entries) {
      for (final PlMenuEntry entry in entries) {
        switch (entry) {
          case PlMenuGroup(label: final String? heading, items: final List<PlMenuEntry> inner):
            if (heading != null) {
              built.add(_heading(tokens, heading));
            }
            walk(inner);
          case PlMenuSeparator():
            built.add(_rule(tokens));
            index++;
          case _:
            built.add(_row(tokens, entry, index, level: level, deepest: deepest));
            index++;
        }
      }
    }

    walk(raw);

    return built;
  }

  Widget _heading(PlassTokens tokens, String label) {
    return Padding(
      padding: _rowPadding[_density]![_size]!,
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: tokens.mutedFg,
          fontSize: metaText[_size]!,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _rule(PlassTokens tokens) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        height: hairline,
        child: ColoredBox(color: tokens.divider),
      ),
    );
  }

  Widget _row(
    PlassTokens tokens,
    PlMenuEntry entry,
    int index, {
    required int level,
    required bool deepest,
  }) {
    final PlassColorFamily family = tokens.family(_colorOf(entry) ?? _color);
    final bool accented = _colorOf(entry) != null;
    final bool available = _pickable(entry);
    final bool lit = deepest && _highlighted == index;
    final bool opened = !deepest && _path.length > level && _path[level] == index;
    final PlassTextScale scale = controlTextLeading[_size]!;

    final Widget row = MouseRegion(
      cursor: available ? SystemMouseCursors.click : SystemMouseCursors.basic,
      // The pointer moves the same highlight the arrow keys do, so the mouse and
      // the keyboard light one row rather than two — and moving onto a row of an
      // outer menu is what closes the submenu that was open beside it.
      onEnter: available ? (PointerEnterEvent event) => _light(index, level) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: available ? () => _press(entry, index) : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: lit || opened ? family.softHover : null,
            borderRadius: BorderRadius.circular(PlassTokens.radius[_rowRadiusStep[_size]!]!),
          ),
          child: Opacity(
            opacity: available ? 1 : disabledOpacity,
            child: Padding(
              padding: _rowPadding[_density]![_size]!,
              child: _rowBody(
                tokens,
                entry,
                ink: !available
                    ? tokens.mutedFg
                    : accented
                    ? family.accent
                    : tokens.fg,
                family: family,
                scale: scale,
              ),
            ),
          ),
        ),
      ),
    );

    if (entry is PlMenuSubmenu) {
      return PlassAnchoredPortal(
        open: opened,
        side: PlassSide.right,
        align: PlassAlign.start,
        offset: _submenuStandoff,
        // Built only while it is open, and that is not an optimisation: a
        // popup argument is evaluated whether or not the portal shows it, so a
        // submenu that built its own submenu unconditionally would recurse to
        // the bottom of the stack.
        popup: opened ? _popup(tokens, level: level + 1) : const SizedBox.shrink(),
        child: _semantics(entry, available, row),
      );
    }

    return _semantics(entry, available, row);
  }

  Widget _semantics(PlMenuEntry entry, bool available, Widget row) {
    return Semantics(
      button: entry is! PlMenuCheckboxItem && entry is! PlMenuRadioItem,
      checked: entry is PlMenuCheckboxItem ? entry.checked : null,
      inMutuallyExclusiveGroup: entry is PlMenuRadioItem,
      selected: entry is PlMenuRadioItem ? entry.selected : null,
      enabled: available,
      label: _labelOf(entry),
      child: ExcludeSemantics(child: row),
    );
  }

  static PlassColor? _colorOf(PlMenuEntry entry) {
    return switch (entry) {
      PlMenuItem(color: final PlassColor? family) => family,
      PlMenuCheckboxItem(color: final PlassColor? family) => family,
      PlMenuRadioItem(color: final PlassColor? family) => family,
      PlMenuGroup() || PlMenuSeparator() || PlMenuSubmenu() => null,
    };
  }

  Widget _rowBody(
    PlassTokens tokens,
    PlMenuEntry entry, {
    required Color ink,
    required PlassColorFamily family,
    required PlassTextScale scale,
  }) {
    final double glyph = scale.size * iconScale;

    Widget slot(Widget? child, Color colour) {
      return SizedBox(
        width: glyph,
        height: scale.line,
        child: child == null
            ? null
            : IconTheme.merge(
                data: IconThemeData(color: colour, size: glyph),
                child: Center(child: child),
              ),
      );
    }

    final Widget? mark = switch (entry) {
      PlMenuCheckboxItem(checked: true) => PlassGlyph(PlassGlyphShape.check, size: glyph),
      PlMenuRadioItem(selected: true) => PlassGlyph(PlassGlyphShape.dot, size: glyph),
      PlMenuItem(startIcon: final Widget? icon) => icon,
      PlMenuSubmenu(startIcon: final Widget? icon) => icon,
      _ => null,
    };

    final bool marked = entry is PlMenuCheckboxItem || entry is PlMenuRadioItem;

    return Row(
      spacing: gap[_size]!,
      children: <Widget>[
        if (mark != null || marked) slot(mark, marked ? family.accent : tokens.mutedFg),
        Expanded(
          child: _label(tokens, entry, ink: ink, scale: scale),
        ),
        if (_endIconOf(entry) != null) slot(_endIconOf(entry), tokens.mutedFg),
        if (_shortcutOf(entry) != null)
          Text(
            _shortcutOf(entry)!,
            style: TextStyle(
              color: tokens.mutedFg,
              fontSize: metaText[_size]!,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        if (entry is PlMenuSubmenu)
          slot(PlassGlyph(PlassGlyphShape.chevron, size: glyph, quarterTurns: -1), tokens.mutedFg),
      ],
    );
  }

  Widget _label(
    PlassTokens tokens,
    PlMenuEntry entry, {
    required Color ink,
    required PlassTextScale scale,
  }) {
    final TextStyle style = TextStyle(
      color: ink,
      fontSize: scale.size,
      height: scale.height,
      leadingDistribution: TextLeadingDistribution.even,
    );

    final String? description = _descriptionOf(entry);

    if (description == null) {
      return Text(_labelOf(entry), maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(_labelOf(entry), maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
        Text(
          description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: tokens.mutedFg, fontSize: metaText[_size]!),
        ),
      ],
    );
  }

  static Widget? _endIconOf(PlMenuEntry entry) {
    return switch (entry) {
      PlMenuItem(endIcon: final Widget? icon) => icon,
      PlMenuCheckboxItem(endIcon: final Widget? icon) => icon,
      PlMenuRadioItem(endIcon: final Widget? icon) => icon,
      _ => null,
    };
  }

  static String? _shortcutOf(PlMenuEntry entry) {
    return switch (entry) {
      PlMenuItem(shortcut: final String? keys) => keys,
      PlMenuCheckboxItem(shortcut: final String? keys) => keys,
      PlMenuRadioItem(shortcut: final String? keys) => keys,
      _ => null,
    };
  }

  static String? _descriptionOf(PlMenuEntry entry) {
    return switch (entry) {
      PlMenuItem(description: final String? line) => line,
      PlMenuCheckboxItem(description: final String? line) => line,
      PlMenuRadioItem(description: final String? line) => line,
      _ => null,
    };
  }
}
