/// A run of buttons that belong together.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/button_group.dart';
import 'package:plass_ui/src/types.dart';

/// A run of buttons that belong together.
///
/// ```dart
/// PlButtonGroup(
///   variant: PlassVariant.glass,
///   color: PlassColor.secondary,
///   children: <Widget>[
///     PlButton(onPressed: showDay, child: const Text('Day')),
///     PlButton(onPressed: showWeek, child: const Text('Week')),
///     PlButton(onPressed: showMonth, child: const Text('Month')),
///   ],
/// )
/// ```
///
/// Two things happen here and only one of them is visual. The corners that face
/// a neighbour are squared off, so the run reads as one piece scored into
/// segments rather than as three keys that happen to be touching. The other
/// half is that [variant], [size], [color], [density], [elevation] and
/// [disabled] are stated **once for the set** rather than repeated on every
/// button; a group where one button is a size out is the failure this exists to
/// prevent.
///
/// None of the axes has a default of its own. An axis the group leaves out is
/// one each button falls back to *its* own default on, so a group that states
/// nothing changes nothing except the corners — and a button that states an
/// axis itself still wins, because a run of secondary actions with one
/// [PlassColor.danger] button in it is a real thing.
///
/// The buttons stay real `PlButton`s and nothing about them is replaced. Which
/// also means this is **not** a segmented control: it has no value and it
/// manages no selection. For one-of-a-set reach for `PlSegmentedButton`, which
/// is that control and carries the roving focus that goes with it.
class PlButtonGroup extends StatelessWidget {
  /// Creates a run of buttons.
  const PlButtonGroup({
    required this.children,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.orientation = PlassOrientation.horizontal,
    this.disabled,
    this.fullWidth = false,
    super.key,
  }) : assert(
         elevation == null || (elevation >= plassElevationMin && elevation <= plassElevationMax),
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The buttons, in order.
  ///
  /// A list rather than a single `child`, and that is not only Flutter's usual
  /// shape: the group has to know which member is at each end to decide which
  /// corners to square, and a widget that was handed one opaque subtree could
  /// not. Anything may go in it — a button wrapped in a `PlTooltip` inherits
  /// just as well, because the axes travel by inherited widget rather than by
  /// rewriting the children.
  final List<Widget> children;

  /// The material of the whole run. `null` leaves every button on its own.
  final PlassVariant? variant;

  /// Height and type scale for the whole run. See [variant].
  final PlassSize? size;

  /// Semantic colour role for the whole run. See [variant].
  final PlassColor? color;

  /// Horizontal padding for the whole run. See [variant].
  final PlassDensity? density;

  /// Drop shadow depth for the whole run. See [variant].
  final PlassElevation? elevation;

  /// Which way the buttons run.
  ///
  /// [PlassOrientation.vertical] is a stacked menu of equal actions;
  /// [PlassOrientation.horizontal] is the default because that is what a
  /// toolbar is.
  final PlassOrientation orientation;

  /// Disables every button in the group at once. A button that says otherwise
  /// still wins.
  final bool? disabled;

  /// Stretches to the container and divides the space evenly between the
  /// buttons, so three actions across the foot of a card are three equal thirds
  /// rather than three different lengths of word.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final vertical = orientation == PlassOrientation.vertical;
    final last = children.length - 1;

    final members = <Widget>[
      for (var index = 0; index < children.length; index += 1)
        _member(
          index: index,
          // A run of one is not joined to anything, which is what keeps a group
          // built from a `.map()` over a list that turned out to have a single
          // entry looking like an ordinary button.
          before: index > 0,
          after: index < last,
          child: children[index],
        ),
    ];

    return vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: fullWidth ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
            children: members,
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: members,
          );
  }

  Widget _member({
    required int index,
    required bool before,
    required bool after,
    required Widget child,
  }) {
    final scope = PlassButtonGroupScope(
      orientation: orientation,
      before: before,
      after: after,
      variant: variant,
      size: size,
      color: color,
      density: density,
      elevation: elevation,
      disabled: disabled,
      child: child,
    );

    // A vertical run stretches through the column's own cross-axis alignment;
    // only a horizontal one needs the space divided.
    return fullWidth && orientation == PlassOrientation.horizontal
        ? Expanded(key: ValueKey<int>(index), child: scope)
        : scope;
  }
}
