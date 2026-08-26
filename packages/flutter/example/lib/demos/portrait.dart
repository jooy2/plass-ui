import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A portrait, drawn rather than fetched.
///
/// The demos need a picture to put in an avatar, and a picture in a repository
/// is a binary file somebody has to keep. This paints one instead — which also
/// makes the point the gallery is there to make: `PlAvatar.image` takes an
/// `ImageProvider`, so anything that can produce pixels fits, and a
/// `NetworkImage` is only the most obvious of them.
@immutable
class PortraitImage extends ImageProvider<PortraitImage> {
  /// Creates a portrait. [seed] picks the two colours.
  const PortraitImage(this.seed, {this.pixels = 128});

  /// Which portrait this is.
  final int seed;

  /// How large it is rendered, in device pixels.
  final int pixels;

  static const List<List<Color>> _palettes = <List<Color>>[
    <Color>[Color(0xFF3F63F2), Color(0xFF8FB6FF)],
    <Color>[Color(0xFF12866A), Color(0xFF6FE0BC)],
    <Color>[Color(0xFFD04246), Color(0xFFFFA9A0)],
    <Color>[Color(0xFF6B7488), Color(0xFFC2CBDD)],
  ];

  @override
  Future<PortraitImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<PortraitImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(PortraitImage key, ImageDecoderCallback decode) {
    return OneFrameImageStreamCompleter(_draw());
  }

  Future<ImageInfo> _draw() async {
    final palette = _palettes[seed % _palettes.length];
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final box = Rect.fromLTWH(0, 0, pixels.toDouble(), pixels.toDouble());
    final unit = pixels / 24;

    canvas
      ..drawRect(
        box,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: palette,
          ).createShader(box),
      )
      ..drawCircle(
        Offset(12 * unit, 9.5 * unit),
        4.2 * unit,
        Paint()..color = const Color(0x59FFFFFF),
      )
      ..drawOval(
        Rect.fromCenter(center: Offset(12 * unit, 22 * unit), width: 15 * unit, height: 14 * unit),
        Paint()..color = const Color(0x59FFFFFF),
      );

    final image = await recorder.endRecording().toImage(pixels, pixels);

    return ImageInfo(image: image);
  }

  @override
  bool operator ==(Object other) {
    return other is PortraitImage && other.seed == seed && other.pixels == pixels;
  }

  @override
  int get hashCode => Object.hash(seed, pixels);
}
