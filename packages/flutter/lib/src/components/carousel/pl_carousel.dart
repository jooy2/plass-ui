/// A strip of slides, one of which is in view.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/icon_button/pl_icon_button.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How far the arrows sit in from the frame's edge.
const Map<PlassSize, double> _arrowInset = <PlassSize, double>{
  PlassSize.xs: 4,
  PlassSize.sm: 6,
  PlassSize.md: 8,
  PlassSize.lg: 12,
  PlassSize.xl: 16,
};

/// A dot at rest, a dot that is current, and the gap between two of them.
///
/// A current dot is a short **bar** rather than a bigger circle: it grows along
/// the row it is in, so the row's height never changes and the dots either side
/// of it do not move. Width and colour are the only two things that travel,
/// which is what keeps the indicator inside the house rule against scaling
/// anything.
const Map<PlassSize, ({double rest, double current, double height, double gap})> _dot =
    <PlassSize, ({double rest, double current, double height, double gap})>{
      PlassSize.xs: (rest: 4, current: 12, height: 4, gap: 4),
      PlassSize.sm: (rest: 4, current: 14, height: 4, gap: 4),
      PlassSize.md: (rest: 6, current: 16, height: 6, gap: 6),
      PlassSize.lg: (rest: 6, current: 20, height: 6, gap: 8),
      PlassSize.xl: (rest: 8, current: 24, height: 8, gap: 8),
    };

/// The room the row of dots keeps above itself.
const double _dotRowGap = 8;

