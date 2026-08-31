/// Two or more choices in one pill, exactly one of them taken.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How much room the groove keeps around the tile riding in it.
const double _troughInset = 4;

/// One choice in a [PlSegmentedButton].
///
/// A description rather than a widget, for the reason a `PlRadioOption` is one:
/// the set owns the roving focus, the arrow keys and the tile that slides
/// between the segments, so it has to know which one is taken and where each one
/// is. It carries no `size`, no `color` and no `variant` either — all three
/// belong to the set, and a segmented button whose third segment is a size out
/// is not a segmented button.
@immutable
class PlSegment<T> {
  /// Creates a segment.
  const PlSegment({
    required this.value,
    this.label,
    this.startIcon,
    this.endIcon,
    this.disabled = false,
  });

  /// Identifies the segment. What [PlSegmentedButton.onChanged] reports.
  final T value;

  /// What the segment says.
  final Widget? label;

  /// Content before the label. Sized against the label rather than the row.
  final Widget? startIcon;

  /// Content after it — a count, a status dot.
  final Widget? endIcon;

  /// Unavailable, but still part of the set.
  final bool disabled;
}

/// Two or more choices in one pill, exactly one of them taken.
///
/// ```dart
/// PlSegmentedButton<String>(
///   value: view,
///   onChanged: (String next) => setState(() => view = next),
///   segments: const <PlSegment<String>>[
///     PlSegment<String>(value: 'list', label: Text('List')),
///     PlSegment<String>(value: 'board', label: Text('Board')),
///   ],
/// )
/// ```
///
/// Underneath it is a set of mutually exclusive options, and that is the whole
/// accessibility argument: a segmented button **is** "exactly one of these", so
/// it takes one focus stop, moves with the arrow keys, and reports which one is
/// taken. Building it out of toggles would announce four independent switches,
/// three of which happen to be off.
///
/// The tile slides because its rectangle is measured off the chosen segment and
/// animated. Nothing is transformed: the tile is an empty box, and no label is
/// resampled while it travels — which is what lets the house no-transform rule
/// survive a component whose entire point is that something moves.
class PlSegmentedButton<T> extends StatefulWidget {
  /// Creates a set.
  const PlSegmentedButton({
    required this.segments,
    required this.value,
    this.onChanged,
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    this.fullWidth = false,
    this.readOnly = false,
    this.disabled = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The choices, in order.
  final List<PlSegment<T>> segments;

  /// Which one is taken, or `null` for none.
  final T? value;

  /// Called with the segment that was chosen.
  final ValueChanged<T>? onChanged;

  /// What the groove and the tile riding in it are made of.
  ///
  /// - [PlassVariant.solid] — a groove cut into the sheet with a **tinted-glass
  ///   key** riding in it. The loudest, and the one for a control a screen is
  ///   about to be steered by.
  /// - [PlassVariant.glass] — the same groove with a hairline round it and a
  ///   clear tile rather than a coloured one. The default.
  /// - [PlassVariant.ghost] — no groove at all: the segments sit straight on the
  ///   page and only the chosen one has a surface.
  final PlassVariant variant;

  /// Height and type scale, shared by every segment.
  final PlassSize? size;

  /// Semantic colour role.
  final PlassColor? color;

  /// Changes horizontal padding and nothing else.
  final PlassDensity? density;

  /// Drop shadow depth of the groove. `0` is the default — a groove is cut into
  /// the page, not laid on it.
  final PlassElevation elevation;

  /// The segments share the full width, each taking an equal part of it.
  final bool fullWidth;

  /// Shows which one is taken but does not let it be changed.
  final bool readOnly;

  /// Unavailable. The light goes out.
  final bool disabled;

  /// The name a screen reader gives the set.
  final String? semanticLabel;

  /// Drive the set's one focus stop from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  @override
  State<PlSegmentedButton<T>> createState() => _PlSegmentedButtonState<T>();
}

class _PlSegmentedButtonState<T> extends State<PlSegmentedButton<T>> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  /// One key per segment, so the tile can be measured off the chosen one.
  ///
  /// A key per segment rather than a fraction of the width: the segments are as
  /// wide as their labels unless `fullWidth` says otherwise, and a tile placed
  /// by arithmetic would sit under the wrong one the moment two labels differ in
  /// length.
  final List<GlobalKey> _keys = <GlobalKey>[];
  final GlobalKey _trough = GlobalKey();

  Rect? _tile;

  bool get _disabled => widget.disabled || widget.onChanged == null;

  bool get _interactive => !_disabled && !widget.readOnly;

  int get _chosen => widget.segments.indexWhere((PlSegment<T> one) => one.value == widget.value);

  int get _focused {
    final chosen = _chosen;

    if (chosen >= 0) {
      return chosen;
    }

    final first = widget.segments.indexWhere((PlSegment<T> one) => !one.disabled);

    return first < 0 ? 0 : first;
  }

  @override
  void initState() {
    super.initState();
    _syncKeys();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _measure());
  }

