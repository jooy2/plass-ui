import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/css.dart';

void main() {
  const LinearGradient gloss = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xCCFFFFFF), Color(0x12000000)],
  );

  /// The colour at the middle of [gradient], which holds a stop there.
  Color middle(LinearGradient gradient) {
    return gradient.colors[gradient.stops!.indexWhere((double stop) => stop == 0.5)];
  }

  test('passes through white between white and black, as CSS does', () {
    final Color halfway = middle(cssGradient(gloss)! as LinearGradient);

    // With the alpha multiplied in, 0.4 of white over 0.435 of cover. A
    // `LinearGradient` left alone would give a mid grey here.
    expect(halfway.r, closeTo(0.4 / 0.435, 0.01));
    expect(halfway.a, closeTo(0.435, 0.01));
  });

  test('keeps both ends and the direction', () {
    final gradient = cssGradient(gloss)! as LinearGradient;

    expect(gradient.colors.first, gloss.colors.first);
    expect(gradient.colors.last.a, closeTo(gloss.colors.last.a, 0.001));
    expect(gradient.begin, gloss.begin);
    expect(gradient.end, gloss.end);
    expect(gradient.colors, hasLength(gradient.stops!.length));
  });

  test('leaves a gradient that only fades as it came', () {
    const LinearGradient fade = LinearGradient(
      colors: <Color>[Color(0x80FFFFFF), Color(0x1AFFFFFF)],
    );

    expect(cssGradient(fade), same(fade));
  });

  test('leaves a span that only fades in one piece beside one that does not', () {
    final gradient =
        cssGradient(
              const LinearGradient(
                colors: <Color>[Color(0x80FFFFFF), Color(0x1AFFFFFF), Color(0x40000000)],
                stops: <double>[0, 0.5, 1],
              ),
            )!
            as LinearGradient;

    expect(gradient.stops![1], 0.5);
  });

  test('follows the stops it is given', () {
    final gradient =
        cssGradient(
              const LinearGradient(
                colors: <Color>[Color(0x80FFFFFF), Color(0x40000000)],
                stops: <double>[0.2, 0.8],
              ),
            )!
            as LinearGradient;

    expect(gradient.stops!.first, 0.2);
    expect(gradient.stops!.last, closeTo(0.8, 0.0001));
  });

  test('hands anything else back as it came', () {
    const RadialGradient radial = RadialGradient(
      colors: <Color>[Color(0x80FFFFFF), Color(0x00000000)],
    );

    expect(cssGradient(radial), same(radial));
    expect(cssGradient(null), isNull);
  });
}
