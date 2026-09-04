/// Instructions, numbered, with what to do under each one.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/steps.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How far along one step is. The same three a `PlStepper` and a `PlTimeline`
/// draw, from `internal/steps.dart`, because a haloed bullet must not mean two
/// things.
typedef PlHowToStepStatus = PlassStepStatus;

/// How the line between two steps is drawn.
typedef PlHowToStepsConnector = PlassStepConnector;

/// The space between one step and the next.
const Map<PlassDensity, Map<PlassSize, double>> _stepGap = <PlassDensity, Map<PlassSize, double>>{
  PlassDensity.standard: <PlassSize, double>{
    PlassSize.xs: 16,
    PlassSize.sm: 20,
    PlassSize.md: 24,
    PlassSize.lg: 28,
    PlassSize.xl: 32,
  },
  PlassDensity.compact: <PlassSize, double>{
    PlassSize.xs: 10,
    PlassSize.sm: 12,
    PlassSize.md: 16,
    PlassSize.lg: 16,
    PlassSize.xl: 20,
  },
};

/// One instruction.
@immutable
class PlHowToStep {
  /// Creates a step.
  const PlHowToStep({this.title, this.child, this.icon, this.status});

  /// What the step is. The line the reader scans for.
  final Widget? title;

  /// What to do.
  final Widget? child;

  /// A glyph in place of the number. The step keeps its place in the order
  /// either way — what changes is only what is drawn in the disc.
  final Widget? icon;

  /// Overrides what the guide worked out from [PlHowToSteps.active].
  final PlHowToStepStatus? status;
}

/// Instructions, numbered, with what to do under each one.
///
/// ```dart
/// PlHowToSteps(
///   steps: const <PlHowToStep>[
///     PlHowToStep(title: Text('Install the CLI'), child: Text('Run flutter pub add plass_ui.')),
///     PlHowToStep(title: Text('Import it'), child: Text("Add one import line.")),
///   ],
/// )
/// ```
///
/// Three widgets put things in order and they answer different questions. A
/// `PlStepper` and a `PlTimeline` both say **where you are** — one in a process
/// the reader is moving through now, the other in a sequence that has already
/// happened. This one says **what to do**, and that is the difference the shape
/// follows from: every step's body is open at once, because somebody following
/// instructions reads ahead, goes back a step, and works at their own pace.
///
/// Which is also why [active] is optional here and not on the other two. A guide
/// that claimed to know how far a reader had got would be guessing; pass it only
/// for the guide that genuinely knows.
///
/// **The position is written into each step's semantics**, which is the one
/// place this parts company with the React build. There a real `<ol>` makes a
/// screen reader say "list, five items, item two" on its own; Flutter has no
/// ordered list to inherit that from, so the number a reader hears is put there
/// by [semanticStepLabel].
class PlHowToSteps extends StatelessWidget {
  /// Creates a guide.
  const PlHowToSteps({
    required this.steps,
    this.active,
    this.numbered = true,
    this.connector = PlassStepConnector.solid,
    this.semanticStepLabel,
    this.size,
    this.color,
    this.density,
    super.key,
  });

  /// The instructions, in the order they are to be followed.
  final List<PlHowToStep> steps;

  /// Which step is being worked on now, as an index.
  ///
  /// Optional, and left out for the ordinary case: a set of instructions is
  /// something a reader works through at their own pace.
  final int? active;

  /// Numbers the steps.
  ///
  /// On by default, because that is what instructions are: "do this, then this"
  /// is an order, and the number is how a reader finds their place again after
  /// looking away. Turn it off for a set of things to do in any order, which is
  /// a checklist rather than a how-to.
  final bool numbered;

  /// The line between one step and the next.
  final PlHowToStepsConnector connector;

  /// What a screen reader hears before each step, given its number and the
  /// total.
  ///
  /// A callback rather than a pair of words, for `PlProgressLinear.formatValue`'s
  /// reason: there is no `Intl` in the framework, and a package that pulled
  /// `package:intl` in would be making a dependency decision on its consumer's
  /// behalf.
  final String Function(int step, int total)? semanticStepLabel;

  /// The type scale of the titles and the bodies.
  final PlassSize? size;

  /// The family the bullets take.
  final PlassColor? color;

  /// The space between steps. Never the type scale, never the bullet.
  final PlassDensity? density;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
    final density = this.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final bullet = stepBulletSize[size]!;
    final gap = _stepGap[density]![size]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int index = 0; index < steps.length; index += 1)
          _Step(
            step: steps[index],
            index: index,
            total: steps.length,
            last: index == steps.length - 1,
            status: steps[index].status ?? stepStatusAt(index, active),
            numbered: numbered,
            connector: connector,
            semanticStepLabel: semanticStepLabel ?? _defaultStepLabel,
            bullet: bullet,
            gap: gap,
            size: size,
            family: family,
            tokens: tokens,
          ),
      ],
    );
  }

  static String _defaultStepLabel(int step, int total) => 'Step $step of $total';
}

/// One row of the guide.
class _Step extends StatelessWidget {
  const _Step({
    required this.step,
    required this.index,
    required this.total,
    required this.last,
    required this.status,
    required this.numbered,
    required this.connector,
    required this.semanticStepLabel,
    required this.bullet,
    required this.gap,
    required this.size,
    required this.family,
    required this.tokens,
  });

  final PlHowToStep step;
  final int index;
  final int total;
  final bool last;
  final PlassStepStatus status;
  final bool numbered;
  final PlassStepConnector connector;
  final String Function(int step, int total) semanticStepLabel;
  final double bullet;
  final double gap;
  final PlassSize size;
  final PlassColorFamily family;
  final PlassTokens tokens;

  @override
  Widget build(BuildContext context) {
    // The last step's line would run off the end of the guide into nothing.
    final drawsConnector = connector != PlassStepConnector.none && !last;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: <Widget>[
        if (step.title != null)
          DefaultTextStyle.merge(
            style: TextStyle(
              color: switch (status) {
                PlassStepStatus.complete => tokens.fg,
                PlassStepStatus.current => family.accent,
                PlassStepStatus.upcoming => tokens.mutedFg,
              },
              fontSize: sheetTitle[size]!.size,
              height: sheetTitle[size]!.height,
              fontWeight: FontWeight.w600,
              leadingDistribution: TextLeadingDistribution.even,
            ),
            child: step.title!,
          ),
        if (step.child != null)
          DefaultTextStyle.merge(
            style: TextStyle(
              color: tokens.mutedFg,
              fontSize: sheetBody[size]!.size,
              height: sheetBody[size]!.height,
              leadingDistribution: TextLeadingDistribution.even,
            ),
            child: step.child!,
          ),
      ],
    );

    final mark = PlassStepBullet(
      status: status,
      family: family,
      tokens: tokens,
      size: bullet,
      child: step.icon ?? (numbered ? Text('${index + 1}') : null),
    );

    return Semantics(
      // What a `<ol>` gives the React build for nothing: where in the guide this
      // step is. Flutter has no ordered list to inherit it from.
      label: semanticStepLabel(index + 1, total),
      container: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              width: bullet,
              child: Column(
                children: <Widget>[
                  ExcludeSemantics(child: mark),
                  if (drawsConnector)
                    Expanded(
                      child: Center(
                        child: PlassStepConnectorLine(
                          style: connector,
                          color: status == PlassStepStatus.complete
                              ? family.lineHover
                              : tokens.border,
                          horizontal: false,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: stepBulletGap[size]!),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: last ? 0 : gap),
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
