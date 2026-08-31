/// The place where there is nothing.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// How big the glyph is. Its own ladder — it is a picture, not a control.
const Map<PlassSize, double> _glyphSize = <PlassSize, double>{
  PlassSize.xs: 24,
  PlassSize.sm: 30,
  PlassSize.md: 36,
  PlassSize.lg: 44,
  PlassSize.xl: 56,
};

/// The place where there is nothing.
///
/// An empty list, a search that found nothing, a filter that excluded
/// everything, a flow that has finished. All four are the same arrangement — a
/// mark, a line, a sentence, a way out — which is why they are one widget and
/// not four, and why [color] is what tells them apart: `secondary` is "nothing
/// here yet", `danger` is "something went wrong", `success` is "you are done".
///
/// It **draws no surface**. An empty state is always inside something — a card,
/// a table, a panel — and a sheet inside a sheet is two sheets. What it decides
/// is the arrangement and the space around it.
///
/// The one thing worth getting right is the **way out**. A screen that says
/// "No projects" and stops is a dead end; the same screen with a "New project"
/// button is the best moment in the whole flow to offer one.
///
/// ```dart
/// PlEmpty(
///   icon: const Icon(Icons.inbox),
///   title: const Text('No projects yet'),
///   description: const Text('Start one and it will show up here.'),
///   actions: <Widget>[PlButton(onPressed: create, child: const Text('New project'))],
/// )
/// ```
class PlEmpty extends StatelessWidget {
  /// Creates an empty state.
  const PlEmpty({
    this.icon,
    this.title,
    this.description,
    this.actions = const <Widget>[],
    this.child,
    this.size,
    this.color,
    this.density,
    super.key,
  });

  /// The glyph or drawing above the words. Sized off [size].
  final Widget? icon;

  /// The one line that says what is not here.
  final Widget? title;

  /// What to do about it. One or two sentences, never a paragraph.
  final Widget? description;

  /// The way out — usually one [PlButton].
  final List<Widget> actions;

  /// Anything else that belongs between the description and the actions.
  final Widget? child;

  /// Glyph, type scale and the space around it.
  final PlassSize? size;

  /// The family the glyph takes.
  ///
  /// `secondary` by default, which is the whole difference between an empty
  /// state and an alert: nothing has gone wrong. Reach for `danger` when
  /// something has, and `success` for the end of a flow — which is what turns
  /// this into the "your order is confirmed" screen without a second widget.
  final PlassColor? color;

  /// The vertical padding, and nothing else.
  final PlassDensity? density;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.secondary;
    final density = this.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final pad = sheetPaddingY[density]![size]!;
    final space = stackGap[size]!;

    final parts = <Widget>[
      if (icon != null)
        ExcludeSemantics(
          child: IconTheme.merge(
            data: IconThemeData(color: family.accent, size: _glyphSize[size]!),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: family.accent, fontSize: _glyphSize[size]!),
              child: icon!,
            ),
          ),
        ),
      if (title != null)
        DefaultTextStyle.merge(
          textAlign: TextAlign.center,
          style: TextStyle(
            color: tokens.fg,
            fontWeight: FontWeight.w600,
            fontSize: sheetTitle[size]!.size,
            height: sheetTitle[size]!.height,
            leadingDistribution: TextLeadingDistribution.even,
          ),
          child: title!,
        ),
      if (description != null)
        DefaultTextStyle.merge(
          textAlign: TextAlign.center,
          style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
          child: description!,
        ),
      ?child,
      if (actions.isNotEmpty)
        Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: actions),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: pad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          for (var index = 0; index < parts.length; index += 1) ...<Widget>[
            if (index > 0) SizedBox(height: space),
            parts[index],
          ],
        ],
      ),
    );
  }
}
