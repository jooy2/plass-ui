/// Plass design tokens.
///
/// This is `src/styles.css` from the React package, in Dart. The values are the
/// same values; what changes is that CSS resolves them through the cascade and
/// `color-mix()`, and here they are resolved once per brightness into an
/// immutable object a widget reads off the tree.
///
/// Components never hardcode a colour; they ask [PlassTokens] for a
/// [PlassColorFamily] and let it answer.
///
/// The surface model is **a key of tinted glass resting on a clear sheet**: a
/// control is a smooth two-stop gradient with a drop shadow tinted by its own
/// colour and a bloom of light that follows the pointer across it; everything
/// that holds content is a translucent, heavily blurred sheet with a white
/// hairline around it. Depth is carried by the gradient, not by a highlight.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/css.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/types.dart';

/* ---------------------------------------------------------------------------
 * The colour families
 *
 * These sit outside every theme on purpose, and it is the one place Plass
 * departs hardest from the libraries it was learned from: **a key's own colour
 * does not change with the theme.** What changes is the sheet it rests on, the
 * glass around it, and the `accent` — the one value that has to be *read* off a
 * surface rather than looked at.
 *
 * `solid` and `solidTo` are the two ends of the gradient, at 135° — the
 * top-left corner and the bottom-right one. They are a **hue sweep at one
 * lightness**, not a shade: primary runs indigo to azure, danger vermilion to
 * rose, success green to teal, info blue to cyan. Nothing gets lighter and
 * nothing gets darker.
 *
 * That is the whole reason there is no highlight layer over the top of a
 * control. A gradient that darkens toward one corner is a moulded object
 * catching a lamp, and it needs a specular highlight to finish the illusion —
 * which is what made every filled control read as lacquer. A gradient that
 * *turns* is a piece of tinted glass, and it needs nothing else.
 *
 * Both ends clear 4.5:1 against their own `onSolid`. `warning` is the exception
 * — its ink is dark, so it runs the other way and has room to spare.
 * ------------------------------------------------------------------------- */

const Map<PlassColor, Color> _solid = <PlassColor, Color>{
  PlassColor.primary: Color(0xFF3F63F2),
  PlassColor.secondary: Color(0xFF6B7488),
  PlassColor.success: Color(0xFF1B8649),
  // The one family with dark ink, and the one whose sweep is a change of
  // lightness rather than of hue — amber has nowhere to turn that is still
  // amber. White on it does not reach 4.5:1 at any lightness worth the name,
  // and changing the ink is the right answer; distorting the family to preserve
  // a white label is not.
  PlassColor.warning: Color(0xFFF0A63E),
  PlassColor.danger: Color(0xFFD04246),
  PlassColor.info: Color(0xFF2379BD),
};

const Map<PlassColor, Color> _solidTo = <PlassColor, Color>{
  PlassColor.primary: Color(0xFF1B78CB),
  PlassColor.secondary: Color(0xFF59637A),
  PlassColor.success: Color(0xFF12866A),
  PlassColor.warning: Color(0xFFD98613),
  PlassColor.danger: Color(0xFFD53C54),
  PlassColor.info: Color(0xFF157AA9),
};

const Color _white = Color(0xFFFFFFFF);
const Color _warningInk = Color(0xFF3B2405);

/// `soft`, `softHover`, `softPress`, `line`, `lineHover` — as percentages of
/// the family's accent.
const List<double> _softSteps = <double>[10, 18, 26, 30, 48];

/// The same five for `warning`, each a couple of points higher.
///
/// Amber is the lightest accent in the set, and at the others' alpha its wash
/// disappears against a white sheet. Written out rather than scaled, because
/// the five do not all move by the same factor.
const List<double> _warningSoftSteps = <double>[12, 20, 28, 34, 52];

