/// The chrome a `PlWindowPane` draws, and the tables that say how big it is.
///
/// It lives here for the reason `internal/mockup.dart` does. One widget reads
/// it, but what it holds is reference data rather than a piece of that widget —
/// eight systems' worth of title bars, three buttons each, drawn five different
/// ways — and a widget file with all of that in it would be a table with a
/// `build` at the bottom.
///
/// Three conventions run through it:
///
/// **Every length is a logical pixel at `md`, scaled once by `size`.** A title
/// bar is 32px on Windows 11 and 38px on macOS because those are the heights
/// they are, not because a ladder in `internal/scales.dart` says so — this is
/// the one place in the library where the numbers come from somewhere else.
///
/// **The buttons are drawings of what they do and carry no other party's
/// marks.** A traffic light is three circles; a Windows control is a line, a
/// box and a cross. Their names come from `PlassLabels` and are read out;
/// nothing here writes a word.
///
/// It is not exported from `plass_ui.dart`.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/types.dart';

/// Whose window this is a picture of.
///
/// Versions are separate entries wherever the *title bar* is what changed,
/// which is why Windows has five and the others have one or two. XP painted its
/// bar in Luna blue and framed the window in it; 7 made it glass; 8 threw both
/// away for a flat square sheet; 10 ruled the bar off from the body; 11 rounded
/// the corners and made the two one Mica sheet again. [PlWindowOs.macosx] is
/// Aqua — the striped grey bar, the glossy lights and the square bottom corners
/// — against the flat [PlWindowOs.macos] that replaced it.
///
/// Nothing here is a copy of any of them: what is drawn is a bar, a border and
/// three buttons at the proportions the system used, and no mark, wordmark or
/// icon belonging to anyone else.
enum PlWindowOs {
  /// Flat macOS: traffic lights, a centred title, rounded all round.
  macos,

  /// Aqua: a striped bar, glossy lights, a square bottom.
  macosx,

  /// Rounded corners and a Mica sheet.
  windows11,

  /// Square corners, a ruled-off bar, an accent border.
  windows10,

  /// The flat one, framed in a band of colour.
  windows8,

  /// Aero: a sheet of glass with the content sunk into it.
  windows7,

  /// Luna: a blue caption and coloured plates for buttons.
  windowsxp,

  /// A GNOME header bar: tall, centred, small round buttons.
  linux,
}

/// The three buttons a title bar can carry.
enum PlWindowControl {
  /// Rolls the window up to its bar.
  minimize,

  /// Fills whatever is holding it.
  maximize,

  /// Takes it off the page.
  close,
}

/// How one control is drawn.
enum PlWindowControlShape {
  /// A flat traffic light.
  dot,

  /// The same one with Aqua's highlight and ring on it.
  glossDot,

  /// A flat rectangle running to the corner of the window.
  square,

  /// XP's coloured, gradient-filled button.
  plate,

  /// A pane of glass hung off the top edge, close first among equals.
  aero,

  /// GNOME's small disc.
  circle,
}

/// Where the title sits along the bar.
enum PlWindowTitleAlign {
  /// Against the leading edge.
  start,

  /// In the middle of the window.
  center,
}

/// The stretch of the system's own colour around a window.
@immutable
class PlWindowBand {
  /// Creates a band.
  const PlWindowBand(this.side, this.bottom);

  /// Down each side.
  final double side;

  /// And along the bottom.
  final double bottom;
}

/// What a system paints its own title bar with.
@immutable
class PlWindowPaint {
  /// Creates a painted bar.
  const PlWindowPaint(this.fill, this.ink, {this.dark = false});

  /// The bar's fill.
  final Color fill;

  /// The title's ink on it.
  final Color ink;

  /// Which way its own controls have to lighten.
  final bool dark;
}

/// One system's title bar, at `md`.
@immutable
class PlWindowChrome {
  /// Creates a chrome.
  const PlWindowChrome({
    required this.bar,
    required this.radius,
    required this.radiusBottom,
    required this.padX,
    required this.padEnd,
    required this.gap,
    required this.title,
    required this.glyph,
    required this.weight,
    required this.frame,
    required this.band,
    required this.control,
    required this.titleAlign,
    required this.controlsAtEnd,
    required this.shape,
    required this.rule,
    required this.stroke,
    required this.boxRadius,
    required this.tint,
    required this.accentBorder,
    this.closeWidth,
    this.paint,
    this.image,
    this.shadow,
    this.glass = false,
  });

