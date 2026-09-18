// That a gallery in a scroll view asks for a picture only when the reader is
// near it.
//
// A Flutter `Image` resolves its provider the moment it is mounted, so a board
// of sixty photographs asked for sixty decodes before one of them was on
// screen. The web build has never had to: `<img loading="lazy">` is the
// browser's answer to the same question.
//
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

/// Twenty tall tiles, so the last of them is well past a 900-pixel viewport.
final List<PlGalleryItem> _items = <PlGalleryItem>[
  for (int i = 0; i < 20; i += 1)
    PlGalleryItem(
      id: '$i',
      image: MemoryImage(_onePixelPng, scale: 1 + i / 1000),
      semanticLabel: 'Picture $i',
      ratio: 1,
    ),
];

/// How many tiles have asked for their picture.
int pictures(WidgetTester tester) => tester.widgetList<PlImage>(find.byType(PlImage)).length;

Future<void> _pump(WidgetTester tester, Widget child, {double? height}) async {
  tester.view.physicalSize = const Size(600, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: 600, height: height));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// A gallery in a scroll view of its own, which is the arrangement an app puts
/// one in and the only one there is anything to be far from.
Widget _scrolled() {
  return SingleChildScrollView(
    child: PlGallery(items: _items, columns: const PlassResponsive<int>(1)),
  );
}

void main() {
  testWidgets('builds every picture when nothing above it scrolls', (WidgetTester tester) async {
    // A gallery that is not in a scroll view is as visible as it is ever going
    // to be, so there is nothing to hold back and the board is what it was.
    // Four tiles rather than twenty, because a board with no viewport over it
    // is as tall as its content and twenty would overflow the screen.
    final List<PlGalleryItem> few = _items.take(4).toList();

    await _pump(tester, PlGallery(items: few, columns: const PlassResponsive<int>(2)));

    expect(pictures(tester), few.length);
  });

  testWidgets('asks only for the pictures near the view inside one', (WidgetTester tester) async {
    await _pump(tester, _scrolled(), height: 900);

    final int first = pictures(tester);

    expect(first, greaterThan(0));
    expect(first, lessThan(_items.length));
  });

  testWidgets('asks for one as the reader scrolls towards it', (WidgetTester tester) async {
    await _pump(tester, _scrolled(), height: 900);

    final int first = pictures(tester);

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(pictures(tester), greaterThan(first));
  });

  testWidgets('keeps a picture it has asked for when the reader scrolls back', (
    WidgetTester tester,
  ) async {
    // One way only: throwing the decode away and showing the placeholder again
    // would be a gallery that flickers whenever it is read twice.
    await _pump(tester, _scrolled(), height: 900);

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -4000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final int reached = pictures(tester);

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 4000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(pictures(tester), reached);
  });
}
