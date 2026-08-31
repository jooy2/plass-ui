/// A field that only holds a number.
library;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/keys.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How long a held stepper waits before it starts repeating.
///
/// The pause is what tells a press from a hold. A press steps once when it is
/// released, the way every other button in the library fires; only a press that
/// outlasts this becomes a run of steps, and without the pause a slow finger
/// would be worth two of them.
const Duration _repeatDelay = Duration(milliseconds: 400);

/// How often a held stepper fires after the pause.
const Duration _repeatInterval = Duration(milliseconds: 60);

/// A stepper's box, as a multiple of the number beside it.
///
/// A ratio rather than a ladder, so the same button works at every step of the
/// scale: a stepper belongs to the digits it moves, not to the row it sits in.
const double _stepperScale = 1.7;

/// The glyph inside it, on the same ratio.
const double _stepperGlyphScale = 0.9;

/// The gap between the two steppers when they sit together at the end.
const double _stepperGap = 2;

/// Where the two steppers sit.
enum PlNumberFieldSteppers {
  /// Both at the trailing edge, the way a spinner has always looked.
  end,

  /// Minus at the start, plus at the end, with the number between them. For a
  /// quantity that is nudged rather than typed.
  split,

  /// No buttons. The field is still a number field: the arrow keys, the
  /// clamping and the formatting all stay.
  ///
  /// There is deliberately no stacked pair of half-height chevrons. At `xs` each
  /// arrow would be under three pixels tall, and a target that small is a target
  /// nobody hits.
  none,
}

/// Steps the value by one [PlNumberField.step].
class _StepIntent extends Intent {
  const _StepIntent(this.direction, {this.amount = _StepAmount.normal});

  final int direction;
  final _StepAmount amount;
}

/// Jumps to an end of the range.
class _EdgeIntent extends Intent {
  const _EdgeIntent(this.toEnd);

  final bool toEnd;
}

/// Which of the three steps a key press asked for.
enum _StepAmount { small, normal, large }