  /// The title bar's height.
  final double bar;

  /// The window's own corner, at the top.
  final double radius;

  /// And at the bottom, which the older systems leave square.
  final double radiusBottom;

  /// The air at the leading edge of the bar.
  final double padX;

  /// And at the trailing edge, which is nothing where the buttons run to it.
  final double padEnd;

  /// Between one control and the next.
  final double gap;

  /// The title's type size.
  final double title;

  /// The mark inside a control.
  final double glyph;

  /// How heavy the title is written, as a `FontWeight` index times 100.
  final int weight;

  /// The hairline around the window.
  final double frame;

  /// The band around it, which is a different thing from the hairline.
  final PlWindowBand band;

  /// One control's box.
  final Size control;

  /// Where the title sits.
  final PlWindowTitleAlign titleAlign;

  /// Whether the controls are on the trailing end.
  final bool controlsAtEnd;

  /// How one control is drawn.
  final PlWindowControlShape shape;

  /// Whether the bar is ruled off from the body.
  final bool rule;

  /// How thick the glyphs are drawn.
  final double stroke;

  /// The corner on the maximize box: Windows 11 rounds it, Windows 10 does not.
  final double boxRadius;

  /// How much of the page's ink is stirred into the bar, in front and behind,
  /// as two percentages.
  final List<int> tint;

  /// Whether an accented window carries the colour into its border as well.
  final bool accentBorder;

  /// Aero's close button, which is wider than the two beside it.
  final double? closeWidth;

  /// The chrome's own colours, for the systems that painted their title bar
  /// rather than taking the page's.
  ///
  /// Fixed values rather than theme tokens, exactly as `PlMockup`'s finishes
  /// are: Luna blue is Luna blue on a page switched to dark, and a title bar
  /// that changed colour with the theme would be a drawing of the theme rather
  /// than of a window.
  final PlWindowPaint? paint;

  /// What is laid over that fill: the gradient, the gloss, the stripes.
  final Gradient? image;

  /// The title's own shadow — XP's hard one, Aero's glow, Aqua's emboss.
  final List<Shadow>? shadow;

  /// Whether the bar blurs what is behind it, which is what made Aero glass.
  final bool glass;
}

