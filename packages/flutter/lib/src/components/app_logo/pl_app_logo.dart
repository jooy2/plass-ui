/// A product's mark, and its name beside it.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How the artwork is framed, which is the one question this widget exists to
/// answer.
enum PlAppLogoShape {
  /// Drawn as it was given, at the height [PlAppLogo.size] asks for and whatever
  /// width that comes to. No plate, no crop, no padding.
  ///
  /// The default, and the only one that is correct for a mark drawn with its own
  /// background, its own margin, or the product's name set into it.
  bare,

  /// An app icon: a tile with the artwork inset in it and the corners cut to the
  /// house radius. What a mark drawn as a bare glyph needs before it can sit
  /// next to anything else.
  plate,

  /// The same tile, round. For the products whose icon is a disc.
  circle,
}

/// The mark's height. `md` is 32, which sits inside a `md` header's 64 floor
/// with room either side rather than filling it.
const Map<PlassSize, double> _markHeight = <PlassSize, double>{
  PlassSize.xs: 20,
  PlassSize.sm: 24,
  PlassSize.md: 32,
  PlassSize.lg: 40,
  PlassSize.xl: 48,
};

/// The name beside it: a wordmark, so heavier and larger than a label.
const Map<PlassSize, double> _nameSize = <PlassSize, double>{
  PlassSize.xs: 14,
  PlassSize.sm: 16,
  PlassSize.md: 18,
  PlassSize.lg: 20,
  PlassSize.xl: 24,
};

/// The gap between the mark and the words.
const Map<PlassSize, double> _gap = <PlassSize, double>{
  PlassSize.xs: 6,
  PlassSize.sm: 8,
  PlassSize.md: 10,
  PlassSize.lg: 12,
  PlassSize.xl: 14,
};

/// How much of a plate the artwork takes.
const double _inset = 0.7;

/// A product's mark, and its name beside it.
///
/// ```dart
/// PlAppLogo(
///   name: const Text('Acme'),
///   description: const Text('Staging'),
///   child: const AcmeGlyph(),
/// )
/// ```
///
/// The whole widget is the **framing**, which is the one thing a logo needs and
/// the one thing every project gets wrong twice. [PlAppLogoShape.bare] is the
/// default because a mark drawn with its own background, its own margin, or the
/// product's name set into it must not be put on a plate or cropped to a circle.
/// The other two are for a mark drawn as a bare glyph, which cannot sit next to
/// anything else until it has been given an edge.
///
/// It is not a [PlAvatar]. An avatar is a picture of a person or a thing and is
/// always a circle or a fillet, with initials behind it when the picture fails;
/// a logo is artwork the product owns, it has no fallback worth inventing, and
/// its shape is a decision somebody already made.
///
/// **With a [name], the mark is decorative.** The wordmark beside it already
/// says what the product is called, and artwork that says it again is a screen
/// reader reading the name twice.
class PlAppLogo extends StatelessWidget {
  /// Creates a logo.
  const PlAppLogo({
    required this.child,
    this.semanticLabel,
    this.name,
    this.description,
    this.shape = PlAppLogoShape.bare,
    this.variant = PlassVariant.solid,
    this.onPressed,
    this.size,
    this.color,
    super.key,
  });

  /// The mark. Whatever the product's artwork actually is.
  final Widget child;

  /// What the mark says, for a reader who cannot see it.
  ///
  /// Leave it out when [name] is set: the wordmark beside the mark already says
  /// the product's name.
  final String? semanticLabel;

  /// The product's name, set beside the mark.
  final Widget? name;

  /// A line under the name — an environment, a tenant, a plan.
  final Widget? description;

  /// How the artwork is framed.
  final PlAppLogoShape shape;

  /// What the plate is made of. Only read when [shape] is not
  /// [PlAppLogoShape.bare].
  final PlassVariant variant;

  /// Makes the logo the way back to the front screen, which is nearly always
  /// what it is. Leaving it `null` draws the same logo and presses nothing.
  final VoidCallback? onPressed;

  /// The height of the mark, and the type scale of the name beside it.
  final PlassSize? size;

  /// The family the plate takes.
  final PlassColor? color;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final height = _markHeight[size]!;
    final plated = shape != PlAppLogoShape.bare;

    Widget mark = child;

    if (plated) {
      final surface = markSurface(tokens, family, variant: variant, elevation: 1);

      // The square is outside the surface rather than inside it: a surface box
      // takes whatever width it is handed, and a plate that stretched to the
      // header it sits in would be a bar with a glyph in the middle.
      mark = SizedBox.square(
        dimension: height,
        child: PlassSurfaceBox(
          surface: surface,
          borderRadius: shape == PlAppLogoShape.circle
              ? BorderRadius.circular(height)
              : BorderRadius.circular(PlassTokens.radius[size]!),
          child: Center(
            child: SizedBox.square(
              dimension: height * _inset,
              child: FittedBox(child: child),
            ),
          ),
        ),
      );
    } else {
      // A height and no width: a wordmark is wider than it is tall, and cropping
      // it to a square is the failure this widget is here to avoid.
      mark = SizedBox(
        height: height,
        child: FittedBox(fit: BoxFit.contain, child: child),
      );
    }

    // Decorative once the name is written out beside it, so the product is
    // announced once rather than twice.
    mark = name != null
        ? ExcludeSemantics(child: mark)
        : Semantics(label: semanticLabel, image: semanticLabel != null, child: mark);

    Widget content = mark;

    if (name != null || description != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        spacing: _gap[size]!,
        children: <Widget>[
          mark,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (name != null)
                  DefaultTextStyle.merge(
                    style: TextStyle(
                      color: tokens.fg,
                      fontSize: _nameSize[size]!,
                      fontWeight: FontWeight.w600,
                      leadingDistribution: TextLeadingDistribution.even,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                    child: name!,
                  ),
                if (description != null)
                  DefaultTextStyle.merge(
                    style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: description!,
                  ),
              ],
            ),
          ),
        ],
      );
    }

    if (onPressed == null) {
      return content;
    }

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: MouseRegion(cursor: SystemMouseCursors.click, child: content),
      ),
    );
  }
}
