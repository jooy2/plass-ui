/// A sequence of steps, in the order they happen in.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/steps.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// How far along one item is.
///
/// The same three a [PlStepper] draws, from `internal/steps.dart`, because a
/// haloed bullet must not mean two things.
typedef PlTimelineStatus = PlassStepStatus;

/// How the line between two items is drawn.
typedef PlTimelineConnector = PlassStepConnector;

/// How far apart two items sit, and the one thing density is allowed to touch
/// here — a compact timeline is the same type at the same bullet size with less
/// air between the steps.
///
/// The floor is set by the item with nothing in it. A step that is only a title
/// and a time is one line tall, so the gap is the *whole* of what separates it
/// from the next one, where a step with a paragraph under it has the paragraph's
/// own leading working for it as well.
const Map<PlassDensity, Map<PlassSize, double>> _itemGap = <PlassDensity, Map<PlassSize, double>>{
  PlassDensity.standard: <PlassSize, double>{
    PlassSize.xs: 20,
    PlassSize.sm: 24,
    PlassSize.md: 28,
    PlassSize.lg: 32,
    PlassSize.xl: 40,
  },
  PlassDensity.compact: <PlassSize, double>{
    PlassSize.xs: 12,
    PlassSize.sm: 14,
    PlassSize.md: 16,
    PlassSize.lg: 20,
    PlassSize.xl: 24,
  },
};

/// One step of a [PlTimeline].
///
/// A description rather than a widget, for the reason a `PlBreadcrumbItem` is
/// one: the timeline has to *reason* about its steps. Which step is complete is
/// arithmetic on an index, and the last step's connector has to know it is the
/// last — neither question can be asked of an opaque `Widget`.
@immutable
class PlTimelineItem {
  /// Creates a step.
  const PlTimelineItem({
    this.title,
    this.meta,
    this.bullet,
    this.status,
    this.color,
    this.connector = PlTimelineConnector.solid,
    this.child,
  });

  /// The heading of this step.
  final Widget? title;

  /// When it happened — a date, a duration, a name. Set beside the title.
  final Widget? meta;

  /// What goes inside the bullet: a number, an icon, an avatar. Omit it and the
  /// bullet is a plain disc, which is what a step with nothing to say about
  /// itself should be.
  final Widget? bullet;

  /// Overrides what the timeline's [PlTimeline.active] would have computed for
  /// this item — a step that failed and stopped the sequence, a step that was
  /// skipped.
  final PlTimelineStatus? status;

  /// Overrides the timeline's colour family for this item alone.
  final PlassColor? color;

  /// How the line to the next item is drawn.
  ///
  /// A connector is the item's own property because it is coloured by whether
  /// the step it *leaves* has been reached, not by where it arrives.
  final PlTimelineConnector connector;

  /// The body of the step.
  final Widget? child;
}

/// A sequence of steps, in the order they happen in.
///
/// ```dart
/// PlTimeline(
///   active: 1,
///   items: <PlTimelineItem>[
///     PlTimelineItem(title: const Text('Ordered'), meta: const Text('Mon')),
///     PlTimelineItem(title: const Text('Shipped'), meta: const Text('Tue')),
///     PlTimelineItem(title: const Text('Delivered')),
///   ],
/// )
/// ```
///
/// The steps are numbered by the timeline rather than by a field on each one, so
/// [active] has something to count against and inserting a step in the middle
/// does not mean renumbering the ones after it.
class PlTimeline extends StatelessWidget {
  /// Creates a sequence.
  const PlTimeline({
    required this.items,
    this.active,
    this.size,
    this.color,
    this.density,
    this.orientation = const PlassResponsive<PlassOrientation>(PlassOrientation.vertical),
    super.key,
  });

  /// The steps, in order.
  final List<PlTimelineItem> items;

  /// How far the sequence has got: the index of the step being worked on now.
  /// Everything before it is complete, everything after it is still to come.
  ///
  /// An index rather than a value, because a timeline has no selection — nothing
  /// here is chosen, and the only question is how far down the list reality has
  /// reached. Omit it and every step is upcoming unless it says otherwise; pass
  /// the step count to mark the whole sequence done.
  final int? active;

  /// Type scale and bullet size.
  final PlassSize? size;