  @override
  void didUpdateWidget(PlSegmentedButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncKeys();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _measure());
  }

  void _syncKeys() {
    while (_keys.length < widget.segments.length) {
      _keys.add(GlobalKey());
    }

    if (_keys.length > widget.segments.length) {
      _keys.removeRange(widget.segments.length, _keys.length);
    }
  }

  /// Reads the chosen segment's box, in the groove's own coordinates.
  void _measure() {
    if (!mounted) {
      return;
    }

    final chosen = _chosen;
    final trough = _trough.currentContext?.findRenderObject() as RenderBox?;
    final segment = chosen >= 0
        ? _keys[chosen].currentContext?.findRenderObject() as RenderBox?
        : null;

    final next = segment != null && trough != null && segment.hasSize && trough.hasSize
        ? (segment.localToGlobal(Offset.zero, ancestor: trough) & segment.size)
        : null;

    if (next != _tile) {
      setState(() => _tile = next);
    }
  }

  void _move(int step) {
    if (!_interactive || widget.segments.isEmpty) {
      return;
    }

    final count = widget.segments.length;
    var index = _focused;

    for (var tried = 0; tried < count; tried += 1) {
      index = (index + step + count) % count;

      if (!widget.segments[index].disabled) {
        widget.onChanged!(widget.segments[index].value);

        return;
      }
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.arrowDown:
        _move(1);

        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.arrowUp:
        _move(-1);

        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(_color);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final height = controlHeight[_size]!;
    final ghost = widget.variant == PlassVariant.ghost;
    final inset = ghost ? 0.0 : _troughInset;

    // The groove carries the well, the one inset shadow in the library and the
    // same one a `solid` field is drawn with: a segmented button, a slider's
    // rail and a filled text field are the same idea — something recessed that
    // holds a value.
    final trough = switch (widget.variant) {
      PlassVariant.solid => PlassSurface(
        fill: tokens.glassPress,
        ink: tokens.fg,
        blur: true,
        insets: <PlassInsetShadow>[tokens.well],
        shadows: tokens.elevation(widget.elevation),
      ),
      PlassVariant.glass => PlassSurface(
        fill: tokens.glass,
        border: Border.all(color: tokens.glassLine, width: hairline),
        ink: tokens.fg,
        blur: true,
        insets: <PlassInsetShadow>[tokens.well],
        shadows: tokens.elevation(widget.elevation),
      ),
      PlassVariant.ghost => PlassSurface(ink: tokens.fg),
    };

    final chosen = _chosen;

    final segments = <Widget>[
      for (var index = 0; index < widget.segments.length; index += 1)
        _Tile<T>(
          key: _keys[index],
          segment: widget.segments[index],
          chosen: index == chosen,
          size: _size,
          density: _density,
          variant: widget.variant,
          family: family,
          tokens: tokens,
          height: height,
          disabled: _disabled || widget.segments[index].disabled,
          readOnly: widget.readOnly,
          onPressed: _interactive && !widget.segments[index].disabled
              ? () => widget.onChanged!(widget.segments[index].value)
              : null,
          focusable: index == _focused,
          focusNode: index == _focused ? widget.focusNode : null,
          autofocus: index == _focused && widget.autofocus,
        ),
    ];

    Widget row = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: <Widget>[
        for (final segment in segments)
          if (widget.fullWidth) Expanded(child: segment) else segment,
      ],
    );

    // The tile rides *behind* the labels, which is why it is a stack rather than
    // a decoration on the chosen segment: a decoration would jump between
    // segments, and this one travels.
    row = Stack(
      key: _trough,
      children: <Widget>[
        if (_tile != null)
          AnimatedPositioned(
            duration: reduceMotion ? Duration.zero : PlassTokens.duration,
            curve: PlassTokens.ease,
            left: _tile!.left,
            top: _tile!.top,
            width: _tile!.width,
            height: _tile!.height,
            child: _Riding(variant: widget.variant, family: family, tokens: tokens),
          ),
        row,
      ],
    );

    row = Padding(padding: EdgeInsets.all(inset), child: row);

    Widget set = PlassSurfaceBox(
      surface: trough,
      // Round, and one of only three places the library allows it — for the same
      // reason a switch's track is: this is not a sheet lying on the page, it is
      // a groove cut into one.
      borderRadius: BorderRadius.circular(height + inset * 2),
      child: row,
    );

    set = plassStateFilter(child: set, disabled: _disabled, readOnly: widget.readOnly, lit: false);

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: Semantics(
        container: true,
        label: widget.semanticLabel,
        enabled: _interactive,
        child: widget.fullWidth ? set : IntrinsicWidth(child: set),
      ),
    );
  }
}

