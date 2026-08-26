/// A picture of a person or a thing, at a known size, that is never an empty
/// box.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// The crop, not the material.
enum PlAvatarShape {
  /// A round crop, and the default. What a portrait has been for as long as
  /// there have been portraits — an avatar is not a surface, it is a picture
  /// laid on one, so it does not owe the radius ladder anything.
  circle,

  /// The library's own fillet instead, which is what a logo or a repository
  /// icon wants: those are drawn to the edges of a rectangle and a round crop
  /// eats them.
  square,
}

/// The initials, sized off the box rather than off the row.
///
/// Its own ladder and not [controlText], because a control's label is measured
/// against the words next to it and this one is measured against the circle
/// around it: roughly 40% of the diameter at every step, which is where two
/// characters fill the width without touching the edge.
const Map<PlassSize, double> _initialsText = <PlassSize, double>{
  PlassSize.xs: 9,
  PlassSize.sm: 11,
  PlassSize.md: 13,
  PlassSize.lg: 16,
  PlassSize.xl: 19,
};

/// How much of the box a glyph handed to [PlAvatar.child] fills.
///
/// Sized off the box like the initials are rather than off the 1.2em an icon
/// riding on a label takes: it is drawn against the circle, not against a word.
const double _glyphFraction = 0.55;

