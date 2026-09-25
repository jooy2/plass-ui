/// That a step's bullet eases into its new state, and takes it at once when the
/// platform asks for less movement, on every widget that draws one.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/steps.dart';

import '../support/host.dart';

/// The three widgets a bullet is drawn by, each with three steps and `active`
/// at the index given.
final Map<String, Widget Function(int active)> sequences = <String, Widget Function(int active)>{
  'PlStepper': (int active) => PlStepper(
    active: active,
    steps: const <PlStep>[
      PlStep(label: Text('Account')),
      PlStep(label: Text('Verify')),
      PlStep(label: Text('Profile')),
    ],
  ),
  'PlTimeline': (int active) => PlTimeline(
    active: active,
    items: const <PlTimelineItem>[
      PlTimelineItem(title: Text('Ordered')),
      PlTimelineItem(title: Text('Shipped')),
      PlTimelineItem(title: Text('Delivered')),
    ],
  ),
  'PlHowToSteps': (int active) => PlHowToSteps(
    active: active,
    steps: const <PlHowToStep>[
      PlHowToStep(title: Text('Install')),
      PlHowToStep(title: Text('Import')),
      PlHowToStep(title: Text('Use')),
    ],
  ),
};

/// The second bullet's decoration as it is painted this frame, and the one it
/// is headed for.
(Decoration?, Decoration?) _second(WidgetTester tester) {
  final Finder box = find.descendant(
    of: find.byType(PlassStepBullet).at(1),
    matching: find.byType(AnimatedContainer),
  );
  final DecoratedBox painted = tester.widget<DecoratedBox>(
    find.descendant(of: box, matching: find.byType(DecoratedBox)).first,
  );

  return (painted.decoration, tester.widget<AnimatedContainer>(box).decoration);
}

void main() {
  final Duration motion = PlassTokens.light().motionDuration;

  group('PlassStepBullet', () {
    testWidgets('eases into the state its step has reached', (WidgetTester tester) async {
      for (final MapEntry<String, Widget Function(int)> sequence in sequences.entries) {
        await tester.pumpWidget(host(sequence.value(0), width: 700));
        await tester.pumpAndSettle();

        await tester.pumpWidget(host(sequence.value(1), width: 700));
        await tester.pump(motion ~/ 2);

        final (Decoration? midway, Decoration? target) = _second(tester);

        expect(midway, isNot(target), reason: sequence.key);

        await tester.pumpAndSettle();

        final (Decoration? settled, Decoration? _) = _second(tester);

        expect(settled, target, reason: sequence.key);
      }
    });

    testWidgets('takes the state at once under reduced motion', (WidgetTester tester) async {
      for (final MapEntry<String, Widget Function(int)> sequence in sequences.entries) {
        await tester.pumpWidget(host(sequence.value(0), width: 700, disableAnimations: true));
        await tester.pumpAndSettle();

        await tester.pumpWidget(host(sequence.value(1), width: 700, disableAnimations: true));

        final (Decoration? painted, Decoration? target) = _second(tester);

        expect(painted, target, reason: sequence.key);
      }
    });
  });
}
