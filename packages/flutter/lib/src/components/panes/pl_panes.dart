/// A set of regions with draggable handles between them.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// A pane's share of the split.
///
/// Two constructors rather than the React package's `number | string`, which is
/// a union Dart has no word for. They mean exactly what the two halves of that
/// union mean: a **percentage** is how a split is usually described and keeps
/// its meaning when the window changes size, and an absolute **length** is what
/// a sidebar with a minimum actually needs — "at least 200 pixels" does not
/// survive being written down as a percentage of a width nobody knows yet.
@immutable
class PlPaneSize {
  /// A share of the space the panes divide, from 0 to 100.
  const PlPaneSize.percent(double value) : percent = value, pixels = null;

  /// A length in logical pixels.
  const PlPaneSize.pixels(double value) : pixels = value, percent = null;

  /// The share, when this is a percentage.
  final double? percent;

  /// The length, when this is one.
  final double? pixels;

  /// This size against a run of [extent] logical pixels.
  double resolve(double extent) => pixels ?? extent * percent! / 100;

  @override
  bool operator ==(Object other) {
    return other is PlPaneSize && other.percent == percent && other.pixels == pixels;
  }

  @override
  int get hashCode => Object.hash(percent, pixels);
}

/// One region of a split.
///
/// A **description rather than a widget**, for the reason a
/// [PlBottomNavigationItem] is: the three sizing values are read by the split
/// rather than used by the pane, because a pane cannot know what "half" is —
/// only the thing holding all of them can.
///
/// It carries no surface of its own on purpose: a split is layout, and the
/// moment a pane drew a sheet it would stop being usable as the thing a
/// [PlCard], a [PlTable] or an editor is put inside.
@immutable
class PlPane {
  /// Creates a region.
  const PlPane({required this.child, this.defaultSize, this.minSize, this.maxSize});

  /// What is inside the pane.
  final Widget child;

  /// The share it starts with. Panes with none split whatever is left over
  /// equally.
  final PlPaneSize? defaultSize;

  /// How small it may be dragged.
  final PlPaneSize? minSize;

  /// How large it may be dragged. Unbounded when left out.
  final PlPaneSize? maxSize;
}

/// The width of a handle, and the width of the target the pointer has to hit.
///
/// A visible line one pixel wide is a target one pixel wide, which is not a
/// target. So the handle is a track several pixels across with the hairline
/// drawn down the middle of it — the same split a scrollbar makes between what
/// is drawn and what can be grabbed.
const Map<PlassSize, double> _handleTrack = <PlassSize, double>{
  PlassSize.xs: 4,
  PlassSize.sm: 6,
  PlassSize.md: 8,
  PlassSize.lg: 10,
  PlassSize.xl: 12,
};

/// How far one arrow key press moves a handle.
const double _keyboardStep = 16;

/// Moves a handle by whole steps.
class _NudgeIntent extends Intent {
  const _NudgeIntent(this.steps);

  final int steps;
}

/// A set of regions with draggable handles between them.
///
/// ```dart
/// PlPanes(
///   panes: <PlPane>[
///     PlPane(
///       defaultSize: const PlPaneSize.pixels(240),
///       minSize: const PlPaneSize.pixels(180),
///       child: sidebar,
///     ),
///     PlPane(child: body),
///   ],
/// )
/// ```
///
/// The panes are sized in **fractions** of what is left after the handles have
/// taken their tracks, which is the React package's own arithmetic — and the
/// place where Flutter makes it easier rather than harder. That build needs a
/// `ResizeObserver`, because CSS measures itself and a split inside a collapsed
/// accordion is zero wide when it mounts; a [LayoutBuilder] is handed the
/// extent on every layout pass, so there is nothing to observe and nothing to
/// re-measure.
///
/// The handles are interleaved here rather than written by the caller, so what
/// a caller writes is just panes.
class PlPanes extends StatefulWidget {
  /// Creates a split.
  const PlPanes({
    required this.panes,
    this.orientation = const PlassResponsive<PlassOrientation>(PlassOrientation.horizontal),
    this.resizable = true,
    this.color,
    this.size,
    this.onResize,
    this.onResizeEnd,
    this.label,
    super.key,
  });

