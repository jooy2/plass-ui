/// A rule between two things.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// Space between the label and the line on either side of it.
const Map<PlassSize, double> _labelGap = <PlassSize, double>{
  PlassSize.xs: 6,
  PlassSize.sm: 8,
  PlassSize.md: 12,
  PlassSize.lg: 14,
  PlassSize.xl: 16,
};

/// The short side of an off-centre label: a fixed stub rather than a small flex
/// ratio, so the label sits the same distance from the edge whatever the
/// divider's length turns out to be.
const double _stub = 16;

/// A rule between two things.
///
/// ```dart
/// const PlDivider()
/// const PlDivider(child: Text('OR'))
/// ```
///
/// With no [child] it is a hairline and nothing else. With one the line breaks
/// around the label.
///
/// There is no `variant` and no `elevation`, because a divider is not a surface.
/// It is not made of glass, catches no light and casts no shadow — it is the
/// absence of a surface, drawn.
class PlDivider extends StatelessWidget {
  /// Creates a rule.
  const PlDivider({
    this.orientation = PlassOrientation.horizontal,
    this.color,
    this.size = PlassSize.md,
    this.length,
    this.thickness = hairline,
    this.textAlign = PlassAlign.center,
    this.child,
    this.semanticLabel,
    super.key,
  });

  /// Which way the line runs.
  ///
  /// A vertical divider has no height of its own — it stretches to whatever
  /// gives it one, which is what a rule between two toolbar groups should do.
  final PlassOrientation orientation;

  /// Semantic colour role, and — like a text link's — it has **no default**.
  ///
  /// Left out, the rule is the neutral hairline, which is the one that is
  /// visible on every ground the library has: a page wash, a glass sheet, a
  /// card. The sheet's own white hairline is white light on a translucent pane
  /// and disappears the moment a divider is set on something opaque, which is
  /// the same reason a checkbox's edge is drawn in the neutral one.
  ///
  /// Passing a family tints the rule instead, at the strength a hairline takes
  /// everywhere else in the library.
  final PlassColor? color;

  /// Type scale of the label. Nothing else on a divider has a size.
  final PlassSize size;

  /// How far the rule runs — the width of a horizontal divider, the height of a
  /// vertical one.
  ///
  /// `length` rather than `width`, because a divider is the one component whose
  /// long axis turns with [orientation]: a `width` that meant height half the
  /// time would be a worse name than a longer one.
  ///
  /// Left out, a horizontal divider is as wide as it is allowed to be and a
  /// vertical one is as tall — which means a vertical divider needs something
  /// above it that has decided on a height. In a [Row] that is usually an
  /// [IntrinsicHeight] or a [SizedBox]; [length] is the other answer.
  final double? length;

  /// How thick the rule is.
  final double thickness;

  /// Where the label sits.
  ///
  /// [PlassAlign.center] splits the line in half; the other two leave a short
  /// stub on the near side, so the label still reads as set *into* the rule
  /// rather than floating above it. Ignored without a [child].
  final PlassAlign textAlign;

  /// A label set into the line — "OR" between two sign-in options.
  final Widget? child;

  /// What a screen reader calls the divider.
  ///
  /// A separator is not named by its own content, so a visible label does not
  /// become the accessible name on its own — a screen reader would announce a
  /// bare "separator" and read the word "OR" as loose text somewhere nearby.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final vertical = orientation == PlassOrientation.vertical;
    final rule = color != null ? tokens.family(color!).line : tokens.border;

    Widget divider = child == null
        ? _line(rule, vertical: vertical)
        : _labelled(context, tokens.mutedFg, rule, vertical: vertical);

    if (length != null) {
      // Inside an `Align`, which passes loose constraints down: a divider very
      // often sits in a `Column` with `crossAxisAlignment: stretch`, and there a
      // bare `SizedBox` would be handed a tight width and lose. `length` is the
      // caller saying how far the rule runs, and it should win.
      divider = Align(
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox(
          width: vertical ? null : length,
          height: vertical ? length : null,
          child: divider,
        ),
      );
    }

    return Semantics(
      label: semanticLabel,
      // Flutter has no `role="separator"`, and the nearest honest thing is to
      // say the divider is decoration unless it was given a name — which is
      // what an unnamed rule is.
      container: semanticLabel != null,
      child: divider,
    );
  }

  /// The hairline: a box with no thickness on its long axis, so a divider never
  /// adds a pixel of layout beyond the rule itself.
  Widget _line(Color rule, {required bool vertical}) {
    return DecoratedBox(
      decoration: BoxDecoration(color: rule),
      child: SizedBox(
        width: vertical ? thickness : double.infinity,
        height: vertical ? double.infinity : thickness,
      ),
    );
  }

  Widget _labelled(BuildContext context, Color ink, Color rule, {required bool vertical}) {
    final leadingStub = textAlign == PlassAlign.start;
    final trailingStub = textAlign == PlassAlign.end;

    Widget stub(bool fixed) {
      final edge = _line(rule, vertical: vertical);

      return fixed
          ? SizedBox(width: vertical ? null : _stub, height: vertical ? _stub : null, child: edge)
          : Expanded(child: edge);
    }

    final label = DefaultTextStyle.merge(
      style: TextStyle(color: ink, fontSize: metaText[size]!, height: 1),
      maxLines: 1,
      softWrap: false,
      child: child!,
    );

    final parts = <Widget>[
      stub(leadingStub),
      // A vertical rule's label has to turn with it, or the line grows to the
      // width of the word and stops being a hairline.
      vertical ? RotatedBox(quarterTurns: 1, child: label) : label,
      stub(trailingStub),
    ];

    return vertical
        ? Column(
            mainAxisSize: length == null ? MainAxisSize.max : MainAxisSize.min,
            spacing: _labelGap[size]!,
            children: parts,
          )
        : Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: _labelGap[size]!,
            children: parts,
          );
  }
}