const Map<PlassColor, Color> _lightAccents = <PlassColor, Color>{
  PlassColor.primary: Color(0xFF2C49D6),
  PlassColor.secondary: Color(0xFF46506A),
  PlassColor.success: Color(0xFF146B41),
  PlassColor.warning: Color(0xFF96600C),
  PlassColor.danger: Color(0xFFBB3339),
  PlassColor.info: Color(0xFF1668AE),
};

const Map<PlassColor, Color> _darkAccents = <PlassColor, Color>{
  PlassColor.primary: Color(0xFF93A8FF),
  PlassColor.secondary: Color(0xFFAAB3C6),
  PlassColor.success: Color(0xFF4FD08D),
  PlassColor.warning: Color(0xFFF2B74E),
  PlassColor.danger: Color(0xFFFF8A8F),
  PlassColor.info: Color(0xFF5FB4EE),
};

/// One colour family, resolved for one theme.
///
/// Four values are given per family and everything else is derived, so adding a
/// colour family is one entry in [PlassColor] plus its colours in this file.
@immutable
class PlassColorFamily {
  /// Creates a resolved family. Only [PlassTokens] should need to.
  const PlassColorFamily({
    required this.solid,
    required this.solidTo,
    required this.onSolid,
    required this.accent,
    required this.tintStrength,
    required this.softSteps,
  });

  /// The top-left end of the gradient, and the colour the family *is*.
  final Color solid;

  /// The bottom-right end of the same gradient, at the same lightness.
  final Color solidTo;

  /// The ink that goes on top of the fill. White everywhere but `warning`.
  final Color onSolid;

  /// The family, readable **on a surface** rather than as a surface. The one
  /// family value that is per-theme, because it is the one that has to be read
  /// rather than looked at.
  final Color accent;

  /// How strongly the family bleeds into the shadow it casts, as a percentage.
  ///
  /// Higher in the dark theme: a tinted shadow has almost nothing to sit on
  /// over a near-black page, so the tint is turned up rather than the shadow
  /// being made bigger.
  final double tintStrength;

  /// The five wash strengths — see [_softSteps].
  final List<double> softSteps;

  /// The fill: the family's two ends, swept across the control at 135°.
  ///
  /// Two stops and not three, and a *sweep* rather than a shade. Three stops
  /// with a light one at the corner is how a moulded key is drawn, and a
  /// moulded key was the wrong object — it needs a highlight over the top of it
  /// to finish the illusion, and that highlight is what made every control look
  /// lacquered.
  PlassCssGradient get fill =>
      PlassCssGradient(angle: 135, colors: <Color>[solid, solidTo], stops: const <double>[0, 1]);

  /// The tinted lift — the shadow a control casts in its own colour, and the
  /// single loudest thing in the design language.
  ///
  /// Deliberately **not** part of the elevation ladder, and it does not scale
  /// with elevation. Elevation says how far a surface is off the page; this
  /// says what the surface is made of, and a `danger` button one step higher is
  /// not a redder piece of glass.
  Color get tint => colorMix(solid, tintStrength);

  /// The wash a ghost surface takes when the pointer is on it.
  Color get soft => colorMix(accent, softSteps[0]);

  /// The same wash, one step up.
  Color get softHover => colorMix(accent, softSteps[1]);

  /// The same wash, pressed.
  Color get softPress => colorMix(accent, softSteps[2]);

  /// The hairline a glass surface takes from the family on hover.
  Color get line => colorMix(accent, softSteps[3]);

  /// The same hairline, engaged.
  Color get lineHover => colorMix(accent, softSteps[4]);

  /// The focus ring. Off [solid] rather than off [accent], so it is the same
  /// ring in both themes.
  Color get ring => colorMix(solid, 55);
}

