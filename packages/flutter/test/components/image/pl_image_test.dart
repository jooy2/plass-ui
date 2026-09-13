// The pictures here are built from bytes in the test file, so nothing depends
// on a network or on a file on disk — a one-pixel PNG that always decodes, and
// a buffer that is not an image and therefore always fails.
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/css.dart';
import 'package:plass_ui/src/internal/watermark.dart';

import '../../support/host.dart';

final Uint8List _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

final MemoryImage _ok = MemoryImage(_onePixelPng);
final MemoryImage _broken = MemoryImage(Uint8List.fromList(<int>[1, 2, 3, 4]));

/// A picture that never arrives and never fails.
///
/// Needed because both of the others settle in the first frame — a `MemoryImage`
/// already has its bytes — so the loading state is not observable through
/// either. This is the only way to hold the widget in it.
class _PendingImage extends ImageProvider<_PendingImage> {
  const _PendingImage();

  @override
  Future<_PendingImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_PendingImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(_PendingImage key, ImageDecoderCallback decode) {
    return _PendingCompleter();
  }
}

class _PendingCompleter extends ImageStreamCompleter {}

/// A picture that arrives when the test says so.
///
/// The frame the picture arrives on is a later frame than the one it was asked
/// for on, which is the case a fade exists for and the one neither a
/// `MemoryImage` nor [_PendingImage] can reach.
class _LaterImage extends ImageProvider<_LaterImage> {
  _LaterImage(Completer<ImageInfo> arrival)
    : _completer = OneFrameImageStreamCompleter(arrival.future);

  final OneFrameImageStreamCompleter _completer;

  @override
  Future<_LaterImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_LaterImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(_LaterImage key, ImageDecoderCallback decode) => _completer;
}

/// A blank picture of the given size, for a [_LaterImage] to deliver.
///
/// A picture with a width and a height of its own is what shows a turn, and a
/// one-pixel square cannot.
Future<ui.Image> _blank(WidgetTester tester, int width, int height) async {
  return (await tester.runAsync(() {
    final ui.PictureRecorder recorder = ui.PictureRecorder();

    Canvas(recorder).drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = const Color(0xFF808080),
    );

    return recorder.endRecording().toImage(width, height);
  }))!;
}

/// The one-pixel PNG, decoded, for a [_LaterImage] to deliver.
Future<ui.Image> _decoded(WidgetTester tester) async {
  return (await tester.runAsync(() async {
    final ui.Codec codec = await ui.instantiateImageCodec(_onePixelPng);

    return (await codec.getNextFrame()).image;
  }))!;
}

Future<void> _pump(WidgetTester tester, Widget child, {bool overlay = false}) async {
  // `overlay` for the preview tests: a `PlOverlay` lifts itself out of the tree
  // through an `OverlayPortal`, and in a real app the place it goes is the
  // navigator's overlay. A test that asks for one gets the bare `Overlay`.
  await tester.pumpWidget(host(child, width: 200, height: 200, overlay: overlay));
  await tester.pump();
}

