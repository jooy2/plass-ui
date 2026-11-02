import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Where the screenshots of a run go on the device.
///
/// Inside the app's own temporary directory, so `tool/pull_screenshots.sh` can
/// copy them off a simulator or an emulator afterwards.
final Directory shotDirectory = Directory('${Directory.systemTemp.path}/plass-shots');

/// Writes what the screen shows now to [name] in [shotDirectory].
///
/// Reads the layer tree rather than asking the platform, so it needs no plugin
/// channel and the file can be large without going through the driver.
Future<void> saveShot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final view = tester.binding.renderViews.first;
    // `debugLayer` is null outside a debug build, and a run on a real device is
    // best made in profile mode.
    // ignore: invalid_use_of_protected_member
    final layer = view.layer! as OffsetLayer;
    // The layer already holds the device's pixel ratio, so its bounds are in
    // physical pixels and the ratio asked for here comes on top of that one.
    final ratio = view.flutterView.devicePixelRatio;
    final ui.Image image = await layer.toImage(
      Offset.zero & view.flutterView.physicalSize,
      pixelRatio: 2 / ratio,
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    image.dispose();

    final file = File('${shotDirectory.path}/${name.replaceAll('/', '__')}.png');

    await file.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });
}

/// Runs [body] and returns one line for each thing that went wrong in it.
///
/// An image the network turned away is left out: it says nothing about the
/// component, and a simulator may well be offline.
Future<List<String>> collectErrors(Future<void> Function() body) async {
  final errors = <String>[];
  final previous = FlutterError.onError;

  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.library == 'image resource service') {
      return;
    }

    errors.add(details.exceptionAsString().split('\n').first);
  };

  try {
    await body();
  } finally {
    FlutterError.onError = previous;
  }

  return errors;
}
