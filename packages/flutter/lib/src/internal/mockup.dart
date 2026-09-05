/// The device a `PlMockup` is a picture of: the tables that say how big it is,
/// and the drawings that go on its screen.
///
/// It lives here for the reason `internal/chart.dart` does. Only one widget
/// reads it, but what it holds is a body of reference data rather than a piece
/// of that widget — five resolutions per device, three shells, six systems'
/// worth of chrome — and a widget file with all of that in it would be a table
/// with a `build` at the bottom.
///
/// **Every length in here is a device pixel.** The screen is laid out at the
/// resolution it claims to have and the whole frame is scaled once, at the top,
/// so a 54px status bar is 54px on the phone rather than 54px on the page.
///
/// It is not exported from `plass_ui.dart`.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// Which machine a mockup is a picture of.
enum PlMockupDevice {
  /// A monitor or a laptop.
  desktop,

  /// A tablet.
  tablet,

  /// A phone.
  mobile,
}

/// The system whose chrome is drawn on the screen.
enum PlMockupOs {
  /// A desktop.
  macos,

  /// A desktop.
  windows,

  /// A desktop.
  linux,

  /// A phone.
  ios,

  /// A tablet.
  ipados,

  /// A phone or a tablet.
  android,
}

/// What holds a desktop screen up.
enum PlMockupHardware {
  /// A stand under it.
  monitor,

  /// A keyboard in front of it.
  laptop,
}

/// The camera cut-out.
enum PlMockupNotch {
  /// None at all.
  none,

  /// Cut out of the top edge.
  notch,

  /// Floating clear of it.
  dynamicIsland,

  /// A hole in the corner.
  punchHole,
}

/// How much hardware there is around the screen.
enum PlMockupBezel {
  /// None. Not a thinner bezel — no hardware at all, leaving the screen on its
  /// own with its corners cut.
  none,

  /// A modern device: an even, narrow frame.
  thin,

  /// The default.
  standard,

  /// An older device: narrow sides, a forehead and a chin.
  thick,
}

/// What the hardware is made of.
enum PlMockupFinish {
  /// Near-black.
  graphite,

  /// Light metal.
  silver,

  /// Off-white.
  white,
}

/// Which way a handheld is held.
///
/// `portrait`/`landscape` rather than [PlassOrientation]'s
/// `horizontal`/`vertical`, and this is the one place the library spells the
/// idea twice on purpose. A `PlDivider` running horizontally is not
/// "landscape", and a device held upright is not "vertical" in any vocabulary a
/// designer or a media query uses.
enum PlMockupOrientation {
  /// Upright.
  portrait,

  /// Turned.
  landscape,
}

/// A screen's logical resolution, in device pixels.
@immutable
class PlMockupResolution {
  /// Creates a resolution.
  const PlMockupResolution(this.width, this.height);

  /// How wide the screen is.
  final double width;

  /// And how tall.
  final double height;

  @override
  bool operator ==(Object other) =>
      other is PlMockupResolution && other.width == width && other.height == height;

  @override
  int get hashCode => Object.hash(width, height);
}

const Map<PlMockupDevice, List<PlMockupOs>> _systems = <PlMockupDevice, List<PlMockupOs>>{
  PlMockupDevice.desktop: <PlMockupOs>[PlMockupOs.macos, PlMockupOs.windows, PlMockupOs.linux],
  PlMockupDevice.tablet: <PlMockupOs>[PlMockupOs.ipados, PlMockupOs.android],
  PlMockupDevice.mobile: <PlMockupOs>[PlMockupOs.ios, PlMockupOs.android],
};

/// The system a device will actually draw.
///
/// An OS the device does not run falls back to its default, with one nicety: a
/// caller who writes `ios` on a tablet or `ipados` on a phone meant the Apple
/// one and gets it, rather than being sent back to the start of the list.
PlMockupOs resolveOs(PlMockupDevice device, PlMockupOs? os) {
  final List<PlMockupOs> allowed = _systems[device]!;

  if (os != null && allowed.contains(os)) {
    return os;
  }

  if (os == PlMockupOs.ios && device == PlMockupDevice.tablet) {
    return PlMockupOs.ipados;
  }

  if (os == PlMockupOs.ipados && device == PlMockupDevice.mobile) {
    return PlMockupOs.ios;
  }

  return allowed.first;
}

