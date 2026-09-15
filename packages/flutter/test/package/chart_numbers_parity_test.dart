// That the numbers `internal/chart.dart` shares with its React twin still agree.
//
// The two files are a port of each other and are meant to match function for
// function, so a chart of the same data at the same size is one picture in both
// packages rather than two that are nearly alike. Nothing in either build makes
// that true: a number edited on one side simply drifts. This reads the React
// literals out of the source and compares them, so it pins no value of its own
// — change the React table and this follows it.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/chart.dart';
import 'package:plass_ui/src/types.dart';

final String _source = File('../react/src/internal/chart.ts').readAsStringSync();

/// The entries of a `Record<…, number>` declared as [name], by their key.
Map<String, double> _table(String name) {
  final RegExpMatch? body = RegExp(
    'export const ${RegExp.escape(name)}[^{]*\\{([^}]*)\\}',
  ).firstMatch(_source);

  if (body == null) {
    throw StateError('`$name` is no longer declared in the React build');
  }

  return <String, double>{
    for (final RegExpMatch entry in RegExp(r'(\w+):\s*([\d.]+)').allMatches(body.group(1)!))
      entry.group(1)!: double.parse(entry.group(2)!),
  };
}

void main() {
  test('a bar takes the same share of its band as it does in React', () {
    // React spells the standard density `default`, which is a Dart keyword and
    // so cannot name an enum member.
    final Map<String, double> react = _table('barBandRatio');

    expect(barBandRatio[PlassDensity.standard], react['default']);
    expect(barBandRatio[PlassDensity.compact], react['compact']);
  });

  test('the size ladders are the same ladders', () {
    for (final (String name, Map<PlassSize, double> ours) in <(String, Map<PlassSize, double>)>[
      ('plotHeights', plotHeights),
      ('sparklineHeights', sparklineHeights),
      ('lineWidths', lineWidths),
      ('markerRadii', markerRadii),
      ('chartFontSizes', chartFontSizes),
      ('barMaxThickness', barMaxThickness),
    ]) {
      final Map<String, double> react = _table(name);

      for (final PlassSize size in PlassSize.values) {
        expect(ours[size], react[size.name], reason: '$name at ${size.name}');
      }
    }
  });
}
