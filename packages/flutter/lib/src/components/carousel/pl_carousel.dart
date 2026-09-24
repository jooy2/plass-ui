/// A strip of slides, one of which is in view.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/icon_button/pl_icon_button.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
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
const Map<PlassSize, ({double rest, double current, double height})> _dot =
    <PlassSize, ({double rest, double current, double height})>{
      PlassSize.xs: (rest: 4, current: 12, height: 4),
      PlassSize.sm: (rest: 4, current: 14, height: 4),
      PlassSize.md: (rest: 6, current: 16, height: 6),
      PlassSize.lg: (rest: 6, current: 20, height: 6),
      PlassSize.xl: (rest: 8, current: 24, height: 8),
    };

/// A dot's press target, on each side: what WCAG 2.5.8 asks for. The targets
/// sit edge to edge with no gap, so none of them overlaps another, and the dot
/// is drawn in the middle of its own.
const double _dotTarget = 24;

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
    this.playLabel,
    this.stopLabel,
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

  /// Advances on its own, with a button over the frame that stops it and starts
  /// it again.
  ///
  /// Off by default and deliberately so: a carousel that moves while it is being
  /// read is the most complained-about pattern there is. It pauses while the
  /// pointer is over it. It **stops** once the focus comes into it or an arrow
  /// or a dot is pressed, and stays stopped until the button starts it again.
  /// For a reader who has asked for reduced motion it starts stopped. And it
  /// needs [onChanged] — a frozen carousel has nothing to advance, and no
  /// button.
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

  /// What the [autoPlay] button says while the carousel is stopped. Never
  /// drawn.
  ///
  /// Left out, it is the theme's [PlassLabels.carouselPlay].
  final String? playLabel;

  /// What it says while the carousel is playing. Left out, it is the theme's
  /// [PlassLabels.carouselStop].
  final String? stopLabel;

  /// Names one slide, and the dot that goes to it.
  ///
  /// Left out, it is the theme's [PlassLabels.carouselSlide], `Slide 1 of 3` in
  /// English.
  final String Function(int index, int count)? slideLabel;

  @override
  State<PlCarousel> createState() => _PlCarouselState();
}

