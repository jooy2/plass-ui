/// Marks the words a reader is looking for, inside text they were already
/// reading.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/typography/pl_typography.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// Letters, digits and underscores in any script — what [PlHighlight.wholeWord]
/// counts as part of a word.
final RegExp _wordCharacter = RegExp(r'[\p{L}\p{N}_]', unicode: true);

/// The corner a mark takes. Well below the control ladder: a mark is a 20px-tall
/// box sitting on a line of text, and a 12px radius on one is a capsule.
const double _markRadius = 4;

/// A hair of room between the surface and the letters on it.
const double _markPadding = 2;

/// Marks the words a reader is looking for, inside text they were already
/// reading.
///
/// ```dart
/// PlHighlight('The quick brown fox', query: 'quick')
/// ```
///
/// The component is the search, not just the styling: [query] is what a search
/// box holds, and everything about *how* the matching is done — case, whole
/// words, a regular expression — is a parameter rather than something a caller
/// has to pre-compute into a list of offsets.
///
/// Marking eleven words in a paragraph tells a screen reader that eleven things
/// are important, which is a way of saying nothing. A highlight is for a handful
/// of matches.
///
/// Nothing here is stateful and nothing measures — the whole widget is a pure
/// function of [text] and [query], so it re-marks on its own the moment the
/// search box changes.
class PlHighlight extends StatelessWidget {
  /// Creates a marked run of text.
  const PlHighlight(
    this.text, {
    required this.query,
    this.variant = PlassVariant.solid,
    this.color,
    this.caseSensitive = false,
    this.wholeWord = false,
    this.underline = false,
    this.weight,
    this.style,
    this.align,
    this.lines,
    super.key,
  }) : assert(
         query is Pattern || query is List<Pattern>,
         'query must be a String, a RegExp, or a List of either',
       );

  /// The text to search.
  final String text;

  /// What to find: a [String], a [RegExp], or a [List] of either.
  ///
  /// Several terms are tried longest first, so `['data', 'database']` marks the
  /// whole word rather than the first four letters of it — alternation is
  /// first-match-wins, and without the sort `base` would fall outside the mark.
  ///
  /// A [RegExp] is used as written; [caseSensitive] and [wholeWord] are ignored
  /// for one, because a regular expression already says both of those things
  /// itself.
  ///
  /// Typed as [Object] rather than as a union, which Dart does not have. The
  /// assert in the constructor is the union.
  final Object query;

  /// What the mark is made of.
  ///
  /// - [PlassVariant.solid] — the family's gradient with its own ink on it: the
  ///   highlighter pen. The default.
  /// - [PlassVariant.glass] — a hairline box with the family's soft tint inside
  ///   it, for a page where a filled run would be too much.
  /// - [PlassVariant.ghost] — the accent colour and nothing else, for marking a
  ///   word inside a heading that is already loud.
  ///
  /// `glass` is deliberately **not** blurred here, which is the one place in the
  /// library the material is quoted rather than used. A mark is a 20px-tall box
  /// sitting on a line of text; there is no backdrop behind it worth smearing.
  final PlassVariant variant;

  /// Semantic colour role.
  ///
  /// [PlassColor.warning] by default, and not arbitrarily: it is the one family
  /// whose gradient is light with dark ink on it, so a `solid` `warning` mark is
  /// a yellow highlighter over black text rather than a white word on a block of
  /// colour.
  final PlassColor? color;

  /// Whether `a` and `A` are different letters.
  final bool caseSensitive;

  /// Whether a term has to be a word on its own — `cat` marking "cat" but not
  /// "concatenate".
  ///
  /// A word here is a run of letters, digits and underscores in any script, so
  /// it means what it should for `café` and `naïve`. It means very little for
  /// Korean or Japanese, where a phrase is not delimited by spaces at all; that
  /// is a property of the writing system rather than of this parameter, and is
  /// the reason it is off by default.
  final bool wholeWord;

  /// Underlines the mark as well. Combines with every variant.
  final bool underline;

  /// Sets the mark's weight.
  ///
  /// Omit it and the mark is the weight of the text around it — the surface is
  /// already saying "this one", and a bolded word inside a sentence changes the
  /// rhythm of the whole line.
  final PlTypographyWeight? weight;

  /// The style the unmarked text is set in. Merged onto whatever the surrounding
  /// [DefaultTextStyle] asked for.
  ///
  /// There is no `size` here on purpose, and it is the one thing a reader will
  /// look for. A mark sits inside running text and has to be the size of the
  /// text it is inside; a `size` would only offer ways to be wrong.
  final TextStyle? style;

