/// A colour, chosen by eye.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/color.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/picker.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

export 'package:plass_ui/src/internal/color.dart' show PlColorFormat;

/// The names for the parts of the picker that have no text on them.
@immutable
class PlColorPickerLabels {
  /// Creates a set of names.
  const PlColorPickerLabels({
    this.area = 'Saturation and brightness',
    this.hue = 'Hue',
    this.alpha = 'Opacity',
    this.value = 'Colour value',
    this.swatches = 'Swatches',
    this.clear = 'Clear',
    this.empty = 'Pick a colour',
  });

  /// The saturation/brightness square.
  final String area;

  /// The hue rail beside it.
  final String hue;

  /// The opacity rail, when `alpha` is on.
  final String alpha;

  /// The field the value can be typed into.
  final String value;

  /// The grid of ready-made colours.
  final String swatches;

  /// The × that empties the control.
  final String clear;

  /// What the trigger reads before anything has been chosen.
  final String empty;
}

/// How wide the panel is, and a ladder of its own rather than a step off the
/// control heights: a saturation square is a *space* to aim at, not a row to
/// read, and one 40 tall would give the pointer four hundred distinguishable
/// colours out of a possible ten thousand.
const Map<PlassSize, double> _panelWidth = <PlassSize, double>{
  PlassSize.xs: 160,
  PlassSize.sm: 176,
  PlassSize.md: 208,
  PlassSize.lg: 240,
  PlassSize.xl: 288,
};

const Map<PlassSize, double> _areaHeight = <PlassSize, double>{
  PlassSize.xs: 96,
  PlassSize.sm: 112,
  PlassSize.md: 128,
  PlassSize.lg: 160,
  PlassSize.xl: 192,
};

const Map<PlassSize, double> _railHeight = <PlassSize, double>{
  PlassSize.xs: 10,
  PlassSize.sm: 12,
  PlassSize.md: 14,
  PlassSize.lg: 16,
  PlassSize.xl: 20,
};

/// The panel's own gaps, one track tighter than a form's.
const Map<PlassSize, double> _panelGap = <PlassSize, double>{
  PlassSize.xs: 6,
  PlassSize.sm: 8,
  PlassSize.md: 10,
  PlassSize.lg: 12,
  PlassSize.xl: 14,
};

const Map<PlassSize, double> _thumbSize = <PlassSize, double>{
  PlassSize.xs: 10,
  PlassSize.sm: 12,
  PlassSize.md: 14,
  PlassSize.lg: 16,
  PlassSize.xl: 18,
};

/// The spectrum, drawn rather than sampled.
///
/// Seven stops at the six primaries plus a repeat of red, which is what makes
/// the rail seamless — the wheel is a circle and a gradient is a line, so the
/// only way for 359° to sit next to 0° is to write red down twice.
const List<Color> _hueStops = <Color>[
  Color(0xFFFF0000),
  Color(0xFFFFFF00),
  Color(0xFF00FF00),
  Color(0xFF00FFFF),
  Color(0xFF0000FF),
  Color(0xFFFF00FF),
  Color(0xFFFF0000),
];

/// One step of an arrow key, and ten with Shift — the same pair every slider in
/// the package uses.
class _NudgeIntent extends Intent {
  const _NudgeIntent(this.dx, this.dy);

  final int dx;
  final int dy;
}

/// A colour, chosen by eye.
///
/// ```dart
/// PlColorPicker(
///   label: const Text('Project colour'),
///   value: colour,
///   onValueChanged: (String next) => setState(() => colour = next),
/// )
/// ```
///
/// A saturation square with a hue rail beside it — the arrangement every design
/// tool has settled on, because it is the one that puts every colour of a hue
/// within a single movement of the pointer.
///
/// The panel's state is **HSV and it never leaves that model**, which is what
/// keeps the hue rail still while the pointer is in the black corner: through
/// RGB, every shade of black is the same colour and the rail would snap to red.
///
/// There is no colour package under this. The conversions are in
/// `internal/color.dart`, a hundred lines of arithmetic — the whole reason a
/// widget that computes colours brings nothing with it.
class PlColorPicker extends StatefulWidget {
  /// Creates a colour picker.
  const PlColorPicker({
    this.value,
    this.onValueChanged,
    this.format = PlColorFormat.hex,
    this.alpha = false,
    this.swatches = defaultSwatches,
    this.inline = false,
    this.editable = true,
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.disabled = false,
    this.readOnly = false,
    this.fullWidth = false,
    this.clearable = false,
    this.labels = const PlColorPickerLabels(),
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    super.key,
  });

