/// Everything an app can do, behind one field.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/hot_keys/pl_hot_keys.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/portal.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/search.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// One thing the palette can do.
@immutable
class PlCommandItem {
  /// Creates a command.
  const PlCommandItem({
    required this.value,
    required this.label,
    this.description,
    this.icon,
    this.shortcut,
    this.group,
    this.keywords = const <String>[],
    this.disabled = false,
    this.onSelect,
  });

  /// What identifies the command.
  final String value;

  /// What the row says, and what the query is matched against.
  final String label;

  /// A second line under it — where the command goes, or what it changes.
  final String? description;

  /// A glyph before the label.
  final Widget? icon;

  /// The keystroke that does the same thing, set at the end of the row.
  ///
  /// Written the way [PlHotKeys] writes them, so `Mod` resolves per platform.
  /// The palette **does not bind it** — the app does.
  final String? shortcut;

  /// The heading this command sits under.
  ///
  /// Commands are drawn in the order they are given, and a heading is drawn
  /// each time the group changes — so a group's commands have to be listed
  /// together.
  final String? group;

  /// Extra words the query is matched against but that are never drawn.
  final List<String> keywords;

  /// In the list but not runnable.
  final bool disabled;

  /// What running it does.
  final VoidCallback? onSelect;
}

/// The sheet's width, per step.
const Map<PlassSize, double> _sheetWidth = <PlassSize, double>{
  PlassSize.xs: 384,
  PlassSize.sm: 448,
  PlassSize.md: 576,
  PlassSize.lg: 672,
  PlassSize.xl: 768,
};

/// The field's own height, and its own ladder.
///
/// A palette's field is not a control in a row of controls — it is the top of a
/// sheet and the one thing on screen, so it sits a step above the control
/// ladder for the same reason a browser's own command bar does.
const Map<PlassSize, double> _inputHeight = <PlassSize, double>{
  PlassSize.xs: 36,
  PlassSize.sm: 40,
  PlassSize.md: 48,
  PlassSize.lg: 56,
  PlassSize.xl: 64,
};

/// A row's gutter, and its own ladder rather than the sheet track.
const Map<PlassSize, double> _insetX = <PlassSize, double>{
  PlassSize.xs: 10,
  PlassSize.sm: 12,
  PlassSize.md: 14,
  PlassSize.lg: 16,
  PlassSize.xl: 20,
};

const Map<PlassSize, double> _rowPadY = <PlassSize, double>{
  PlassSize.xs: 4,
  PlassSize.sm: 6,
  PlassSize.md: 8,
  PlassSize.lg: 10,
  PlassSize.xl: 12,
};

/// `Mod+K` and its friends, as a predicate over a real key event.
///
/// The same vocabulary [PlHotKeys] draws, read rather than written — a shortcut
/// a widget displays and a shortcut it binds must be spelled the same way, or
/// the cap on the screen is a claim nobody checked.
bool _pressed(String shortcut, KeyEvent event) {
  final List<String> parts = shortcut
      .toLowerCase()
      .split('+')
      .map((String part) => part.trim())
      .toList(growable: false);
  final String key = parts.last;
  final Set<String> wanted = parts.sublist(0, parts.length - 1).toSet();

  final HardwareKeyboard keyboard = HardwareKeyboard.instance;
  final bool mac = PlHotKeys.platform == PlHotKeysOS.mac;
  final bool mod = mac ? keyboard.isMetaPressed : keyboard.isControlPressed;

  if (wanted.contains('mod') != mod) return false;
  if (wanted.contains('shift') != keyboard.isShiftPressed) return false;
  if (wanted.contains('alt') != keyboard.isAltPressed) return false;

  if (!wanted.contains('mod')) {
    if (wanted.contains('ctrl') != keyboard.isControlPressed) return false;
    if (wanted.contains('meta') != keyboard.isMetaPressed) return false;
  }

  return event.logicalKey.keyLabel.toLowerCase() == key;
}

/// Everything an application can do, behind one field.
///
/// ```dart
/// PlCommandPalette(
///   open: open,
///   onOpenChanged: (bool next) => setState(() => open = next),
///   items: const <PlCommandItem>[
///     PlCommandItem(value: 'new', label: 'New document', group: 'File'),
///   ],
/// )
/// ```
///
/// The shape a keyboard-first product takes once it has more actions than a
/// menu bar can hold: a reader types what they want instead of remembering
/// where it was put. It is not a [PlMenu] — a menu is a short list in one place
/// and every row is visible before you look for it — and not a [PlCombobox]:
/// what comes back is not a value, it is *something happening*.
class PlCommandPalette extends StatefulWidget {
  /// Creates a palette.
  const PlCommandPalette({
    required this.items,
    required this.open,
    this.onOpenChanged,
    this.onSelect,
    this.shortcut = 'Mod+K',
    this.width,
    this.maxHeight = 320,
    this.placeholder = 'Search commands',
    this.emptyMessage = 'No commands found',
    this.label = 'Command palette',
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    super.key,
  });