/// What a device puts in its screen when the caller says nothing.
PlMockupNotch defaultNotch(PlMockupDevice device, PlMockupOs os) {
  if (device != PlMockupDevice.mobile) {
    return PlMockupNotch.none;
  }

  return os == PlMockupOs.android ? PlMockupNotch.punchHole : PlMockupNotch.dynamicIsland;
}

/* ---------------------------------------------------------------------------
 * Resolutions
 *
 * Logical device pixels — the width a page inside the screen would report —
 * rather than the panel's physical pixel count, because that is the number the
 * content is laid out against and the only one a caller can do anything with.
 * ------------------------------------------------------------------------- */

/// Five real machines per device, on the size ladder.
///
/// This is the second widget after `PlBox` where `size` does not mean a control
/// height. On a box it is the size of the sheet; here it is the size of the
/// *device*, which is the only thing about a mockup there is to scale.
const Map<PlMockupDevice, Map<PlassSize, PlMockupResolution>> resolutions =
    <PlMockupDevice, Map<PlassSize, PlMockupResolution>>{
      PlMockupDevice.mobile: <PlassSize, PlMockupResolution>{
        PlassSize.xs: PlMockupResolution(320, 568),
        PlassSize.sm: PlMockupResolution(360, 780),
        PlassSize.md: PlMockupResolution(390, 844),
        PlassSize.lg: PlMockupResolution(414, 896),
        PlassSize.xl: PlMockupResolution(430, 932),
      },
      PlMockupDevice.tablet: <PlassSize, PlMockupResolution>{
        PlassSize.xs: PlMockupResolution(744, 1133),
        PlassSize.sm: PlMockupResolution(768, 1024),
        PlassSize.md: PlMockupResolution(820, 1180),
        PlassSize.lg: PlMockupResolution(834, 1194),
        PlassSize.xl: PlMockupResolution(1024, 1366),
      },
      PlMockupDevice.desktop: <PlassSize, PlMockupResolution>{
        PlassSize.xs: PlMockupResolution(1024, 640),
        PlassSize.sm: PlMockupResolution(1280, 800),
        PlassSize.md: PlMockupResolution(1440, 900),
        PlassSize.lg: PlMockupResolution(1680, 1050),
        PlassSize.xl: PlMockupResolution(1920, 1200),
      },
    };

/* ---------------------------------------------------------------------------
 * Shells
 * ------------------------------------------------------------------------- */

/// How much hardware sits on each side of the screen.
@immutable
class PlMockupInset {
  /// Creates an inset.
  const PlMockupInset(this.x, this.top, this.bottom);

  /// Each side.
  final double x;

  /// Above the screen.
  final double top;

  /// And below it.
  final double bottom;
}

class _Shell {
  const _Shell(this.bezel, this.frameRadius, this.screenRadius);

  final PlMockupInset bezel;

  /// The outside of the hardware.
  final double frameRadius;

  /// The glass inside it. Written out rather than derived from the bezel: on a
  /// thick-bezelled device the screen is square-cornered, which no amount of
  /// subtracting from the frame's radius produces.
  final double screenRadius;
}

const Map<PlMockupDevice, Map<PlMockupBezel, _Shell>> _shells =
    <PlMockupDevice, Map<PlMockupBezel, _Shell>>{
      PlMockupDevice.mobile: <PlMockupBezel, _Shell>{
        PlMockupBezel.thin: _Shell(PlMockupInset(8, 8, 8), 50, 42),
        PlMockupBezel.standard: _Shell(PlMockupInset(13, 13, 13), 56, 43),
        PlMockupBezel.thick: _Shell(PlMockupInset(16, 62, 62), 40, 4),
      },
      PlMockupDevice.tablet: <PlMockupBezel, _Shell>{
        PlMockupBezel.thin: _Shell(PlMockupInset(12, 12, 12), 34, 22),
        PlMockupBezel.standard: _Shell(PlMockupInset(20, 20, 20), 42, 22),
        PlMockupBezel.thick: _Shell(PlMockupInset(28, 74, 74), 36, 4),
      },
      PlMockupDevice.desktop: <PlMockupBezel, _Shell>{
        PlMockupBezel.thin: _Shell(PlMockupInset(8, 8, 8), 12, 4),
        PlMockupBezel.standard: _Shell(PlMockupInset(13, 13, 30), 16, 4),
        PlMockupBezel.thick: _Shell(PlMockupInset(22, 22, 62), 18, 3),
      },
    };

