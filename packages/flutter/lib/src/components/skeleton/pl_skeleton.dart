/// The shape of something that has not loaded yet.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// What the placeholder is standing in for.
enum PlSkeletonShape {
  /// A run of text. Sized off the type scale, so an `md` line is exactly as
  /// tall as the `md` type it will be replaced by.
  line,

  /// A block: an image, a chart, a card, a map.
  rect,

  /// An avatar, or anything else round.
  circle,
}

/// A line's height is the type scale itself — the same lengths [sheetBody] sets
/// as a font size — so a placeholder occupies the em box of the text that
/// replaces it. The leading around it is [_lineGap], and the two together add up
/// to that ladder's line box.
const Map<PlassSize, double> _lineHeight = <PlassSize, double>{
  PlassSize.xs: 11,
  PlassSize.sm: 12,
  PlassSize.md: 13,
  PlassSize.lg: 15,
  PlassSize.xl: 17,
};

/// The leading: the body ladder's line box less the bar drawn in it.
const Map<PlassSize, double> _lineGap = <PlassSize, double>{
  PlassSize.xs: 5,
  PlassSize.sm: 6,
  PlassSize.md: 9,
  PlassSize.lg: 9,
  PlassSize.xl: 11,
};

/// A bar's corner, at ~45% of its own height — held just short of the 50% that
/// would make it a capsule.
///
/// Not [PlassTokens.radius], which is ~30% of a *control's* height: 12 on a
/// 13px bar is a capsule and a half. Not [tickRadius] either, which is sized
/// against a box rather than against a run of text.
const Map<PlassSize, double> _barRadius = <PlassSize, double>{
  PlassSize.xs: 5,
  PlassSize.sm: 5,
  PlassSize.md: 6,
  PlassSize.lg: 7,
  PlassSize.xl: 8,
};

/// What a [PlSkeletonShape.rect] is as tall as when nothing says otherwise: a
/// thumbnail. Anything else wants a height, and most uses of this shape pass
/// one.
const Map<PlassSize, double> _blockHeight = <PlassSize, double>{
  PlassSize.xs: 48,
  PlassSize.sm: 64,
  PlassSize.md: 80,
  PlassSize.lg: 112,
  PlassSize.xl: 144,
};

/// How far the last line of a paragraph falls short of the margin.
const double _lastLineFraction = 0.6;

/// How long the highlight takes to cross a placeholder.
const Duration _sweepDuration = Duration(milliseconds: 1500);

/// How wide that highlight is, as a fraction of the placeholder.
const double _sweepWidth = 0.6;

/// The shape of something that has not loaded yet.
///
/// ```dart
/// const PlSkeleton(shape: PlSkeletonShape.line, lines: 3)
/// ```
///
/// It reserves the space the real thing will take, which is the whole job: a
/// card that grows by 200px when its image arrives has moved everything below it
/// while somebody was reading. A spinner cannot do that.
///
/// The three shapes are the three things a layout is made of — a run of text, a
/// block and a circle — and each is sized off the ladder the real component
/// uses, so an `md` line is as tall as `md` type and an `md` circle is exactly
/// an avatar at `md`.
///
/// The surface is deliberately **not** glass. Every other sheet in the library
/// is translucent over a blurred backdrop, because it is a thing sitting on the
/// page; a skeleton is the shape of something that is not there yet, so it is a
/// flat tint and nothing else — no blur, no hairline, no gloss, no shadow. It
/// also keeps a page of thirty placeholders from asking for thirty backdrop
/// filters.
class PlSkeleton extends StatelessWidget {
  /// Creates a placeholder.
  const PlSkeleton({
    this.shape = PlSkeletonShape.line,
    this.lines = 1,
    this.size,
    this.color,
    this.width,
    this.height,
    this.animated = true,
    this.label,
    super.key,
  }) : assert(lines >= 1, 'lines must be at least 1');

  /// What is being stood in for.
  final PlSkeletonShape shape;

  /// How many lines to draw, for [PlSkeletonShape.line].
  ///
  /// The last one is drawn short, the way the last line of a paragraph is, so a
  /// block of them reads as prose rather than as a barcode. Ignored by the
  /// other two shapes.
  final int lines;

  /// The scale of the thing being stood in for: the type scale for a line, the
  /// diameter for a circle, the default block height for a rect.
  final PlassSize? size;

  /// Colour family.
  ///
  /// [PlassColor.secondary] by default, and it is worth leaving there: a
  /// placeholder that carries a semantic colour is saying something about
  /// content that has not arrived yet.
  final PlassColor? color;

  /// An explicit width.
  final double? width;

  /// An explicit height.
  final double? height;

  /// The travelling highlight.
  ///
  /// Turn it off for a page holding dozens of them, or where the wait is
  /// expected to be long enough that motion becomes noise. A platform that has
  /// asked for less movement already replaces the sweep with a colour pulse
  /// without being asked, so this is not the accessibility switch.
  final bool animated;