  /// Everything the palette can do.
  final List<PlCommandItem> items;

  /// Whether the palette is open.
  ///
  /// Required, and the one place this differs from the React build: there is no
  /// uncontrolled mode, because the thing that opens a palette is a key bound
  /// on the whole app and an app that binds one already holds the state.
  final bool open;

  /// Called when it opens or closes.
  final ValueChanged<bool>? onOpenChanged;

  /// Called when a command is run, after its own [PlCommandItem.onSelect]. The
  /// palette closes either way.
  final ValueChanged<PlCommandItem>? onSelect;

  /// The keystroke that opens the palette, bound on the keyboard.
  ///
  /// Written the way [PlHotKeys] writes them, so `Mod` is Command on a Mac and
  /// Control everywhere else. `null` binds nothing.
  final String? shortcut;

  /// How wide the sheet may get. `null` is the width [size] implies.
  final double? width;

  /// How tall the list may get before it scrolls.
  final double maxHeight;

  /// The placeholder in the field.
  final String placeholder;

  /// The line where the rows would be, when nothing matched.
  final String emptyMessage;

  /// The name a screen reader gives the sheet, which has no visible title.
  final String label;

  /// The sheet's width, the field's height and the rows' type scale.
  final PlassSize size;

  /// Semantic colour role. It reaches the highlight and the caret; the sheet is
  /// never dyed.
  final PlassColor color;

  /// The height of a row, and nothing else.
  final PlassDensity density;

  @override
  State<PlCommandPalette> createState() => _PlCommandPaletteState();
}

