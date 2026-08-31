/// The rail a sequence is drawn on, shared by [PlTimeline] and [PlStepper].
///
/// The two widgets are not the same thing — a timeline **reports** a sequence
/// that happened and a stepper **is** one the reader is moving through, which is
/// why one is a column of text and the other is a row of buttons with a panel
/// under it — but they are the same *drawing*, and a reader who has learned what
/// a haloed bullet means on one must not find it meaning something else on the
/// other.
///
/// So the marks live here and the behaviour lives in the widgets. This is the
/// arrangement `internal/button_group.dart` and `internal/progress.dart` already
/// make, and it is here for the reason `internal/icons.dart` gives: two copies
/// of twelve lines are not expensive, they are two copies that drift.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How far along one step is.
///
/// Three states rather than two, because "the one you are on" is not the same
/// claim as "done", and a sequence that cannot say which step is current is a
/// list. Each gets its own axis — a filled bullet, a filled bullet with a halo
/// around it, an empty one — rather than three shades of the same thing.
enum PlassStepStatus {
  /// Behind the sequence. The family's gradient.
  complete,

  /// The one being worked on. The gradient with a halo of the soft tint round
  /// it.
  current,

  /// Still to come. A hairline ring on the page's own surface.
  upcoming,
}

/// How the line between two steps is drawn.
enum PlassStepConnector {
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
/// Its own ladder rather than a step off `controlHeight`, for the reason
/// `tickSize` has one: a bullet is not a control you can put a label inside. It
/// is a mark beside one, sized against the title next to it.
const Map<PlassSize, double> stepBulletSize = <PlassSize, double>{
  PlassSize.xs: 14,
  PlassSize.sm: 16,
  PlassSize.md: 20,
  PlassSize.lg: 24,
  PlassSize.xl: 30,
};

/// Between the bullet column and the content beside it.
const Map<PlassSize, double> stepBulletGap = <PlassSize, double>{
  PlassSize.xs: 8,
  PlassSize.sm: 10,
  PlassSize.md: 12,
  PlassSize.lg: 14,
  PlassSize.xl: 16,
};

/// How thick the connector is.
const double stepConnectorWidth = 2;

/// How far the halo reaches past a current bullet.
const double stepHalo = 4;

/// Which of the three a step is, from where the sequence has got to.
///
/// `active` is an **index**, not a value, because neither a timeline nor a
/// stepper has a selection: everything before it is complete, the step at it is
/// current, everything after it is upcoming.
PlassStepStatus stepStatusAt(int index, int? active) {
  if (active == null) {
    return PlassStepStatus.upcoming;
  }

  if (index < active) {
    return PlassStepStatus.complete;
  }

  return index == active ? PlassStepStatus.current : PlassStepStatus.upcoming;
}

/// The bullet at one of the three states.
///
/// Every one of them is a different axis, never a different opacity: `complete`
/// is the family's gradient, `current` is that gradient with a halo of the soft
/// tint around it, and `upcoming` is a hairline ring on the page's own surface.
/// A reader who cannot tell the colours apart still has a filled shape, a haloed
/// shape and an empty one.
class PlassStepBullet extends StatelessWidget {
  /// Creates a bullet.
  const PlassStepBullet({
    required this.status,
    required this.family,
    required this.tokens,
    required this.size,
    this.child,
    super.key,
  });

  /// Which of the three it draws.
  final PlassStepStatus status;

  /// The family it is filled with.
  final PlassColorFamily family;

  /// The theme it reads its neutrals from.
  final PlassTokens tokens;

  /// Its diameter.
  final double size;

  /// The number, the tick, or whatever the caller put there.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final filled = status != PlassStepStatus.upcoming;
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
                : Border.all(color: tokens.border, width: stepConnectorWidth),
            boxShadow: status == PlassStepStatus.current
                ? <BoxShadow>[BoxShadow(color: family.soft, spreadRadius: stepHalo)]
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
class PlassStepConnectorLine extends StatelessWidget {
  /// Creates a connector.
  const PlassStepConnectorLine({
    required this.style,
    required this.color,
    required this.horizontal,
    super.key,
  });

  /// Solid, dashed, dotted or nothing.
  final PlassStepConnector style;

  /// What it is drawn in — the family once the step it leaves has been reached.
  final Color color;

  /// Whether it runs across or down.
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: horizontal
          ? const Size(double.infinity, stepConnectorWidth)
          : const Size(stepConnectorWidth, double.infinity),
      painter: _ConnectorPainter(style: style, color: color, horizontal: horizontal),
      child: SizedBox(
        width: horizontal ? double.infinity : stepConnectorWidth,
        height: horizontal ? stepConnectorWidth : double.infinity,
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter({required this.style, required this.color, required this.horizontal});

  final PlassStepConnector style;
  final Color color;
  final bool horizontal;

  /// The dash and the gap, per style. A dot is a round cap on a zero-length run,
  /// which is what makes it a circle rather than a short square.
  (double, double) get _pattern {
    switch (style) {
      case PlassStepConnector.dashed:
        return (6, 4);
      case PlassStepConnector.dotted:
        return (0, 4);
      case PlassStepConnector.solid:
      case PlassStepConnector.none:
        return (0, 0);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (style == PlassStepConnector.none) {
      return;
    }

    final length = horizontal ? size.width : size.height;
    final paint = Paint()
      ..color = color
      ..strokeWidth = stepConnectorWidth
      ..strokeCap = style == PlassStepConnector.dotted ? StrokeCap.round : StrokeCap.butt;

    Offset at(double distance) {
      return horizontal ? Offset(distance, size.height / 2) : Offset(size.width / 2, distance);
    }

    if (style == PlassStepConnector.solid) {
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
