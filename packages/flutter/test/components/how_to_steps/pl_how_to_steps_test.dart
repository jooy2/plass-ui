import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

const List<PlHowToStep> _steps = <PlHowToStep>[
  PlHowToStep(title: Text('Install the CLI'), child: Text('Run flutter pub add plass_ui.')),
  PlHowToStep(title: Text('Import it'), child: Text('Add one import line.')),
  PlHowToStep(title: Text('Use it'), child: Text('Drop a PlButton in.')),
];

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(host(child, width: 360));
  await tester.pumpAndSettle();
}

void main() {
  group('PlHowToSteps', () {
    group('the list', () {
      testWidgets('numbers the steps as it walks them', (WidgetTester tester) async {
        await _pump(tester, const PlHowToSteps(steps: _steps));

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('stops numbering when it was told to', (WidgetTester tester) async {
        await _pump(tester, const PlHowToSteps(steps: _steps, numbered: false));

        expect(find.text('1'), findsNothing);
      });

      testWidgets('takes a glyph in place of a number, keeping the place in the order', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const PlHowToSteps(
            steps: <PlHowToStep>[
              PlHowToStep(title: Text('One')),
              PlHowToStep(title: Text('Two'), icon: Text('★')),
              PlHowToStep(title: Text('Three')),
            ],
          ),
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.text('★'), findsOneWidget);
        expect(find.text('2'), findsNothing);
        expect(find.text('3'), findsOneWidget);
      });
    });

    group('the body', () {
      testWidgets('is open on every step at once', (WidgetTester tester) async {
        await _pump(tester, const PlHowToSteps(steps: _steps));

        // Somebody following instructions reads ahead and goes back a step,
        // which is the whole difference from a stepper.
        expect(find.text('Run flutter pub add plass_ui.'), findsOneWidget);
        expect(find.text('Add one import line.'), findsOneWidget);
        expect(find.text('Drop a PlButton in.'), findsOneWidget);
      });
    });

    group('active', () {
      testWidgets('leaves every bullet upcoming when it was not given one', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const PlHowToSteps(steps: _steps));

        // A guide that claimed to know how far a reader had got would be
        // guessing, so every bullet is an empty ring.
        expect(_filled(tester), 0);
      });

      testWidgets('fills the bullets up to the one it names', (WidgetTester tester) async {
        await _pump(tester, const PlHowToSteps(steps: _steps, active: 1));

        expect(_filled(tester), 2);
      });

      testWidgets('lets a step say for itself', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlHowToSteps(
            steps: <PlHowToStep>[
              PlHowToStep(title: Text('One'), status: PlHowToStepStatus.complete),
              PlHowToStep(title: Text('Two')),
            ],
          ),
        );

        expect(_filled(tester), 1);
      });
    });

    group('semantics', () {
      testWidgets('says where in the guide each step is', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, const PlHowToSteps(steps: _steps));

        // What a real `<ol>` gives the React build for nothing. Flutter has no
        // ordered list to inherit it from, so the widget writes it in.
        expect(find.bySemanticsLabel(RegExp('Step 2 of 3')), findsOneWidget);

        handle.dispose();
      });

      testWidgets('takes its own words for that', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(
          tester,
          PlHowToSteps(
            steps: _steps,
            semanticStepLabel: (int step, int total) => '$total단계 중 $step단계',
          ),
        );

        expect(find.bySemanticsLabel(RegExp('3단계 중 2단계')), findsOneWidget);

        handle.dispose();
      });
    });
  });
}

/// How many bullets are drawn filled rather than as an empty ring.
///
/// A `complete` or `current` bullet is the family's gradient; an `upcoming` one
/// is a hairline ring with no fill at all.
int _filled(WidgetTester tester) {
  return tester
      .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
      .map((AnimatedContainer container) => container.decoration)
      .whereType<BoxDecoration>()
      .where((BoxDecoration decoration) => decoration.shape == BoxShape.circle)
      .where((BoxDecoration decoration) => decoration.gradient != null)
      .length;
}
