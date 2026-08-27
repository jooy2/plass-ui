/// What a [PlButton] inherits from the [PlButtonGroup] around it.
///
/// The Dart half of the React package's `internal/button-group.ts`, and it is
/// here for the same reason: a button has to be able to read the group without
/// the two components importing each other.
///
/// Every axis is nullable, and `null` means *not specified* rather than a
/// value: a button falls back to its own default, so a group that states
/// nothing changes nothing except the corners.
///
/// What is **not** in the React version is the join — [before] and [after], the
/// two edges of this key that face a neighbour. The stylesheet says that with
/// `rounded-s-none` and a negative margin on the run's own children; there is no
/// stylesheet here, so the group tells each key what it is next to and the key
/// draws itself accordingly. Which is also why this is a scope per child rather
/// than one around the whole run.
///
/// None of it is exported from `plass_ui.dart`.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/types.dart';

/// The axes and the join one key reads off the run it is in.
class PlassButtonGroupScope extends InheritedWidget {
  /// Wraps one member of a run.
  const PlassButtonGroupScope({
    required this.orientation,
    required this.before,
    required this.after,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.disabled,
    required super.child,
    super.key,
  });

  /// Which way the run goes, which decides which pair of corners a join flattens.
  final PlassOrientation orientation;

  /// There is a neighbour on the leading side of this key.
  final bool before;

  /// And on the trailing side.
  final bool after;

  /// The axes, or `null` for "the group did not say".
  final PlassVariant? variant;

  /// See [variant].
  final PlassSize? size;

  /// See [variant].
  final PlassColor? color;

  /// See [variant].
  final PlassDensity? density;

  /// See [variant].
  final PlassElevation? elevation;

  /// See [variant].
  final bool? disabled;

  /// The run this key is in, or `null` when it is not in one.
  static PlassButtonGroupScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PlassButtonGroupScope>();
  }

  /// This key's corners, given the radius its own [PlassSize] asks for.
  ///
  /// Resolved against the ambient [TextDirection] rather than written as a
  /// [BorderRadiusDirectional], because the same value has to reach a
  /// `ClipRRect`, a `BoxDecoration` and two painters, and one of those takes a
  /// resolved [BorderRadius].
  BorderRadius corners(double radius, TextDirection direction) {
    final Radius round = Radius.circular(radius);
    const Radius square = Radius.zero;

    if (orientation == PlassOrientation.vertical) {
      return BorderRadius.only(
        topLeft: before ? square : round,
        topRight: before ? square : round,
        bottomLeft: after ? square : round,
        bottomRight: after ? square : round,
      );
    }

    final bool ltr = direction == TextDirection.ltr;
    final bool leftJoined = ltr ? before : after;
    final bool rightJoined = ltr ? after : before;

    return BorderRadius.only(
      topLeft: leftJoined ? square : round,
      bottomLeft: leftJoined ? square : round,
      topRight: rightJoined ? square : round,
      bottomRight: rightJoined ? square : round,
    );
  }

  /// This key's edge, with the sides that face a neighbour dropped.
  ///
  /// **This is where the two packages part company.** The stylesheet pulls each
  /// key after the first back by a pixel so two hairlines land on top of each
  /// other and read as one. Flutter has no negative margin — `EdgeInsets`
  /// asserts it is non-negative — and the alternative is a `Transform`, which
  /// this library does not put on a control. So the seam is made by *not
  /// drawing* the second of the two lines, which arrives at the same place: one
  /// hairline per seam, at full strength, and nothing has moved.
  BoxBorder border(BorderSide side, TextDirection direction) {
    const BorderSide none = BorderSide.none;

    if (orientation == PlassOrientation.vertical) {
      return Border(left: side, right: side, top: before ? none : side, bottom: side);
    }

    final bool ltr = direction == TextDirection.ltr;

    return Border(
      top: side,
      bottom: side,
      left: before && ltr ? none : side,
      right: before && !ltr ? none : side,
    );
  }

  @override
  bool updateShouldNotify(PlassButtonGroupScope oldWidget) {
    return oldWidget.orientation != orientation ||
        oldWidget.before != before ||
        oldWidget.after != after ||
        oldWidget.variant != variant ||
        oldWidget.size != size ||
        oldWidget.color != color ||
        oldWidget.density != density ||
        oldWidget.elevation != elevation ||
        oldWidget.disabled != disabled;
  }
}
