/// The places where "the same as the React build" is not the same number.
///
/// Plass is one design language with two implementations, and most of it ports
/// straight across: a 40px control is 40px, `#3f63f2` is `#3f63f2`. Three
/// things do not, because CSS and Flutter measure them differently, and writing
/// the CSS value into a Flutter API would quietly produce a heavier shadow, a
/// gradient running at the wrong angle, and an edge highlight that does not
/// exist. Each conversion lives here with the arithmetic that justifies it.
///
/// None of this is exported from `plass_ui.dart` — it is the library talking to
/// itself.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// A CSS `blur-radius`, as a Flutter [BoxShadow.blurRadius].
///
/// The two APIs take the same-sounding number and mean different things by it.
/// CSS defines a shadow's blur radius as *twice* the Gaussian standard
/// deviation — `0 4px 14px` is σ 7. Flutter converts with
/// `σ = blurRadius * 0.57735 + 0.5`. Handing Flutter the CSS number therefore
/// asks for σ 8.6 instead of σ 7, and every shadow in the library comes out
/// about a fifth softer and wider than the one it is copying.
///
/// Solving `cssRadius / 2 == blurRadius * 0.57735 + 0.5` for `blurRadius` is
/// this.
double cssBlur(double cssRadius) {
  if (cssRadius <= 0) {
    return 0;
  }

  return math.max(0, (cssRadius / 2 - 0.5) / 0.57735);
}

/// `color-mix(in srgb, color X%, transparent)`.
///
/// The two are genuinely identical rather than approximately so: sRGB mixing is
/// premultiplied, and `transparent` is `rgba(0 0 0 / 0)`, so mixing `X%` of a
/// colour into it leaves that colour's channels at alpha `X%`.
Color colorMix(Color color, double percent) {
  return color.withValues(alpha: color.a * (percent / 100));
}

/// A CSS `linear-gradient(<angle>, …)`.
///
/// Flutter's [LinearGradient] is expressed as two [Alignment]s, so the usual
/// spelling of a 135° sweep is `topLeft` → `bottomRight`. That is only the same
/// thing on a square. CSS puts the gradient line through the centre at the
/// stated angle and sizes it so the box's corners land on 0% and 100%; the
/// corner-to-corner line instead runs at whatever angle the box's diagonal
/// happens to be. On a 120×40 button the difference is 45° against 18°, and the
/// sweep visibly flattens out.
///
/// So the endpoints are computed per paint from the rect, exactly as the spec
/// describes: the gradient line's length is `|W·sinθ| + |H·cosθ|`, and its
/// direction is `(sinθ, −cosθ)` — CSS measures the angle clockwise from
/// straight up, which is the opposite of the usual mathematical convention on a
/// y-down canvas.
@immutable
class PlassCssGradient extends LinearGradient {
  /// Creates a gradient that sweeps at [angle] degrees, CSS-style.
  const PlassCssGradient({required this.angle, required super.colors, super.stops});

  /// Degrees clockwise from "to top", as in `linear-gradient(135deg, …)`.
  final double angle;

  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) {
    final radians = angle * math.pi / 180;
    final dx = math.sin(radians);
    final dy = -math.cos(radians);
    final length = (rect.width * dx).abs() + (rect.height * dy).abs();
    final centre = rect.center;
    final half = Offset(dx, dy) * (length / 2);

    return ui.Gradient.linear(centre - half, centre + half, colors, stops);
  }

  /*
   * `Gradient.lerp` is reached from `BoxDecoration.lerp`, which an
   * `AnimatedContainer` runs on every frame of a transition. Without these two,
   * a decoration that merely *contains* this gradient would spend the whole
   * transition as a plain `LinearGradient` — the CSS geometry would drop out
   * for 150ms and snap back, which is precisely the flicker the class exists to
   * avoid. Both directions are covered because `Gradient.lerp` asks `b` first
   * and falls through to `a`.
   */

  @override
  Gradient? lerpFrom(Gradient? a, double t) {
    return a == null || a is PlassCssGradient ? _lerp(a as PlassCssGradient?, this, t) : null;
  }

  @override
  Gradient? lerpTo(Gradient? b, double t) {
    return b == null || b is PlassCssGradient ? _lerp(this, b as PlassCssGradient?, t) : null;
  }

  static PlassCssGradient? _lerp(PlassCssGradient? a, PlassCssGradient? b, double t) {
    if (a == null && b == null) {
      return null;
    }

    final from = a ?? b!;
    final to = b ?? a!;

    return PlassCssGradient(
      angle: ui.lerpDouble(from.angle, to.angle, t)!,
      colors: <Color>[
        for (var i = 0; i < math.min(from.colors.length, to.colors.length); i += 1)
          Color.lerp(from.colors[i], to.colors[i], t)!,
      ],
      stops: from.stops == null || to.stops == null
          ? null
          : <double>[
              for (var i = 0; i < math.min(from.stops!.length, to.stops!.length); i += 1)
                ui.lerpDouble(from.stops![i], to.stops![i], t)!,
            ],
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PlassCssGradient && other.angle == angle && super == other;
  }

  @override
  int get hashCode => Object.hash(angle, super.hashCode);
}

/// A `filter: brightness()`, as a colour matrix.
///
/// CSS applies `filter` to the whole element — its background, its label and
/// the shadow it casts — which is what a [ColorFiltered] wrapped around the
/// finished control does too. That is why hover and press are a brightness
/// change rather than a second set of colours: a gradient cannot be
/// transitioned, but light falling on one can.
ColorFilter brightnessFilter(double amount) {
  return ColorFilter.matrix(<double>[
    amount, 0, 0, 0, 0, //
    0, amount, 0, 0, 0, //
    0, 0, amount, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);
}

/// A `filter: saturate()`, as a colour matrix.
///
/// The luminance coefficients are the ones the CSS filter spec names, so a
/// `saturate(160%)` here desaturates exactly as far as the same declaration in
/// the stylesheet.
ColorFilter saturationFilter(double amount) {
  const double lumR = 0.2126;
  const double lumG = 0.7152;
  const double lumB = 0.0722;

  final r = (1 - amount) * lumR;
  final g = (1 - amount) * lumG;
  final b = (1 - amount) * lumB;

  return ColorFilter.matrix(<double>[
    r + amount, g, b, 0, 0, //
    r, g + amount, b, 0, 0, //
    r, g, b + amount, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);
}
