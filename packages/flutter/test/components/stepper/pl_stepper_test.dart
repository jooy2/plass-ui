import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// The three-step sign-up every test works against.
const List<PlStep> steps = <PlStep>[
  PlStep(
    label: Text('Account'),
    description: Text('Email and password'),
    child: Text('Account panel'),
  ),
  PlStep(label: Text('Verify'), child: Text('Verify panel')),
  PlStep(label: Text('Profile'), optional: Text('Optional'), child: Text('Profile panel')),
];

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(900, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: 700));
  await tester.pumpAndSettle();
}

void main() {
  group('PlStepper', () {
    group('rendering', () {
      testWidgets('names each step', (WidgetTester tester) async {
        await _pump(tester, PlStepper(steps: steps, active: 0, onActiveChanged: (int _) {}));

        expect(find.text('Account'), findsOneWidget);
        expect(find.text('Verify'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
      });

      testWidgets('draws a description under the label', (WidgetTester tester) async {
        await _pump(tester, PlStepper(steps: steps, active: 0, onActiveChanged: (int _) {}));

        expect(find.text('Email and password'), findsOneWidget);
      });

      testWidgets('numbers the steps it was not given bullets for', (WidgetTester tester) async {
        await _pump(tester, PlStepper(steps: steps, active: 0, onActiveChanged: (int _) {}));

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('takes a bullet of its own', (WidgetTester tester) async {
        await _pump(
          tester,
          PlStepper(
            steps: const <PlStep>[PlStep(label: Text('Account'), bullet: Text('A'))],
            active: 0,
            onActiveChanged: (int _) {},
          ),
        );

        expect(find.text('A'), findsOneWidget);
      });

      testWidgets('says which steps are optional in the words it was given', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlStepper(steps: steps, active: 0, onActiveChanged: (int _) {}));

        // There is no default string: the package ships no translations, and a
        // word it invented would be in one language.
        expect(find.text('Optional'), findsOneWidget);
      });
    });

    group('where the reader is', () {
      testWidgets('shows the current step’s panel and no other', (WidgetTester tester) async {
        await _pump(tester, PlStepper(steps: steps, active: 1, onActiveChanged: (int _) {}));

        expect(find.text('Verify panel'), findsOneWidget);
        expect(find.text('Account panel'), findsNothing);
      });

      testWidgets('marks the current step and only that one', (WidgetTester tester) async {
        await _pump(tester, PlStepper(steps: steps, active: 1, onActiveChanged: (int _) {}));

        final SemanticsHandle handle = tester.ensureSemantics();

        expect(
          find.byWidgetPredicate(
            (Widget widget) => widget is Semantics && widget.properties.selected == true,
          ),
          findsOneWidget,
        );

        handle.dispose();
      });

      testWidgets('reports the step that was pressed', (WidgetTester tester) async {
        int? pressed;

        await _pump(
          tester,
          PlStepper(steps: steps, active: 2, onActiveChanged: (int next) => pressed = next),
        );
        await tester.tap(find.text('Account'));
        await tester.pumpAndSettle();

        expect(pressed, equals(0));
      });

      testWidgets('ticks a step the reader is past', (WidgetTester tester) async {
        await _pump(tester, PlStepper(steps: steps, active: 2, onActiveChanged: (int _) {}));

        // A number is replaced by a tick once the step is behind: two axes for
        // the same fact, so a reader who cannot tell the colours apart still has
        // one.
        expect(find.text('1'), findsNothing);
        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('takes an overriding status', (WidgetTester tester) async {
        await _pump(
          tester,
          PlStepper(
            steps: const <PlStep>[
              PlStep(label: Text('Account'), status: PlStepStatus.upcoming),
              PlStep(label: Text('Verify')),
              PlStep(label: Text('Profile')),
            ],
            active: 2,
            onActiveChanged: (int _) {},
          ),
        );

        // The step that failed validation while the reader moved on keeps its
        // number rather than being ticked.
        expect(find.text('1'), findsOneWidget);
      });
    });

    group('linear', () {
      testWidgets('leaves the steps ahead out of reach', (WidgetTester tester) async {
        int? pressed;

        await _pump(
          tester,
          PlStepper(steps: steps, active: 0, onActiveChanged: (int next) => pressed = next),
        );
        await tester.tap(find.text('Profile'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(pressed, isNull);
      });

      testWidgets('keeps the steps behind reachable', (WidgetTester tester) async {
        int? pressed;

        await _pump(
          tester,
          PlStepper(steps: steps, active: 2, onActiveChanged: (int next) => pressed = next),
        );
        await tester.tap(find.text('Account'));
        await tester.pumpAndSettle();

        // Going back to correct an answer is the whole reason a stepper is not a
        // wizard with one door.
        expect(pressed, equals(0));
      });

      testWidgets('opens every step when it is turned off', (WidgetTester tester) async {
        int? pressed;

        await _pump(
          tester,
          PlStepper(
            steps: steps,
            active: 0,
            linear: false,
            onActiveChanged: (int next) => pressed = next,
          ),
        );
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        expect(pressed, equals(2));
      });

      testWidgets('never reaches a disabled step', (WidgetTester tester) async {
        int? pressed;

        await _pump(
          tester,
          PlStepper(
            steps: const <PlStep>[
              PlStep(label: Text('Account')),
              PlStep(label: Text('Verify'), disabled: true),
              PlStep(label: Text('Profile')),
            ],
            active: 2,
            linear: false,
            onActiveChanged: (int next) => pressed = next,
          ),
        );
        await tester.tap(find.text('Verify'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(pressed, isNull);
      });

      testWidgets('is inert without an onActiveChanged', (WidgetTester tester) async {
        await _pump(tester, const PlStepper(steps: steps, active: 1));

        // Still drawn — a stepper shown without being driven is a legitimate
        // thing to want.
        expect(find.text('Verify panel'), findsOneWidget);
      });
    });

    group('orientation', () {
      testWidgets('puts a vertical step’s panel under its own label', (WidgetTester tester) async {
        await _pump(
          tester,
          PlStepper(
            steps: steps,
            active: 1,
            orientation: const PlassResponsive<PlassOrientation>(PlassOrientation.vertical),
            onActiveChanged: (int _) {},
          ),
        );

        // The answer sits under the question rather than under the whole rail,
        // which is the reason to lay one out vertically at all.
        expect(
          tester.getTopLeft(find.text('Verify panel')).dy,
          greaterThan(tester.getTopLeft(find.text('Verify')).dy),
        );
        expect(
          tester.getTopLeft(find.text('Verify panel')).dy,
          lessThan(tester.getTopLeft(find.text('Profile')).dy),
        );
      });

      testWidgets('puts a horizontal step’s panel under the rail', (WidgetTester tester) async {
        await _pump(tester, PlStepper(steps: steps, active: 1, onActiveChanged: (int _) {}));

        expect(
          tester.getTopLeft(find.text('Verify panel')).dy,
          greaterThan(tester.getTopLeft(find.text('Profile')).dy),
        );
      });
    });
  });
}
