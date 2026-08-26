/// A row of one-character slots: a PIN, a texted verification code.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// What may be typed into a slot.
///
/// [PlOtpCharset.numeric] is the default because that is what a texted code is,
/// and it is also what puts a number pad in front of a phone.
/// [PlOtpCharset.any] accepts whatever the keyboard produces — for a licence
/// key with punctuation in it.
enum PlOtpCharset {
  /// Digits only.
  numeric,

  /// Letters only. Case is left alone.
  alpha,

  /// Letters and digits.
  alphanumeric,

  /// Anything the keyboard produces.
  any,
}

/// How many slots a code may have. Two is the shortest thing worth splitting.
const int _minLength = 2;

/// And twelve is where the row stops fitting a phone.
const int _maxLength = 12;

/// A slot's box.
///
/// Its own ladder rather than [controlHeight], for the reason a tick box has
/// one: a slot is not a control in a row of controls, it is a character
/// standing on its own, and an `md` slot the height of an `md` button would be
/// too small to read a code out of across a desk. Every step is taller than it
/// is wide, which is what makes a row of them read as places for one character
/// each rather than as a row of tiny fields.
const Map<PlassSize, Size> _slotSize = <PlassSize, Size>{
  PlassSize.xs: Size(24, 28),
  PlassSize.sm: Size(28, 32),
  PlassSize.md: Size(32, 40),
  PlassSize.lg: Size(40, 48),
  PlassSize.xl: Size(48, 56),
};

/// And its own radius, for the reason a tick box has one.
///
/// [PlassTokens.radius] is a share of a *control's height*, which is a cut
/// corner on something wide and a lozenge on something nearly square: `md` is
/// 12, and a 12 corner on a 32-wide box is most of the way to a pill. These are
/// ~22% of the slot's width instead — the same amount of cut on this shape.
const Map<PlassSize, double> _slotRadius = <PlassSize, double>{
  PlassSize.xs: 5,
  PlassSize.sm: 6,
  PlassSize.md: 7,
  PlassSize.lg: 9,
  PlassSize.xl: 11,
};

/// And its own type scale, two steps up the control ladder. A verification code
/// is read out loud off a phone and typed with the other hand; it is the one
/// piece of text in a form that should be bigger than the label above it.
const Map<PlassSize, double> _slotText = <PlassSize, double>{
  PlassSize.xs: 13,
  PlassSize.sm: 15,
  PlassSize.md: 17,
  PlassSize.lg: 20,
  PlassSize.xl: 24,
};

/// Between the slots, and the only thing density touches here — spacing, never
/// the box and never the type scale, exactly as everywhere else in the library.
const Map<PlassDensity, Map<PlassSize, double>> _slotGap = <PlassDensity, Map<PlassSize, double>>{
  PlassDensity.standard: <PlassSize, double>{
    PlassSize.xs: 4,
    PlassSize.sm: 4,
    PlassSize.md: 6,
    PlassSize.lg: 8,
    PlassSize.xl: 10,
  },
  PlassDensity.compact: <PlassSize, double>{
    PlassSize.xs: 2,
    PlassSize.sm: 2,
    PlassSize.md: 4,
    PlassSize.lg: 4,
    PlassSize.xl: 6,
  },
};

