/// Content at some widths and not others.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/types.dart';

/// Content at some widths and not others.
///
/// ```dart
/// PlShow(from: PlassBreakpointFloor.md, child: PlTable<Row>(columns: columns, rows: rows))
/// PlShow(until: PlassBreakpointFloor.md, child: PlList(children: rows))
/// ```
///
/// [until] is **exclusive**, which is what lets it and [from] be the two halves
/// of one decision: `until: md` and `from: md` on two widgets leave no width
/// that draws both and none that draws neither.
///
/// It builds nothing at all at a width it is closed at — not an empty box with
/// a size, and not a subtree hidden behind an [Offstage]. That differs from the
/// React build, which sends both halves and hides one with `display: none`, and
/// the difference cuts both ways: an expensive subtree costs nothing here while
/// it is closed, and any state inside one loses everything when the window
/// crosses the boundary. Lift that state above the gate.
class PlShow extends StatelessWidget {
  /// Creates a gate.
  const PlShow({required this.child, this.from, this.until, super.key});

  /// The narrowest width [child] is drawn at. Below it, nothing.
  final PlassBreakpointFloor? from;

  /// The width [child] stops being drawn at. From that rung up, nothing.
  final PlassBreakpointFloor? until;

  /// What is shown, at the widths it is shown at.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // The window's width rather than this widget's own box, which is what a
    // breakpoint means everywhere else in the package: two widgets side by side
    // are at the same breakpoint however wide each of them ended up.
    final double width = MediaQuery.sizeOf(context).width;

    final bool open =
        (from == null || width >= from!.width) && (until == null || width < until!.width);

    return open ? child : const SizedBox.shrink();
  }
}