/// Every token a Plass component reads, resolved for one [Brightness].
///
/// Obtained through `PlassTheme.of(context)`, which falls back to the
/// platform's own brightness when nothing has been wrapped around the app — so
/// a component works with no setup at all, and a theme is something you reach
/// for when you want to override the platform rather than something you must
/// install before anything renders.
@immutable
class PlassTokens {
  const PlassTokens._({
    required this.brightness,
    required this.surface,
    required this.fg,
    required this.mutedFg,
    required this.border,
    required this.bgFrom,
    required this.bgTo,
    required this.glass,
    required this.glassHover,
    required this.glassPress,
    required this.glassLine,
    required this.blurSigma,
    required this.saturation,
    required this.glossGlass,
    required this.well,
    required this.glowOnFill,
    required this.flashOnFill,
    required this.shadowAmbient,
    required this.tintStrength,
    required this.scrim,
    required this.families,
  });

  /// The light theme, and the default.
  factory PlassTokens.light() => _light;

  /// The dark theme.
  ///
  /// The fills do not move — see the note above the families. What moves is the
  /// ground under them: the glass loses its white and becomes a smoked pane,
  /// the shadow goes black and deepens, and the accents lighten far enough to
  /// be read off the dark sheet.
  factory PlassTokens.dark() => _dark;

  /// The set for a brightness — what `PlassTheme.of` ends up calling.
  factory PlassTokens.of(Brightness brightness) {
    return brightness == Brightness.dark ? _dark : _light;
  }

  static final PlassTokens _light = PlassTokens._(
    brightness: Brightness.light,
    surface: const Color(0xFFFFFFFF),
    fg: const Color(0xFF1B1E27),
    mutedFg: const Color(0xFF5B6376),
    border: const Color(0xFFD5DEEF),
    // The page a Plass screen is laid on. Not painted by any component — a
    // library has no business painting the background — but it is what the
    // glass was tuned over.
    bgFrom: const Color(0xFFEEF2FB),
    bgTo: const Color(0xFFDFE8F8),
    // Three strengths of one translucent sheet, and the ladder is **opacity
    // rather than lightness**: as a surface is engaged it holds more light,
    // instead of turning grey. Undyed on purpose — a sheet holds other people's
    // content, which arrives with its own colours, and tinting it puts every
    // one of them on a background they were not chosen against.
    glass: const Color(0x9EFFFFFF),
    glassHover: const Color(0xC2FFFFFF),
    glassPress: const Color(0xE0FFFFFF),
    glassLine: const Color(0x99FFFFFF),
    // 22 is a deliberate, generous smear: unlike a frosted-acrylic language,
    // Plass is not trying to let you read what is behind the sheet — it is
    // trying to make the sheet look thick. Below about 14 the glass reads as a
    // flat white box with an alpha on it.
    blurSigma: 22,
    saturation: 1.6,
    glossGlass: const PlassInsetShadow(color: Color(0x8CFFFFFF), offset: Offset(0, 1)),
    well: const PlassInsetShadow(color: Color(0x1A14285A), offset: Offset(0, 1), blur: 2),
    glowOnFill: const Color(0x2EFFFFFF),
    flashOnFill: const Color(0x42FFFFFF),
    // A blue-grey rather than black: a neutral shadow over a blue-tinted page
    // reads as dirt — and it is faint, because the tint below is what a
    // control's shadow is actually made of.
    shadowAmbient: const Color(0x1A14285A),
    tintStrength: 35,
    scrim: const Color(0x66101828),
    families: _familiesFor(accents: _lightAccents, tintStrength: 35),
  );

  static final PlassTokens _dark = PlassTokens._(
    brightness: Brightness.dark,
    surface: const Color(0xFF141B30),
    fg: const Color(0xFFE7EAF3),
    mutedFg: const Color(0xFF99A2BA),
    border: const Color(0x1FFFFFFF),
    bgFrom: const Color(0xFF111731),
    bgTo: const Color(0xFF0A0E1C),
    glass: const Color(0x12FFFFFF),
    glassHover: const Color(0x1CFFFFFF),
    glassPress: const Color(0x26FFFFFF),
    glassLine: const Color(0x1FFFFFFF),
    blurSigma: 22,
    saturation: 1.5,
    glossGlass: const PlassInsetShadow(color: Color(0x1AFFFFFF), offset: Offset(0, 1)),
    well: const PlassInsetShadow(color: Color(0x73000000), offset: Offset(0, 1), blur: 2),
    glowOnFill: const Color(0x26FFFFFF),
    flashOnFill: const Color(0x38FFFFFF),
    shadowAmbient: const Color(0x6B000000),
    tintStrength: 55,
    scrim: const Color(0x99000000),
    families: _familiesFor(accents: _darkAccents, tintStrength: 55),
  );

