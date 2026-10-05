// That muted text can be read on every step of the glass.
//
// WCAG 1.4.3 asks 4.5:1 of body text, and `mutedFg` is the labels, the
// descriptions and the hints. It is read on the page, on a sheet of glass laid
// over the page or over an opaque sheet, and on the densest step most of all: a
// modal, a select's list and a tooltip are `glassPress`. Like
// `focus_ring_contrast_test.dart`, this pins no design value: the colours can
// move, but not below the floor.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

double _contrast(Color one, Color two) {
  final List<double> ends = <double>[one.computeLuminance(), two.computeLuminance()]
    ..sort((double a, double b) => b.compareTo(a));

  return (ends[0] + 0.05) / (ends[1] + 0.05);
}

void main() {
  for (final Brightness brightness in Brightness.values) {
    test('muted text clears 4.5:1 on every step of the glass in the ${brightness.name} theme', () {
      final PlassTokens tokens = PlassTokens.of(brightness);
      final Map<String, Color> grounds = <String, Color>{
        'surface': tokens.surface,
        'bgFrom': tokens.bgFrom,
        'bgTo': tokens.bgTo,
      };
      final Map<String, Color?> steps = <String, Color?>{
        'bare': null,
        'glass': tokens.glass,
        'glassHover': tokens.glassHover,
        'glassPress': tokens.glassPress,
      };
      final List<String> failures = <String>[];

      for (final MapEntry<String, Color> ground in grounds.entries) {
        for (final MapEntry<String, Color?> step in steps.entries) {
          final Color back = step.value == null
              ? ground.value
              : Color.alphaBlend(step.value!, ground.value);
          final double ratio = _contrast(tokens.mutedFg, back);

          if (ratio < 4.5) {
            failures.add('${step.key} on ${ground.key}: ${ratio.toStringAsFixed(2)}');
          }
        }
      }

      expect(failures, isEmpty);
    });
  }
}