/// A row of one-character slots: a PIN, a texted verification code, an invite
/// key.
///
/// ```dart
/// PlOtpField(
///   label: const Text('Verification code'),
///   groupSize: 3,
///   onCompleted: verify,
/// )
/// ```
///
/// **One editor behind the whole row**, drawn as slots. The React build is one
/// `<input>` per slot, because that is what a browser's paste and autofill
/// expect; Flutter's text input is a single connection to the platform, and
/// splitting it into six would be six keyboards fighting over one code. So the
/// value lives in a [TextEditingController], the boxes are painted from it, and
/// pressing anywhere in the row puts the caret at the first empty slot.
///
/// The shell is the one [PlTextField] and [PlSelect] draw: a slot is a
/// field-shaped box, and a form holding both should not look like two form kits
/// stacked on each other.
class PlOtpField extends StatefulWidget {
  /// Creates a code field.
  const PlOtpField({
    this.controller,
    this.onChanged,
    this.onCompleted,
    this.onRejected,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.elevation = 0,
    this.length = 6,
    this.charset = PlOtpCharset.numeric,
    this.mask = false,
    this.groupSize,
    this.separator = '–',
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.disabled = false,
    this.readOnly = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The code being typed. Left out, the field owns a controller of its own.
  final TextEditingController? controller;

  /// Called on every change.
  final ValueChanged<String>? onChanged;

  /// Fires once every slot is filled — the moment to verify the code.
  final ValueChanged<String>? onCompleted;

  /// Fires with the characters typed or pasted text held that [charset]
  /// rejects.
  ///
  /// A slot that silently swallows a keystroke is a slot the reader thinks is
  /// broken, which is the whole reason a refusal has somewhere to go.
  final ValueChanged<String>? onRejected;

  /// What a slot is made of. `solid` is the **well** rather than a tinted pane,
  /// for the reason it is on a text field: a caret and a selection have to stay
  /// legible on top of it.
  final PlassVariant variant;

  /// The slot's box and the type inside it — the slot's own ladder rather than
  /// the control one.
  final PlassSize size;

  /// Semantic colour role. It reaches the hairline, the ring and the caret; the
  /// glass is never dyed.
  final PlassColor color;

  /// Changes the gap between slots and nothing else.
  final PlassDensity density;

  /// Drop shadow depth, `0`–`3`. `0` is the default — a slot is a well.
  final PlassElevation elevation;

  /// How many characters the code has. Clamped to 2–12: one box is a text
  /// field, and past twelve the row stops fitting a phone.
  final int length;

  /// What may be typed. Anything rejected is dropped rather than shown, and
  /// [onRejected] reports it.
  final PlOtpCharset charset;

  /// Hides the characters, the way a password field does.
  final bool mask;

  /// Splits the row every [groupSize] slots with a [separator]. `3` on a
  /// six-character code gives the familiar two blocks of three.
  final int? groupSize;

  /// What is drawn between two groups.
  final String separator;

  /// Label above the row.
  final Widget? label;

  /// Helper text below the row.
  final Widget? description;

  /// Error message below the row. Its presence also turns the field invalid.
  final Widget? error;

  /// Forces the invalid state without a message — for when a form library owns
  /// the validity. Defaults to whether [error] was given.
  final bool? invalid;

  /// Unavailable. Every slot stops answering.
  final bool disabled;

  /// Readable and copyable, but not typeable.
  final bool readOnly;

  /// The name a screen reader announces for the row.
  final String? semanticLabel;

  /// Drive focus from outside. Left out, the row owns a node of its own.
  final FocusNode? focusNode;

  /// Puts the caret in the row as it is inserted into the tree.
  final bool autofocus;

  @override
  State<PlOtpField> createState() => _PlOtpFieldState();
}

class _PlOtpFieldState extends State<PlOtpField> {
  TextEditingController? _fallback;
  FocusNode? _ownedFocus;
  bool _focused = false;
  bool _hovered = false;
  String _last = '';

  TextEditingController get _controller =>
      widget.controller ?? (_fallback ??= TextEditingController());

  FocusNode get _focusNode => widget.focusNode ?? (_ownedFocus ??= FocusNode());

  int get _slots => widget.length.clamp(_minLength, _maxLength);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocus);
    _controller.addListener(_onText);
    _last = _controller.text;
  }

