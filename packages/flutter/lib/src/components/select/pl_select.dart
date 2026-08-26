/// One value chosen from a list of them.
library;

import 'package:flutter/services.dart';
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

/// How tall the list is allowed to get before it scrolls.
const double _maxPopupHeight = 320;

/// The room the popup keeps around its rows.
const double _popupInset = 4;

/// A row's vertical padding.
const double _rowPaddingY = 6;

/// The room the tick keeps at the leading edge of a row.
const double _tickGutter = 28;

/// How far the list stands off the trigger.
const double _standoff = 6;

/// Moves the highlight through the list.
class _MoveIntent extends Intent {
  const _MoveIntent(this.by);

  final int by;
}

/// Jumps it to one end.
class _EdgeIntent extends Intent {
  const _EdgeIntent(this.toEnd);

  final bool toEnd;
}

/// One choice.
///
/// A description rather than a widget, for the reason a [PlRadioOption] is one:
/// the select owns the highlight, the arrow keys and what the trigger says, so
/// it has to know which option is chosen, which are available and what each one
/// is called.
@immutable
class PlSelectOption<T> {
  /// Creates an option.
  const PlSelectOption({required this.value, this.label, this.disabled = false});

  /// What [PlSelect.value] holds, and what [PlSelect.onChanged] reports.
  final T value;

  /// Shown in the list and in the trigger. The value's own `toString` if it is
  /// left out.
  final Widget? label;

  /// Unavailable, but still listed — the option exists, it just cannot be taken.
  final bool disabled;
}

