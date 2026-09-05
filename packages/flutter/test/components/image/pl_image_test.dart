// The pictures here are built from bytes in the test file, so nothing depends
// on a network or on a file on disk — a one-pixel PNG that always decodes, and
// a buffer that is not an image and therefore always fails.
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/css.dart';

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