/// The eight systems, at `md`.
///
/// macOS puts three coloured dots on the leading edge and centres the title
/// over the whole window. Windows puts three full-height rectangles hard
/// against the trailing corner — they are wide because they are a corner
/// target, and that is what makes a Windows title bar recognisable at a glance.
/// A GNOME header bar is taller than either, centres its title and draws its
/// buttons as small circles held clear of the edge.
const Map<PlWindowOs, PlWindowChrome> _chromes = <PlWindowOs, PlWindowChrome>{
  PlWindowOs.macos: PlWindowChrome(
    bar: 38,
    radius: 10,
    radiusBottom: 10,
    padX: 12,
    padEnd: 12,
    gap: 8,
    title: 13,
    glyph: 7,
    weight: 500,
    frame: 1,
    band: PlWindowBand(0, 0),
    control: Size(12, 12),
    titleAlign: PlWindowTitleAlign.center,
    controlsAtEnd: false,
    shape: PlWindowControlShape.dot,
    rule: false,
    stroke: 1.4,
    boxRadius: 0,
    tint: <int>[6, 3],
    accentBorder: false,
  ),
  PlWindowOs.macosx: PlWindowChrome(
    // Aqua: a short striped bar, glossy lights, a bold embossed title in the
    // middle of it, a hairline under it and a bottom that was never rounded.
    bar: 26,
    radius: 8,
    radiusBottom: 0,
    padX: 10,
    padEnd: 10,
    gap: 8,
    title: 12,
    glyph: 7,
    weight: 700,
    frame: 1,
    band: PlWindowBand(0, 0),
    control: Size(13, 13),
    titleAlign: PlWindowTitleAlign.center,
    controlsAtEnd: false,
    shape: PlWindowControlShape.glossDot,
    rule: true,
    stroke: 1.5,
    boxRadius: 0,
    tint: <int>[0, 0],
    accentBorder: false,
    paint: PlWindowPaint(Color(0xFFE4E4E4), Color(0xFF333333)),
    image: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[Color(0xCCFFFFFF), Color(0x12000000)],
    ),
    shadow: <Shadow>[Shadow(color: Color(0xD9FFFFFF), offset: Offset(0, 1))],
  ),
  PlWindowOs.windows11: PlWindowChrome(
    // 32px bar, 46x32 buttons: the real proportion, and the reason the buttons
    // reach the top edge of the window rather than sitting inside a padding.
    bar: 32,
    radius: 8,
    radiusBottom: 8,
    padX: 12,
    padEnd: 0,
    gap: 0,
    title: 12,
    glyph: 10,
    weight: 400,
    frame: 1,
    band: PlWindowBand(0, 0),
    control: Size(46, 32),
    titleAlign: PlWindowTitleAlign.start,
    controlsAtEnd: true,
    shape: PlWindowControlShape.square,
    rule: false,
    stroke: 1,
    boxRadius: 1.6,
    // Mica: the bar is the same sheet as the window, and what separates them is
    // the title and the buttons rather than a change of shade.
    tint: <int>[3, 1],
    accentBorder: false,
  ),
  PlWindowOs.windows10: PlWindowChrome(
    // Square corners, a shorter bar, a rule under it, thinner glyphs and a
    // border that takes the accent colour: the five things that say "not 11".
    bar: 30,
    radius: 0,
    radiusBottom: 0,
    padX: 10,
    padEnd: 0,
    gap: 0,
    title: 12,
    glyph: 10,
    weight: 400,
    frame: 1,
    band: PlWindowBand(0, 0),
    control: Size(45, 30),
    titleAlign: PlWindowTitleAlign.start,
    controlsAtEnd: true,
    shape: PlWindowControlShape.square,
    rule: true,
    stroke: 0.9,
    boxRadius: 0,
    tint: <int>[0, 0],
    accentBorder: true,
  ),
  PlWindowOs.windows8: PlWindowChrome(
    // The flat one. Where 10 rules its bar off from the body, 8 leaves the two
    // as one white sheet and draws a band of colour around the whole window —
    // which is the trait it is remembered by.
    bar: 32,
    radius: 0,
    radiusBottom: 0,
    padX: 10,
    padEnd: 0,
    gap: 0,
    title: 12,
    glyph: 11,
    weight: 400,
    frame: 2,
    band: PlWindowBand(0, 0),
    control: Size(45, 32),
    titleAlign: PlWindowTitleAlign.start,
    controlsAtEnd: true,
    shape: PlWindowControlShape.square,
    rule: false,
    stroke: 1,
    boxRadius: 0,
    tint: <int>[0, 0],
    accentBorder: true,
  ),
  PlWindowOs.windows7: PlWindowChrome(
    // Aero, and the band is most of it: an Aero window is a sheet of glass with
    // the content sunk into the middle of it, so the page is blurred down both
    // sides and along the bottom as well as behind the caption. Drawn without
    // that, all that is left is a pale blue title bar on an ordinary window.
    bar: 30,
    radius: 7,
    radiusBottom: 0,
    padX: 10,
    padEnd: 3,
    gap: 2,
    title: 12,
    glyph: 10,
    weight: 400,
    frame: 1,
    band: PlWindowBand(7, 7),
    control: Size(29, 20),
    closeWidth: 45,
    titleAlign: PlWindowTitleAlign.start,
    controlsAtEnd: true,
    shape: PlWindowControlShape.aero,
    rule: false,
    stroke: 1.1,
    boxRadius: 0,
    tint: <int>[0, 0],
    accentBorder: false,
    // Half a sheet of glass rather than a whole one: the band lays the first
    // layer down and the caption lays this one over it, so the top of the
    // window is denser than its sides — which is how Aero reads.
    paint: PlWindowPaint(Color(0x73C6DAF2), Color(0xFF12314F)),
    image: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[Color(0x9EFFFFFF), Color(0x1AFFFFFF), Color(0x57FFFFFF), Color(0x80FFFFFF)],
      stops: <double>[0, 0.46, 0.88, 1],
    ),
    shadow: <Shadow>[Shadow(color: Color(0xF2FFFFFF), blurRadius: 6)],
    glass: true,
  ),
  PlWindowOs.windowsxp: PlWindowChrome(
    // Luna: the bar is the system's blue rather than the page's white, the
    // window is framed in the same blue on three sides, and the buttons are
    // coloured plates rather than marks on the bar.
    bar: 30,
    radius: 8,
    radiusBottom: 0,
    padX: 6,
    padEnd: 4,
    gap: 2,
    title: 13,
    glyph: 9,
    weight: 700,
    frame: 1,
    band: PlWindowBand(4, 4),
    control: Size(21, 21),
    // The close plate is the wide one on XP, as it is on Aero — the only two
    // systems here that made the button you least want to hit the easiest one.
    closeWidth: 26,
    titleAlign: PlWindowTitleAlign.start,
    controlsAtEnd: true,
    shape: PlWindowControlShape.plate,
    rule: false,
    stroke: 1.8,
    boxRadius: 3,
    tint: <int>[0, 0],
    accentBorder: false,
    paint: PlWindowPaint(Color(0xFF1F66D6), Color(0xFFFFFFFF), dark: true),
    // Luna's caption is not a slope from light to dark, which is what made a
    // flat overlay wrong: it is bright at the very top, sinks through the
    // middle, comes back up in a band at about four fifths, and is closed off
    // by a dark line at the bottom edge. Written in white and black rather than
    // in blues, so a caller who dyes the bar with `accent` gets the same curve
    // in their own colour.
    image: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[
        Color(0x8CFFFFFF),
        Color(0x42FFFFFF),
        Color(0x1C000000),
        Color(0x0D000000),
        Color(0x38FFFFFF),
        Color(0x57FFFFFF),
        Color(0x29000000),
        Color(0x57000000),
      ],
      stops: <double>[0, 0.07, 0.42, 0.56, 0.76, 0.88, 0.96, 1],
    ),
    shadow: <Shadow>[Shadow(color: Color(0x73000000), offset: Offset(0, 1), blurRadius: 1)],
  ),
  PlWindowOs.linux: PlWindowChrome(
    bar: 44,
    radius: 12,
    radiusBottom: 12,
    padX: 10,
    padEnd: 10,
    gap: 6,
    title: 14,
    glyph: 10,
    weight: 600,
    frame: 1,
    band: PlWindowBand(0, 0),
    control: Size(24, 24),
    titleAlign: PlWindowTitleAlign.center,
    controlsAtEnd: true,
    shape: PlWindowControlShape.circle,
    rule: false,
    stroke: 1.2,
    boxRadius: 0,
    tint: <int>[11, 5],
    accentBorder: false,
  ),
};

