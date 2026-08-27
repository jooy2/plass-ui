/// A strip of anything, laid out in one direction and scrolled in it.
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/icon_button/pl_icon_button.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// When the scroll buttons are drawn.
enum PlScrollZoneButtons {
  /// Only the one that has somewhere to go, and neither of them while
  /// everything fits.
  ///
  /// The default: a control that cannot do anything is worse than no control,
  /// and a row that does not overflow is not a scroller.
  auto,

  /// Both, from the first frame, with the one that has nowhere to go disabled
  /// rather than gone. What a strip whose content arrives later wants, since
  /// the buttons do not appear under the pointer half a second in.
  always,

  /// None at all. Dragging, the wheel and the arrow keys are still there; this
  /// is the strip that scrolls the way a phone scrolls.
  none,
}

/// What pressing a scroll button does.
enum PlScrollZoneMode {
  /// Moves to the next child along, `step` of them at a time. The default, and
  /// the only one that lands on something rather than between two things.
  item,

  /// Moves by everything currently on screen, the way Page Down does.
  page,

  /// Scrolls for as long as the button is held, at `speed` pixels a second. A
  /// press too short to be a hold moves one item instead, so the button is
  /// never dead to a quick tap.
  hold,
}

/// Where the scroll buttons sit, which is also where the strip ends.
enum PlScrollZoneButtonPlacement {
  /// Over the ends of the strip, which keeps every pixel of the box for content
  /// and lets an item pass under a button.
  overlay,

  /// Beside the strip, in the layout. The scroller stops where the button
  /// starts, so an item is *cut off* at the button's edge rather than sliding
  /// beneath it — nothing is ever half-hidden behind a control, and the button
  /// is legible over the page rather than over whatever it landed on.
  ///
  /// The lane an inline button sits in is kept even while that button has
  /// nowhere to go, or the strip would resize under the pointer every time it
  /// reached an end.
  inline,
}

/// How far the buttons sit in from the edge they are held against.
const Map<PlassSize, double> _buttonInset = <PlassSize, double>{
  PlassSize.xs: 4,
  PlassSize.sm: 6,
  PlassSize.md: 8,
  PlassSize.lg: 12,
  PlassSize.xl: 16,
};

/// And the air between an inline button and the strip it flanks.
const Map<PlassSize, double> _buttonGap = <PlassSize, double>{
  PlassSize.xs: 4,
  PlassSize.sm: 6,
  PlassSize.md: 8,
  PlassSize.lg: 12,
  PlassSize.xl: 16,
};

/// Under this, a press in [PlScrollZoneMode.hold] was a tap and moves one item.
const Duration _tap = Duration(milliseconds: 140);

/// How close to an end counts as being at it.
const double _epsilon = 1;

/// The scroll behaviour a zone that answers a mouse drag runs under.
///
/// A finger already scrolls and a trackpad already scrolls; what this adds is
/// the mouse, which Flutter deliberately leaves out — dragging a scroll view
/// with a mouse is unusual enough that it has to be asked for, and a shelf is
/// exactly the place that asks.
class _DragBehavior extends ScrollBehavior {
  const _DragBehavior({required this.drag});

  final bool drag;

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
    if (drag) PointerDeviceKind.mouse,
  };

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    // `RawScrollbar` and not the Material one, for the reason the whole package
    // has no Material in it. The zone draws its own below when it is asked for
    // one; this is the hook that stops the framework drawing a second.
    return child;
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    // A glow at the end of a shelf is Android's own ink, and this package is not
    // Material. The strip simply stops.
    return child;
  }
}