  @override
  void didUpdateWidget(PlOtpField old) {
    super.didUpdateWidget(old);

    if (old.controller != widget.controller) {
      old.controller?.removeListener(_onText);
      _controller.addListener(_onText);
    }

    if (old.focusNode != widget.focusNode) {
      old.focusNode?.removeListener(_onFocus);
      _focusNode.addListener(_onFocus);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onText);
    widget.focusNode?.removeListener(_onFocus);
    _fallback?.dispose();
    _ownedFocus?.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  void _onText() {
    final String text = _controller.text;

    if (text == _last) {
      // A selection move is not a change, and reporting one would fire
      // `onCompleted` again every time the caret was put back in the row.
      setState(() {});
      return;
    }

    _last = text;
    setState(() {});
    widget.onChanged?.call(text);

    if (text.length == _slots) {
      widget.onCompleted?.call(text);
    }
  }

  /// Pressing anywhere in the row puts the caret at the first empty slot, which
  /// is where the next character is going to land whatever was pressed.
  void _focusAtEnd() {
    if (widget.disabled) {
      return;
    }

    _focusNode.requestFocus();
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
  }

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final bool hasError = widget.error != null;
    final bool isInvalid = widget.invalid ?? hasError;
    // Invalid re-points the whole slot family at `danger`, exactly as on a text
    // field, so the edge, the ring, the caret and the message all turn over
    // together and no state needs tokens of its own.
    final PlassColorFamily family = tokens.family(isInvalid ? PlassColor.danger : widget.color);

    final Size box = _slotSize[widget.size]!;
    final double radius = _slotRadius[widget.size]!;
    final double type = _slotText[widget.size]!;
    final double meta = metaText[widget.size]!;
    final String text = _controller.text;
    final int caret = text.characters.length.clamp(0, _slots - 1);
    final int? every = widget.groupSize != null && widget.groupSize! > 0 ? widget.groupSize : null;

    final List<Widget> row = <Widget>[];

    for (int index = 0; index < _slots; index++) {
      if (every != null && index > 0 && index % every == 0) {
        // A plain, excluded run of text rather than a separator node: the dash
        // is punctuation inside one value, not a break between two things, and
        // a reader that announced it once per group would be reading out the
        // shape of the box instead of the code in it.
        row.add(
          ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                widget.separator,
                style: TextStyle(color: tokens.mutedFg, fontSize: type),
              ),
            ),
          ),
        );
      }

      row.add(
        _slot(
          index: index,
          text: text,
          caret: caret,
          box: box,
          radius: radius,
          type: type,
          tokens: tokens,
          family: family,
        ),
      );
    }

    // The editor is laid out over the row and painted at zero opacity: a text
    // input has to be in the tree and measured to hold a connection to the
    // platform, so it cannot be `Offstage`. Nothing touches it directly — the
    // gesture below owns every press — and what a reader sees is the boxes.
    final Widget editor = IgnorePointer(
      child: Opacity(
        opacity: 0,
        child: EditableText(
          controller: _controller,
          focusNode: _focusNode,
          readOnly: widget.readOnly || widget.disabled,
          autofocus: widget.autofocus,
          keyboardType: widget.charset == PlOtpCharset.numeric
              ? TextInputType.number
              : TextInputType.text,
          // What lets a phone offer the code straight from the message.
          autofillHints: const <String>[AutofillHints.oneTimeCode],
          autocorrect: false,
          enableSuggestions: false,
          inputFormatters: <TextInputFormatter>[
            _CharsetFormatter(charset: widget.charset, onRejected: widget.onRejected),
            LengthLimitingTextInputFormatter(_slots),
          ],
          maxLines: 1,
          style: TextStyle(color: tokens.fg, fontSize: type),
          cursorColor: family.accent,
          backgroundCursorColor: tokens.mutedFg,
          selectionColor: family.softPress,
          showSelectionHandles: false,
          enableInteractiveSelection: false,
        ),
      ),
    );

    Widget slots = Stack(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: _slotGap[widget.density]![widget.size]!,
          children: row,
        ),
        Positioned.fill(child: editor),
      ],
    );

    slots = plassStateFilter(
      child: slots,
      disabled: widget.disabled,
      readOnly: widget.readOnly,
      lit: false,
    );

    slots = MouseRegion(
      cursor: widget.disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.text,
      onEnter: (PointerEnterEvent event) => setState(() => _hovered = true),
      onExit: (PointerExitEvent event) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: _focusAtEnd,
        child: slots,
      ),
    );

    final Column stack = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: stackGap[widget.size]!,
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
        slots,
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
      // The code itself, unmasked or not, is what a screen reader should read
      // back — the boxes are a drawing of it.
      value: text,
      child: IntrinsicWidth(child: stack),
    );
  }

  /// One box, and the character in it.
  Widget _slot({
    required int index,
    required String text,
    required int caret,
    required Size box,
    required double radius,
    required double type,
    required PlassTokens tokens,
    required PlassColorFamily family,
  }) {
    final List<String> characters = text.characters.toList();
    final bool filled = index < characters.length;
    // `:focus` and not `:focus-visible`, which is the one place in the library
    // that distinction is deliberately dropped: a slot is put in focus by
    // pressing it as often as by typing into it, and the ring is the only thing
    // saying which character the next keystroke lands on.
    final bool active = _focused && index == caret && !widget.readOnly && !widget.disabled;

    final BorderRadius corners = BorderRadius.circular(radius);

    Widget slot = PlassSurfaceBox(
      surface: fieldSurface(
        tokens,
        family,
        variant: widget.variant,
        elevation: widget.elevation,
        hovered: _hovered,
        focused: active,
        readOnly: widget.readOnly,
        disabled: widget.disabled,
      ),
      borderRadius: corners,
      child: Center(
        child: Text(
          filled ? (widget.mask ? '•' : characters[index]) : '',
          style: TextStyle(
            color: tokens.fg,
            fontSize: type,
            fontWeight: FontWeight.w500,
            height: 1,
            leadingDistribution: TextLeadingDistribution.even,
          ),
        ),
      ),
    );

    if (active) {
      slot = CustomPaint(
        foregroundPainter: PlassFocusRingPainter(color: family.ring, borderRadius: corners),
        child: slot,
      );
    }

    return SizedBox(
      width: box.width,
      height: box.height,
      child: ExcludeSemantics(child: slot),
    );
  }
}

