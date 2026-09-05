/// A device with a screen you can put anything on.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/mockup.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

export 'package:plass_ui/src/internal/mockup.dart'
    show
        PlMockupBezel,
        PlMockupDevice,
        PlMockupFinish,
        PlMockupHardware,
        PlMockupNotch,
        PlMockupOrientation,
        PlMockupOs,
        PlMockupResolution;

/// A device with a screen you can put anything on: a phone, a tablet, a monitor
/// or a laptop, with the system's own bars drawn on it.
///
/// The screen is laid out at the device's own resolution — an `md` phone is 390
/// by 844 pixels — and the whole device is then scaled once to whatever room it
/// has been given. So the content inside is laid out against a *screen* rather
/// than against the page: a 390-pixel column wraps where it would wrap on a
/// phone, and the mockup can be 200 pixels wide on the page without the content
/// knowing.
///
/// That scale is a transform, and it is the one place in the library where one
/// is used. The rule it is an exception to is about controls, where a scale
/// resamples a label under the finger pressing it. Nothing here is pressed and
/// the scale never changes on an interaction: it is set once from the space
/// available, which is the only way to draw a 1440-pixel desktop in a
/// paragraph's width at all.
///
/// ```dart
/// PlMockup(
///   device: PlMockupDevice.mobile,
///   child: MyApp(),
/// )
/// ```
class PlMockup extends StatelessWidget {
  /// Creates a mockup.
  const PlMockup({
    required this.device,
    this.os,
    this.hardware = PlMockupHardware.monitor,
    this.size,
    this.resolution,
    this.orientation = PlMockupOrientation.portrait,
    this.bezel = PlMockupBezel.standard,
    this.finish = PlMockupFinish.graphite,
    this.notch,
    this.systemUi = true,
    this.wallpaper,
    this.time = '9:41',
    this.width,
    this.height,
    this.color,
    this.elevation = 0,
    this.child,
    super.key,
  });

  /// Which machine this is a picture of. The one prop with no default: a mockup
  /// that has not said what it is a mockup of has not said anything.
  final PlMockupDevice device;

  /// The system whose chrome is drawn on the screen. Anything the device does
  /// not run falls back to its own default.
  final PlMockupOs? os;

  /// What holds a desktop screen up. Ignored on a tablet and a phone, which
  /// hold themselves up.
  final PlMockupHardware hardware;

  /// How big the device is, on a five-step ladder of real resolutions.
  ///
  /// As on `PlBox`, `size` here does not set a height or a type scale. What it
  /// sets is the resolution of the screen, which is the only thing about a
  /// device there is to scale. [resolution] overrides it outright.
  final PlassSize? size;

  /// The screen's logical resolution, when none of the five steps is the
  /// machine you mean.
  final PlMockupResolution? resolution;

  /// Which way a handheld is held. Landscape turns the screen, the bezel and
  /// the cut-out together. Ignored on a desktop, whose stand does not turn.
  final PlMockupOrientation orientation;

  /// How much hardware there is around the screen.
  final PlMockupBezel bezel;

  /// What the hardware is made of.
  final PlMockupFinish finish;

  /// The camera cut-out. Hardware rather than chrome, so it is drawn whether or
  /// not [systemUi] is on. Defaults to what the device would have.
  final PlMockupNotch? notch;

  /// Draws the system's own bars. Each one takes its own space rather than
  /// covering the content, so turning it off gives the screen back to [child]
  /// rather than uncovering anything.
  final bool systemUi;

  /// What is behind the content. The page's own surface colour by default.
  final Decoration? wallpaper;

  /// The clock in the status bar or the taskbar, and the only text the chrome
  /// draws. A string rather than a `DateTime`, because a mockup's clock is a
  /// prop of the picture.
  final String time;

  /// The rendered width of the whole device. The device is laid out at its own
  /// resolution and then scaled to whatever this comes to, so the content
  /// inside is genuinely a screen's worth rather than a page's worth shrunk.
  final double? width;

  /// The rendered height. Given on its own it decides the size and the width
  /// follows the device's proportion.
  final double? height;

  /// Reaches the accent in the chrome — a dock's first icon, a taskbar's.
  final PlassColor? color;

  /// How far off the page the device sits. Drawn as a silhouette rather than a
  /// box, so the shadow follows a lid on a neck on a foot.
  final int elevation;

  /// What is on the screen.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final PlassSize step = size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final PlassColor family = color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

    final PlMockupOs system = resolveOs(device, os);
    final PlMockupNotch cutout = notch ?? defaultNotch(device, system);
    final bool landscape =
        device != PlMockupDevice.desktop && orientation == PlMockupOrientation.landscape;
    final PlMockupMetrics metrics = mockupMetrics(
      device: device,
      size: step,
      resolution: resolution,
      orientation: orientation,
      bezel: bezel,
      hardware: hardware,
    );

    final PlMockupShellColors shell = finishes[finish]!;
    final PlMockupChrome chrome = systemUi
        ? mockupChrome(
            os: system,
            notch: cutout,
            landscape: landscape,
            time: time,
            tokens: tokens,
            accent: tokens.family(family).accent,
          )
        : const PlMockupChrome();

