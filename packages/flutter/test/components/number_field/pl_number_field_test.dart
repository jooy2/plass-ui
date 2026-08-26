import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/icons.dart';

import '../../support/host.dart';

/// A field wired to a variable, which is how every caller uses it.
class _Harness extends StatefulWidget {
  const _Harness({
    this.value = 5,
    this.min,
    this.max,
    this.step = 1,
    this.snapOnStep = false,
    this.steppers = PlNumberFieldSteppers.end,
    this.readOnly = false,
    this.disabled = false,
    this.format,
    this.onCommitted,
  });

  final double? value;
  final double? min;
  final double? max;
  final double step;
  final bool snapOnStep;
  final PlNumberFieldSteppers steppers;
  final bool readOnly;
  final bool disabled;
  final String Function(double value)? format;
  final ValueChanged<double?>? onCommitted;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late double? _value = widget.value;

  double? get value => _value;

  @override
  Widget build(BuildContext context) {
    return PlNumberField(
      value: _value,
      min: widget.min,
      max: widget.max,
      step: widget.step,
      snapOnStep: widget.snapOnStep,
      steppers: widget.steppers,
      readOnly: widget.readOnly,
      disabled: widget.disabled,
      format: widget.format,
      onCommitted: widget.onCommitted,
      onChanged: (double? next) => setState(() => _value = next),
    );
  }
}

Future<_HarnessState> _pump(WidgetTester tester, _Harness harness) async {
  await tester.pumpWidget(host(harness, width: 320));

  return tester.state<_HarnessState>(find.byType(_Harness));
}

/// The `+` stepper, which is the second glyph in the row when both are drawn.
Finder _plus() => find.byWidgetPredicate(
  (Widget widget) => widget is PlassGlyph && widget.shape == PlassGlyphShape.plus,
);

Finder _minus() => find.byWidgetPredicate(
  (Widget widget) => widget is PlassGlyph && widget.shape == PlassGlyphShape.minus,
);

