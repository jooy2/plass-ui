// The pictures here are built from bytes in the test file, so nothing depends
// on a network or on a file on disk.
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

final Uint8List _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

MemoryImage _picture(int seed) => MemoryImage(_onePixelPng, scale: 1 + seed / 1000);

final List<PlGalleryItem> items = <PlGalleryItem>[
  PlGalleryItem(
    id: 'a',
    image: _picture(1),
    semanticLabel: 'A harbour',
    title: 'Harbour',
    description: 'Busan',
  ),
  PlGalleryItem(id: 'b', image: _picture(2), semanticLabel: 'A bridge', ratio: 1.5),
  PlGalleryItem(id: 'c', image: _picture(3), semanticLabel: 'A hillside', ratio: 0.75),
  PlGalleryItem(id: 'd', image: _picture(4), semanticLabel: 'A market'),
];

/// Pumps a few frames rather than settling.
///
/// `pumpAndSettle` never returns here: a picture that has not decoded yet is a
/// `PlSkeleton`, and a skeleton shimmers forever by design. Two frames and the
/// house duration is enough for every animation this component has.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _pump(WidgetTester tester, Widget child, {double width = 600}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: width, overlay: true));
  await _settle(tester);
}

/// The pictures the gallery drew, by the words on them.
List<String> _pictures(WidgetTester tester) {
  return tester
      .widgetList<PlImage>(find.byType(PlImage))
      .map((PlImage image) => image.semanticLabel ?? '')
      .toList();
}