    final bool bare = bezel == PlMockupBezel.none;

    final Widget screen = Container(
      width: metrics.screen.width,
      height: metrics.screen.height,
      decoration: BoxDecoration(
        color: wallpaper == null ? tokens.surface : null,
        borderRadius: BorderRadius.circular(metrics.screenRadius),
        // The glass sits a hair below the hardware around it. Not a bevel — a
        // ring in the finish's own dark tone, so a silver phone gets a silver
        // shadow rather than a black line.
        border: bare ? null : Border.all(color: shell.shade),
      ),
      foregroundDecoration: wallpaper,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              if (chrome.top != null) chrome.top!,
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (chrome.start != null) chrome.start!,
                    Expanded(child: ClipRect(child: child ?? const SizedBox.expand())),
                  ],
                ),
              ),
              if (chrome.bottom != null) chrome.bottom!,
            ],
          ),
          // Above the bars, because it is a hole in the glass they are printed
          // on. Left to the source order it would sit under one instead, which
          // is a camera behind a pane of frosted plastic.
          if (mockupCutout(notch: cutout, screen: metrics.screen, landscape: landscape) != null)
            Positioned.fill(
              child: Align(
                alignment: landscape ? Alignment.centerLeft : Alignment.topCenter,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    mockupCutout(notch: cutout, screen: metrics.screen, landscape: landscape)!,
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    final Widget frame = SizedBox(
      width: metrics.frame.width,
      height: metrics.frame.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: metrics.body.width,
            height: metrics.body.height,
            padding: EdgeInsets.fromLTRB(
              metrics.bezel.x,
              metrics.bezel.top,
              metrics.bezel.x,
              metrics.bezel.bottom,
            ),
            decoration: bare
                ? null
                : BoxDecoration(
                    color: shell.shell,
                    borderRadius: BorderRadius.circular(metrics.frameRadius),
                    border: Border.all(color: shell.shade),
                  ),
            child: screen,
          ),
          if (metrics.stand != null) ...<Widget>[
            ClipPath(
              clipper: _NeckClipper(),
              child: Container(
                width: metrics.stand!.neckWidth,
                height: metrics.stand!.neckHeight,
                color: shell.shade,
              ),
            ),
            Container(
              width: metrics.stand!.footWidth,
              height: metrics.stand!.footHeight,
              decoration: BoxDecoration(
                color: shell.shell,
                borderRadius: BorderRadius.circular(metrics.stand!.footHeight / 2),
                border: Border.all(color: shell.shade),
              ),
            ),
          ],
          if (metrics.base != null)
            ClipPath(
              clipper: _BaseClipper(),
              child: Container(
                width: metrics.base!.width,
                height: metrics.base!.height,
                color: shell.shell,
                child: Align(
                  alignment: Alignment.topCenter,
                  // The lip the lid is opened by — the one detail that says this
                  // is a laptop rather than a monitor on a very short stand.
                  child: Container(
                    width: metrics.base!.lipWidth,
                    height: (metrics.base!.height * 0.34).roundToDouble(),
                    decoration: BoxDecoration(
                      color: shell.shade,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular((metrics.base!.height * 0.2).roundToDouble()),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        /* One measurement, and the reason the device cannot simply be sized by
           the layout: the scale is a ratio between a length the parent knows
           and a length only this file knows.

           Both axes, because a height on its own is a legitimate way to size a
           mockup and because a caller who pins both would otherwise get a
           device overflowing whichever one it was not scaled against. */
        final double room =
            width ?? (constraints.maxWidth.isFinite ? constraints.maxWidth : metrics.frame.width);
        final double tall =
            height ??
            (constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : room * metrics.frame.height / metrics.frame.width);
        final double scale = <double>[
          room / metrics.frame.width,
          tall / metrics.frame.height,
        ].reduce((double a, double b) => a < b ? a : b);

        return SizedBox(
          width: metrics.frame.width * scale,
          height: metrics.frame.height * scale,
          child: DecoratedBox(
            // Outside the scale on purpose: a device drawn at a third of its
            // size would otherwise get a third of its shadow and stop reading as
            // an object on a page.
            decoration: BoxDecoration(
              boxShadow: mockupElevation(elevation, tokens.shadowAmbient),
              borderRadius: BorderRadius.circular(metrics.frameRadius * scale),
            ),
            child: FittedBox(fit: BoxFit.contain, child: frame),
          ),
        );
      },
    );
  }
}

/// A monitor's neck: wider where it meets the foot than where it leaves the lid.
class _NeckClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width * 0.16, 0)
    ..lineTo(size.width * 0.84, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(_NeckClipper old) => false;
}

/// A laptop's base, drawn from the front: very slightly tapered.
class _BaseClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width * 0.985, size.height)
    ..lineTo(size.width * 0.015, size.height)
    ..close();

  @override
  bool shouldReclip(_BaseClipper old) => false;
}