/// One value chosen from a list of them.
///
/// ```dart
/// PlSelect<String>(
///   label: const Text('City'),
///   value: city,
///   onChanged: (String? next) => setState(() => city = next),
///   options: const <PlSelectOption<String>>[
///     PlSelectOption<String>(value: 'kr-11', label: Text('Seoul')),
///     PlSelectOption<String>(value: 'jp-13', label: Text('Tokyo')),
///   ],
/// )
/// ```
///
/// The trigger is a [PlTextField]'s shell wearing a chevron, on purpose: a form
/// where the select is a different height, radius or material from the fields
/// around it is a form that looks assembled rather than designed.
///
/// The list is the same floating sheet a `PlTooltip`'s plate is — the glass at
/// its most opaque, because it has a page under it rather than a sheet, and a
/// 62%-translucent pane over arbitrary body copy is a pane you read the body
/// copy through.
///
/// The trigger holds its width at the longest label it could ever say, so
/// choosing a shorter one does not shrink the field out from under the pointer
/// that chose it.
///
/// Needs an [Overlay] above it, which `WidgetsApp` with a navigator and
/// `MaterialApp` both provide.
class PlSelect<T> extends StatefulWidget {
  /// Creates a select.
  const PlSelect({
    required this.options,
    required this.value,
    this.onChanged,
    this.placeholder,
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
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The choices, in order.
  final List<PlSelectOption<T>> options;

  /// The chosen value, or `null` for none.
  final T? value;

  /// Called with the value that was chosen.
  final ValueChanged<T?>? onChanged;

  /// Shown in the trigger while nothing is chosen.
  final Widget? placeholder;

  /// What the trigger's well is cut into.
  final PlassVariant variant;

  /// Height and type scale.
  final PlassSize size;

  /// Semantic colour role. It reaches the edge, the ring and the chosen row.
  final PlassColor color;

  /// Horizontal padding. Never the height.
  final PlassDensity density;

  /// Drop shadow depth of the **trigger**.
  ///
  /// `0`, like a [PlTextField]: a field is cut into the sheet rather than
  /// resting on it. The list has its own, fixed at the top of the ladder — it
  /// genuinely floats above the page, which is the one case elevation is for.
  final PlassElevation elevation;

  /// Label above the trigger.
  final Widget? label;

  /// Helper text below it.
  final Widget? description;

  /// Error message below it. Its presence also turns the select invalid.
  final Widget? error;

  /// Forces the invalid state without a message.
  final bool? invalid;

  /// Content before the value.
  final Widget? startIcon;

  /// Stretches to the width of the container.
  final bool fullWidth;

  /// The value is shown but cannot be changed, and the list does not open.
  final bool readOnly;

  /// Unavailable.
  final bool disabled;

  /// The name a screen reader gives the select.
  final String? semanticLabel;

  /// Drive focus from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  @override
  State<PlSelect<T>> createState() => _PlSelectState<T>();
}

class _PlSelectState<T> extends State<PlSelect<T>> {
  final ScrollController _scroll = ScrollController();
  FocusNode? _owned;
  bool _open = false;

  /// Which row the keyboard is on. `-1` is none, which is what an empty list and
  /// a freshly opened select with nothing chosen both are.
  int _highlighted = -1;

  @override
  void dispose() {
    _scroll.dispose();
    _owned?.dispose();
    super.dispose();
  }

  FocusNode get _focusNode => widget.focusNode ?? (_owned ??= FocusNode(debugLabel: 'PlSelect'));

  bool get _usable => !widget.disabled && !widget.readOnly && widget.onChanged != null;

  int get _chosen =>
      widget.options.indexWhere((PlSelectOption<T> option) => option.value == widget.value);

  void _openList() {
    if (!_usable || _open) {
      return;
    }

    // The trigger takes focus as the list opens, because the list's keys are
    // bound to the trigger: an open select nothing is focused on is a list the
    // arrow keys cannot reach.
    _focusNode.requestFocus();

    setState(() {
      _open = true;
      // Opens on the chosen row, or on the first one that can be taken.
      _highlighted = _chosen >= 0 ? _chosen : _next(-1, 1);
    });
  }

  void _close() {
    if (_open) {
      setState(() => _open = false);
    }
  }

  /// The next row in [by]'s direction that can actually be taken.
  int _next(int from, int by) {
    final count = widget.options.length;

    for (var step = 1; step <= count; step += 1) {
      final index = (from + by * step) % count;
      final wrapped = index < 0 ? index + count : index;

      if (!widget.options[wrapped].disabled) {
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

  void _edge(bool toEnd) {
    if (!_open) {
      return;
    }

    final next = toEnd ? _next(widget.options.length, -1) : _next(-1, 1);

    if (next >= 0) {
      setState(() => _highlighted = next);
    }
  }

  void _take(int index) {
    if (index < 0 || index >= widget.options.length || widget.options[index].disabled) {
      return;
    }

    widget.onChanged?.call(widget.options[index].value);
    _close();
  }

  /// What the trigger says, and what it must stay wide enough to say.
  Widget _label(PlSelectOption<T> option) {
    return option.label ?? Text('${option.value}');
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
    final chosen = _chosen;

    Widget trigger = PlassInteractive(
      onTap: _open ? () => _take(_highlighted) : _openList,
      enabled: !widget.disabled,
      interactive: _usable,
      cursor: widget.disabled
          ? SystemMouseCursors.forbidden
          : _usable
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      // Space would scroll a page under a closed select, and the arrow keys
      // below are what opens it from the keyboard anyway.
      shortcuts: PlassInteractive.enterOnly,
      onFocusChange: (bool has) {
        if (!has) {
          _close();
        }
      },
      builder: (BuildContext context, PlassInteraction state) {
        final surface = fieldSurface(
          tokens,
          family,
          variant: widget.variant,
          elevation: widget.elevation,
          hovered: state.hovered,
          focused: state.focusVisible || _open,
          readOnly: widget.readOnly,
          disabled: widget.disabled,
        );

        Widget shell = ConstrainedBox(
          constraints: BoxConstraints(minHeight: controlHeight[size]!),
          child: PlassSurfaceBox(
            surface: surface,
            borderRadius: radius,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingX[widget.density]![size]!),
              child: Row(
                mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                spacing: gap[size]!,
                children: <Widget>[
                  if (widget.startIcon != null)
                    IconTheme.merge(
                      data: IconThemeData(color: tokens.mutedFg, size: scale.size * iconScale),
                      child: widget.startIcon!,
                    ),
                  // Stretched only when the field was told to fill its
                  // container: with `fullWidth` off the trigger is as wide as
                  // its widest label, and the chevron belongs against that
                  // rather than out at the end of a box nobody asked for.
                  if (widget.fullWidth)
                    Expanded(child: _value(tokens, scale, chosen: chosen))
                  else
                    Flexible(child: _value(tokens, scale, chosen: chosen)),
                  // The chevron is the one thing here that may turn: it is a
                  // glyph, not a label, and nothing about it resamples.
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: PlassTokens.duration,
                    curve: PlassTokens.ease,
                    child: PlassGlyph(
                      PlassGlyphShape.chevron,
                      size: scale.size * iconScale,
                      color: tokens.mutedFg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        shell = plassStateFilter(
          child: shell,
          disabled: widget.disabled,
          readOnly: widget.readOnly,
          lit: false,
        );

        if (state.focusVisible) {
          shell = CustomPaint(
            foregroundPainter: PlassFocusRingPainter(color: family.ring, borderRadius: radius),
            child: shell,
          );
        }

        return Semantics(
          container: true,
          button: true,
          expanded: _open,
          readOnly: widget.readOnly,
          enabled: !widget.disabled,
          label: widget.semanticLabel,
          value: chosen >= 0 ? _spoken(widget.options[chosen]) : null,
          onTap: _usable ? _openList : null,
          child: shell,
        );
      },
    );

    // Bound outside the trigger's own shortcuts, which keep Enter: these are the
    // keys a list needs and a button does not.
    trigger = Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowDown): _MoveIntent(1),
        SingleActivator(LogicalKeyboardKey.arrowUp): _MoveIntent(-1),
        SingleActivator(LogicalKeyboardKey.home): _EdgeIntent(false),
        SingleActivator(LogicalKeyboardKey.end): _EdgeIntent(true),
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
          _EdgeIntent: CallbackAction<_EdgeIntent>(
            onInvoke: (_EdgeIntent intent) {
              _edge(intent.toEnd);

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
        child: trigger,
      ),
    );

    final field = PlassAnchoredPortal(
      open: _open,
      side: PlassSide.bottom,
      align: PlassAlign.start,
      offset: _standoff,
      matchAnchorWidth: true,
      onDismiss: _close,
      popup: _list(tokens, family, scale),
      child: trigger,
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

    return widget.fullWidth ? stack : IntrinsicWidth(child: stack);
  }

  /// The chosen label, over every label it could have been.
  ///
  /// The samples are laid out and not painted, so the trigger is as wide as the
  /// longest thing it could ever say: a field that shrank when a shorter option
  /// was taken would move out from under the pointer that took it.
  Widget _value(PlassTokens tokens, PlassTextScale scale, {required int chosen}) {
    final samples = <Widget>[
      for (final option in widget.options) _label(option),
      if (widget.placeholder != null) widget.placeholder!,
    ];

    return DefaultTextStyle.merge(
      style: TextStyle(
        color: chosen >= 0 ? tokens.fg : tokens.mutedFg,
        fontSize: scale.size,
        height: scale.height,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: <Widget>[
          for (final sample in samples)
            Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: sample,
            ),
          if (chosen >= 0)
            _label(widget.options[chosen])
          else
            widget.placeholder ?? const SizedBox.shrink(),
        ],
      ),
    );
  }

  /// What a screen reader calls an option, when it can.
  String? _spoken(PlSelectOption<T> option) {
    final label = option.label;

    return label is Text ? label.data : '${option.value}';
  }

  Widget _list(PlassTokens tokens, PlassColorFamily family, PlassTextScale scale) {
    final size = widget.size;
    final radius = PlassTokens.radius[size]!;
    final chosen = _chosen;

    // As wide as its widest row and no wider — a scroll view fills whatever
    // cross-axis room it is given, and what it is given here is the screen. The
    // anchor's width comes back as a *minimum* from the portal, so the list is
    // never narrower than the field it belongs to either.
    return IntrinsicWidth(
      child: ConstrainedBox(
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
          borderRadius: BorderRadius.circular(radius),
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.all(_popupInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (var index = 0; index < widget.options.length; index += 1)
                    _row(tokens, family, scale, index: index, chosen: index == chosen),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(
    PlassTokens tokens,
    PlassColorFamily family,
    PlassTextScale scale, {
    required int index,
    required bool chosen,
  }) {
    final option = widget.options[index];
    final lit = index == _highlighted && !option.disabled;
    final ink = option.disabled
        ? tokens.mutedFg
        : chosen || lit
        ? family.accent
        : tokens.fg;

    // The pointer and the arrow keys light the same row, which is the whole
    // reason the highlight is a number here rather than a hover state per row.
    return MouseRegion(
      cursor: option.disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) {
        if (!option.disabled && _highlighted != index) {
          setState(() => _highlighted = index);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _take(index),
        child: Semantics(
          container: true,
          inMutuallyExclusiveGroup: true,
          selected: chosen,
          enabled: !option.disabled,
          onTap: option.disabled ? null : () => _take(index),
          child: Opacity(
            opacity: option.disabled ? disabledOpacity : 1,
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
                  // The tick sits in the gutter the padding just opened, which
                  // is outside this stack: clipped, it would not be drawn at all.
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
                      child: _label(option),
                    ),
                    if (chosen)
                      PositionedDirectional(
                        top: 0,
                        bottom: 0,
                        start: -_tickGutter + 8,
                        child: Center(
                          child: PlassGlyph(
                            PlassGlyphShape.check,
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