/// A strip of slides, one of which is in view.
///
/// ```dart
/// PlCarousel(
///   label: 'Places',
///   value: slide,
///   onChanged: (int next) => setState(() => slide = next),
///   children: <Widget>[HarbourPhoto(), DunesPhoto(), PinesPhoto()],
/// )
/// ```
///
/// The mechanism is a [PageView], which is Flutter's own scrolling with snap
/// points — so swiping is the platform's rather than a gesture handler
/// imitating it, and the strip runs the other way under RTL without being told.
/// Nothing is transformed: the page view moves a viewport rather than the
/// slides, so the house rule against moving a surface holds here for free.
///
/// Slides are not a sub-widget. Every child becomes one, and the wrapper is what
/// carries the semantics a screen reader needs — none of which a caller should
/// have to remember to put on a photograph.
///
/// **Controlled**, like every other stateful widget in the package: it is handed
/// [value] and reports what the value should become. Leaving [onChanged] out
/// freezes it where it is, [autoPlay] included.
class PlCarousel extends StatefulWidget {
  /// Creates a carousel.
  const PlCarousel({
    required this.children,
    required this.value,
    this.onChanged,
    this.loop = true,
    this.autoPlay = false,
    this.interval = const Duration(seconds: 5),
    this.arrows = true,
    this.indicators = true,
    this.aspectRatio,
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    this.label,
    this.previousLabel,
    this.nextLabel,
    this.slideLabel,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The slides. Every child becomes one.
  final List<Widget> children;

  /// Which slide is showing, counted from 0.
  final int value;

  /// Called with the slide that should come into view.
  final ValueChanged<int>? onChanged;

  /// Whether the arrows wrap from the last slide back to the first.
  ///
  /// With it off they go inert at the ends instead, which is the honest thing
  /// for a set that has a beginning and an end — a gallery of three photographs
  /// does, a rotating banner does not.
  final bool loop;

  /// Advances on its own.
  ///
  /// Off by default and deliberately so: a carousel that moves while it is being
  /// read is the most complained-about pattern there is. It pauses while the
  /// pointer is over it, it does not start at all for a reader who has asked for
  /// reduced motion, and it needs [onChanged] — a frozen carousel has nothing to
  /// advance.
  final bool autoPlay;

  /// How long each slide is held.
  final Duration interval;

  /// The previous/next buttons.
  final bool arrows;

  /// The row of position dots under the frame.
  final bool indicators;

  /// How tall the frame is, as a width-to-height ratio.
  ///
  /// A parameter the React build has no need of: a browser's page view is as
  /// tall as whatever is in it, and a [PageView] has to be given a height — it
  /// lays every page out at the viewport's size rather than measuring them.
  /// Left out, the carousel takes whatever height the layout around it hands
  /// down, which is what a caller who has already sized the box wants.
  final double? aspectRatio;

  /// What the frame is made of. Never dyed — a carousel holds other people's
  /// pictures. [PlassVariant.ghost] has no frame at all.
  final PlassVariant variant;

  /// The frame's radius, and the size of the arrows and the dots.
  final PlassSize? size;

  /// Semantic colour role. It reaches the arrows and the current dot.
  final PlassColor? color;

  /// How tightly the arrows pack.
  final PlassDensity? density;

  /// Drop shadow depth of the frame, `0`–`3`.
  final PlassElevation elevation;

  /// The carousel's name. Never drawn.
  final String? label;

  /// The arrows' names. Never drawn.
  final String? previousLabel;

  /// See [previousLabel].
  final String? nextLabel;

  /// Names one slide, and the dot that goes to it.
  ///
  /// Defaults to `Slide 1 of 3`.
  final String Function(int index, int count)? slideLabel;

  @override
  State<PlCarousel> createState() => _PlCarouselState();
}

class _PlCarouselState extends State<PlCarousel> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

  late final PageController _pages = PageController(initialPage: _index);
  Timer? _timer;

  /// Whether the pointer is over the frame. A carousel that kept advancing
  /// under the pointer would be moving what somebody is reading.
  bool _paused = false;

  int get _count => widget.children.length;

  int get _index => _count == 0 ? 0 : widget.value.clamp(0, _count - 1);

  String _name(int index) => widget.slideLabel?.call(index, _count) ?? 'Slide $index of $_count';

  @override
  void didUpdateWidget(PlCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_pages.hasClients && _pages.page?.round() != _index) {
      // `animateToPage` and not `jumpToPage`: the travel is what says the slides
      // are a strip rather than a stack of pictures being swapped.
      _pages.animateToPage(
        _index,
        duration: _travel == Duration.zero ? const Duration(milliseconds: 1) : _travel,
        curve: PlassTokens.ease,
      );
    }

    _restart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pages.dispose();
    super.dispose();
  }