/// A strip of anything, laid out in one direction and scrolled in it.
///
/// ```dart
/// PlScrollZone(
///   label: 'Continue watching',
///   spacing: 12,
///   children: <Widget>[for (final Show show in shows) ShowCard(show)],
/// )
/// ```
///
/// The mechanism is an **ordinary scroll view**, and everything the widget
/// offers is a way of driving one. Swiping, a trackpad, the wheel and the
/// scrollbar are Flutter's own and are never intercepted; what is added on top
/// is a pair of buttons for the pointer that has neither a wheel nor a finger,
/// and a mouse drag for the strip that reads as something to pull rather than
/// something to page.
///
/// Nothing is transformed. A translated track would have to argue for an
/// exception to the house rule; a scroll offset does not, and it is also what
/// makes the strip run the other way under RTL without being told.
///
/// It draws **no sheet of its own**, and there is no `elevation` to give it one.
/// A shelf is a way of laying children out, and the children arrive with their
/// own surfaces. [variant], [size] and [color] reach the two buttons, which are
/// real [PlIconButton]s.
///
/// [lines] is what separates this from a `PlCarousel`: a carousel is one thing
/// at a time and knows which one, a scroll zone is a shelf that happens to be
/// longer than the room it is in.
class PlScrollZone extends StatefulWidget {
  /// Creates a scroll zone.
  const PlScrollZone({
    required this.children,
    this.orientation = PlassOrientation.horizontal,
    this.lines = 1,
    this.spacing = 8,
    this.buttons = PlScrollZoneButtons.auto,
    this.buttonPlacement = PlScrollZoneButtonPlacement.overlay,
    this.mode = PlScrollZoneMode.item,
    this.step = 1,
    this.speed = 900,
    this.snap = false,
    this.drag = true,
    this.scrollbar = false,
    this.controller,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.label,
    this.previousLabel = 'Previous',
    this.nextLabel = 'Next',
    super.key,
  }) : assert(lines >= 1, 'lines must be at least 1'),
       assert(step >= 1, 'step must be at least 1');

  /// What is being laid out. Every child is one item of the strip.
  final List<Widget> children;

  /// Which way the children run, and therefore which way the zone scrolls.
  final PlassOrientation orientation;

  /// How many rows a horizontal zone lays its children out in before it starts
  /// a new column — and how many columns a vertical one uses.
  ///
  /// `2` is the shelf that holds twice as much in the same width.
  final int lines;

  /// The gap between children, in logical pixels.
  ///
  /// A length rather than the React build's step on the spacing scale: Dart has
  /// no `rem`, and every other measurement in this package is already the same
  /// number in logical pixels that the other one writes in `rem`.
  final double spacing;

  /// When the scroll buttons are drawn.
  final PlScrollZoneButtons buttons;

  /// Whether the buttons sit over the strip or beside it.
  final PlScrollZoneButtonPlacement buttonPlacement;

  /// What pressing one does.
  final PlScrollZoneMode mode;

  /// How many children one press moves, in [PlScrollZoneMode.item].
  final int step;

  /// How fast a held button scrolls, in pixels a second.
  final double speed;

  /// Brings the nearest child to the leading edge when the scrolling stops —
  /// dragging and the wheel included, not only the buttons.
  final bool snap;

  /// Lets a mouse drag the strip along, the way a finger already does.
  final bool drag;

  /// Draws a scrollbar over the strip.
  final bool scrollbar;

  /// Drive the scroll from outside. Left out, the zone owns one of its own.
  final ScrollController? controller;

  /// What the scroll buttons are made of. The zone itself draws no sheet.
  final PlassVariant variant;

  /// The size of the buttons and how far in from the edge they sit.
  final PlassSize size;

  /// Semantic colour role, carried by the buttons.
  final PlassColor color;

  /// What the scrollable region is called — "Categories", "Recent files".
  final String? label;

  /// What the buttons are called. Never drawn — a disc with a chevron in it has
  /// no accessible name of its own, which is the defect [PlIconButton]'s
  /// `label` exists to make impossible.
  final String previousLabel;

  /// See [previousLabel].
  final String nextLabel;

  @override
  State<PlScrollZone> createState() => _PlScrollZoneState();
}

class _PlScrollZoneState extends State<PlScrollZone> with SingleTickerProviderStateMixin {
  ScrollController? _own;
  Ticker? _hold;

