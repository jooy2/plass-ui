import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

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
      allowWheelScrub: widget.allowWheelScrub,
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
