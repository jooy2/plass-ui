/// What a [PlAvatar] inherits from the [PlAvatarGroup] around it.
///
/// The Dart half of the React package's `internal/avatar-group.ts`, and it is
/// here for the same reason `internal/button_group.dart` is: an avatar has to be
/// able to read the stack without the two components importing each other.
///
/// Every axis is nullable, and `null` means *not specified* rather than a value:
/// an avatar falls back to its own default, so a group that states nothing
/// changes nothing except the overlap.
///
/// None of it is exported from `plass_ui.dart`.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/avatar/pl_avatar.dart';
import 'package:plass_ui/src/types.dart';

/// The axes one face reads off the stack it is in.
class PlassAvatarGroupScope extends InheritedWidget {
  /// Wraps one face of a stack.
  const PlassAvatarGroupScope({
    this.shape,
    this.variant,
    this.size,
    this.color,
    this.elevation,
    required super.child,
    super.key,
  });

  /// The axes, or `null` for "the group did not say".
  final PlAvatarShape? shape;

  /// See [shape].
  final PlassVariant? variant;

  /// See [shape].
  final PlassSize? size;

  /// See [shape].
  final PlassColor? color;

  /// See [shape].
  final PlassElevation? elevation;

  /// The stack this face is in, or `null` when it is not in one.
  static PlassAvatarGroupScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PlassAvatarGroupScope>();
  }

  @override
  bool updateShouldNotify(PlassAvatarGroupScope oldWidget) {
    return shape != oldWidget.shape ||
        variant != oldWidget.variant ||
        size != oldWidget.size ||
        color != oldWidget.color ||
        elevation != oldWidget.elevation;
  }
}