  /// Semantic colour role.
  final PlassColor? color;

  /// Spacing between steps. Never the type scale, never the bullet.
  final PlassDensity? density;

  /// Which way the sequence runs.
  ///
  /// [PlassOrientation.vertical] is the default and the one that takes an
  /// arbitrary number of steps with an arbitrary amount to say about each;
  /// horizontal is the stepper across the top of a checkout, and it is only
  /// honest while every label is short.
  ///
  /// **Responsive**, so a set can run one way on a phone and the other on a
  /// laptop. It is resolved against the window's width in `build` rather than
  /// laid out by a constraint, which is what makes two of these side by side
  /// agree about which rung they are on.
  final PlassResponsive<PlassOrientation> orientation;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
    final density = this.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

    final PlassOrientation orientation = resolveResponsive(context, this.orientation);
    final horizontal = orientation == PlassOrientation.horizontal;

    final steps = <Widget>[
      for (var index = 0; index < items.length; index += 1)
        _Step(
          item: items[index],
          status:
              items[index].status ??
              (active == null
                  ? PlTimelineStatus.upcoming
                  : index < active!
                  ? PlTimelineStatus.complete
                  : index == active!
                  ? PlTimelineStatus.current
                  : PlTimelineStatus.upcoming),
          size: size,
          density: density,
          orientation: orientation,
          color: items[index].color ?? color,
          last: index == items.length - 1,
        ),
    ];

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: horizontal
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[for (final step in steps) Expanded(child: step)],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: steps,
            ),
    );
  }
}

/// One drawn step, with the line that leaves it.
class _Step extends StatelessWidget {
  const _Step({
    required this.item,
    required this.status,
    required this.size,
    required this.density,
    required this.orientation,
    required this.color,
    required this.last,
  });

  final PlTimelineItem item;
  final PlTimelineStatus status;
  final PlassSize size;
  final PlassDensity density;
  final PlassOrientation orientation;
  final PlassColor color;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final horizontal = orientation == PlassOrientation.horizontal;
    final bullet = stepBulletSize[size]!;
    final gap = last ? 0.0 : _itemGap[density]![size]!;

    // The last item's line would run off the end of the sequence into nothing.
    final drawsConnector = item.connector != PlTimelineConnector.none && !last;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: <Widget>[
        if (item.title != null || item.meta != null)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: <Widget>[
              if (item.title != null)
                DefaultTextStyle.merge(
                  style: TextStyle(
                    color: switch (status) {
                      PlTimelineStatus.complete => tokens.fg,
                      PlTimelineStatus.current => family.accent,
                      PlTimelineStatus.upcoming => tokens.mutedFg,
                    },
                    fontSize: sheetTitle[size]!.size,
                    height: sheetTitle[size]!.height,
                    fontWeight: FontWeight.w600,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                  child: item.title!,
                ),
              if (item.meta != null)
                DefaultTextStyle.merge(
                  style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                  child: item.meta!,
                ),
            ],
          ),
        if (item.child != null)
          DefaultTextStyle.merge(
            style: TextStyle(
              color: tokens.mutedFg,
              fontSize: sheetBody[size]!.size,
              height: sheetBody[size]!.height,
              leadingDistribution: TextLeadingDistribution.even,
            ),
            child: item.child!,
          ),
      ],
    );

    final mark = PlassStepBullet(
      status: status,
      family: family,
      tokens: tokens,
      size: bullet,
      child: item.bullet,
    );

    // The line starts at the far edge of the bullet and runs to the edge of the
    // item, which is where the next bullet begins.
    final line = PlassStepConnectorLine(
      style: item.connector,
      color: status == PlTimelineStatus.complete ? family.lineHover : tokens.border,
      horizontal: horizontal,
    );

    if (horizontal) {
      return Padding(
        padding: EdgeInsetsDirectional.only(end: gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: bullet,
              child: Row(
                children: <Widget>[
                  mark,
                  if (drawsConnector) Expanded(child: Center(child: line)),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.only(top: 8), child: body),
          ],
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: bullet,
            child: Column(
              children: <Widget>[
                mark,
                if (drawsConnector) Expanded(child: Center(child: line)),
              ],
            ),
          ),
          SizedBox(width: stepBulletGap[size]!),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: gap),
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}
