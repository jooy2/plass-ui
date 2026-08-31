/// A picture, and the two states a picture spends most of its life in.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/aspect_ratio/pl_aspect_ratio.dart';
import 'package:plass_ui/src/components/overlay/pl_overlay.dart';
import 'package:plass_ui/src/components/skeleton/pl_skeleton.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

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
    this.rounded = false,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.placeholder,
    this.fallback,
    this.preview = false,
    this.previewLabel = 'Preview',
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

  /// Rounds the corners to the [size] step of the house ladder.
  final bool rounded;

  /// Which step of the radius ladder [rounded] uses.
  final PlassSize size;

  /// The family the skeleton and the focus ring take.
  final PlassColor color;

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
  final String previewLabel;

  /// Called when the picture has loaded, and when it has failed.
  final ValueChanged<PlImageStatus>? onStatusChanged;

  @override
  State<PlImage> createState() => _PlImageState();
}

class _PlImageState extends State<PlImage> {
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

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(widget.color);
    final radius = BorderRadius.circular(widget.rounded ? PlassTokens.radius[widget.size]! : 0);

    final placeholder =
        widget.placeholder ??
        PlSkeleton(shape: PlSkeletonShape.rect, size: widget.size, color: widget.color);

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
      frameBuilder: (BuildContext context, Widget child, int? frame, bool sync) {
        if (frame == null && !sync) {
          return placeholder;
        }

        _settle(PlImageStatus.loaded);

        return child;
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
            label: widget.previewLabel,
            child: Image(image: widget.image, fit: BoxFit.contain, excludeFromSemantics: true),
          ),
        ],
      );
    }

    return result;
  }
}