class _PlCommandPaletteState extends State<PlCommandPalette> {
  final TextEditingController _query = TextEditingController();
  final FocusNode _field = FocusNode(debugLabel: 'PlCommandPalette');
  final ScrollController _scroll = ScrollController();
  int _highlighted = 0;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void didUpdateWidget(PlCommandPalette oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.open && !oldWidget.open) {
      _highlighted = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) => _field.requestFocus());
    }

    // The query is dropped on the way *out* rather than on the way in, so the
    // sheet never flashes the last search as it fades.
    if (!widget.open && oldWidget.open) {
      _query.clear();
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _query.dispose();
    _field.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Everything the palette listens to, in one place.
  ///
  /// The opener is read with the same vocabulary [PlHotKeys] draws — a shortcut
  /// a widget displays and a shortcut it binds must be spelled the same way, or
  /// the cap on the screen is a claim nobody checked.
  ///
  /// The list keys are here rather than in a [Shortcuts] scope for a reason
  /// that only shows up in this component: the field has the focus, and an
  /// [EditableText] consumes the arrow keys and Enter itself. Reading them
  /// before the focus system does is the only way the field can keep every
  /// character while the list keeps its own four keys.
  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return false;
    }

    if (!widget.open) {
      final String? shortcut = widget.shortcut;

      if (shortcut == null || !_pressed(shortcut, event)) {
        return false;
      }

      widget.onOpenChanged?.call(true);

      return true;
    }

    final LogicalKeyboardKey key = event.logicalKey;
    final List<PlCommandItem> rows = _filtered;

    if (key == LogicalKeyboardKey.arrowDown) {
      _move(1, rows);
      return true;
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      _move(-1, rows);
      return true;
    }

    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      if (rows.isNotEmpty) {
        _run(rows[_highlighted.clamp(0, rows.length - 1)]);
      }
      return true;
    }

    if (key == LogicalKeyboardKey.escape) {
      widget.onOpenChanged?.call(false);
      return true;
    }

    return false;
  }

  List<PlCommandItem> get _filtered {
    final String needle = searchText(_query.text);

    if (needle.isEmpty) return widget.items;

    return widget.items
        .where(
          (PlCommandItem item) =>
              searchHaystack(<String?>[item.label, item.group, ...item.keywords]).contains(needle),
        )
        .toList(growable: false);
  }

  void _run(PlCommandItem item) {
    if (item.disabled) return;

    item.onSelect?.call();
    widget.onSelect?.call(item);
    widget.onOpenChanged?.call(false);
  }

  void _move(int by, List<PlCommandItem> rows) {
    if (rows.isEmpty) return;

    setState(() {
      _highlighted = (_highlighted + by).clamp(0, rows.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final List<PlCommandItem> rows = _filtered;
    final int highlighted = rows.isEmpty ? -1 : _highlighted.clamp(0, rows.length - 1);

    return PlassPortal(
      open: widget.open,
      modal: true,
      barrierColor: tokens.scrim,
      onDismiss: () => widget.onOpenChanged?.call(false),
      label: widget.label,
      child: Align(
        alignment: const Alignment(0, -0.6),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.width ?? _sheetWidth[widget.size]!),
            child: _sheet(tokens, rows, highlighted),
          ),
        ),
      ),
    );
  }

  Widget _sheet(PlassTokens tokens, List<PlCommandItem> rows, int highlighted) {
    final PlassSize size = widget.size;
    final double inset = _insetX[size]!;
    final PlassTextScale text = controlTextLeading[size]!;

    final Widget field = SizedBox(
      height: _inputHeight[size]!,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: inset),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: EditableText(
            controller: _query,
            focusNode: _field,
            onChanged: (String _) => setState(() => _highlighted = 0),
            style: TextStyle(color: tokens.fg, fontSize: text.size, height: text.height),
            cursorColor: tokens.family(widget.color).accent,
            backgroundCursorColor: tokens.mutedFg,
            selectionColor: tokens.family(widget.color).softPress,
          ),
        ),
      ),
    );

    final Widget placeholder = Padding(
      padding: EdgeInsets.symmetric(horizontal: inset),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          widget.placeholder,
          style: TextStyle(color: tokens.mutedFg, fontSize: text.size, height: text.height),
        ),
      ),
    );

    return PlassSurfaceBox(
      surface: PlassSurface(
        fill: tokens.glassPress,
        border: Border.all(color: tokens.glassLine, width: hairline),
        ink: tokens.fg,
        blur: true,
        insets: <PlassInsetShadow>[tokens.glossGlass],
        shadows: tokens.elevation(3),
      ),
      borderRadius: BorderRadius.circular(PlassTokens.radius[size]!),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: tokens.glassLine, width: hairline),
              ),
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _query,
                    builder: (BuildContext context, TextEditingValue value, Widget? child) =>
                        value.text.isEmpty ? placeholder : const SizedBox.shrink(),
                  ),
                ),
                field,
              ],
            ),
          ),
          if (rows.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: inset, vertical: 24),
              child: Text(
                widget.emptyMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.maxHeight),
              child: SingleChildScrollView(
                controller: _scroll,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      for (int index = 0; index < rows.length; index += 1) ...<Widget>[
                        if (rows[index].group != null &&
                            (index == 0 || rows[index - 1].group != rows[index].group))
                          Padding(
                            padding: EdgeInsets.only(left: inset, right: inset, top: 8, bottom: 4),
                            child: Text(
                              rows[index].group!,
                              style: TextStyle(
                                color: tokens.mutedFg,
                                fontSize: metaText[size]!,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        _Row(
                          item: rows[index],
                          highlighted: index == highlighted,
                          size: size,
                          color: widget.color,
                          density: widget.density,
                          onHover: () => setState(() => _highlighted = index),
                          onRun: () => _run(rows[index]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One command.
class _Row extends StatelessWidget {
  const _Row({
    required this.item,
    required this.highlighted,
    required this.size,
    required this.color,
    required this.density,
    required this.onHover,
    required this.onRun,
  });

  final PlCommandItem item;
  final bool highlighted;
  final PlassSize size;
  final PlassColor color;
  final PlassDensity density;
  final VoidCallback onHover;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final PlassColorFamily family = tokens.family(color);
    final PlassTextScale text = controlTextLeading[size]!;
    final double inset = _insetX[size]!;
    final double padY = _rowPadY[density == PlassDensity.compact ? PlassSize.xs : size]!;
    final Color ink = item.disabled
        ? tokens.mutedFg
        : highlighted
        ? family.accent
        : tokens.fg;

    Widget row = Padding(
      padding: EdgeInsets.symmetric(horizontal: inset, vertical: padY),
      child: Row(
        spacing: 12,
        children: <Widget>[
          ?item.icon,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: ink, fontSize: text.size, height: text.height),
                ),
                if (item.description != null)
                  Text(
                    item.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                  ),
              ],
            ),
          ),
          if (item.shortcut != null) PlHotKeys(keys: item.shortcut!, size: PlassSize.xs),
        ],
      ),
    );

    row = PlassSurfaceBox(
      surface: PlassSurface(fill: highlighted && !item.disabled ? family.soft : null, ink: ink),
      borderRadius: BorderRadius.circular(PlassTokens.radius[size]!),
      child: row,
    );

    if (item.disabled) {
      return Semantics(button: true, enabled: false, label: item.label, child: row);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (PointerEnterEvent event) => onHover(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onRun,
        child: Semantics(button: true, selected: highlighted, label: item.label, child: row),
      ),
    );
  }
}
