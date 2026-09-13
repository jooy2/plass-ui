/// A picture, and the two states a picture spends most of its life in.
library;

import 'dart:ui' as ui;

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

/// What fills the part of the box a picture leaves empty.
///
/// Drawn only where [PlImage.fit] can leave space — [PlAspectFit.contain],
/// [PlAspectFit.none] and [PlAspectFit.scaleDown]. Under the other two there is
/// nothing for it to show through.
@immutable
class PlImageLetterbox {
  /// Paints [decoration] behind the picture: a colour, a gradient, an image of
  /// your own.
  const PlImageLetterbox(Decoration this.decoration);

  const PlImageLetterbox._blur() : decoration = null;

  /// The picture itself, covering the box and blurred behind it, the way a video
  /// player fills the sides of a portrait clip.
  ///
  /// The copy is the same [ImageProvider], so it is answered from the same
  /// cache entry rather than loaded a second time. It is off the semantics tree
  /// and takes no pointer.
  static const PlImageLetterbox blur = PlImageLetterbox._blur();

  /// What is painted behind the picture, or `null` for [blur].
  final Decoration? decoration;
}

/// A picture to stand in while the file arrives, in place of the skeleton.
///
/// Given to [PlImage.placeholder], it is drawn the way the picture will be, with
/// the same [PlImage.fit], [PlImage.position], [PlImage.rotate], [PlImage.flip]
/// and treatment. That is what it is for: a small copy of the same file, a few
/// hundred bytes in a [MemoryImage] or an asset, so the reader sees the
/// picture's colours and shape before its detail. It stays under the picture
/// until the picture has finished fading in over it.
///
/// Like the skeleton it fills the box, so it needs a box to fill: a
/// [PlImage.ratio], or both [PlImage.width] and [PlImage.height].
///
/// Built anywhere else, it draws its picture covering the space it is given.
class PlImagePlaceholder extends StatelessWidget {
  /// Creates a stand-in.
  const PlImagePlaceholder({required this.image, this.blur = 0, super.key});

  /// The stand-in.
  final ImageProvider<Object> image;

  /// How far the stand-in is blurred, in logical pixels. A copy stretched up
  /// from a few pixels is blocky without it; `20` is what the React build's
  /// `blur: true` means.
  final double blur;

  @override
  Widget build(BuildContext context) {
    final Widget picture = Image(
      image: image,
      fit: BoxFit.cover,
      excludeFromSemantics: true,
      errorBuilder: _drawNothing,
    );

    return ClipRect(
      child: blur > 0 ? ImageFiltered(imageFilter: _blurOf(blur), child: picture) : picture,
    );
  }
}

/// What a stand-in or a letterbox copy draws when its own file does not load:
/// nothing, and no error reported for it. Neither is the picture, and the
/// picture reports its own failure.
Widget _drawNothing(BuildContext context, Object error, StackTrace? stack) {
  return const SizedBox.shrink();
}

/// A Gaussian blur of the same radius on both axes.
ui.ImageFilter _blurOf(double sigma) => ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);

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
    this.position = Alignment.center,
    this.letterbox,
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

  /// Where the picture sits in its box: which part of it a
  /// [PlAspectFit.cover] crop keeps, and where [PlAspectFit.contain],
  /// [PlAspectFit.none] and [PlAspectFit.scaleDown] leave their empty space.
  ///
  /// An [Alignment] rather than an [AlignmentGeometry], on purpose. The subject
  /// of a photograph is on the same side of it in every language, so a crop
  /// that keeps it must not move to the other side under a right-to-left
  /// [Directionality].
  ///
  /// Read on the picture as it is shown, so it holds through [rotate] and
  /// [flip]: the top of the alignment keeps the top of what the reader sees
  /// rather than the top of the file.
  final Alignment position;

  /// What fills the box where [fit] leaves it empty: [PlImageLetterbox.blur] for
  /// the picture itself, blurred behind it, or a [Decoration] of your own.
  /// `null` leaves the space as it is.
  final PlImageLetterbox? letterbox;

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
  ///
  /// A [PlImagePlaceholder] is drawn as a picture instead: under the picture,
  /// turned and placed the way the picture is, and kept until the picture has
  /// faded in over it.
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

