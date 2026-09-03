/// Things piled up, overlapping.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// Which way the pile grows.
enum PlStackDirection {
  /// Along the reader's inline axis.
  horizontal,

  /// Down the page.
  vertical,

  /// Along the inline axis, with a step down the page per item.
  ///
  /// A **fan** rather than a true 45°, and it cannot be anything else: the
  /// horizontal advance is `item width - overlap`, and a pile that takes
  /// arbitrary children does not know how wide they are. The vertical step is
  /// [PlStack.drop], stated separately.
  diagonal,
}

/// Which end of the list is on top.
enum PlStackFront {
  /// The first item paints over the rest. What a deck of cards is: the top card
  /// is the one you read first.
  first,

  /// The last item paints over the rest. What a row of faces wants — the newest
  /// arrival in front.
  last,
}

/// How far one item sits under the last, per rung.
///
/// Roughly a third of a control at every size: enough that the pile reads as a
/// pile, and not so much that what is behind is hidden by what is in front.
const Map<PlassSize, double> _overlap = <PlassSize, double>{
  PlassSize.xs: 8,
  PlassSize.sm: 10,
  PlassSize.md: 14,
  PlassSize.lg: 16,
  PlassSize.xl: 20,
};

/// How wide the hairline between two overlapping items is drawn.
const double _ringWidth = 2;

/// Things piled up, overlapping.
///
/// ```dart
/// PlStack(
///   max: 4,
///   total: 11,
///   ring: BorderRadius.circular(999),
///   overflow: (int hidden) => PlAvatar(initials: '+$hidden'),
///   children: <Widget>[
///     PlAvatar(name: 'Ada Lovelace'),
///     PlAvatar(name: 'Grace Hopper'),
///   ],
/// )
/// ```
///
/// A row of faces is one arrangement of this and not a widget of its own: a deck
/// of cards, a pile of documents, a fan of thumbnails and a stack of avatars
/// differ in what is in them, not in how they are laid out. So this takes
/// whatever it is given and never looks inside.
///
/// Which is also what it gives up. It cannot set an axis on its items the way a
/// `PlAvatarGroup` used to, because it does not know what they are — put a
/// [PlassTheme] around it for `size` and `color`, and write anything narrower on
/// the items themselves.
///
/// **The box measures exactly what it draws.** The overlap is real layout rather
/// than a [Transform]: a translated pile is laid out one item wide, paints
/// outside its own box, and everything after it is placed against a size the
/// reader never sees. Flutter has no negative margin — `EdgeInsets` asserts it
/// is non-negative, and `Flex.spacing` does too — so the pile is laid out by a
/// render object of its own, which is the only place child sizes are known.
class PlStack extends StatelessWidget {
  /// Creates a pile.
  const PlStack({
    required this.children,
    this.direction = const PlassResponsive<PlStackDirection>(PlStackDirection.horizontal),
    this.overlap,
    this.drop,
    this.size,
    this.max,
    this.total,
    this.overflow,
    this.front = PlStackFront.last,
    this.scaleStep = 1,
    this.opacityStep = 1,
    this.ring,
    this.semanticLabel,
    super.key,
  }) : assert(max == null || max >= 0, 'max cannot be negative');

  /// The things in the pile.
  final List<Widget> children;

  /// Which way the pile grows.
  ///
  /// **Responsive**, so a set can run one way on a phone and the other on a
  /// laptop. It is resolved against the window's width in `build` rather than
  /// laid out by a constraint, which is what makes two of these side by side
  /// agree about which rung they are on.
  final PlassResponsive<PlStackDirection> direction;

  /// How far each item sits under the one before it, in logical pixels, along
  /// the axis the pile flows on.
  ///
  /// Left out it is a fraction of [size], which keeps the overlap looking the
  /// same at every step.
  final double? overlap;

  /// The step on the *other* axis, for [PlStackDirection.diagonal] only.
  ///
  /// Defaults to whatever [overlap] resolved to, which is a 45° fan for square
  /// items and a shallower one for anything wider than it is tall.
  final double? drop;

  /// Which rung of the ladder the default [overlap] comes off.
  ///
  /// It decides **nothing else**. A pile draws no surface of its own and has no
  /// type in it, so there is no height to set and no ink to colour — the items
  /// are whatever they already were.
  final PlassSize? size;

  /// How many items are drawn. Left out, every one of them is.
  final int? max;

  /// How many there are altogether, when the pile was handed only the first few.
  ///
  /// Without it the count is worked out from [children], which is right only
  /// when all of them were passed.
  final int? total;

  /// Builds a last item standing for the ones that did not fit, given how many
  /// that is.
  ///
  /// A builder rather than a widget, because the number **is** the item — a
  /// widget would have to be given a count it has no way to work out, and would
  /// then be wrong every time the list changed.
  final Widget Function(int hidden)? overflow;

  /// Which end of the list is on top.
  final PlStackFront front;

  /// What each item further back is multiplied by, compounding. `0.94` takes
  /// four steps down to about 78%.
  final double scaleStep;