  /// The regions.
  final List<PlPane> panes;

  /// Which way they run. `horizontal` puts them side by side with upright
  /// handles between them; `vertical` stacks them.
  ///
  /// **Responsive**, so a set can run one way on a phone and the other on a
  /// laptop. It is resolved against the window's width in `build` rather than
  /// laid out by a constraint, which is what makes two of these side by side
  /// agree about which rung they are on.
  final PlassResponsive<PlassOrientation> orientation;

  /// Whether the handles can be dragged. Turn it off for a split that is a
  /// layout rather than a control.
  final bool resizable;

  /// The colour family the handles light up in.
  ///
  /// A split draws no sheet, so the family only ever shows up in three places:
  /// the handle's hairline under the pointer, the tint behind it, and the focus
  /// ring.
  final PlassColor? color;

  /// How thick a handle is, and how wide the target the pointer has to hit.
  final PlassSize? size;

  /// Fires with every pane's share, in percent, while a handle is dragged.
  final ValueChanged<List<double>>? onResize;

  /// Fires once, with the same shape, when the handle is let go — and on a key
  /// press, which is a whole gesture on its own with no "let go" to wait for.
  final ValueChanged<List<double>>? onResizeEnd;

  /// What a screen reader calls a handle, before the share it is at.
  final String? label;

  @override
  State<PlPanes> createState() => _PlPanesState();
}