  /// One key per *group* — a column of a horizontal strip, a row of a vertical
  /// one — so a press moves one whole group rather than a fraction of one.
  ///
  /// Measured rather than assumed: the children of a scroll zone are whatever
  /// the caller put there, so no two of them are necessarily the same size.
  final List<GlobalKey> _groupKeys = <GlobalKey>[];
  final GlobalKey _viewportKey = GlobalKey();

  bool _back = false;
  bool _forward = false;

  /// Whether the last pointer press on a button was long enough to have been a
  /// hold, so the tap that follows it can be swallowed.
  bool _wasHeld = false;

  ScrollController get _scroll => widget.controller ?? (_own ??= ScrollController());

  bool get _horizontal => widget.orientation == PlassOrientation.horizontal;

  /// The children, chunked into the groups [lines] asks for.
  List<List<Widget>> get _groups {
    final groups = <List<Widget>>[];

    for (var index = 0; index < widget.children.length; index += widget.lines) {
      groups.add(
        widget.children.sublist(index, (index + widget.lines).clamp(0, widget.children.length)),
      );
    }

    return groups;
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_measure);
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _measure());
  }

  @override
  void didUpdateWidget(PlScrollZone oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_measure);
      _own?.removeListener(_measure);
      _scroll.addListener(_measure);
    }

    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _measure());
  }

  @override
  void dispose() {
    _hold?.dispose();
    _scroll.removeListener(_measure);
    _own?.dispose();
    super.dispose();
  }

  /// Whether there is anything left in each direction.
  void _measure() {
    if (!mounted || !_scroll.hasClients) {
      return;
    }

    final position = _scroll.position;
    final back = position.pixels > position.minScrollExtent + _epsilon;
    final forward = position.pixels < position.maxScrollExtent - _epsilon;

    if (back != _back || forward != _forward) {
      setState(() {
        _back = back;
        _forward = forward;
      });
    }
  }

  /// A reader who has asked for less motion gets the cut rather than the travel.
  Duration get _travel => (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
      ? Duration.zero
      : PlassTokens.duration;

  void _to(double offset) {
    if (!_scroll.hasClients) {
      return;
    }

    final position = _scroll.position;
    final target = offset.clamp(position.minScrollExtent, position.maxScrollExtent);

    if (_travel == Duration.zero) {
      _scroll.jumpTo(target);

      return;
    }

    _scroll.animateTo(target, duration: _travel, curve: PlassTokens.ease);
  }

  /// Where each group starts, in the scroll view's own coordinates.
  List<double> _groupStarts() {
    final viewport = _viewportKey.currentContext?.findRenderObject() as RenderBox?;

    if (viewport == null || !viewport.hasSize || !_scroll.hasClients) {
      return <double>[];
    }

    final starts = <double>[];

    for (final key in _groupKeys) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;

      if (box == null || !box.hasSize) {
        continue;
      }

      final local = box.localToGlobal(Offset.zero, ancestor: viewport);

      // Back to an absolute scroll offset: where the group sits in the viewport
      // right now, plus how far the viewport has already been scrolled.
      starts.add((_horizontal ? local.dx : local.dy) + _scroll.position.pixels);
    }

    starts.sort();

    return starts;
  }

  /// One press, in whichever unit [PlScrollZone.mode] is counted in.
  void _advance(bool forward, {PlScrollZoneMode? unit}) {
    if (!_scroll.hasClients) {
      return;
    }

    final position = _scroll.position;
    final extent = position.viewportDimension;

    if ((unit ?? widget.mode) == PlScrollZoneMode.page) {
      _to(position.pixels + (forward ? extent : -extent));

      return;
    }

    final starts = _groupStarts();
    final ahead = starts.where((double start) => start > position.pixels + _epsilon).toList();
    final behind = starts.where((double start) => start < position.pixels - _epsilon).toList();
    final target = forward
        ? (ahead.length >= widget.step ? ahead[widget.step - 1] : null)
        : (behind.length >= widget.step ? behind[behind.length - widget.step] : null);

    if (target == null) {
      // Nothing that far along: go as far as there is. Without this, the last
      // half-item of a strip would be unreachable by button.
      _to(position.pixels + (forward ? extent : -extent));

      return;
    }

    _to(target);
  }

  /*
   * `hold` — a ticker rather than a timer, so the strip moves at `speed` pixels
   * a second whatever the display is doing.
   */

  void _beginHold(bool forward) {
    _stopHold();

    var previous = Duration.zero;

    _hold = createTicker((Duration elapsed) {
      final delta = elapsed - previous;

      previous = elapsed;

      if (!_scroll.hasClients) {
        return;
      }

      final position = _scroll.position;
      final by = widget.speed * delta.inMicroseconds / Duration.microsecondsPerSecond;

      _scroll.jumpTo(
        (position.pixels + (forward ? by : -by)).clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        ),
      );
    })..start();
  }

  void _stopHold() {
    _hold?.dispose();
    _hold = null;
  }

  /// Snaps to the nearest group when the scrolling stops, however it stopped.
  bool _onScrollEnd(ScrollEndNotification notification) {
    if (!widget.snap || !_scroll.hasClients) {
      return false;
    }

    final starts = _groupStarts();

    if (starts.isEmpty) {
      return false;
    }

    final pixels = _scroll.position.pixels;
    var nearest = starts.first;

    for (final start in starts) {
      if ((start - pixels).abs() < (nearest - pixels).abs()) {
        nearest = start;
      }
    }

    if ((nearest - pixels).abs() > _epsilon) {
      WidgetsBinding.instance.addPostFrameCallback((Duration _) => _to(nearest));
    }

    return false;
  }

  Widget _button(BuildContext context, {required bool forward}) {
    final available = forward ? _forward : _back;
    final spare = widget.buttons == PlScrollZoneButtons.auto && !available;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    // Drawn pointing down and turned, which is the one allowance the
    // no-transform rule makes — and turned the other way under RTL, where
    // "forward" is on the other side of the strip.
    final turns = _horizontal ? (forward ? (rtl ? 1 : -1) : (rtl ? -1 : 1)) : (forward ? 0 : 2);

    Widget button = PlIconButton(
      icon: PlassGlyph(PlassGlyphShape.chevron, quarterTurns: turns),
      label: forward ? widget.nextLabel : widget.previousLabel,
      variant: widget.variant,
      size: widget.size,
      color: widget.color,
      elevation: 1,
      disabled: !available,
      onPressed: () {
        // A hold has already moved the strip; the tap that Flutter reports on
        // release would move it one more item on top of that.
        if (_wasHeld) {
          _wasHeld = false;

          return;
        }

        _advance(forward);
      },
    );

    if (widget.mode == PlScrollZoneMode.hold) {
      // A `Listener` above the button rather than a gesture inside it: the
      // button owns the tap, and this only has to know when the pointer went
      // down and when it came back up.
      button = Listener(
        onPointerDown: (PointerDownEvent event) {
          if (!available) {
            return;
          }

          _wasHeld = false;
          _beginHold(forward);

          Future<void>.delayed(_tap, () {
            if (_hold != null) {
              _wasHeld = true;
            }
          });
        },
        onPointerUp: (PointerUpEvent _) => _stopHold(),
        onPointerCancel: (PointerCancelEvent _) => _stopHold(),
        child: button,
      );
    }

    if (widget.buttonPlacement == PlScrollZoneButtonPlacement.overlay) {
      return button;
    }

    // An inline button leaves its lane behind when it has nowhere to go, because
    // a lane that came and went would resize the strip under the pointer that
    // had just reached the end of it. `ExcludeFocus` and `ExcludeSemantics` are
    // what keep it out of the tab order and off the accessibility tree while it
    // is invisible.
    if (spare) {
      return ExcludeSemantics(
        child: ExcludeFocus(
          child: Opacity(opacity: 0, child: IgnorePointer(child: button)),
        ),
      );
    }

    return button;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final groups = _groups;

    while (_groupKeys.length < groups.length) {
      _groupKeys.add(GlobalKey());
    }

    if (_groupKeys.length > groups.length) {
      _groupKeys.removeRange(groups.length, _groupKeys.length);
    }

    // A group is a column of a horizontal strip and a row of a vertical one,
    // which is what `grid-auto-flow: column` and `grid-template-rows` say in the
    // other package. The cross axis of a vertical zone divides evenly, exactly
    // as `minmax(0, 1fr)` does there.
    final track = <Widget>[
      for (var index = 0; index < groups.length; index += 1)
        KeyedSubtree(
          key: _groupKeys[index],
          child: _horizontal
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: widget.spacing,
                  children: groups[index],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: widget.spacing,
                  children: <Widget>[
                    for (final child in groups[index]) Expanded(child: child),
                    // The last row of a vertical strip keeps the columns the
                    // rows above it have, or a short final row stretches.
                    for (var gap = groups[index].length; gap < widget.lines; gap += 1)
                      const Expanded(child: SizedBox.shrink()),
                  ],
                ),
        ),
    ];

    Widget strip = SingleChildScrollView(
      key: _viewportKey,
      controller: _scroll,
      scrollDirection: _horizontal ? Axis.horizontal : Axis.vertical,
      padding: EdgeInsets.zero,
      child: _horizontal
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: widget.spacing,
              children: track,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              spacing: widget.spacing,
              children: track,
            ),
    );

    if (widget.scrollbar) {
      strip = RawScrollbar(
        controller: _scroll,
        thumbColor: tokens.border,
        radius: const Radius.circular(4),
        thickness: 4,
        child: strip,
      );
    }

    strip = ScrollConfiguration(
      behavior: _DragBehavior(drag: widget.drag),
      child: NotificationListener<ScrollEndNotification>(
        onNotification: _onScrollEnd,
        child: strip,
      ),
    );

    if (widget.label != null) {
      strip = Semantics(container: true, label: widget.label, child: strip);
    }

    final drawn =
        widget.buttons != PlScrollZoneButtons.none &&
        (widget.buttons == PlScrollZoneButtons.always || _back || _forward);

    if (!drawn) {
      return strip;
    }

    if (widget.buttonPlacement == PlScrollZoneButtonPlacement.inline) {
      final gap = _buttonGap[widget.size]!;

      return _horizontal
          ? Row(
              spacing: gap,
              children: <Widget>[
                _button(context, forward: false),
                Expanded(child: strip),
                _button(context, forward: true),
              ],
            )
          : Column(
              spacing: gap,
              children: <Widget>[
                _button(context, forward: false),
                Expanded(child: strip),
                _button(context, forward: true),
              ],
            );
    }

    final inset = _buttonInset[widget.size]!;

    return Stack(
      children: <Widget>[
        strip,
        // An overlay button with nowhere to go is not drawn at all — there is no
        // lane to keep here, because the strip already has every pixel of the
        // box.
        if (widget.buttons == PlScrollZoneButtons.always || _back)
          Positioned.directional(
            textDirection: Directionality.of(context),
            start: _horizontal ? inset : 0,
            end: _horizontal ? null : 0,
            top: _horizontal ? 0 : inset,
            bottom: 0,
            child: Align(child: _button(context, forward: false)),
          ),
        if (widget.buttons == PlScrollZoneButtons.always || _forward)
          Positioned.directional(
            textDirection: Directionality.of(context),
            start: _horizontal ? null : 0,
            end: _horizontal ? inset : 0,
            top: _horizontal ? 0 : null,
            bottom: _horizontal ? 0 : inset,
            child: Align(child: _button(context, forward: true)),
          ),
      ],
    );
  }
}
