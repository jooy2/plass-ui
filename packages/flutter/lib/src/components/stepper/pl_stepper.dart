/// A process the reader is moving through, and where they are in it.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/steps.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How far along one step is. The same three a [PlTimeline] draws.
typedef PlStepStatus = PlassStepStatus;

/// How the line between two steps is drawn.
typedef PlStepConnector = PlassStepConnector;

/// One step of a [PlStepper].
///
/// A description rather than a widget, for the reason a [PlTimelineItem] is one:
/// the stepper has to *reason* about its steps. Which step is complete is
/// arithmetic on an index, which step can be reached is arithmetic on the same
/// index, and the last step's connector has to know it is the last — none of
/// those can be asked of an opaque `Widget`.
@immutable
class PlStep {
  /// Creates a step.
  const PlStep({
    this.label,
    this.description,
    this.bullet,
    this.status,
    this.optional,
    this.disabled = false,
    this.color,
    this.connector = PlassStepConnector.solid,
    this.child,
  });

  /// What the step is called.
  final Widget? label;

  /// A second line under it — what the step asks for.
  final Widget? description;

  /// What is drawn in the bullet. The step's own number by default, and a tick
  /// once it is complete.
  final Widget? bullet;

  /// Overrides where the sequence says this step is. For the one that failed
  /// validation while the reader was three steps further on.
  final PlStepStatus? status;

  /// Marks the step as skippable, and says so in these words. Pass
  /// `Text('Optional')` — there is no default string, because the package ships
  /// no translations and a word it invented would be in one language.
  final Widget? optional;

  /// Cannot be reached, whatever [PlStepper.linear] says.
  final bool disabled;

  /// Overrides the stepper's family for this one step.
  final PlassColor? color;

  /// How the line to the next step is drawn.
  final PlassStepConnector connector;

  /// The panel this step shows while it is the current one.
  final Widget? child;
}

/// A tick, for a step that is behind the reader.
class _StepTick extends StatelessWidget {
  const _StepTick();

  @override
  Widget build(BuildContext context) {
    // The ink comes from the bullet, which has already set it for its number —
    // so a tick and a numeral in the same bullet are the same colour without
    // either being told what it is.
    return CustomPaint(
      size: const Size.square(12),
      painter: _TickPainter(
        color: DefaultTextStyle.of(context).style.color ?? const Color(0xFFFFFFFF),
      ),
    );
  }
}

class _TickPainter extends CustomPainter {
  const _TickPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.53)
      ..lineTo(size.width * 0.42, size.height * 0.73)
      ..lineTo(size.width * 0.8, size.height * 0.28);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TickPainter oldDelegate) => oldDelegate.color != color;
}

/// A process the reader is moving through, and where they are in it.
///
/// It draws the same rail a [PlTimeline] does — the same three bullet states,
/// the same connector, shared in `internal/steps.dart` — and the difference is
/// what the two are *for*, which is also the whole of when to reach for which. A
/// timeline **reports**: it is a column of text about a sequence that already
/// happened, and nothing on it can be pressed. A stepper **is** the sequence:
/// its steps are buttons, the current one owns a panel, and pressing one moves
/// the reader.
///
/// ```dart
/// PlStepper(
///   active: step,
///   onActiveChanged: (int next) => setState(() => step = next),
///   steps: <PlStep>[
///     PlStep(label: const Text('Account'), child: const Text('…')),
///     PlStep(label: const Text('Verify'), child: const Text('…')),
///   ],
/// )
/// ```
///
/// [active] is an index rather than a value, exactly as a timeline's is, because
/// a stepper has no selection: everything before it is done, the step at it is
/// where you are, everything after it is ahead.
class PlStepper extends StatelessWidget {
  /// Creates a stepper.
  const PlStepper({
    required this.steps,
    required this.active,
    this.onActiveChanged,
    this.linear = true,
    this.orientation = PlassOrientation.horizontal,
    this.size,
    this.color,
    this.density,
    super.key,
  });

  /// The steps, in order.
  final List<PlStep> steps;

  /// Which step the reader is on.
  final int active;

  /// Called with the step that was pressed. A `null` handler makes every step
  /// inert, which is how a stepper is shown without being driven.
  final ValueChanged<int>? onActiveChanged;

  /// Whether a step ahead of the current one can be jumped to.
  ///
  /// On by default, because that is what makes it a process rather than a set of
  /// tabs: the third step of a sign-up cannot be filled in before the second.
  /// Turn it off for a review screen, where every step has already been answered
  /// and the reader is going back to check one.
  final bool linear;

  /// Horizontal puts the panel under the rail; vertical puts each one inside its
  /// own step, which is the reason to lay one out vertically at all.
  final PlassOrientation orientation;

  /// Bullet and type scale.
  final PlassSize? size;

  /// The family the rail takes.
  final PlassColor? color;

  /// The space between steps, and nothing else.
  final PlassDensity? density;

  bool _reachable(int index) {
    if (steps[index].disabled || onActiveChanged == null) {
      return false;
    }

    // A step *behind* the reader is always reachable: going back to correct an
    // answer is the whole reason a stepper is not a wizard with one door.
    return !linear || index <= active;
  }

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
    final density = this.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

    final tokens = PlassTheme.of(context);
    final horizontal = orientation == PlassOrientation.horizontal;

    final rail = <Widget>[
      for (var index = 0; index < steps.length; index += 1)
        _Step(
          step: steps[index],
          index: index,
          last: index == steps.length - 1,
          status: steps[index].status ?? stepStatusAt(index, active),
          reachable: _reachable(index),
          onPressed: _reachable(index) ? () => onActiveChanged!(index) : null,
          tokens: tokens,
          family: tokens.family(steps[index].color ?? color),
          size: size,
          density: density,
          horizontal: horizontal,
          // A vertical stepper puts the panel inside the step it belongs to,
          // which is the whole reason to lay one out vertically: the answer sits
          // under the question rather than under the whole rail.
          panel: !horizontal && index == active ? steps[index].child : null,
        ),
    ];

