/// What the example app has to be for a demo to work wherever it is copied to.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no demo names a picture by a path only a website can resolve', () {
    final files = Directory(
      'example/lib/demos',
    ).listSync(recursive: true).whereType<File>().where((File file) => file.path.endsWith('.dart'));

    final relative = <String>[
      for (final file in files)
        if (RegExp(r'''['"]/samples/''').hasMatch(file.readAsStringSync())) file.path,
    ];

    expect(relative, isEmpty);
  });
}