  /// The colour, as a CSS string. `null` starts the picker on its own blue.
  final String? value;

  /// Called with the new colour, written in [format].
  final ValueChanged<String>? onValueChanged;

  /// Which notation the value is written in on the way out.
  final PlColorFormat format;

  /// Offers an opacity rail, and lets the value carry a fourth channel.
  final bool alpha;

  /// The ready-made colours under the panel. An empty list draws none.
  final List<String> swatches;

  /// Draws the panel in the screen instead of in a popup, with no trigger.
  final bool inline;

  /// The field under the panel that the value can be typed into.
  final bool editable;

  /// Label above the control.
  final Widget? label;

  /// Helper text below it.
  final Widget? description;

  /// Error message below. Its presence also turns the control invalid.
  final Widget? error;

  /// The same state without a message.
  final bool? invalid;

  /// Unusable and out of the focus order.
  final bool disabled;

  /// Shows the colour and forbids changing it.
  final bool readOnly;

  /// Stretches the trigger to what is around it.
  final bool fullWidth;

  /// Offers the × that empties the control.
  final bool clearable;

  /// The accessible names of the parts that have no text on them.
  final PlColorPickerLabels labels;

  /// What the trigger is made of.
  final PlassVariant variant;

  /// The trigger's height, the panel's width, and the size of the square and
  /// the rails.
  final PlassSize? size;

  /// Semantic colour role — the family the control lights up in, not the colour
  /// it is holding.
  final PlassColor? color;

  /// Changes the padding and nothing else.
  final PlassDensity? density;

  /// Drop shadow depth on the trigger.
  final PlassElevation elevation;

  @override
  State<PlColorPicker> createState() => _PlColorPickerState();
}

