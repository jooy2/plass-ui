/// A field somebody types into.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/keys.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// The vertical padding a multiline field takes, per size.
///
/// `(height − line-height) / 2`, which makes a one-row field exactly as tall as
/// the single-line field of the same size. Keyed by size and never by density:
/// density is horizontal padding only, and letting it touch this would make the
/// same `rows` produce two different heights.
const Map<PlassSize, double> _multilinePaddingY = <PlassSize, double>{
  PlassSize.xs: 4,
  PlassSize.sm: 7,
  PlassSize.md: 10,
  PlassSize.lg: 12,
  PlassSize.xl: 14,
};

/// A field somebody types into.
///
/// ```dart
/// PlTextField(
///   controller: email,
///   label: const Text('Email'),
///   description: const Text('We only use it to sign you in.'),
/// )
/// ```
///
/// A field is a **well cut into the sheet** rather than a key resting on it, and
/// the one place in the library where a shadow points inward. `solid` is that
/// well: a gradient under a caret, a text selection and a placeholder is not
/// legible, so the family shows up in the hairline, the ring and the caret
/// instead.
///
/// [label], [description] and [error] are parameters rather than three widgets a
/// caller wires together: the arrangement is fixed, and what a caller wants to
/// decide is what goes in each slot. There is no floating label on purpose — a
/// floating label moves under the caret, which is the one effect this library
/// rules out on a control.
class PlTextField extends StatefulWidget {
  /// Creates a field.
  const PlTextField({
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hotKeys,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.elevation = 0,
    this.multiline = false,
    this.rows = 3,
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.placeholder,
    this.startIcon,
    this.endIcon,
    this.loading = false,
    this.fullWidth = false,
    this.readOnly = false,
    this.disabled = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLength,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The text being edited. Left out, the field owns one of its own.
  final TextEditingController? controller;

  /// Called on every change.
  final ValueChanged<String>? onChanged;

  /// Called when the field is submitted from the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// Chords this field answers to, in the vocabulary [PlHotKeys] draws.
  ///
  /// `{'Mod+Enter': save, 'Escape': cancel}` — the same string a [PlHotKeys]
  /// beside the field would print, so the cap and the binding cannot drift. A
  /// chord that matches is **consumed**: the callback runs and the key reaches
  /// neither the control's own key handling nor the route above it.
  final PlassHotKeys? hotKeys;

  /// What the shell is made of. See [PlassVariant].
  final PlassVariant variant;

  /// Height and type scale together, the same ladder a button walks — so a field
  /// and the button beside it in a row sit on one baseline.
  final PlassSize size;

  /// Semantic colour role. It reaches the hairline, the ring and the caret; the
  /// glass is never dyed.
  final PlassColor color;

  /// Changes horizontal padding and nothing else.
  final PlassDensity density;

  /// Drop shadow depth, `0`–`3`. `0` is the default — a field is a well.
  final PlassElevation elevation;

  /// Lets the field grow to more than one line.
  ///
  /// Everything else — sizing, density, variants, states — stays identical, so
  /// switching a field to multiline never changes how it sits in a form.
  final bool multiline;

  /// How many rows a multiline field shows. One row is exactly the single-line
  /// height.
  final int rows;

  /// Label above the control.
  final Widget? label;

  /// Helper text below it.
  final Widget? description;

  /// Error message below it. Its presence also turns the field invalid.
  final Widget? error;

  /// Forces the invalid state without a message.
  final bool? invalid;

  /// What is shown while the field is empty.
  final String? placeholder;

  /// Content before the control. Sized against the text rather than the row.
  final Widget? startIcon;

  /// Content after the control.
  final Widget? endIcon;

  /// Shows a spinner in place of [endIcon].
  ///
  /// Typing is deliberately still allowed — a field is usually loading *because
  /// of* what was typed into it.
  final bool loading;

  /// Stretches to the width of the container.
  final bool fullWidth;

  /// Inert but not dimmed: the value is still there to be read and copied, which
  /// is the whole difference from [disabled].
  final bool readOnly;

  /// Unavailable. The light goes out.
  final bool disabled;

  /// Hides what is typed, for a password.
  final bool obscureText;

  /// Which keyboard to raise on a touch device.
  final TextInputType? keyboardType;

  /// What the keyboard's action key does.
  final TextInputAction? textInputAction;

  /// Rules applied to what is typed, before it reaches the value.
  final List<TextInputFormatter>? inputFormatters;

  /// How many characters the field will take.
  final int? maxLength;

  /// The name a screen reader announces, for a field with no visible [label].
  final String? semanticLabel;

  /// Drive focus from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  @override
  State<PlTextField> createState() => _PlTextFieldState();
}

class _PlTextFieldState extends State<PlTextField> {
  FocusNode? _owned;
  TextEditingController? _fallback;
  bool _hovered = false;
  bool _focused = false;

  FocusNode get _focusNode => widget.focusNode ?? (_owned ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(PlTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _owned)?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _owned?.dispose();
    _fallback?.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final hasError = widget.error != null;
    final isInvalid = widget.invalid ?? hasError;
    // Invalid re-points the whole family at `danger`, so the edge, the ring, the
    // caret and the message all turn over together and no state needs its own
    // set of tokens.
    final family = tokens.family(isInvalid ? PlassColor.danger : widget.color);

    final size = widget.size;
    final scale = controlTextLeading[size]!;
    final meta = metaText[size]!;
    final radius = BorderRadius.circular(PlassTokens.radius[size]!);

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

    // A box the height of one line keeps an adornment centred on the first line
    // rather than on the whole box, which is the only way it stays put when the
    // control grows to five rows.
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

    Widget control = EditableText(
      controller: widget.controller ?? (_fallback ??= TextEditingController()),
      focusNode: _focusNode,
      readOnly: widget.readOnly || widget.disabled,
      autofocus: widget.autofocus,
      obscureText: widget.obscureText,
      keyboardType:
          widget.keyboardType ?? (widget.multiline ? TextInputType.multiline : TextInputType.text),
      textInputAction: widget.textInputAction,
      inputFormatters: <TextInputFormatter>[
        if (widget.maxLength != null) LengthLimitingTextInputFormatter(widget.maxLength),
        ...?widget.inputFormatters,
      ],
      maxLines: widget.multiline ? widget.rows : 1,
      minLines: widget.multiline ? widget.rows : 1,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
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
      // `EditableText` rather than a `TextField`: the latter is Material, and
      // this package imports neither Material nor Cupertino. What Material adds
      // on top — the decoration, the counter, the ripple — is what this
      // component is *instead of*.
      //
      // Which costs one thing worth naming: the drag handles a touch platform
      // puts under a selection are Material's and Cupertino's, so a selection
      // here is made by dragging and has no handles to adjust afterwards.
      showSelectionHandles: false,
      enableInteractiveSelection: !widget.disabled,
      cursorOpacityAnimates: true,
    );

    // The placeholder is drawn under the text rather than by the editor, which
    // has no notion of one.
    if (widget.placeholder != null) {
      control = Stack(
        children: <Widget>[
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller ?? _fallback!,
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
                        maxLines: widget.multiline ? widget.rows : 1,
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          control,
        ],
      );
    }

    control = plassHotKeyScope(hotKeys: widget.hotKeys, child: control);

    Widget shell = Row(
      crossAxisAlignment: widget.multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      spacing: gap[size]!,
      children: <Widget>[
        if (widget.startIcon != null) adornment(widget.startIcon!),
        Expanded(child: control),
        if (widget.loading)
          adornment(PlassSpinner(size: scale.size * iconScale, color: tokens.mutedFg))
        else if (widget.endIcon != null)
          adornment(widget.endIcon!),
      ],
    );

    shell = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: paddingX[widget.density]![size]!,
        vertical: widget.multiline ? _multilinePaddingY[size]! : 0,
      ),
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
      // The ring belongs to the shell rather than to the editor inside it, so it
      // traces the glass edge rather than a rectangle floating inside it.
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
        // Pressing the shell's own padding puts the caret in the field, the way
        // pressing anywhere inside a native input does.
        onTap: widget.disabled ? null : _focusNode.requestFocus,
        child: shell,
      ),
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
      textField: true,
      readOnly: widget.readOnly,
      enabled: !widget.disabled,
      label: widget.semanticLabel,
      child: widget.fullWidth ? stack : IntrinsicWidth(child: stack),
    );
  }
}
