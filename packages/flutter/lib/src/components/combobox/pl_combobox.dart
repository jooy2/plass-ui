/// A field you can type into and also choose from.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/chip/pl_chip.dart';
import 'package:plass_ui/src/internal/anchored.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How tall the list is allowed to get before it scrolls.
const double _maxPopupHeight = 320;

/// The room the popup keeps around its rows.
const double _popupInset = 4;

/// A row's vertical padding.
const double _rowPaddingY = 6;

/// The room the tick keeps at the leading edge of a row.
const double _tickGutter = 28;

/// How far the list stands off the field.
const double _standoff = 6;

/// Between the chips in a full field.
const double _chipGap = 4;

/// And between the last chip and where typing starts.
///
/// The gap above is the distance between two things of the same kind, and it is
/// too little between a chip and a caret: the query reads as another chip's
/// label rather than as the field's own text.
const double _afterChips = 6;

/// Moves the highlight through the list.
class _MoveIntent extends Intent {
  const _MoveIntent(this.by);

  final int by;
}

/// One choice.
///
/// The same description a [PlSelectOption] is, with one difference: the label is
/// a `String` rather than a widget, because the filter types against it and it
/// is written into a text field, and neither of those can be done to a widget.
@immutable
class PlComboboxOption<T> {
  /// Creates an option.
  const PlComboboxOption({required this.value, required this.label, this.disabled = false});

  /// What the combobox holds, and what it reports.
  final T value;

  /// Shown in the list, in the field and on the chip, and what the filter reads.
  final String label;

  /// Unavailable, but still listed — the option exists, it just cannot be taken.
  final bool disabled;
}

