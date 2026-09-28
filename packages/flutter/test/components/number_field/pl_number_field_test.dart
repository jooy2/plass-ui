import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/glow.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/notch.dart';
import 'package:plass_ui/src/internal/scales.dart';

import '../../support/host.dart';
import '../../support/text_input.dart';

/// A field wired to a variable, which is how every caller uses it.
class _Harness extends StatefulWidget {
  const _Harness({
    super.key,
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
    this.allowWheelScrub = false,
    this.startIcon,
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
  final bool allowWheelScrub;
  final Widget? startIcon;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late double? _value = widget.value;

  double? get value => _value;

  /// Sets the value from outside the field, as a parent's own state changing
  /// does.
  void handIn(double? next) => setState(() => _value = next);

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
      allowWheelScrub: widget.allowWheelScrub,
      startIcon: widget.startIcon,
      onChanged: (double? next) => setState(() => _value = next),
    );
  }
}

Future<_HarnessState> _pump(WidgetTester tester, _Harness harness) async {
  await tester.pumpWidget(host(harness, width: 320));

  return tester.state<_HarnessState>(find.byType(_Harness));
}

/// [harness] inside a `WidgetsApp`, which is what gives a focused editor the
/// tap regions a real app has: there, and only there, a mouse press outside
/// the editor's region takes the focus out of it.
Future<_HarnessState> _pumpInApp(WidgetTester tester, _Harness harness) async {
  await tester.pumpWidget(
    WidgetsApp(
      color: const Color(0xFF000000),
      builder: (BuildContext context, Widget? child) => host(harness, width: 320),
    ),
  );

  return tester.state<_HarnessState>(find.byType(_Harness));
}

/// Whether the field's editor holds the focus.
bool _editorFocused(WidgetTester tester) {
  return tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus;
}

