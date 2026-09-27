/// A field that only holds a number.
library;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/adornment.dart';
import 'package:plass_ui/src/internal/editor.dart';
import 'package:plass_ui/src/internal/fieldset.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/ink.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/keys.dart';
import 'package:plass_ui/src/internal/notch.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
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

/// How far short of a multiple, as a share of the step, a stepped value may
/// land and still count as on it with [PlNumberField.snapOnStep]: `0.7 + 0.1`
/// is a hair under `0.8`, and without the allowance a step up from `0.7` would
/// snap back to it. The factor Base UI's `snapToStep` uses.
const double _snapTolerance = 1e-10;

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

/// When a value the field writes is reported through
/// [PlNumberField.onCommitted].
enum _CommitWhen {
  /// Every time, changed or not: leaving the field, <kbd>Enter</kbd>, and the
  /// release of a press on a stepper.
  always,

  /// Only when the value changed: a key step, <kbd>Home</kbd>, <kbd>End</kbd>,
  /// the wheel, and a screen reader's press on a stepper. One that leaves the
  /// value where it was settles nothing.
  changed,

  /// Never: a repeat of a held stepper, which settles on its release.
  never,
}

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
    this.incrementLabel,
    this.decrementLabel,
    this.hotKeys,
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    this.label,
    this.labelPlacement,
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
  /// press, and alongside [onChanged] for the keyboard and the wheel, so a key
  /// or a turn of the wheel that leaves the value where it was calls neither.
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

  /// Whether a step lands on a multiple of how far it goes, counted from [min],
  /// or from zero without one, rather than that far from where the value was.
  ///
  /// A step goes to the next multiple in its direction, so with a [step] of 5
  /// the up arrow takes 8 to 10 and the down arrow takes it to 5. A [smallStep]
  /// goes to the nearest one. A number typed into the box is left as it is.
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
  final String? incrementLabel;

  /// The decrement button's.
  final String? decrementLabel;

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
  final PlassSize? size;

  /// Semantic colour role. It reaches the edge, the ring, the caret and the
  /// steppers' hover.
  final PlassColor? color;

  /// Horizontal padding. Never the height.
  final PlassDensity? density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` is the default — a field is a well cut into the sheet, not a key
  /// resting on it.
  final PlassElevation elevation;

  /// The name of what the field holds.
  final Widget? label;

  /// Where the [label] goes — above the control, or in its top edge.
  ///
  /// Falls back to the nearest [PlassTheme], then to [PlassFieldLabelPlacement.top].
  final PlassFieldLabelPlacement? labelPlacement;

  /// Helper text below it.
  final Widget? description;

  /// Error message below it. Its presence also turns the field invalid.
  final Widget? error;

  /// Forces the invalid state without a message.
  final bool? invalid;

  /// Shown while the field is empty.
  ///
  /// On a field with neither a [label] nor a [semanticLabel], it is also the
  /// name a screen reader gives the field, holding a number or not.
  final String? placeholder;

  /// Content before the number — a currency mark, a unit, an icon. What it
  /// says to a screen reader is on a node of its own, not part of the field's
  /// name.
  final Widget? startIcon;

  /// Content after the number, before the steppers. Read on a node of its own,
  /// as [startIcon] is.
  final Widget? endIcon;

  /// Stretches to the width of the container.
  final bool fullWidth;

  /// The number is shown but cannot be changed. The steppers go with it.
  final bool readOnly;

  /// Unavailable.
  final bool disabled;

  /// The name a screen reader gives the field.
  ///
  /// Given beside a visible [label], it is the name in the label's place, and
  /// the label's words are not read after it.
  final String? semanticLabel;

  /// Drive focus from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  @override
  State<PlNumberField> createState() => _PlNumberFieldState();
}

class _PlNumberFieldState extends State<PlNumberField> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;
  PlassFieldLabelPlacement get _labelPlacement =>
      widget.labelPlacement ?? PlassTheme.labelPlacementOf(context) ?? PlassFieldLabelPlacement.top;

  late final TextEditingController _controller;
  FocusNode? _owned;
  Timer? _repeat;

  /// Whether the stepper being held has repeated, which makes its release the
  /// moment the value settles rather than one more step.
  bool _repeated = false;

  /// Whether a change has been reported that has not settled since: text typed
  /// into the box, or the repeats of a held stepper before its release.
  ///
  /// Leaving the field reports a settle only while this holds, or when the box
  /// settles to a number other than [_held]. Otherwise there is nothing left to
  /// settle, and a Tab through the field, or a press that takes the focus out of
  /// it and brings it back, would report the value it already had.
  bool _unsettled = false;

  /// Whether the box holds text typed into it since the field last wrote it.
  ///
  /// A value handed in while the field is focused is written into the box
  /// unless this holds. Typed text is kept until the field is left, where it
  /// settles: a value written over it would move the caret out from under the
  /// finger between two keystrokes. Any other value is shown at once, so the
  /// next blur does not write back the number the box held before.
  bool _typed = false;

  /// The value as far as the field knows it: the last one handed in, or the
  /// last one it reported, whichever came later, until the frame after a report
  /// brings the parent's answer and this holds that.
  ///
  /// Not [PlNumberField.value], which does not hold a report until the parent
  /// has built again. A blur can come first: Enter settles the box and takes
  /// the focus out in the same turn, and measured against the value before it,
  /// the box would read as a number still to settle. So can a second key,
  /// which a commit measures against this to tell whether it changed anything.
  double? _held;
  bool _hovered = false;
  bool _pressed = false;

  /// Where the pointer is over the shell, which is what the interaction light
  /// is centred on. Written on every pointer frame; the light sits inside a
  /// `RepaintBoundary` in `PlassSurfaceBox`, so the repaint stays off the text.
  Offset? _pointer;

  /// Whether the light is standing down while the field is being typed into.
  /// See `PlTextField`, which explains the whole of it.
  bool _quiet = false;

  /// Puts the light out, only while the field has the focus: autofill can
  /// write into a field that does not have it, and that is not a reader typing.
  ///
  /// Called for the text typed and for the keys that step or settle the value,
  /// and never for the field's own writes into the box: a step taken with a
  /// press or the wheel is the pointer at work, and the value put back once the
  /// caller has answered is not the reader's at all.
  void _quieten() {
    if (_editable && _focused && !_quiet) {
      setState(() => _quiet = true);
    }
  }

  /// The caret or the selection has moved. Only a move made from the keyboard
  /// is the reader typing: the caret the editor puts in as the focus arrives,
  /// and one a press puts somewhere, leave the light where it was, as the React
  /// field is quieted by a key press alone.
  void _onSelectionChanged(TextSelection selection, SelectionChangedCause? cause) {
    if (cause == SelectionChangedCause.keyboard) {
      _quieten();
    }
  }

  void _setPointer(Offset position) {
    if (!_editable || (_pointer == position && !_quiet)) {
      return;
    }

    setState(() {
      _pointer = position;
      // A pointer that is moving again is a hand that has come back to it.
      _quiet = false;
    });
  }

  void _releasePress() {
    if (_pressed) {
      setState(() => _pressed = false);
    }
  }

  bool _focused = false;

  FocusNode get _focusNode => widget.focusNode ?? (_owned ??= FocusNode());

  /// The editor, which a screen reader's tap and focus are handed to.
  final GlobalKey<EditableTextState> _editor = GlobalKey<EditableTextState>();

  /// [PlNumberField.disabled], or a disabled [PlFieldset] around it.
  bool get _disabled => widget.disabled || PlassFieldsetScope.disabledOf(context);

  bool get _editable => !widget.readOnly && !_disabled;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _write(widget.value));
    _held = widget.value;
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(PlNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _owned)?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
    }

    if (widget.value != oldWidget.value) {
      _held = widget.value;
    }

    // A value handed in from outside is written into the box, focused or not,
    // unless the box holds text being typed: rewriting it would move the caret
    // out from under the finger between two keystrokes. The typed text settles
    // when the field is left.
    if (widget.value != oldWidget.value && !(_focused && _typed)) {
      _show(widget.value);
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
    // saying what the field actually holds. It is reported only if something was
    // left to settle. A read-only or disabled field is left as it is: nothing
    // can be typed into it, and a value handed to it outside the range is the
    // caller's to keep.
    if (!_focused && _editable) {
      final double? raw = _read(_controller.text);
      final double? next = raw == null ? null : _settle(raw);

      if (_unsettled || next != _held) {
        _commit(raw);
      } else {
        _show(next);
      }
    }
  }

  /// Writes [value] into the box as a settled value is written, with the caret
  /// at the end. Whatever was typed there is replaced.
  void _show(double? value) {
    final String text = _write(value);

    _typed = false;

    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
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

  /// The value as it is allowed to settle: held inside the range.
  double _settle(double value) {
    var next = value;

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

  /// Settles [raw] into the box, reports it through `onChanged` if the value
  /// changed, and through `onCommitted` as [when] says.
  ///
  /// A commit that changes nothing still writes the box in its settled form.
  /// If it goes unreported, a number typed before it still settles when the
  /// focus leaves, as in Base UI.
  void _commit(double? raw, {_CommitWhen when = _CommitWhen.always}) {
    final next = raw == null ? null : _settle(raw);
    // Measured against [_held] rather than the parent's value, which a second
    // key in the same frame would find still holding the value before the
    // first: up and down from 5 would come back to a 5 that reads as no change,
    // and leave the parent holding 6.
    final changed = next != _held;

    _show(next);

    if (changed) {
      _held = next;
      _unsettled = true;
      widget.onChanged?.call(next);
    }

    if (when == _CommitWhen.always || (when == _CommitWhen.changed && changed)) {
      _unsettled = false;
      widget.onCommitted?.call(next);
    }

    // The value is the parent's to take or turn down. Once it has rebuilt with
    // its answer, a box still showing a number the parent did not take goes
    // back to the one it holds, or the two would say different things until
    // something else changed.
    _takeAnswer(show: true);
  }

  /// After the frame that builds the parent's answer to a report, holds the
  /// value the parent holds, and with [show] writes it into the box.
  ///
  /// So a report the parent turned down is not the value the next one is
  /// measured against: that one is reported, and the parent can take it.
  void _takeAnswer({required bool show}) {
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) {
        return;
      }

      _held = widget.value;

      if (show) {
        _show(widget.value);
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _step(
    int direction, {
    _StepAmount amount = _StepAmount.normal,
    _CommitWhen when = _CommitWhen.always,
  }) {
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
    var next = from + by * direction;

    // Snapped before the range is applied, as Base UI snaps, so a `max` that is
    // not a multiple can still be reached.
    if (widget.snapOnStep && by != 0) {
      next = _snap(next, by * direction, nearest: amount == _StepAmount.small);
    }

    _commit(next, when: when);
  }

  /// Where a step of [by], signed with its direction, that took the value to
  /// [value] settles with [PlNumberField.snapOnStep]: on the last multiple of
  /// the step, counted from [PlNumberField.min] or from zero, that it reached
  /// on the way, or with [nearest] on the nearest one, as Base UI's
  /// `snapToStep` puts it.
  double _snap(double value, double by, {required bool nearest}) {
    final double base = widget.min ?? 0;
    final double size = by.abs();
    // Leaned in the step's direction, so a value a hair short of a multiple is
    // on it, and a small step half-way between two goes on to the next.
    final double offset = value - base + by * _snapTolerance;

    if (nearest) {
      return base + _roundHalfUp(offset / by) * by;
    }

    final double count = offset / size;

    return base + (by > 0 ? count.floorToDouble() : count.ceilToDouble()) * size;
  }

  /// `Math.round`, which takes a half towards positive infinity where Dart's
  /// `roundToDouble` takes it away from zero.
  static double _roundHalfUp(double value) {
    final double floor = value.floorToDouble();

    return value - floor >= 0.5 ? floor + 1 : floor;
  }

  /// <kbd>Home</kbd> or <kbd>End</kbd>: a field that can be edited goes to that
  /// end of the range, if the range has one.
  void _edge(bool toEnd) {
    final target = toEnd ? widget.max : widget.min;

    if (target != null && _editable) {
      _commit(target, when: _CommitWhen.changed);
    }
  }

  void _onTyped(String text) {
    _quieten();

    // Reported as typed rather than as settled — see the note on `onChanged`.
    final double? typed = _read(text);

    _held = typed;
    _unsettled = true;
    _typed = true;
    widget.onChanged?.call(typed);

    // The box keeps what was typed until the field is left, whatever the
    // parent answers, but a number it turned down is offered again there.
    _takeAnswer(show: false);
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
    _repeated = false;
    _repeat = Timer(_repeatDelay, () {
      _repeat = Timer.periodic(_repeatInterval, (Timer timer) {
        _repeated = true;
        _step(direction, amount: amount, when: _CommitWhen.never);

        // Nothing more to add once the range has run out.
        final double? now = _read(_controller.text);

        if (now != null &&
            (direction > 0
                ? widget.max != null && now >= widget.max!
                : widget.min != null && now <= widget.min!)) {
          timer.cancel();
        }
      });
    });
  }

  /// A press coming down on a stepper that can step.
  ///
  /// A mouse press brings the focus into the field, as the React stepper's
  /// does, so the arrow keys carry on from the value the press leaves. A finger
  /// or a pen does not: the focus would bring a keyboard up over a field that
  /// was only being nudged.
  void _pressStepper(PointerDownEvent event, int direction) {
    final touchLike = switch (event.kind) {
      PointerDeviceKind.touch ||
      PointerDeviceKind.stylus ||
      PointerDeviceKind.invertedStylus => true,
      _ => false,
    };

    if (!touchLike && !_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }

    _arm(direction);
  }

  /// Ends a hold. A hold that repeated settles here, once, and its release is
  /// not a step of its own.
  void _release() {
    _repeat?.cancel();
    _repeat = null;

    if (_repeated) {
      _unsettled = false;
      widget.onCommitted?.call(_read(_controller.text));

      // Kept for the press that ends the hold, which arrives in the same
      // pointer event, and dropped after it. A hold that ended where the
      // stepper can no longer be pressed has no press to swallow, and the next
      // one, from the keyboard, is a step.
      scheduleMicrotask(() => _repeated = false);
    }
  }

  /// The press of a stepper, which is a step unless it ended a hold that
  /// already repeated.
  void _tapStepper(int direction) {
    if (_repeated) {
      _repeated = false;

      return;
    }

    _step(direction, amount: _heldAmount);
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
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final hasError = widget.error != null;
    final isInvalid = widget.invalid ?? hasError;
    final family = tokens.family(isInvalid ? PlassColor.danger : _color);

    final size = _size;
    final scale = controlTextLeading[size]!;
    final meta = metaText[size]!;
    final radius = BorderRadius.circular(tokens.radii[size]!);
    final padX = paddingX[_density]![size]!;
    final showSteppers = widget.steppers != PlNumberFieldSteppers.none && !widget.readOnly;
    final split = widget.steppers == PlNumberFieldSteppers.split;
    // A notch with nothing in it is a gap in the edge for no reason, so the
    // placement only takes effect where there is a label to put there.
    final notched = _labelPlacement == PlassFieldLabelPlacement.notch && widget.label != null;

    final surface = fieldSurface(
      tokens,
      family,
      variant: widget.variant,
      elevation: widget.elevation,
      hovered: _hovered,
      focused: _focused,
      readOnly: widget.readOnly,
      disabled: _disabled,
    );

    // One widget for both placements, so the label a reader taps and the label
    // a screen reader reads are the same widget wherever it is drawn. A
    // `semanticLabel` is the name in its place, so the drawn words are then not
    // read after it.
    final Widget? labelNode = widget.label == null
        ? null
        : ExcludeSemantics(
            excluding: widget.semanticLabel != null,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: _disabled ? tokens.mutedFg : tokens.fg,
                fontSize: meta,
                fontWeight: FontWeight.w600,
              ),
              child: widget.label!,
            ),
          );

    Widget editor = EditableText(
      key: _editor,
      controller: _controller,
      focusNode: _focusNode,
      // The caller's alone, so a disabled field is still announced as a text
      // field, as the React `<input disabled>` is. It takes no text because it
      // cannot take the focus, and the two ways in that need none are shut
      // below.
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
      onChanged: _onTyped,
      onSelectionChanged: _onSelectionChanged,
      // Enter is a key press, which puts the light out whether or not the value
      // it settles changes the box.
      onSubmitted: (String text) {
        _quieten();
        _commit(_read(text));
      },
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
      enableInteractiveSelection: !_disabled,
      // A pen on an iPad and autofill both write into a field without its
      // focus.
      stylusHandwritingEnabled: !_disabled,
      autofillHints: _disabled ? null : const <String>[],
      cursorOpacityAnimates: true,
    );

    // A disabled field leaves the focus order, as a disabled button does, so Tab
    // passes it and no ring is drawn on it. The `ExcludeFocus` is in the tree
    // either way, so turning `disabled` off does not build the editor again.
    editor = ExcludeFocus(excluding: _disabled, child: editor);

    // Kept off the semantics tree: where the placeholder names the field, it
    // does so as the field's own label, which stays once a number is in the box
    // and the drawing is gone.
    if (widget.placeholder != null) {
      editor = Stack(
        children: <Widget>[
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (BuildContext context, TextEditingValue value, Widget? child) {
              return value.text.isEmpty
                  ? IgnorePointer(
                      child: ExcludeSemantics(
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
          // A key press, which puts the light out as typing does, where a
          // stepper or the wheel stepping the same value leaves it lit.
          _StepIntent: CallbackAction<_StepIntent>(
            onInvoke: (_StepIntent intent) {
              _quieten();
              _step(intent.direction, amount: intent.amount, when: _CommitWhen.changed);

              return null;
            },
          ),
          _EdgeIntent: CallbackAction<_EdgeIntent>(
            onInvoke: (_EdgeIntent intent) {
              _quieten();
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
      // Faded of its own only at its limit in a field that is not disabled: a
      // disabled field is already drawn at half by the state filter round it,
      // and a second fade would draw the stepper at a quarter.
      final faded = !_disabled && _atEdge(direction);
      final box = scale.size * _stepperScale;

      final Widget control = PlassInteractive(
        onTap: inert ? null : () => _tapStepper(direction),
        enabled: !inert,
        interactive: !inert,
        cursor: inert ? SystemMouseCursors.basic : SystemMouseCursors.click,
        builder: (BuildContext context, PlassInteraction state) {
          final ink = inert
              ? tokens.mutedFg
              : state.hovered || state.pressed
              ? family.accent
              : tokens.mutedFg;

          // Eased with the ink, as the React stepper's `background-color` is.
          Widget button = AnimatedContainer(
            duration: reduceMotion ? Duration.zero : tokens.motionDuration,
            curve: tokens.motionEase,
            decoration: BoxDecoration(
              color: inert
                  ? null
                  : state.pressed
                  ? family.softPress
                  : state.hovered
                  ? family.soft
                  : null,
              borderRadius: BorderRadius.circular(tokens.radii[PlassSize.xs]!),
            ),
            child: SizedBox.square(
              dimension: box,
              child: Center(
                // Eased under the pointer, as the React stepper's `color` is.
                child: PlassInk(
                  color: ink,
                  child: PlassGlyph(
                    direction > 0 ? PlassGlyphShape.plus : PlassGlyphShape.minus,
                    size: scale.size * _stepperGlyphScale,
                  ),
                ),
              ),
            ),
          );

          button = CustomPaint(
            foregroundPainter: state.focusVisible
                ? PlassFocusRingPainter(
                    color: family.ring,
                    borderRadius: BorderRadius.circular(tokens.radii[PlassSize.xs]!),
                    offset: -focusRingWidth,
                  )
                : null,
            child: button,
          );

          // A held stepper repeats, which is the difference between a spinner
          // and two buttons: nobody presses `+` forty times.
          return Listener(
            onPointerDown: inert
                ? null
                : (PointerDownEvent event) => _pressStepper(event, direction),
            onPointerUp: (PointerUpEvent _) => _release(),
            onPointerCancel: (PointerCancelEvent _) => _release(),
            child: Semantics(
              container: true,
              button: true,
              enabled: !inert,
              label: direction > 0
                  ? widget.incrementLabel ?? PlassTheme.labelsOf(context).increase
                  : widget.decrementLabel ?? PlassTheme.labelsOf(context).decrease,
              // `PlassInteractive` keeps its tap off the semantics tree, so the
              // press a screen reader makes is given here. It is one step, the
              // click a Base UI stepper answers with no pointer behind it: no
              // repeat, no focus, and settled only if it moved the value.
              onTap: inert
                  ? null
                  : () => _step(direction, amount: _heldAmount, when: _CommitWhen.changed),
              // Painted straight onto the canvas while it is not faded, rather
              // than through an `Opacity` at 1, which is a layer all the same:
              // one on each stepper of every field on the screen, for nothing.
              child: PlassFiltered(
                colorFilter: null,
                opacity: faded ? disabledOpacity : 1,
                child: button,
              ),
            ),
          );
        },
      );

      // Counted as the editor's own, so a mouse press on a stepper, and a touch
      // in a browser, does not take the focus out of the field before the press
      // is a step: that settled the old value on the way out, and left the
      // arrow keys with nothing to step until the field was focused again. A
      // stepper at its limit counts too, and a press on it leaves the focus
      // where it was.
      return TextFieldTapRegion(child: control);
    }

    Widget shell = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      spacing: gap[size]!,
      children: <Widget>[
        if (showSteppers && split) stepper(-1),
        if (widget.startIcon != null)
          PlassFieldAdornment(size: size, apart: true, child: widget.startIcon!),
        // Keyed, because a read-only field puts its steppers away, and with
        // `split` one of them is in front of the editor. Found by its place
        // alone, the editor would be built again from scratch.
        Expanded(key: const ValueKey<String>('editor'), child: editor),
        if (widget.endIcon != null)
          PlassFieldAdornment(size: size, apart: true, child: widget.endIcon!),
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
      child: PlassSurfaceBox(
        // A notched field hands its edge over: the line round it has a gap in
        // it, and a gap is not something a border can have.
        surface: notched ? surface.withoutBorder() : surface,
        borderRadius: radius,
        // The interaction light. A field answering a pointer is as true a
        // claim as a key answering one, and it is not a claim a locked field
        // makes.
        pointer: _pointer,
        glow: _editable ? tokens.fieldGlow(family) : null,
        glowVisible: _hovered && !_quiet,
        flash: _editable ? tokens.fieldFlash(family) : null,
        flashVisible: _pressed,
        reduceMotion: reduceMotion,
        child: shell,
      ),
    );

    shell = plassStateFilter(
      child: shell,
      disabled: _disabled,
      readOnly: widget.readOnly,
      lit: false,
    );

    if (notched) {
      // No ring here: an outline is a rectangle and the label is sitting on the
      // edge it would be drawn along, so the edge itself thickens instead.
      shell = PlassFieldNotch(
        size: size,
        density: _density,
        disabled: _disabled,
        edge: notchEdgePainter(
          tokens,
          family,
          variant: widget.variant,
          borderRadius: radius,
          hovered: _hovered,
          focused: _focused,
          readOnly: widget.readOnly,
          disabled: _disabled,
        ),
        label: labelNode!,
        child: shell,
      );
    } else {
      // Kept in the tree with no painter while unfocused, so the focus arriving
      // does not build the editor again without its text input connection.
      shell = CustomPaint(
        foregroundPainter: _focused
            ? PlassFocusRingPainter(color: family.ring, borderRadius: radius)
            : null,
        child: shell,
      );
    }

    shell = MouseRegion(
      cursor: _disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.text,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      onHover: (PointerHoverEvent event) => _setPointer(event.localPosition),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: _disabled ? null : _focusNode.requestFocus,
        // The press half of the light. On a touch screen there is no hover at
        // all, and this is the layer that carries the effect there.
        onTapDown: (TapDownDetails details) {
          _setPointer(details.localPosition);
          if (_editable) {
            setState(() => _pressed = true);
          }
        },
        onTapUp: (TapUpDetails details) => _releasePress(),
        onTapCancel: _releasePress,
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

          // Only a wheel turned up or down means more or less. A sideways one
          // is left to whatever scrolls sideways.
          final double dy = event.scrollDelta.dy;

          if (dy == 0) {
            return;
          }

          // Claimed through the resolver, so the page under the field does not
          // scroll on the same turn and carry the field away from the pointer.
          GestureBinding.instance.pointerSignalResolver.register(event, (PointerSignalEvent _) {
            _step(dy > 0 ? -1 : 1, when: _CommitWhen.changed);
          });
        },
        child: shell,
      );
    }

    final stack = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: stackGap[size]!,
      children: <Widget>[
        if (labelNode != null && !notched) labelNode,
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

    // Descendants are left to merge into this node, so the label's text becomes
    // the field's name, and the editor's own node, which says it is a text
    // field, whether it is read-only, what the box shows and what can be done
    // to it, merges in as well. Saying `textField`, `readOnly` or the text as a
    // `value` here too would clash with the editor's, and split the field into
    // a named node that never takes the focus over an unnamed one that holds
    // the text. The two steppers keep nodes of their own.
    return Semantics(
      container: true,
      enabled: !_disabled,
      // Named by the placeholder only where nothing else names it, as the React
      // input is: a `semanticLabel` is its `aria-label`, and a visible label,
      // merged in below, is its `<label>`.
      label: widget.semanticLabel ?? (widget.label == null ? widget.placeholder : null),
      // A screen reader's tap and focus, which the editor answers neither of on
      // its own. As on a Material `TextField`, a read-only field takes the focus
      // and no tap, and a disabled one takes neither.
      onTap: _editable ? () => plassTapEditor(_editor) : null,
      onFocus: _disabled ? null : () => plassFocusEditor(_editor),
      child: widget.fullWidth ? stack : IntrinsicWidth(child: stack),
    );
  }
}