class _PlPanesState extends State<PlPanes> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

  /// Every pane's share, summing to one, once anything has moved a handle.
  List<double>? _fractions;

  bool get _horizontal =>
      resolveResponsive(context, widget.orientation) == PlassOrientation.horizontal;

  double get _gutter => _handleTrack[_size]! * (widget.panes.length - 1).clamp(0, double.infinity);

  /// The split as it stands, which is what was dragged to or — until something
  /// has been — what the panes asked for.
  List<double> _current(double extent) {
    final List<double>? held = _fractions;

    if (held != null && held.length == widget.panes.length) {
      return held;
    }

    return _initial(extent);
  }

  /// Every pane's share of the space, summing to one.
  List<double> _initial(double extent) {
    final List<double?> sizes = <double?>[
      for (final PlPane pane in widget.panes) pane.defaultSize?.resolve(extent),
    ];

    final double named = sizes.fold<double>(0, (double total, double? size) => total + (size ?? 0));
    final int unnamed = sizes.where((double? size) => size == null).length;
    // Whatever is left after the named panes, split evenly. Negative when the
    // caller asked for more than there is, which the clamp below turns into
    // zero.
    final double share = unnamed > 0 ? (extent - named).clamp(0, double.infinity) / unnamed : 0;

    final List<double> resolved = <double>[
      for (final double? size in sizes) (size ?? share).clamp(0, double.infinity),
    ];
    final double total = resolved.fold<double>(0, (double sum, double size) => sum + size);

    if (total <= 0) {
      return <double>[for (int i = 0; i < resolved.length; i++) 1 / resolved.length];
    }

    return <double>[for (final double size in resolved) size / total];
  }

  /// Moves the boundary between [index] and the pane after it by [delta]
  /// pixels.
  ///
  /// A drag only ever moves one boundary, so the pair's total is fixed and one
  /// pane's floor is the other's ceiling. Folding all four bounds into a single
  /// range on the first of the pair is what keeps every move to one clamp and
  /// one division.
  List<double>? _resize(int index, double delta, double extent) {
    if (!widget.resizable || extent <= 0 || index + 1 >= widget.panes.length) {
      return null;
    }

    final List<double> current = _current(extent);
    final PlPane before = widget.panes[index];
    final PlPane after = widget.panes[index + 1];

    final double start = current[index] * extent;
    final double pair = start + current[index + 1] * extent;

    final double lower = <double>[
      before.minSize?.resolve(extent) ?? 0,
      pair - (after.maxSize?.resolve(extent) ?? pair),
    ].reduce((double a, double b) => a > b ? a : b);

    final double upper = <double>[
      before.maxSize?.resolve(extent) ?? pair,
      pair - (after.minSize?.resolve(extent) ?? 0),
    ].reduce((double a, double b) => a < b ? a : b);

    if (upper < lower) {
      return null;
    }

    final double sized = (start + delta).clamp(lower, upper);
    final List<double> next = List<double>.of(current);
    next[index] = sized / extent;
    next[index + 1] = (pair - sized) / extent;

    setState(() => _fractions = next);
    widget.onResize?.call(<double>[for (final double fraction in next) fraction * 100]);

    return next;
  }

  void _settle(List<double> fractions) {
    widget.onResizeEnd?.call(<double>[for (final double fraction in fractions) fraction * 100]);
  }

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final PlassColorFamily family = tokens.family(_color);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double run = _horizontal ? constraints.maxWidth : constraints.maxHeight;
        final double extent = run - _gutter;

        if (!extent.isFinite || extent <= 0) {
          // Nothing to divide yet. The panes still lay out, evenly, rather than
          // collapsing to nothing and jumping on the next frame.
          return _line(<Widget>[
            for (final PlPane pane in widget.panes) Expanded(child: _pane(pane)),
          ]);
        }

        final List<double> fractions = _current(extent);
        final List<Widget> children = <Widget>[];

        for (int index = 0; index < widget.panes.length; index++) {
          if (index > 0) {
            children.add(_handle(tokens, family, index - 1, extent, fractions));
          }

          final double size = fractions[index] * extent;

          children.add(
            SizedBox(
              width: _horizontal ? size : null,
              height: _horizontal ? null : size,
              child: _pane(widget.panes[index]),
            ),
          );
        }

        return _line(children);
      },
    );
  }

  Widget _line(List<Widget> children) {
    return _horizontal
        ? Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: children)
        : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }

  /// A pane clips and scrolls its own content, so a long line inside one does
  /// not decide how narrow the pane may be dragged.
  Widget _pane(PlPane pane) => ClipRect(child: pane.child);

  Widget _handle(
    PlassTokens tokens,
    PlassColorFamily family,
    int index,
    double extent,
    List<double> fractions,
  ) {
    final double track = _handleTrack[_size]!;

    return _Handle(
      track: track,
      horizontal: _horizontal,
      resizable: widget.resizable,
      family: family,
      rest: tokens.border,
      label: widget.label,
      share: (fractions[index] * 100).round(),
      // What one key press is worth, as a share — Flutter will not take an
      // increase action without being told what the value becomes.
      step: (_keyboardStep / extent * 100).round().clamp(1, 100),
      onDrag: (double delta) => _resize(index, delta, extent),
      onSettle: _settle,
      onNudge: (int steps) {
        final List<double>? next = _resize(index, steps * _keyboardStep, extent);

        // A key press is a whole gesture on its own — there is no "let go" to
        // wait for, so the settled callback fires with it.
        if (next != null) {
          _settle(next);
        }
      },
    );
  }
}

/// One handle: the track that can be grabbed, and the hairline drawn down it.
class _Handle extends StatefulWidget {
  const _Handle({
    required this.track,
    required this.horizontal,
    required this.resizable,
    required this.family,
    required this.rest,
    required this.share,
    required this.step,
    required this.onDrag,
    required this.onSettle,
    required this.onNudge,
    this.label,
  });

  final double track;
  final bool horizontal;
  final bool resizable;
  final PlassColorFamily family;
  final Color rest;
  final String? label;
  final int share;
  final int step;
  final List<double>? Function(double delta) onDrag;
  final ValueChanged<List<double>> onSettle;
  final ValueChanged<int> onNudge;

  @override
  State<_Handle> createState() => _HandleState();
}

class _HandleState extends State<_Handle> {
  bool _hovered = false;
  bool _dragging = false;
  bool _focusVisible = false;
  List<double>? _latest;

