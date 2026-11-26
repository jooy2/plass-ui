import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// The character drawn in each slot, empty ones included.
List<String> drawn(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.descendant(of: find.byType(PlOtpField), matching: find.byType(Text)))
      .map((Text text) => text.data ?? '')
      .toList();
}

/// What an input method has written while a composition is open: the whole
/// code, with the caret at the end of the part still being composed.
TextEditingValue composing(String text, int start, int end) {
  return TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: end),
    composing: TextRange(start: start, end: end),
  );
}

/// What it has written once nothing is being composed.
TextEditingValue committed(String text) {
  return TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );
}

/// What the Windows engine sends as a composition starts, before the input
/// method has written anything into it: the code as it was, with an empty
/// composition at the caret.
TextEditingValue compositionStarts(String text) {
  return TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
    composing: TextRange.collapsed(text.length),
  );
}

/// Sends [values] in turn, and checks that the row holds each one just as the
/// input method sent it.
Future<void> compose(
  WidgetTester tester,
  TextEditingController controller,
  List<TextEditingValue> values,
) async {
  for (final TextEditingValue value in values) {
    tester.testTextInput.updateEditingValue(value);
    await tester.pump();

    expect(controller.value, value, reason: 'the input method holds "${value.text}"');
  }
}

/// The last editing state the framework sent to the platform.
Map<String, dynamic> lastSent(WidgetTester tester) {
  final MethodCall call = tester.testTextInput.log.lastWhere(
    (MethodCall call) => call.method == 'TextInput.setEditingState',
  );

  return call.arguments as Map<String, dynamic>;
}