/// Drops what the charset refuses, and says which characters those were.
///
/// A `FilteringTextInputFormatter` would do the dropping and nothing else, and
/// a refusal that disappears silently is the single worst thing a code field
/// does: the reader presses a key, sees nothing, and concludes the field is
/// broken.
class _CharsetFormatter extends TextInputFormatter {
  const _CharsetFormatter({required this.charset, this.onRejected});

  final PlOtpCharset charset;
  final ValueChanged<String>? onRejected;

  static final RegExp _numeric = RegExp(r'[0-9]');
  static final RegExp _alpha = RegExp(r'[A-Za-z]');
  static final RegExp _alphanumeric = RegExp(r'[A-Za-z0-9]');

  RegExp? get _allowed {
    switch (charset) {
      case PlOtpCharset.numeric:
        return _numeric;
      case PlOtpCharset.alpha:
        return _alpha;
      case PlOtpCharset.alphanumeric:
        return _alphanumeric;
      case PlOtpCharset.any:
        return null;
    }
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue before, TextEditingValue after) {
    final RegExp? allowed = _allowed;

    if (allowed == null) {
      return after;
    }

    final StringBuffer kept = StringBuffer();
    final StringBuffer dropped = StringBuffer();

    for (final String character in after.text.characters) {
      if (allowed.hasMatch(character)) {
        kept.write(character);
      } else {
        dropped.write(character);
      }
    }

    if (dropped.isEmpty) {
      return after;
    }

    onRejected?.call(dropped.toString());

    final String text = kept.toString();

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