/// A picture of a person or a thing, at a known size, that is never an empty
/// box.
///
/// ```dart
/// const PlAvatar(name: 'Ada Lovelace', image: NetworkImage('/ada.jpg'))
/// ```
///
/// Three things can be drawn in it and exactly one of them is at a time: the
/// picture, if [image] is given and it loads; otherwise whatever stands in for
/// it — [child], or [initials], or the initials derived from [name]; and failing
/// all of those, a silhouette.
///
/// The three materials are said the way a *control* says them: an avatar **is**
/// the thing being coloured — a portrait of one particular person — so its sheet
/// takes the tint, exactly as an alert's does and unlike a card's.
///
/// It carries no status dot of its own. An avatar with a green mark on it is a
/// [PlBadge] with an avatar in it, and inventing a second spelling for that
/// would give the library two of them.
class PlAvatar extends StatefulWidget {
  /// Creates an avatar.
  const PlAvatar({
    this.image,
    this.name,
    this.initials,
    this.semanticLabel,
    this.shape = PlAvatarShape.circle,
    this.variant = PlassVariant.ghost,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.elevation = 0,
    this.child,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The picture. Until it loads — and forever, if it fails — the fallback is
  /// what is drawn, so an avatar is never an empty box.
  ///
  /// An [ImageProvider] rather than a URL, because that is the shape every
  /// image in Flutter has: a `NetworkImage`, an `AssetImage`, a `MemoryImage`
  /// or a provider from a caching package all fit without the component having
  /// to know which.
  final ImageProvider<Object>? image;

  /// Who or what this is. One parameter doing three jobs: it names the picture,
  /// the initials are derived from it, and it is the sentence a screen reader
  /// hears instead of those initials.
  ///
  /// The initials are the first character of the first word plus the first
  /// character of the last — "Jane Doe" is `JD`, "홍길동" is `홍`. That rule is
  /// wrong for some names, which is what [initials] is for.
  final String? name;

  /// The initials, written out, for when the rule derived the wrong ones.
  final String? initials;

  /// What the picture says, for a reader who cannot see it.
  ///
  /// Falls back to [name], and to nothing at all when there is no name — an
  /// avatar next to the person's own name in a row is decoration, and reading it
  /// out says the name twice.
  final String? semanticLabel;

  /// The crop.
  final PlAvatarShape shape;

  /// What the sheet behind the fallback is made of. Invisible once a picture has
  /// loaded, apart from the edge it keeps.
  ///
  /// [PlassVariant.ghost] is the default: a directory is a page of avatars, and
  /// a page of saturated circles is a page nobody can read a name off.
  final PlassVariant variant;

  /// The box the picture is drawn in — the control heights, so an avatar and the
  /// button beside it in a toolbar are the same height.
  final PlassSize size;

  /// Semantic colour role.
  final PlassColor color;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` is the default: an avatar is a picture set into the page rather than a
  /// key resting on it.
  final PlassElevation elevation;

  /// The fallback, drawn instead of the initials. An icon, a logo, a single
  /// emoji — whatever stands in for this particular thing when there is no
  /// picture of it.
  final Widget? child;

  /// The first character of the first word, plus the first of the last.
  ///
  /// Split into runes rather than indexed, so a name that starts with an emoji
  /// or with any character outside the basic plane is not cut in half between
  /// its two code units.
  ///
  /// One word gives one character on purpose. Korean, Japanese and Chinese names
  /// are a single token, and two of their characters at 40px is a smudge where
  /// one is a name.
  static String initialsOf(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((String word) => word.isNotEmpty);

    if (words.isEmpty) {
      return '';
    }

    String head(String word) {
      final runes = word.runes;

      return runes.isEmpty ? '' : String.fromCharCode(runes.first);
    }

    final first = head(words.first);
    final last = words.length > 1 ? head(words.last) : '';

    return (first + last).toUpperCase();
  }

  @override
  State<PlAvatar> createState() => _PlAvatarState();
}

class _PlAvatarState extends State<PlAvatar> {
  /// Whether the picture has failed. Nothing else needs tracking: an [Image]
  /// with a `frameBuilder` reports its own arrival, and a picture that has not
  /// arrived is the same case as one that never will.
  bool _failed = false;

  @override
  void didUpdateWidget(PlAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.image != widget.image) {
      _failed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(widget.color);
    final box = controlHeight[widget.size]!;

    final derived = widget.name != null ? PlAvatar.initialsOf(widget.name!) : '';
    final standIn = widget.initials ?? (derived.isEmpty ? null : derived);
    final label = widget.semanticLabel ?? widget.name;

    // `child` beats the initials beats the silhouette. Only the last of the
    // three has nothing to say, which is what decides whether the fallback needs
    // the name spelled out beside it.
    final speaks = widget.child != null || standIn != null;

    final surface = markSurface(
      tokens,
      family,
      variant: widget.variant,
      elevation: widget.elevation,
    );

    final radius = widget.shape == PlAvatarShape.circle
        ? BorderRadius.circular(box)
        : BorderRadius.circular(PlassTokens.radius[widget.size]!);

    Widget fallback = DefaultTextStyle.merge(
      style: TextStyle(
        color: surface.ink,
        fontSize: _initialsText[widget.size]!,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        height: 1,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: surface.ink, size: box * _glyphFraction),
        child:
            widget.child ??
            (standIn != null
                ? Text(standIn)
                : _PersonMark(size: box * _glyphFraction, color: surface.ink)),
      ),
    );

    // "JD" read out loud is two letters, not a person. When there is a name it
    // becomes the accessible name and the initials are left as the picture they
    // are standing in for.
    if (label != null && speaks) {
      fallback = ExcludeSemantics(child: fallback);
    }

    final standInBox = Center(child: fallback);
    Widget content = standInBox;

    if (widget.image != null && !_failed) {
      content = Image(
        image: widget.image!,
        fit: BoxFit.cover,
        width: box,
        height: box,
        // Only ever named once, by the `Semantics` below.
        excludeFromSemantics: true,
        // A picture that is still arriving shows the fallback rather than a gap,
        // and one that never arrives shows it for good.
        frameBuilder:
            (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
              return frame == null && !wasSynchronouslyLoaded ? standInBox : child;
            },
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
          // Deferred, because `errorBuilder` runs during the build that
          // discovered the failure and `setState` inside one is an error.
          WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
            if (mounted && !_failed) {
              setState(() => _failed = true);
            }
          });

          return standInBox;
        },
      );
    }

    final avatar = SizedBox.square(
      dimension: box,
      child: PlassSurfaceBox(surface: surface, borderRadius: radius, child: content),
    );

    return Semantics(
      label: label,
      image: widget.image != null,
      container: label != null,
      child: avatar,
    );
  }
}

/// A shoulders-and-head silhouette, drawn here rather than in
/// `internal/icons.dart` because this is the only component that needs it.
///
/// It exists so that a `PlAvatar` with nothing at all is still an avatar. A box
/// with no picture, no name and no glyph in it is indistinguishable from a
/// component that failed to render.
class _PersonMark extends StatelessWidget {
  const _PersonMark({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _PersonPainter(color));
  }
}

class _PersonPainter extends CustomPainter {
  const _PersonPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 24;
    final paint = Paint()..color = color;

    canvas
      ..save()
      ..scale(scale)
      ..drawCircle(const Offset(12, 7.5), 4.5, paint)
      ..drawPath(
        Path()
          ..moveTo(12, 14.25)
          ..cubicTo(7.72, 14.25, 4.25, 16.67, 4.25, 19.65)
          ..cubicTo(4.25, 20.4, 4.85, 21, 5.6, 21)
          ..lineTo(18.4, 21)
          ..cubicTo(19.15, 21, 19.75, 20.4, 19.75, 19.65)
          ..cubicTo(19.75, 16.67, 16.28, 14.25, 12, 14.25)
          ..close(),
        paint,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_PersonPainter oldDelegate) => oldDelegate.color != color;
}
