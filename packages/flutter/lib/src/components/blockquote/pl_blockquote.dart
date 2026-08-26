/// Somebody else's words, set apart from your own.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// The quote itself, one step above body copy with the leading opened up.
///
/// The sizes are [sheetTitle]'s, because a quote is set at a heading's scale —
/// but the leading is not: a title is a line or two and a quote is a paragraph
/// somebody has to read, so it gets the air a paragraph needs.
const Map<PlassSize, PlassTextScale> _quoteText = <PlassSize, PlassTextScale>{
  PlassSize.xs: PlassTextScale(12, 20),
  PlassSize.sm: PlassTextScale(13, 22),
  PlassSize.md: PlassTextScale(15, 26),
  PlassSize.lg: PlassTextScale(17, 30),
  PlassSize.xl: PlassTextScale(20, 34),
};

/// How thick the rule down the leading edge is.
///
/// The one number here that does not come off a ladder: a quote rule is 2px at
/// every size, because it is a mark in the margin rather than a part of the
/// type.
const double _ruleWidth = 2;

/// Somebody else's words, set apart from your own.
///
/// ```dart
/// const PlBlockquote(
///   author: Text('Dieter Rams'),
///   child: Text('Good design is as little design as possible.'),
/// )
/// ```
///
/// The three materials say what they say everywhere else, and the sheet is never
/// dyed — exactly as on a card. A quote holds somebody else's words, and
/// words on a tinted pane are words on a background nobody chose them against.
/// The family reaches the rule and stops.
///
/// [PlassVariant.ghost] is the default and the one that belongs in running
/// prose: a rule in the margin and nothing else, which is what a quote has
/// looked like since long before there were surfaces to put one on.
class PlBlockquote extends StatelessWidget {
  /// Creates a quote.
  const PlBlockquote({
    this.child,
    this.variant = PlassVariant.ghost,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.elevation = 0,
    this.author,
    this.source,
    this.icon,
    this.showIcon = true,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// What was said.
  final Widget? child;

  /// What the surface is made of. See [PlassVariant].
  final PlassVariant variant;

  /// Type scale and padding.
  final PlassSize size;

  /// Semantic colour role. It reaches the rule and the quotation mark.
  final PlassColor color;

  /// How tightly the quote packs its content.
  final PlassDensity density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` is the default — a quote is set *into* a page rather than floating over
  /// it, so it is raised even less often than a card.
  final PlassElevation elevation;

  /// Who said it. Rendered under the quote, after an em dash.
  ///
  /// An attribution is *about* the quote and is not part of what was said, which
  /// is why it sits outside it rather than in it.
  final Widget? author;

  /// Where it is from — a book, a talk, a page.
  final Widget? source;

  /// The mark drawn before the quote. Left out, the house glyph is used.
  final Widget? icon;

  /// Whether a mark is drawn at all.
  ///
  /// The pair says what React says with one three-way prop; Dart has no value
  /// that is neither `null` nor a widget, so "take it away" gets its own name.
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final quote = _quoteText[size]!;
    final attributed = author != null || source != null;

    final surface = sheetSurface(tokens, variant: variant, elevation: elevation);

    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showIcon)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: IconTheme.merge(
              // The mark tracks the quote's own type scale at twice its size, so
              // one drawing is the right size at every step of the ladder.
              data: IconThemeData(size: quote.size * 2, color: family.softPress),
              child: icon ?? _QuoteMark(size: quote.size * 2, color: family.softPress),
            ),
          ),
        if (child != null)
          DefaultTextStyle.merge(
            style: TextStyle(
              color: tokens.fg,
              fontSize: quote.size,
              height: quote.height,
              leadingDistribution: TextLeadingDistribution.even,
            ),
            child: child!,
          ),
        if (attributed)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!, height: 1.4),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: <Widget>[
                  if (author != null)
                    DefaultTextStyle.merge(
                      style: TextStyle(color: tokens.fg, fontWeight: FontWeight.w500),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // An em dash, the way an attribution has been set since
                          // print, and excluded from semantics because a screen
                          // reader announcing "em dash" before a name is reading
                          // the typography rather than the text.
                          const ExcludeSemantics(child: Text('— ')),
                          Flexible(child: author!),
                        ],
                      ),
                    ),
                  ?source,
                ],
              ),
            ),
          ),
      ],
    );

    body = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sheetPaddingX[density]![size]!,
        vertical: sheetPaddingY[density]![size]!,
      ),
      child: body,
    );

    // The corners on the ruled edge stay square: a 2px rule that curves away
    // from the text it marks is a bracket, not a margin rule.
    final radius = variant == PlassVariant.ghost
        ? BorderRadius.zero
        : BorderRadiusDirectional.horizontal(
            end: Radius.circular(PlassTokens.radius[size]!),
          ).resolve(Directionality.of(context));

    return Semantics(
      container: true,
      child: Stack(
        children: <Widget>[
          PlassSurfaceBox(surface: surface, borderRadius: radius, child: body),
          // The rule belongs on the side the text starts on, which is the right
          // edge under RTL — so it is positioned directionally rather than left.
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: _ruleWidth,
              child: DecoratedBox(decoration: BoxDecoration(color: family.accent)),
            ),
          ),
        ],
      ),
    );
  }
}

/// The quotation mark: a pair of commas turned up, drawn rather than typed.
///
/// A real `“` would be set in whatever face the page uses and would change
/// shape, weight and baseline with it — and at 2em it is the largest single
/// glyph in the component, so it changing is the most visible thing that could.
/// This is one drawing at one weight, and it lives here rather than in
/// `internal/icons.dart` because exactly one component draws it.
class _QuoteMark extends StatelessWidget {
  const _QuoteMark({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _QuoteMarkPainter(color));
  }
}

class _QuoteMarkPainter extends CustomPainter {
  const _QuoteMarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 16;
    final path = Path();

    // The same two commas the React package's SVG draws, at the same
    // coordinates in the same 16-unit box.
    for (final dx in const <double>[0, 6.9]) {
      path
        ..moveTo(6.4 + dx, 3.6)
        ..cubicTo(4.1 + dx, 4.5, 2.7 + dx, 6.4, 2.7 + dx, 8.7)
        ..cubicTo(2.7 + dx, 10.7, 3.9 + dx, 12, 5.5 + dx, 12)
        ..cubicTo(6.9 + dx, 12, 8 + dx, 11, 8 + dx, 9.6)
        ..cubicTo(8 + dx, 8.3, 7.1 + dx, 7.4, 5.9 + dx, 7.4)
        ..cubicTo(5.7 + dx, 7.4, 5.5 + dx, 7.4, 5.3 + dx, 7.5)
        ..cubicTo(5.6 + dx, 6.5, 6.4 + dx, 5.7, 7.5 + dx, 5.2)
        ..close();
    }

    canvas
      ..save()
      ..scale(scale)
      ..drawPath(path, Paint()..color = color)
      ..restore();
  }

  @override
  bool shouldRepaint(_QuoteMarkPainter oldDelegate) => oldDelegate.color != color;
}
