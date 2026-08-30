/// A set of toggles that share one state.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/button_group.dart';
import 'package:plass_ui/src/internal/toggle_group.dart';
import 'package:plass_ui/src/types.dart';

/// A set of toggles that share one state.
///
/// ```dart
/// PlToggleGroup(
///   multiple: true,
///   value: marks,
///   onValueChanged: (List<String> next) => setState(() => marks = next),
///   children: const <Widget>[
///     PlToggle(value: 'bold', child: Text('Bold')),
///     PlToggle(value: 'italic', child: Text('Italic')),
///   ],
/// )
/// ```
///
/// Two things happen here and only one of them is visual. The corners that face
/// a neighbour are squared off, so the run reads as one piece scored into
/// segments. The other half is that the set owns the value: the toggles report
/// into one list, [multiple] decides whether more than one of them can be on,
/// and the five style axes and [disabled] are stated once here rather than on
/// every toggle.
///
/// The value is a **list in both cases**, which is the one shape that does not
/// change type when [multiple] is turned on.
///
/// Without [multiple] this is a one-of-a-set, and that is worth a second
/// thought: if the choice is a *value* rather than a state, it is a
/// `PlSegmentedButton` or a `PlRadioGroup`.
class PlToggleGroup extends StatefulWidget {
  /// Creates a set of toggles.
  const PlToggleGroup({
    required this.children,
    this.value,
    this.defaultValue = const <String>[],
    this.onValueChanged,
    this.multiple = false,
    this.orientation = PlassOrientation.horizontal,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.disabled,
    this.fullWidth = false,
    super.key,
  });

  /// The toggles that make up the set. Each needs a `value` to be part of it.
  final List<Widget> children;

  /// Which toggles are on, by their `value`. Passing it makes the set
  /// controlled.
  final List<String>? value;

  /// Which start on, for an uncontrolled set.
  final List<String> defaultValue;

  /// Called when the set's value changes.
  final ValueChanged<List<String>>? onValueChanged;

  /// Whether more than one can be on at a time. Off, turning one on turns the
  /// last one off.
  final bool multiple;

  /// Which way the toggles run.
  final PlassOrientation orientation;

  /// Passed to every toggle in the set. `null` leaves each one its own default.
  final PlassVariant? variant;

  /// See [variant].
  final PlassSize? size;

  /// See [variant].
  final PlassColor? color;

  /// See [variant].
  final PlassDensity? density;

  /// See [variant].
  final PlassElevation? elevation;

  /// Disables every toggle in the set at once.
  final bool? disabled;

  /// Stretches to what is around it and divides the space evenly between the
  /// toggles.
  final bool fullWidth;

  @override
  State<PlToggleGroup> createState() => _PlToggleGroupState();
}

class _PlToggleGroupState extends State<PlToggleGroup> {
  late List<String> _ownValue = List<String>.of(widget.defaultValue);

  List<String> get _value => widget.value ?? _ownValue;

  void _toggle(String value) {
    final List<String> current = _value;
    final List<String> next;

    if (current.contains(value)) {
      next = current.where((String entry) => entry != value).toList(growable: false);
    } else if (widget.multiple) {
      next = <String>[...current, value];
    } else {
      // One of a set: turning one on turns whatever was on off.
      next = <String>[value];
    }

    if (widget.value == null) {
      setState(() => _ownValue = next);
    }

    widget.onValueChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final bool vertical = widget.orientation == PlassOrientation.vertical;
    final int last = widget.children.length - 1;

    final List<Widget> members = <Widget>[
      for (int index = 0; index < widget.children.length; index += 1)
        _member(
          index: index,
          // A run of one is not joined to anything, which is what keeps a set
          // built from a `map` over a list that turned out to have a single
          // entry looking like an ordinary toggle.
          before: index > 0,
          after: index < last,
          child: widget.children[index],
        ),
    ];

    return PlassToggleGroupScope(
      value: _value,
      onToggle: _toggle,
      child: vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: widget.fullWidth
                  ? CrossAxisAlignment.stretch
                  : CrossAxisAlignment.start,
              children: members,
            )
          : Row(
              mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: members,
            ),
    );
  }

  Widget _member({
    required int index,
    required bool before,
    required bool after,
    required Widget child,
  }) {
    final Widget scope = PlassButtonGroupScope(
      orientation: widget.orientation,
      before: before,
      after: after,
      variant: widget.variant,
      size: widget.size,
      color: widget.color,
      density: widget.density,
      elevation: widget.elevation,
      disabled: widget.disabled,
      child: child,
    );

    return widget.fullWidth && widget.orientation == PlassOrientation.horizontal
        ? Expanded(key: ValueKey<int>(index), child: scope)
        : scope;
  }
}