/// The screen's own radius when there is no hardware to be concentric with.
const Map<PlMockupDevice, double> _bareRadius = <PlMockupDevice, double>{
  PlMockupDevice.mobile: 42,
  PlMockupDevice.tablet: 24,
  PlMockupDevice.desktop: 8,
};

/// A monitor's neck and foot.
@immutable
class PlMockupStand {
  /// Creates a stand.
  const PlMockupStand(this.neckWidth, this.neckHeight, this.footWidth, this.footHeight);

  /// How wide the neck is where it meets the foot.
  final double neckWidth;

  /// How far it drops.
  final double neckHeight;

  /// How wide the foot is.
  final double footWidth;

  /// And how thick.
  final double footHeight;
}

/// A laptop's base.
@immutable
class PlMockupBase {
  /// Creates a base.
  const PlMockupBase(this.width, this.height, this.lipWidth);

  /// Wider than the lid.
  final double width;

  /// And shallow.
  final double height;

  /// The lip the lid is opened by.
  final double lipWidth;
}

/// Every number the widget needs to lay a device out, in device pixels.
@immutable
class PlMockupMetrics {
  /// Creates a set of metrics.
  const PlMockupMetrics({
    required this.screen,
    required this.bezel,
    required this.body,
    required this.frame,
    required this.frameRadius,
    required this.screenRadius,
    this.stand,
    this.base,
  });

  /// The screen, after the orientation has had its say.
  final PlMockupResolution screen;

  /// The hardware around it. Zero on all four sides when the bezel is `none`.
  final PlMockupInset bezel;

  /// Screen plus bezel: the part you would call the device's face.
  final Size body;

  /// Face plus whatever holds it up. This is what gets scaled to fit.
  final Size frame;

  /// The outside of the hardware.
  final double frameRadius;

  /// The glass inside it.
  final double screenRadius;

  /// A monitor's stand, when there is one.
  final PlMockupStand? stand;

  /// A laptop's base, when there is one.
  final PlMockupBase? base;
}

/// Works out where every part of a device goes.
///
/// A desktop has one orientation and it is the one it is drawn in. Rotating a
/// monitor is a thing people do, but a mockup of it is a different picture —
/// the stand does not move — and pretending otherwise would draw a landscape
/// stand under a portrait screen.
PlMockupMetrics mockupMetrics({
  required PlMockupDevice device,
  required PlassSize size,
  required PlMockupOrientation orientation,
  required PlMockupBezel bezel,
  required PlMockupHardware hardware,
  PlMockupResolution? resolution,
}) {
  final PlMockupResolution native = resolution ?? resolutions[device]![size]!;
  final bool landscape =
      device != PlMockupDevice.desktop && orientation == PlMockupOrientation.landscape;
  final PlMockupResolution screen = landscape
      ? PlMockupResolution(native.height, native.width)
      : native;

  if (bezel == PlMockupBezel.none) {
    return PlMockupMetrics(
      screen: screen,
      bezel: const PlMockupInset(0, 0, 0),
      body: Size(screen.width, screen.height),
      frame: Size(screen.width, screen.height),
      frameRadius: _bareRadius[device]!,
      screenRadius: _bareRadius[device]!,
    );
  }

  final _Shell shell = _shells[device]![bezel]!;
  // Turning the device turns its bezel with it: the forehead and chin of a
  // thick-bezelled phone become its left and right edges.
  final PlMockupInset inset = landscape
      ? PlMockupInset(shell.bezel.top, shell.bezel.x, shell.bezel.x)
      : shell.bezel;
  // A laptop's chin is on its base, not on its lid, so the lid's bezel is even.
  final bool laptop = device == PlMockupDevice.desktop && hardware == PlMockupHardware.laptop;
  final PlMockupInset frameInset = laptop ? PlMockupInset(inset.x, inset.top, inset.top) : inset;

  final Size body = Size(
    screen.width + frameInset.x * 2,
    screen.height + frameInset.top + frameInset.bottom,
  );

  if (device != PlMockupDevice.desktop) {
    return PlMockupMetrics(
      screen: screen,
      bezel: frameInset,
      body: body,
      frame: body,
      frameRadius: shell.frameRadius,
      screenRadius: shell.screenRadius,
    );
  }

  if (laptop) {
    // The base is wider than the lid and shallow — the proportion a laptop seen
    // from the front actually has, rather than the wedge it has from the side.
    final base = PlMockupBase(
      (body.width * 1.075).roundToDouble(),
      (body.height * 0.035).roundToDouble(),
      (body.width * 0.12).roundToDouble(),
    );

    return PlMockupMetrics(
      screen: screen,
      bezel: frameInset,
      body: body,
      frame: Size(base.width, body.height + base.height),
      frameRadius: shell.frameRadius,
      screenRadius: shell.screenRadius,
      base: base,
    );
  }

  final stand = PlMockupStand(
    (body.width * 0.11).roundToDouble(),
    (body.height * 0.09).roundToDouble(),
    (body.width * 0.28).roundToDouble(),
    (body.height * 0.018).roundToDouble(),
  );

  return PlMockupMetrics(
    screen: screen,
    bezel: frameInset,
    body: body,
    frame: Size(body.width, body.height + stand.neckHeight + stand.footHeight),
    frameRadius: shell.frameRadius,
    screenRadius: shell.screenRadius,
    stand: stand,
  );
}

