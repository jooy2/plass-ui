/// A picture, and the two states a picture spends most of its life in.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/aspect_ratio/pl_aspect_ratio.dart';
import 'package:plass_ui/src/components/overlay/pl_overlay.dart';
import 'package:plass_ui/src/components/skeleton/pl_skeleton.dart';
import 'package:plass_ui/src/internal/css.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

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
    this.fit = PlAspectFit.cover,
    this.filter = PlImageFilter.none,
    this.colorFilter,
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

  /// How the picture is fitted to the box.
  final PlAspectFit fit;

  /// A treatment laid over the picture.
  ///
  /// [colorFilter] wins where both are given, which is what makes it the escape
  /// hatch: the named ones are the common answers and it is the rest.
  final PlImageFilter filter;

  /// Any [ColorFilter] of your own, in place of a named [filter].
  final ColorFilter? colorFilter;

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
        final Widget treated = _treat(child);

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

        if (frame != null) {
          return fading;
        }

        // `StackFit.passthrough` so the placeholder is measured by whatever the
        // picture would have been measured by, and the undecoded image under it
        // takes no room of its own.
        return Stack(fit: StackFit.passthrough, children: <Widget>[placeholder, fading]);
      },
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        _settle(PlImageStatus.error);

        return fallback;
      },
    );

    if (widget.ratio != null) {
      picture = AspectRatio(aspectRatio: widget.ratio!, child: picture);
    }

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
            child: Image(image: widget.image, fit: BoxFit.contain, excludeFromSemantics: true),
          ),
        ],
      );
    }

    return result;
  }
}