class _PlColorPickerState extends State<PlColorPicker> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  static const PlassHsv _fallback = PlassHsv(217, 87, 82);

  late PlassColorValue _model =
      parseColor(widget.value ?? '#1a58d1') ?? const PlassColorValue(_fallback, 1);
  late final TextEditingController _text = TextEditingController(text: widget.value ?? '#1a58d1');
  bool _open = false;

  String get _written => formatColor(_model.hsv, widget.alpha ? _model.alpha : 1, widget.format);

  bool get _empty => widget.value == '';

  bool get _inert => widget.disabled || widget.readOnly;

  @override
  void didUpdateWidget(PlColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    final String? incoming = widget.value;

    if (incoming == null || incoming == oldWidget.value) return;

    final PlassColorValue? parsed = parseColor(incoming);

    if (parsed == null) {
      // Not a colour this understands — `''` after a clear, or something a
      // caller made up. The field shows it and the panel stays where it was.
      _text.text = incoming;
      return;
    }

    // Compared as colours rather than as strings: `#FF0000` and `#ff0000` are
    // the same colour written twice, and a string comparison would re-seed the
    // model from a value it had just produced.
    if (formatColor(parsed.hsv, widget.alpha ? parsed.alpha : 1, widget.format) == _written) {
      return;
    }

    setState(() {
      _model = parsed;
      _text.text = incoming;
    });
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _commit(PlassColorValue next, {String? typed}) {
    setState(() {
      _model = next;
      _text.text = typed ?? formatColor(next.hsv, widget.alpha ? next.alpha : 1, widget.format);
    });

    widget.onValueChanged?.call(
      formatColor(next.hsv, widget.alpha ? next.alpha : 1, widget.format),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final bool invalid = widget.invalid ?? widget.error != null;

    final Widget panel = _ColorPanel(
      model: _model,
      onChanged: _commit,
      controller: _text,
      onTyped: (String next) {
        final PlassColorValue? parsed = parseColor(next);

        if (parsed == null) {
          setState(() {});
          return;
        }

        _commit(parsed, typed: next);
      },
      withAlpha: widget.alpha,
      swatches: widget.swatches,
      editable: widget.editable,
      size: _size,
      color: _color,
      inert: _inert,
      labels: widget.labels,
    );

    if (widget.inline) {
      final PlassColor family = invalid ? PlassColor.danger : _color;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: stackGap[_size]!,
        children: <Widget>[
          if (widget.label != null)
            DefaultTextStyle.merge(
              style: TextStyle(
                color: widget.disabled ? tokens.mutedFg : tokens.fg,
                fontSize: metaText[_size]!,
                fontWeight: FontWeight.w600,
              ),
              child: widget.label!,
            ),
          panel,
          if (widget.description != null)
            DefaultTextStyle.merge(
              style: TextStyle(color: tokens.mutedFg, fontSize: metaText[_size]!),
              child: widget.description!,
            ),
          if (widget.error != null)
            DefaultTextStyle.merge(
              style: TextStyle(color: tokens.family(family).accent, fontSize: metaText[_size]!),
              child: widget.error!,
            ),
        ],
      );
    }

    return PlassPickerShell(
      variant: widget.variant,
      size: _size,
      color: _color,
      density: _density,
      elevation: widget.elevation,
      label: widget.label,
      description: widget.description,
      error: widget.error,
      invalid: widget.invalid,
      disabled: widget.disabled,
      readOnly: widget.readOnly,
      fullWidth: widget.fullWidth,
      clearable: widget.clearable,
      clearLabel: widget.labels.clear,
      onClear: () {
        _text.text = '';
        widget.onValueChanged?.call('');
      },
      empty: _empty,
      open: _open,
      onOpenChanged: (bool next) => setState(() => _open = next),
      startIcon: _Chip(
        tokens: tokens,
        size: _thumbSize[_size]! + 4,
        color: _empty
            ? const Color(0x00000000)
            : hsvToColor(_model.hsv, widget.alpha ? _model.alpha : 1),
      ),
      display: Text(_empty ? widget.labels.empty : _written),
      semanticValue: _empty ? widget.labels.empty : _written,
      samples: <Widget>[Text(_sample(widget.format, widget.alpha))],
      popup: Padding(padding: const EdgeInsets.all(8), child: panel),
    );
  }

  /// The widest string each notation can produce, so the trigger stops resizing.
  static String _sample(PlColorFormat format, bool withAlpha) {
    switch (format) {
      case PlColorFormat.hex:
        return withAlpha ? '#ffffffff' : '#ffffff';
      case PlColorFormat.rgb:
        return withAlpha ? 'rgba(255, 255, 255, 0.55)' : 'rgb(255, 255, 255)';
      case PlColorFormat.hsl:
        return withAlpha ? 'hsla(360, 100%, 100%, 0.55)' : 'hsl(360, 100%, 100%)';
    }
  }
}

/// The chequerboard behind a translucent colour.
class _Checker extends StatelessWidget {
  const _Checker({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CheckerPainter(color), child: child);
  }
}

class _CheckerPainter extends CustomPainter {
  const _CheckerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const double tile = 4;
    final Paint paint = Paint()..color = color;

    for (double y = 0; y < size.height; y += tile) {
      for (double x = 0; x < size.width; x += tile) {
        if (((x / tile).floor() + (y / tile).floor()) % 2 == 0) continue;
        canvas.drawRect(Rect.fromLTWH(x, y, tile, tile), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerPainter oldDelegate) => oldDelegate.color != color;
}

/// The round sample on the trigger and beside the field.
class _Chip extends StatelessWidget {
  const _Chip({required this.tokens, required this.size, required this.color});

  final PlassTokens tokens;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: _Checker(
          color: tokens.border,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: tokens.border, width: hairline),
            ),
          ),
        ),
      ),
    );
  }
}

/// The square, the rails, the field and the swatches.
class _ColorPanel extends StatelessWidget {
  const _ColorPanel({
    required this.model,
    required this.onChanged,
    required this.controller,
    required this.onTyped,
    required this.withAlpha,
    required this.swatches,
    required this.editable,
    required this.size,
    required this.color,
    required this.inert,
    required this.labels,
  });

