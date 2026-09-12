import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The one size decision in this package that cannot be undone by a compiler.
///
/// Dart's tree shaker is whole-program and it is good. Measured against an
/// empty `WidgetsApp`, one `PlDivider` costs 3.6 kB gzipped, one `PlButton`
/// 84 kB, and a gallery that constructs all 127 components 352 kB. An app pays
/// for what it reaches and for nothing else, and almost nothing a widget
/// library does can move that.
///
/// Importing `package:flutter/material.dart` can. Material is not a set of
/// widgets a tree shaker can pick through — a `MaterialApp` reaches `Theme`,
/// which reaches the whole `ThemeData` graph, its typography, its ink machinery
/// and its icon set. An app whose only widget is a Material button is 161 kB
/// larger than the same empty one: getting on for half of what every component
/// in this package costs put together, for one widget.
///
/// `dart run tool/size.dart` prints the table those came from; it was Flutter
/// 3.44. Run it again rather than trusting them, because they move with the
/// Flutter version.
///
/// So a single `import 'package:flutter/material.dart'` anywhere under `lib/`
/// would hand that cost to every consumer, including the ones who chose this
/// package precisely because it does not have one. It is a one-line change that
/// no review would flag and no widget test would fail, which is why it has a
/// test of its own.
///
/// The same goes for Cupertino, and for `dart:mirrors` — which is not available
/// to Flutter anyway, but is the other thing that defeats tree shaking outright.
void main() {
  group('package surface', () {
    final List<File> sources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.path.endsWith('.dart'))
        .toList(growable: false);

    test('lib/ is not empty (the scan below would pass vacuously)', () {
      expect(sources.length, greaterThan(40));
    });

    for (final String banned in <String>[
      'package:flutter/material.dart',
      'package:flutter/cupertino.dart',
      'dart:mirrors',
    ]) {
      test('nothing under lib/ imports $banned', () {
        final List<String> offenders = <String>[
          for (final File file in sources)
            if (file.readAsStringSync().contains("import '$banned'")) file.path,
        ];

        expect(
          offenders,
          isEmpty,
          reason:
              'Plass is built on package:flutter/widgets.dart alone. Importing '
              '$banned puts it in every consumer\'s binary, tree shaking or not.',
        );
      });
    }
  });
}
