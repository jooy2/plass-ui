// Whether the arrow keys can take the focus off a field built on an
// `EditableText` under `NavigationMode.directional`, where they are the only
// way from one control to the next, and leave the caret alone to do so only
// there.
//
// Each field sits between four stops, one on every side, under the keys a
// `WidgetsApp` gives: the caret keys a text field answers, and the arrows that
// move the focus between controls.
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/host.dart';

/// The stops round the field, one on each side.
class _Stops {
  final FocusNode above = FocusNode(debugLabel: 'above');
  final FocusNode below = FocusNode(debugLabel: 'below');
  final FocusNode before = FocusNode(debugLabel: 'left');
  final FocusNode after = FocusNode(debugLabel: 'right');

  void dispose() {
    above.dispose();
    below.dispose();
    before.dispose();
    after.dispose();
  }

  /// Which stop holds the focus, or `null` while none does.
  String? get focused {
    for (final FocusNode node in <FocusNode>[above, below, before, after]) {
      if (node.hasPrimaryFocus) {
        return node.debugLabel;
      }
    }

    return null;
  }
}

Widget _stop(FocusNode node) {
  return Focus(focusNode: node, child: const SizedBox.square(dimension: 8));
}

/// Pumps [field] between the four stops under [mode], and puts the focus in
/// its editor.
Future<_Stops> _pump(WidgetTester tester, NavigationMode mode, Widget field) async {
  final _Stops stops = _Stops();
  addTearDown(stops.dispose);

  await tester.pumpWidget(
    host(
      inNavigationMode(
        mode,
        // In the order a `WidgetsApp` puts them in: the caret keys nearer the
        // field than the keys that move the focus.
        Shortcuts(
          shortcuts: WidgetsApp.defaultShortcuts,
          child: DefaultTextEditingShortcuts(
            child: Actions(
              actions: WidgetsApp.defaultActions,
              child: FocusScope(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _stop(stops.above),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _stop(stops.before),
                        SizedBox(width: 280, child: field),
                        _stop(stops.after),
                      ],
                    ),
                    _stop(stops.below),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      width: 400,
      height: 500,
      overlay: true,
    ),
  );
  await tester.pumpAndSettle();
  await _focusEditor(tester);

  return stops;
}

/// Puts the focus back in the field's editor, as a reader who came to it
/// fresh would have it.
///
/// The focus system remembers the way the arrows last took the focus, and an
/// arrow back the other way returns to where they took it from. Forgotten
/// here, so each arrow is asked about on its own.
Future<void> _focusEditor(WidgetTester tester) async {
  final FocusNode node = tester.widget<EditableText>(find.byType(EditableText)).focusNode;

  node.requestFocus();
  await tester.pumpAndSettle();
  FocusTraversalGroup.of(node.context!).invalidateScopeData(node.nearestScope!);
}

/// Places the caret at [offset] in the field's text.
Future<void> _caret(WidgetTester tester, int offset) async {
  tester.widget<EditableText>(find.byType(EditableText)).controller.selection =
      TextSelection.collapsed(offset: offset);
  await tester.pump();
}

bool _inEditor(WidgetTester tester) {
  return tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasPrimaryFocus;
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

void main() {
  for (final NavigationMode mode in NavigationMode.values) {
    final bool directional = mode == NavigationMode.directional;

    group('a field of one line, ${mode.name}', () {
      testWidgets('PlTextField', (WidgetTester tester) async {
        final TextEditingController text = TextEditingController(text: 'Ada');
        addTearDown(text.dispose);

        final _Stops stops = await _pump(
          tester,
          mode,
          PlTextField(controller: text, label: const Text('Name')),
        );

        // Up and down leave a field of one line.
        for (final (LogicalKeyboardKey key, String stop) in <(LogicalKeyboardKey, String)>[
          (LogicalKeyboardKey.arrowUp, 'above'),
          (LogicalKeyboardKey.arrowDown, 'below'),
        ]) {
          await _focusEditor(tester);
          await _press(tester, key);

          expect(stops.focused, directional ? stop : isNull, reason: key.keyLabel);
          expect(_inEditor(tester), !directional, reason: key.keyLabel);
        }

        // Left and right move the caret, and leave only past the end they
        // point at.
        await _focusEditor(tester);
        await _caret(tester, 3);
        await _press(tester, LogicalKeyboardKey.arrowLeft);

        expect(_inEditor(tester), isTrue);
        expect(text.selection, const TextSelection.collapsed(offset: 2));

        await _caret(tester, 3);
        await _press(tester, LogicalKeyboardKey.arrowRight);

        expect(stops.focused, directional ? 'right' : isNull);

        await _focusEditor(tester);
        await _caret(tester, 0);
        await _press(tester, LogicalKeyboardKey.arrowLeft);

        expect(stops.focused, directional ? 'left' : isNull);
      });

      testWidgets('PlCombobox, left and right', (WidgetTester tester) async {
        final _Stops stops = await _pump(
          tester,
          mode,
          PlCombobox<String>(
            options: const <PlComboboxOption<String>>[
              PlComboboxOption<String>(value: 'seoul', label: 'Seoul'),
            ],
            value: 'seoul',
            onChanged: (String? next) {},
          ),
        );

        await _caret(tester, 0);
        await _press(tester, LogicalKeyboardKey.arrowLeft);

        expect(stops.focused, directional ? 'left' : isNull);

        await _focusEditor(tester);
        await _caret(tester, 'Seoul'.length);
        await _press(tester, LogicalKeyboardKey.arrowRight);

        expect(stops.focused, directional ? 'right' : isNull);
      });

      testWidgets('PlOtpField', (WidgetTester tester) async {
        final _Stops stops = await _pump(
          tester,
          mode,
          PlOtpField(length: 4, onChanged: (String _) {}),
        );

        await _press(tester, LogicalKeyboardKey.arrowDown);

        expect(stops.focused, directional ? 'below' : isNull);
      });
    });

    testWidgets('a field of several lines keeps up and down, ${mode.name}', (
      WidgetTester tester,
    ) async {
      final TextEditingController text = TextEditingController(text: 'One\nTwo');
      addTearDown(text.dispose);

      final _Stops stops = await _pump(
        tester,
        mode,
        PlTextField(controller: text, multiline: true, label: const Text('Notes')),
      );

      await _caret(tester, 0);
      await _press(tester, LogicalKeyboardKey.arrowDown);

      // Between the lines, as it always did.
      expect(stops.focused, isNull);
      expect(_inEditor(tester), isTrue);
    });

    testWidgets('PlNumberField steps with up and down, and leaves at an end, ${mode.name}', (
      WidgetTester tester,
    ) async {
      double? value = 9;

      final _Stops stops = await _pump(
        tester,
        mode,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => PlNumberField(
            value: value,
            max: 10,
            label: const Text('Seats'),
            onChanged: (double? next) => setState(() => value = next),
          ),
        ),
      );

      await _press(tester, LogicalKeyboardKey.arrowUp);

      expect(value, 10);
      expect(_inEditor(tester), isTrue);

      // At the top of the range there is nothing left to step.
      await _press(tester, LogicalKeyboardKey.arrowUp);

      expect(value, 10);
      expect(stops.focused, directional ? 'above' : isNull);

      // Left and right leave at either end of the number.
      await _focusEditor(tester);
      await _caret(tester, 0);
      await _press(tester, LogicalKeyboardKey.arrowLeft);

      expect(stops.focused, directional ? 'left' : isNull);
    });
  }
}