class _PlCarouselState extends State<PlCarousel> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

  late final PageController _pages = PageController(initialPage: _index);
  Timer? _timer;

  // Two different things hold the strip still, and they are kept apart on
  // purpose. The pointer over the frame is a *pause*: it lasts exactly as long
  // as the pointer does. The focus coming in is a *stop*, and so is a press on
  // an arrow or a dot: a reader who has reached a slide or steered to one is
  // reading it, and the strip stays where it is until the button starts it
  // again — the pointer leaving, or the focus, does not.

  /// Whether the pointer is over the frame. A carousel that kept advancing
  /// under the pointer would be moving what somebody is reading.
  bool _hovered = false;

  /// The reader's own answer to "should this be moving?", `true` for stopped.
  ///
  /// `null` until they have given one, and until then it is the platform's
  /// answer: a reader who asked for reduced motion starts stopped, and the
  /// button is how they start it anyway.
  bool? _choice;

  bool get _stopped => _choice ?? _reduceMotion;

  /// Holds the focus of everything in the carousel, so the focus coming in can
  /// be seen wherever it lands.
  final FocusNode _within = FocusNode(
    debugLabel: 'PlCarousel',
    canRequestFocus: false,
    skipTraversal: true,
  );

  /// The button's own, which is the one place the focus can land without
  /// stopping anything: a keyboard reader reaches it first and stops the strip
  /// from there.
  final FocusNode _toggleFocus = FocusNode(debugLabel: 'PlCarousel autoPlay');

  /// Raised when the button starts the strip. The reader has just answered the
  /// stop, and moving on to an arrow, a dot or a slide does not stop what they
  /// started, whether the focus goes there or a press does.
  ///
  /// Raised whether or not the focus is inside, because a press on the button
  /// is, and in a browser the click would have brought the focus with it.
  /// Lowered whenever the focus comes in or goes out: a start made with the
  /// focus inside ends when it leaves, and one made with it elsewhere ends when
  /// it arrives, which in a browser it could only do after leaving.
  bool _resumedInside = false;

  @override
  void initState() {
    super.initState();
    _toggleFocus.addListener(_focusMoved);
  }

  int get _count => widget.children.length;

  int get _index => _count == 0 ? 0 : widget.value.clamp(0, _count - 1);

  String _name(int index) =>
      widget.slideLabel?.call(index, _count) ??
      PlassTheme.labelsOf(context).carouselSlide(index, _count);

  @override
  void didUpdateWidget(PlCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_pages.hasClients && _pages.page?.round() != _index) {
      // `animateToPage` and not `jumpToPage`: the travel is what says the slides
      // are a strip rather than a stack of pictures being swapped.
      _pages.animateToPage(
        _index,
        duration: _travel == Duration.zero ? const Duration(milliseconds: 1) : _travel,
        curve: PlassTheme.of(context).motionEase,
      );
    }

    // Only when something the timer depends on changed. A parent that rebuilds
    // every second would otherwise restart a five-second interval before it
    // ever fired, and the carousel would never advance.
    if (widget.autoPlay != oldWidget.autoPlay ||
        widget.interval != oldWidget.interval ||
        widget.value != oldWidget.value ||
        widget.children.length != oldWidget.children.length ||
        (widget.onChanged == null) != (oldWidget.onChanged == null)) {
      _restart();
    }
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
    _toggleFocus
      ..removeListener(_focusMoved)
      ..dispose();
    _within.dispose();
    super.dispose();
  }

  /// A reader who has asked for less motion gets the cut rather than the travel.
  Duration get _travel => (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
      ? Duration.zero
      : PlassTheme.of(context).motionDurationSlow;

  bool get _reduceMotion => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  void _restart() {
    _timer?.cancel();
    _timer = null;

    // Every one of these is a way an auto-playing carousel goes wrong: it moves
    // under the pointer, it moves once the reader has stopped it — or, before
    // they have said, for a reader who asked for stillness — or it moves with
    // nothing to report the move to.
    if (!widget.autoPlay || _hovered || _stopped || _count < 2 || widget.onChanged == null) {
      return;
    }

    _timer = Timer.periodic(widget.interval, (Timer _) => _go(_index + 1));
  }

  void _hover({required bool hovered}) {
    if (_hovered == hovered) {
      return;
    }

    _hovered = hovered;
    _restart();
  }

  /// Answers the focus arriving anywhere inside, or moving off the button.
  ///
  /// Those are the only two moves that matter, and they are the two a listener
  /// hears: the carousel's own node when the focus comes in or goes out, the
  /// button's when it leaves the button for something else inside.
  void _focusMoved() {
    if (!_within.hasFocus) {
      _resumedInside = false;

      return;
    }

    if (_toggleFocus.hasFocus) {
      return;
    }

    _hold();
  }

  /// Stops the strip because the reader has taken hold of it, unless the
  /// button has just started it.
  void _hold() {
    if (!widget.autoPlay || _resumedInside || _stopped) {
      return;
    }

    setState(() => _choice = true);
    _restart();
  }

  /// An arrow or a dot, pressed by a pointer, a key or a screen reader.
  ///
  /// The same stop as the focus coming in. In a browser the click is what
  /// brings the focus in, so the React build stops there without being told;
  /// a press here leaves the focus where it was, and has to say so itself.
  void _steer(int next) {
    _hold();
    _go(next);
  }

  void _toggle() {
    final stop = !_stopped;

    setState(() => _choice = stop);
    _resumedInside = !stop;
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
    final radius = BorderRadius.circular(tokens.radii[_size]!);
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
      duration: tokens.motionDurationSlow,
      child: ClipRRect(borderRadius: radius, child: strip),
    );

    final arrows = widget.arrows && _count > 1;
    // Only where it can do something: a frozen carousel never plays, and a
    // button saying "Stop slide show" over it would be describing nothing.
    final toggle = widget.autoPlay && _count > 1 && widget.onChanged != null;

    if (arrows || toggle) {
      frame = Stack(
        children: <Widget>[
          frame,
          if (arrows) ...<Widget>[
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
          // In the top corner the reading starts from, so it is the first thing
          // a keyboard reader reaches and can stop the strip before anything
          // else. Last in the stack only so it is painted over the arrows.
          if (toggle)
            Positioned.directional(
              textDirection: Directionality.of(context),
              start: _arrowInset[_size]!,
              top: _arrowInset[_size]!,
              child: _toggleButton(context),
            ),
        ],
      );
    }

    frame = MouseRegion(
      onEnter: (_) => _hover(hovered: true),
      onExit: (_) => _hover(hovered: false),
      child: frame,
    );

    return Focus(
      focusNode: _within,
      onFocusChange: (bool focused) {
        _resumedInside = false;
        _focusMoved();
      },
      child: Semantics(
        container: true,
        label: widget.label ?? PlassTheme.labelsOf(context).carousel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.aspectRatio == null) Expanded(child: frame) else frame,
            if (widget.indicators && _count > 1)
              // No gap and no padding: each dot is a press target of its own with
              // the dot drawn in its middle, so the targets sit edge to edge and
              // the dot lands about where the padding used to put it.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                      ring: family.ring,
                      duration: _travel,
                      onPressed: widget.onChanged == null ? null : () => _steer(index),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// A button whose name changes rather than a pressed toggle: "Stop slide show"
  /// says what pressing it does, where a pressed "Slide show" would make the
  /// reader work out which way round the state goes.
  Widget _toggleButton(BuildContext context) {
    final labels = PlassTheme.labelsOf(context);

    return PlIconButton(
      focusNode: _toggleFocus,
      icon: PlassGlyph(_stopped ? PlassGlyphShape.play : PlassGlyphShape.pause),
      label: _stopped
          ? widget.playLabel ?? labels.carouselPlay
          : widget.stopLabel ?? labels.carouselStop,
      variant: PlassVariant.glass,
      size: _size,
      color: _color,
      elevation: 1,
      onPressed: _toggle,
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
      onPressed: () => _steer(forward ? _index + 1 : _index - 1),
    );
  }
}

/// One position dot.
///
/// A real button named after the slide it goes to, so the row is a way to
/// navigate rather than a read-out: a stop of its own in the tab order, pressed
/// with <kbd>Enter</kbd> or <kbd>Space</kbd>, as a `<button>` is on the web.
/// Frozen with the rest of the carousel, it leaves the tab order as the arrows
/// do.
class _Dot extends StatelessWidget {
  const _Dot({
    required this.current,
    required this.label,
    required this.rest,
    required this.grown,
    required this.height,
    required this.accent,
    required this.quiet,
    required this.ring,
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
  final Color ring;
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
        child: PlassInteractive(
          onTap: onPressed,
          enabled: onPressed != null,
          interactive: onPressed != null,
          cursor: onPressed == null ? MouseCursor.defer : SystemMouseCursors.click,
          builder: (BuildContext context, PlassInteraction state) {
            // The ring goes round the whole press target rather than the dot,
            // and the painter stays in the tree when there is no ring to draw,
            // so the focus arriving does not build the dot again.
            return CustomPaint(
              foregroundPainter: state.focusVisible
                  ? PlassFocusRingPainter(
                      color: ring,
                      borderRadius: BorderRadius.circular(_dotTarget / 2),
                    )
                  : null,
              // The row's height never changes and the dots either side of the
              // current one do not move: only the width and the colour travel,
              // inside a target that is the same size for every dot.
              child: SizedBox(
                width: grown > _dotTarget ? grown : _dotTarget,
                height: _dotTarget,
                child: Center(
                  child: AnimatedContainer(
                    duration: duration,
                    curve: PlassTheme.of(context).motionEase,
                    width: current ? grown : rest,
                    height: height,
                    decoration: BoxDecoration(
                      color: current ? accent : quiet,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