/// A field you can type into and also choose from.
///
/// ```dart
/// PlCombobox<String>(
///   label: const Text('Framework'),
///   value: framework,
///   onChanged: (String? next) => setState(() => framework = next),
///   options: const <PlComboboxOption<String>>[
///     PlComboboxOption<String>(value: 'react', label: 'React'),
///     PlComboboxOption<String>(value: 'vue', label: 'Vue'),
///   ],
/// )
/// ```
///
/// The shell is a [PlTextField]'s wearing a chevron, exactly as a [PlSelect]'s
/// trigger is — the three have to be indistinguishable in a form or the form
/// looks assembled rather than designed. What is different is what the text
/// does: it filters the list, and — when [onCreate] is given — it can become the
/// value itself, offered as its own row at the end of the list rather than
/// committed silently when focus leaves.
///
/// [PlCombobox.multiple] is the other half: the chosen values become [PlChip]s
/// inside the field and the field goes on filtering after each one, so a set of
/// tags is built without the list ever closing.
///
/// Needs an [Overlay] above it, which `WidgetsApp` with a navigator and
/// `MaterialApp` both provide.
class PlCombobox<T> extends StatefulWidget {
  /// Creates a combobox holding one value.
  const PlCombobox({
    required this.options,
    required this.value,
    this.onChanged,
    this.onCreate,
    this.customLabel,
    this.onQueryChanged,
    this.placeholder,
    this.emptyMessage = 'No matches',
    this.limit,
    this.clearable = false,
    this.clearLabel = 'Clear',
    this.openLabel = 'Open',
    this.removeLabel = _defaultRemoveLabel,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.elevation = 0,
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.startIcon,
    this.fullWidth = false,
    this.readOnly = false,
    this.disabled = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : values = const <Never>[],
       onValuesChanged = null,
       multiple = false,
       assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// Creates a combobox holding a set of values, drawn as chips in the field.
  const PlCombobox.multiple({
    required this.options,
    required this.values,
    ValueChanged<List<T>>? onChanged,
    this.onCreate,
    this.customLabel,
    this.onQueryChanged,
    this.placeholder,
    this.emptyMessage = 'No matches',
    this.limit,
    this.clearable = false,
    this.clearLabel = 'Clear',
    this.openLabel = 'Open',
    this.removeLabel = _defaultRemoveLabel,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.elevation = 0,
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.startIcon,
    this.fullWidth = false,
    this.readOnly = false,
    this.disabled = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : value = null,
       onChanged = null,
       onValuesChanged = onChanged,
       multiple = true,
       assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The choices, in order. The filter reads their labels.
  final List<PlComboboxOption<T>> options;

  /// The chosen value, or `null` for none. Single mode only.
  final T? value;

  /// Called with the value that was chosen. Single mode only.
  final ValueChanged<T?>? onChanged;

  /// The chosen values. `PlCombobox.multiple` only.
  final List<T> values;

  /// Called with the new set. `PlCombobox.multiple` only.
  final ValueChanged<List<T>>? onValuesChanged;

  /// Whether this is the multiple form. Set by the constructor.
  final bool multiple;

  /// Turns what was typed into a value, and **passing it is what allows one**.
  ///
  /// This is Flutter's `allowCustom`, and it is a callback rather than a flag
  /// for a reason the React build does not have: there a value is always a
  /// `string` or a `number`, so the field can build one out of the query on its
  /// own. Here it is a `T`, and only the caller knows how to make one — so the
  /// permission and the recipe are the same parameter.
  ///
  /// For a `PlCombobox<String>` that is `(String query) => query`.
  final T Function(String query)? onCreate;

  /// What the row offering that value says. Receives the trimmed query.
  final Widget Function(String query)? customLabel;

  /// Called as the text changes — the filter query, not the value.
  final ValueChanged<String>? onQueryChanged;

  /// Shown in the field while nothing is typed.
  final String? placeholder;

  /// Shown where the list would be when nothing matched and nothing may be
  /// added.
  final String emptyMessage;

  /// The most rows the list will show at once. `null` is all of them.
  final int? limit;

  /// Offers the × that empties the field.
  ///
  /// Off by default: a field that can be cleared in one press is a field that
  /// can be emptied by accident.
  final bool clearable;

  /// The name a screen reader gives that ×.
  final String clearLabel;

  /// And the one it gives the button that opens the list.
  final String openLabel;

  /// The name a chip's × takes, given the chip's label.
  ///
  /// Named after its chip — `Remove Seoul`, not `Remove` — because a screen
  /// reader reading a row of six identical buttons has told the reader nothing.
  final String Function(String label) removeLabel;

  /// What the field's well is cut into.
  final PlassVariant variant;

  /// Height and type scale. With `PlCombobox.multiple` it is a **minimum**
  /// height rather than a height, because chips wrap.
  final PlassSize size;

  /// Semantic colour role. It reaches the edge, the ring, the caret and the
  /// chosen row.
  final PlassColor color;

  /// Horizontal padding. Never the height.
  final PlassDensity density;

  /// Drop shadow depth of the **field**. `0`, like a [PlTextField]: a field is
  /// cut into the sheet rather than resting on it.
  final PlassElevation elevation;

  /// Label above the field.
  final Widget? label;

  /// Helper text below it.
  final Widget? description;

  /// Error message below it. Its presence also turns the combobox invalid.
  final Widget? error;

  /// Forces the invalid state without a message.
  final bool? invalid;

  /// Content before the text.
  final Widget? startIcon;

  /// Stretches to the width of the container.
  final bool fullWidth;

  /// The value is shown but cannot be changed, and the list does not open.
  final bool readOnly;

  /// Unavailable.
  final bool disabled;

  /// The name a screen reader gives the field.
  final String? semanticLabel;

  /// Drive focus from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  static String _defaultRemoveLabel(String label) => 'Remove $label';

  @override
  State<PlCombobox<T>> createState() => _PlComboboxState<T>();
}

/// One row of the list: an option, or the offer to make one.
@immutable
class _Row<T> {
  const _Row.option(this.option) : query = null;

  const _Row.create(this.query) : option = null;

  final PlComboboxOption<T>? option;
  final String? query;

  bool get isCreate => option == null;

  String get label => option?.label ?? query!;
}

class _PlComboboxState<T> extends State<PlCombobox<T>> {
  final ScrollController _scroll = ScrollController();
  late final TextEditingController _text = TextEditingController(text: _labelOfValue());
  FocusNode? _owned;
  bool _open = false;
  bool _focused = false;
  bool _hovered = false;

  /// Which row the keyboard is on. `-1` is none.
  int _highlighted = -1;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(PlCombobox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      _owned?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
    }

    // In single mode the text *is* the chosen option's label, so a value handed
    // in from outside has to reach the field. It is only written while the field
    // is not focused: doing it mid-edit would take the query out from under
    // somebody typing.
    if (!widget.multiple && !_focused && widget.value != oldWidget.value) {
      _text.text = _labelOfValue();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _scroll.dispose();
    _text.dispose();
    _owned?.dispose();
    super.dispose();
  }

  FocusNode get _focusNode => widget.focusNode ?? (_owned ??= FocusNode(debugLabel: 'PlCombobox'));

  bool get _usable =>
      !widget.disabled &&
      !widget.readOnly &&
      (widget.multiple ? widget.onValuesChanged != null : widget.onChanged != null);

  List<T> get _chosen => widget.multiple
      ? widget.values
      : widget.value == null
      ? <T>[]
      : <T>[widget.value as T];

  String _labelOfValue() {
    if (widget.multiple || widget.value == null) {
      return '';
    }

    for (final option in widget.options) {
      if (option.value == widget.value) {
        return option.label;
      }
    }

    return '${widget.value}';
  }

  void _onFocusChanged() {
    final has = _focusNode.hasFocus;

    if (has == _focused) {
      return;
    }

    setState(() {
      _focused = has;

      if (!has) {
        _open = false;
        // An abandoned query does not survive the field losing focus: in single
        // mode the text goes back to being the value, and in multiple mode it
        // empties. Nothing is committed on the way out — that is the whole point
        // of `onCreate` being a row you take rather than a thing that happens.
        _text.text = _labelOfValue();
      }
    });
  }

  /// The rows the list is currently showing.
  List<_Row<T>> get _rows {
    final query = _text.text.trim();
    final folded = query.toLowerCase();

    final matched = <_Row<T>>[
      for (final option in widget.options)
        if (folded.isEmpty || option.label.toLowerCase().contains(folded)) _Row<T>.option(option),
    ];

    final capped = widget.limit != null && widget.limit! >= 0 && matched.length > widget.limit!
        ? matched.sublist(0, widget.limit!)
        : matched;

    if (widget.onCreate == null || !_usable || query.isEmpty) {
      return capped;
    }

    // Nothing to offer when the query already names something: an option, or a
    // value that has already been taken.
    final known =
        widget.options.any((PlComboboxOption<T> option) => option.label.toLowerCase() == folded) ||
        _chosen.any((T value) => '$value'.toLowerCase() == folded);

    return known ? capped : <_Row<T>>[...capped, _Row<T>.create(query)];
  }

  void _openList() {
    if (!_usable || _open) {
      return;
    }

    _focusNode.requestFocus();
    setState(() {
      _open = true;
      _highlighted = _next(-1, 1);
    });
  }

  void _close() {
    if (_open) {
      setState(() => _open = false);
    }
  }

  /// The next row in [by]'s direction that can actually be taken.
  int _next(int from, int by) {
    final rows = _rows;
    final count = rows.length;

    if (count == 0) {
      return -1;
    }

    for (var step = 1; step <= count; step += 1) {
      final index = (from + by * step) % count;
      final wrapped = index < 0 ? index + count : index;

      if (!(rows[wrapped].option?.disabled ?? false)) {
        return wrapped;
      }
    }

    return -1;
  }

  void _move(int by) {
    if (!_open) {
      _openList();

      return;
    }

    final next = _next(_highlighted, by);

    if (next >= 0 && next != _highlighted) {
      setState(() => _highlighted = next);
    }
  }

  void _onQueryChanged(String query) {
    widget.onQueryChanged?.call(query);

    setState(() {
      _open = _usable;
      // The first match lights up as the query changes, so Enter commits without
      // an arrow key first — which is also what makes the create row reachable
      // from the keyboard at all: a value the list does not have is the only
      // match there is.
      _highlighted = _next(-1, 1);
    });
  }

  void _take(int index) {
    final rows = _rows;

    if (index < 0 || index >= rows.length) {
      return;
    }

    final row = rows[index];

    if (row.option?.disabled ?? false) {
      return;
    }

    final value = row.isCreate ? widget.onCreate!(row.query!) : row.option!.value;

    if (widget.multiple) {
      final next = <T>[...widget.values];

      if (!next.contains(value)) {
        next.add(value);
      }

      widget.onValuesChanged?.call(next);
      // The query is spent, and the field goes on filtering from empty — which
      // is what lets a set of tags be built without the list ever closing.
      _text.clear();
      setState(() => _highlighted = _next(-1, 1));

      return;
    }

    widget.onChanged?.call(value);
    _text.text = row.label;
    _close();
  }

  void _remove(T value) {
    widget.onValuesChanged?.call(<T>[
      for (final held in widget.values)
        if (held != value) held,
    ]);
  }

  void _clear() {
    if (widget.multiple) {
      widget.onValuesChanged?.call(const <Never>[]);
    } else {
      widget.onChanged?.call(null);
    }

    _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final hasError = widget.error != null;
    final isInvalid = widget.invalid ?? hasError;
    final family = tokens.family(isInvalid ? PlassColor.danger : widget.color);

    final size = widget.size;
    final scale = controlTextLeading[size]!;
    final meta = metaText[size]!;
    final radius = BorderRadius.circular(PlassTokens.radius[size]!);

    final field = PlassAnchoredPortal(
      open: _open,
      side: PlassSide.bottom,
      align: PlassAlign.start,
      offset: _standoff,
      matchAnchorWidth: true,
      onDismiss: _close,
      popup: _list(tokens, family, scale),
      child: _shell(tokens, family, scale, radius),
    );

    final stack = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: stackGap[size]!,
      children: <Widget>[
        if (widget.label != null)
          DefaultTextStyle.merge(
            style: TextStyle(
              color: widget.disabled ? tokens.mutedFg : tokens.fg,
              fontSize: meta,
              fontWeight: FontWeight.w600,
            ),
            child: widget.label!,
          ),
        field,
        if (widget.description != null)
          DefaultTextStyle.merge(
            style: TextStyle(color: tokens.mutedFg, fontSize: meta),
            child: widget.description!,
          ),
        if (hasError)
          DefaultTextStyle.merge(
            style: TextStyle(color: family.accent, fontSize: meta),
            child: widget.error!,
          ),
      ],
    );

    return Semantics(
      container: true,
      textField: true,
      expanded: _open,
      readOnly: widget.readOnly,
      enabled: !widget.disabled,
      label: widget.semanticLabel,
      child: widget.fullWidth ? stack : IntrinsicWidth(child: stack),
    );
  }

  /// The box, which is a text field's to the pixel.
  Widget _shell(
    PlassTokens tokens,
    PlassColorFamily family,
    PlassTextScale scale,
    BorderRadius radius,
  ) {
    final size = widget.size;

    final surface = fieldSurface(
      tokens,
      family,
      variant: widget.variant,
      elevation: widget.elevation,
      hovered: _hovered,
      focused: _focused,
      readOnly: widget.readOnly,
      disabled: widget.disabled,
    );

    Widget editor = EditableText(
      controller: _text,
      focusNode: _focusNode,
      readOnly: widget.readOnly || widget.disabled,
      autofocus: widget.autofocus,
      maxLines: 1,
      minLines: 1,
      onChanged: _onQueryChanged,
      onSubmitted: (String _) => _take(_highlighted),
      style: TextStyle(
        color: tokens.fg,
        fontSize: scale.size,
        height: scale.height,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      // The caret and the selection are where the family reaches a field. The
      // glass under them is never dyed.
      cursorColor: family.accent,
      backgroundCursorColor: tokens.mutedFg,
      selectionColor: family.softPress,
      showSelectionHandles: false,
      enableInteractiveSelection: !widget.disabled,
      cursorOpacityAnimates: true,
    );

    if (widget.placeholder != null) {
      // The placeholder is drawn under the text rather than by the editor, which
      // has no notion of one.
      editor = Stack(
        children: <Widget>[
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _text,
            builder: (BuildContext context, TextEditingValue value, Widget? child) {
              return value.text.isEmpty
                  ? IgnorePointer(
                      child: Text(
                        widget.placeholder!,
                        style: TextStyle(
                          color: tokens.mutedFg,
                          fontSize: scale.size,
                          height: scale.height,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                        maxLines: 1,
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          editor,
        ],
      );
    }

    final chips = widget.multiple && widget.values.isNotEmpty
        ? <Widget>[
            for (final value in widget.values)
              PlChip(
                size: size,
                color: family == tokens.family(PlassColor.danger)
                    ? PlassColor.danger
                    : widget.color,
                density: PlassDensity.compact,
                disabled: widget.disabled,
                deleteLabel: widget.removeLabel(_labelOf(value)),
                onDeleted: widget.readOnly || widget.disabled || !_usable
                    ? null
                    : () => _remove(value),
                child: Text(_labelOf(value)),
              ),
          ]
        : const <Widget>[];

    final glyph = scale.size * iconScale;

    Widget adornment({
      required PlassGlyphShape shape,
      required String label,
      required VoidCallback? onTap,
      double turns = 0,
    }) {
      return Semantics(
        button: true,
        label: label,
        onTap: onTap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: onTap,
          child: MouseRegion(
            cursor: onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
            child: SizedBox(
              height: scale.line,
              child: Center(
                child: AnimatedRotation(
                  turns: turns,
                  duration: PlassTokens.duration,
                  curve: PlassTokens.ease,
                  child: PlassGlyph(shape, size: glyph, color: tokens.mutedFg),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final showClear =
        widget.clearable && !widget.readOnly && !widget.disabled && _chosen.isNotEmpty;

    // With chips in it the field cannot have a fixed height — they wrap — so the
    // height becomes a minimum and the padding is what keeps a one-row combobox
    // exactly as tall as the field beside it.
    Widget shell = Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingX[widget.density]![size]!),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
        spacing: gap[size]!,
        children: <Widget>[
          if (widget.startIcon != null)
            SizedBox(
              height: scale.line,
              child: Center(
                child: IconTheme.merge(
                  data: IconThemeData(color: tokens.mutedFg, size: glyph),
                  child: widget.startIcon!,
                ),
              ),
            ),
          Expanded(
            child: chips.isEmpty
                ? editor
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: _chipInset[size]!),
                    child: Wrap(
                      spacing: _chipGap,
                      runSpacing: _chipGap,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        ...chips,
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: _afterChips),
                          child: SizedBox(width: _queryWidth, child: editor),
                        ),
                      ],
                    ),
                  ),
          ),
          if (showClear)
            adornment(shape: PlassGlyphShape.close, label: widget.clearLabel, onTap: _clear),
          adornment(
            shape: PlassGlyphShape.chevron,
            label: widget.openLabel,
            onTap: _usable ? (_open ? _close : _openList) : null,
            turns: _open ? 0.5 : 0,
          ),
        ],
      ),
    );

    shell = ConstrainedBox(
      constraints: BoxConstraints(minHeight: controlHeight[size]!),
      child: PlassSurfaceBox(surface: surface, borderRadius: radius, child: shell),
    );

    shell = plassStateFilter(
      child: shell,
      disabled: widget.disabled,
      readOnly: widget.readOnly,
      lit: false,
    );

    if (_focused) {
      shell = CustomPaint(
        foregroundPainter: PlassFocusRingPainter(color: family.ring, borderRadius: radius),
        child: shell,
      );
    }

    shell = MouseRegion(
      cursor: widget.disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.text,
      onEnter: (PointerEnterEvent event) => setState(() => _hovered = true),
      onExit: (PointerExitEvent event) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: widget.disabled ? null : _focusNode.requestFocus,
        child: shell,
      ),
    );

    // Bound outside the editor, which keeps the keys a text field needs: these
    // are the list's.
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowDown): _MoveIntent(1),
        SingleActivator(LogicalKeyboardKey.arrowUp): _MoveIntent(-1),
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _MoveIntent: CallbackAction<_MoveIntent>(
            onInvoke: (_MoveIntent intent) {
              _move(intent.by);

              return null;
            },
          ),
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (DismissIntent intent) {
              _close();

              return null;
            },
          ),
        },
        child: shell,
      ),
    );
  }

