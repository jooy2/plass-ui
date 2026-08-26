/// A sequence of steps, in the order they happen in.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How far along one item is.
///
/// Three states rather than two, because "the one you are on" is not the same
/// claim as "done", and a sequence that cannot say which step is current is a
/// list. Each gets its own axis — a filled bullet, a filled bullet with a halo
/// around it, an empty one — rather than three shades of the same thing.
enum PlTimelineStatus {
  /// Behind the sequence. The family's gradient.
  complete,

  /// The one being worked on. The gradient with a halo of the soft tint round
  /// it.
  current,

  /// Still to come. A hairline ring on the page's own surface.
  upcoming,
}

/// How the line between two items is drawn.
enum PlTimelineConnector {
  /// An unbroken rule.
  solid,

  /// A dashed one.
  dashed,

  /// A dotted one.
  dotted,

  /// None at all — the gap is left open.
  none,
}

/// The bullet.
///
/// Its own ladder rather than a step off [controlHeight], for the reason
/// [tickSize] has one: a bullet is not a control you can put a label inside. It
/// is a mark beside one, sized against the title next to it.
const Map<PlassSize, double> _bulletSize = <PlassSize, double>{
  PlassSize.xs: 14,
  PlassSize.sm: 16,
  PlassSize.md: 20,
  PlassSize.lg: 24,
  PlassSize.xl: 30,
};

/// Between the bullet column and the content beside it.
const Map<PlassSize, double> _bulletGap = <PlassSize, double>{
  PlassSize.xs: 8,
  PlassSize.sm: 10,
  PlassSize.md: 12,
  PlassSize.lg: 14,
  PlassSize.xl: 16,
};

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

/// How thick the connector is, and the halo around a current bullet.
const double _connectorWidth = 2;

/// How far the halo reaches past a current bullet.
const double _halo = 4;

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
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.orientation = PlassOrientation.vertical,
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
  final PlassSize size;

  /// Semantic colour role.
  final PlassColor color;

  /// Spacing between steps. Never the type scale, never the bullet.
  final PlassDensity density;

  /// Which way the sequence runs.
  ///
  /// [PlassOrientation.vertical] is the default and the one that takes an
  /// arbitrary number of steps with an arbitrary amount to say about each;
  /// horizontal is the stepper across the top of a checkout, and it is only
  /// honest while every label is short.
  final PlassOrientation orientation;

  @override
  Widget build(BuildContext context) {
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
    final bullet = _bulletSize[size]!;
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

    final mark = _Bullet(
      status: status,
      family: family,
      tokens: tokens,
      size: bullet,
      child: item.bullet,
    );

    // The line starts at the far edge of the bullet and runs to the edge of the
    // item, which is where the next bullet begins.
    final line = _Connector(
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
          SizedBox(width: _bulletGap[size]!),
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

/// The bullet at one of the three states.
class _Bullet extends StatelessWidget {
  const _Bullet({
    required this.status,
    required this.family,
    required this.tokens,
    required this.size,
    this.child,
  });

  final PlTimelineStatus status;
  final PlassColorFamily family;
  final PlassTokens tokens;
  final double size;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final filled = status != PlTimelineStatus.upcoming;
    final ink = filled ? family.onSolid : tokens.mutedFg;

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: AnimatedContainer(
          duration: PlassTokens.duration,
          curve: PlassTokens.ease,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: filled ? family.fill : null,
            color: filled ? null : tokens.surface,
            border: filled
                ? null
                // The neutral hairline rather than the sheet's white one, the
                // same call a checkbox's edge makes: a bullet is small enough
                // that its edge *is* the object.
                : Border.all(color: tokens.border, width: _connectorWidth),
            boxShadow: status == PlTimelineStatus.current
                ? <BoxShadow>[BoxShadow(color: family.soft, spreadRadius: _halo)]
                : null,
          ),
          child: Center(
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: ink,
                // The label inside the bullet is sized off the bullet rather
                // than off the page's own text, so a number in an `xs` bullet is
                // not the same 8px it would be in an `xl` one.
                fontSize: size * 0.5,
                fontWeight: FontWeight.w600,
                height: 1,
                leadingDistribution: TextLeadingDistribution.even,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
              child: IconTheme.merge(
                data: IconThemeData(color: ink, size: size * 0.6),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The line between two bullets.
///
/// Painted rather than drawn as a border, because Flutter's `BorderSide` has no
/// dashes: `dashed` and `dotted` are runs laid down by hand, at the same weight
/// the solid one is.
class _Connector extends StatelessWidget {
  const _Connector({required this.style, required this.color, required this.horizontal});

  final PlTimelineConnector style;
  final Color color;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: horizontal
          ? const Size(double.infinity, _connectorWidth)
          : const Size(_connectorWidth, double.infinity),
      painter: _ConnectorPainter(style: style, color: color, horizontal: horizontal),
      child: SizedBox(
        width: horizontal ? double.infinity : _connectorWidth,
        height: horizontal ? _connectorWidth : double.infinity,
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter({required this.style, required this.color, required this.horizontal});

  final PlTimelineConnector style;
  final Color color;
  final bool horizontal;

  /// The dash and the gap, per style. A dot is a round cap on a zero-length run,
  /// which is what makes it a circle rather than a short square.
  (double, double) get _pattern {
    switch (style) {
      case PlTimelineConnector.dashed:
        return (6, 4);
      case PlTimelineConnector.dotted:
        return (0, 4);
      case PlTimelineConnector.solid:
      case PlTimelineConnector.none:
        return (0, 0);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (style == PlTimelineConnector.none) {
      return;
    }

    final length = horizontal ? size.width : size.height;
    final paint = Paint()
      ..color = color
      ..strokeWidth = _connectorWidth
      ..strokeCap = style == PlTimelineConnector.dotted ? StrokeCap.round : StrokeCap.butt;

    Offset at(double distance) {
      return horizontal ? Offset(distance, size.height / 2) : Offset(size.width / 2, distance);
    }

    if (style == PlTimelineConnector.solid) {
      canvas.drawLine(at(0), at(length), paint);

      return;
    }

    final (dash, gap) = _pattern;
    final step = dash + gap;

    for (var distance = 0.0; distance < length; distance += step) {
      final end = distance + dash > length ? length : distance + dash;

      canvas.drawLine(at(distance), at(end), paint);
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter oldDelegate) {
    return oldDelegate.style != style ||
        oldDelegate.color != color ||
        oldDelegate.horizontal != horizontal;
  }
}
