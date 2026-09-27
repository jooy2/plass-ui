/// A group of controls that answer one question together.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/fieldset.dart';
import 'package:plass_ui/src/internal/scales.dart';
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
/// [disabled] reaches every control inside, including one a widget three
/// levels down drew and never heard of. The fieldset takes the pointer and the
/// focus away from everything in it and hands its state down: every control of
/// this package in it draws itself disabled once, as it does with a `disabled`
/// of its own, and says so to a screen reader. Anything else in the group, a
/// line of text or a widget from somewhere else, is drawn as it is.
class PlFieldset extends StatelessWidget {
  /// Creates a group.
  const PlFieldset({
    required this.children,
    this.legend,
    this.description,
    this.disabled = false,
    this.size,
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

  /// Disables every control inside at once: takes the pointer and the focus
  /// away from everything in the group, and draws each control disabled.
  final bool disabled;

  /// The type scale of the legend and the gap between the controls.
  final PlassSize? size;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;

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

    // Counted in with a disabled fieldset further out, as the React build and
    // the browser both count it.
    final bool inherited = PlassFieldsetScope.disabledOf(context) || disabled;

    // In the tree whether the group is disabled or not, with only their flags
    // switching: wrapped round the group only while it is disabled, every field
    // in it would be built again from scratch each time `disabled` changed, and
    // lose what was typed into it. The group itself is not drained. Each control
    // in it draws itself disabled from the scope, and a group drained on top of
    // that would drain every field twice.
    group = ExcludeFocus(
      excluding: disabled,
      child: IgnorePointer(
        ignoring: disabled,
        child: PlassFieldsetScope(disabled: inherited, child: group),
      ),
    );

    return Semantics(container: true, explicitChildNodes: true, child: group);
  }
}
