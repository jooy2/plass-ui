/// Text at one of the library's sizes.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// What a piece of text *is*, which decides both its type scale and whether it
/// enters the document outline.
///
/// Deliberately not called `variant`. In this library `variant` names what a
/// surface is made of, and a second meaning for the same word is exactly what
/// the prop conventions forbid.
enum PlTypographyLevel {
  /// The page's title. 30px on a 36px line.
  h1,

  /// 24px on 30.
  h2,

  /// 20px on 26.
  h3,

  /// 17px on 24.
  h4,

  /// 15px on 22.
  h5,

  /// 13px on 20 — the same size as [body], and separated from it by weight.
  h6,

  /// A standfirst. 17px on a 28px line, at the body's weight.
  lead,

  /// The default, and the ladder everything else is measured against. 13px on a
  /// 22px line — the same as a sheet's body at `md`, so a paragraph inside a
  /// card and a standalone one are the same text.
  body,

  /// A note under something. Muted by default.
  caption,

  /// A label above something: small, letterspaced and upper case. Muted by
  /// default.
  overline,
}

/// How heavy the type is drawn.
///
/// A [PlTypographyLevel] picks one of these; naming one overrides it.
enum PlTypographyWeight {
  /// 400.
  regular,

  /// 500.
  medium,

  /// 600, and what every heading takes.
  semibold,

  /// 700.
  bold,
}

/// One step of the ladder: a size, a line box, and how far the letters are set
/// apart.
@immutable
class _Level {
  const _Level(this.size, this.line, {this.tracking = 0, this.upperCase = false});

  final double size;
  final double line;

  /// In `em`, as the stylesheet writes it. Multiplied out per step below.
  final double tracking;

  final bool upperCase;
}

/// The scale.
///
/// The headings step up from [PlTypographyLevel.body] by roughly a major third,
/// and the leading tightens as they grow — a 30px line does not want the 1.7
/// ratio a 13px one does. Tracking goes the other way for the same reason: type
/// set large needs pulling in, and type set small and quiet needs opening out.
const Map<PlTypographyLevel, _Level> _levels = <PlTypographyLevel, _Level>{
  PlTypographyLevel.h1: _Level(30, 36, tracking: -0.02),
  PlTypographyLevel.h2: _Level(24, 30, tracking: -0.015),
  PlTypographyLevel.h3: _Level(20, 26, tracking: -0.01),
  PlTypographyLevel.h4: _Level(17, 24),
  PlTypographyLevel.h5: _Level(15, 22),
  PlTypographyLevel.h6: _Level(13, 20),
  PlTypographyLevel.lead: _Level(17, 28),
  PlTypographyLevel.body: _Level(13, 22),
  PlTypographyLevel.caption: _Level(12, 18),
  PlTypographyLevel.overline: _Level(11, 16, tracking: 0.08, upperCase: true),
};

/// The weight a level takes when none is asked for.
const Map<PlTypographyLevel, PlTypographyWeight> _levelWeights =
    <PlTypographyLevel, PlTypographyWeight>{
      PlTypographyLevel.h1: PlTypographyWeight.semibold,
      PlTypographyLevel.h2: PlTypographyWeight.semibold,
      PlTypographyLevel.h3: PlTypographyWeight.semibold,
      PlTypographyLevel.h4: PlTypographyWeight.semibold,
      PlTypographyLevel.h5: PlTypographyWeight.semibold,
      PlTypographyLevel.h6: PlTypographyWeight.semibold,
      PlTypographyLevel.lead: PlTypographyWeight.regular,
      PlTypographyLevel.body: PlTypographyWeight.regular,
      PlTypographyLevel.caption: PlTypographyWeight.regular,
      PlTypographyLevel.overline: PlTypographyWeight.medium,
    };

const Map<PlTypographyWeight, FontWeight> _weights = <PlTypographyWeight, FontWeight>{
  PlTypographyWeight.regular: FontWeight.w400,
  PlTypographyWeight.medium: FontWeight.w500,
  PlTypographyWeight.semibold: FontWeight.w600,
  PlTypographyWeight.bold: FontWeight.w700,
};

/// How much room a level leaves under itself when `gutter` is on.
const Map<PlTypographyLevel, double> _gutters = <PlTypographyLevel, double>{
  PlTypographyLevel.h1: 16,
  PlTypographyLevel.h2: 14,
  PlTypographyLevel.h3: 12,
  PlTypographyLevel.h4: 10,
  PlTypographyLevel.h5: 8,
  PlTypographyLevel.h6: 8,
  PlTypographyLevel.lead: 16,
  PlTypographyLevel.body: 12,
  PlTypographyLevel.caption: 8,
  PlTypographyLevel.overline: 8,
};

/// The two quiet levels. Everything else takes the page's own foreground — a
/// heading that arrived pre-greyed is a heading a designer has to undo.
const Set<PlTypographyLevel> _muted = <PlTypographyLevel>{
  PlTypographyLevel.caption,
  PlTypographyLevel.overline,
};