  static Map<PlassColor, PlassColorFamily> _familiesFor({
    required Map<PlassColor, Color> accents,
    required double tintStrength,
  }) {
    return <PlassColor, PlassColorFamily>{
      for (final color in PlassColor.values)
        color: PlassColorFamily(
          solid: _solid[color]!,
          solidTo: _solidTo[color]!,
          onSolid: color == PlassColor.warning ? _warningInk : _white,
          accent: accents[color]!,
          tintStrength: tintStrength,
          softSteps: color == PlassColor.warning ? _warningSoftSteps : _softSteps,
        ),
    };
  }

  /// Which theme this set is.
  final Brightness brightness;

  /// An opaque surface, for anything that cannot be translucent.
  final Color surface;

  /// Body text.
  final Color fg;

  /// A label, a description, a caption — one step quieter than [fg].
  final Color mutedFg;

  /// The neutral hairline, for edges that are not made of glass.
  final Color border;

  /// The top of the two-stop wash a Plass screen is laid on. See [bgTo].
  final Color bgFrom;

  /// The bottom of that wash.
  ///
  /// No component paints it. But a sheet of glass over a flat white page has
  /// nothing to be in front of, and every translucent surface in the library
  /// will read as opaque — so an app that uses Plass should lay one down.
  final Color bgTo;

  /// The translucent sheet at rest.
  final Color glass;

  /// The same sheet under the pointer.
  final Color glassHover;

  /// The same sheet pressed, and the densest of the three.
  final Color glassPress;

  /// The white hairline around a glass sheet.
  final Color glassLine;

  /// How hard a glass sheet blurs what is behind it, as a Gaussian σ.
  final double blurSigma;

  /// How much colour that blur pulls out of the backdrop. `1.6` is `160%`.
  final double saturation;

  /// The light lying along the top edge of a sheet.
  ///
  /// There is one of these and it belongs to **glass only**: a pane has a real
  /// cut edge for light to catch. A gradient key does not get one — a bright
  /// line across the top of a filled control is the single thing that makes it
  /// read as moulded plastic, and the gradient is already saying everything
  /// about the form that needs saying.
  final PlassInsetShadow glossGlass;

  /// A well cut into the glass — what a filled field is drawn as. The only
  /// inset shadow in the library that goes *downward*.
  final PlassInsetShadow well;

  /// The bloom that follows the pointer across a **filled** surface.
  ///
  /// A glass or a ghost control uses its own family's soft tint instead,
  /// because white light on a near-white sheet is invisible.
  final Color glowOnFill;

  /// The brighter flash the moment a filled surface is pressed.
  ///
  /// Only a shade brighter than the bloom it replaces: the press is carried by
  /// the whole control dimming, and this is the highlight riding on top of it
  /// rather than the effect itself.
  final Color flashOnFill;

  /// The neutral shadow every elevation is made of.
  final Color shadowAmbient;

  /// How strongly a key's own colour bleeds into the shadow it casts.
  final double tintStrength;

  /// The scrim behind a modal surface.
  final Color scrim;

  /// The six colour families, resolved for this theme.
  final Map<PlassColor, PlassColorFamily> families;

  /// One family. There are six and they are all present, so this never fails.
  PlassColorFamily family(PlassColor color) => families[color]!;

  /// The bloom that follows the pointer across a surface of [variant].
  Color glow(PlassColorFamily family, PlassVariant variant) {
    return variant == PlassVariant.solid ? glowOnFill : family.soft;
  }

