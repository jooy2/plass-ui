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

/// Delivers the one-pixel PNG to a [_LaterImage], and pumps until a frame has
/// been built with the picture in it.
///
/// The stream tells its listeners a task after the future completes, so the
/// frame the picture is first built on is one or two pumps later depending on
/// what else the run has queued. A fade measured from before that frame is
/// measured from a moment it had not started at.
Future<void> _arrive(WidgetTester tester, Completer<ImageInfo> arrival) async {
  arrival.complete(ImageInfo(image: await _decoded(tester)));

  final Finder fade = find.byWidgetPredicate(
    (Widget widget) => widget is AnimatedOpacity && widget.curve is! Threshold,
  );

  for (int tries = 0; tries < 10; tries += 1) {
    await tester.pump();

    if (tester.widget<AnimatedOpacity>(fade).opacity == 1) {
      return;
    }
  }

  fail('the picture never arrived');
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

    group('fit', () {
      testWidgets('covers the box by default', (WidgetTester tester) async {
        await _pump(tester, PlImage(image: _ok, semanticLabel: 'A portrait'));

        expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.cover);
      });

      testWidgets('scales a picture down without ever enlarging it', (WidgetTester tester) async {
        await _pump(
          tester,
          PlImage(image: _ok, semanticLabel: 'A portrait', fit: PlAspectFit.scaleDown),
        );

        expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.scaleDown);
      });
    });

    group('position', () {
      Alignment placed(WidgetTester tester) {
        return tester.widget<Image>(find.byType(Image)).alignment as Alignment;
      }

      testWidgets('sits in the middle by default', (WidgetTester tester) async {
        await _pump(tester, PlImage(image: _ok, semanticLabel: 'A portrait', rotate: 90));

        expect(placed(tester), Alignment.center);
      });

      testWidgets('keeps the side it names on an upright picture', (WidgetTester tester) async {
        await _pump(
          tester,
          PlImage(image: _ok, semanticLabel: 'A portrait', position: Alignment.topCenter),
        );

        expect(placed(tester), Alignment.topCenter);
      });

      testWidgets('keeps the top of what is shown through a half turn', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlImage(
            image: _ok,
            semanticLabel: 'A portrait',
            position: Alignment.topCenter,
            rotate: 180,
          ),
        );

        expect(placed(tester), Alignment.bottomCenter);
      });

      testWidgets('keeps the top of what is shown through a quarter turn', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlImage(
            image: _ok,
            semanticLabel: 'A portrait',
            position: Alignment.topCenter,
            rotate: 90,
          ),
        );

        // The picture's left edge is what lies along the top of the screen.
        expect(placed(tester), Alignment.centerLeft);
      });

      testWidgets('keeps the side it names through a mirror', (WidgetTester tester) async {
        await _pump(
          tester,
          PlImage(
            image: _ok,
            semanticLabel: 'A portrait',
            position: Alignment.centerLeft,
            flip: PlImageFlip.horizontal,
          ),
        );

        expect(placed(tester), Alignment.centerRight);
      });

      testWidgets('stays physical under a right-to-left direction', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlImage(image: _ok, semanticLabel: 'A portrait', position: const Alignment(-0.4, 0)),
            textDirection: TextDirection.rtl,
          ),
        );

        expect(placed(tester), const Alignment(-0.4, 0));
      });
    });

    group('letterbox', () {
      Finder copy() {
        return find.descendant(of: find.byType(ImageFiltered), matching: find.byType(Image));
      }

      testWidgets('fills nothing until it is asked to', (WidgetTester tester) async {
        await _pump(
          tester,
          PlImage(image: _ok, ratio: 1, semanticLabel: 'A portrait', fit: PlAspectFit.contain),
        );

        expect(find.byType(ImageFiltered), findsNothing);
        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('paints a decoration behind the picture', (WidgetTester tester) async {
        const BoxDecoration decoration = BoxDecoration(color: Color(0xFF101418));

        await _pump(
          tester,
          PlImage(
            image: _ok,
            ratio: 1,
            semanticLabel: 'A portrait',
            fit: PlAspectFit.contain,
            letterbox: const PlImageLetterbox(decoration),
          ),
        );

        final Finder painted = find.byWidgetPredicate(
          (Widget widget) => widget is DecoratedBox && widget.decoration == decoration,
        );

        expect(painted, findsOneWidget);
        expect(find.descendant(of: painted, matching: find.byType(Image)), findsOneWidget);
        expect(find.byType(ImageFiltered), findsNothing);
      });

      testWidgets('draws one blurred copy of the picture for blur', (WidgetTester tester) async {
        await _pump(
          tester,
          PlImage(
            image: _ok,
            ratio: 1,
            semanticLabel: 'A portrait',
            fit: PlAspectFit.contain,
            letterbox: PlImageLetterbox.blur,
          ),
        );
        await tester.pumpAndSettle();

        expect(copy(), findsOneWidget);
        expect(
          tester.widget<ImageFiltered>(find.byType(ImageFiltered)).imageFilter,
          ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        );

        final Image drawn = tester.widget<Image>(copy());

        // The same picture, answered from the same cache entry, covering the box.
        expect(drawn.image, same(_ok));
        expect(drawn.fit, BoxFit.cover);
        expect(drawn.excludeFromSemantics, isTrue);
        expect(
          find.ancestor(of: find.byType(ImageFiltered), matching: find.byType(IgnorePointer)),
          findsWidgets,
        );
        // Grown past the 200 by 200 box by two radii on every side.
        expect(tester.getSize(find.byType(ImageFiltered)), const Size(296, 296));
      });

      testWidgets('turns, mirrors and places the copy the way the picture is', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlImage(
            image: _ok,
            ratio: 1,
            semanticLabel: 'A portrait',
            fit: PlAspectFit.none,
            letterbox: PlImageLetterbox.blur,
            rotate: 90,
            flip: PlImageFlip.vertical,
            position: Alignment.topCenter,
          ),
        );
        await tester.pumpAndSettle();

        // The copy is drawn inside the picture's own frame, so the picture is
        // the outer of the two.
        final Image shown = tester.widget<Image>(find.byType(Image).first);

        expect(shown.alignment, isNot(Alignment.center));
        expect(tester.widget<Image>(copy()).alignment, shown.alignment);
        expect(
          find.descendant(of: find.byType(ImageFiltered), matching: find.byType(RotatedBox)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: find.byType(ImageFiltered), matching: find.byType(Transform)),
          findsWidgets,
        );
      });

      testWidgets('draws no copy under a fit that leaves no space', (WidgetTester tester) async {
        for (final PlAspectFit fit in <PlAspectFit>[PlAspectFit.cover, PlAspectFit.fill]) {
          await _pump(
            tester,
            PlImage(
              image: _ok,
              ratio: 1,
              semanticLabel: 'A portrait',
              fit: fit,
              letterbox: PlImageLetterbox.blur,
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(ImageFiltered), findsNothing);
        }
      });
    });

    group('width and height', () {
      Future<void> pumpIn(WidgetTester tester, Widget child) async {
        // A width to be given and a height left open, the way a column of
        // content lays a picture out.
        await tester.pumpWidget(host(child, width: 200));
        await tester.pumpAndSettle();
      }

      testWidgets('sizes the box to a lone height, across the width it is given', (
        WidgetTester tester,
      ) async {
        await pumpIn(tester, PlImage(image: _ok, semanticLabel: 'A portrait', height: 120));

        expect(tester.getSize(find.byType(ClipRRect)), const Size(200, 120));
      });

      testWidgets('takes the width from a ratio beside a lone height', (WidgetTester tester) async {
        await pumpIn(
          tester,
          PlImage(image: _ok, semanticLabel: 'A portrait', height: 60, ratio: 3 / 2),
        );

        expect(tester.getSize(find.byType(ClipRRect)), const Size(90, 60));
      });

      testWidgets('sizes the box to a lone width, never wider than the space it has', (
        WidgetTester tester,
      ) async {
        await pumpIn(tester, PlImage(image: _ok, semanticLabel: 'A portrait', width: 80, ratio: 1));

        expect(tester.getSize(find.byType(ClipRRect)), const Size(80, 80));

        await pumpIn(
          tester,
          PlImage(image: _ok, semanticLabel: 'A portrait', width: 800, ratio: 1),
        );

        expect(tester.getSize(find.byType(ClipRRect)), const Size(200, 200));
      });

      testWidgets('sits a narrowed box at the start of its space', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlImage(image: _ok, semanticLabel: 'A portrait', width: 80, ratio: 1),
            width: 200,
            textDirection: TextDirection.rtl,
          ),
        );
        await tester.pumpAndSettle();

        // The start of a right-to-left line is its right-hand edge.
        expect(
          tester.getTopRight(find.byType(ClipRRect)),
          tester.getTopRight(find.byType(PlImage)),
        );
        expect(tester.getSize(find.byType(ClipRRect)), const Size(80, 80));
      });

      testWidgets('keeps the proportion of the two together', (WidgetTester tester) async {
        await pumpIn(
          tester,
          PlImage(image: _ok, semanticLabel: 'A portrait', width: 1200, height: 800),
        );

        expect(tester.getSize(find.byType(ClipRRect)), const Size(200, 400 / 3));
      });

      testWidgets('turns the proportion of the two for a picture on its side', (
        WidgetTester tester,
      ) async {
        await pumpIn(
          tester,
          PlImage(image: _ok, semanticLabel: 'A portrait', width: 1200, height: 800, rotate: 90),
        );

        expect(tester.getSize(find.byType(ClipRRect)), const Size(200, 300));
      });

      testWidgets('narrows a preview’s press target and focus ring to the box', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlImage(image: _ok, semanticLabel: 'A portrait', width: 80, ratio: 1, preview: true),
            width: 200,
            overlay: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          tester.getSize(
            find.byWidgetPredicate(
              (Widget widget) => widget is Semantics && widget.properties.label == 'A portrait',
            ),
          ),
          const Size(80, 80),
        );
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

        await _arrive(tester, arrival);
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

    group('a picture placeholder', () {
      final MemoryImage tiny = MemoryImage(_onePixelPng);

      Finder standIn() {
        return find.byWidgetPredicate((Widget widget) => widget is Image && widget.image == tiny);
      }

      testWidgets('stands in for the picture instead of the skeleton', (WidgetTester tester) async {
        await _pump(
          tester,
          PlImage(
            image: const _PendingImage(),
            ratio: 1,
            semanticLabel: 'A portrait',
            placeholder: PlImagePlaceholder(image: tiny),
          ),
        );

        expect(standIn(), findsOneWidget);
        expect(find.byType(PlSkeleton), findsNothing);
        expect(tester.widget<Image>(standIn()).excludeFromSemantics, isTrue);
        expect(find.ancestor(of: standIn(), matching: find.byType(IgnorePointer)), findsWidgets);
        // Filling the box, under a picture that is still at nothing.
        expect(tester.getSize(standIn()), const Size(200, 200));
      });

      testWidgets('is not taken for a placeholder of the caller’s own', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const PlImage(
            image: _PendingImage(),
            semanticLabel: 'A portrait',
            placeholder: Text('Loading…'),
          ),
        );

        expect(find.text('Loading…'), findsOneWidget);
        expect(find.byType(ImageFiltered), findsNothing);
      });

      testWidgets('blurs by the radius it was given, and grows by two of them', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlImage(
            image: const _PendingImage(),
            ratio: 1,
            semanticLabel: 'A portrait',
            placeholder: PlImagePlaceholder(image: tiny, blur: 20),
          ),
        );

        expect(
          tester.widget<ImageFiltered>(find.byType(ImageFiltered)).imageFilter,
          ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        );
        expect(tester.getSize(standIn()), const Size(280, 280));
      });

      testWidgets('is fitted, placed, turned and mirrored the way the picture is', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlImage(
            image: const _PendingImage(),
            ratio: 1,
            semanticLabel: 'A portrait',
            fit: PlAspectFit.contain,
            position: Alignment.topCenter,
            rotate: 270,
            flip: PlImageFlip.horizontal,
            placeholder: PlImagePlaceholder(image: tiny),
          ),
        );

        final Image drawn = tester.widget<Image>(standIn());
        final Image shown = tester.widget<Image>(find.byType(Image).first);

        expect(drawn.fit, BoxFit.contain);
        expect(drawn.alignment, shown.alignment);
        expect(find.ancestor(of: standIn(), matching: find.byType(RotatedBox)), findsOneWidget);
        expect(find.ancestor(of: standIn(), matching: find.byType(Transform)), findsWidgets);
      });

      testWidgets('stays until the picture has faded in over it, then goes in one step', (
        WidgetTester tester,
      ) async {
        final Completer<ImageInfo> arrival = Completer<ImageInfo>();

        await _pump(
          tester,
          PlImage(
            image: _LaterImage(arrival),
            ratio: 1,
            semanticLabel: 'A portrait',
            placeholder: PlImagePlaceholder(image: tiny),
          ),
        );

        double opacity() {
          return tester
              .widget<FadeTransition>(
                find.ancestor(of: standIn(), matching: find.byType(FadeTransition)).first,
              )
              .opacity
              .value;
        }

        expect(opacity(), 1);

        await _arrive(tester, arrival);
        await tester.pump(PlassTokens.duration - const Duration(milliseconds: 10));

        // Still whole while the picture is on its way up over it.
        expect(opacity(), 1);

        await tester.pump(const Duration(milliseconds: 20));

        expect(opacity(), 0);
      });

      testWidgets('is taken away when the picture does not arrive', (WidgetTester tester) async {
        await _pump(
          tester,
          PlImage(
            image: _broken,
            ratio: 1,
            semanticLabel: 'A portrait',
            placeholder: PlImagePlaceholder(image: tiny),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('A portrait'), findsOneWidget);
        expect(standIn(), findsNothing);
      });

      testWidgets('draws nothing and reports nothing when its own file does not load', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlImage(
            image: const _PendingImage(),
            ratio: 1,
            semanticLabel: 'A portrait',
            placeholder: PlImagePlaceholder(image: _broken),
          ),
        );
        await tester.pumpAndSettle();

        // The picture is what reports a failure, and it has not failed.
        expect(tester.takeException(), isNull);
        expect(
          find.descendant(
            of: find.byWidgetPredicate(
              (Widget widget) => widget is Image && widget.image == _broken,
            ),
            matching: find.byType(RawImage),
          ),
          findsNothing,
        );
      });

      testWidgets('draws its picture covering its space when it is built on its own', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(PlImagePlaceholder(image: tiny, blur: 8), width: 120, height: 80),
        );

        expect(tester.widget<Image>(standIn()).fit, BoxFit.cover);
        expect(find.byType(ImageFiltered), findsOneWidget);
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

      testWidgets('opens from a screen reader too', (WidgetTester tester) async {
        await _pump(
          tester,
          PlImage(image: _ok, ratio: 1, semanticLabel: 'A portrait', preview: true),
          overlay: true,
        );
        await tester.pumpAndSettle();

        tester.semantics.tap(find.semantics.byLabel('A portrait'));
        await tester.pumpAndSettle();

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