/// A field that only holds a number.
///
/// ```dart
/// PlNumberField(
///   value: quantity,
///   min: 0,
///   max: 99,
///   onChanged: (double? next) => setState(() => quantity = next),
/// )
/// ```
///
/// The shell is a [PlTextField]'s, to the pixel, because a form where the
/// quantity box is a different height or radius from the boxes around it is a
/// form that looks assembled rather than designed. What is added on top is a
/// real numeric control: the arrow keys and the steppers move by [step]
/// (<kbd>Shift</kbd> for [largeStep], <kbd>Alt</kbd> for [smallStep]), the value
/// clamps to [min] and [max] when it settles, and [format] writes it as currency
/// or a percentage while [value] stays a plain number.
///
/// **Controlled**, like every other input in the package: it is handed a value
/// and reports what the value should become.
class PlNumberField extends StatefulWidget {
  /// Creates a number field.
  const PlNumberField({
    required this.value,
    this.onChanged,
    this.onCommitted,
    this.min,
    this.max,
    this.step = 1,
    this.largeStep = 10,
    this.smallStep = 0.1,
    this.snapOnStep = false,
    this.allowWheelScrub = false,
    this.format,
    this.parse,
    this.steppers = PlNumberFieldSteppers.end,
    this.incrementLabel = 'Increase',
    this.decrementLabel = 'Decrease',
    this.hotKeys,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.elevation = 0,
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.placeholder,
    this.startIcon,
    this.endIcon,
    this.fullWidth = false,
    this.readOnly = false,
    this.disabled = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(step > 0, 'step must be positive'),
       assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The number, or `null` for an empty field.
  final double? value;

  /// Called on every change — a keystroke, a step, the wheel.
  ///
  /// What it reports while a number is being typed is what has been typed, not
  /// what it will settle to: `5` on the way to `50` is not out of a range that
  /// starts at ten, it is half-finished. The clamp happens when the field
  /// settles.
  final ValueChanged<double?>? onChanged;

  /// Called when the value settles: on blur after typing, on release after a
  /// press, and alongside [onChanged] for the keyboard.
  final ValueChanged<double?>? onCommitted;

  /// The bottom of the range. Stepping stops here.
  final double? min;

  /// The top of the range.
  final double? max;

  /// How far one step goes.
  final double step;

  /// The step taken while <kbd>Shift</kbd> is held.
  final double largeStep;

  /// The step taken while <kbd>Alt</kbd> is held.
  final double smallStep;

  /// Whether stepping snaps to multiples of [step].
  final bool snapOnStep;

  /// Whether the wheel changes the value while the field is focused and the
  /// pointer is over it.
  ///
  /// Off by default: a page that scrolls under the pointer and a field that
  /// changes under it are the same gesture, and only one of them was meant.
  final bool allowWheelScrub;

  /// How a settled value is written — a currency mark, a unit, a fixed number of
  /// decimal places.
  ///
  /// Two functions rather than the React build's one options object, because
  /// there is no `Intl.NumberFormat` in the Dart SDK and this package has no
  /// dependencies. [format] is the half that writes and [parse] is the half that
  /// reads; a field that formats without parsing cannot be typed into.
  ///
  /// Left out, a whole number is written without a decimal point and everything
  /// else as Dart writes it.
  final String Function(double value)? format;

  /// How typed text is read back.
  ///
  /// Left out, everything but digits, a sign and a decimal point is thrown away
  /// and the rest is parsed — which is what makes `$1,240.00` typeable in a
  /// field that formats as currency.
  final double? Function(String text)? parse;

  /// Where the steppers sit, or [PlNumberFieldSteppers.none] for a field with
  /// none.
  final PlNumberFieldSteppers steppers;

  /// The name of the increment button. Never drawn.
  final String incrementLabel;

  /// The decrement button's.
  final String decrementLabel;

  /// Chords this field answers to, in the vocabulary [PlHotKeys] draws.
  ///
  /// `{'Mod+Enter': save, 'Escape': cancel}` — the same string a [PlHotKeys]
  /// beside the field would print, so the cap and the binding cannot drift. A
  /// chord that matches is **consumed**: the callback runs and the key reaches
  /// neither the control's own key handling nor the route above it.
  final PlassHotKeys? hotKeys;

  /// What the well is cut into.
  final PlassVariant variant;

  /// Height and type scale.
  final PlassSize size;

  /// Semantic colour role. It reaches the edge, the ring, the caret and the
  /// steppers' hover.
  final PlassColor color;

  /// Horizontal padding. Never the height.
  final PlassDensity density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` is the default — a field is a well cut into the sheet, not a key
  /// resting on it.
  final PlassElevation elevation;

  /// Label above the control.
  final Widget? label;

  /// Helper text below it.
  final Widget? description;

  /// Error message below it. Its presence also turns the field invalid.
  final Widget? error;

  /// Forces the invalid state without a message.
  final bool? invalid;

  /// Shown while the field is empty.
  final String? placeholder;

  /// Content before the number — a currency mark, a unit, an icon.
  final Widget? startIcon;

  /// Content after the number, before the steppers.
  final Widget? endIcon;

  /// Stretches to the width of the container.
  final bool fullWidth;

  /// The number is shown but cannot be changed. The steppers go with it.
  final bool readOnly;

  /// Unavailable.
  final bool disabled;

  /// The name a screen reader gives the field.
  final String? semanticLabel;

  /// Drive focus from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  @override
  State<PlNumberField> createState() => _PlNumberFieldState();
}

class _PlNumberFieldState extends State<PlNumberField> {
  late final TextEditingController _controller;
  FocusNode? _owned;
  Timer? _repeat;
  bool _hovered = false;
  bool _focused = false;

  FocusNode get _focusNode => widget.focusNode ?? (_owned ??= FocusNode());

  bool get _editable => !widget.readOnly && !widget.disabled;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _write(widget.value));
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(PlNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _owned)?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
    }

    // A value handed in from outside is written into the box — unless the box is
    // being typed in, where rewriting it would move the caret out from under the
    // finger between two keystrokes.
    if (widget.value != oldWidget.value && !_focused) {
      _controller.text = _write(widget.value);
    }
  }

  @override
  void dispose() {
    _repeat?.cancel();
    _focusNode.removeListener(_onFocusChanged);
    _owned?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focused == _focusNode.hasFocus) {
      return;
    }

    setState(() => _focused = _focusNode.hasFocus);

    // Leaving the field is what settles it: the text is read, clamped and
    // written back, so a box holding `007` or `1e3` or nothing at all comes back
    // saying what the field actually holds.
    if (!_focused) {
      _commit(_read(_controller.text));
    }
  }

  String _write(double? value) {
    if (value == null) {
      return '';
    }

    if (widget.format != null) {
      return widget.format!(value);
    }

    return value == value.roundToDouble() && value.abs() < 1e15
        ? value.toStringAsFixed(0)
        : '$value';
  }

  double? _read(String text) {
    if (widget.parse != null) {
      return widget.parse!(text);
    }

    // Everything a number is written *with* rather than everything it is written
    // *as*: a thousands separator, a currency mark and a unit all come off, and
    // what is left is a number or it is nothing.
    final digits = text.replaceAll(RegExp(r'[^0-9.\-]'), '');

    return digits.isEmpty ? null : double.tryParse(digits);
  }

  /// The value as it is allowed to settle: snapped if asked for, then held
  /// inside the range.
  double _settle(double value) {
    var next = value;

    if (widget.snapOnStep) {
      next = (next / widget.step).roundToDouble() * widget.step;
    }

    if (widget.min != null && next < widget.min!) {
      next = widget.min!;
    }

    if (widget.max != null && next > widget.max!) {
      next = widget.max!;
    }

    // A step of 0.1 from 0.3 is 0.4 and not 0.30000000000000004. Rounded to the
    // tenth of a step, which is finer than any step anybody reads and coarse
    // enough to swallow the binary.
    return double.parse(next.toStringAsFixed(10));
  }

  void _commit(double? raw) {
    final next = raw == null ? null : _settle(raw);
    final text = _write(next);

    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    if (next != widget.value) {
      widget.onChanged?.call(next);
    }

    widget.onCommitted?.call(next);
  }

  void _step(int direction, {_StepAmount amount = _StepAmount.normal}) {
    if (!_editable) {
      return;
    }

    final by = switch (amount) {
      _StepAmount.small => widget.smallStep,
      _StepAmount.normal => widget.step,
      _StepAmount.large => widget.largeStep,
    };

    // An empty field steps from the bottom of the range if it has one, and from
    // zero if it does not: the first press of `+` on a blank quantity box should
    // put something in it.
    final from = _read(_controller.text) ?? widget.min ?? 0;

    _commit(from + by * direction);
  }

  void _edge(bool toEnd) {
    final target = toEnd ? widget.max : widget.min;

    if (target != null) {
      _commit(target);
    }
  }

  void _onTyped(String text) {
    // Reported as typed rather than as settled — see the note on `onChanged`.
    widget.onChanged?.call(_read(text));
  }

  /// Which step the modifiers being held are asking for.
  ///
  /// Read off the keyboard rather than off a key event, because a stepper is
  /// pressed with a finger: <kbd>Shift</kbd> held while clicking `+` should mean
  /// what it means while pressing the up arrow.
  _StepAmount get _heldAmount {
    final keyboard = HardwareKeyboard.instance;

    if (keyboard.isShiftPressed) {
      return _StepAmount.large;
    }

    if (keyboard.isAltPressed) {
      return _StepAmount.small;
    }

    return _StepAmount.normal;
  }

  /// Arms the repeat on a stepper that is being held.
  ///
  /// The step itself belongs to the tap, which is what fires when the press is
  /// released; this only adds the run of them a held button makes. Doing both
  /// from the press would mean every click was worth two steps.
  void _arm(int direction) {
    final amount = _heldAmount;

    _repeat?.cancel();
    _repeat = Timer(_repeatDelay, () {
      _repeat = Timer.periodic(_repeatInterval, (Timer _) => _step(direction, amount: amount));
    });
  }

  void _release() {
    _repeat?.cancel();
    _repeat = null;
  }

  bool _atEdge(int direction) {
    final value = widget.value;

    if (value == null) {
      return false;
    }

    return direction > 0
        ? widget.max != null && value >= widget.max!
        : widget.min != null && value <= widget.min!;
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
    final padX = paddingX[widget.density]![size]!;
    final showSteppers = widget.steppers != PlNumberFieldSteppers.none && !widget.readOnly;
    final split = widget.steppers == PlNumberFieldSteppers.split;

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

    Widget adornment(Widget slot) {
      final ink = _focused ? family.accent : tokens.mutedFg;

      return SizedBox(
        height: scale.line,
        child: Center(
          child: IconTheme.merge(
            data: IconThemeData(color: ink, size: scale.size * iconScale),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: ink),
              child: slot,
            ),
          ),
        ),
      );
    }

    Widget editor = EditableText(
      controller: _controller,
      focusNode: _focusNode,
      readOnly: !_editable,
      autofocus: widget.autofocus,
      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
      onChanged: _onTyped,
      onSubmitted: (String text) => _commit(_read(text)),
      textAlign: split && showSteppers ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        color: tokens.fg,
        fontSize: scale.size,
        height: scale.height,
        leadingDistribution: TextLeadingDistribution.even,
        // Digits that change under a press should not move the ones beside
        // them, which is the whole argument for tabular figures in a field
        // whose value is stepped rather than typed.
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
      cursorColor: family.accent,
      backgroundCursorColor: tokens.mutedFg,
      selectionColor: family.softPress,
      showSelectionHandles: false,
      enableInteractiveSelection: !widget.disabled,
      cursorOpacityAnimates: true,
    );

    if (widget.placeholder != null) {
      editor = Stack(
        children: <Widget>[
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (BuildContext context, TextEditingValue value, Widget? child) {
              return value.text.isEmpty
                  ? IgnorePointer(
                      child: Text(
                        widget.placeholder!,
                        textAlign: split && showSteppers ? TextAlign.center : TextAlign.start,
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

    // Bound *inside* the field rather than around it: a `Shortcuts` closer to
    // the focused editor than the app's own text-editing shortcuts is the one
    // that answers, which is what keeps the up arrow from moving the caret in a
    // box where it is supposed to move the number.
    editor = Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowUp): _StepIntent(1),
        SingleActivator(LogicalKeyboardKey.arrowDown): _StepIntent(-1),
        SingleActivator(LogicalKeyboardKey.arrowUp, shift: true): _StepIntent(
          1,
          amount: _StepAmount.large,
        ),
        SingleActivator(LogicalKeyboardKey.arrowDown, shift: true): _StepIntent(
          -1,
          amount: _StepAmount.large,
        ),
        SingleActivator(LogicalKeyboardKey.arrowUp, alt: true): _StepIntent(
          1,
          amount: _StepAmount.small,
        ),
        SingleActivator(LogicalKeyboardKey.arrowDown, alt: true): _StepIntent(
          -1,
          amount: _StepAmount.small,
        ),
        SingleActivator(LogicalKeyboardKey.pageUp): _StepIntent(1, amount: _StepAmount.large),
        SingleActivator(LogicalKeyboardKey.pageDown): _StepIntent(-1, amount: _StepAmount.large),
        SingleActivator(LogicalKeyboardKey.home): _EdgeIntent(false),
        SingleActivator(LogicalKeyboardKey.end): _EdgeIntent(true),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _StepIntent: CallbackAction<_StepIntent>(
            onInvoke: (_StepIntent intent) {
              _step(intent.direction, amount: intent.amount);

              return null;
            },
          ),
          _EdgeIntent: CallbackAction<_EdgeIntent>(
            onInvoke: (_EdgeIntent intent) {
              _edge(intent.toEnd);

              return null;
            },
          ),
        },
        // Nearer the editor than the steppers' own `Shortcuts` above it, so a
        // caller who binds an arrow takes it from the number rather than
        // sharing it. That is what consuming a chord means.
        child: plassHotKeyScope(hotKeys: widget.hotKeys, child: editor),
      ),
    );

    Widget stepper(int direction) {
      final inert = !_editable || _atEdge(direction);
      final box = scale.size * _stepperScale;

      return PlassInteractive(
        onTap: inert ? null : () => _step(direction, amount: _heldAmount),
        enabled: !inert,
        interactive: !inert,
        cursor: inert ? SystemMouseCursors.basic : SystemMouseCursors.click,
        builder: (BuildContext context, PlassInteraction state) {
          final ink = inert
              ? tokens.mutedFg
              : state.hovered || state.pressed
              ? family.accent
              : tokens.mutedFg;

          Widget button = DecoratedBox(
            decoration: BoxDecoration(
              color: inert
                  ? null
                  : state.pressed
                  ? family.softPress
                  : state.hovered
                  ? family.soft
                  : null,
              borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.xs]!),
            ),
            child: SizedBox.square(
              dimension: box,
              child: Center(
                child: PlassGlyph(
                  direction > 0 ? PlassGlyphShape.plus : PlassGlyphShape.minus,
                  size: scale.size * _stepperGlyphScale,
                  color: ink,
                ),
              ),
            ),
          );

          if (state.focusVisible) {
            button = CustomPaint(
              foregroundPainter: PlassFocusRingPainter(
                color: family.ring,
                borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.xs]!),
                offset: -focusRingWidth,
              ),
              child: button,
            );
          }

          // A held stepper repeats, which is the difference between a spinner
          // and two buttons: nobody presses `+` forty times.
          return Listener(
            onPointerDown: inert ? null : (PointerDownEvent _) => _arm(direction),
            onPointerUp: (PointerUpEvent _) => _release(),
            onPointerCancel: (PointerCancelEvent _) => _release(),
            child: Semantics(
              container: true,
              button: true,
              enabled: !inert,
              label: direction > 0 ? widget.incrementLabel : widget.decrementLabel,
              child: Opacity(opacity: inert ? disabledOpacity : 1, child: button),
            ),
          );
        },
      );
    }

    Widget shell = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      spacing: gap[size]!,
      children: <Widget>[
        if (showSteppers && split) stepper(-1),
        if (widget.startIcon != null) adornment(widget.startIcon!),
        Expanded(child: editor),
        if (widget.endIcon != null) adornment(widget.endIcon!),
        if (showSteppers && !split)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: _stepperGap,
            children: <Widget>[stepper(-1), stepper(1)],
          ),
        if (showSteppers && split) stepper(1),
      ],
    );

    // The steppers bring their own padding, so the shell keeps its own only on
    // the side that has no button: stacking the two would leave a button
    // floating in the middle of a gap.
    shell = Padding(
      padding: showSteppers
          ? EdgeInsetsDirectional.only(start: split ? _stepperGap : padX, end: _stepperGap)
          : EdgeInsets.symmetric(horizontal: padX),
      child: shell,
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
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: widget.disabled ? null : _focusNode.requestFocus,
        child: shell,
      ),
    );

    if (widget.allowWheelScrub) {
      shell = Listener(
        onPointerSignal: (PointerSignalEvent event) {
          // Focused *and* hovered, both: a wheel over a field nobody is typing
          // in belongs to the page under it.
          if (event is! PointerScrollEvent || !_focused || !_editable) {
            return;
          }

          _step(event.scrollDelta.dy > 0 ? -1 : 1);
        },
        child: shell,
      );
    }

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
        shell,
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
      explicitChildNodes: true,
      textField: true,
      readOnly: widget.readOnly,
      enabled: !widget.disabled,
      label: widget.semanticLabel,
      value: _controller.text.isEmpty ? null : _controller.text,
      child: widget.fullWidth ? stack : IntrinsicWidth(child: stack),
    );
  }
}