  /// The brighter flash the moment a surface of [variant] is pressed.
  Color flash(PlassColorFamily family, PlassVariant variant) {
    return variant == PlassVariant.solid ? flashOnFill : family.softHover;
  }

  /* -------------------------------------------------------------------------
   * Scales that do not change with the theme
   * ---------------------------------------------------------------------- */

  /// Corner radius: roughly 30% of the control height, and roughly constant in
  /// feel across the ladder — a Plass corner is a moulded fillet, not a pill
  /// and not a chamfer.
  static const Map<PlassSize, double> radius = <PlassSize, double>{
    PlassSize.xs: 8,
    PlassSize.sm: 10,
    PlassSize.md: 12,
    PlassSize.lg: 14,
    PlassSize.xl: 16,
  };

  /// One duration and one curve, applied the same way in both directions — a
  /// key going down and a key coming back up are the same spring.
  static const Duration duration = Duration(milliseconds: 150);

  /// The slower of the two, for anything larger than a control.
  static const Duration durationSlow = Duration(milliseconds: 260);

  /// The house curve.
  static const Curve ease = Cubic(0.16, 0.9, 0.3, 1);

  /// How long the pointer bloom takes to fade in and out.
  static const Duration glowDuration = Duration(milliseconds: 240);

  /// How long the press flash takes to drain.
  ///
  /// The asymmetry against its 0ms rise is the whole trick: the flash lands on
  /// the frame of the press and is still visibly draining a beat after the
  /// finger lifts.
  static const Duration flashDuration = Duration(milliseconds: 700);

  /// The curve that drain follows.
  static const Curve flashEase = Cubic(0.22, 1, 0.36, 1);

  /* -------------------------------------------------------------------------
   * Elevation
   *
   * Neutral, wide and faint — it climbs by *blur* far more than by offset,
   * because a surface that moves 20px down the page when it is raised has left
   * the sheet, and everything in this library is still sitting on one. A
   * control's shadow is mostly the tint below rather than this; what this adds
   * is the small amount of grey that says the sheet is above the page rather
   * than printed on it.
   *
   * Written as CSS `blur-radius` values and converted, for the reason `cssBlur`
   * gives.
   * ---------------------------------------------------------------------- */

  /// Offset y, CSS blur-radius, spread — one row per level, plus the extra one
  /// hovering climbs to.
  static const List<List<double>> _ladder = <List<double>>[
    <double>[0, 0, 0],
    <double>[4, 14, -3],
    <double>[8, 24, -5],
    <double>[14, 36, -9],
    <double>[22, 52, -13],
  ];

  /// The neutral drop shadow at [level].
  ///
  /// Hovering adds a level and pressing removes one, which is why the ladder
  /// runs one step past [plassElevationMax] and why the arithmetic is here
  /// rather than in each component.
  List<BoxShadow> elevation(int level) {
    final step = _ladder[level.clamp(0, _ladder.length - 1)];

    if (step[1] == 0) {
      return const <BoxShadow>[];
    }

    return <BoxShadow>[
      BoxShadow(
        color: shadowAmbient,
        offset: Offset(0, step[0]),
        blurRadius: cssBlur(step[1]),
        spreadRadius: step[2],
      ),
    ];
  }

  /// The tinted lift a control casts at rest.
  BoxShadow lift(PlassColorFamily family) => BoxShadow(
    color: family.tint,
    offset: const Offset(0, 6),
    blurRadius: cssBlur(16),
    spreadRadius: -4,
  );

  /// The same lift, hovered — further off the page.
  BoxShadow liftHover(PlassColorFamily family) => BoxShadow(
    color: family.tint,
    offset: const Offset(0, 10),
    blurRadius: cssBlur(24),
    spreadRadius: -6,
  );

  /// The same lift, pressed. The control is against the sheet and its tint has
  /// nowhere to fall.
  BoxShadow liftPress(PlassColorFamily family) => BoxShadow(
    color: family.tint,
    offset: const Offset(0, 2),
    blurRadius: cssBlur(6),
    spreadRadius: -2,
  );
}