void main() {
  group('PlNumberField', () {
    group('shapes', () {
      testWidgets('draws both steppers by default', (WidgetTester tester) async {
        await _pump(tester, const _Harness());

        expect(_plus(), findsOneWidget);
        expect(_minus(), findsOneWidget);
      });

      testWidgets('drops them when asked', (WidgetTester tester) async {
        await _pump(tester, const _Harness(steppers: PlNumberFieldSteppers.none));

        expect(_plus(), findsNothing);
        expect(_minus(), findsNothing);
      });

      testWidgets('a read-only field keeps the number and loses the buttons', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const _Harness(readOnly: true));

        expect(find.text('5'), findsOneWidget);
        expect(_plus(), findsNothing);
      });

      testWidgets('split puts the minus before the number', (WidgetTester tester) async {
        await _pump(tester, const _Harness(steppers: PlNumberFieldSteppers.split));

        expect(tester.getCenter(_minus()).dx, lessThan(tester.getCenter(_plus()).dx));
        expect(tester.getCenter(_minus()).dx, lessThan(tester.getCenter(find.text('5')).dx));
      });
    });

    group('stepping', () {
      testWidgets('a press moves by one step', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness());

        await tester.tap(_plus());
        await tester.pump();
        expect(state.value, 6);

        await tester.tap(_minus());
        await tester.pump();
        expect(state.value, 5);
      });

      testWidgets('stops at each end of the range', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness(value: 1, min: 1, max: 2));

        await tester.tap(_minus());
        await tester.pump();
        expect(state.value, 1);

        await tester.tap(_plus());
        await tester.pump();
        await tester.tap(_plus());
        await tester.pump();
        expect(state.value, 2);
      });

      testWidgets('the arrow keys step, and the modifiers change how far', (
        WidgetTester tester,
      ) async {
        final state = await _pump(tester, const _Harness(value: 0));

        await tester.tap(find.byType(PlNumberField));
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();
        expect(state.value, 1);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();
        expect(state.value, 11);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
        await tester.pump();
        expect(state.value, 10.9);
      });

      testWidgets('Home and End go to the ends of the range', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness(value: 5, min: 0, max: 100));

        await tester.tap(find.byType(PlNumberField));
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump();
        expect(state.value, 100);

        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pump();
        expect(state.value, 0);
      });

      testWidgets('snaps to a multiple of the step when asked', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness(value: 7, step: 5, snapOnStep: true));

        await tester.tap(_plus());
        await tester.pump();
        expect(state.value, 10);
      });

      testWidgets('an empty field steps from the bottom of the range', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness(value: null, min: 3));

        await tester.tap(_plus());
        await tester.pump();
        expect(state.value, 4);
      });

      testWidgets('a held stepper keeps going', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness(value: 0));

        final press = await tester.startGesture(tester.getCenter(_plus()));
        await tester.pump(const Duration(milliseconds: 700));
        await press.up();
        await tester.pump();

        // Five repeats after the pause, plus the one the release itself is
        // worth. The exact count is the timer's; that it ran at all is the test.
        expect(state.value, greaterThan(2));
      });

      testWidgets('a disabled field does not step', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness(disabled: true));

        await tester.tap(_plus(), warnIfMissed: false);
        await tester.pump();
        expect(state.value, 5);
      });
    });

    group('text', () {
      testWidgets('reads what was typed and settles it on the way out', (
        WidgetTester tester,
      ) async {
        final state = await _pump(tester, const _Harness(value: 5, max: 12));

        await tester.enterText(find.byType(EditableText), '40');
        await tester.pump();

        // Reported as typed…
        expect(state.value, 40);

        // …and clamped when the field settles.
        tester.binding.focusManager.primaryFocus!.unfocus();
        await tester.pumpAndSettle();
        expect(state.value, 12);
        expect(find.text('12'), findsOneWidget);
      });

      testWidgets('throws away everything a number is written with', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness(value: 0));

        await tester.enterText(find.byType(EditableText), r'$1,240.50');
        await tester.pump();

        expect(state.value, 1240.5);
      });

      testWidgets('writes a settled value the way format asks for', (WidgetTester tester) async {
        await _pump(
          tester,
          _Harness(value: 1240, format: (double value) => '\$${value.toStringAsFixed(2)}'),
        );

        expect(find.text(r'$1240.00'), findsOneWidget);
      });

      testWidgets('a whole number keeps no decimal point of its own', (WidgetTester tester) async {
        await _pump(tester, const _Harness(value: 12));

        expect(find.text('12'), findsOneWidget);
      });

      testWidgets('onCommitted fires once the field settles, not per keystroke', (
        WidgetTester tester,
      ) async {
        final settled = <double?>[];
        await _pump(tester, _Harness(value: 5, max: 12, onCommitted: settled.add));

        await tester.enterText(find.byType(EditableText), '40');
        await tester.pump();
        expect(settled, isEmpty);

        tester.binding.focusManager.primaryFocus!.unfocus();
        await tester.pumpAndSettle();
        expect(settled, <double?>[12]);
      });
    });

    group('accessibility', () {
      testWidgets('is announced as a text field holding what it shows', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, const _Harness(value: 5));

        expect(
          semanticsOf(tester, find.byType(PlNumberField)),
          isSemantics(isTextField: true, value: '5'),
        );

        handle.dispose();
      });

      testWidgets('each stepper has a name of its own', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, const _Harness());

        expect(find.bySemanticsLabel('Increase'), findsOneWidget);
        expect(find.bySemanticsLabel('Decrease'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('a stepper at the end of the range is unavailable', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, const _Harness(value: 2, max: 2));

        expect(
          tester.getSemantics(find.bySemanticsLabel('Increase')),
          isSemantics(isEnabled: false, hasEnabledState: true),
        );

        handle.dispose();
      });
    });
  });
}