void main() {
  group('PlImage', () {
    group('the picture', () {
      testWidgets('draws an Image', (WidgetTester tester) async {
        await _pump(tester, PlImage(image: _ok, semanticLabel: 'A portrait'));

        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('names it once, from the outside', (WidgetTester tester) async {
        await _pump(tester, PlImage(image: _ok, semanticLabel: 'A portrait'));

        // The `Image` itself is excluded, so the name is the wrapper's and is
        // never read twice.
        expect(tester.widget<Image>(find.byType(Image).first).excludeFromSemantics, isTrue);
        expect(
          find.byWidgetPredicate(
            (Widget widget) => widget is Semantics && widget.properties.label == 'A portrait',
          ),
          findsOneWidget,
        );
      });

      testWidgets('says nothing when it is decorative', (WidgetTester tester) async {
        await _pump(tester, PlImage(image: _ok));

        // A null label marks the picture decorative rather than unnamed.
        expect(
          find.byWidgetPredicate(
            (Widget widget) => widget is Semantics && widget.properties.label != null,
          ),
          findsNothing,
        );
      });
    });

    group('the space it reserves', () {
      testWidgets('holds the proportion it was given', (WidgetTester tester) async {
        await _pump(tester, PlImage(image: _ok, ratio: 16 / 9, semanticLabel: 'A portrait'));

        expect(
          tester.widget<AspectRatio>(find.byType(AspectRatio)).aspectRatio,
          closeTo(16 / 9, 0.001),
        );
      });

      testWidgets('holds nothing without one', (WidgetTester tester) async {
        await _pump(tester, PlImage(image: _ok, semanticLabel: 'A portrait'));

        // Honest rather than helpful: with no ratio there is nothing to reserve.
        expect(find.byType(AspectRatio), findsNothing);
      });

      testWidgets('clips whatever overflows it', (WidgetTester tester) async {
        await _pump(tester, PlImage(image: _ok, rounded: true, semanticLabel: 'A portrait'));

        expect(find.byType(ClipRRect), findsOneWidget);
      });
    });

    group('while it is loading', () {
      testWidgets('draws a placeholder of its own when it has one', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlImage(
            image: _PendingImage(),
            semanticLabel: 'A portrait',
            placeholder: Text('Loading…'),
          ),
        );

        expect(find.text('Loading…'), findsOneWidget);
      });

      testWidgets('draws a skeleton otherwise', (WidgetTester tester) async {
        await _pump(tester, const PlImage(image: _PendingImage(), semanticLabel: 'A portrait'));

        expect(find.byType(PlSkeleton), findsOneWidget);
      });

      testWidgets('holds the picture at nothing under the placeholder', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const PlImage(image: _PendingImage(), semanticLabel: 'A portrait'));

        // Built rather than absent, and at zero: a widget created at 1 has
        // nothing to travel from, so the picture would arrive on one frame.
        expect(tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity, 0);
      });

      testWidgets('fades the picture in once it arrives', (WidgetTester tester) async {
        final Completer<ImageInfo> arrival = Completer<ImageInfo>();

        await _pump(
          tester,
          PlImage(image: _LaterImage(arrival), ratio: 1, semanticLabel: 'A portrait'),
        );

        final State<StatefulWidget> waiting = tester.state(find.byType(AnimatedOpacity));

        arrival.complete(ImageInfo(image: await _decoded(tester)));
        await tester.pump();
        await tester.pump(PlassTokens.duration ~/ 3);

        // The same fade that was waiting at zero, on its way to one. Built again
        // instead, it would start at one and the picture would cut in.
        expect(tester.state(find.byType(AnimatedOpacity)), same(waiting));
        expect(
          tester
              .widget<FadeTransition>(
                find.descendant(
                  of: find.byType(AnimatedOpacity),
                  matching: find.byType(FadeTransition),
                ),
              )
              .opacity
              .value,
          allOf(greaterThan(0), lessThan(1)),
        );
        expect(find.byType(PlSkeleton), findsNothing);
      });
    });

    group('when it does not arrive', () {
      testWidgets('draws the label rather than a gap', (WidgetTester tester) async {
        await _pump(tester, PlImage(image: _broken, semanticLabel: 'A portrait'));
        await tester.pumpAndSettle();

        expect(find.text('A portrait'), findsOneWidget);
      });

      testWidgets('draws a fallback of its own when it has one', (WidgetTester tester) async {
        await _pump(
          tester,
          PlImage(image: _broken, semanticLabel: 'A portrait', fallback: const Text('No photo')),
        );
        await tester.pumpAndSettle();

        expect(find.text('No photo'), findsOneWidget);
      });

      testWidgets('reports the failure', (WidgetTester tester) async {
        PlImageStatus? status;

        await _pump(
          tester,
          PlImage(
            image: _broken,
            semanticLabel: 'A portrait',
            onStatusChanged: (PlImageStatus next) => status = next,
          ),
        );
        await tester.pumpAndSettle();

        expect(status, equals(PlImageStatus.error));
      });

      testWidgets('reports the arrival', (WidgetTester tester) async {
        PlImageStatus? status;

        await _pump(
          tester,
          PlImage(
            image: _ok,
            semanticLabel: 'A portrait',
            onStatusChanged: (PlImageStatus next) => status = next,
          ),
        );
        await tester.pumpAndSettle();

        expect(status, equals(PlImageStatus.loaded));
      });
    });

    group('rotate', () {
      /// The turn the picture is drawn with, or `null` for none.
      int? turned(WidgetTester tester) {
        final Finder boxes = find.descendant(
          of: find.byType(PlImage),
          matching: find.byType(RotatedBox),
        );

        return boxes.evaluate().isEmpty
            ? null
            : tester.widget<RotatedBox>(boxes.first).quarterTurns;
      }

      /// A [PlImage] of a 120 by 80 picture, arrived.
      Future<void> pumpArrived(
        WidgetTester tester,
        PlImage Function(ImageProvider<Object>) build,
      ) async {
        final Completer<ImageInfo> arrival = Completer<ImageInfo>();

        await tester.pumpWidget(host(build(_LaterImage(arrival)), width: 120));
        arrival.complete(ImageInfo(image: await _blank(tester, 120, 80)));
        await tester.pumpAndSettle();
      }

      testWidgets('turns nothing until it is asked to', (WidgetTester tester) async {
        await _pump(tester, PlImage(image: _ok, semanticLabel: 'A portrait'));
        await tester.pumpAndSettle();

        expect(turned(tester), isNull);
      });

      testWidgets('turns a quarter at a time', (WidgetTester tester) async {
        await _pump(tester, PlImage(image: _ok, semanticLabel: 'A portrait', rotate: 270));
        await tester.pumpAndSettle();

        expect(turned(tester), 3);
      });

      testWidgets('takes any other number to the nearest quarter', (WidgetTester tester) async {
        await _pump(tester, PlImage(image: _ok, semanticLabel: 'A portrait', rotate: -90));
        await tester.pumpAndSettle();

        expect(turned(tester), 3);

        await _pump(tester, PlImage(image: _ok, semanticLabel: 'A portrait', rotate: 450));
        await tester.pumpAndSettle();

        expect(turned(tester), 1);
      });

      testWidgets('takes the turned shape of the picture without a ratio', (
        WidgetTester tester,
      ) async {
        await pumpArrived(
          tester,
          (ImageProvider<Object> image) =>
              PlImage(image: image, semanticLabel: 'A portrait', rotate: 90),
        );

        // A 120 by 80 picture on its side, 120 wide: two wide by three tall.
        expect(tester.getSize(find.byType(PlImage)), const Size(120, 180));
      });

      testWidgets('keeps the shape of an upright picture on a half turn', (
        WidgetTester tester,
      ) async {
        await pumpArrived(
          tester,
          (ImageProvider<Object> image) =>
              PlImage(image: image, semanticLabel: 'A portrait', rotate: 180),
        );

        expect(tester.getSize(find.byType(PlImage)), const Size(120, 80));
      });

      testWidgets('keeps a ratio of the caller’s own and fits the turned picture to it', (
        WidgetTester tester,
      ) async {
        await pumpArrived(
          tester,
          (ImageProvider<Object> image) => PlImage(
            image: image,
            semanticLabel: 'A portrait',
            ratio: 1,
            fit: PlAspectFit.contain,
            rotate: 90,
          ),
        );

        // The ratio is the layout's shape. The picture is laid out on its side
        // inside it, so the raw image fills the box it was turned into.
        expect(tester.getSize(find.byType(PlImage)), const Size(120, 120));
        expect(tester.getSize(find.byType(RawImage)), const Size(120, 120));
      });

      testWidgets('leaves the placeholder upright', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlImage(image: _PendingImage(), semanticLabel: 'A portrait', ratio: 1, rotate: 90),
        );

        expect(
          find.descendant(of: find.byType(RotatedBox), matching: find.byType(PlSkeleton)),
          findsNothing,
        );
      });

      testWidgets('opens the preview turned', (WidgetTester tester) async {
        await _pump(
          tester,
          PlImage(image: _ok, ratio: 1, semanticLabel: 'A portrait', preview: true, rotate: 90),
          overlay: true,
        );
        await tester.pumpAndSettle();

        final Finder opened = find.descendant(
          of: find.byType(PlOverlay),
          matching: find.byType(RotatedBox),
        );

        expect(opened, findsNothing);

        await tester.tap(find.byType(PlImage));
        await tester.pumpAndSettle();

        expect(opened, findsOneWidget);
      });
    });

    group('flip', () {
      /// The mirror the picture is drawn with, as the signs of the matrix's two
      /// scales, or `null` for none.
      (double, double)? mirrored(WidgetTester tester, {Finder? within}) {
        final Finder flips = find.descendant(
          of: within ?? find.byType(PlImage),
          matching: find.byWidgetPredicate(
            (Widget widget) =>
                widget is Transform &&
                (widget.transform.entry(0, 0) < 0 || widget.transform.entry(1, 1) < 0),
          ),
        );

        if (flips.evaluate().isEmpty) {
          return null;
        }

        final Matrix4 matrix = tester.widget<Transform>(flips.first).transform;

        return (matrix.entry(0, 0), matrix.entry(1, 1));
      }

      testWidgets('mirrors nothing until it is asked to', (WidgetTester tester) async {
        await _pump(tester, PlImage(image: _ok, semanticLabel: 'A portrait'));
        await tester.pumpAndSettle();

        expect(mirrored(tester), isNull);
      });

      testWidgets('mirrors along the axis it names', (WidgetTester tester) async {
        await _pump(
          tester,
          PlImage(image: _ok, semanticLabel: 'A portrait', flip: PlImageFlip.horizontal),
        );
        await tester.pumpAndSettle();

        expect(mirrored(tester), (-1.0, 1.0));

        await _pump(
          tester,
          PlImage(image: _ok, semanticLabel: 'A portrait', flip: PlImageFlip.vertical),
        );
        await tester.pumpAndSettle();

        expect(mirrored(tester), (1.0, -1.0));

        await _pump(
          tester,
          PlImage(image: _ok, semanticLabel: 'A portrait', flip: PlImageFlip.both),
        );
        await tester.pumpAndSettle();

        expect(mirrored(tester), (-1.0, -1.0));
      });

      testWidgets('mirrors the screen’s axes over a turn', (WidgetTester tester) async {
        await _pump(
          tester,
          PlImage(
            image: _ok,
            semanticLabel: 'A portrait',
            flip: PlImageFlip.horizontal,
            rotate: 90,
          ),
        );
        await tester.pumpAndSettle();

        // Outside the turn, so left and right on the screen are what swap: the
        // mirror holds the turn rather than the other way round.
        expect(mirrored(tester), (-1.0, 1.0));
        expect(
          find.descendant(of: find.byType(Transform), matching: find.byType(RotatedBox)),
          findsOneWidget,
        );
      });

      testWidgets('opens the preview mirrored', (WidgetTester tester) async {
        await _pump(
          tester,
          PlImage(
            image: _ok,
            ratio: 1,
            semanticLabel: 'A portrait',
            preview: true,
            flip: PlImageFlip.vertical,
          ),
          overlay: true,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(PlImage));
        await tester.pumpAndSettle();

        expect(mirrored(tester, within: find.byType(PlOverlay)), (1.0, -1.0));
      });
    });

    group('filter', () {
      /// The filter the picture is actually drawn through, or `null`.
      ColorFilter? applied(WidgetTester tester) {
        final Finder filtered = find.descendant(
          of: find.byType(PlImage),
          matching: find.byType(ColorFiltered),
        );

        return filtered.evaluate().isEmpty
            ? null
            : tester.widget<ColorFiltered>(filtered.first).colorFilter;
      }

      testWidgets('draws nothing of its own until it is asked to', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlImage(image: _ok, semanticLabel: 'A portrait')));
        await tester.pumpAndSettle();

        expect(applied(tester), isNull);
      });

      testWidgets('resolves a named treatment to a colour matrix', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlImage(image: _ok, semanticLabel: 'A portrait', filter: PlImageFilter.grayscale)),
        );
        await tester.pumpAndSettle();

        // The same numbers the React build writes into its `filter` chain, so
        // the two packages agree about what `grayscale` looks like.
        expect(applied(tester), saturationFilter(0));
      });

      testWidgets('lets a colorFilter of its own win', (WidgetTester tester) async {
        const ColorFilter own = ColorFilter.mode(Color(0x330000FF), BlendMode.srcOver);

        await tester.pumpWidget(
          host(
            PlImage(
              image: _ok,
              semanticLabel: 'A portrait',
              filter: PlImageFilter.sepia,
              colorFilter: own,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // A caller who reached for the escape hatch has already said the names
        // did not cover it.
        expect(applied(tester), own);
      });

      testWidgets('treats the picture and not the placeholder', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlImage(
              image: _PendingImage(),
              semanticLabel: 'A portrait',
              filter: PlImageFilter.grayscale,
            ),
          ),
        );
        await tester.pump();

        // A greyed-out skeleton is not what `grayscale` was asked for.
        expect(find.byType(PlSkeleton), findsOneWidget);
        expect(
          find.descendant(of: find.byType(ColorFiltered), matching: find.byType(PlSkeleton)),
          findsNothing,
        );
      });
    });

    group('watermark', () {
      testWidgets('draws nothing until it is asked to', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlImage(image: _ok, semanticLabel: 'A portrait')));
        await tester.pumpAndSettle();

        expect(find.byType(PlassWatermarkLayer), findsNothing);
      });

      testWidgets('puts the text in a corner', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlImage(
              image: _ok,
              semanticLabel: 'A portrait',
              watermark: const PlImageWatermark('© Ada & Co'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('© Ada & Co'), findsOneWidget);
      });

      testWidgets('is off the semantics tree and takes no pointer', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlImage(
              image: _ok,
              semanticLabel: 'A portrait',
              watermark: const PlImageWatermark('© Ada & Co'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // A watermark is a claim about the file, not something the screen is
        // telling a reader. The label is where a picture says what it is.
        expect(
          find.descendant(of: find.byType(PlImage), matching: find.bySemanticsLabel('© Ada & Co')),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byType(PlassWatermarkLayer),
            matching: find.byType(IgnorePointer),
          ),
          findsOneWidget,
        );
      });

      testWidgets('waits for the picture before it stamps it', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlImage(
              image: _PendingImage(),
              semanticLabel: 'A portrait',
              watermark: PlImageWatermark('© Ada & Co'),
            ),
          ),
        );
        await tester.pump();

        // A stamp over a skeleton is a claim about a file that has not arrived.
        expect(find.byType(PlassWatermarkLayer), findsNothing);
      });

      testWidgets('paints a tiled mark rather than stacking widgets', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlImage(
              image: _ok,
              semanticLabel: 'A portrait',
              watermark: const PlImageWatermark('PROOF', placement: PlImageWatermarkPlacement.tile),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // One painter for however many copies the box holds, not one widget per
        // copy.
        expect(find.text('PROOF'), findsNothing);
        expect(
          find.descendant(of: find.byType(PlassWatermarkLayer), matching: find.byType(CustomPaint)),
          findsWidgets,
        );
      });

      testWidgets('takes its own opacity when it is given one', (WidgetTester tester) async {
        const PlImageWatermark corner = PlImageWatermark('© Ada & Co', opacity: 0.3);
        const PlImageWatermark tiled = PlImageWatermark(
          'PROOF',
          placement: PlImageWatermarkPlacement.tile,
        );

        // A mark that covers everything has to be fainter than one that covers a
        // corner, which is why the two defaults differ.
        expect(corner.resolvedOpacity, 0.3);
        expect(tiled.resolvedOpacity, lessThan(const PlImageWatermark('x').resolvedOpacity));
      });
    });

    group('preview', () {
      testWidgets('is not a button unless it is asked to be', (WidgetTester tester) async {
        await _pump(tester, PlImage(image: _ok, semanticLabel: 'A portrait'));

        expect(find.byType(PlOverlay), findsNothing);
      });

      testWidgets('opens over the page once the picture has arrived', (WidgetTester tester) async {
        // A `ratio` on purpose: without one the picture is its own intrinsic
        // size, which for a one-pixel PNG is one pixel — and a tap aimed at the
        // middle of the box would land beside it.
        await _pump(
          tester,
          PlImage(image: _ok, ratio: 1, semanticLabel: 'A portrait', preview: true),
          overlay: true,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(PlImage));
        await tester.pumpAndSettle();

        // Two pictures now: the one on the page and the one over it.
        expect(find.byType(Image), findsNWidgets(2));
      });

      testWidgets('cannot be opened before it has', (WidgetTester tester) async {
        await _pump(
          tester,
          PlImage(image: _broken, ratio: 1, semanticLabel: 'A portrait', preview: true),
          overlay: true,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(PlImage), warnIfMissed: false);
        await tester.pumpAndSettle();

        // There is nothing to preview yet.
        expect(find.byType(Image), findsOneWidget);
      });
    });
  });
}