/// How far a blurred letterbox is blurred, as a standard deviation in logical
/// pixels — the same number the React build writes into `blur()`.
const double _letterboxBlur = 24;

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

  /// [PlImage.position], as the alignment of the picture before it is turned
  /// and mirrored.
  Alignment get _alignment {
    final PlImageFlip flip = widget.flip;
    final Alignment shown = widget.position;
    final (double across, double down) = elementFractions(
      ((shown.x + 1) / 2, (shown.y + 1) / 2),
      quartersOf(widget.rotate),
      mirrorAcross: flip == PlImageFlip.horizontal || flip == PlImageFlip.both,
      mirrorDown: flip == PlImageFlip.vertical || flip == PlImageFlip.both,
    );

    return Alignment(across * 2 - 1, down * 2 - 1);
  }

  /// The picture turned and mirrored the way [PlImage.rotate] and
  /// [PlImage.flip] say.
  Widget _pose(Widget child) {
    return posed(
      child,
      quartersOf(widget.rotate),
      mirrorAcross: widget.flip == PlImageFlip.horizontal || widget.flip == PlImageFlip.both,
      mirrorDown: widget.flip == PlImageFlip.vertical || widget.flip == PlImageFlip.both,
    );
  }

  /// The blurred copy of the picture a [PlImageLetterbox.blur] draws behind it,
  /// or `null` where there is none to draw.
  ///
  /// Grown past the box by two radii on every side and clipped back to it,
  /// because a blur fades to nothing over about that distance at its edge and
  /// the box would otherwise show a soft frame of whatever is behind it.
  Widget? _backdrop() {
    final PlAspectFit fit = widget.fit;

    if (widget.letterbox != PlImageLetterbox.blur ||
        fit == PlAspectFit.cover ||
        fit == PlAspectFit.fill) {
      return null;
    }

    return PositionedDirectional(
      start: -_letterboxBlur * 2,
      end: -_letterboxBlur * 2,
      top: -_letterboxBlur * 2,
      bottom: -_letterboxBlur * 2,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: _blurOf(_letterboxBlur),
          child: _treat(
            _pose(
              Image(
                image: widget.image,
                fit: BoxFit.cover,
                alignment: _alignment,
                excludeFromSemantics: true,
                errorBuilder: _drawNothing,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The picture stand-in a [PlImagePlaceholder] draws under the picture, or
  /// `null` where the placeholder is something else.
  ///
  /// Opaque while the picture is on its way, and taken away in one step once
  /// the picture has finished fading in over it. A cross-fade of the two would
  /// leave both half there with the page showing through. Grown and clipped
  /// back the way the blurred letterbox is, when it is blurred.
  Widget? _standIn({required bool arrived, required Duration fade}) {
    final Widget? placeholder = widget.placeholder;

    if (placeholder is! PlImagePlaceholder) {
      return null;
    }

    final double bleed = placeholder.blur * 2;
    Widget layer = _treat(
      _pose(
        Image(
          image: placeholder.image,
          fit: PlAspectRatio.boxFit(widget.fit),
          alignment: _alignment,
          excludeFromSemantics: true,
          errorBuilder: _drawNothing,
        ),
      ),
    );

    if (placeholder.blur > 0) {
      layer = ImageFiltered(imageFilter: _blurOf(placeholder.blur), child: layer);
    }

    return PositionedDirectional(
      start: -bleed,
      end: -bleed,
      top: -bleed,
      bottom: -bleed,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: arrived ? 0 : 1,
          duration: fade,
          // Held at one for the whole of the fade, and dropped at its end.
          curve: const Threshold(1),
          child: layer,
        ),
      ),
    );
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
      alignment: _alignment,
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
        final Widget? backdrop = _backdrop();
        final Widget posed = _treat(_pose(child));
        // The copy fades in with the picture rather than ahead of it, so the two
        // go under one fade. The stack clips the copy's grown edge back to the
        // box.
        final Widget treated = backdrop == null
            ? posed
            : Stack(fit: StackFit.passthrough, children: <Widget>[backdrop, posed]);

        if (sync) {
          _settle(PlImageStatus.loaded);

          return treated;
        }

        if (frame != null) {
          _settle(PlImageStatus.loaded);
        }

        final Duration fade = reduceMotion ? Duration.zero : PlassTokens.duration;
        final Widget fading = AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: fade,
          curve: PlassTokens.ease,
          child: treated,
        );
        final Widget? standIn = _standIn(arrived: frame != null, fade: fade);

        // `StackFit.passthrough` so the placeholder is measured by whatever the
        // picture would have been measured by, and the undecoded image under it
        // takes no room of its own.
        //
        // The same `Stack` once the first frame is in, with the placeholder
        // gone from in front of the picture. Returning the `AnimatedOpacity` on
        // its own there would move it to a different parent, and a widget that
        // changes parent is built again from scratch — at 1, with nothing to
        // travel from.
        //
        // A picture stand-in is the exception: it goes under the picture and
        // stays there through the fade.
        return Stack(
          fit: StackFit.passthrough,
          children: <Widget>[?standIn, if (frame == null && standIn == null) placeholder, fading],
        );
      },
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        _settle(PlImageStatus.error);

        return fallback;
      },
    );

    final Decoration? painted = widget.letterbox?.decoration;

    if (painted != null) {
      picture = DecoratedBox(decoration: painted, child: picture);
    }

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
      // The press target excludes itself from semantics, so the action a
      // screen reader, Switch Access or Voice Access fires is declared here.
      onTap: widget.preview && _status == PlImageStatus.loaded
          ? () => setState(() => _open = true)
          : null,
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