  @override
  Widget build(BuildContext context) {
    final bool lit = widget.resizable && (_hovered || _dragging || _focusVisible);
    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    // What is *drawn* is the hairline; what can be **grabbed** is the track
    // around it — the same split a scrollbar makes between the two.
    Widget mark = Align(
      child: SizedBox(
        width: widget.horizontal ? hairline : null,
        height: widget.horizontal ? null : hairline,
        child: AnimatedContainer(
          duration: PlassTokens.duration,
          curve: PlassTokens.ease,
          color: lit ? widget.family.accent : widget.rest,
        ),
      ),
    );

    mark = SizedBox(
      width: widget.horizontal ? widget.track : double.infinity,
      height: widget.horizontal ? double.infinity : widget.track,
      child: AnimatedContainer(
        duration: PlassTokens.duration,
        curve: PlassTokens.ease,
        color: lit ? widget.family.soft : null,
        child: mark,
      ),
    );

    if (_focusVisible) {
      mark = CustomPaint(
        foregroundPainter: PlassFocusRingPainter(
          color: widget.family.ring,
          borderRadius: BorderRadius.zero,
          offset: -focusRingWidth,
        ),
        child: mark,
      );
    }

    Widget handle = MouseRegion(
      cursor: widget.resizable
          ? (widget.horizontal ? SystemMouseCursors.resizeColumn : SystemMouseCursors.resizeRow)
          : MouseCursor.defer,
      onEnter: (PointerEnterEvent event) => setState(() => _hovered = true),
      onExit: (PointerExitEvent event) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onHorizontalDragStart: widget.resizable && widget.horizontal ? _start : null,
        onHorizontalDragUpdate: widget.resizable && widget.horizontal
            // Positive is always "toward the end", so a drag under RTL moves the
            // boundary the way the pointer went rather than the way the axis is
            // numbered.
            ? (DragUpdateDetails details) => _drag(rtl ? -details.delta.dx : details.delta.dx)
            : null,
        onHorizontalDragEnd: widget.resizable && widget.horizontal ? _end : null,
        onVerticalDragStart: widget.resizable && !widget.horizontal ? _start : null,
        onVerticalDragUpdate: widget.resizable && !widget.horizontal
            ? (DragUpdateDetails details) => _drag(details.delta.dy)
            : null,
        onVerticalDragEnd: widget.resizable && !widget.horizontal ? _end : null,
        child: mark,
      ),
    );

    if (widget.resizable) {
      handle = FocusableActionDetector(
        includeFocusSemantics: false,
        onShowFocusHighlight: (bool value) {
          if (_focusVisible != value) {
            setState(() => _focusVisible = value);
          }
        },
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.arrowRight): _NudgeIntent(1),
          SingleActivator(LogicalKeyboardKey.arrowDown): _NudgeIntent(1),
          SingleActivator(LogicalKeyboardKey.arrowLeft): _NudgeIntent(-1),
          SingleActivator(LogicalKeyboardKey.arrowUp): _NudgeIntent(-1),
        },
        actions: <Type, Action<Intent>>{
          _NudgeIntent: CallbackAction<_NudgeIntent>(
            onInvoke: (_NudgeIntent intent) {
              final int steps = widget.horizontal && rtl ? -intent.steps : intent.steps;
              widget.onNudge(steps);
              return null;
            },
          ),
        },
        child: handle,
      );
    }

    // Flutter's semantics tree has no `separator` role and no `valuenow`, so a
    // handle is what it actually is to a screen reader: a control with a value
    // that can be turned up and down.
    return Semantics(
      slider: true,
      enabled: widget.resizable,
      label: widget.label,
      value: '${widget.share}%',
      increasedValue: '${(widget.share + widget.step).clamp(0, 100)}%',
      decreasedValue: '${(widget.share - widget.step).clamp(0, 100)}%',
      onIncrease: widget.resizable ? () => widget.onNudge(1) : null,
      onDecrease: widget.resizable ? () => widget.onNudge(-1) : null,
      child: ExcludeSemantics(child: handle),
    );
  }

  void _start(DragStartDetails details) => setState(() => _dragging = true);

  void _drag(double delta) {
    _latest = widget.onDrag(delta) ?? _latest;
  }

  void _end(DragEndDetails details) {
    setState(() => _dragging = false);

    final List<double>? settled = _latest;
    _latest = null;

    if (settled != null) {
      widget.onSettle(settled);
    }
  }
}