/* ---------------------------------------------------------------------------
 * Finishes
 * ------------------------------------------------------------------------- */

/// What the hardware is made of, as three colours.
@immutable
class PlMockupShellColors {
  /// Creates a finish.
  const PlMockupShellColors(this.shell, this.edge, this.shade);

  /// The face of the hardware.
  final Color shell;

  /// The light along its top edge.
  final Color edge;

  /// The hairline all the way round, and the ring under the glass.
  final Color shade;
}

/// Fixed colours rather than theme tokens, because hardware is hardware.
///
/// A graphite phone is the same graphite on a page that has been switched to
/// dark, and a device that changed colour with the theme would read as a
/// drawing of the theme rather than of a device.
const Map<PlMockupFinish, PlMockupShellColors> finishes = <PlMockupFinish, PlMockupShellColors>{
  PlMockupFinish.graphite: PlMockupShellColors(
    Color(0xFF2B2F38),
    Color(0x29FFFFFF),
    Color(0xFF181B22),
  ),
  PlMockupFinish.silver: PlMockupShellColors(
    Color(0xFFCFD2D7),
    Color(0xBFFFFFFF),
    Color(0xFF9CA1A9),
  ),
  PlMockupFinish.white: PlMockupShellColors(
    Color(0xFFF3F4F6),
    Color(0xE6FFFFFF),
    Color(0xFFC1C4CA),
  ),
};

/// How far off the page the whole device sits.
///
/// A silhouette rather than a box, which is why it is a shadow *filter* rather
/// than a `BoxShadow`: the shadow has to follow a rounded lid on a narrow neck
/// on a wide foot, and a box shadow would draw the rectangle that contains all
/// three. It also sits outside the scale, so a device shrunk to a third of its
/// size does not get a third of its shadow.
List<BoxShadow> mockupElevation(int level, Color ambient) {
  switch (level) {
    case 0:
      return const <BoxShadow>[];
    case 1:
      return <BoxShadow>[BoxShadow(color: ambient, blurRadius: 2, offset: const Offset(0, 1))];
    case 2:
      return <BoxShadow>[
        BoxShadow(color: ambient, blurRadius: 4, offset: const Offset(0, 2)),
        BoxShadow(color: ambient, blurRadius: 12, offset: const Offset(0, 8)),
      ];
    default:
      return <BoxShadow>[
        BoxShadow(color: ambient, blurRadius: 6, offset: const Offset(0, 4)),
        BoxShadow(color: ambient, blurRadius: 28, offset: const Offset(0, 18)),
      ];
  }
}