  /// What a value is called, for a chip and for the × on it.
  String _labelOf(T value) {
    for (final option in widget.options) {
      if (option.value == value) {
        return option.label;
      }
    }

    // A value the list does not have is one `onCreate` made, and its label is
    // the query it was made from.
    return '$value';
  }

  Widget _list(PlassTokens tokens, PlassColorFamily family, PlassTextScale scale) {
    final size = widget.size;
    final rows = _rows;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: _maxPopupHeight),
      child: PlassSurfaceBox(
        surface: PlassSurface(
          fill: tokens.glassPress,
          border: Border.all(color: tokens.glassLine, width: hairline),
          ink: tokens.fg,
          blur: true,
          insets: <PlassInsetShadow>[tokens.glossGlass],
          shadows: tokens.elevation(plassElevationMax),
        ),
        borderRadius: BorderRadius.circular(PlassTokens.radius[size]!),
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          child: rows.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: _rowPaddingY + 2),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: tokens.mutedFg,
                      fontSize: scale.size,
                      height: scale.height,
                    ),
                    child: Text(widget.emptyMessage),
                  ),
                )
              : SingleChildScrollView(
                  controller: _scroll,
                  padding: const EdgeInsets.all(_popupInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (var index = 0; index < rows.length; index += 1)
                        _row(tokens, family, scale, rows[index], index),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _row(
    PlassTokens tokens,
    PlassColorFamily family,
    PlassTextScale scale,
    _Row<T> row,
    int index,
  ) {
    final disabled = row.option?.disabled ?? false;
    final chosen = row.option != null && _chosen.contains(row.option!.value);
    final lit = index == _highlighted && !disabled;
    final ink = disabled
        ? tokens.mutedFg
        : chosen || lit || row.isCreate
        ? family.accent
        : tokens.fg;

    // The pointer and the arrow keys light the same row, which is the whole
    // reason the highlight is a number here rather than a hover state per row.
    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) {
        if (!disabled && _highlighted != index) {
          setState(() => _highlighted = index);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _take(index),
        child: Semantics(
          container: true,
          inMutuallyExclusiveGroup: !row.isCreate,
          selected: chosen,
          enabled: !disabled,
          onTap: disabled ? null : () => _take(index),
          child: Opacity(
            opacity: disabled ? disabledOpacity : 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: lit ? family.soft : null,
                borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.xs]!),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: _tickGutter,
                  end: 8,
                  top: _rowPaddingY,
                  bottom: _rowPaddingY,
                ),
                child: Stack(
                  // The mark sits in the gutter the padding just opened, which is
                  // outside this stack: clipped, it would not be drawn at all.
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    DefaultTextStyle.merge(
                      style: TextStyle(
                        color: ink,
                        fontSize: scale.size,
                        height: scale.height,
                        fontWeight: chosen ? FontWeight.w600 : FontWeight.w400,
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      child: row.isCreate
                          ? (widget.customLabel?.call(row.query!) ?? Text('Add “${row.query}”'))
                          : Text(row.label),
                    ),
                    if (chosen || row.isCreate)
                      PositionedDirectional(
                        top: 0,
                        bottom: 0,
                        start: -_tickGutter + 8,
                        child: Center(
                          child: PlassGlyph(
                            row.isCreate ? PlassGlyphShape.plus : PlassGlyphShape.check,
                            size: scale.size,
                            color: family.accent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// How far a chip line is inset from the field's minimum height.
///
/// `(control height − chip height) / 2`, which is what makes a one-row combobox
/// exactly as tall as the field beside it.
const Map<PlassSize, double> _chipInset = <PlassSize, double>{
  PlassSize.xs: 1,
  PlassSize.sm: 3,
  PlassSize.md: 4,
  PlassSize.lg: 5,
  PlassSize.xl: 6,
};

/// How much room the caret keeps for itself among the chips.
const double _queryWidth = 72;
