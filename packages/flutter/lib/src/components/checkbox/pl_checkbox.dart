/// A single yes/no, or one member of a set of them.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// The mark is drawn at 70% of the box, so it never touches the corners.
const double _markFraction = 0.7;

/// A single yes/no, or one member of a set of them.
///
/// ```dart
/// PlCheckbox(
///   value: agreed,
///   onChanged: (bool next) => setState(() => agreed = next),
///   label: const Text('I agree'),
/// )
/// ```
///
/// Unchecked the tick is a small pane of clear glass with a hairline round it —
/// the same material a `glass` button is. Checked it fills with the family's
/// gradient, which is the one place this library expresses a state by swapping
/// the whole surface rather than shifting it a step: "on" and "off" are not two
/// strengths of the same thing.
///
/// [label], [description] and [error] are parameters rather than children for
/// the same reason they are on a text field: the arrangement is fixed, and what
/// a caller wants to decide is what goes in each slot.
class PlCheckbox extends StatelessWidget {
  /// Creates a checkbox.
  const PlCheckbox({
    required this.value,
    this.onChanged,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.indeterminate = false,
    this.readOnly = false,
    this.disabled = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// Whether the box is ticked.
  final bool value;

  /// Called with what the value should become.
  ///
  /// Leaving it `null` disables the checkbox, as it does everywhere else in
  /// Flutter. [disabled] says the same thing explicitly, for a checkbox whose
  /// callback is still wired up.
  final ValueChanged<bool>? onChanged;

  /// The tick's own ladder — 14 to 24px, sized against the label beside it
  /// rather than against the row it sits in.
  final PlassSize size;

  /// Semantic colour role.
  final PlassColor color;

  /// The text beside the tick. Pressing it toggles the box.
  final Widget? label;

  /// Helper text under the label.
  final Widget? description;

  /// Error message below. Its presence also turns the checkbox invalid.
  final Widget? error;

  /// Forces the invalid state without a message — for when an external form
  /// library owns the validity. Defaults to whether [error] was given.
  final bool? invalid;

  /// Neither on nor off: the state a "select all" takes when only some of the
  /// boxes under it are ticked. Drawn as a dash.
  final bool indeterminate;

  /// Inert but not dimmed — the value is still there to be read.
  final bool readOnly;

  /// Unavailable. The light goes out, exactly as it does on a button.
  final bool disabled;

  /// The name a screen reader announces, for a checkbox with no visible [label].
  final String? semanticLabel;

  /// Drive focus from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  bool get _disabled => disabled || onChanged == null;

  bool get _interactive => !_disabled && !readOnly;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final hasError = error != null;
    final isInvalid = invalid ?? hasError;
    // Invalid re-points the whole family at `danger`, so the tick, the ring and
    // the message all turn over together.
    final family = tokens.family(isInvalid ? PlassColor.danger : color);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final row = tickRowText[size]!;
    final box = tickSize[size]!;
    final radius = BorderRadius.circular(tickRadius[size]!);
    final marked = value || indeterminate;

    Widget tick(PlassInteraction state) {
      // No gloss line on a tick, and no tinted lift under it. A 1px white edge
      // reads as light on a cut edge at 40px and as a grey smudge at 18px; a
      // `0 6px 16px` shadow under an 18px box is a shadow bigger than the box.
      // The material stays — it is only the two decorations that go.
      //
      // The edge is the neutral hairline rather than the sheet's own white one:
      // white light on a translucent pane is invisible the moment the tick is
      // set on a light card rather than on the page wash, and a tick nobody can
      // see is a control nobody can find.
      Widget surface = AnimatedContainer(
        duration: reduceMotion ? Duration.zero : PlassTokens.duration,
        curve: PlassTokens.ease,
        decoration: BoxDecoration(
          borderRadius: radius,
          color: marked ? null : tokens.glass,
          gradient: marked ? family.fill : null,
          border: marked
              ? null
              : Border.all(
                  color: _interactive && state.hovered ? family.line : tokens.border,
                  width: hairline,
                ),
        ),
        child: Center(
          child: SizedBox.square(
            dimension: box * _markFraction,
            child: marked
                ? CustomPaint(
                    painter: _TickPainter(color: family.onSolid, dash: indeterminate),
                  )
                : null,
          ),
        ),
      );

      surface = SizedBox.square(dimension: box, child: surface);

      surface = plassStateFilter(
        child: surface,
        disabled: _disabled,
        readOnly: readOnly,
        hovered: state.hovered && marked,
        reduceMotion: reduceMotion,
        // A filled tick brightens under the pointer the way a filled key does;
        // an empty one answers with its hairline instead.
        lit: marked,
      );

      if (state.focusVisible) {
        surface = CustomPaint(
          foregroundPainter: PlassFocusRingPainter(color: family.ring, borderRadius: radius),
          child: surface,
        );
      }

      return surface;
    }

    Widget field = PlassInteractive(
      onTap: _interactive ? () => onChanged!(!value) : null,
      interactive: _interactive,
      enabled: !_disabled,
      focusNode: focusNode,
      autofocus: autofocus,
      cursor: _disabled
          ? SystemMouseCursors.forbidden
          : readOnly
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      builder: (BuildContext context, PlassInteraction state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: <Widget>[
            // A box the height of one line centres the tick on the *first* line
            // of the label rather than on the whole block, so it stays put when
            // the label wraps to three.
            SizedBox(
              height: row.line,
              child: Center(child: tick(state)),
            ),
            if (label != null || description != null)
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: <Widget>[
                    if (label != null)
                      DefaultTextStyle.merge(
                        style: TextStyle(color: _disabled ? tokens.mutedFg : tokens.fg),
                        child: label!,
                      ),
                    if (description != null)
                      DefaultTextStyle.merge(
                        style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                        child: description!,
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );

    field = DefaultTextStyle.merge(
      style: TextStyle(
        color: tokens.fg,
        fontSize: row.size,
        height: row.height,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      child: field,
    );

    if (hasError) {
      field = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: <Widget>[
          field,
          DefaultTextStyle.merge(
            style: TextStyle(color: family.accent, fontSize: metaText[size]!),
            child: error!,
          ),
        ],
      );
    }

    return MergeSemantics(
      child: Semantics(
        container: true,
        // `mixed` is set only when it is true: handing Flutter both a `checked`
        // and a `mixed` is two claims about one state, and the tree keeps
        // whichever it read last.
        checked: indeterminate ? null : value,
        mixed: indeterminate ? true : null,
        enabled: _interactive,
        label: semanticLabel,
        onTap: _interactive ? () => onChanged!(!value) : null,
        child: field,
      ),
    );
  }
}

/// The tick, or the dash that stands for "some of them".
///
/// Both are drawn in the same 12-unit box the React package's SVGs use, at the
/// same weight — a dash a quarter-point lighter than the tick beside it in a
/// tree of checkboxes reads as two controls.
class _TickPainter extends CustomPainter {
  const _TickPainter({required this.color, required this.dash});

  final Color color;
  final bool dash;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    if (dash) {
      path
        ..moveTo(2.5, 6)
        ..lineTo(9.5, 6);
    } else {
      path
        ..moveTo(2, 6.2)
        ..lineTo(4.6, 8.8)
        ..lineTo(10, 3.4);
    }

    canvas
      ..save()
      ..scale(size.shortestSide / 12)
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_TickPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.dash != dash;
  }
}
