/// The arithmetic that decides what size a picture is decoded at.
///
/// `internal/decode.dart` has no React counterpart: a browser keeps an `<img>`
/// at the pixels it is drawn at on its own.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/decode.dart';

final MemoryImage _file = MemoryImage(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ),
);

void main() {
  group('decodeTarget', () {
    test('reaches both sides of the box for a crop, keeping the proportion', () {
      // A panorama cropped into a square has to be as tall as the square.
      expect(decodeTarget(4000, 1000, width: 300, height: 300, cover: true), (1200, 300));
      expect(decodeTarget(1000, 4000, width: 300, height: 300, cover: true), (300, 1200));
    });

    test('fits the whole picture inside the box when it is shown whole', () {
      expect(decodeTarget(4000, 1000, width: 300, height: 300, cover: false), (300, 75));
      expect(decodeTarget(1000, 4000, width: 300, height: 300, cover: false), (75, 300));
    });

    test('goes by the one side it is given', () {
      expect(decodeTarget(4000, 3000, width: 400, cover: true), (400, 300));
      expect(decodeTarget(4000, 3000, height: 300, cover: false), (400, 300));
    });

    test('never makes a picture larger than its file', () {
      expect(decodeTarget(200, 100, width: 800, height: 800, cover: true), (200, 100));
      expect(decodeTarget(200, 100, width: 800, cover: false), (200, 100));
    });

    test('rounds up, so the picture is never short of the box by a pixel', () {
      expect(decodeTarget(3000, 2000, width: 100, cover: true), (100, 67));
    });

    test('leaves the file alone with no side to go by', () {
      expect(decodeTarget(4000, 3000, cover: true), (4000, 3000));
    });
  });

  group('sizedForDecode', () {
    test('rounds the box up to a step of device pixels', () {
      final ImageProvider<Object> sized = sizedForDecode(
        _file,
        width: 40,
        height: 40,
        devicePixelRatio: 3,
        cover: true,
      );

      expect(sized, PlassSizedImage(_file, width: 128, height: 128, cover: true));
    });

    test('keeps one size for a box that grows by a pixel', () {
      expect(
        sizedForDecode(_file, width: 300, height: 200, devicePixelRatio: 2, cover: false),
        sizedForDecode(_file, width: 301, height: 201, devicePixelRatio: 2, cover: false),
      );
    });

    test('leaves out an axis with no bound', () {
      expect(
        sizedForDecode(
          _file,
          width: 300,
          height: double.infinity,
          devicePixelRatio: 1,
          cover: true,
        ),
        PlassSizedImage(_file, width: 384, cover: true),
      );
    });

    test('hands back a picture with nothing to size it by', () {
      expect(
        sizedForDecode(_file, width: double.infinity, devicePixelRatio: 1, cover: true),
        same(_file),
      );
    });

    test('leaves a ResizeImage the caller made as it is', () {
      final ResizeImage own = ResizeImage(_file, width: 64);

      expect(
        sizedForDecode(own, width: 300, height: 300, devicePixelRatio: 2, cover: true),
        same(own),
      );
    });

    test('does not size a picture twice', () {
      final ImageProvider<Object> once = sizedForDecode(
        _file,
        width: 300,
        height: 300,
        devicePixelRatio: 2,
        cover: true,
      );

      expect(
        sizedForDecode(once, width: 900, height: 900, devicePixelRatio: 2, cover: true),
        same(once),
      );
    });
  });

  group('PlassSizedImage', () {
    testWidgets('decodes the file at the size it is sized for', (WidgetTester tester) async {
      final MemoryImage photograph = MemoryImage(await _png(tester, 1600, 1200));
      final ImageStream stream = PlassSizedImage(
        photograph,
        width: 160,
        height: 160,
        cover: true,
      ).resolve(ImageConfiguration.empty);

      final ImageInfo info = (await tester.runAsync(() {
        final Completer<ImageInfo> arrival = Completer<ImageInfo>();

        stream.addListener(ImageStreamListener((ImageInfo info, bool _) => arrival.complete(info)));

        return arrival.future;
      }))!;

      // Both sides reach the 160-pixel box, in the file's own proportion.
      expect((info.image.width, info.image.height), (214, 160));
      info.dispose();
    });
  });
}

/// A PNG of the given size, encoded the way a file off a disk or a network is.
Future<Uint8List> _png(WidgetTester tester, int width, int height) async {
  return (await tester.runAsync(() async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();

    Canvas(recorder).drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = const Color(0xFF808080),
    );

    final ui.Image image = await recorder.endRecording().toImage(width, height);
    final ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    image.dispose();

    return bytes!.buffer.asUint8List();
  }))!;
}