  /// What a screen reader is told, if anything.
  ///
  /// Left out — the default — the placeholder says nothing, because a dozen
  /// boxes each announcing themselves is worse than silence. Give the *one*
  /// skeleton that stands for the whole region a label and it becomes the
  /// element that reports the wait.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.secondary;

    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    // A run of lines is a stack of bars rather than one box, so the gaps between
    // them are real gaps: text has leading, and a striped fill would not survive
    // a caller putting the block in a row.
    final stacked = shape == PlSkeletonShape.line && lines > 1;

    Widget placeholder = stacked
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: _lineGap[size]!,
            children: <Widget>[
              for (var index = 0; index < lines; index += 1)
                FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  // The last line of a paragraph does not reach the margin.
                  widthFactor: index == lines - 1 ? _lastLineFraction : 1,
                  child: _bar(context, family, still: still),
                ),
            ],
          )
        : _bar(context, family, still: still);

    if (width != null || height != null || shape != PlSkeletonShape.line) {
      placeholder = SizedBox(
        width: width ?? (shape == PlSkeletonShape.circle ? controlHeight[size]! : null),
        height: height ?? _defaultHeight(size),
        child: placeholder,
      );
    }

    return label != null
        ? Semantics(label: label, liveRegion: true, container: true, child: placeholder)
        : ExcludeSemantics(child: placeholder);
  }

  /// Takes the **resolved** size rather than reading the field, which is null
  /// whenever the caller left it to the theme.
  double? _defaultHeight(PlassSize size) {
    switch (shape) {
      case PlSkeletonShape.circle:
        return controlHeight[size]!;
      case PlSkeletonShape.rect:
        return _blockHeight[size]!;
      case PlSkeletonShape.line:
        return null;
    }
  }

  /// One filled shape, with the highlight travelling across it.
  Widget _bar(BuildContext context, PlassColorFamily family, {required bool still}) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;

    final radius = shape == PlSkeletonShape.circle
        ? BorderRadius.circular(controlHeight[size]!)
        : shape == PlSkeletonShape.rect
        // A block's corner is the sheet ladder, because a block stands for a
        // sheet.
        ? BorderRadius.circular(PlassTokens.radius[size]!)
        : BorderRadius.circular(_barRadius[size]!);

    Widget bar = DecoratedBox(
      decoration: BoxDecoration(color: family.softHover, borderRadius: radius),
      child: SizedBox(
        width: double.infinity,
        height: shape == PlSkeletonShape.line ? _lineHeight[size]! : double.infinity,
      ),
    );

    if (animated) {
      bar = _Sweep(color: family.softPress, still: still, borderRadius: radius, child: bar);
    }

    return bar;
  }
}

/// The travelling highlight, and — where the platform has asked for less
/// movement — the pulse that stands in for it.
///
/// Kept running rather than stopped, because a skeleton that holds still is
/// indistinguishable from an empty box that finished loading with nothing in it.
/// What changes is the axis: the highlight stops crossing the placeholder and
/// the whole thing breathes in colour instead, which is the axis every other
/// state in the library already uses.
class _Sweep extends StatefulWidget {
  const _Sweep({
    required this.color,
    required this.still,
    required this.borderRadius,
    required this.child,
  });

  final Color color;
  final bool still;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  State<_Sweep> createState() => _SweepState();
}

class _SweepState extends State<_Sweep> with SingleTickerProviderStateMixin {
  late final AnimationController _travel = AnimationController(
    vsync: this,
    duration: _sweepDuration,
  )..repeat();

  @override
  void dispose() {
    _travel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          widget.child,
          Positioned.fill(
            child: ClipRRect(
              borderRadius: widget.borderRadius,
              child: AnimatedBuilder(
                animation: _travel,
                builder: (BuildContext context, Widget? child) {
                  if (widget.still) {
                    // 0 → 1 → 0 across the cycle, which is the pulse's shape.
                    final breath = 1 - (_travel.value * 2 - 1).abs();

                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: widget.color.a * breath),
                      ),
                    );
                  }

                  final eased = PlassTokens.ease.transform(_travel.value);

                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[
                          widget.color.withValues(alpha: 0),
                          widget.color,
                          widget.color.withValues(alpha: 0),
                        ],
                        // The band occupies the first `_sweepWidth` of the box
                        // and is slid across it, rather than being a child that
                        // has to be positioned: outside its stops the clamped
                        // tile mode extends the transparent ends, so there is
                        // nothing to see until it arrives.
                        stops: const <double>[0, _sweepWidth / 2, _sweepWidth],
                        transform: _SweepShift(-_sweepWidth + eased * (1 + _sweepWidth)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Slides a gradient sideways by a fraction of the box it is painted in.
@immutable
class _SweepShift extends GradientTransform {
  const _SweepShift(this.fraction);

  final double fraction;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * fraction, 0, 0);
  }
}
