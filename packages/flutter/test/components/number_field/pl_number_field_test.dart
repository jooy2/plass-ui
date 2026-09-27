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

        // The next press, from the keyboard on the other stepper, is a step.
        Focus.of(tester.element(_minus())).requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
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

      testWidgets('settles a box that reads as another number, once', (WidgetTester tester) async {
        final List<double?> settled = <double?>[];
        final _HarnessState state = await _pump(
          tester,
          _Harness(value: 40, max: 12, onCommitted: settled.add),
        );

        await tester.showKeyboard(find.byType(EditableText));
        await tester.pump();
        tester.binding.focusManager.primaryFocus!.unfocus();
        await tester.pumpAndSettle();

        expect(state.value, 12);
        expect(settled, <double?>[12]);
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

      testWidgets('is named by its label, and holds the editor and the steppers', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlNumberField(value: 5, label: const Text('Guests'), onChanged: (double? _) {}),
            width: 320,
          ),
        );

        final SemanticsNode field = semanticsOf(tester, find.byType(PlNumberField));

        // One text field node named by the label, rather than a nameless one
        // with the label as a separate line beside the editor.
        expect(field, isSemantics(isTextField: true, label: 'Guests', value: '5'));

        final List<String> inside = <String>[];
        field.visitChildren((SemanticsNode child) {
          inside.add(child.label);
          return true;
        });

        expect(inside, <String>['', 'Decrease', 'Increase']);

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

        // A stepper at the end of the range has nothing to press.
        expect(semanticsLabelsWithAction(tester, SemanticsAction.tap), <String>['Decrease']);

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
