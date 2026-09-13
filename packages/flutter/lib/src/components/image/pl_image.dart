/// A picture, and the two states a picture spends most of its life in.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/aspect_ratio/pl_aspect_ratio.dart';
import 'package:plass_ui/src/components/overlay/pl_overlay.dart';
import 'package:plass_ui/src/components/skeleton/pl_skeleton.dart';
import 'package:plass_ui/src/internal/css.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/image.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/watermark.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

export 'package:plass_ui/src/internal/watermark.dart'
    show PlImageWatermark, PlImageWatermarkPlacement;

/// The treatments that have a name.
///
/// The escape hatch is [PlImage.colorFilter], which takes a [ColorFilter] of
/// your own — the React build takes a CSS `filter` chain there instead, because
/// that is what an escape hatch is in each place.
enum PlImageFilter {
  /// Left as it is.
  none,

  /// All the colour taken out.
  grayscale,

  /// Warmed and aged.
  sepia,

  /// The colour pushed up.
  saturate,

  /// And most of the way down, without going to grey.
  desaturate,

  /// The darks darker and the lights lighter.
  contrast,

  /// Held back from the page around it.
  dim,
}

/// Which way the picture is mirrored, along the axes it is shown on.
enum PlImageFlip {
  /// Left as it is.
  none,

  /// Left and right swapped on the screen.
  horizontal,

  /// Top and bottom swapped on the screen.
  vertical,

  /// Both, which is the same picture turned upside down.
  both,
}

/// Where the picture has got to.
enum PlImageStatus {
  /// On its way.
  loading,

  /// Arrived.
  loaded,

  /// Did not.
  error,
}

/// A picture, and the two states a picture spends most of its life in.
///
/// An [Image] is one widget and it works, which is the reason to say what this
/// adds rather than to assume it. Three things: the space is **reserved** before
/// the picture arrives, so what is under it does not move when it does; a
/// failure is *drawn* rather than left as an empty box; and the two are one
/// state machine, so the placeholder is not still there behind a picture that
/// has already loaded.
///
/// [ratio] is what makes the first one work and is the parameter worth reaching
/// for every time. Without it there is nothing to reserve — the box is however
/// tall the picture turns out to be, which is not known until it arrives.
///
/// ```dart
/// PlImage(
///   image: const NetworkImage('https://example.com/cover.jpg'),
///   semanticLabel: 'The 2026 team',
///   ratio: 16 / 9,
///   rounded: true,
/// )
/// ```
class PlImage extends StatefulWidget {
  /// Creates a picture.
  const PlImage({
    required this.image,
    this.semanticLabel,
    this.ratio,
    this.width,
    this.height,
    this.fit = PlAspectFit.cover,
    this.rotate = 0,
    this.flip = PlImageFlip.none,
    this.filter = PlImageFilter.none,
    this.colorFilter,
    this.watermark,
    this.rounded = false,
    this.size,
    this.color,
    this.placeholder,
    this.fallback,
    this.preview = false,
    this.previewLabel,
    this.onStatusChanged,
    super.key,
  });

  /// The picture.
  ///
  /// An [ImageProvider] rather than a URL, because that is the shape every
  /// source has in common — a network image, an asset, a file, a memory buffer.
  final ImageProvider<Object> image;

  /// The description a screen reader reads.
  ///
  /// `null` marks the picture decorative and takes it off the semantics tree,
  /// which is the right call for a background or a texture and the wrong one for
  /// anything a reader would miss. It is also what the [fallback] falls back to.
  final String? semanticLabel;

  /// The proportion the box holds while the picture is on its way — `16 / 9`.
  ///
  /// This is what the widget is really for. Without it the layout has nothing to
  /// reserve, and every picture that arrives late pushes what is under it down.
  final double? ratio;

  /// The picture's own pixel width, or, given without [height], the width of
  /// the box.
  ///
  /// Given together, the two describe the file, and the box keeps their
  /// proportion before the picture arrives, the way [ratio] does. They are the
  /// same numbers the React build's `<img>` takes, and they mean the same thing
  /// there.
  ///
  /// Given alone, one is not a proportion, so it is read as the length it looks
  /// like: `width: 320` is a box 320 wide, never wider than the space it is
  /// given, and as tall as the picture or the [ratio] makes it. It sits at the
  /// start of that space.
  final double? width;

