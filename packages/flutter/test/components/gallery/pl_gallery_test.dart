// The pictures here are built from bytes in the test file, so nothing depends
// on a network or on a file on disk.
import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/decode.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';

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

/// A pack's way of saying where a picture sits, for a theme to hand the gallery.
String _whereInKorean(int index, int total) => '$total장 중 $index번째';

/// The pictures the gallery drew, by the words on them.
List<String> _pictures(WidgetTester tester) {
  return tester
      .widgetList<PlImage>(find.byType(PlImage))
      .map((PlImage image) => image.semanticLabel ?? '')
      .toList();
}

/// The pictures named in [names] a screen reader reaches, in the order it
/// reaches them.
List<String> _read(WidgetTester tester, List<String> names) {
  return tester.semantics
      .simulatedAccessibilityTraversal()
      .map((SemanticsNode node) => node.label.split(' — ').first)
      .where(names.contains)
      .toList();
}

/// The tile holding the focus, by the words on its picture, or `null` when the
/// focus is on something else.
String? _focusedTile() {
  String? label;

  FocusManager.instance.primaryFocus?.context?.visitAncestorElements((Element element) {
    final Widget widget = element.widget;

    if (widget is Semantics && widget.properties.button == true) {
      label = widget.properties.label;

      return false;
    }

    return true;
  });

  return label?.split(' — ').first;
}

