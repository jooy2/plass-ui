/// What a [PlToggle] reads off the [PlToggleGroup] around it.
///
/// A scope rather than a rewritten child list, for `internal/button_group.dart`'s
/// reason: a toggle wrapped in something else or produced by a `map` is still
/// inside the group, and a scope reaches it wherever it ended up.
///
/// Only the **value** lives here. The five style axes and `disabled` travel on
/// `PlassButtonGroupScope`, which the group publishes as well, so a toggle picks
/// up a `PlButtonGroup` and a `PlToggleGroup` by exactly the same route.
///
/// It is not exported from `plass_ui.dart`.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The set's value, and the one thing a member can do to it.
class PlassToggleGroupScope extends InheritedWidget {
  /// Wraps the members of a set.
  const PlassToggleGroupScope({
    required this.value,
    required this.onToggle,
    required super.child,
    super.key,
  });

  /// The values that are currently on.
  final List<String> value;

  /// Turns one of them on or off. The group decides what that does to the rest.
  final void Function(String value) onToggle;

  /// The set this toggle is in, or `null` when it is not in one.
  static PlassToggleGroupScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PlassToggleGroupScope>();
  }

  @override
  bool updateShouldNotify(PlassToggleGroupScope oldWidget) {
    return !listEquals(value, oldWidget.value);
  }
}