  /// The picture's own pixel height, or, given without [width], the height of
  /// the box.
  ///
  /// `height: 200` alone is a box 200 tall, as wide as the space it is given,
  /// which therefore has to have a width. With a [ratio] as well, the width is
  /// worked out from the ratio instead, and the box sits at the start.
  final double? height;

  /// How the picture is fitted to the box.
  final PlAspectFit fit;

  /// Turns the picture clockwise, a quarter at a time: `0`, `90`, `180` or
  /// `270`.
  ///
  /// Quarter turns and nothing between them. A picture turned by any other angle
  /// no longer covers its own box, so any other number is taken to the nearest
  /// quarter, and `-90` is the `270` it means.
  ///
  /// A picture on its side is laid out on its side. Without a [ratio] the widget
  /// takes the turned shape of the picture; with one, the ratio is the layout's
  /// and is kept, and [fit] decides how the turned picture fills it. The
  /// placeholder, the fallback and the watermark stay upright.
  final int rotate;

  /// Mirrors the picture, along the axes it is shown on.
  ///
  /// [PlImageFlip.horizontal] swaps left and right on the screen and
  /// [PlImageFlip.vertical] swaps top and bottom, whichever way [rotate] has
  /// turned the picture.
  final PlImageFlip flip;

  /// A treatment laid over the picture.
  ///
  /// [colorFilter] wins where both are given, which is what makes it the escape
  /// hatch: the named ones are the common answers and it is the rest.
  final PlImageFilter filter;

  /// Any [ColorFilter] of your own, in place of a named [filter].
  final ColorFilter? colorFilter;

  /// A mark laid over the picture.
  ///
  /// It is drawn only once the picture has arrived, and it is off the semantics
  /// tree and takes no pointer. A watermark is a claim about the file rather
  /// than something the screen is telling a reader — [semanticLabel] is where a
  /// picture says what it is.
  final PlImageWatermark? watermark;

  /// Rounds the corners to the [size] step of the house ladder.
  final bool rounded;

  /// Which step of the radius ladder [rounded] uses.
  final PlassSize? size;

  /// The family the skeleton and the focus ring take.
  final PlassColor? color;

  /// What is drawn while the picture is loading. A [PlSkeleton] by default.
  final Widget? placeholder;

  /// What is drawn when the picture does not arrive.
  ///
  /// A muted panel with the [semanticLabel] in it by default, which is the one
  /// thing that is certainly available and certainly describes what is missing.
  final Widget? fallback;

  /// Opens the picture over the page when it is pressed.
  ///
  /// Off by default. A picture that grows when you press it is a promise that
  /// there is more of it to see, and most pictures on a screen are not making
  /// it.
  final bool preview;

  /// The name of the preview overlay.
  final String? previewLabel;

  /// Called when the picture has loaded, and when it has failed.
  final ValueChanged<PlImageStatus>? onStatusChanged;

  @override
  State<PlImage> createState() => _PlImageState();
}