/// `size` on a `PlWindowPane`, and the third widget after `PlBox` and
/// `PlMockup` where it does not mean a control height.
///
/// What it scales is the chrome — the bar, the buttons, the title — and nothing
/// else: a window's *content* is the caller's and is laid out at its own scale,
/// exactly as it would be on a real desktop where the title bar does not grow
/// with the document. The steps are gentle for the same reason a 24px title bar
/// is not a smaller title bar but an unusable one.
const Map<PlassSize, double> _scales = <PlassSize, double>{
  PlassSize.xs: 0.8,
  PlassSize.sm: 0.9,
  PlassSize.md: 1,
  PlassSize.lg: 1.15,
  PlassSize.xl: 1.3,
};

/// Everything the widget needs to lay a title bar out, in logical pixels.
@immutable
class PlWindowMetrics {
  /// Creates a set of metrics.
  const PlWindowMetrics({
    required this.bar,
    required this.radius,
    required this.radiusBottom,
    required this.frame,
    required this.band,
    required this.padX,
    required this.padEnd,
    required this.gap,
    required this.title,
    required this.control,
    required this.glyph,
    required this.weight,
    required this.closeWidth,
  });

  /// The title bar's height.
  final double bar;

  /// The window's own corner, at the top.
  final double radius;

  /// And at the bottom.
  final double radiusBottom;

