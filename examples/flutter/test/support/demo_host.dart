import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/canvas.dart';

/// Where the gallery's Inter files are, from `examples/flutter`.
const String _fonts = '../../packages/flutter/example/assets/fonts';

/// Loads the font the app runs with, because `flutter test` otherwise draws
/// every glyph as a square as wide as the font size, and a label then overflows
/// a box it fits in on a device.
Future<void> loadFonts() async {
  final loader = FontLoader('packages/plass_ui_example/Inter');

  for (final name in <String>['Inter-Regular.ttf', 'Inter-SemiBold.ttf']) {
    final bytes = await File('$_fonts/$name').readAsBytes();

    loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  }

  await loader.load();
}

/// A transparent PNG, one pixel square.
final Uint8List _dot = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

class _ImageClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _ImageRequest();
}

class _ImageRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _NoHeaders();

  @override
  Future<HttpClientResponse> close() async => _ImageResponse();
}

class _NoHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _ImageResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _dot.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(
      _dot,
    ).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

/// Puts [child] on a screen of [size], with the [padding] a notch and a home
/// indicator take, the way the app shows a demo.
Widget screen(
  Widget child, {
  required Size size,
  EdgeInsets padding = EdgeInsets.zero,
  double textScale = 1,
  Brightness brightness = Brightness.light,
}) {
  return MediaQuery(
    data: MediaQueryData(
      size: size,
      padding: padding,
      viewPadding: padding,
      platformBrightness: brightness,
      textScaler: TextScaler.linear(textScale),
    ),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: DefaultTextStyle(
        style: const TextStyle(fontFamily: 'Inter', package: 'plass_ui_example'),
        child: PlassTheme(
          brightness: brightness,
          child: Overlay.wrap(child: PlassCanvas(child: child)),
        ),
      ),
    ),
  );
}

/// Runs [body] and returns what went wrong during it, one line for each failure.
///
Future<List<String>> collectErrors(Future<void> Function() body) async {
  final errors = <String>[];
  final previous = FlutterError.onError;

  FlutterError.onError = (FlutterErrorDetails details) {
    errors.add(details.exceptionAsString().split('\n').first);
  };

  // Every network image is answered with a dot, since `flutter test` has no
  // network and a failed image is drawn as a box of error text wider than a
  // phone.
  debugNetworkImageHttpClientProvider = _ImageClient.new;

  try {
    await body();
  } finally {
    debugNetworkImageHttpClientProvider = null;
    FlutterError.onError = previous;
  }

  return errors;
}