    final panel = horizontal && active >= 0 && active < steps.length ? steps[active].child : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (horizontal)
          Row(children: <Widget>[for (final Widget step in rail) Expanded(child: step)]),
        if (!horizontal) ...rail,
        if (panel != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: tokens.fg,
                fontSize: sheetBody[size]!.size,
                height: sheetBody[size]!.height,
                leadingDistribution: TextLeadingDistribution.even,
              ),
              child: panel,
            ),
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.step,
    required this.index,
    required this.last,
    required this.status,
    required this.reachable,
    required this.onPressed,
    required this.tokens,
    required this.family,
    required this.size,
    required this.density,
    required this.horizontal,
    required this.panel,
  });

  final PlStep step;
  final int index;
  final bool last;
  final PlassStepStatus status;
  final bool reachable;
  final VoidCallback? onPressed;
  final PlassTokens tokens;
  final PlassColorFamily family;
  final PlassSize size;
  final PlassDensity density;
  final bool horizontal;
  final Widget? panel;

  @override
  Widget build(BuildContext context) {
    final bullet = stepBulletSize[size]!;
    final radius = BorderRadius.circular(PlassTokens.radius[size]!);
    final drawsConnector = step.connector != PlassStepConnector.none && !last;

    final mark = PlassStepBullet(
      status: status,
      family: family,
      tokens: tokens,
      size: bullet,
      child:
          step.bullet ??
          (status == PlassStepStatus.complete ? const _StepTick() : Text('${index + 1}')),
    );

    final text = Column(
      crossAxisAlignment: horizontal ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (step.label != null)
          DefaultTextStyle.merge(
            style: TextStyle(
              color: switch (status) {
                PlassStepStatus.complete => tokens.fg,
                PlassStepStatus.current => family.accent,
                PlassStepStatus.upcoming => tokens.mutedFg,
              },
              fontWeight: FontWeight.w600,
              fontSize: sheetTitle[size]!.size,
              height: sheetTitle[size]!.height,
              leadingDistribution: TextLeadingDistribution.even,
            ),
            child: step.label!,
          ),
        if (step.description != null)
          DefaultTextStyle.merge(
            style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
            child: step.description!,
          ),
        if (step.optional != null)
          DefaultTextStyle.merge(
            style: TextStyle(
              color: tokens.mutedFg,
              fontSize: metaText[size]!,
              fontStyle: FontStyle.italic,
            ),
            child: step.optional!,
          ),
      ],
    );

    Widget inner = horizontal
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              mark,
              SizedBox(height: stepBulletGap[size]! * 0.75),
              text,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              mark,
              SizedBox(width: stepBulletGap[size]!),
              Flexible(child: text),
            ],
          );

    inner = Padding(padding: const EdgeInsets.all(4), child: inner);

    if (reachable) {
      // Held in a `final` of its own before the reassignment below. A closure
      // captures the *variable*, so a builder that read `inner` would read
      // whatever `inner` had become by the time it ran — which is the
      // `PlassInteractive` holding the builder, and a widget that contains
      // itself is a stack overflow rather than a layout.
      final Widget content = inner;

      inner = PlassInteractive(
        onTap: onPressed,
        builder: (BuildContext context, PlassInteraction state) {
          Widget body = AnimatedContainer(
            duration: PlassTokens.duration,
            curve: PlassTokens.ease,
            decoration: BoxDecoration(
              color: state.hovered || state.pressed ? family.soft : null,
              borderRadius: radius,
            ),
            child: content,
          );

          if (state.focusVisible) {
            body = CustomPaint(
              foregroundPainter: PlassFocusRingPainter(color: family.ring, borderRadius: radius),
              child: body,
            );
          }

          return body;
        },
      );
    } else if (step.disabled) {
      inner = Opacity(opacity: 0.5, child: inner);
    }

    // `selected` marks the current step, which is the nearest thing the
    // framework has to the `aria-current="step"` the React build sets — and it
    // is deliberately the only role claimed. A stepper is not a tab list: a tab
    // list owes a keyboard reader one stop and arrow keys, and claiming that
    // without the behaviour is worse than never claiming it.
    inner = Semantics(
      container: true,
      button: reachable,
      enabled: reachable,
      selected: status == PlassStepStatus.current,
      child: inner,
    );

    final row = horizontal
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(child: inner),
              if (drawsConnector)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: bullet / 2 + 4),
                    child: PlassStepConnectorLine(
                      style: step.connector,
                      color: status == PlassStepStatus.complete ? family.lineHover : tokens.border,
                      horizontal: true,
                    ),
                  ),
                ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              inner,
              if (panel != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: bullet + stepBulletGap[size]! + 4,
                    top: 4,
                    bottom: 12,
                  ),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: tokens.fg,
                      fontSize: sheetBody[size]!.size,
                      height: sheetBody[size]!.height,
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                    child: panel!,
                  ),
                ),
              if (drawsConnector)
                Padding(
                  padding: EdgeInsetsDirectional.only(start: bullet / 2 + 4),
                  child: SizedBox(
                    height: density == PlassDensity.compact ? 16 : 24,
                    child: PlassStepConnectorLine(
                      style: step.connector,
                      color: status == PlassStepStatus.complete ? family.lineHover : tokens.border,
                      horizontal: false,
                    ),
                  ),
                ),
            ],
          );

    return row;
  }
}
