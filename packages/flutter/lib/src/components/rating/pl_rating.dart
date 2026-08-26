/// A score out of five, as a row of stars.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// What one choice, and the whole control once it is read only, is called.
typedef PlRatingValueLabel = String Function(double value, int count);

/// A score out of five, as a row of stars.
///
/// ```dart
/// PlRating(value: score, onChanged: (double next) => setState(() => score = next))
/// ```
///
/// **Controlled**, like every other input in this package: it is handed a
/// [value] and reports the one that should replace it. There is no
/// `defaultValue` anywhere in the library.
///
/// The fraction is drawn by laying the filled star over the empty one and
/// clipping it to a share of the width. Nothing is transformed and no glyph is
/// scaled, so a half star is the leading half of exactly the star beside it —
/// which is the house no-transform rule holding on a widget whose whole job is
/// a partial shape. The clip runs from the leading edge, so it fills from the
/// right under RTL without being told to.
///
/// [readOnly] is a different widget in the same clothes: no gestures, no
/// options, and one image semantics node carrying the score as a sentence. A
/// star display that kept twenty focusable options would be twenty stops on a
/// screen that was only reporting a number.
class PlRating extends StatefulWidget {
  /// Creates a rating.
  const PlRating({
    required this.value,
    this.onChanged,
    this.count = 5,
    this.precision = 1,
    this.icon,
    this.emptyIcon,
    this.clearable = true,
    this.readOnly = false,
    this.disabled = false,
    this.size = PlassSize.md,
    this.color = PlassColor.warning,
    this.label = 'Rating',
    this.valueLabel = defaultValueLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// How much is rated. `0` is no rating at all.
  final double value;

  /// Called with the new score. Leaving it out freezes the rating where it is.
  final ValueChanged<double>? onChanged;

  /// How many stars there are, and therefore the highest score.
  final int count;

  /// The smallest step that can be *chosen*, as a fraction of one star — `0.5`
  /// gives half stars, `1` whole ones. Anything outside `0 < precision <= 1`
  /// falls back to `1`.
  ///
  /// It bounds what a reader can pick and nothing else: a [value] of `4.3` is
  /// drawn as four stars and a third at every precision, because an average is
  /// not a choice and rounding it to the nearest half would be reporting a
  /// different number from the one the widget was handed.
  final double precision;

  /// The glyph a filled star is drawn with.
  final Widget? icon;

  /// And the one an empty star is drawn with. Has to be the same shape — the
  /// two are laid one over the other and the top one is cropped.
  final Widget? emptyIcon;

  /// Choosing the score that is already chosen clears it back to `0`.
  final bool clearable;

  /// Shows the score without letting it be changed — a product's average, a
  /// rating somebody else left.
  ///
  /// This is the one `readOnly` in the library that does **not** drain the
  /// saturation, because it is not a control being held still: there are no
  /// controls left, and a row of grey stars would say the score itself was
  /// unavailable.
  final bool readOnly;

  /// Unavailable. The light goes out of the whole row.
  final bool disabled;

  /// Height of one star, on the standalone-glyph ladder — a star is content
  /// rather than a control, so it is measured against the text beside it.
  final PlassSize size;

  /// Semantic colour role.
  ///
  /// [PlassColor.warning] by default — the amber a star is expected to be —
  /// rather than the `primary` everything else takes. It is the one place in
  /// the library where a widget's default colour is chosen by what the object
  /// *is* instead of by what it means.
  final PlassColor color;

  /// Names the whole control.
  final String label;

  /// What one choice, and the whole control once it is read only, is called.
  final PlRatingValueLabel valueLabel;

  /// Drive focus from outside. Left out, the row owns one of its own.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  /// `3 out of 5`, and `No rating` at zero.
  static String defaultValueLabel(double value, int count) {
    if (value <= 0) {
      return 'No rating';
    }

    // A score is a small number with at most a couple of decimals, and a
    // trailing `.0` on every whole star would be read out on every one of them.
    final String score = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();

    return '$score out of $count';
  }

  @override
  State<PlRating> createState() => _PlRatingState();
}

class _PlRatingState extends State<PlRating> {
  /// What the pointer is currently promising, which is not the value until it
  /// is tapped. `null` is "the pointer is not on the row", not "zero stars".
  double? _hovered;

  bool _focusVisible = false;

  bool get _interactive => !widget.readOnly && !widget.disabled && widget.onChanged != null;

  int get _stars => widget.count < 1 ? 1 : widget.count;

  double get _step => widget.precision > 0 && widget.precision <= 1 ? widget.precision : 1;

  int get _stepsPerStar => (1 / _step).round();

  /// Rounds a score onto the step ladder, so a keyboard cannot land between two
  /// choices the pointer could never have reached.
  double _snap(double score) {
    final double clamped = score.clamp(0, _stars.toDouble());
    final double steps = (clamped / _step).roundToDouble();

    return double.parse((steps * _step).toStringAsFixed(4));
  }

  void _choose(double score) {
    if (!_interactive) {
      return;
    }

    if (widget.clearable && score == widget.value) {
      widget.onChanged!(0);
      return;
    }

    widget.onChanged!(score);
  }

  void _nudge(int steps) {
    if (!_interactive) {
      return;
    }

    final double next = _snap(widget.value + steps * _step);

    if (next != widget.value) {
      widget.onChanged!(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final PlassColorFamily family = tokens.family(widget.color);
    final double box = iconSize[widget.size]!;
    final double spacing = gap[widget.size]!;

    // An empty star is not a disabled one and not a hairline: it is the ghost
    // of the star beside it, so it takes the muted ink at enough strength to
    // read as a shape and not enough to compete with the ones that are filled.
    final Color empty = tokens.mutedFg.withValues(alpha: tokens.mutedFg.a * 0.4);

    final double shown = (_hovered ?? widget.value).clamp(0, _stars.toDouble());

    Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing,
      children: <Widget>[
        for (int index = 0; index < _stars; index++)
          _star(
            index: index,
            fill: (shown - index).clamp(0, 1),
            box: box,
            empty: empty,
            family: family,
          ),
      ],
    );

    if (_focusVisible) {
      row = CustomPaint(
        foregroundPainter: PlassFocusRingPainter(
          color: family.ring,
          borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.xs]!),
        ),
        child: row,
      );
    }

    if (widget.disabled) {
      // The house treatment, not a grey token: the light goes out of the row
      // and the screen shows through it.
      row = Opacity(opacity: disabledOpacity, child: row);
    }

    if (widget.readOnly) {
      return Semantics(
        image: true,
        label: widget.valueLabel(widget.value.clamp(0, _stars.toDouble()), _stars),
        child: ExcludeSemantics(child: row),
      );
    }

    return Semantics(
      container: true,
      label: widget.label,
      enabled: _interactive,
      child: FocusableActionDetector(
        enabled: _interactive,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        includeFocusSemantics: false,
        mouseCursor: widget.disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        onShowFocusHighlight: (bool value) {
          if (_focusVisible != value) {
            setState(() => _focusVisible = value);
          }
        },
        // Declared rather than inherited, so the row works the same in a bare
        // `WidgetsApp` or with no app widget above it at all. The arrows are
        // what a radio group gives the React build for free.
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.arrowRight): _NudgeIntent(1),
          SingleActivator(LogicalKeyboardKey.arrowUp): _NudgeIntent(1),
          SingleActivator(LogicalKeyboardKey.arrowLeft): _NudgeIntent(-1),
          SingleActivator(LogicalKeyboardKey.arrowDown): _NudgeIntent(-1),
          SingleActivator(LogicalKeyboardKey.home): _SetIntent(0),
          SingleActivator(LogicalKeyboardKey.end): _SetIntent(double.infinity),
        },
        actions: <Type, Action<Intent>>{
          _NudgeIntent: CallbackAction<_NudgeIntent>(
            onInvoke: (_NudgeIntent intent) {
              // The arrows follow the writing direction, because the row does.
              final bool rtl = Directionality.of(context) == TextDirection.rtl;
              _nudge(rtl ? -intent.steps : intent.steps);
              return null;
            },
          ),
          _SetIntent: CallbackAction<_SetIntent>(
            onInvoke: (_SetIntent intent) {
              _choose(_snap(intent.score));
              return null;
            },
          ),
        },
        child: MouseRegion(
          onExit: (PointerExitEvent event) => setState(() => _hovered = null),
          child: row,
        ),
      ),
    );
  }

  /// One star: the empty glyph, the filled glyph clipped to [fill], and — when
  /// the row can be used — one hit region per choosable fraction laid over it.
  Widget _star({
    required int index,
    required double fill,
    required double box,
    required Color empty,
    required PlassColorFamily family,
  }) {
    final TextDirection direction = Directionality.of(context);

    return SizedBox(
      width: box,
      height: box,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: IconTheme.merge(
              data: IconThemeData(color: empty, size: box),
              child: widget.emptyIcon ?? PlassGlyph(PlassGlyphShape.starOutline, size: box),
            ),
          ),
          if (fill > 0)
            Positioned.fill(
              child: ClipRect(
                clipper: _FractionClipper(fraction: fill, direction: direction),
                child: IconTheme.merge(
                  data: IconThemeData(color: family.accent, size: box),
                  child: widget.icon ?? PlassGlyph(PlassGlyphShape.star, size: box),
                ),
              ),
            ),
          if (!widget.readOnly)
            Positioned.fill(
              child: Row(
                children: <Widget>[
                  for (int part = 0; part < _stepsPerStar; part++)
                    Expanded(child: _region(_snap(index + (part + 1) * _step), family: family)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// One choosable fraction of one star: a hit target, a hover preview and a
  /// semantics node that says it is one of a set.
  Widget _region(double score, {required PlassColorFamily family}) {
    return MouseRegion(
      onEnter: (PointerEnterEvent event) {
        if (_interactive) {
          setState(() => _hovered = score);
        }
      },
      child: GestureDetector(
        // Opaque, so a tap on an unavailable rating is swallowed rather than
        // falling through to whatever is behind it.
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: () => _choose(score),
        child: Semantics(
          inMutuallyExclusiveGroup: true,
          checked: widget.value == score,
          enabled: _interactive,
          label: widget.valueLabel(score, _stars),
          onTap: _interactive ? () => _choose(score) : null,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

/// Crops the filled star to a share of its width, from the leading edge.
///
/// A clipper rather than a narrower box, because the glyph has to keep its own
/// full width — sized down instead of cropped, a half star would be a whole
/// star squashed into half the room.
class _FractionClipper extends CustomClipper<Rect> {
  const _FractionClipper({required this.fraction, required this.direction});

  final double fraction;
  final TextDirection direction;

  @override
  Rect getClip(Size size) {
    final double width = size.width * fraction;

    return direction == TextDirection.rtl
        ? Rect.fromLTWH(size.width - width, 0, width, size.height)
        : Rect.fromLTWH(0, 0, width, size.height);
  }

  @override
  bool shouldReclip(_FractionClipper oldClipper) {
    return oldClipper.fraction != fraction || oldClipper.direction != direction;
  }
}

/// Moves the score by whole steps. See `PlRating`'s shortcuts.
class _NudgeIntent extends Intent {
  const _NudgeIntent(this.steps);

  final int steps;
}

/// Sets the score outright — the two ends of the row.
class _SetIntent extends Intent {
  const _SetIntent(this.score);

  final double score;
}