  /// The same, for opacity.
  final double opacityStep;

  /// The corners of the hairline drawn around each item, or `null` for none.
  ///
  /// The hairline is the page's own surface colour, and it is not decoration:
  /// two shapes of similar tone laid over each other have no boundary between
  /// them at all and the pile reads as one smeared shape. Drawn in
  /// [PlassTokens.surface] it reads as the *hole* the near item is cut out of
  /// rather than as a line around anything.
  ///
  /// A radius rather than a `bool`, which is the one place this widget diverges
  /// from the React build. There a ring is a box shadow and CSS gives it the
  /// element's own `border-radius` for nothing; here nothing can read a child's
  /// shape, so the shape has to be said. It is painted as a spread shadow, so it
  /// costs no layout and the overlap arithmetic is untouched.
  final BorderRadius? ring;

  /// What the pile is a pile *of*, for a screen reader.
  ///
  /// A row of faces is a picture of a set, and what it is a set of is the
  /// sentence beside it — name the pile when nothing else is saying so.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final PlassSize size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final PlStackDirection direction = resolveResponsive(context, this.direction);

    final double step = overlap ?? _overlap[size]!;
    final double fall = drop ?? step;

    final List<Widget> shown = max == null
        ? children
        : children.sublist(0, max!.clamp(0, children.length));
    final int counted = total ?? children.length;
    final int hidden = counted - shown.length;

    final List<Widget> piled = <Widget>[
      ...shown,
      if (overflow != null && hidden > 0) overflow!(hidden),
    ];

    final List<Widget> dressed = <Widget>[
      for (int index = 0; index < piled.length; index += 1)
        _dress(tokens, piled[index], depth: _depthOf(index, piled.length)),
    ];

    final Widget pile = _StackFlow(
      direction: direction,
      overlap: step,
      drop: fall,
      front: front,
      textDirection: Directionality.of(context),
      children: dressed,
    );

    return Semantics(
      label: semanticLabel,
      container: semanticLabel != null,
      // The items keep their own nodes, so a named pile is read as its name and
      // then as what is in it rather than as one run-on sentence.
      explicitChildNodes: semanticLabel != null,
      child: pile,
    );
  }

  /// How many steps back from the front an item at [index] sits.
  ///
  /// The front item is always at full size, so turning [front] round does not
  /// also have to turn the depth round.
  int _depthOf(int index, int count) {
    return front == PlStackFront.first ? index : count - 1 - index;
  }

  /// The ring and the depth, in the order they have to be applied.
  Widget _dress(PlassTokens tokens, Widget item, {required int depth}) {
    Widget dressed = item;

    if (ring != null) {
      // A spread shadow rather than a padded box: a shadow paints outside the
      // item without taking part in the layout, which is what keeps the overlap
      // arithmetic about the item rather than about the item plus its ring.
      dressed = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: ring,
          boxShadow: <BoxShadow>[BoxShadow(color: tokens.surface, spreadRadius: _ringWidth)],
        ),
        child: dressed,
      );
    }

    if (opacityStep != 1) {
      dressed = Opacity(
        opacity: math.pow(opacityStep, depth).toDouble().clamp(0, 1),
        child: dressed,
      );
    }

    if (scaleStep != 1) {
      // A paint-time scale, so an item that recedes does not also take less room
      // and pull the pile in behind it.
      dressed = Transform.scale(scale: math.pow(scaleStep, depth).toDouble(), child: dressed);
    }

    return dressed;
  }
}

/* ---------------------------------------------------------------------------
 * The layout
 * ------------------------------------------------------------------------- */

/// Lays the items out overlapping and reports the size of what it drew.
class _StackFlow extends MultiChildRenderObjectWidget {
  const _StackFlow({
    required this.direction,
    required this.overlap,
    required this.drop,
    required this.front,
    required this.textDirection,
    required super.children,
  });

  final PlStackDirection direction;
  final double overlap;
  final double drop;
  final PlStackFront front;
  final TextDirection textDirection;

  @override
  _RenderStackFlow createRenderObject(BuildContext context) {
    return _RenderStackFlow(
      direction: direction,
      overlap: overlap,
      drop: drop,
      front: front,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderStackFlow renderObject) {
    renderObject
      ..direction = direction
      ..overlap = overlap
      ..drop = drop
      ..front = front
      ..textDirection = textDirection;
  }
}

class _StackFlowParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderStackFlow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _StackFlowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _StackFlowParentData> {
  _RenderStackFlow({
    required PlStackDirection direction,
    required double overlap,
    required double drop,
    required PlStackFront front,
    required TextDirection textDirection,
  }) : _direction = direction,
       _overlap = overlap,
       _drop = drop,
       _front = front,
       _textDirection = textDirection;