/// The camera, drawn on the glass.
///
/// Portrait puts it against the top edge and landscape against the leading one,
/// which is where it goes on a real device turned the same way — and it is why
/// the island does not collide with the status bar in landscape: it has moved
/// out from under it.
Widget? mockupCutout({
  required PlMockupNotch notch,
  required PlMockupResolution screen,
  required bool landscape,
}) {
  if (notch == PlMockupNotch.none) {
    return null;
  }

  const Color ink = Color(0xFF0B0D12);
  final double along = landscape ? screen.height : screen.width;

  if (notch == PlMockupNotch.punchHole) {
    final double diameter = math.max(16, (along * 0.07).roundToDouble());
    final double offset = (diameter * 0.55).roundToDouble();

    return Positioned(
      left: landscape ? offset : null,
      top: landscape ? null : offset,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: const BoxDecoration(color: ink, shape: BoxShape.circle),
      ),
    );
  }

  if (notch == PlMockupNotch.dynamicIsland) {
    final double length = math.max(96, (along * 0.32).roundToDouble());
    final double depth = (length * 0.29).roundToDouble();
    final double offset = (depth * 0.32).roundToDouble();

    return Positioned(
      left: landscape ? offset : null,
      top: landscape ? null : offset,
      child: Container(
        width: landscape ? depth : length,
        height: landscape ? length : depth,
        decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(depth)),
      ),
    );
  }

  // A notch is cut out of the edge rather than floating on the glass, so it is
  // rounded only on the three corners that are not against it.
  final double length = math.max(120, (along * 0.42).roundToDouble());
  final double depth = (length * 0.23).roundToDouble();
  final Radius radius = Radius.circular((depth * 0.6).roundToDouble());

  return Positioned(
    left: landscape ? 0 : null,
    top: landscape ? null : 0,
    child: Container(
      width: landscape ? depth : length,
      height: landscape ? length : depth,
      decoration: BoxDecoration(
        color: ink,
        borderRadius: landscape
            ? BorderRadius.only(topRight: radius, bottomRight: radius)
            : BorderRadius.only(bottomLeft: radius, bottomRight: radius),
      ),
    ),
  );
}

/* ---------------------------------------------------------------------------
 * The chrome
 * ------------------------------------------------------------------------- */

/// What a system puts on the screen, and how much room it takes.
@immutable
class PlMockupChrome {
  /// Creates a set of bars.
  const PlMockupChrome({this.top, this.bottom, this.start});

  /// The bar along the top, and how tall it is.
  final Widget? top;

  /// And along the bottom.
  final Widget? bottom;

  /// A dock down the leading edge. Only Linux has one.
  final Widget? start;
}

/// A tile: an app icon, a menu title, a tray glyph.
Widget _tile(double width, double radius, Color ink, {double? height, double opacity = 0.26}) {
  return Container(
    width: width,
    height: height ?? width,
    decoration: BoxDecoration(
      color: ink.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// A row of them, with the first one carrying the colour family.
Widget _tiles(int count, double size, double radius, double gap, Color ink, Color? accent) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    spacing: gap,
    children: <Widget>[
      for (int i = 0; i < count; i += 1)
        if (accent != null && i == 0)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(radius)),
          )
        else
          _tile(size, radius, ink),
    ],
  );
}

/// The bar's own fill.
///
/// `surface` rather than the wallpaper, because a status bar that inherited a
/// dark wallpaper would be unreadable — and it is a flat translucency rather
/// than the house blur, which is the one place the glass is given up: a blur
/// inside a scaled subtree samples the wrong region, and the whole device is
/// inside a scale.
Widget _bar({
  required double height,
  required PlassTokens tokens,
  required Widget child,
  double padding = 0,
  bool transparent = false,
}) {
  return Container(
    height: height,
    padding: EdgeInsets.symmetric(horizontal: padding),
    color: transparent ? null : tokens.surface.withValues(alpha: 0.88),
    child: child,
  );
}

Widget _clock(String time, PlassTokens tokens, double size) => Text(
  time,
  style: TextStyle(fontSize: size, fontWeight: FontWeight.w500, color: tokens.fg),
);

/// The trio on the trailing end of a status bar.
Widget _statusGlyphs(double height, double gap, Color ink) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    spacing: gap,
    children: <Widget>[
      CustomPaint(size: Size(height * 17 / 11, height), painter: _SignalPainter(ink)),
      CustomPaint(size: Size(height * 16 / 12, height), painter: _WifiPainter(ink)),
      CustomPaint(size: Size(height * 25 / 12, height), painter: _BatteryPainter(ink)),
    ],
  );
}