/// The tile that slides.
///
/// `solid` makes it the family's gradient with that family's tinted shadow under
/// it — a key of tinted glass riding in a groove, which is the design language's
/// own sentence with nothing added. The other two lift a pane of clear glass
/// instead and leave the label in the accent.
class _Riding extends StatelessWidget {
  const _Riding({required this.variant, required this.family, required this.tokens});

  final PlassVariant variant;
  final PlassColorFamily family;
  final PlassTokens tokens;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(999),
        gradient: variant == PlassVariant.solid ? family.fill : null,
        color: variant == PlassVariant.solid ? null : tokens.glassPress,
        boxShadow: <BoxShadow>[
          ...tokens.elevation(1),
          if (variant == PlassVariant.solid) tokens.lift(family),
        ],
      ),
    );
  }
}

/// One drawn segment.
class _Tile<T> extends StatelessWidget {
  const _Tile({
    required this.segment,
    required this.chosen,
    required this.size,
    required this.density,
    required this.variant,
    required this.family,
    required this.tokens,
    required this.height,
    required this.disabled,
    required this.readOnly,
    required this.onPressed,
    required this.focusable,
    required this.focusNode,
    required this.autofocus,
    super.key,
  });

  final PlSegment<T> segment;
  final bool chosen;
  final PlassSize size;
  final PlassDensity density;
  final PlassVariant variant;
  final PlassColorFamily family;
  final PlassTokens tokens;
  final double height;
  final bool disabled;
  final bool readOnly;
  final VoidCallback? onPressed;
  final bool focusable;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final fontSize = controlText[size]!;

    return ExcludeFocus(
      excluding: !focusable,
      child: PlassInteractive(
        onTap: onPressed,
        interactive: onPressed != null,
        enabled: !disabled,
        focusNode: focusNode,
        autofocus: autofocus,
        cursor: disabled
            ? SystemMouseCursors.forbidden
            : readOnly
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        builder: (BuildContext context, PlassInteraction state) {
          final ink = disabled
              ? tokens.mutedFg
              : chosen
              ? (variant == PlassVariant.solid ? family.onSolid : family.accent)
              : state.hovered
              ? tokens.fg
              : tokens.mutedFg;

          Widget body = SizedBox(
            height: height,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingX[density]![size]!),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: ink,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
                maxLines: 1,
                softWrap: false,
                child: IconTheme.merge(
                  data: IconThemeData(color: ink, size: fontSize * iconScale),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: gap[size]!,
                    children: <Widget>[?segment.startIcon, ?segment.label, ?segment.endIcon],
                  ),
                ),
              ),
            ),
          );

          body = plassStateFilter(child: body, disabled: disabled, lit: false);

          if (state.focusVisible) {
            // Inset rather than offset — an offset ring on a segment inside a
            // groove is drawn on top of its neighbours.
            body = CustomPaint(
              foregroundPainter: PlassFocusRingPainter(
                color: family.ring,
                borderRadius: BorderRadius.circular(height),
                offset: -focusRingWidth,
              ),
              child: body,
            );
          }

          return Semantics(
            container: true,
            inMutuallyExclusiveGroup: true,
            checked: chosen,
            enabled: onPressed != null,
            onTap: onPressed,
            child: body,
          );
        },
      ),
    );
  }
}
