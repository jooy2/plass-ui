/// A bounded box that scrolls, with the library's own scrollbar in it.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// Which axes may scroll.
///
/// [PlassOrientation] plus a third value rather than the shared enum widened,
/// because "both" is meaningless everywhere else it is used — a divider, a
/// button group and a slider each run one way — and widening it there to say it
/// here would be a third value nobody can answer.
enum PlScrollAreaAxis {
  /// Down the side. The default.
  vertical,

  /// Along the bottom.
  horizontal,

  /// Both, with a lane on each edge.
  both,
}

/// When the scrollbars are drawn.
enum PlScrollbars {
  /// While the pointer is over the box or the content is moving, and never
  /// otherwise. What a reader is used to on a Mac.
  auto,

  /// Kept at full strength.
  always,
}

/// How thick a thumb is. Its own ladder rather than a fraction of the control
/// heights: a scrollbar is furniture beside the content, not a control that has
/// to line up with a field in the same row.
const Map<PlassSize, double> _thumbThickness = <PlassSize, double>{
  PlassSize.xs: 4,
  PlassSize.sm: 6,
  PlassSize.md: 8,
  PlassSize.lg: 10,
  PlassSize.xl: 12,
};

/// The inset that turns a lane into a thumb: two logical pixels either side, at
/// every step, the same as the React build's.
const double _laneInset = 2;

/// A bounded box that scrolls, with the library's own scrollbar in it.
///
/// ```dart
/// PlScrollArea(
///   height: 220,
///   label: 'Release notes',
///   child: Column(children: notes),
/// )
/// ```
///
/// The reason to reach for it over a bare [SingleChildScrollView] is the
/// **bar**. A platform scrollbar is either an overlay that vanishes the moment
/// the content stops moving or a strip of permanent grey furniture, and neither
/// belongs beside a translucent sheet — and the framework's own [Scrollbar]
/// lives in `material.dart`, which this package does not import. This one is
/// the library's material: the thumb is [PlassTokens.track], the same neutral
/// ink a `PlSlider`'s rail and a progress groove are cut in.
///
/// It is **not** a `PlScrollZone`, which is the other answer to the same fact.
/// A scroll zone is a strip that runs off the end of its box: it takes the
/// scrollbar away, fades the end that still has something behind it and adds a
/// pair of buttons. That is right for a row of tabs or chips. This is right for
/// a panel of content, where the bar is the honest signal and where a reader
/// wants to know **how far through** they are, which a fade cannot say.
///
/// There is no fade here for that reason: two signals for one fact, one of them
/// measured and one of them not, is one more than the box needs.
class PlScrollArea extends StatefulWidget {
  /// Creates a scroll area. Bound it with [height] or [maxHeight] — a vertical
  /// one with no bound has nothing for its content to overflow.
  const PlScrollArea({
    required this.child,
    this.orientation = PlScrollAreaAxis.vertical,
    this.height,
    this.maxHeight,
    this.width,
    this.maxWidth,
    this.scrollbars = PlScrollbars.auto,
    this.label,
    this.size,
    super.key,
  });

  /// What scrolls.
  final Widget child;

  /// Which axes may scroll.
  final PlScrollAreaAxis orientation;

  /// A fixed height.
  ///
  /// **A vertical scroll area has to be bounded by something**, or there is
  /// nothing for the content to overflow and the box simply grows to fit. This
  /// is that something, and it is a parameter rather than an enclosing
  /// [SizedBox] because it is the one measurement without which the widget does
  /// nothing at all.
  final double? height;

  /// The height it stops growing at, for a box that should shrink to short
  /// content.
  final double? maxHeight;

  /// The same two for a horizontal area.
  final double? width;

  /// The width it stops growing at.
  final double? maxWidth;

  /// When the scrollbars are drawn.
  final PlScrollbars scrollbars;

  /// A name for the region, read out when the box takes the focus.
  ///
  /// Worth giving, and the reason is not obvious: a scrollable box is reachable
  /// by the keyboard even when nothing inside it is, because somebody has to be
  /// able to scroll it. A landing point with no name is announced as nothing at
  /// all.
  final String? label;

  /// Thickness of the scrollbars and the corner the box is cut to.
  final PlassSize? size;

  @override
  State<PlScrollArea> createState() => _PlScrollAreaState();
}

class _PlScrollAreaState extends State<PlScrollArea> {
  final ScrollController _vertical = ScrollController();
  final ScrollController _horizontal = ScrollController();

  /// The pointer is over the box. `auto` shows the bars while it is, which is
  /// what the React build's `data-hovering` does and what a reader deciding
  /// whether there is more below is actually asking.
  bool _hovering = false;

  bool get _hasVertical => widget.orientation != PlScrollAreaAxis.horizontal;
  bool get _hasHorizontal => widget.orientation != PlScrollAreaAxis.vertical;

  @override
  void dispose() {
    _vertical.dispose();
    _horizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final tokens = PlassTheme.of(context);

    final thickness = _thumbThickness[size]!;
    final visible = widget.scrollbars == PlScrollbars.always || _hovering;

    Widget content = widget.child;

    if (_hasHorizontal) {
      content = RawScrollbar(
        controller: _horizontal,
        thumbColor: tokens.track,
        thickness: thickness,
        radius: Radius.circular(thickness),
        crossAxisMargin: _laneInset,
        mainAxisMargin: _laneInset,
        thumbVisibility: visible,
        // Only the inner scrollable's notifications: with two axes the outer
        // one is depth 1 from here, and a bar that answered both would jump
        // whenever the other direction moved.
        // Only its own scrollable's notifications. The horizontal view is the
        // inner one, so it is always depth 0 from where this bar sits.
        notificationPredicate: (ScrollNotification notification) => notification.depth == 0,
        child: SingleChildScrollView(
          controller: _horizontal,
          scrollDirection: Axis.horizontal,
          child: content,
        ),
      );
    }

    if (_hasVertical) {
      content = RawScrollbar(
        controller: _vertical,
        thumbColor: tokens.track,
        thickness: thickness,
        radius: Radius.circular(thickness),
        crossAxisMargin: _laneInset,
        mainAxisMargin: _laneInset,
        thumbVisibility: visible,
        notificationPredicate: (ScrollNotification notification) =>
            notification.depth == (_hasHorizontal ? 1 : 0),
        child: SingleChildScrollView(controller: _vertical, child: content),
      );
    }

    final Widget box = ClipRRect(
      borderRadius: BorderRadius.circular(PlassTokens.radius[size]!),
      child: content,
    );

    return MouseRegion(
      onEnter: (_) => _setHovering(true),
      onExit: (_) => _setHovering(false),
      child: Semantics(
        label: widget.label,
        container: widget.label != null,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: widget.maxHeight ?? double.infinity,
            maxWidth: widget.maxWidth ?? double.infinity,
          ),
          child: SizedBox(height: widget.height, width: widget.width, child: box),
        ),
      ),
    );
  }

  void _setHovering(bool hovering) {
    if (widget.scrollbars == PlScrollbars.always || _hovering == hovering) {
      return;
    }

    setState(() => _hovering = hovering);
  }
}
