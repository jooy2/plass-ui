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

      testWidgets('takes focus on a press otherwise', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlOtpField(length: 3)));

        await tester.tap(find.byType(PlOtpField));
        await tester.pump();

        expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus, isTrue);
      });

      testWidgets('puts the caret at the first empty slot on a press', (WidgetTester tester) async {
        final TextEditingController controller = TextEditingController(text: '12');
        addTearDown(controller.dispose);

        await tester.pumpWidget(host(PlOtpField(length: 6, controller: controller)));

        await tester.tap(find.byType(PlOtpField));
        await tester.pump();

        expect(controller.selection.baseOffset, 2);
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