void main() {
  group('PlGallery', () {
    group('rendering', () {
      testWidgets('is a named set of pictures', (WidgetTester tester) async {
        await _pump(tester, PlGallery(items: items));

        expect(find.bySemanticsLabel('Gallery'), findsOneWidget);
        expect(_pictures(tester), <String>['A harbour', 'A bridge', 'A hillside', 'A market']);
      });

      testWidgets('takes a name of its own', (WidgetTester tester) async {
        await _pump(tester, PlGallery(items: items, semanticLabel: 'Trip photos'));

        expect(find.bySemanticsLabel('Trip photos'), findsOneWidget);
      });

      testWidgets('draws nothing at all for an empty set', (WidgetTester tester) async {
        await _pump(tester, const PlGallery(items: <PlGalleryItem>[]));

        expect(find.byType(PlImage), findsNothing);
      });

      testWidgets('draws what it was given instead, when there is one', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const PlGallery(items: <PlGalleryItem>[], empty: Text('No pictures yet')),
        );

        expect(find.text('No pictures yet'), findsOneWidget);
      });
    });

    group('the layouts', () {
      testWidgets('gives every grid tile the gallery own ratio', (WidgetTester tester) async {
        await _pump(tester, PlGallery(items: items, ratio: 1.5));

        final List<double?> ratios = tester
            .widgetList<PlImage>(find.byType(PlImage))
            .map((PlImage image) => image.ratio)
            .toList();

        expect(ratios, <double>[1.5, 1.5, 1.5, 1.5]);
      });

      testWidgets('keeps each picture own shape in a masonry', (WidgetTester tester) async {
        await _pump(tester, PlGallery(items: items, layout: PlGalleryLayout.masonry, ratio: 1));

        final List<double?> ratios = tester
            .widgetList<PlImage>(find.byType(PlImage))
            .map((PlImage image) => image.ratio)
            .toList();

        expect(ratios.toSet(), <double>{1, 1.5, 0.75});
      });

      testWidgets('lays a justified row out to the width it has', (WidgetTester tester) async {
        await _pump(
          tester,
          PlGallery(items: items, layout: PlGalleryLayout.justified, rowHeight: 120),
          width: 600,
        );

        expect(_pictures(tester).length, 4);
      });

      testWidgets('spans a quilted tile over the cells it asked for', (WidgetTester tester) async {
        await _pump(
          tester,
          PlGallery(
            items: <PlGalleryItem>[
              PlGalleryItem(
                id: 'wide',
                image: _picture(1),
                semanticLabel: 'A harbour',
                cols: 2,
                rows: 2,
              ),
              items[1],
            ],
            layout: PlGalleryLayout.quilted,
            columns: const PlassResponsive<int>(3),
            rowHeight: 100,
            gap: 0,
          ),
          width: 300,
        );

        final Size wide = tester.getSize(find.byType(PlImage).first);

        // Two of three 100px columns wide, two 100px rows tall.
        expect(wide.width, closeTo(200, 0.5));
        expect(wide.height, closeTo(200, 0.5));
      });
    });

    group('captions', () {
      testWidgets('says nothing by default', (WidgetTester tester) async {
        await _pump(tester, PlGallery(items: items));

        expect(find.text('Harbour'), findsNothing);
      });

      testWidgets('writes the two lines under the picture', (WidgetTester tester) async {
        await _pump(tester, PlGallery(items: items, caption: PlGalleryCaption.below));

        expect(find.text('Harbour'), findsOneWidget);
        expect(find.text('Busan'), findsOneWidget);
      });

      testWidgets('leaves the caption out of a tile that has no words', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlGallery(items: items, caption: PlGalleryCaption.below));

        // Only the first of the four items has any.
        expect(find.text('A bridge'), findsNothing);
      });
    });

    group('choosing', () {
      testWidgets('is not a button unless something happens when it is pressed', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlGallery(items: items));

        // The picture still names itself; what is absent is the tile's own
        // button, which is the picture's words plus where in the set it sits.
        expect(find.bySemanticsLabel(RegExp('A harbour — ')), findsNothing);
        expect(find.bySemanticsLabel('A harbour'), findsOneWidget);
      });

      testWidgets('reports the tile that was chosen', (WidgetTester tester) async {
        PlGalleryItem? seen;
        int? at;

        await _pump(
          tester,
          PlGallery(
            items: items,
            onItemSelected: (PlGalleryItem item, int index) {
              seen = item;
              at = index;
            },
          ),
        );

        await tester.tap(find.bySemanticsLabel('A bridge — 2 of 4'));
        await _settle(tester);

        expect(seen, items[1]);
        expect(at, 1);
      });

      testWidgets('names a tile by its picture and its place in the set', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlGallery(items: items, onItemSelected: (PlGalleryItem _, int _) {}));

        expect(find.bySemanticsLabel('A harbour — 1 of 4'), findsOneWidget);
      });

      testWidgets('takes its own way of saying where in the set a tile is', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlGallery(
            items: items,
            onItemSelected: (PlGalleryItem _, int _) {},
            itemLabel: (int index, int total) => '$index번째 / 전체 $total',
          ),
        );

        expect(find.bySemanticsLabel('A harbour — 1번째 / 전체 4'), findsOneWidget);
      });
    });

    group('turned and fitted pictures', () {
      final List<PlGalleryItem> turned = <PlGalleryItem>[
        PlGalleryItem(
          id: 'a',
          image: _picture(1),
          semanticLabel: 'A harbour',
          ratio: 2,
          rotate: 90,
        ),
        PlGalleryItem(id: 'b', image: _picture(2), semanticLabel: 'A bridge', ratio: 1.5),
      ];

      PlImage imageOf(WidgetTester tester, String label) {
        return tester
            .widgetList<PlImage>(find.byType(PlImage))
            .firstWhere((PlImage image) => image.semanticLabel == label);
      }

      testWidgets('lays a turned picture out on its side in a masonry', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlGallery(
            items: turned,
            layout: PlGalleryLayout.masonry,
            columns: const PlassResponsive<int>(1),
          ),
          width: 200,
        );

        expect(imageOf(tester, 'A harbour').ratio, closeTo(0.5, 0.0001));
        expect(imageOf(tester, 'A bridge').ratio, 1.5);
        // One wide by two tall across the 200 the lane has.
        expect(tester.getSize(find.byWidget(imageOf(tester, 'A harbour'))), const Size(200, 400));
      });

      testWidgets('deals a masonry by the height a turned picture really has', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlGallery(
            items: <PlGalleryItem>[
              PlGalleryItem(id: 'a', image: _picture(1), semanticLabel: 'A', ratio: 2, rotate: 90),
              PlGalleryItem(id: 'b', image: _picture(2), semanticLabel: 'B', ratio: 2),
              PlGalleryItem(id: 'c', image: _picture(3), semanticLabel: 'C', ratio: 2),
            ],
            layout: PlGalleryLayout.masonry,
            columns: const PlassResponsive<int>(2),
          ),
        );

        // On its side the first picture is four times as tall as the second, so
        // the third goes under the second rather than under the first.
        final double left = tester.getTopLeft(find.bySemanticsLabel('B')).dx;

        expect(tester.getTopLeft(find.bySemanticsLabel('C')).dx, left);
      });

      testWidgets('keeps the gallery’s shape for a turned grid tile', (WidgetTester tester) async {
        await _pump(tester, PlGallery(items: turned, ratio: 1.5));

        expect(imageOf(tester, 'A harbour').ratio, 1.5);
      });

      testWidgets('hands each item’s own turn, mirror, position and stand-in to its picture', (
        WidgetTester tester,
      ) async {
        final PlImagePlaceholder standIn = PlImagePlaceholder(image: _picture(7), blur: 20);

        await _pump(
          tester,
          PlGallery(
            items: <PlGalleryItem>[
              PlGalleryItem(
                id: 'a',
                image: _picture(1),
                semanticLabel: 'A harbour',
                rotate: 180,
                flip: PlImageFlip.horizontal,
                position: Alignment.topCenter,
                placeholder: standIn,
              ),
            ],
          ),
        );

        final PlImage image = imageOf(tester, 'A harbour');

        expect(image.rotate, 180);
        expect(image.flip, PlImageFlip.horizontal);
        expect(image.position, Alignment.topCenter);
        expect(image.placeholder, same(standIn));
      });

      testWidgets('hands the gallery’s fit and letterbox to every picture', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlGallery(items: turned, fit: PlAspectFit.contain, letterbox: PlImageLetterbox.blur),
        );

        for (final PlImage image in tester.widgetList<PlImage>(find.byType(PlImage))) {
          expect(image.fit, PlAspectFit.contain);
          expect(image.letterbox, PlImageLetterbox.blur);
        }
      });

      testWidgets('covers by default', (WidgetTester tester) async {
        await _pump(tester, PlGallery(items: turned));

        expect(imageOf(tester, 'A bridge').fit, PlAspectFit.cover);
        expect(imageOf(tester, 'A bridge').letterbox, isNull);
      });

      testWidgets('opens a turned, mirrored picture the way its tile shows it', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlGallery(
            items: <PlGalleryItem>[
              PlGalleryItem(
                id: 'a',
                image: _picture(1),
                semanticLabel: 'A harbour',
                ratio: 2,
                rotate: 90,
                flip: PlImageFlip.vertical,
              ),
            ],
            preview: true,
          ),
        );

        final Finder viewer = find.byType(PlOverlay);

        expect(find.descendant(of: viewer, matching: find.byType(RotatedBox)), findsNothing);

        await tester.tap(find.bySemanticsLabel('A harbour — 1 of 1'));
        await _settle(tester);

        final Finder turnedBox = find.descendant(of: viewer, matching: find.byType(RotatedBox));

        expect(tester.widget<RotatedBox>(turnedBox).quarterTurns, 1);
        expect(
          find.ancestor(
            of: turnedBox,
            matching: find.byWidgetPredicate(
              (Widget widget) => widget is Transform && widget.transform.entry(1, 1) < 0,
            ),
          ),
          findsOneWidget,
        );
      });
    });

    group('the viewer', () {
      testWidgets('is not up until a tile is pressed', (WidgetTester tester) async {
        await _pump(tester, PlGallery(items: items, preview: true));

        expect(find.text('1 of 4'), findsNothing);
      });

      testWidgets('opens the picture that was chosen', (WidgetTester tester) async {
        await _pump(tester, PlGallery(items: items, preview: true));

        await tester.tap(find.bySemanticsLabel('A bridge — 2 of 4'));
        await _settle(tester);

        expect(find.text('2 of 4'), findsOneWidget);
      });

      testWidgets('prefers the larger file when there is one', (WidgetTester tester) async {
        final MemoryImage big = _picture(9);

        await _pump(
          tester,
          PlGallery(
            items: <PlGalleryItem>[
              PlGalleryItem(id: 'a', image: _picture(1), full: big, semanticLabel: 'A harbour'),
            ],
            preview: true,
          ),
        );

        await tester.tap(find.bySemanticsLabel('A harbour — 1 of 1'));
        await _settle(tester);

        final Iterable<Image> shown = tester.widgetList<Image>(find.byType(Image));

        expect(shown.any((Image image) => identical(image.image, big)), isTrue);
      });

      testWidgets('walks the set with the arrow keys', (WidgetTester tester) async {
        await _pump(tester, PlGallery(items: items, preview: true));

        await tester.tap(find.bySemanticsLabel('A harbour — 1 of 4'));
        await _settle(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await _settle(tester);
        expect(find.text('2 of 4'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await _settle(tester);
        expect(find.text('1 of 4'), findsOneWidget);
      });

      testWidgets('stops at the ends rather than wrapping', (WidgetTester tester) async {
        await _pump(tester, PlGallery(items: items, preview: true));

        await tester.tap(find.bySemanticsLabel('A harbour — 1 of 4'));
        await _settle(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await _settle(tester);

        expect(find.text('1 of 4'), findsOneWidget);
      });

      testWidgets('offers no arrows for a set of one', (WidgetTester tester) async {
        await _pump(
          tester,
          PlGallery(
            items: <PlGalleryItem>[
              PlGalleryItem(id: 'a', image: _picture(1), semanticLabel: 'A harbour'),
            ],
            preview: true,
          ),
        );

        await tester.tap(find.bySemanticsLabel('A harbour — 1 of 1'));
        await _settle(tester);

        expect(find.bySemanticsLabel('Next'), findsNothing);
        expect(find.text('1 of 1'), findsNothing);
      });
    });
  });
}