void main() {
  group('PlOtpField', () {
    group('the row', () {
      testWidgets('is six slots unless it is told otherwise', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlOtpField()));

        expect(drawn(tester).length, 6);
      });

      testWidgets('takes the length it was given', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlOtpField(length: 4)));

        expect(drawn(tester).length, 4);
      });

      testWidgets('refuses to be one box, which is a text field', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlOtpField(length: 1)));

        expect(drawn(tester).length, 2);
      });

      testWidgets('stops at twelve, where the row stops fitting a phone', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlOtpField(length: 40)));

        expect(drawn(tester).length, 12);
      });
    });

    group('the code', () {
      testWidgets('draws one character per slot', (WidgetTester tester) async {
        final TextEditingController controller = TextEditingController(text: '123');
        addTearDown(controller.dispose);

        await tester.pumpWidget(host(PlOtpField(length: 4, controller: controller)));

        expect(drawn(tester), <String>['1', '2', '3', '']);
      });

      testWidgets('reports every change', (WidgetTester tester) async {
        final TextEditingController controller = TextEditingController();
        addTearDown(controller.dispose);
        final List<String> seen = <String>[];

        await tester.pumpWidget(
          host(PlOtpField(length: 3, controller: controller, onChanged: seen.add)),
        );

        controller.text = '12';
        await tester.pump();

        expect(seen, <String>['12']);
      });

      testWidgets('fires once the last slot is filled', (WidgetTester tester) async {
        final TextEditingController controller = TextEditingController();
        addTearDown(controller.dispose);
        String? completed;

        await tester.pumpWidget(
          host(
            PlOtpField(
              length: 3,
              controller: controller,
              onCompleted: (String code) => completed = code,
            ),
          ),
        );

        controller.text = '12';
        await tester.pump();
        expect(completed, isNull);

        controller.text = '123';
        await tester.pump();
        expect(completed, '123');
      });

      // The slots are counted in characters, and a character can be more than
      // one UTF-16 code unit.
      for (final (String typed, List<String> completes, String why)
          in <(String, List<String>, String)>[
            ('1😀', <String>['1😀'], 'fires for a character outside the Basic Multilingual Plane'),
            ('é', <String>[], 'waits for the last slot past a character of two code points'),
          ]) {
        testWidgets(why, (WidgetTester tester) async {
          final TextEditingController controller = TextEditingController();
          addTearDown(controller.dispose);
          final List<String> completed = <String>[];

          await tester.pumpWidget(
            host(
              PlOtpField(
                length: 2,
                charset: PlOtpCharset.any,
                controller: controller,
                onCompleted: completed.add,
                autofocus: true,
              ),
            ),
          );
          await tester.pump();
          await tester.enterText(find.byType(EditableText), typed);

          expect(controller.text, typed);
          expect(completed, completes);
        });
      }

      testWidgets('does not fire again when the caret is only moved', (WidgetTester tester) async {
        final TextEditingController controller = TextEditingController(text: '123');
        addTearDown(controller.dispose);
        int fired = 0;

        await tester.pumpWidget(
          host(PlOtpField(length: 3, controller: controller, onCompleted: (String _) => fired++)),
        );

        controller.selection = const TextSelection.collapsed(offset: 1);
        await tester.pump();

        expect(fired, 0);
      });

      testWidgets('hides the characters when it is masked', (WidgetTester tester) async {
        final TextEditingController controller = TextEditingController(text: '12');
        addTearDown(controller.dispose);

        await tester.pumpWidget(host(PlOtpField(length: 2, mask: true, controller: controller)));

        expect(drawn(tester), <String>['•', '•']);
      });
    });

    group('charset', () {
      test('keeps digits and drops the rest by default', () {
        const PlOtpField field = PlOtpField();

        expect(field.charset, PlOtpCharset.numeric);
      });

      testWidgets('drops what it rejects and says which characters those were', (
        WidgetTester tester,
      ) async {
        final TextEditingController controller = TextEditingController();
        addTearDown(controller.dispose);
        final List<String> rejected = <String>[];

        await tester.pumpWidget(
          host(
            PlOtpField(
              length: 4,
              controller: controller,
              onRejected: rejected.add,
              autofocus: true,
            ),
          ),
        );
        await tester.pump();
        await tester.enterText(find.byType(EditableText), '1a2b');

        expect(controller.text, '12');
        expect(rejected, <String>['ab']);
      });

      testWidgets('takes letters once it is asked to', (WidgetTester tester) async {
        final TextEditingController controller = TextEditingController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          host(
            PlOtpField(
              length: 4,
              charset: PlOtpCharset.alpha,
              controller: controller,
              autofocus: true,
            ),
          ),
        );
        await tester.pump();
        await tester.enterText(find.byType(EditableText), 'ab1c');

        expect(controller.text, 'abc');
      });

      testWidgets('takes anything at all when it is told to', (WidgetTester tester) async {
        final TextEditingController controller = TextEditingController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          host(
            PlOtpField(
              length: 4,
              charset: PlOtpCharset.any,
              controller: controller,
              autofocus: true,
            ),
          ),
        );
        await tester.pump();
        await tester.enterText(find.byType(EditableText), 'a-1?');

        expect(controller.text, 'a-1?');
      });

      testWidgets('never takes more characters than there are slots', (WidgetTester tester) async {
        final TextEditingController controller = TextEditingController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          host(PlOtpField(length: 3, controller: controller, autofocus: true)),
        );
        await tester.pump();
        await tester.enterText(find.byType(EditableText), '123456');

        expect(controller.text, '123');
      });
    });

    // In the order the Windows engine sends them: an empty composition as one
    // starts, and then the whole code with the part being composed marked.
    group('while an input method composes', () {
      testWidgets('with charset any, takes a reading longer than the slots left until it ends', (
        WidgetTester tester,
      ) async {
        // Held to the slots, the row would turn zho away while the input method
        // went on composing it, though 中国 fits in the two slots left.
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;

        try {
          final TextEditingController controller = TextEditingController();
          addTearDown(controller.dispose);
          final List<String> changes = <String>[];

          await tester.pumpWidget(
            host(
              PlOtpField(
                length: 4,
                charset: PlOtpCharset.any,
                controller: controller,
                onChanged: changes.add,
                autofocus: true,
              ),
            ),
          );
          await tester.pump();
          await tester.enterText(find.byType(EditableText), '12');

          const String reading = 'zhongguo';

          await compose(tester, controller, <TextEditingValue>[
            compositionStarts('12'),
            for (int typed = 1; typed <= reading.length; typed++)
              composing('12${reading.substring(0, typed)}', 2, 2 + typed),
            composing('12中国', 2, 4),
            committed('12中国'),
          ]);

          expect(changes.last, '12中国');
          expect(drawn(tester), <String>['1', '2', '中', '国']);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });

      testWidgets('with digits, drops a syllable and leaves nothing being composed', (
        WidgetTester tester,
      ) async {
        // Why the other charsets keep the platform's own limit: what an input
        // method composes never gets past the charset, and the row is sent back
        // with no composition for the next syllable to be written into.
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;

        try {
          final TextEditingController controller = TextEditingController();
          addTearDown(controller.dispose);
          final List<String> rejected = <String>[];

          await tester.pumpWidget(
            host(
              PlOtpField(
                length: 2,
                controller: controller,
                onRejected: rejected.add,
                autofocus: true,
              ),
            ),
          );
          await tester.pump();
          await tester.enterText(find.byType(EditableText), '12');
          tester.testTextInput.log.clear();

          tester.testTextInput.updateEditingValue(composing('12ㅁ', 2, 3));
          await tester.pump();

          expect(controller.value, committed('12'));
          expect(rejected, <String>['ㅁ']);
          expect(
            lastSent(tester),
            allOf(
              containsPair('text', '12'),
              containsPair('composingBase', -1),
              containsPair('composingExtent', -1),
            ),
          );
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    });

    // The ring stays on the last slot once every slot is filled, and the React
    // field's last slot takes a key then.
    group('a full row', () {
      Future<TextEditingController> pumpFull(
        WidgetTester tester, {
        ValueChanged<String>? onCompleted,
        ValueChanged<String>? onRejected,
      }) async {
        final TextEditingController controller = TextEditingController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          host(
            PlOtpField(
              length: 4,
              controller: controller,
              onCompleted: onCompleted,
              onRejected: onRejected,
              autofocus: true,
            ),
          ),
        );
        await tester.pump();
        await tester.enterText(find.byType(EditableText), '1234');

        return controller;
      }

      testWidgets('puts a key pressed in it in the last slot, and completes again', (
        WidgetTester tester,
      ) async {
        final List<String> completed = <String>[];
        final TextEditingController controller = await pumpFull(tester, onCompleted: completed.add);

        await tester.enterText(find.byType(EditableText), '12345');

        expect(controller.value, committed('1235'));
        expect(completed, <String>['1234', '1235']);
      });

      testWidgets('puts the first character of a paste in the last slot', (
        WidgetTester tester,
      ) async {
        final TextEditingController controller = await pumpFull(tester);

        await tester.enterText(find.byType(EditableText), '123456');

        expect(controller.value, committed('1235'));
      });

      testWidgets('keeps its last slot when the charset refuses the key', (
        WidgetTester tester,
      ) async {
        final List<String> rejected = <String>[];
        final TextEditingController controller = await pumpFull(tester, onRejected: rejected.add);

        await tester.enterText(find.byType(EditableText), '1234a');

        expect(controller.value, committed('1234'));
        expect(rejected, <String>['a']);
      });

      for (final (TargetPlatform platform, String name) in <(TargetPlatform, String)>[
        (TargetPlatform.windows, 'Windows'),
        (TargetPlatform.macOS, 'macOS'),
      ]) {
        testWidgets('on $name, composes a syllable started in it in the last slot', (
          WidgetTester tester,
        ) async {
          // The platform is told the composition now covers the last slot, so
          // the input method's next update is written there. Windows finishes
          // 글 and starts ㅁ in one update; macOS finishes each syllable on its
          // own first.
          debugDefaultTargetPlatformOverride = platform;

          try {
            final bool windows = platform == TargetPlatform.windows;
            final TextEditingController controller = TextEditingController();
            addTearDown(controller.dispose);

            await tester.pumpWidget(
              host(
                PlOtpField(
                  length: 2,
                  charset: PlOtpCharset.any,
                  controller: controller,
                  autofocus: true,
                ),
              ),
            );
            await tester.pump();

            await compose(tester, controller, <TextEditingValue>[
              if (windows) compositionStarts(''),
              composing('한', 0, 1),
              if (!windows) committed('한'),
              composing('한글', 1, 2),
              if (!windows) committed('한글'),
            ]);

            tester.testTextInput.log.clear();
            tester.testTextInput.updateEditingValue(composing('한글ㅁ', 2, 3));
            await tester.pump();

            expect(controller.value, composing('한ㅁ', 1, 2));
            expect(
              lastSent(tester),
              allOf(
                containsPair('text', '한ㅁ'),
                containsPair('composingBase', 1),
                containsPair('composingExtent', 2),
              ),
            );

            await compose(tester, controller, <TextEditingValue>[
              composing('한마', 1, 2),
              committed('한마'),
            ]);

            expect(drawn(tester), <String>['한', '마']);
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        });
      }
    });

    group('the separator', () {
      testWidgets('draws nothing unless a group size is given', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlOtpField(length: 6)));

        expect(drawn(tester).where((String mark) => mark == '–'), isEmpty);
      });

      testWidgets('splits the row every group', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlOtpField(length: 6, groupSize: 3)));

        expect(drawn(tester).where((String mark) => mark == '–').length, 1);
      });

      testWidgets('draws whatever it was handed', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlOtpField(length: 4, groupSize: 2, separator: '·')));

        expect(drawn(tester).where((String mark) => mark == '·').length, 1);
      });

      testWidgets('never puts one at either end', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlOtpField(length: 4, groupSize: 4)));

        expect(drawn(tester).where((String mark) => mark == '–'), isEmpty);
      });
    });

    group('the field', () {
      testWidgets('names the row with its label', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlOtpField(label: Text('Verification code'))));

        expect(find.text('Verification code'), findsOneWidget);
      });

      testWidgets('shows a description under it', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlOtpField(description: Text('We texted it to you.'))));

        expect(find.text('We texted it to you.'), findsOneWidget);
      });

      testWidgets('shows an error under it', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlOtpField(error: Text('That code has expired.'))));

        expect(find.text('That code has expired.'), findsOneWidget);
      });
    });

    group('states', () {
      testWidgets('stops answering when it is disabled', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlOtpField(length: 3, disabled: true)));

        await tester.tap(find.byType(PlOtpField));
        await tester.pump();

        expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus, isFalse);
      });

      testWidgets('is passed by Tab while disabled, and reached by it otherwise', (
        WidgetTester tester,
      ) async {
        final before = FocusNode();
        addTearDown(before.dispose);

        Future<bool> tabbedIn({required bool disabled}) async {
          await tester.pumpWidget(
            host(afterFocusStop(before, PlOtpField(length: 3, disabled: disabled))),
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

      testWidgets('takes focus on a press otherwise', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlOtpField(length: 3)));

        await tester.tap(find.byType(PlOtpField));
        await tester.pump();

        expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus, isTrue);
      });

      testWidgets('takes focus from a screen reader too', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlOtpField(length: 3, semanticLabel: 'Code')));

        tester.semantics.tap(find.semantics.byLabel('Code'));
        await tester.pump();

        expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus, isTrue);
        expect(
          tester.getSemantics(find.byType(PlOtpField)),
          isSemantics(isTextField: true, isFocused: true),
        );
      });

      testWidgets('puts the caret at the first empty slot on a press', (WidgetTester tester) async {
        final TextEditingController controller = TextEditingController(text: '12');
        addTearDown(controller.dispose);

        await tester.pumpWidget(host(PlOtpField(length: 6, controller: controller)));

        await tester.tap(find.byType(PlOtpField));
        await tester.pump();

        expect(controller.selection.baseOffset, 2);
      });

      testWidgets('brings the keyboard back as the row is pressed', (WidgetTester tester) async {
        final TextEditingController controller = TextEditingController(text: '12');
        final FocusNode focus = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);

        Widget build({bool readOnly = false}) => host(
          PlOtpField(length: 6, controller: controller, focusNode: focus, readOnly: readOnly),
        );

        await tester.pumpWidget(build());
        await tester.tap(find.byType(PlOtpField));
        await tester.pump();

        expect(focus.hasFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);

        // The keyboard put away under the focus, as Android's back does. The
        // editor takes no press, so the row's press is the only way back to it.
        await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
        expect(tester.testTextInput.isVisible, isFalse);

        await tester.tap(find.byType(PlOtpField));
        await tester.pump();

        expect(tester.testTextInput.isVisible, isTrue);
        expect(controller.selection, const TextSelection.collapsed(offset: 2));

        // A read-only row takes the focus and opens no keyboard.
        focus.unfocus();
        await tester.pumpWidget(build(readOnly: true));
        await tester.tap(find.byType(PlOtpField));
        await tester.pump();

        expect(focus.hasFocus, isTrue);
        expect(tester.testTextInput.hasAnyClients, isFalse);
      });

      testWidgets('stays readable but not typeable when it is read-only', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlOtpField(length: 3, readOnly: true)));

        expect(tester.widget<EditableText>(find.byType(EditableText)).readOnly, isTrue);
      });
    });

    group('accessibility', () {
      testWidgets('offers the code to the phone that texted it', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlOtpField(length: 4)));

        expect(
          tester.widget<EditableText>(find.byType(EditableText)).autofillHints,
          contains(AutofillHints.oneTimeCode),
        );
      });

      testWidgets('reads the code back rather than the boxes', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        final TextEditingController controller = TextEditingController(text: '12');
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          host(PlOtpField(length: 4, controller: controller, semanticLabel: 'Verification code')),
        );

        expect(find.bySemanticsLabel('Verification code'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('says a semanticLabel in place of its label rather than before it', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            const PlOtpField(
              length: 4,
              semanticLabel: 'Verification code',
              label: Text('Enter the code'),
            ),
          ),
        );

        expect(semanticsLabels(tester), <String>['Verification code']);

        handle.dispose();
      });

      testWidgets('takes a screen reader s focus, with the caret at the first empty slot', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        final TextEditingController controller = TextEditingController(text: '12');
        final FocusNode focus = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);

        Widget build({bool disabled = false}) => host(
          PlOtpField(
            length: 6,
            controller: controller,
            focusNode: focus,
            disabled: disabled,
            semanticLabel: 'Verification code',
          ),
        );

        SemanticsNode field() => tester.getSemantics(find.byType(PlOtpField));

        Future<void> perform(SemanticsAction action) async {
          field().owner!.performAction(field().id, action);
          await tester.pump();
        }

        // A screen reader on the web only moves the focus onto the field's
        // `<input>`, which nothing on the node answered, so it never put the
        // caret in the row.
        await tester.pumpWidget(build());

        expect(
          field(),
          isSemantics(label: 'Verification code', hasTapAction: true, hasFocusAction: true),
        );

        controller.selection = const TextSelection.collapsed(offset: 0);
        await perform(SemanticsAction.focus);

        expect(focus.hasFocus, isTrue);
        expect(controller.selection, const TextSelection.collapsed(offset: 2));
        expect(tester.testTextInput.isVisible, isTrue);

        // Focused with the keyboard put away, the row gets it back.
        await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
        await perform(SemanticsAction.focus);

        expect(tester.testTextInput.isVisible, isTrue);

        // A disabled row takes neither.
        await tester.pumpWidget(build(disabled: true));
        await tester.pump();

        expect(
          field(),
          isSemantics(label: 'Verification code', hasTapAction: false, hasFocusAction: false),
        );

        handle.dispose();
      });
    });
    group('hotKeys', () {
      testWidgets('answers a chord pressed in the row', (WidgetTester tester) async {
        var resent = 0;

        await tester.pumpWidget(
          host(
            PlOtpField(
              autofocus: true,
              hotKeys: <String, VoidCallback>{'Escape': () => resent += 1},
            ),
          ),
        );
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        expect(resent, 1);
      });
    });
  });
}
