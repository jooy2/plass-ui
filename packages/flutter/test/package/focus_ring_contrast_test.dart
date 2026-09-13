// That every family's focus ring can be seen against the surface round it.
//
// WCAG 1.4.11 asks 3:1 of a focus indicator against what is next to it, and a
// ring is drawn around a control, so what is next to it is the sheet or the
// page. Like `theme_defaults_test.dart`, this pins no design value: the colours
// can move, but not below the floor.
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
    test('every focus ring clears 3:1 in the ${brightness.name} theme', () {
      final PlassTokens tokens = PlassTokens.of(brightness);
      final Map<String, Color> grounds = <String, Color>{
        'surface': tokens.surface,
        'bgFrom': tokens.bgFrom,
        'bgTo': tokens.bgTo,
      };
      final List<String> failures = <String>[];

      for (final PlassColor color in PlassColor.values) {
        final Color ring = tokens.family(color).ring;

        for (final MapEntry<String, Color> ground in grounds.entries) {
          final Color drawn = Color.alphaBlend(ring, ground.value);
          final double ratio = _contrast(drawn, ground.value);

          if (ratio < 3) {
            failures.add('${color.name} on ${ground.key}: ${ratio.toStringAsFixed(2)}');
          }
        }
      }

      expect(failures, isEmpty);
    });
  }
}