  PlStackDirection _direction;
  PlStackDirection get direction => _direction;
  set direction(PlStackDirection value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  double _overlap;
  double get overlap => _overlap;
  set overlap(double value) {
    if (_overlap == value) return;
    _overlap = value;
    markNeedsLayout();
  }

  double _drop;
  double get drop => _drop;
  set drop(double value) {
    if (_drop == value) return;
    _drop = value;
    markNeedsLayout();
  }

  PlStackFront _front;
  PlStackFront get front => _front;
  set front(PlStackFront value) {
    if (_front == value) return;
    _front = value;
    // Only the order things are painted in, so there is nothing to lay out
    // again — but the hit-test order rides on it, so it cannot be skipped.
    markNeedsPaint();
  }

  TextDirection _textDirection;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  bool get _flowsAcross => direction != PlStackDirection.vertical;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _StackFlowParentData) {
      child.parentData = _StackFlowParentData();
    }
  }

  /// The pile's size, and — unless [dry] — where each item goes.
  ///
  /// One walk for both, because the two must not be able to disagree: a dry
  /// layout that answered a different size from the real one is a parent laid
  /// out against a box that never existed.
  Size _run(BoxConstraints constraints, {required bool dry}) {
    final BoxConstraints loose = constraints.loosen();

    double cursor = 0;
    double width = 0;
    double height = 0;
    int index = 0;

    RenderBox? child = firstChild;

    while (child != null) {
      final _StackFlowParentData data = child.parentData! as _StackFlowParentData;
      final Size childSize = dry
          ? child.getDryLayout(loose)
          : (child..layout(loose, parentUsesSize: true)).size;

      final double dx = _flowsAcross ? cursor : 0;
      final double dy = switch (direction) {
        PlStackDirection.horizontal => 0,
        PlStackDirection.vertical => cursor,
        PlStackDirection.diagonal => drop * index,
      };

      if (!dry) {
        data.offset = Offset(dx, dy);
      }

      cursor += (_flowsAcross ? childSize.width : childSize.height) - overlap;
      width = math.max(width, dx + childSize.width);
      height = math.max(height, dy + childSize.height);

      index += 1;
      child = data.nextSibling;
    }

    final Size size = constraints.constrain(Size(width, height));

    // The pile grows from the reader's start, so under RTL every item is
    // mirrored about the finished box — the constrained one rather than the
    // content's own extent, so a pile in a box wider than itself sits against
    // the reader's starting edge rather than floating in the middle of it.
    //
    // Done here rather than in `paint` because a hit test and a semantics
    // rectangle read the offsets too.
    if (!dry && _flowsAcross && textDirection == TextDirection.rtl) {
      RenderBox? mirrored = firstChild;

      while (mirrored != null) {
        final _StackFlowParentData data = mirrored.parentData! as _StackFlowParentData;

        data.offset = Offset(size.width - data.offset.dx - mirrored.size.width, data.offset.dy);
        mirrored = data.nextSibling;
      }
    }

    return size;
  }

  @override
  void performLayout() {
    size = _run(constraints, dry: false);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _run(constraints, dry: true);

  /// The pile's own extent along one axis, given each item's.
  double _intrinsic(double Function(RenderBox child) extentOf, {required bool along}) {
    double total = 0;
    double largest = 0;
    int count = 0;

    RenderBox? child = firstChild;

    while (child != null) {
      final double extent = extentOf(child);

      total += extent;
      largest = math.max(
        largest,
        extent + (direction == PlStackDirection.diagonal ? drop * count : 0),
      );
      count += 1;
      child = (child.parentData! as _StackFlowParentData).nextSibling;
    }

    return along ? math.max(0, total - overlap * math.max(0, count - 1)) : largest;
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _intrinsic((RenderBox child) => child.getMinIntrinsicWidth(height), along: _flowsAcross);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _intrinsic((RenderBox child) => child.getMaxIntrinsicWidth(height), along: _flowsAcross);

  @override
  double computeMinIntrinsicHeight(double width) =>
      _intrinsic((RenderBox child) => child.getMinIntrinsicHeight(width), along: !_flowsAcross);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _intrinsic((RenderBox child) => child.getMaxIntrinsicHeight(width), along: !_flowsAcross);

  /// The items in the order they are painted, back to front.
  Iterable<RenderBox> get _painted {
    final List<RenderBox> order = <RenderBox>[];

    RenderBox? child = firstChild;

    while (child != null) {
      order.add(child);
      child = (child.parentData! as _StackFlowParentData).nextSibling;
    }

    // Stated rather than inherited: the list's own order is the answer for
    // exactly one of the two readings, and a deck wants the other.
    return front == PlStackFront.first ? order.reversed : order;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (final RenderBox child in _painted) {
      final _StackFlowParentData data = child.parentData! as _StackFlowParentData;

      context.paintChild(child, offset + data.offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // Front to back, which is the reverse of the paint order: the item a reader
    // can see is the one their finger lands on.
    for (final RenderBox child in _painted.toList().reversed) {
      final _StackFlowParentData data = child.parentData! as _StackFlowParentData;

      final bool hit = result.addWithPaintOffset(
        offset: data.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child.hitTest(result, position: transformed);
        },
      );

      if (hit) {
        return true;
      }
    }

    return false;
  }
}