  /// The hairline around the window.
  final double frame;

  /// The band around it.
  final PlWindowBand band;

  /// The air at the leading edge of the bar.
  final double padX;

  /// And at the trailing edge.
  final double padEnd;

  /// Between one control and the next.
  final double gap;

  /// The title's type size.
  final double title;

  /// One control's box.
  final Size control;

  /// The mark inside it.
  final double glyph;

  /// How heavy the title is written.
  final FontWeight weight;

  /// Aero's close button, which is wider than the two beside it.
  final double closeWidth;
}

/// The numbers for one system at one size.
PlWindowMetrics windowMetrics(PlWindowOs os, PlassSize size) {
  final PlWindowChrome chrome = _chromes[os]!;
  final double scale = _scales[size]!;
  double round(double value) => (value * scale).roundToDouble();

  final Size control = Size(round(chrome.control.width), round(chrome.control.height));

  return PlWindowMetrics(
    bar: round(chrome.bar),
    // The corners are *not* scaled with the rest: they are the shape of the
    // window rather than a measure of its chrome, and an `xs` macOS window with
    // a 7px corner stops reading as macOS.
    radius: chrome.radius,
    radiusBottom: chrome.radiusBottom,
    frame: chrome.frame,
    band: PlWindowBand(round(chrome.band.side), round(chrome.band.bottom)),
    padX: round(chrome.padX),
    // A Windows caption button is a corner target — it runs to the edge of the
    // window, which is what makes it hittable by throwing the pointer at the
    // corner. Everything else keeps its air.
    padEnd: round(chrome.padEnd),
    gap: round(chrome.gap),
    title: round(chrome.title),
    control: control,
    glyph: round(chrome.glyph),
    weight: FontWeight.values[(chrome.weight ~/ 100) - 1],
    closeWidth: chrome.closeWidth == null ? control.width : round(chrome.closeWidth!),
  );
}

/// One system's chrome.
PlWindowChrome windowChrome(PlWindowOs os) => _chromes[os]!;

/// The order the buttons go in, per system, and the reason `controls` is a set
/// rather than a list: which three a window has is the caller's decision, and
/// what order they sit in is the system's.
const Map<PlWindowOs, List<PlWindowControl>> _order = <PlWindowOs, List<PlWindowControl>>{
  PlWindowOs.macos: <PlWindowControl>[
    PlWindowControl.close,
    PlWindowControl.minimize,
    PlWindowControl.maximize,
  ],
  PlWindowOs.macosx: <PlWindowControl>[
    PlWindowControl.close,
    PlWindowControl.minimize,
    PlWindowControl.maximize,
  ],
  PlWindowOs.windows11: <PlWindowControl>[
    PlWindowControl.minimize,
    PlWindowControl.maximize,
    PlWindowControl.close,
  ],
  PlWindowOs.windows10: <PlWindowControl>[
    PlWindowControl.minimize,
    PlWindowControl.maximize,
    PlWindowControl.close,
  ],
  PlWindowOs.windows8: <PlWindowControl>[
    PlWindowControl.minimize,
    PlWindowControl.maximize,
    PlWindowControl.close,
  ],
  PlWindowOs.windows7: <PlWindowControl>[
    PlWindowControl.minimize,
    PlWindowControl.maximize,
    PlWindowControl.close,
  ],
  PlWindowOs.windowsxp: <PlWindowControl>[
    PlWindowControl.minimize,
    PlWindowControl.maximize,
    PlWindowControl.close,
  ],
  PlWindowOs.linux: <PlWindowControl>[
    PlWindowControl.minimize,
    PlWindowControl.maximize,
    PlWindowControl.close,
  ],
};

/// The buttons a window has, in the order its system puts them.
List<PlWindowControl> orderControls(PlWindowOs os, Set<PlWindowControl> controls) =>
    <PlWindowControl>[
      for (final PlWindowControl one in _order[os]!)
        if (controls.contains(one)) one,
    ];