  /// Which edge the text is set against.
  final TextAlign? align;

  /// Clamps the text to this many lines with an ellipsis.
  final int? lines;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.warning;

    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final base = DefaultTextStyle.of(context).style.merge(style);
    final pattern = _pattern;

    return Text.rich(
      TextSpan(
        style: style,
        children: pattern == null
            ? <InlineSpan>[TextSpan(text: text)]
            : _mark(pattern, base, family, tokens),
      ),
      textAlign: align,
      maxLines: lines,
      overflow: lines != null ? TextOverflow.ellipsis : null,
      // The marks are widgets, so their characters would otherwise reach a
      // screen reader as a sequence of placeholders with the plain runs between
      // them. The whole string, said once, is what was being read.
      semanticsLabel: text,
    );
  }

  /// One expression, or `null` when there is nothing to look for — an empty
  /// search box should leave the text exactly as it was, not mark every
  /// character in it.
  RegExp? get _pattern {
    final raw = query;

    if (raw is RegExp) {
      return raw;
    }

    final terms = <String>[
      for (final term in raw is List<Pattern> ? raw : <Object>[raw])
        if (term is RegExp) term.pattern else (term as String).trim(),
    ]..removeWhere((String term) => term.isEmpty);

    if (terms.isEmpty) {
      return null;
    }

    // Longest first, because alternation is first-match-wins.
    terms.sort((String a, String b) => b.length.compareTo(a.length));

    return RegExp(terms.map(RegExp.escape).join('|'), caseSensitive: caseSensitive, unicode: true);
  }

  /// Splits the text into plain runs and marked ones.
  List<InlineSpan> _mark(
    RegExp pattern,
    TextStyle base,
    PlassColorFamily family,
    PlassTokens tokens,
  ) {
    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final match in pattern.allMatches(text)) {
      // A pattern that can match nothing — `x*` — has nothing to mark.
      if (match.end == match.start) {
        continue;
      }

      if (wholeWord && !_isWholeWord(match.start, match.end)) {
        continue;
      }

      // `allMatches` can hand back a match inside a run already consumed by a
      // longer one only if the caller's own expression overlaps; skipping keeps
      // the output in order either way.
      if (match.start < cursor) {
        continue;
      }

      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }

      spans.add(_markSpan(match.group(0)!, base, family, tokens));
      cursor = match.end;
    }

    if (spans.isEmpty) {
      return <InlineSpan>[TextSpan(text: text)];
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return spans;
  }

  /// Whether a match is a word on its own.
  bool _isWholeWord(int start, int end) {
    final before = start > 0 ? text[start - 1] : '';
    final after = end < text.length ? text[end] : '';

    return !_wordCharacter.hasMatch(before) && !_wordCharacter.hasMatch(after);
  }

  /// One mark.
  ///
  /// A [WidgetSpan] rather than a [TextSpan] with a background, because a
  /// background is one flat colour with square corners and the mark is a
  /// surface: a gradient on `solid`, a hairline on `glass`, a fillet on both.
  /// The cost is that a marked phrase does not break across lines, which the
  /// page says.
  InlineSpan _markSpan(
    String matched,
    TextStyle base,
    PlassColorFamily family,
    PlassTokens tokens,
  ) {
    final ink = variant == PlassVariant.solid ? family.onSolid : family.accent;

    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_markRadius),
          gradient: variant == PlassVariant.solid ? family.fill : null,
          color: variant == PlassVariant.glass ? family.soft : null,
          border: variant == PlassVariant.glass
              ? Border.all(color: family.line, width: hairline)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _markPadding),
          child: Text(
            matched,
            style: base.copyWith(
              color: ink,
              fontWeight: weight != null ? _weights[weight!] : null,
              decoration: underline ? TextDecoration.underline : null,
              // Under the descenders rather than through them, which is the
              // whole difference between an underline and a strikethrough that
              // missed.
              decorationThickness: underline ? 2 : null,
              decorationColor: underline ? ink : null,
            ),
          ),
        ),
      ),
    );
  }

  static const Map<PlTypographyWeight, FontWeight> _weights = <PlTypographyWeight, FontWeight>{
    PlTypographyWeight.regular: FontWeight.w400,
    PlTypographyWeight.medium: FontWeight.w500,
    PlTypographyWeight.semibold: FontWeight.w600,
    PlTypographyWeight.bold: FontWeight.w700,
  };
}