/// The bars, per system.
///
/// Each one takes its own space rather than floating over the content: a caller
/// putting a screenshot in a mockup wants all of the screenshot, and a status
/// bar that covered the top of it would be a crop nobody asked for. The cut-out
/// is the exception, because that one really is a hole in the glass.
PlMockupChrome mockupChrome({
  required PlMockupOs os,
  required PlMockupNotch notch,
  required bool landscape,
  required String time,
  required PlassTokens tokens,
  required Color accent,
}) {
  final Color ink = tokens.fg;

  if (os == PlMockupOs.ios || os == PlMockupOs.ipados) {
    final bool tablet = os == PlMockupOs.ipados;
    // The island and the notch both stand in the middle of the status bar, so
    // the bar has to be tall enough to have a middle. In landscape they have
    // moved to the edge and it does not.
    final bool raised =
        !tablet && !landscape && notch != PlMockupNotch.none && notch != PlMockupNotch.punchHole;
    final double height = tablet ? 30 : (raised ? 54 : 44);

    return PlMockupChrome(
      top: _bar(
        height: height,
        tokens: tokens,
        padding: tablet ? 22 : 26,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[_clock(time, tokens, 15), _statusGlyphs(tablet ? 11 : 12, 6, ink)],
        ),
      ),
      bottom: _bar(
        height: tablet ? 22 : 34,
        tokens: tokens,
        transparent: true,
        child: Center(
          child: Container(
            width: tablet ? 220 : 140,
            height: 5,
            decoration: BoxDecoration(
              color: ink.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }

  if (os == PlMockupOs.android) {
    return PlMockupChrome(
      top: _bar(
        height: 34,
        tokens: tokens,
        padding: 18,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[_clock(time, tokens, 13), _statusGlyphs(11, 5, ink)],
        ),
      ),
      bottom: _bar(
        height: 48,
        tokens: tokens,
        child: Center(
          child: Opacity(
            opacity: 0.72,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 72,
              children: <Widget>[
                CustomPaint(size: const Size(20, 20), painter: _BackPainter(ink)),
                CustomPaint(size: const Size(20, 20), painter: _HomePainter(ink)),
                CustomPaint(size: const Size(20, 20), painter: _RecentsPainter(ink)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  if (os == PlMockupOs.macos) {
    return PlMockupChrome(
      top: _bar(
        height: 28,
        tokens: tokens,
        padding: 16,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: <Widget>[
                _tile(13, 4, ink),
                _tile(34, 4, ink, height: 7),
                _tile(26, 4, ink, height: 7, opacity: 0.12),
                _tile(30, 4, ink, height: 7, opacity: 0.12),
                _tile(22, 4, ink, height: 7, opacity: 0.12),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 14,
              children: <Widget>[
                _tile(11, 3, ink, opacity: 0.12),
                _tile(11, 3, ink, opacity: 0.12),
                _clock(time, tokens, 13),
              ],
            ),
          ],
        ),
      ),
      // The dock is a sheet of its own floating clear of the edge, which is the
      // one thing about it that is unmistakable at any size.
      bottom: SizedBox(
        height: 78,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tokens.surface.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(22),
              boxShadow: tokens.elevation(2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: <Widget>[
                _tiles(5, 52, 14, 10, ink, accent),
                Container(width: 1, height: 44, color: ink.withValues(alpha: 0.16)),
                _tiles(2, 52, 14, 10, ink, null),
              ],
            ),
          ),
        ),
      ),
    );
  }

  if (os == PlMockupOs.windows) {
    return PlMockupChrome(
      bottom: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: tokens.border)),
        ),
        child: _bar(
          height: 52,
          tokens: tokens,
          padding: 16,
          child: Stack(
            children: <Widget>[
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: <Widget>[
                    Opacity(
                      opacity: 0.7,
                      child: CustomPaint(size: const Size(22, 22), painter: _StartPainter(ink)),
                    ),
                    _tiles(6, 30, 8, 10, ink, accent),
                  ],
                ),
              ),
              PositionedDirectional(
                end: 0,
                top: 0,
                bottom: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: <Widget>[
                    _tile(11, 3, ink, opacity: 0.12),
                    _tile(11, 3, ink, opacity: 0.12),
                    _clock(time, tokens, 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  return PlMockupChrome(
    top: _bar(
      height: 34,
      tokens: tokens,
      padding: 14,
      child: Stack(
        children: <Widget>[
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            child: Center(child: _tile(52, 5, ink, height: 9)),
          ),
          Center(child: _clock(time, tokens, 13)),
          PositionedDirectional(
            end: 0,
            top: 0,
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: <Widget>[
                _tile(10, 3, ink, opacity: 0.12),
                _tile(10, 3, ink, opacity: 0.12),
                _tile(10, 3, ink, opacity: 0.12),
              ],
            ),
          ),
        ],
      ),
    ),
    // The one dock that runs down an edge rather than along one, which is what
    // makes a Linux desktop recognisable from across a room.
    start: DecoratedBox(
      decoration: BoxDecoration(
        border: BorderDirectional(end: BorderSide(color: tokens.border)),
      ),
      child: Container(
        width: 66,
        color: tokens.surface.withValues(alpha: 0.88),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          spacing: 10,
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(12)),
            ),
            _tile(44, 12, ink),
            _tile(44, 12, ink),
            _tile(44, 12, ink),
          ],
        ),
      ),
    ),
  );
}

/// The four bars of a signal meter, the last one faint.
class _SignalPainter extends CustomPainter {
  const _SignalPainter(this.ink);

  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.height / 11;
    final Paint paint = Paint()..color = ink;
    const List<List<double>> bars = <List<double>>[
      <double>[0, 7.5, 3, 3.5],
      <double>[4.7, 5, 3, 6],
      <double>[9.4, 2.5, 3, 8.5],
      <double>[14, 0, 3, 11],
    ];

    for (int i = 0; i < bars.length; i += 1) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bars[i][0] * unit, bars[i][1] * unit, bars[i][2] * unit, bars[i][3] * unit),
          Radius.circular(unit),
        ),
        i == 3 ? (Paint()..color = ink.withValues(alpha: 0.35)) : paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SignalPainter old) => old.ink != ink;
}