  /// A reader who has asked for less motion gets the cut rather than the travel.
  Duration get _travel => (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
      ? Duration.zero
      : PlassTokens.durationSlow;

  bool get _reduceMotion => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  void _restart() {
    _timer?.cancel();
    _timer = null;

    // Every one of these is a way an auto-playing carousel goes wrong: it moves
    // under the pointer, it moves for a reader who asked for stillness, or it
    // moves with nothing to report the move to.
    if (!widget.autoPlay || _paused || _reduceMotion || _count < 2 || widget.onChanged == null) {
      return;
    }

    _timer = Timer.periodic(widget.interval, (Timer _) => _go(_index + 1));
  }

  void _pause({required bool paused}) {
    if (_paused == paused) {
      return;
    }

    _paused = paused;
    _restart();
  }

  void _go(int next) {
    if (_count == 0) {
      return;
    }

    final wrapped = widget.loop ? ((next % _count) + _count) % _count : next.clamp(0, _count - 1);

    if (wrapped != _index) {
      widget.onChanged?.call(wrapped);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(_color);
    final radius = BorderRadius.circular(PlassTokens.radius[_size]!);
    final dot = _dot[_size]!;

    Widget strip = PageView.builder(
      controller: _pages,
      itemCount: _count,
      // Reported rather than acted on, like every other control in the package:
      // a swipe says where the reader went, and the value comes back down.
      onPageChanged: (int page) => widget.onChanged?.call(page),
      itemBuilder: (BuildContext context, int index) {
        return Semantics(container: true, label: _name(index + 1), child: widget.children[index]);
      },
    );

    if (widget.aspectRatio != null) {
      strip = AspectRatio(aspectRatio: widget.aspectRatio!, child: strip);
    }

    Widget frame = PlassSurfaceBox(
      surface: sheetSurface(tokens, variant: widget.variant, elevation: widget.elevation),
      borderRadius: radius,
      duration: PlassTokens.durationSlow,
      child: ClipRRect(borderRadius: radius, child: strip),
    );

    if (widget.arrows && _count > 1) {
      frame = Stack(
        children: <Widget>[
          frame,
          Positioned.directional(
            textDirection: Directionality.of(context),
            start: _arrowInset[_size]!,
            top: 0,
            bottom: 0,
            child: Align(child: _arrow(context, forward: false)),
          ),
          Positioned.directional(
            textDirection: Directionality.of(context),
            end: _arrowInset[_size]!,
            top: 0,
            bottom: 0,
            child: Align(child: _arrow(context, forward: true)),
          ),
        ],
      );
    }

    frame = MouseRegion(
      onEnter: (_) => _pause(paused: true),
      onExit: (_) => _pause(paused: false),
      child: frame,
    );

    return Semantics(
      container: true,
      label: widget.label ?? PlassTheme.labelsOf(context).carousel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.aspectRatio == null) Expanded(child: frame) else frame,
          if (widget.indicators && _count > 1)
            Padding(
              padding: const EdgeInsets.only(top: _dotRowGap),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: dot.gap,
                children: <Widget>[
                  for (var index = 0; index < _count; index += 1)
                    _Dot(
                      current: index == _index,
                      label: _name(index + 1),
                      rest: dot.rest,
                      grown: dot.current,
                      height: dot.height,
                      accent: family.accent,
                      quiet: tokens.border,
                      duration: _travel,
                      onPressed: widget.onChanged == null ? null : () => _go(index),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _arrow(BuildContext context, {required bool forward}) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final atEnd = forward ? _index >= _count - 1 : _index <= 0;

    return PlIconButton(
      // Drawn pointing down and turned, which is the one allowance the
      // no-transform rule makes — and turned the other way under RTL, where
      // "previous" is on the other side of the frame.
      icon: PlassGlyph(
        PlassGlyphShape.chevron,
        quarterTurns: forward ? (rtl ? 1 : -1) : (rtl ? -1 : 1),
      ),
      label: forward
          ? widget.nextLabel ?? PlassTheme.labelsOf(context).carouselNext
          : widget.previousLabel ?? PlassTheme.labelsOf(context).carouselPrevious,
      variant: PlassVariant.glass,
      size: _size,
      color: _color,
      elevation: 1,
      disabled: widget.onChanged == null || (!widget.loop && atEnd),
      onPressed: () => _go(forward ? _index + 1 : _index - 1),
    );
  }
}

/// One position dot.
///
/// A real button named after the slide it goes to, so the row is a way to
/// navigate rather than a read-out.
class _Dot extends StatelessWidget {
  const _Dot({
    required this.current,
    required this.label,
    required this.rest,
    required this.grown,
    required this.height,
    required this.accent,
    required this.quiet,
    required this.duration,
    required this.onPressed,
  });

  final bool current;
  final String label;
  final double rest;
  final double grown;
  final double height;
  final Color accent;
  final Color quiet;
  final Duration duration;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: current,
      label: label,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: MouseRegion(
            cursor: onPressed == null ? MouseCursor.defer : SystemMouseCursors.click,
            // The row's height never changes and the dots either side of the
            // current one do not move: only the width and the colour travel.
            child: AnimatedContainer(
              duration: duration,
              curve: PlassTokens.ease,
              width: current ? grown : rest,
              height: height,
              decoration: BoxDecoration(
                color: current ? accent : quiet,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
