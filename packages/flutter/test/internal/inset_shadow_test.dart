/// That the one shadow Flutter has no box for still falls exactly where it did.
///
/// The ring between two rounded rectangles used to be built with a path boolean
/// operation, which ran on every repaint — once per glass sheet and per field,
/// and on every frame of a hover transition. `drawDRRect` says the same thing
/// without building a path, and *the same thing* is what is checked here: every
/// shadow the library ships, and a few harder ones, painted both ways into two
/// images and compared pixel for pixel.
///
/// So this is not a design test. It pins no colour, no radius and no offset —
/// only that two ways of drawing one ring agree.
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';

/// The ring, built the way it was before `drawDRRect`.
void combinePaths(
  Canvas canvas,
  Size size,
  List<PlassInsetShadow> shadows,
  BorderRadius borderRadius,
) {
  final RRect shape = borderRadius.toRRect(Offset.zero & size);

  canvas.save();
  canvas.clipRRect(shape);

  for (final PlassInsetShadow shadow in shadows) {
    final double sigma = shadow.blur / 2;
    final RRect hole = shape.shift(shadow.offset).deflate(shadow.spread);
    final double margin = size.longestSide + shadow.blur * 3 + shadow.spread.abs() + 16;
    final Path outer = Path()..addRect(shape.outerRect.inflate(margin));
    final Path ring = Path.combine(PathOperation.difference, outer, Path()..addRRect(hole));
    final Paint paint = Paint()..color = shadow.color;

    if (sigma > 0) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);
    }

    canvas.drawPath(ring, paint);
  }

  canvas.restore();
}

/// [draw] rasterised over an opaque ground, as straight RGBA.
///
/// The ground is opaque and not white, so a shadow of either colour lands
/// somewhere a difference would show rather than saturating.
Future<Uint8List> raster(WidgetTester tester, Size size, void Function(Canvas canvas) draw) async {
  return (await tester.runAsync(() async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF6E7A8A));
    draw(canvas);

    final ui.Image image = await recorder.endRecording().toImage(
      size.width.round(),
      size.height.round(),
    );
    final ByteData? bytes = await image.toByteData();

    image.dispose();

    return bytes!.buffer.asUint8List();
  }))!;
}

void main() {
  /// The two the theme ships, and then the cases they do not reach: a spread, a
  /// wider blur, an offset that goes up and back, a square corner, and both
  /// shadows stacked the way a filled field carries them.
  final Map<String, (Size, BorderRadius, List<PlassInsetShadow>)> cases =
      <String, (Size, BorderRadius, List<PlassInsetShadow>)>{
        'the light gloss on a glass sheet': (
          const Size(200, 120),
          BorderRadius.circular(14),
          const <PlassInsetShadow>[
            PlassInsetShadow(color: Color(0x8CFFFFFF), offset: Offset(0, 1)),
          ],
        ),
        'the well a filled field is cut into': (
          const Size(200, 40),
          BorderRadius.circular(12),
          const <PlassInsetShadow>[
            PlassInsetShadow(color: Color(0x1A14285A), offset: Offset(0, 1), blur: 2),
          ],
        ),
        'the same well in the dark theme': (
          const Size(200, 40),
          BorderRadius.circular(12),
          const <PlassInsetShadow>[
            PlassInsetShadow(color: Color(0x73000000), offset: Offset(0, 1), blur: 2),
          ],
        ),
        'a shadow with a spread': (
          const Size(160, 96),
          BorderRadius.circular(20),
          const <PlassInsetShadow>[
            PlassInsetShadow(color: Color(0x99101828), offset: Offset(2, -2), blur: 6, spread: 3),
          ],
        ),
        'a shadow pulled outwards by a negative spread': (
          const Size(160, 96),
          BorderRadius.circular(8),
          const <PlassInsetShadow>[
            PlassInsetShadow(color: Color(0x66101828), offset: Offset(-3, 4), spread: -4),
          ],
        ),
        'a square corner': (
          const Size(120, 60),
          BorderRadius.zero,
          const <PlassInsetShadow>[
            PlassInsetShadow(color: Color(0xAAFFFFFF), offset: Offset(0, 2), blur: 3),
          ],
        ),
        'two shadows stacked': (
          const Size(200, 44),
          BorderRadius.circular(12),
          const <PlassInsetShadow>[
            PlassInsetShadow(color: Color(0x1A14285A), offset: Offset(0, 1), blur: 2),
            PlassInsetShadow(color: Color(0x8CFFFFFF), offset: Offset(0, 1)),
          ],
        ),
      };

  group('an inset shadow', () {
    for (final MapEntry<String, (Size, BorderRadius, List<PlassInsetShadow>)> entry
        in cases.entries) {
      final (Size size, BorderRadius radius, List<PlassInsetShadow> shadows) = entry.value;

      testWidgets('${entry.key} is drawn where a path boolean drew it', (
        WidgetTester tester,
      ) async {
        final Uint8List drawn = await raster(
          tester,
          size,
          (Canvas canvas) =>
              PlassInsetShadowPainter(shadows: shadows, borderRadius: radius).paint(canvas, size),
        );
        final Uint8List combined = await raster(
          tester,
          size,
          (Canvas canvas) => combinePaths(canvas, size, shadows, radius),
        );

        expect(drawn, equals(combined));
      });
    }

    testWidgets('paints nothing when it has no shadows', (WidgetTester tester) async {
      const Size size = Size(80, 40);

      final Uint8List drawn = await raster(
        tester,
        size,
        (Canvas canvas) => const PlassInsetShadowPainter(
          shadows: <PlassInsetShadow>[],
          borderRadius: BorderRadius.zero,
        ).paint(canvas, size),
      );
      final Uint8List ground = await raster(tester, size, (Canvas canvas) {});

      expect(drawn, equals(ground));
    });
  });
}