/// The traffic lights, which are hardware colours rather than theme tokens: a
/// red close button is red on a page switched to dark.
const Map<PlWindowControl, Color> trafficColors = <PlWindowControl, Color>{
  PlWindowControl.close: Color(0xFFFF5F57),
  PlWindowControl.minimize: Color(0xFFFEBC2E),
  PlWindowControl.maximize: Color(0xFF28C840),
};

/// And XP's plates, which are the same three ideas at a different weight.
const Map<PlWindowControl, Color> plateColors = <PlWindowControl, Color>{
  PlWindowControl.close: Color(0xFFCF4B36),
  PlWindowControl.minimize: Color(0xFF4B85D4),
  PlWindowControl.maximize: Color(0xFF4B85D4),
};

/// What each system turns the close button when the pointer is on it.
const Map<PlWindowOs, Color?> closeHover = <PlWindowOs, Color?>{
  PlWindowOs.macos: null,
  PlWindowOs.macosx: null,
  PlWindowOs.windows11: Color(0xFFC42B1C),
  PlWindowOs.windows10: Color(0xFFE81123),
  PlWindowOs.windows8: Color(0xFFE81123),
  PlWindowOs.windows7: Color(0xFFE04343),
  PlWindowOs.windowsxp: null,
  PlWindowOs.linux: null,
};

/// The mark inside a control: a line, a cross, a box, or two boxes.
class PlWindowGlyphPainter extends CustomPainter {
  /// Creates a glyph.
  const PlWindowGlyphPainter({
    required this.control,
    required this.maximized,
    required this.chrome,
    required this.ink,
  });

  /// Which button this is.
  final PlWindowControl control;

  /// Whether the window is filling its container, which turns the maximize box
  /// into the two-box restore mark every system uses to say "this came from
  /// somewhere smaller".
  final bool maximized;

  /// The system, for its stroke weight and box corner.
  final PlWindowChrome chrome;

  /// What it is drawn in.
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.width / 10;
    final bool round = chrome.boxRadius > 0 || chrome.shape != PlWindowControlShape.square;
    final Paint stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = chrome.stroke * unit
      ..strokeCap = round ? StrokeCap.round : StrokeCap.square
      ..strokeJoin = round ? StrokeJoin.round : StrokeJoin.miter;

    switch (control) {
      case PlWindowControl.minimize:
        // On the systems whose button is a plate, the minimize mark sits low in
        // it rather than through the middle, which is where every one of them
        // drew it.
        final double y = chrome.shape == PlWindowControlShape.plate ? 7.5 : 5;
        final double from = chrome.shape == PlWindowControlShape.plate ? 2 : 1.5;
        final double to = chrome.shape == PlWindowControlShape.plate ? 8 : 8.5;

        canvas.drawLine(Offset(from * unit, y * unit), Offset(to * unit, y * unit), stroke);
      case PlWindowControl.close:
        canvas
          ..drawLine(Offset(1.6 * unit, 1.6 * unit), Offset(8.4 * unit, 8.4 * unit), stroke)
          ..drawLine(Offset(8.4 * unit, 1.6 * unit), Offset(1.6 * unit, 8.4 * unit), stroke);
      case PlWindowControl.maximize:
        final Radius corner = Radius.circular(chrome.boxRadius * unit);

        if (!maximized) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(1.5 * unit, 1.5 * unit, 7 * unit, 7 * unit),
              corner,
            ),
            stroke,
          );

          return;
        }

        canvas
          ..drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(1.4 * unit, 3.4 * unit, 5.2 * unit, 5.2 * unit),
              corner,
            ),
            stroke,
          )
          ..drawPath(
            Path()
              ..moveTo(3.6 * unit, 3.4 * unit)
              ..lineTo(3.6 * unit, 1.4 * unit)
              ..lineTo(8.6 * unit, 1.4 * unit)
              ..lineTo(8.6 * unit, 6.4 * unit)
              ..lineTo(6.6 * unit, 6.4 * unit),
            stroke,
          );
    }
  }

  @override
  bool shouldRepaint(PlWindowGlyphPainter old) =>
      old.control != control ||
      old.maximized != maximized ||
      old.ink != ink ||
      old.chrome != chrome;
}