/// The tiles [steps] presses of Tab visit from [before], in the order they
/// visit them.
Future<List<String>> _walk(WidgetTester tester, FocusNode before, int steps) async {
  final List<String> visited = <String>[];

  before.requestFocus();
  await tester.pump();

  for (int step = 0; step < steps; step += 1) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    visited.add(_focusedTile() ?? '');
  }

  return visited;
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

    group('a masonry’s order', () {
      /// Nine pictures of three shapes, which three lanes deal as A H, B D F I
      /// and C E G — so the lanes, the rows and the list all disagree.
      final List<PlGalleryItem> mixed = <PlGalleryItem>[
        for (final (int at, double ratio) in <(int, double)>[
          (0, 0.5),
          (1, 2),
          (2, 2),
          (3, 2),
          (4, 1),
          (5, 1),
          (6, 2),
          (7, 1),
          (8, 1),
        ])
          PlGalleryItem(
            id: '$at',
            image: _picture(at + 1),
            semanticLabel: String.fromCharCode(65 + at),
            ratio: ratio,
          ),
      ];
      final List<String> given = <String>['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];

      Widget masonry({
        int lanes = 3,
        void Function(PlGalleryItem item, int index)? onItemSelected,
      }) {
        return PlGallery(
          items: mixed,
          layout: PlGalleryLayout.masonry,
          columns: PlassResponsive<int>(lanes),
          onItemSelected: onItemSelected,
        );
      }

      testWidgets('is read in the order the pictures were given', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, masonry());

        expect(_read(tester, given), given);
        handle.dispose();
      });

      testWidgets('is read in the order given when the tiles are buttons', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, masonry(onItemSelected: (PlGalleryItem item, int index) {}));

        expect(_read(tester, given), given);
        handle.dispose();
      });

      testWidgets('is walked with Tab in the order the pictures were given', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        await _pump(
          tester,
          afterFocusStop(before, masonry(onItemSelected: (PlGalleryItem item, int index) {})),
        );

        expect(await _walk(tester, before, given.length), given);
      });

      testWidgets('keeps a tile, and the focus on it, when the number of lanes changes', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        Widget board(int lanes) {
          return afterFocusStop(
            before,
            masonry(lanes: lanes, onItemSelected: (PlGalleryItem item, int index) {}),
          );
        }

        final Finder e = find.byWidgetPredicate(
          (Widget widget) => widget is PlImage && widget.semanticLabel == 'E',
        );

        await _pump(tester, board(3), width: 300);
        await _walk(tester, before, 5);

        expect(_focusedTile(), 'E');

        final Element picture = tester.element(e);
        final double x = tester.getTopLeft(e).dx;

        await _pump(tester, board(2), width: 300);

        // E goes from the last of three lanes to the second of two, and is
        // still the tile it was: the same picture, with the focus still on it.
        expect(tester.getTopLeft(e).dx, isNot(closeTo(x, 1)));
        expect(identical(tester.element(e), picture), isTrue);
        expect(_focusedTile(), 'E');
      });

      testWidgets('draws the first lane on the reader’s starting side', (
        WidgetTester tester,
      ) async {
        double left(String label) => tester
            .getTopLeft(
              find.byWidgetPredicate(
                (Widget widget) => widget is PlImage && widget.semanticLabel == label,
              ),
            )
            .dx;

        await _pump(tester, masonry());

        // A leads the first lane and C the third.
        expect(left('A'), lessThan(left('C')));

        tester.view.physicalSize = const Size(600, 900);
        await tester.pumpWidget(
          host(masonry(), width: 600, overlay: true, textDirection: TextDirection.rtl),
        );
        await _settle(tester);

        expect(left('A'), greaterThan(left('C')));
      });
    });

    group('a quilt’s order', () {
      /// Two wide tiles and two narrow ones on three columns. B is too wide for
      /// the one column left beside A, so it opens the second row, and C, which
      /// fits, fills the gap: the quilt is drawn A C, B D.
      final List<PlGalleryItem> quilt = <PlGalleryItem>[
        for (final (int at, int cols) in <(int, int)>[(0, 2), (1, 2), (2, 1), (3, 1)])
          PlGalleryItem(
            id: '$at',
            image: _picture(at + 1),
            semanticLabel: String.fromCharCode(65 + at),
            cols: cols,
          ),
      ];
      final List<String> given = <String>['A', 'B', 'C', 'D'];

      Widget quilted({void Function(PlGalleryItem item, int index)? onItemSelected}) {
        return PlGallery(
          items: quilt,
          layout: PlGalleryLayout.quilted,
          columns: const PlassResponsive<int>(3),
          rowHeight: 100,
          onItemSelected: onItemSelected,
        );
      }

      testWidgets('is read in the order the pictures were given', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, quilted());

        expect(_read(tester, given), given);
        handle.dispose();
      });

      testWidgets('is read in the order given when the tiles are buttons', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, quilted(onItemSelected: (PlGalleryItem item, int index) {}));

        expect(_read(tester, given), given);
        handle.dispose();
      });

      testWidgets('is walked with Tab in the order the pictures were given', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        await _pump(
          tester,
          afterFocusStop(before, quilted(onItemSelected: (PlGalleryItem item, int index) {})),
        );

        expect(await _walk(tester, before, given.length), given);
      });
    });

    group('a grid’s and a justified board’s rows', () {
      /// Six square pictures, which three columns, or a 300px justified board
      /// with 100px rows, lay out as A B C over D E F.
      final List<PlGalleryItem> six = <PlGalleryItem>[
        for (int at = 0; at < 6; at += 1)
          PlGalleryItem(
            id: '$at',
            image: _picture(at + 1),
            semanticLabel: String.fromCharCode(65 + at),
            ratio: 1,
          ),
      ];
      final List<String> given = <String>['A', 'B', 'C', 'D', 'E', 'F'];

      Finder picture(String label) => find.byWidgetPredicate(
        (Widget widget) => widget is PlImage && widget.semanticLabel == label,
      );

      Widget grid({int columns = 3, void Function(PlGalleryItem item, int index)? onItemSelected}) {
        return PlGallery(
          items: six,
          columns: PlassResponsive<int>(columns),
          gap: 0,
          onItemSelected: onItemSelected,
        );
      }

      Widget justified({void Function(PlGalleryItem item, int index)? onItemSelected}) {
        return PlGallery(
          items: six,
          layout: PlGalleryLayout.justified,
          rowHeight: 100,
          gap: 0,
          onItemSelected: onItemSelected,
        );
      }

      for (final (String name, Widget Function() board) in <(String, Widget Function())>[
        ('grid', () => grid()),
        ('justified board', () => justified()),
      ]) {
        testWidgets('reads a $name row by row', (WidgetTester tester) async {
          final SemanticsHandle handle = tester.ensureSemantics();

          await _pump(tester, board(), width: 300);

          expect(
            tester.getTopLeft(picture('D')).dy,
            greaterThan(tester.getTopLeft(picture('C')).dy),
          );
          expect(_read(tester, given), given);
          handle.dispose();
        });
      }

      testWidgets('walks a grid and a justified board with Tab row by row', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        await _pump(
          tester,
          afterFocusStop(before, grid(onItemSelected: (PlGalleryItem _, int _) {})),
          width: 300,
        );

        expect(await _walk(tester, before, given.length), given);

        await _pump(
          tester,
          afterFocusStop(before, justified(onItemSelected: (PlGalleryItem _, int _) {})),
          width: 300,
        );

        expect(await _walk(tester, before, given.length), given);
      });

      testWidgets('draws the first tile of a row on the reader’s starting side', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = const Size(300, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        for (final Widget board in <Widget>[grid(), justified()]) {
          await tester.pumpWidget(
            host(board, width: 300, overlay: true, textDirection: TextDirection.rtl),
          );
          await _settle(tester);

          expect(tester.getTopLeft(picture('A')).dx, closeTo(200, 0.5));
          expect(tester.getTopLeft(picture('C')).dx, closeTo(0, 0.5));
        }
      });

      testWidgets('keeps a grid tile and its focus when the columns move it to another row', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        Widget board(int columns) {
          return afterFocusStop(
            before,
            grid(columns: columns, onItemSelected: (PlGalleryItem _, int _) {}),
          );
        }

        await _pump(tester, board(3), width: 300);
        await _walk(tester, before, 4);

        expect(_focusedTile(), 'D');

        final State<PlImage> resting = tester.state<State<PlImage>>(picture('D'));
        final double y = tester.getTopLeft(picture('D')).dy;

        await _pump(tester, board(4), width: 300);

        // D goes from the second row of three to the first row of four, and is
        // still the tile it was: the same picture, with the focus still on it.
        expect(tester.getTopLeft(picture('D')).dy, lessThan(y));
        expect(tester.state<State<PlImage>>(picture('D')), same(resting));
        expect(_focusedTile(), 'D');
      });

      testWidgets('keeps a justified tile and its focus when the width moves it to another row', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        Widget board() {
          return afterFocusStop(before, justified(onItemSelected: (PlGalleryItem _, int _) {}));
        }

        await _pump(tester, board(), width: 300);
        await _walk(tester, before, 3);

        expect(_focusedTile(), 'C');

        final State<PlImage> resting = tester.state<State<PlImage>>(picture('C'));
        final double y = tester.getTopLeft(picture('C')).dy;

        await _pump(tester, board(), width: 200);

        // At 200px a row holds two, so C goes from the end of the first row to
        // the start of the second, and is still the tile it was.
        expect(tester.getTopLeft(picture('C')).dy, greaterThan(y));
        expect(tester.state<State<PlImage>>(picture('C')), same(resting));
        expect(_focusedTile(), 'C');
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

      testWidgets('keeps a tile’s picture when the focus ring comes and goes', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        int rings() => tester
            .widgetList<CustomPaint>(find.byType(CustomPaint))
            .where((CustomPaint paint) => paint.foregroundPainter is PlassFocusRingPainter)
            .length;

        await _pump(
          tester,
          afterFocusStop(
            before,
            PlGallery(items: items, onItemSelected: (PlGalleryItem _, int _) {}),
          ),
        );

        final State<PlImage> resting = tester.state<State<PlImage>>(find.byType(PlImage).first);

        await _walk(tester, before, 1);
        await _settle(tester);

        // The ring really is drawn, and the picture under it is the same one.
        expect(_focusedTile(), 'A harbour');
        expect(rings(), 1);
        expect(tester.state<State<PlImage>>(find.byType(PlImage).first), same(resting));

        before.requestFocus();
        await _settle(tester);

        expect(rings(), 0);
        expect(tester.state<State<PlImage>>(find.byType(PlImage).first), same(resting));
      });

      testWidgets('names a tile by its picture and its place in the set', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlGallery(items: items, onItemSelected: (PlGalleryItem _, int _) {}));

        expect(find.bySemanticsLabel('A harbour — 1 of 4'), findsOneWidget);
      });

      testWidgets('describes a tile by the caption it draws, and keeps its name', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlGallery(
            items: <PlGalleryItem>[
              items[0],
              PlGalleryItem(
                id: 'b',
                image: _picture(2),
                semanticLabel: 'A bridge',
                description: 'Over the river',
              ),
              items[2],
            ],
            caption: PlGalleryCaption.hover,
            onItemSelected: (PlGalleryItem _, int _) {},
          ),
        );

        // A `hover` caption describes the tile before the pointer has shown it,
        // and only the lines a tile has are said.
        String hintOf(String label) => tester.getSemantics(find.bySemanticsLabel(label)).hint;

        expect(hintOf('A harbour — 1 of 3'), 'Harbour\nBusan');
        expect(hintOf('A bridge — 2 of 3'), 'Over the river');
        expect(hintOf('A hillside — 3 of 3'), isEmpty);
      });

      testWidgets('describes nothing with a caption that is not drawn', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlGallery(items: items, onItemSelected: (PlGalleryItem _, int _) {}));

        expect(tester.getSemantics(find.bySemanticsLabel('A harbour — 1 of 4')).hint, isEmpty);
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

      testWidgets('says where a tile is in the words of the label pack', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlassTheme.merge(
            defaults: const PlassDefaults(labels: PlassLabels(galleryItem: _whereInKorean)),
            child: PlGallery(items: items, preview: true),
          ),
        );

        // The tile's name and the viewer's counter used to be an English
        // template inside the widget, whatever pack the screen was reading.
        await tester.tap(find.bySemanticsLabel('A bridge — 4장 중 2번째'));
        await _settle(tester);

        expect(find.text('4장 중 2번째'), findsOneWidget);
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

      testWidgets('names the open picture the way its tile is named', (WidgetTester tester) async {
        // Read off the picture rather than the semantics tree: a picture that
        // has not decoded is laid out at no size, and a node with no size is
        // left out of the tree until it has one.
        Iterable<String?> named() => tester
            .widgetList<Image>(
              find.descendant(of: find.byType(PlOverlay), matching: find.byType(Image)),
            )
            .where((Image one) => !one.excludeFromSemantics)
            .map((Image one) => one.semanticLabel);

        await _pump(tester, PlGallery(items: items, preview: true));

        await tester.tap(find.bySemanticsLabel('A bridge — 2 of 4'));
        await _settle(tester);
        expect(named(), <String>['A bridge']);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await _settle(tester);
        expect(named(), <String>['A hillside']);
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

      testWidgets('decodes the open picture to fit the viewer, turned with it', (
        WidgetTester tester,
      ) async {
        final MemoryImage big = _picture(9);

        await _pump(
          tester,
          MediaQuery(
            data: const MediaQueryData(size: Size(600, 900), devicePixelRatio: 2),
            child: PlGallery(
              items: <PlGalleryItem>[
                PlGalleryItem(
                  id: 'a',
                  image: _picture(1),
                  full: big,
                  rotate: 90,
                  semanticLabel: 'A harbour',
                ),
              ],
              preview: true,
            ),
          ),
        );

        await tester.tap(find.bySemanticsLabel('A harbour — 1 of 1'));
        await _settle(tester);

        final Image open = tester
            .widgetList<Image>(
              find.descendant(of: find.byType(PlOverlay), matching: find.byType(Image)),
            )
            .firstWhere((Image image) => !image.excludeFromSemantics);

        // The viewer takes 540 by 720 of a 600 by 900 screen. The file lies on
        // its side, so its own width is measured down the screen, and the whole
        // of it fits inside: 720 and 540 at two device pixels to one, rounded up
        // to whole steps.
        expect(open.image, PlassSizedImage(big, width: 1536, height: 1152, cover: false));
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