/// Presses [key] with <kbd>Shift</kbd> or <kbd>Alt</kbd> held if asked, and
/// lets the parent build with what the field reported.
Future<void> _press(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool shift = false,
  bool alt = false,
}) async {
  final LogicalKeyboardKey? modifier = shift
      ? LogicalKeyboardKey.shiftLeft
      : alt
      ? LogicalKeyboardKey.altLeft
      : null;

  if (modifier != null) {
    await tester.sendKeyDownEvent(modifier);
  }

  await tester.sendKeyEvent(key);

  if (modifier != null) {
    await tester.sendKeyUpEvent(modifier);
  }

  await tester.pump();
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

      testWidgets('dims a stepper at its limit, and never twice', (WidgetTester tester) async {
        final int dim = Color.getAlphaFromOpacity(disabledOpacity);

        Iterable<int> alphas() {
          return tester.layers.whereType<OpacityLayer>().map((OpacityLayer layer) => layer.alpha!);
        }

        Future<void> field({double value = 5, bool disabled = false}) async {
          await tester.pumpWidget(
            host(
              PlNumberField(
                value: value,
                min: 0,
                max: 10,
                disabled: disabled,
                onChanged: (double? _) {},
              ),
              width: 320,
            ),
          );
          await tester.pumpAndSettle();
        }

        // Both steppers can step, and an opacity of 1 on them would be two
        // more layers on every field for nothing.
        await field();
        expect(alphas(), isEmpty, reason: 'available');

        // At either end of the range the stepper that has run into it goes
        // out, and the other one does not.
        await field(value: 10);
        expect(alphas(), <int>[dim], reason: 'at the top of the range');
        await field(value: 0);
        expect(alphas(), <int>[dim], reason: 'at the bottom of the range');

        // A disabled field is dimmed as one, and its steppers with it rather
        // than a second time on their own, which would draw them at a quarter,
        // the one at the end of the range included.
        await field(disabled: true);
        expect(alphas(), <int>[dim], reason: 'disabled');
        await field(value: 10, disabled: true);
        expect(alphas(), <int>[dim], reason: 'disabled at the top of the range');
      });

      testWidgets('keeps its adornments muted as it takes the focus', (WidgetTester tester) async {
        final FocusNode focus = FocusNode();
        addTearDown(focus.dispose);

        await tester.pumpWidget(
          host(
            PlNumberField(
              value: 5,
              onChanged: (double? _) {},
              focusNode: focus,
              startIcon: const Text(r'$'),
              endIcon: const Text('kg'),
            ),
            width: 320,
          ),
        );

        final Color muted = PlassTokens.light().mutedFg;

        expect(styleOf(tester, r'$').color, muted);
        expect(styleOf(tester, 'kg').color, muted);

        focus.requestFocus();
        await tester.pumpAndSettle();

        // The focus is answered by the edge, the ring and the caret, as the
        // React field answers it.
        expect(focus.hasFocus, isTrue);
        expect(styleOf(tester, r'$').color, muted);
        expect(styleOf(tester, 'kg').color, muted);
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

      testWidgets('Home and End leave a read-only field where it is', (WidgetTester tester) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pump(
          tester,
          _Harness(value: 5, min: 0, max: 100, readOnly: true, onCommitted: settled.add),
        );

        await tester.tap(find.byType(PlNumberField));
        await tester.pump();
        expect(_editorFocused(tester), isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pump();

        expect(state.value, 5);
        expect(find.text('5'), findsOneWidget);
        expect(settled, isEmpty);
      });

      testWidgets('leaves Home and End to the caret when the range has no such end', (
        WidgetTester tester,
      ) async {
        final _HarnessState state = await _pump(tester, const _Harness(value: 5, max: 9));

        await tester.tap(find.byType(EditableText));
        await tester.pump();

        // No `min`, so Home is the editor's, as Base UI leaves it to the browser.
        expect(await tester.sendKeyEvent(LogicalKeyboardKey.home), isFalse);
        await tester.pump();
        expect(state.value, 5);

        expect(await tester.sendKeyEvent(LogicalKeyboardKey.end), isTrue);
        await tester.pump();
        expect(state.value, 9);
      });

      testWidgets('turns the wheel by the step its modifier asks for', (WidgetTester tester) async {
        final _HarnessState state = await _pump(
          tester,
          const _Harness(value: 5, allowWheelScrub: true),
        );

        await tester.tap(find.byType(EditableText));
        await tester.pump();

        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);
        await tester.sendEventToBinding(mouse.hover(tester.getCenter(find.byType(EditableText))));

        // Shift for the large step, Alt for the small one, as Base UI takes
        // them, and Shift turning the wheel sideways as some platforms do.
        for (final (LogicalKeyboardKey? key, Offset turn, double after)
            in <(LogicalKeyboardKey?, Offset, double)>[
              (null, const Offset(0, -40), 6),
              (LogicalKeyboardKey.shiftLeft, const Offset(-40, 0), 16),
              (LogicalKeyboardKey.altLeft, const Offset(0, 40), 15.9),
            ]) {
          if (key != null) {
            await tester.sendKeyDownEvent(key);
          }

          await tester.sendEventToBinding(mouse.scroll(turn));
          await tester.pump();

          if (key != null) {
            await tester.sendKeyUpEvent(key);
          }

          expect(state.value, closeTo(after, 1e-9), reason: '$key');
        }

        // A sideways turn with no Shift is the page's.
        await tester.sendEventToBinding(mouse.scroll(const Offset(40, 0)));
        await tester.pump();

        expect(state.value, closeTo(15.9, 1e-9));
      });

      testWidgets('a key or a turn of the wheel that changes nothing settles nothing', (
        WidgetTester tester,
      ) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pump(
          tester,
          _Harness(value: 10, min: 0, max: 10, allowWheelScrub: true, onCommitted: settled.add),
        );

        await tester.tap(find.byType(EditableText));
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump();

        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

        await tester.sendEventToBinding(mouse.hover(tester.getCenter(find.byType(EditableText))));
        await tester.sendEventToBinding(mouse.scroll(const Offset(0, -40)));
        await tester.pump();

        expect(state.value, 10);
        expect(settled, isEmpty);

        // One that moves the value settles it.
        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pump();

        expect(state.value, 0);
        expect(settled, <double?>[0]);
      });

      testWidgets('a second key before the parent builds steps from where the first one left it', (
        WidgetTester tester,
      ) async {
        double? value = 5;
        final List<double?> changes = <double?>[];
        final List<double?> settled = <double?>[];

        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => PlNumberField(
                value: value,
                onChanged: (double? next) => setState(() {
                  changes.add(next);
                  value = next;
                }),
                onCommitted: settled.add,
              ),
            ),
            width: 320,
          ),
        );

        await tester.tap(find.byType(EditableText));
        await tester.pump();

        // Both keys are handled before the next frame, so the parent has not
        // built with 6 when the second one steps back to 5.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();

        expect(changes, <double?>[6, 5]);
        expect(settled, <double?>[6, 5]);
        expect(value, 5);
        expect(find.text('5'), findsOneWidget);

        // The same the other way, from the value the parent built with.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();

        expect(changes, <double?>[6, 5, 4, 5]);
        expect(settled, <double?>[6, 5, 4, 5]);
        expect(value, 5);
        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('a second key before a parent that turns the first down is reported too', (
        WidgetTester tester,
      ) async {
        final List<double?> changes = <double?>[];
        final List<double?> settled = <double?>[];

        await tester.pumpWidget(
          host(
            PlNumberField(value: 5, onChanged: changes.add, onCommitted: settled.add),
            width: 320,
          ),
        );

        await tester.tap(find.byType(EditableText));
        await tester.pump();

        // A caller that saves what settles has been told 6, so it is told the
        // step back to 5 as well, and ends where the field does.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        expect(changes, <double?>[6, 5]);
        expect(settled, <double?>[6, 5]);
        expect(find.text('5'), findsOneWidget);

        // The parent has answered by now, so the next step is measured against
        // the 5 it holds rather than the 6 it turned down, and is reported.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();

        expect(changes, <double?>[6, 5, 6]);
        expect(settled, <double?>[6, 5, 6]);
        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('a key that changes nothing leaves what was typed to settle on the way out', (
        WidgetTester tester,
      ) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pump(
          tester,
          _Harness(max: 10, onCommitted: settled.add),
        );

        await tester.showKeyboard(find.byType(EditableText));
        tester.testTextInput.enterText('10');
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();

        expect(state.value, 10);
        expect(settled, isEmpty);

        // The key wrote the box, so a value handed in now is shown, and what
        // settles on the way out is the value the field holds by then.
        state.handIn(3);
        await tester.pump();
        expect(find.text('3'), findsOneWidget);

        tester.binding.focusManager.primaryFocus!.unfocus();
        await tester.pumpAndSettle();

        expect(state.value, 3);
        expect(settled, <double?>[3]);
      });

      testWidgets('the wheel steps a focused field and leaves the page where it is', (
        WidgetTester tester,
      ) async {
        final ScrollController page = ScrollController();
        addTearDown(page.dispose);

        await tester.pumpWidget(
          host(
            ListView(
              controller: page,
              children: const <Widget>[
                SizedBox(height: 100),
                _Harness(value: 5, allowWheelScrub: true),
                SizedBox(height: 2000),
              ],
            ),
            width: 320,
            height: 400,
          ),
        );
        final _HarnessState state = tester.state<_HarnessState>(find.byType(_Harness));

        await tester.tap(find.byType(EditableText));
        await tester.pump();

        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);
        final Offset over = tester.getCenter(find.byType(EditableText));

        await tester.sendEventToBinding(mouse.hover(over));
        await tester.sendEventToBinding(mouse.scroll(const Offset(0, 40)));
        await tester.pump();

        expect(state.value, 4);
        // The wheel was spoken for by the field. A page that scrolled as well
        // would move the field out from under the pointer turning it.
        expect(page.offset, 0);

        // A sideways wheel says nothing about more or less.
        await tester.sendEventToBinding(mouse.scroll(const Offset(40, 0)));
        await tester.pump();

        expect(state.value, 4);
      });

      testWidgets('snaps to a multiple of the step when asked', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness(value: 7, step: 5, snapOnStep: true));

        await tester.tap(_plus());
        await tester.pump();
        expect(state.value, 10);
      });

      testWidgets('a snapped step goes to the next multiple in its direction', (
        WidgetTester tester,
      ) async {
        final _HarnessState state = await _pump(
          tester,
          const _Harness(value: 8, max: 12, step: 5, snapOnStep: true),
        );

        await tester.tap(find.byType(EditableText));
        await tester.pump();

        // Up from 8 is 10, the multiple the step passed, and not 15, the
        // multiple nearest to 13.
        await _press(tester, LogicalKeyboardKey.arrowUp);
        expect(state.value, 10);

        // Snapped before it is clamped, so a `max` that is not a multiple is
        // still reached.
        await _press(tester, LogicalKeyboardKey.arrowUp);
        expect(state.value, 12);

        state.handIn(8);
        await tester.pump();

        await _press(tester, LogicalKeyboardKey.arrowDown);
        expect(state.value, 5);
      });

      testWidgets('a snapped field goes all the way to its range on End', (
        WidgetTester tester,
      ) async {
        final _HarnessState state = await _pump(
          tester,
          const _Harness(value: 8, max: 12, step: 5, snapOnStep: true),
        );

        await tester.tap(find.byType(EditableText));
        await tester.pump();

        // `End` is not a step, so it goes to 12 and not to the 10 nearest it.
        await _press(tester, LogicalKeyboardKey.end);
        expect(state.value, 12);
      });

      testWidgets('a snapped step counts its multiples from min', (WidgetTester tester) async {
        final _HarnessState state = await _pump(
          tester,
          const _Harness(value: 8, min: 1, step: 5, snapOnStep: true),
        );

        await tester.tap(find.byType(EditableText));
        await tester.pump();

        await _press(tester, LogicalKeyboardKey.arrowUp);
        expect(state.value, 11);

        state.handIn(8);
        await tester.pump();

        await _press(tester, LogicalKeyboardKey.arrowDown);
        expect(state.value, 6);
      });

      testWidgets('a snapped small step goes to the nearest multiple of the small step', (
        WidgetTester tester,
      ) async {
        final _HarnessState state = await _pump(tester, const _Harness(value: 5, snapOnStep: true));

        await tester.tap(find.byType(EditableText));
        await tester.pump();

        // A tenth, and not back to the whole number the step snaps to.
        await _press(tester, LogicalKeyboardKey.arrowUp, alt: true);
        expect(state.value, 5.1);

        // 4.94 is nearer 4.9 than 5.
        state.handIn(5.04);
        await tester.pump();

        await _press(tester, LogicalKeyboardKey.arrowDown, alt: true);
        expect(state.value, 4.9);
      });

      testWidgets('a snapped small step counts its multiples from min too', (
        WidgetTester tester,
      ) async {
        final _HarnessState state = await _pump(
          tester,
          const _Harness(value: 1, min: 0.05, snapOnStep: true),
        );

        await tester.tap(find.byType(EditableText));
        await tester.pump();

        // The multiples of a tenth counted from 0.05, as Base UI counts them.
        await _press(tester, LogicalKeyboardKey.arrowUp, alt: true);
        expect(state.value, 1.15);
      });

      testWidgets('a snapped large step goes to a multiple of the large step', (
        WidgetTester tester,
      ) async {
        final _HarnessState state = await _pump(tester, const _Harness(value: 5, snapOnStep: true));

        await tester.tap(find.byType(EditableText));
        await tester.pump();

        await _press(tester, LogicalKeyboardKey.arrowUp, shift: true);
        expect(state.value, 10);

        await _press(tester, LogicalKeyboardKey.pageUp);
        expect(state.value, 20);

        state.handIn(23);
        await tester.pump();

        await _press(tester, LogicalKeyboardKey.pageDown);
        expect(state.value, 20);
      });

      testWidgets('leaves a typed number unsnapped', (WidgetTester tester) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pump(
          tester,
          _Harness(step: 5, snapOnStep: true, onCommitted: settled.add),
        );

        await tester.showKeyboard(find.byType(EditableText));
        tester.testTextInput.enterText('7');
        await tester.pump();

        tester.binding.focusManager.primaryFocus!.unfocus();
        await tester.pumpAndSettle();

        expect(state.value, 7);
        expect(find.text('7'), findsOneWidget);
        expect(settled, <double?>[7]);

        await tester.showKeyboard(find.byType(EditableText));
        tester.testTextInput.enterText('13');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(state.value, 13);
        expect(settled, <double?>[7, 13]);
      });

      testWidgets('an empty field is given zero held inside the range', (
        WidgetTester tester,
      ) async {
        // As Base UI seeds it: zero, or the end of the range nearest it, and
        // not a step on from either.
        for (final (double? min, double? max, double seeded) in <(double?, double?, double)>[
          (null, null, 0),
          (3, null, 3),
          (null, -2, -2),
        ]) {
          final state = await _pump(
            tester,
            _Harness(key: UniqueKey(), value: null, min: min, max: max),
          );

          await tester.tap(_plus());
          await tester.pump();
          expect(state.value, seeded, reason: 'min $min, max $max');
        }
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

      testWidgets('a held stepper stops at the end of the range, and settles once on release', (
        WidgetTester tester,
      ) async {
        double? value = 0;
        int changes = 0;
        final List<double?> settled = <double?>[];

        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => PlNumberField(
                value: value,
                max: 3,
                onChanged: (double? next) => setState(() {
                  changes += 1;
                  value = next;
                }),
                onCommitted: settled.add,
              ),
            ),
            width: 320,
          ),
        );

        final press = await tester.startGesture(tester.getCenter(_plus()));
        await tester.pump(const Duration(milliseconds: 1200));

        // Each repeat is a change, and none of them is the value settling: a
        // caller that saves on `onCommitted` would otherwise send a request for
        // every one.
        expect(value, 3);
        expect(settled, isEmpty);

        final int atTheEnd = changes;
        await tester.pump(const Duration(milliseconds: 600));
        expect(changes, atTheEnd);

        await press.up();
        await tester.pumpAndSettle();

        expect(settled, <double?>[3]);
        expect(value, 3);

        // The next press, on the other stepper, is a step.
        await tester.tap(_minus());
        await tester.pumpAndSettle();

        expect(value, 2);
        expect(settled, <double?>[3, 2]);
      });

      testWidgets('a disabled field does not step', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness(disabled: true));

        await tester.tap(_plus(), warnIfMissed: false);
        await tester.pump();
        expect(state.value, 5);
      });

      testWidgets('a mouse press on a stepper leaves the focus in a focused field', (
        WidgetTester tester,
      ) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pumpInApp(tester, _Harness(onCommitted: settled.add));

        await tester.tap(find.byType(EditableText), kind: PointerDeviceKind.mouse);
        await tester.pumpAndSettle();
        expect(_editorFocused(tester), isTrue);

        await tester.tap(_plus(), kind: PointerDeviceKind.mouse);
        await tester.pumpAndSettle();

        // One step, settled once, and the field still being typed in: the
        // stepper is the field's own, not a press somewhere else on the page.
        expect(state.value, 6);
        expect(settled, <double?>[6]);
        expect(_editorFocused(tester), isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();

        expect(state.value, 7);
        expect(settled, <double?>[6, 7]);
      });

      testWidgets('a mouse press on a stepper leaves the focus in a field at its limit', (
        WidgetTester tester,
      ) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pumpInApp(
          tester,
          _Harness(max: 5, onCommitted: settled.add),
        );

        await tester.tap(find.byType(EditableText), kind: PointerDeviceKind.mouse);
        await tester.pumpAndSettle();

        await tester.tap(_plus(), kind: PointerDeviceKind.mouse);
        await tester.pumpAndSettle();

        expect(state.value, 5);
        expect(settled, isEmpty);
        expect(_editorFocused(tester), isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        expect(state.value, 4);
      });

      testWidgets('a mouse press on a stepper brings the focus into the field', (
        WidgetTester tester,
      ) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pumpInApp(tester, _Harness(onCommitted: settled.add));

        expect(_editorFocused(tester), isFalse);

        await tester.tap(_plus(), kind: PointerDeviceKind.mouse);
        await tester.pumpAndSettle();

        // So the keyboard can carry on from the value the press left.
        expect(state.value, 6);
        expect(settled, <double?>[6]);
        expect(_editorFocused(tester), isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();

        expect(state.value, 7);
      });

      testWidgets('a touch on a stepper steps without bringing the focus in', (
        WidgetTester tester,
      ) async {
        final _HarnessState state = await _pumpInApp(tester, const _Harness());

        await tester.tap(_plus());
        await tester.pumpAndSettle();

        // A finger that brought the focus in would bring the keyboard up with
        // it, over the field it was only nudging.
        expect(state.value, 6);
        expect(_editorFocused(tester), isFalse);
      });
    });

    group('text', () {
      testWidgets('keeps its text input connection when it takes the focus', (
        WidgetTester tester,
      ) async {
        final state = await _pump(tester, const _Harness(value: 5));

        await tester.tap(find.byType(EditableText));
        await tester.pumpAndSettle();

        // Typed straight into the connection the focus opened. `enterText` would
        // ask for the keyboard again and hide a connection that was lost.
        expect(tester.testTextInput.hasAnyClients, isTrue);
        tester.testTextInput.enterText('40');
        await tester.pump();

        expect(state.value, 40);
      });

      testWidgets('brings the keyboard back as a press lands round the number', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const _Harness(value: 25));

        // The shell's own padding, before the start of the editor.
        final Rect editor = tester.getRect(find.byType(EditableText));
        final Offset padding = Offset(editor.left - 6, editor.center.dy);
        final TextEditingController controller = tester
            .widget<EditableText>(find.byType(EditableText))
            .controller;

        await tester.tapAt(padding);
        await tester.pump();

        expect(_editorFocused(tester), isTrue);
        expect(tester.testTextInput.isVisible, isTrue);

        // The keyboard put away under the focus, as Android's back does. The
        // press brings it back, and leaves the caret where it was.
        controller.selection = const TextSelection.collapsed(offset: 1);
        await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
        expect(tester.testTextInput.isVisible, isFalse);

        await tester.tapAt(padding);
        await tester.pump();

        expect(tester.testTextInput.isVisible, isTrue);
        expect(controller.selection, const TextSelection.collapsed(offset: 1));

        // A read-only field takes the focus and opens no keyboard, and a
        // disabled one takes neither.
        FocusManager.instance.primaryFocus!.unfocus();
        await _pump(tester, const _Harness(value: 25, readOnly: true));
        await tester.tapAt(padding);
        await tester.pump();

        expect(_editorFocused(tester), isTrue);
        expect(tester.testTextInput.hasAnyClients, isFalse);

        FocusManager.instance.primaryFocus!.unfocus();
        await _pump(tester, const _Harness(value: 25, disabled: true));
        await tester.tapAt(padding);
        await tester.pump();

        expect(_editorFocused(tester), isFalse);
        expect(tester.testTextInput.hasAnyClients, isFalse);
      });

      testWidgets('brings the keyboard back as a press lands on the number, once', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const _Harness(value: null));

        final Finder editor = find.byType(EditableText);

        await tester.tap(editor);
        await tester.pump();

        expect(_editorFocused(tester), isTrue);
        expect(tester.testTextInput.isVisible, isTrue);

        // The keyboard put away under the focus, as Android's back does. The
        // caret of an empty box is already where the press puts it, which on
        // its own asks for no keyboard.
        await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
        tester.testTextInput.log.clear();
        await tester.tap(editor);
        await tester.pump();

        expect(tester.testTextInput.isVisible, isTrue);
        expect(
          tester.testTextInput.log.where((MethodCall call) => call.method == 'TextInput.show'),
          hasLength(1),
        );
      });

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

      testWidgets('shows what the parent holds when the parent turns a value down', (
        WidgetTester tester,
      ) async {
        final List<double?> offered = <double?>[];

        await tester.pumpWidget(host(PlNumberField(value: 5, onChanged: offered.add), width: 320));

        await tester.enterText(find.byType(EditableText), '40');
        await tester.pump();
        tester.binding.focusManager.primaryFocus!.unfocus();
        await tester.pumpAndSettle();

        // Offered, and not taken: the box says what the field holds rather than
        // the number that was turned down.
        expect(offered, contains(40));
        expect(find.text('5'), findsOneWidget);
        expect(find.text('40'), findsNothing);

        await tester.tap(_plus());
        await tester.pumpAndSettle();

        expect(offered.last, 6);
        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('shows a value handed in while it holds the focus', (WidgetTester tester) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pump(tester, _Harness(onCommitted: settled.add));

        await tester.showKeyboard(find.byType(EditableText));
        await tester.pump();

        state.handIn(9);
        await tester.pump();

        // Nothing is being typed, so the box says what the field now holds.
        expect(_editorFocused(tester), isTrue);
        expect(find.text('9'), findsOneWidget);

        // Leaving it has nothing to settle. A box still holding the number
        // from before would write that number back over the one handed in.
        tester.binding.focusManager.primaryFocus!.unfocus();
        await tester.pumpAndSettle();

        expect(state.value, 9);
        expect(find.text('9'), findsOneWidget);
        expect(settled, isEmpty);
      });

      testWidgets('keeps what is being typed over a value handed in, and settles it', (
        WidgetTester tester,
      ) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pump(tester, _Harness(onCommitted: settled.add));

        await tester.showKeyboard(find.byType(EditableText));
        tester.testTextInput.enterText('7');
        await tester.pump();

        state.handIn(9);
        await tester.pump();

        expect(find.text('7'), findsOneWidget);

        tester.binding.focusManager.primaryFocus!.unfocus();
        await tester.pumpAndSettle();

        expect(state.value, 7);
        expect(settled, <double?>[7]);
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

    group('leaving the field', () {
      testWidgets('settles nothing when the field is passed by Tab', (WidgetTester tester) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);
        final List<double?> settled = <double?>[];

        await tester.pumpWidget(
          host(afterFocusStop(before, _Harness(onCommitted: settled.add)), width: 320),
        );
        final _HarnessState state = tester.state<_HarnessState>(find.byType(_Harness));

        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(_editorFocused(tester), isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // Nothing was typed and nothing changed, so there is nothing to settle.
        expect(_editorFocused(tester), isFalse);
        expect(state.value, 5);
        expect(settled, isEmpty);
      });

      testWidgets('settles what was typed, though every keystroke already reported it', (
        WidgetTester tester,
      ) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pump(tester, _Harness(onCommitted: settled.add));

        await tester.enterText(find.byType(EditableText), '7');
        await tester.pump();
        expect(state.value, 7);

        // The box settles to the value the parent already holds, and the
        // number was still typed rather than settled.
        tester.binding.focusManager.primaryFocus!.unfocus();
        await tester.pumpAndSettle();

        expect(settled, <double?>[7]);
      });

      testWidgets('offers a typed number the parent turned down again as it settles', (
        WidgetTester tester,
      ) async {
        final List<double?> changes = <double?>[];
        final List<double?> settled = <double?>[];

        await tester.pumpWidget(
          host(
            PlNumberField(value: 5, onChanged: changes.add, onCommitted: settled.add),
            width: 320,
          ),
        );

        await tester.showKeyboard(find.byType(EditableText));
        tester.testTextInput.enterText('7');
        await tester.pump();
        expect(changes, <double?>[7]);

        // The parent still holds 5, so the 7 the field settles to is a change,
        // as Base UI offers it again on blur.
        tester.binding.focusManager.primaryFocus!.unfocus();
        await tester.pumpAndSettle();

        expect(changes, <double?>[7, 7]);
        expect(settled, <double?>[7]);
        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('keeps a value handed in outside the range when nothing was typed', (
        WidgetTester tester,
      ) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pump(
          tester,
          _Harness(value: 40, max: 12, onCommitted: settled.add),
        );

        await tester.showKeyboard(find.byType(EditableText));
        await tester.pump();
        tester.binding.focusManager.primaryFocus!.unfocus();
        await tester.pumpAndSettle();

        // As Base UI keeps it: a Tab through the field is not an edit.
        expect(state.value, 40);
        expect(find.text('40'), findsOneWidget);
        expect(settled, isEmpty);
      });

      testWidgets('settles a number typed outside the range, once', (WidgetTester tester) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pump(
          tester,
          _Harness(value: 4, max: 12, onCommitted: settled.add),
        );

        await tester.showKeyboard(find.byType(EditableText));
        tester.testTextInput.enterText('40');
        await tester.pump();
        tester.binding.focusManager.primaryFocus!.unfocus();
        await tester.pumpAndSettle();

        expect(state.value, 12);
        expect(settled, <double?>[12]);
      });

      testWidgets('keeps a number as it was typed', (WidgetTester tester) async {
        final _HarnessState state = await _pump(tester, const _Harness(value: 4));

        await tester.showKeyboard(find.byType(EditableText));
        tester.testTextInput.enterText('1.123456789012345');
        await tester.pump();
        tester.binding.focusManager.primaryFocus!.unfocus();
        await tester.pumpAndSettle();

        // Not rounded to ten places, as a step is: Base UI keeps typed input.
        expect(state.value, 1.123456789012345);
      });

      testWidgets('commits nothing on Enter with nothing typed', (WidgetTester tester) async {
        final List<double?> settled = <double?>[];

        await _pump(tester, _Harness(value: 4, onCommitted: settled.add));

        await tester.showKeyboard(find.byType(EditableText));
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(settled, isEmpty);

        // Typed, it settles on Enter.
        await tester.showKeyboard(find.byType(EditableText));
        tester.testTextInput.enterText('7');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(settled, <double?>[7]);
      });

      testWidgets('settles nothing in a read-only field', (WidgetTester tester) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pump(
          tester,
          _Harness(value: 40, max: 12, readOnly: true, onCommitted: settled.add),
        );

        await tester.tap(find.byType(PlNumberField));
        await tester.pump();
        expect(_editorFocused(tester), isTrue);

        tester.binding.focusManager.primaryFocus!.unfocus();
        await tester.pumpAndSettle();

        // A value outside the range is the caller's to hand a field that
        // cannot be changed, and leaving the field does not clamp it.
        expect(state.value, 40);
        expect(find.text('40'), findsOneWidget);
        expect(settled, isEmpty);
      });

      testWidgets('settles nothing in a field disabled while it holds the focus', (
        WidgetTester tester,
      ) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pump(
          tester,
          _Harness(max: 12, onCommitted: settled.add),
        );

        await tester.showKeyboard(find.byType(EditableText));
        tester.testTextInput.enterText('40');
        await tester.pump();

        await tester.pumpWidget(
          host(_Harness(max: 12, disabled: true, onCommitted: settled.add), width: 320),
        );
        await tester.pumpAndSettle();

        expect(_editorFocused(tester), isFalse);
        expect(state.value, 40);
        expect(settled, isEmpty);
      });

      testWidgets('settles once when Enter settles and takes the focus out', (
        WidgetTester tester,
      ) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pump(
          tester,
          _Harness(max: 12, onCommitted: settled.add),
        );

        await tester.showKeyboard(find.byType(EditableText));
        tester.testTextInput.enterText('40');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(_editorFocused(tester), isFalse);
        expect(state.value, 12);
        expect(settled, <double?>[12]);
      });

      testWidgets(
        'settles nothing when a press on an adornment takes the focus and gives it back',
        (WidgetTester tester) async {
          final List<double?> settled = <double?>[];
          await _pumpInApp(
            tester,
            _Harness(startIcon: const Text('qty'), onCommitted: settled.add),
          );

          await tester.tap(find.byType(EditableText), kind: PointerDeviceKind.mouse);
          await tester.pumpAndSettle();
          await tester.tap(find.text('qty'), kind: PointerDeviceKind.mouse);
          await tester.pumpAndSettle();

          expect(_editorFocused(tester), isTrue);
          expect(settled, isEmpty);
        },
      );

      testWidgets('settles a press on a stepper once, and not again on the way out', (
        WidgetTester tester,
      ) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pumpInApp(tester, _Harness(onCommitted: settled.add));

        await tester.tap(_plus(), kind: PointerDeviceKind.mouse);
        await tester.pumpAndSettle();
        expect(_editorFocused(tester), isTrue);

        tester.binding.focusManager.primaryFocus!.unfocus();
        await tester.pumpAndSettle();

        expect(state.value, 6);
        expect(settled, <double?>[6]);
      });

      testWidgets('settles a held stepper once, on its release and not again on the way out', (
        WidgetTester tester,
      ) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pumpInApp(
          tester,
          _Harness(value: 0, max: 3, onCommitted: settled.add),
        );

        final TestGesture press = await tester.startGesture(
          tester.getCenter(_plus()),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pump(const Duration(milliseconds: 1200));
        expect(settled, isEmpty);

        await press.up();
        await tester.pumpAndSettle();
        expect(_editorFocused(tester), isTrue);

        tester.binding.focusManager.primaryFocus!.unfocus();
        await tester.pumpAndSettle();

        expect(state.value, 3);
        expect(settled, <double?>[3]);
      });

      testWidgets('settles a held stepper the focus leaves before its release', (
        WidgetTester tester,
      ) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pumpInApp(
          tester,
          _Harness(value: 0, onCommitted: settled.add),
        );

        final TestGesture press = await tester.startGesture(
          tester.getCenter(_plus()),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pump(const Duration(milliseconds: 600));
        expect(state.value, greaterThan(0));

        // The repeats so far are changes nothing has settled yet.
        tester.binding.focusManager.primaryFocus!.unfocus();
        await tester.pump();

        expect(settled, <double?>[state.value]);

        // Let go, so the repeat stops.
        await press.up();
        await tester.pumpAndSettle();
      });
    });

    group('the interaction light', () {
      /// Whether the shell's bloom is lit: the first of the two layers of the
      /// light, and the shell is the one surface here that has one.
      bool bloomIsLit(WidgetTester tester) {
        return tester.widgetList<PlassGlowLayer>(find.byType(PlassGlowLayer)).first.visible;
      }

      /// A mouse left resting on the field's text, as a hand that has gone
      /// over to the keyboard leaves it.
      Future<TestGesture> rest(WidgetTester tester) async {
        final TestGesture pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);

        await pointer.addPointer(location: Offset.zero);
        addTearDown(pointer.removePointer);
        await pointer.moveTo(tester.getCenter(find.byType(EditableText)));
        await tester.pump();

        expect(bloomIsLit(tester), isTrue);

        return pointer;
      }

      /// [harness] under the keys a `WidgetsApp` gives a text field, focused
      /// before the pointer comes to rest on it.
      Future<TestGesture> focusAndRest(WidgetTester tester, _Harness harness) async {
        await tester.pumpWidget(host(DefaultTextEditingShortcuts(child: harness), width: 320));
        await tester.showKeyboard(find.byType(EditableText));
        await tester.pump();

        return rest(tester);
      }

      testWidgets('stays lit as Tab brings the focus in under a resting pointer', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        await tester.pumpWidget(host(afterFocusStop(before, const _Harness()), width: 320));
        before.requestFocus();
        await tester.pump();
        await rest(tester);

        // The editor puts its caret in as the focus arrives, which is not the
        // reader typing.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus, isTrue);
        expect(bloomIsLit(tester), isTrue);
      });

      testWidgets('stays lit as a stepper is pressed in the focused field', (
        WidgetTester tester,
      ) async {
        final TestGesture pointer = await focusAndRest(tester, const _Harness());
        final _HarnessState state = tester.state<_HarnessState>(find.byType(_Harness));

        await pointer.moveTo(tester.getCenter(_plus()));
        await tester.pump();
        await pointer.down(tester.getCenter(_plus()));
        await pointer.up();
        await tester.pumpAndSettle();

        // The value it writes in, and the value put back once the caller has
        // answered, are the field's own.
        expect(state.value, 6);
        expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus, isTrue);
        expect(bloomIsLit(tester), isTrue);
      });

      testWidgets('stays lit as the wheel steps the focused field', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(allowWheelScrub: true), width: 320));
        final _HarnessState state = tester.state<_HarnessState>(find.byType(_Harness));

        await tester.showKeyboard(find.byType(EditableText));
        await tester.pump();

        // A pointer of its own, since only a bare one can be turned as a wheel.
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

        await tester.sendEventToBinding(mouse.hover(tester.getCenter(find.byType(EditableText))));
        await tester.pump();
        expect(bloomIsLit(tester), isTrue);

        await tester.sendEventToBinding(mouse.scroll(const Offset(0, -40)));
        await tester.pumpAndSettle();

        expect(state.value, 6);
        expect(bloomIsLit(tester), isTrue);
      });

      testWidgets('goes out as a character is typed, and comes back as the pointer moves', (
        WidgetTester tester,
      ) async {
        final TestGesture pointer = await focusAndRest(tester, const _Harness());

        tester.testTextInput.enterText('50');
        await tester.pump();

        expect(bloomIsLit(tester), isFalse);

        await pointer.moveTo(tester.getCenter(find.byType(EditableText)) + const Offset(6, 0));
        await tester.pump();

        expect(bloomIsLit(tester), isTrue);
      });

      testWidgets('goes out as the caret is moved from the keyboard', (WidgetTester tester) async {
        await focusAndRest(tester, const _Harness(value: 50));

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();

        expect(
          tester.widget<EditableText>(find.byType(EditableText)).controller.selection,
          const TextSelection.collapsed(offset: 1),
        );
        expect(bloomIsLit(tester), isFalse);
      });

      testWidgets('goes out as a key steps the value or settles it', (WidgetTester tester) async {
        final TestGesture pointer = await focusAndRest(tester, const _Harness(max: 100));
        final _HarnessState state = tester.state<_HarnessState>(find.byType(_Harness));

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();

        expect(state.value, 6);
        expect(bloomIsLit(tester), isFalse);

        await pointer.moveTo(tester.getCenter(find.byType(EditableText)) + const Offset(6, 0));
        await tester.pump();
        expect(bloomIsLit(tester), isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump();

        expect(state.value, 100);
        expect(bloomIsLit(tester), isFalse);

        await pointer.moveTo(tester.getCenter(find.byType(EditableText)));
        await tester.pump();
        expect(bloomIsLit(tester), isTrue);

        // Enter settles a value the box already shows, and writes nothing.
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(bloomIsLit(tester), isFalse);
      });
    });

    group('accessibility', () {
      testWidgets('says a semanticLabel in place of its label rather than before it', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlNumberField(
              value: 5,
              semanticLabel: 'Number of guests',
              label: const Text('Guests'),
              onChanged: (double? _) {},
            ),
            width: 320,
          ),
        );

        expect(
          semanticsOf(tester, find.byType(PlNumberField)),
          isSemantics(isTextField: true, label: 'Number of guests', value: '5'),
        );

        handle.dispose();
      });

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

      testWidgets('is one node named by its label, with the steppers inside it', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        double? value = 5;

        Widget build({bool readOnly = false}) {
          return host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => PlNumberField(
                value: value,
                readOnly: readOnly,
                label: const Text('Guests'),
                onChanged: (double? next) => setState(() => value = next),
              ),
            ),
            width: 320,
          );
        }

        SemanticsNode field() => semanticsOf(tester, find.byType(PlNumberField));
        SemanticsNode editor() => tester.getSemantics(find.byType(EditableText));

        await tester.pumpWidget(build());

        // One text field node named by the label, rather than a nameless one
        // with the label as a separate line beside the editor. The editor's own
        // node, which says it is a text field and holds the text, was a second
        // node under the named one, which took no focus: a screen reader met
        // the name and the number as two stops.
        expect(field(), isSemantics(isTextField: true, label: 'Guests', value: '5'));
        expect(editor().id, field().id);
        expect(semanticsTextFields(tester), hasLength(1));

        final List<String> inside = <String>[];
        field().visitChildren((SemanticsNode child) {
          inside.add(child.label);
          return true;
        });

        expect(inside, <String>['Decrease', 'Increase']);

        // Typed into, it is still the one node, and says what the box holds.
        await tester.enterText(find.byType(EditableText), '12');
        await tester.pump();

        expect(editor().id, field().id);
        expect(
          field(),
          isSemantics(
            isTextField: true,
            isFocused: true,
            label: 'Guests',
            value: '12',
            hasSetTextAction: true,
          ),
        );

        // A read-only field too. Both nodes said read-only, which kept them
        // apart on its own.
        await tester.pumpWidget(build(readOnly: true));

        expect(editor().id, field().id);
        expect(semanticsTextFields(tester), hasLength(1));
        expect(field(), isSemantics(isTextField: true, isReadOnly: true, label: 'Guests'));

        handle.dispose();
      });

      testWidgets('is named by its placeholder only while nothing else names it', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        double? value;

        Widget field({String? semanticLabel}) => host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => PlNumberField(
              value: value,
              placeholder: 'Amount',
              semanticLabel: semanticLabel,
              onChanged: (double? next) => setState(() => value = next),
            ),
          ),
          width: 320,
        );

        SemanticsNode node() => semanticsOf(tester, find.byType(PlNumberField));
        Iterable<String> saying(String words) =>
            semanticsLabels(tester).where((String label) => label.contains(words));

        // Named by nothing else, the field takes the placeholder's words as its
        // name, and keeps them once it holds a number and the placeholder is
        // gone, as the React input does.
        await tester.pumpWidget(field());

        expect(node().label, 'Amount');
        expect(saying('Amount'), hasLength(1));

        await tester.enterText(find.byType(EditableText), '12');
        await tester.pump();

        expect(find.text('Amount'), findsNothing);
        expect(node().label, 'Amount');

        // A `semanticLabel` in the same words is read once.
        value = null;
        await tester.pumpWidget(field(semanticLabel: 'Amount'));
        await tester.enterText(find.byType(EditableText), '');
        await tester.pump();

        expect(find.text('Amount'), findsOneWidget);
        expect(node().label, 'Amount');
        expect(saying('Amount'), hasLength(1));

        handle.dispose();
      });

      testWidgets('reads what an adornment says on a node of its own, not in its name', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlNumberField(
              value: 5,
              semanticLabel: 'Weight',
              startIcon: const Text('≈'),
              endIcon: const Text('kg'),
              onChanged: (double? _) {},
            ),
            width: 320,
          ),
        );

        final SemanticsNode field = semanticsOf(tester, find.byType(PlNumberField));

        expect(field.label, 'Weight');

        for (final String words in <String>['≈', 'kg']) {
          final SemanticsNode? adornment = semanticsNodeLabelled(tester, words);

          expect(adornment, isNotNull, reason: words);
          expect(adornment!.id, isNot(field.id), reason: words);
          expect(adornment, isSemantics(label: words, isTextField: false), reason: words);
        }

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

      testWidgets('a screen reader presses a stepper, one step at a time', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pump(tester, _Harness(max: 6, onCommitted: settled.add));

        tester.semantics.tap(find.semantics.byLabel('Increase'));
        await tester.pumpAndSettle();

        // One step, settled as it is taken, and no focus brought in with it.
        expect(state.value, 6);
        expect(settled, <double?>[6]);
        expect(_editorFocused(tester), isFalse);

        // A stepper at the end of the range has nothing to press. The field's
        // own tap, which puts the caret in it, is not a stepper's.
        expect(
          semanticsLabelsWithAction(
            tester,
            SemanticsAction.tap,
          ).where(<String>{'Increase', 'Decrease'}.contains),
          <String>['Decrease'],
        );

        tester.semantics.tap(find.semantics.byLabel('Decrease'));
        await tester.pumpAndSettle();

        expect(state.value, 5);
        expect(settled, <double?>[6, 5]);

        handle.dispose();
      });

      testWidgets('a disabled field has no stepper to press', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, const _Harness(disabled: true));

        expect(find.bySemanticsLabel('Increase'), findsOneWidget);
        expect(semanticsLabelsWithAction(tester, SemanticsAction.tap), isEmpty);

        handle.dispose();
      });

      testWidgets('is passed by Tab while disabled, and reached by it otherwise', (
        WidgetTester tester,
      ) async {
        final before = FocusNode();
        addTearDown(before.dispose);

        Future<bool> tabbedIn({required bool disabled}) async {
          await tester.pumpWidget(
            host(
              afterFocusStop(
                before,
                PlNumberField(value: 5, disabled: disabled, onChanged: (double? _) {}),
              ),
              width: 320,
            ),
          );
          before.requestFocus();
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();

          return tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus;
        }

        expect(await tabbedIn(disabled: false), isTrue);
        expect(await tabbedIn(disabled: true), isFalse);
      });

      testWidgets('Tab goes from the number to the next control, past the steppers', (
        WidgetTester tester,
      ) async {
        final before = FocusNode();
        final after = FocusNode();
        addTearDown(before.dispose);
        addTearDown(after.dispose);

        for (final PlNumberFieldSteppers steppers in <PlNumberFieldSteppers>[
          PlNumberFieldSteppers.end,
          PlNumberFieldSteppers.split,
        ]) {
          await tester.pumpWidget(
            host(
              afterFocusStop(
                before,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    PlNumberField(value: 5, steppers: steppers, onChanged: (double? _) {}),
                    Focus(focusNode: after, child: const SizedBox.square(dimension: 1)),
                  ],
                ),
              ),
              width: 320,
            ),
          );
          before.requestFocus();
          await tester.pump();

          // As the React steppers are `tabIndex: -1`: the number is the one
          // stop, with a `split` stepper in front of it as well as after.
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();

          expect(_editorFocused(tester), isTrue, reason: '$steppers');

          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();

          expect(after.hasPrimaryFocus, isTrue, reason: '$steppers');
        }
      });

      testWidgets('a stepper takes no focus in either navigation mode', (
        WidgetTester tester,
      ) async {
        for (final NavigationMode mode in NavigationMode.values) {
          await tester.pumpWidget(
            host(
              MediaQuery(
                data: MediaQueryData(navigationMode: mode),
                child: PlNumberField(value: 5, onChanged: (double? _) {}),
              ),
              width: 320,
            ),
          );

          // A remote's arrows land only where a node can take the focus, and
          // no stepper can: the up and down keys belong to the number.
          for (final Finder stepper in <Finder>[_minus(), _plus()]) {
            final FocusNode node = Focus.of(tester.element(stepper));

            node.requestFocus();
            await tester.pump();

            expect(node.canRequestFocus, isFalse, reason: '$mode');
            expect(node.hasFocus, isFalse, reason: '$mode');
          }
        }
      });

      testWidgets('takes a screen reader s tap and focus, as a Material field does', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        final focus = FocusNode();
        addTearDown(focus.dispose);

        Widget build({bool readOnly = false, bool disabled = false}) => host(
          PlNumberField(
            value: 5,
            semanticLabel: 'Guests',
            focusNode: focus,
            readOnly: readOnly,
            disabled: disabled,
            onChanged: (double? _) {},
          ),
          width: 320,
        );

        SemanticsNode field() => semanticsOf(tester, find.byType(PlNumberField));

        Future<void> perform(SemanticsAction action) async {
          field().owner!.performAction(field().id, action);
          await tester.pump();
        }

        // Neither was on the node, so a screen reader on the web, which only
        // moves the focus onto the field's `<input>`, never put the caret in
        // the field, and TalkBack's double tap did nothing.
        await tester.pumpWidget(build());

        expect(field(), isSemantics(label: 'Guests', hasTapAction: true, hasFocusAction: true));

        await perform(SemanticsAction.focus);

        expect(focus.hasFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);

        // Focused with the keyboard put away, the field gets it back.
        await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
        await perform(SemanticsAction.focus);

        expect(tester.testTextInput.isVisible, isTrue);

        focus.unfocus();
        await tester.pump();
        await perform(SemanticsAction.tap);

        expect(focus.hasFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);

        // A read-only field takes the focus and no tap, and a disabled one
        // takes neither.
        focus.unfocus();
        await tester.pumpWidget(build(readOnly: true));

        expect(field(), isSemantics(label: 'Guests', hasTapAction: false, hasFocusAction: true));

        await perform(SemanticsAction.focus);

        expect(focus.hasFocus, isTrue);

        await tester.pumpWidget(build(disabled: true));
        await tester.pump();

        expect(field(), isSemantics(label: 'Guests', hasTapAction: false, hasFocusAction: false));

        handle.dispose();
      });

      testWidgets('is a text field while disabled, unavailable rather than read-only', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();

        // Read-only, the field was no text input to iOS or Android, which read
        // it as dimmed words rather than as a dimmed text field, as a browser
        // reads the React `<input disabled>`.
        await tester.pumpWidget(
          host(
            PlNumberField(
              value: 5,
              disabled: true,
              semanticLabel: 'Guests',
              onChanged: (double? _) {},
            ),
            width: 320,
          ),
        );

        expect(semanticsTextFields(tester), hasLength(1));
        expect(
          semanticsOf(tester, find.byType(PlNumberField)),
          isSemantics(
            isTextField: true,
            isReadOnly: false,
            hasEnabledState: true,
            isEnabled: false,
            label: 'Guests',
            value: '5',
          ),
        );

        handle.dispose();
      });

      testWidgets('takes no text while disabled, by any way in', (WidgetTester tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        final handle = tester.ensureSemantics();
        final name = TextEditingController();
        addTearDown(name.dispose);
        double? value = 5;

        Widget build({required bool disabled}) => host(
          AutofillGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                PlTextField(fullWidth: true, controller: name),
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) => PlNumberField(
                    value: value,
                    disabled: disabled,
                    semanticLabel: 'Guests',
                    onChanged: (double? next) => setState(() => value = next),
                  ),
                ),
              ],
            ),
          ),
          width: 320,
          overlay: true,
        );

        final Finder nameEditor = find.byType(EditableText).first;
        final Finder editor = find.descendant(
          of: find.byType(PlNumberField),
          matching: find.byType(EditableText),
        );

        // A pen put down on the field while it can be written in is offered it,
        // and one put down on it disabled is offered nothing.
        await tester.pumpWidget(build(disabled: false));

        expect(await scribble(tester, editor), 1);

        await tester.pumpWidget(build(disabled: true));
        await tester.pump();

        expect(tester.testTextInput.hasAnyClients, isFalse);
        expect(await scribble(tester, editor), 0);
        expect(tester.testTextInput.hasAnyClients, isFalse);

        // Autofill writes into every field of its group while one of them has
        // the keyboard, and reaches the field beside this one only.
        await tester.showKeyboard(nameEditor);
        await autofill(tester, <Finder, String>{nameEditor: 'Ada', editor: '12'});

        expect(name.text, 'Ada');
        expect(value, 5);
        expect(tester.widget<EditableText>(editor).controller.text, '5');

        // A screen reader finds nothing on it that writes text.
        final SemanticsData node = semanticsOf(
          tester,
          find.byType(PlNumberField),
        ).getSemanticsData();

        for (final SemanticsAction action in <SemanticsAction>[
          SemanticsAction.setText,
          SemanticsAction.paste,
          SemanticsAction.cut,
        ]) {
          expect(node.hasAction(action), isFalse, reason: action.name);
        }

        handle.dispose();
        debugDefaultTargetPlatformOverride = null;
      });
    });
    group('hotKeys', () {
      testWidgets('answers a chord pressed in the editor', (WidgetTester tester) async {
        var saved = 0;

        await tester.pumpWidget(
          host(
            PlNumberField(
              value: 1,
              onChanged: (double? _) {},
              autofocus: true,
              hotKeys: <String, VoidCallback>{'Escape': () => saved += 1},
            ),
            width: 300,
          ),
        );
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        expect(saved, 1);
      });
    });

    group('labelPlacement', () {
      testWidgets('puts the label in the field\'s own top edge', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlNumberField(
              value: 3,
              fullWidth: true,
              label: Text('Quantity'),
              labelPlacement: PlassFieldLabelPlacement.notch,
            ),
            width: 320,
          ),
        );

        final field = tester.getRect(find.byType(PlNumberField));

        expect(find.byType(PlassFieldNotch), findsOneWidget);
        expect(
          tester.getRect(find.text('Quantity')).center.dy,
          closeTo(field.top + notchRise(PlassSize.md), 0.5),
        );
      });
    });
  });
}