  final PlassColorValue model;
  final void Function(PlassColorValue next, {String? typed}) onChanged;
  final TextEditingController controller;
  final ValueChanged<String> onTyped;
  final bool withAlpha;
  final List<String> swatches;
  final bool editable;
  final PlassSize size;
  final PlassColor color;
  final bool inert;
  final PlColorPickerLabels labels;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final PlassColorFamily family = tokens.family(color);
    final double thumb = _thumbSize[size]!;
    final double radius = PlassTokens.radius[size]!;
    final Color pure = hsvToColor(PlassHsv(model.hsv.h, 100, 100));
    final Color solid = hsvToColor(model.hsv);

    return SizedBox(
      width: _panelWidth[size]!,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: _panelGap[size]!,
        children: <Widget>[
          _Track(
            label: labels.area,
            valueText: '${model.hsv.s.round()}%, ${model.hsv.v.round()}%',
            increasedValue: '${(model.hsv.s + 1).clamp(0, 100).round()}%, ${model.hsv.v.round()}%',
            decreasedValue: '${(model.hsv.s - 1).clamp(0, 100).round()}%, ${model.hsv.v.round()}%',
            value: model.hsv.s.round(),
            max: 100,
            inert: inert,
            ring: family.ring,
            height: _areaHeight[size]!,
            borderRadius: BorderRadius.circular(radius),
            border: tokens.border,
            onFraction: (double x, double y) => onChanged(
              PlassColorValue(PlassHsv(model.hsv.h, x * 100, (1 - y) * 100), model.alpha),
            ),
            onNudge: (int dx, int dy) => onChanged(
              PlassColorValue(
                PlassHsv(
                  model.hsv.h,
                  (model.hsv.s + dx).clamp(0, 100).toDouble(),
                  (model.hsv.v + dy).clamp(0, 100).toDouble(),
                ),
                model.alpha,
              ),
            ),
            // Black over white: the brightness ramp has to be above the
            // saturation ramp or the bottom of the square never reaches black.
            layers: <Widget>[
              Positioned.fill(child: ColoredBox(color: pure)),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[Color(0xFFFFFFFF), Color(0x00FFFFFF)],
                    ),
                  ),
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: <Color>[Color(0xFF000000), Color(0x00000000)],
                    ),
                  ),
                ),
              ),
            ],
            thumb: _Thumb(size: thumb, color: solid),
            thumbX: model.hsv.s / 100,
            thumbY: 1 - model.hsv.v / 100,
          ),
          _Track(
            label: labels.hue,
            increasedValue: '${((model.hsv.h + 2) % 360).round()}',
            decreasedValue: '${((model.hsv.h - 2 + 360) % 360).round()}',
            value: model.hsv.h.round(),
            max: 360,
            inert: inert,
            ring: family.ring,
            height: _railHeight[size]!,
            borderRadius: BorderRadius.circular(_railHeight[size]!),
            border: tokens.border,
            onFraction: (double x, double _) =>
                onChanged(PlassColorValue(model.hsv.copyWith(h: x * 360), model.alpha)),
            // The wheel is a circle, so a step past either end wraps rather
            // than stopping.
            onNudge: (int dx, int _) => onChanged(
              PlassColorValue(
                model.hsv.copyWith(h: (model.hsv.h + dx * 2 + 360) % 360),
                model.alpha,
              ),
            ),
            layers: const <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: _hueStops,
                    ),
                  ),
                ),
              ),
            ],
            thumb: _Thumb(size: thumb, color: pure),
            thumbX: model.hsv.h / 360,
            thumbY: 0.5,
          ),
          if (withAlpha)
            _Track(
              label: labels.alpha,
              increasedValue: '${(model.alpha * 100 + 1).clamp(0, 100).round()}',
              decreasedValue: '${(model.alpha * 100 - 1).clamp(0, 100).round()}',
              value: (model.alpha * 100).round(),
              max: 100,
              inert: inert,
              ring: family.ring,
              height: _railHeight[size]!,
              borderRadius: BorderRadius.circular(_railHeight[size]!),
              border: tokens.border,
              onFraction: (double x, double _) =>
                  onChanged(PlassColorValue(model.hsv, x.clamp(0, 1))),
              onNudge: (int dx, int _) =>
                  onChanged(PlassColorValue(model.hsv, (model.alpha + dx / 100).clamp(0, 1))),
              layers: <Widget>[
                Positioned.fill(
                  child: _Checker(color: tokens.border, child: const SizedBox.expand()),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[hsvToColor(model.hsv, 0), solid],
                      ),
                    ),
                  ),
                ),
              ],
              thumb: _Thumb(size: thumb, color: hsvToColor(model.hsv, model.alpha)),
              thumbX: model.alpha,
              thumbY: 0.5,
            ),
          if (editable)
            Row(
              spacing: _panelGap[size]!,
              children: <Widget>[
                _Chip(tokens: tokens, size: thumb + 6, color: hsvToColor(model.hsv, model.alpha)),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: tokens.border, width: hairline),
                      borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.xs]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Semantics(
                        label: labels.value,
                        textField: true,
                        child: EditableText(
                          controller: controller,
                          focusNode: FocusNode(),
                          readOnly: inert,
                          onChanged: onTyped,
                          style: TextStyle(
                            color: tokens.fg,
                            fontSize: metaText[size]!,
                            fontFamily: 'monospace',
                          ),
                          cursorColor: family.accent,
                          backgroundCursorColor: tokens.mutedFg,
                          selectionColor: family.softPress,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (swatches.isNotEmpty)
            Semantics(
              container: true,
              label: labels.swatches,
              explicitChildNodes: true,
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: <Widget>[
                  for (final String swatch in swatches)
                    _Swatch(
                      swatch: swatch,
                      size: (_panelWidth[size]! - 4 * 7) / 8,
                      chosen: _isChosen(swatch),
                      inert: inert,
                      border: tokens.border,
                      ring: family.ring,
                      onPressed: () {
                        final PlassColorValue? parsed = parseColor(swatch);

                        if (parsed != null) onChanged(parsed);
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _isChosen(String swatch) {
    final PlassColorValue? parsed = parseColor(swatch);

    if (parsed == null) return false;

    return formatColor(parsed.hsv, parsed.alpha, PlColorFormat.hex) ==
        formatColor(model.hsv, model.alpha, PlColorFormat.hex);
  }
}

/// The thumb: a white ring that survives on white and on black.
class _Thumb extends StatelessWidget {
  const _Thumb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFFFFF), width: 2),
        // Two shadows: a dark hairline so the white ring survives on white, and
        // a soft drop so it survives on black. Neither is tinted with the
        // colour under it, which would make the thumb disappear at exactly the
        // moment it matters.
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x59000000), spreadRadius: 1),
          BoxShadow(color: Color(0x66000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}

/// A square or a rail: something a pointer aims at and the arrow keys walk.
class _Track extends StatefulWidget {
  const _Track({
    required this.label,
    required this.value,
    required this.max,
    required this.inert,
    required this.ring,
    required this.height,
    required this.borderRadius,
    required this.border,
    required this.onFraction,
    required this.onNudge,
    required this.layers,
    required this.thumb,
    required this.thumbX,
    required this.thumbY,
    required this.increasedValue,
    required this.decreasedValue,
    this.valueText,
  });

  final String label;
  final String? valueText;
  final int value;
  final int max;
  final bool inert;
  final Color ring;
  final double height;
  final BorderRadius borderRadius;
  final Color border;
  final void Function(double x, double y) onFraction;
  final void Function(int dx, int dy) onNudge;
  final List<Widget> layers;
  final Widget thumb;
  final double thumbX;
  final double thumbY;

  /// What the value becomes one step up and one step down.
  ///
  /// Flutter refuses a node that offers `increase` with a `value` and no
  /// `increasedValue` — a screen reader that can say what pressing will do is
  /// the whole point of the action being there.
  final String increasedValue;
  final String decreasedValue;

  @override
  State<_Track> createState() => _TrackState();
}

class _TrackState extends State<_Track> {
  final GlobalKey _box = GlobalKey();
  bool _focusVisible = false;

  void _at(Offset global) {
    if (widget.inert) return;

    final RenderBox? box = _box.currentContext?.findRenderObject() as RenderBox?;

    if (box == null || box.size.isEmpty) return;

    final Offset local = box.globalToLocal(global);

    widget.onFraction(
      (local.dx / box.size.width).clamp(0, 1),
      (local.dy / box.size.height).clamp(0, 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget track = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double thumb = _thumbSize[PlassSize.md]!;

        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            ...widget.layers,
            Positioned(
              left: constraints.maxWidth * widget.thumbX - thumb / 2,
              top: widget.height * widget.thumbY - thumb / 2,
              child: IgnorePointer(child: widget.thumb),
            ),
          ],
        );
      },
    );

    track = ClipRRect(borderRadius: widget.borderRadius, child: track);

    track = Container(
      key: _box,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        border: Border.all(color: widget.border, width: hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: track,
    );

    track = GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTapDown: (TapDownDetails details) => _at(details.globalPosition),
      onPanStart: (DragStartDetails details) => _at(details.globalPosition),
      onPanUpdate: (DragUpdateDetails details) => _at(details.globalPosition),
      child: track,
    );

    track = FocusableActionDetector(
      enabled: !widget.inert,
      includeFocusSemantics: false,
      onShowFocusHighlight: (bool value) {
        if (_focusVisible != value) setState(() => _focusVisible = value);
      },
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowRight): _NudgeIntent(1, 0),
        SingleActivator(LogicalKeyboardKey.arrowLeft): _NudgeIntent(-1, 0),
        SingleActivator(LogicalKeyboardKey.arrowUp): _NudgeIntent(0, 1),
        SingleActivator(LogicalKeyboardKey.arrowDown): _NudgeIntent(0, -1),
        SingleActivator(LogicalKeyboardKey.arrowRight, shift: true): _NudgeIntent(10, 0),
        SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true): _NudgeIntent(-10, 0),
        SingleActivator(LogicalKeyboardKey.arrowUp, shift: true): _NudgeIntent(0, 10),
        SingleActivator(LogicalKeyboardKey.arrowDown, shift: true): _NudgeIntent(0, -10),
      },
      actions: <Type, Action<Intent>>{
        _NudgeIntent: CallbackAction<_NudgeIntent>(
          onInvoke: (_NudgeIntent intent) {
            widget.onNudge(intent.dx, intent.dy);
            return null;
          },
        ),
      },
      child: track,
    );

    if (_focusVisible) {
      track = CustomPaint(
        foregroundPainter: PlassFocusRingPainter(
          color: widget.ring,
          borderRadius: widget.borderRadius,
        ),
        child: track,
      );
    }

    return Semantics(
      slider: true,
      enabled: !widget.inert,
      label: widget.label,
      value: widget.valueText ?? '${widget.value}',
      increasedValue: widget.increasedValue,
      decreasedValue: widget.decreasedValue,
      onIncrease: widget.inert ? null : () => widget.onNudge(1, 0),
      onDecrease: widget.inert ? null : () => widget.onNudge(-1, 0),
      child: track,
    );
  }
}

/// One ready-made colour.
class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.swatch,
    required this.size,
    required this.chosen,
    required this.inert,
    required this.border,
    required this.ring,
    required this.onPressed,
  });

  final String swatch;
  final double size;
  final bool chosen;
  final bool inert;
  final Color border;
  final Color ring;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final PlassColorValue? parsed = parseColor(swatch);
    final Color fill = parsed == null
        ? const Color(0x00000000)
        : hsvToColor(parsed.hsv, parsed.alpha);

    return Semantics(
      button: true,
      selected: chosen,
      enabled: !inert,
      label: swatch,
      onTap: inert ? null : onPressed,
      child: GestureDetector(
        onTap: inert ? null : onPressed,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: hairline),
          ),
          // Black or white, decided by what can actually be read on the swatch
          // — a fixed white tick vanishes on yellow.
          child: chosen && parsed != null
              ? Center(
                  child: PlassGlyph(
                    PlassGlyphShape.check,
                    size: size * 0.6,
                    color: readableInk(parsed.hsv),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
