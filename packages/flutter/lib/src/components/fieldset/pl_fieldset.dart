/// A group of controls that answer one question together.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// A group of controls that answer one question together, with a name on it.
///
/// ```dart
/// PlFieldset(
///   legend: const Text('Billing address'),
///   description: const Text('Where the invoice goes.'),
///   children: <Widget>[streetField, cityField],
/// )
/// ```
///
/// It draws **no surface**, and that is deliberate: a group of fields is a
/// *grouping* and not a sheet, and the sheet already exists — put this inside a
/// [PlCard] or a [PlBox] when one is wanted. What it owns is the legend, the
/// gap the controls stand at, and [disabled].
///
/// **[disabled] is the one thing said differently from the React build**, and
/// the difference is the platform's. There, a `<fieldset disabled>` is an
/// attribute the browser applies to every control inside it, including one a
/// component three levels down rendered and never heard of. There is no such
/// cascade in Flutter, so this does the three things that cascade actually
/// buys: the pointer is taken away, the focus is taken away, and the group is
/// drained the way every disabled surface in the package is. A field inside
/// still reports itself as enabled to a screen reader, which is the part that
/// cannot be reproduced without every widget agreeing to look — so a field that
/// has to *say* it is unavailable is given its own `disabled`.
class PlFieldset extends StatelessWidget {
  /// Creates a group.
  const PlFieldset({
    required this.children,
    this.legend,
    this.description,
    this.disabled = false,
    this.size = PlassSize.md,
    super.key,
  });

  /// The controls that answer one question together.
  final List<Widget> children;

  /// What the group is called.
  ///
  /// It names the group to a screen reader, so it has to be a phrase that still
  /// reads correctly in front of each control in it — "Billing address", not
  /// "Where should we send it?".
  final Widget? legend;

  /// A line under the legend.
  final Widget? description;

  /// Takes the pointer and the focus away from everything inside, and drains
  /// the group.
  final bool disabled;

  /// The type scale of the legend and the gap between the controls.
  final PlassSize size;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final bool hasLegend = legend != null || description != null;

    Widget group = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: sheetSectionGap[size]!,
      children: <Widget>[
        if (hasLegend)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: sheetHeaderGap[size]!,
            children: <Widget>[
              if (legend != null)
                DefaultTextStyle.merge(
                  style: TextStyle(
                    color: tokens.fg,
                    fontSize: sheetTitle[size]!.size,
                    height: sheetTitle[size]!.height,
                    fontWeight: FontWeight.w600,
                  ),
                  child: legend!,
                ),
              if (description != null)
                DefaultTextStyle.merge(
                  style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                  child: description!,
                ),
            ],
          ),
        ...children,
      ],
    );

    if (disabled) {
      group = ExcludeFocus(
        child: IgnorePointer(child: plassStateFilter(child: group, disabled: true)),
      );
    }

    return Semantics(container: true, explicitChildNodes: true, child: group);
  }
}