/// Two arcs and a dot.
class _WifiPainter extends CustomPainter {
  const _WifiPainter(this.ink);

  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.height / 12;
    final Paint stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * unit
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawArc(
        Rect.fromLTWH(unit, unit, 14 * unit, 14 * unit),
        math.pi * 1.15,
        math.pi * 0.7,
        false,
        stroke,
      )
      ..drawArc(
        Rect.fromLTWH(3.6 * unit, 4 * unit, 8.8 * unit, 8.8 * unit),
        math.pi * 1.2,
        math.pi * 0.6,
        false,
        stroke,
      )
      ..drawCircle(Offset(8 * unit, 10.2 * unit), 1.6 * unit, Paint()..color = ink);
  }

  @override
  bool shouldRepaint(_WifiPainter old) => old.ink != ink;
}

/// A cell, a charge and a cap.
class _BatteryPainter extends CustomPainter {
  const _BatteryPainter(this.ink);

  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.height / 12;
    final Paint faint = Paint()..color = ink.withValues(alpha: 0.45);

    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.7 * unit, 0.7 * unit, 20.6 * unit, 10.6 * unit),
          Radius.circular(3.2 * unit),
        ),
        Paint()
          ..color = ink.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3 * unit,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(2.6 * unit, 2.6 * unit, 12.8 * unit, 6.8 * unit),
          Radius.circular(1.8 * unit),
        ),
        Paint()..color = ink,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(22.8 * unit, 4 * unit, 1.8 * unit, 4 * unit),
          Radius.circular(0.9 * unit),
        ),
        faint,
      );
  }

  @override
  bool shouldRepaint(_BatteryPainter old) => old.ink != ink;
}

/// Android's back chevron.
class _BackPainter extends CustomPainter {
  const _BackPainter(this.ink);

  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.height / 16;

    canvas.drawPath(
      Path()
        ..moveTo(10 * unit, 3 * unit)
        ..lineTo(5 * unit, 8 * unit)
        ..lineTo(10 * unit, 13 * unit),
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * unit
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_BackPainter old) => old.ink != ink;
}

/// Android's home circle.
class _HomePainter extends CustomPainter {
  const _HomePainter(this.ink);

  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.height / 16;

    canvas.drawCircle(
      Offset(8 * unit, 8 * unit),
      5 * unit,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * unit,
    );
  }

  @override
  bool shouldRepaint(_HomePainter old) => old.ink != ink;
}

/// Android's recents square.
class _RecentsPainter extends CustomPainter {
  const _RecentsPainter(this.ink);

  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.height / 16;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3.5 * unit, 3.5 * unit, 9 * unit, 9 * unit),
        Radius.circular(1.6 * unit),
      ),
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * unit,
    );
  }

  @override
  bool shouldRepaint(_RecentsPainter old) => old.ink != ink;
}

/// Windows' four squares.
class _StartPainter extends CustomPainter {
  const _StartPainter(this.ink);

  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.height / 16;
    final Paint paint = Paint()..color = ink;

    for (final List<double> at in <List<double>>[
      <double>[1, 1],
      <double>[9, 1],
      <double>[1, 9],
      <double>[9, 9],
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(at[0] * unit, at[1] * unit, 6 * unit, 6 * unit),
          Radius.circular(1.4 * unit),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StartPainter old) => old.ink != ink;
}