class _PlImageState extends State<PlImage> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

  PlImageStatus _status = PlImageStatus.loading;
  bool _open = false;

  @override
  void didUpdateWidget(PlImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A new picture starts again. Without this a second one would inherit the
    // first one's `loaded` and never draw its own failure.
    if (oldWidget.image != widget.image) {
      _status = PlImageStatus.loading;
    }
  }

  void _settle(PlImageStatus next) {
    if (_status == next) {
      return;
    }

    // Deferred, because both builders run during the build that discovered the
    // change and `setState` inside one is an error.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted || _status == next) {
        return;
      }

      setState(() => _status = next);
      widget.onStatusChanged?.call(next);
    });
  }

  /// The picture turned and mirrored the way [PlImage.rotate] and
  /// [PlImage.flip] say.
  ///
  /// The turn is a [RotatedBox] rather than a [Transform], because it turns the
  /// layout as well as the paint: the picture is laid out at the box's height by
  /// its width, fitted there, and turned into place, so a picture on its side
  /// fills its box rather than overhanging it on one axis and falling short on
  /// the other.
  ///
  /// The mirror goes outside the turn, so it acts on the axes of the screen and
  /// needs no swapping on a quarter turn. The React build writes its mirror in
  /// the element's own axes and swaps them there instead.
  Widget _pose(Widget child) {
    final int quarters = quartersOf(widget.rotate);
    final PlImageFlip flip = widget.flip;
    Widget posed = child;

    if (quarters != 0) {
      posed = RotatedBox(quarterTurns: quarters, child: posed);
    }

    if (flip != PlImageFlip.none) {
      posed = Transform.flip(
        flipX: flip == PlImageFlip.horizontal || flip == PlImageFlip.both,
        flipY: flip == PlImageFlip.vertical || flip == PlImageFlip.both,
        child: posed,
      );
    }

    return posed;
  }

  /// The picture with its treatment on it, or the picture as it is.
  ///
  /// [PlImage.colorFilter] wins where both are given: the named ones are the
  /// common answers and the raw filter is the rest, so a caller who reached for
  /// the escape hatch has already said the names did not cover it.
  Widget _treat(Widget child) {
    final ColorFilter? filter = widget.colorFilter ?? _named(widget.filter);

    if (filter == null) {
      return child;
    }

    return ColorFiltered(colorFilter: filter, child: child);
  }

  /// The CSS each name stands for, as a colour matrix.
  ///
  /// The amounts are the same numbers the React build writes into its `filter`
  /// chain, so `sepia` is one colour across the two packages rather than two
  /// that look alike.
  ColorFilter? _named(PlImageFilter filter) {
    switch (filter) {
      case PlImageFilter.none:
        return null;
      case PlImageFilter.grayscale:
        return saturationFilter(0);
      case PlImageFilter.sepia:
        return sepiaFilter(0.72);
      case PlImageFilter.saturate:
        return saturationFilter(1.35);
      case PlImageFilter.desaturate:
        return saturationFilter(0.45);
      case PlImageFilter.contrast:
        return contrastFilter(1.2);
      case PlImageFilter.dim:
        return brightnessFilter(0.82);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(_color);
    final radius = BorderRadius.circular(widget.rounded ? PlassTokens.radius[_size]! : 0);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final placeholder =
        widget.placeholder ?? PlSkeleton(shape: PlSkeletonShape.rect, size: _size, color: _color);

    final fallback =
        widget.fallback ??
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          color: tokens.glassPress,
          child: Text(
            widget.semanticLabel ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(color: tokens.mutedFg, fontSize: 13),
          ),
        );

    Widget picture = Image(
      image: widget.image,
      fit: PlAspectRatio.boxFit(widget.fit),
      // Only ever named once, by the `Semantics` below.
      excludeFromSemantics: true,
      // The picture fades up over the placeholder rather than replacing it
      // between two frames. A photograph that cuts in has decoded, which is
      // true and is not what the reader is being told — what a hard cut reads
      // as is the layout changing its mind, and it reads that way hardest on
      // the slow connection the placeholder exists for.
      //
      // Both branches build the same `AnimatedOpacity`, which is what makes it
      // animate at all: a widget created at 1 has nothing to travel from. A
      // picture that was already decoded is handed back whole and unwrapped —
      // `sync` is the frame where there was never anything to wait for, and an
      // entrance there would be an entrance for a picture that never arrived.
      frameBuilder: (BuildContext context, Widget child, int? frame, bool sync) {
        // The treatment goes on the picture and on nothing else. Wrapping the
        // whole `Image` would put it over the placeholder and the fallback too,
        // and a greyed-out skeleton is not what `filter: grayscale` was asked
        // for.
        final Widget treated = _treat(_pose(child));

        if (sync) {
          _settle(PlImageStatus.loaded);

          return treated;
        }

        if (frame != null) {
          _settle(PlImageStatus.loaded);
        }

        final Widget fading = AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: reduceMotion ? Duration.zero : PlassTokens.duration,
          curve: PlassTokens.ease,
          child: treated,
        );

        // `StackFit.passthrough` so the placeholder is measured by whatever the
        // picture would have been measured by, and the undecoded image under it
        // takes no room of its own.
        //
        // The same `Stack` once the first frame is in, with the placeholder
        // gone from in front of the picture. Returning the `AnimatedOpacity` on
        // its own there would move it to a different parent, and a widget that
        // changes parent is built again from scratch — at 1, with nothing to
        // travel from.
        return Stack(
          fit: StackFit.passthrough,
          children: <Widget>[if (frame == null) placeholder, fading],
        );
      },
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        _settle(PlImageStatus.error);

        return fallback;
      },
    );

    // The mark goes on before the ratio and the clip, so it is bounded by the
    // picture and cut by the same corners rather than sitting over them. Only
    // once there is a picture to mark: a stamp over a skeleton is a claim about
    // a file that has not arrived.
    if (widget.watermark != null && _status == PlImageStatus.loaded) {
      picture = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          picture,
          PlassWatermarkLayer(watermark: widget.watermark!),
        ],
      );
    }

    final double? width = widget.width;
    final double? height = widget.height;
    final bool sideways = isSideways(quartersOf(widget.rotate));

    // Two dimensions are the file, and keep its proportion — turned, for a
    // picture on its side. A `ratio` is the layout's shape and outranks them.
    double? ratio = widget.ratio;

    if (ratio == null && width != null && height != null && width > 0 && height > 0) {
      ratio = sideways ? height / width : width / height;
    }

    if (ratio != null) {
      picture = AspectRatio(aspectRatio: ratio, child: picture);
    }

    // One dimension alone sizes the box on its own axis. A lone height takes
    // the width it is given, unless a ratio can say what the width is.
    final bool loneWidth = width != null && height == null;
    final bool loneHeight = height != null && width == null;

    if (loneWidth) {
      picture = SizedBox(width: width, child: picture);
    } else if (loneHeight) {
      picture = SizedBox(
        height: height,
        width: ratio == null ? double.infinity : height * ratio,
        child: picture,
      );
    }

    // Whether the box is narrower than the space it was given, and so has to
    // sit at the start of it rather than be stretched across.
    final bool narrowed = loneWidth || (loneHeight && ratio != null);

    picture = ClipRRect(borderRadius: radius, child: picture);

    if (widget.preview) {
      final bool ready = _status == PlImageStatus.loaded;
      // Held in a `final` of its own before the reassignment. A closure captures
      // the *variable*, so a builder that read `picture` would read whatever
      // `picture` had become by the time it ran — the `PlassInteractive` holding
      // the builder, which is a widget that contains itself.
      final Widget content = picture;

      picture = PlassInteractive(
        onTap: ready ? () => setState(() => _open = true) : null,
        enabled: ready,
        interactive: ready,
        cursor: SystemMouseCursors.zoomIn,
        builder: (BuildContext context, PlassInteraction state) {
          if (!state.focusVisible) {
            return content;
          }

          return CustomPaint(
            foregroundPainter: PlassFocusRingPainter(color: family.ring, borderRadius: radius),
            child: content,
          );
        },
      );
    }

    Widget result = Semantics(
      label: widget.semanticLabel,
      image: true,
      button: widget.preview,
      container: widget.semanticLabel != null,
      child: picture,
    );

    if (widget.preview) {
      result = Stack(
        children: <Widget>[
          result,
          PlOverlay(
            open: _open,
            onOpenChanged: (bool next) => setState(() => _open = next),
            tone: PlOverlayTone.glass,
            dismissible: true,
            label: widget.previewLabel ?? PlassTheme.labelsOf(context).preview,
            // The mark follows the picture in. One that comes off the moment it
            // is opened large has marked the copy nobody wanted.
            // Turned and mirrored the way the thumbnail was, so the picture opens
            // the way it was shown.
            child: widget.watermark == null
                ? _pose(Image(image: widget.image, fit: BoxFit.contain, excludeFromSemantics: true))
                : Stack(
                    children: <Widget>[
                      _pose(
                        Image(image: widget.image, fit: BoxFit.contain, excludeFromSemantics: true),
                      ),
                      PlassWatermarkLayer(watermark: widget.watermark!),
                    ],
                  ),
          ),
        ],
      );
    }

    // Outside the preview's press target and its focus ring, so a narrowed box
    // is what both of them are drawn round rather than the space around it.
    if (narrowed) {
      result = Align(
        alignment: AlignmentDirectional.topStart,
        widthFactor: 1,
        heightFactor: 1,
        child: result,
      );
    }

    return result;
  }
}
