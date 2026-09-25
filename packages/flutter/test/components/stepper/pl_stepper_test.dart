import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';

import '../../support/host.dart';

/// A label with a `State` of its own: built again from scratch, it is a
/// different object.
class _Probe extends StatefulWidget {
  const _Probe(this.text);

  final String text;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => Text(widget.text);
}

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

      testWidgets('takes a press from a screen reader', (WidgetTester tester) async {
        int? pressed;

        await _pump(
          tester,
          PlStepper(steps: steps, active: 2, onActiveChanged: (int next) => pressed = next),
        );
        tester.semantics.tap(find.semantics.byLabel(RegExp('Account')));
        await tester.pumpAndSettle();

        expect(pressed, equals(0));
      });

      testWidgets('keeps a step’s label when the focus ring comes and goes', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        int rings() => tester
            .widgetList<CustomPaint>(find.byType(CustomPaint))
            .where((CustomPaint paint) => paint.foregroundPainter is PlassFocusRingPainter)
            .length;

        await _pump(
          tester,
          afterFocusStop(
            before,
            PlStepper(
              steps: const <PlStep>[
                PlStep(label: _Probe('Account')),
                PlStep(label: Text('Verify')),
              ],
              active: 1,
              onActiveChanged: (int next) {},
            ),
          ),
        );

        final State<_Probe> resting = tester.state(find.byType(_Probe));

        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // The ring really is drawn, and the label inside it is the same object.
        expect(rings(), 1);
        expect(tester.state(find.byType(_Probe)), same(resting));

        before.requestFocus();
        await tester.pumpAndSettle();

        expect(rings(), 0);
        expect(tester.state(find.byType(_Probe)), same(resting));
      });

      testWidgets('does not call a step ahead disabled', (WidgetTester tester) async {
        await _pump(tester, PlStepper(steps: steps, active: 0, onActiveChanged: (int _) {}));

        // Not pressable yet, which leaving `button` off says. Only `disabled`
        // makes a step one a screen reader announces as unavailable.
        expect(
          tester.getSemantics(find.text('Profile')),
          isSemantics(isButton: false, hasEnabledState: false, hasTapAction: false),
        );
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

      testWidgets('keeps a step’s label as it is disabled and enabled again', (
        WidgetTester tester,
      ) async {
        Widget stepper({bool disabled = false}) {
          return PlStepper(
            steps: <PlStep>[
              const PlStep(label: Text('Account')),
              PlStep(label: const _Probe('Verify'), disabled: disabled),
            ],
            active: 0,
            linear: false,
            onActiveChanged: (int _) {},
          );
        }

        double dim() {
          return tester
              .widget<PlassFiltered>(
                find.ancestor(of: find.byType(_Probe), matching: find.byType(PlassFiltered)).first,
              )
              .opacity;
        }

        await _pump(tester, stepper());
        final State<_Probe> held = tester.state(find.byType(_Probe));

        expect(dim(), 1);

        await _pump(tester, stepper(disabled: true));

        expect(dim(), disabledOpacity);
        expect(tester.state(find.byType(_Probe)), same(held), reason: 'disabled');

        await _pump(tester, stepper());

        expect(tester.state(find.byType(_Probe)), same(held), reason: 'enabled again');
      });

      testWidgets('keeps a step’s label as the reader comes level with it', (
        WidgetTester tester,
      ) async {
        Widget stepper(int active) {
          return PlStepper(
            steps: const <PlStep>[
              PlStep(label: Text('Account')),
              PlStep(label: _Probe('Verify')),
            ],
            active: active,
            onActiveChanged: (int _) {},
          );
        }

        await _pump(tester, stepper(0));
        final State<_Probe> held = tester.state(find.byType(_Probe));

        // Within reach now, and so pressable, where it was out of reach before.
        await _pump(tester, stepper(1));

        expect(tester.state(find.byType(_Probe)), same(held));
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

      for (final (String how, PlassOrientation orientation) in <(String, PlassOrientation)>[
        ('vertical', PlassOrientation.vertical),
        ('horizontal', PlassOrientation.horizontal),
      ]) {
        testWidgets('names a $how panel after the step it belongs to', (WidgetTester tester) async {
          final SemanticsHandle handle = tester.ensureSemantics();
          await _pump(
            tester,
            PlStepper(
              steps: steps,
              active: 1,
              orientation: PlassResponsive<PlassOrientation>(orientation),
              onActiveChanged: (int _) {},
            ),
          );

          // A reader landing in the panel is told which step it is the panel
          // for, as the React panel's `aria-labelledby` says.
          expect(
            find.ancestor(of: find.text('Verify panel'), matching: find.bySemanticsLabel('Verify')),
            findsOneWidget,
          );

          handle.dispose();
        });
      }
    });
  });
}