/// The headings, which are the levels that enter the document outline.
const Set<PlTypographyLevel> _headings = <PlTypographyLevel>{
  PlTypographyLevel.h1,
  PlTypographyLevel.h2,
  PlTypographyLevel.h3,
  PlTypographyLevel.h4,
  PlTypographyLevel.h5,
  PlTypographyLevel.h6,
};

/// Text at one of the library's sizes.
///
/// The type scale is the one thing in a design system that everything else is
/// measured against, and it would otherwise exist only inside the components
/// that happen to need it — a card's title, a field's label. This is that ladder
/// on its own, so a page can use it without wrapping its prose in a card.
///
/// ```dart
/// const PlTypography('Settings', level: PlTypographyLevel.h2)
/// ```
///
/// There is no `variant`, no `elevation` and no `size`. [level] **is** the size:
/// a `size` alongside it would let a caller ask for an `h1` at `xs`, which is a
/// heading that is not a heading.
///
/// The font is the host app's. Neither package ships one, and a heading at
/// [PlTypographyWeight.semibold] needs a family that has a real 600 — see the
/// note on the documentation site.
class PlTypography extends StatelessWidget {
  /// Creates a run of text.
  const PlTypography(
    String this.data, {
    this.level = PlTypographyLevel.body,
    this.color,
    this.weight,
    this.align,
    this.lines,
    this.gutter = false,
    this.semanticsLabel,
    super.key,
  }) : textSpan = null;

  /// Creates a run of text out of spans, for text that changes style part of the
  /// way through.
  ///
  /// [PlTypographyLevel.overline] does not upper-case a rich span the way it
  /// upper-cases a string: Flutter has no `text-transform`, so the one case that
  /// can be handled is the one where the library owns the characters.
  const PlTypography.rich(
    InlineSpan this.textSpan, {
    this.level = PlTypographyLevel.body,
    this.color,
    this.weight,
    this.align,
    this.lines,
    this.gutter = false,
    this.semanticsLabel,
    super.key,
  }) : data = null;

  /// The text. Null on [PlTypography.rich].
  final String? data;

  /// The spans. Null on the default constructor.
  final InlineSpan? textSpan;

  /// The type scale, and whether this is a heading.
  final PlTypographyLevel level;

  /// Semantic colour role. Unlike every other component this has **no default**:
  /// text inherits whatever colour it is sitting in unless a role is asked for,
  /// because the common case for a paragraph is to look like the paragraphs
  /// around it.
  final PlassColor? color;

  /// Overrides the weight the level would otherwise pick.
  final PlTypographyWeight? weight;

  /// Which edge the text is set against. Left out, it takes whatever the
  /// surrounding [DefaultTextStyle] asked for.
  final TextAlign? align;

  /// Clamps the text to this many lines with an ellipsis. `1` is a single-line
  /// truncation. Omit it and the text wraps as far as it needs to.
  final int? lines;

  /// Adds the space below that a run of prose expects.
  ///
  /// Off by default: a library component that injects margins is one a layout
  /// has to fight.
  final bool gutter;

  /// What a screen reader reads instead of the text — for a line whose
  /// characters are not the words, such as a truncated one.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final step = _levels[level]!;

    final ink = color != null
        ? tokens.family(color!).accent
        : _muted.contains(level)
        ? tokens.mutedFg
        : tokens.fg;

    final style = TextStyle(
      color: ink,
      fontSize: step.size,
      height: step.line / step.size,
      fontWeight: _weights[weight ?? _levelWeights[level]!],
      letterSpacing: step.tracking == 0 ? null : step.tracking * step.size,
      // CSS splits a line box's leading evenly above and below the text.
      // Flutter's default hands it out in proportion to the font's ascent and
      // descent instead, which pushes every line off its baseline by a pixel or
      // two — visible the moment two levels are stacked.
      leadingDistribution: TextLeadingDistribution.even,
    );

    Widget text = data != null
        ? Text(
            step.upperCase ? data!.toUpperCase() : data!,
            style: style,
            textAlign: align,
            maxLines: lines,
            overflow: lines != null ? TextOverflow.ellipsis : null,
            semanticsLabel: semanticsLabel,
          )
        : Text.rich(
            textSpan!,
            style: style,
            textAlign: align,
            maxLines: lines,
            overflow: lines != null ? TextOverflow.ellipsis : null,
            semanticsLabel: semanticsLabel,
          );

    if (_headings.contains(level)) {
      // What `<h1>`–`<h6>` buy on the web: a screen reader can list the
      // headings on a screen and jump between them. Flutter's accessibility
      // tree has one flag for it rather than six levels, so the level itself
      // does not carry across — which is why the page says so.
      text = Semantics(header: true, child: text);
    }

    if (gutter) {
      text = Padding(
        padding: EdgeInsets.only(bottom: _gutters[level]!),
        child: text,
      );
    }

    return text;
  }
}
