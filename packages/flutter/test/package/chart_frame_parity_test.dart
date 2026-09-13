// That a chart's grid, axis and baseline are the colours the stylesheet derives.
//
// The React package computes the three with `color-mix()` from the border and
// the muted ink, per theme; the Dart tokens are written out. Written-out colours
// drift, and in the dark theme they once did far enough that the grid was no
// longer the faintest line on the plot. So this reads both the inputs and the
// mix percentages out of `styles.css` and compares the result with the tokens.
// It pins no design value of its own: change the stylesheet and this follows.
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

final String _css = File('../react/src/styles.css').readAsStringSync();

/// Every value `name` is declared with, in the order the sheet declares them.
/// The first is the light theme's; the last is the dark class block's.
List<String> _declared(String name) => RegExp(
  '${RegExp.escape(name)}:\\s*([^;]+);',
).allMatches(_css).map((RegExpMatch match) => match.group(1)!.trim()).toList();

Color _parse(String value) {
  final RegExpMatch? hex = RegExp(r'^#([0-9a-fA-F]{6})$').firstMatch(value);

  if (hex != null) {
    return Color(0xFF000000 | int.parse(hex.group(1)!, radix: 16));
  }

  final RegExpMatch? rgb = RegExp(
    r'^rgb\((\d+)\s+(\d+)\s+(\d+)\s*/\s*([\d.]+)\)$',
  ).firstMatch(value);

  if (rgb != null) {
    return Color.fromARGB(
      (double.parse(rgb.group(4)!) * 255).round(),
      int.parse(rgb.group(1)!),
      int.parse(rgb.group(2)!),
      int.parse(rgb.group(3)!),
    );
  }

  throw FormatException('not a colour this test reads', value);
}

/// The percentage `name` is mixed with `transparent` at, in the derived block.
double _mix(String name) {
  final String value = _declared(name).single;

  return double.parse(RegExp(r'(\d+)%').firstMatch(value)!.group(1)!) / 100;
}

/// What `color-mix(in srgb, colour p%, transparent)` resolves to: the same
/// colour, with its alpha scaled.
Color _faded(Color colour, double share) => colour.withValues(alpha: colour.a * share);

Matcher _near(Color expected) => predicate<Color>(
  (Color actual) =>
      (actual.r - expected.r).abs() <= 1 / 255 &&
      (actual.g - expected.g).abs() <= 1 / 255 &&
      (actual.b - expected.b).abs() <= 1 / 255 &&
      (actual.a - expected.a).abs() <= 1.5 / 255,
  'within a step of $expected',
);

void main() {
  test('the stylesheet draws the axis in the border colour', () {
    expect(_declared('--plass-chart-axis').single, 'var(--plass-border)');
  });

  final double grid = _mix('--plass-chart-grid');
  final double baseline = _mix('--plass-chart-baseline');

  for (final (String theme, PlassTokens tokens, String Function(List<String>) pick)
      in <(String, PlassTokens, String Function(List<String>))>[
        ('light', PlassTokens.light(), (List<String> values) => values.first),
        ('dark', PlassTokens.dark(), (List<String> values) => values.last),
      ]) {
    test('the $theme chart frame is derived the way the stylesheet derives it', () {
      final Color border = _parse(pick(_declared('--plass-border')));
      final Color muted = _parse(pick(_declared('--plass-muted-fg')));

      expect(tokens.chartGrid, _near(_faded(border, grid)), reason: 'grid');
      expect(tokens.chartAxis, _near(border), reason: 'axis');
      expect(tokens.chartBaseline, _near(_faded(muted, baseline)), reason: 'baseline');
    });
  }
}
