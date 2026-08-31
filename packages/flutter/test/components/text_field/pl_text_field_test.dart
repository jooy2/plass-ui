import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// The shell: the box with the field's own radius on it.
BoxDecoration shellOf(WidgetTester tester) {
  return decorationsOf(tester, find.byType(PlTextField)).firstWhere(
    (BoxDecoration decoration) => decoration.borderRadius != null && decoration.boxShadow == null,
  );
}

void main() {
  group('PlTextField', () {
    group('rendering', () {
      testWidgets('is a control-height field', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlTextField(fullWidth: true, size: PlassSize.lg), width: 300),
        );

        expect(tester.getSize(find.byType(PlTextField)).height, 48);
      });

      testWidgets('a one-row multiline field is as tall as a single-line one', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlTextField(fullWidth: true), width: 300));
        final single = tester.getSize(find.byType(PlTextField)).height;

        await tester.pumpWidget(
          host(const PlTextField(fullWidth: true, multiline: true, rows: 1), width: 300),
        );

        expect(tester.getSize(find.byType(PlTextField)).height, single);
      });

      testWidgets('draws its label, description and error', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlTextField(
              fullWidth: true,
              label: Text('Email'),
              description: Text('We only use it to sign you in.'),
              error: Text('That is not an email address.'),
            ),
            width: 320,
          ),
        );

        expect(find.text('Email'), findsOneWidget);
        expect(
          styleOf(tester, 'We only use it to sign you in.').color,
          PlassTokens.light().mutedFg,
        );
        expect(
          styleOf(tester, 'That is not an email address.').color,
          PlassTokens.light().family(PlassColor.danger).accent,
        );
      });

      testWidgets('shows a placeholder only while it is empty', (WidgetTester tester) async {
        final controller = TextEditingController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          host(
            PlTextField(fullWidth: true, controller: controller, placeholder: 'you@example.com'),
            width: 320,
          ),
        );
        expect(find.text('you@example.com'), findsOneWidget);

        controller.text = 'ada@example.com';
        await tester.pump();

        expect(find.text('you@example.com'), findsNothing);
      });
    });

    group('the shell', () {
      testWidgets('is the well when it is solid', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlTextField(fullWidth: true, variant: PlassVariant.solid), width: 300),
        );

        final tokens = PlassTokens.light();

        expect(shellOf(tester).color, tokens.glassPress);
        // A gradient under a caret is not legible, so a solid field is not one.
        expect(shellOf(tester).gradient, isNull);
      });

      testWidgets('takes the neutral hairline rather than the sheet white', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlTextField(fullWidth: true), width: 300));

        expect((shellOf(tester).border! as Border).top.color, PlassTokens.light().border);
      });
    });

    group('typing', () {
      testWidgets('reports what was typed', (WidgetTester tester) async {
        var typed = '';
        await tester.pumpWidget(
          host(PlTextField(fullWidth: true, onChanged: (String next) => typed = next), width: 300),
        );

        await tester.tap(find.byType(PlTextField));
        await tester.pump();
        await tester.enterText(find.byType(EditableText), 'ada');

        expect(typed, 'ada');
      });

      testWidgets('does not take text while disabled', (WidgetTester tester) async {
        final controller = TextEditingController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          host(PlTextField(fullWidth: true, controller: controller, disabled: true), width: 300),
        );

        expect(tester.widget<EditableText>(find.byType(EditableText)).readOnly, isTrue);
      });
    });

    group('error', () {
      testWidgets('turns the whole field over to danger', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlTextField(fullWidth: true, error: Text('Required')), width: 300),
        );

        expect(
          tester.widget<EditableText>(find.byType(EditableText)).cursorColor,
          PlassTokens.light().family(PlassColor.danger).accent,
        );
      });
    });

    group('loading', () {
      testWidgets('shows a spinner and still takes text', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlTextField(fullWidth: true, loading: true), width: 300),
        );

        expect(find.byType(CustomPaint), findsWidgets);
        expect(tester.widget<EditableText>(find.byType(EditableText)).readOnly, isFalse);

        // The spinner is the one thing in the library that moves on its own.
        await tester.pump(const Duration(milliseconds: 100));
      });
    });

    group('accessibility', () {
      testWidgets('is a text field to a screen reader', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const PlTextField(fullWidth: true, semanticLabel: 'Email'), width: 300),
        );

        expect(
          semanticsOf(tester, find.byType(PlTextField)),
          isSemantics(isTextField: true, label: 'Email'),
        );

        handle.dispose();
      });
    });
    group('hotKeys', () {
      /// A field with a chord map, under a listener that counts what got past it.
      ///
      /// The listener is how "consumed" is actually asserted: a chord the field
      /// answered must never reach anything above it, and a key it did not
      /// answer must.
      Future<void> pumpBound(
        WidgetTester tester,
        PlassHotKeys hotKeys, [
        List<LogicalKeyboardKey>? escaped,
      ]) async {
        await tester.pumpWidget(
          host(
            Focus(
              canRequestFocus: false,
              onKeyEvent: (FocusNode node, KeyEvent event) {
                if (event is KeyDownEvent) {
                  escaped?.add(event.logicalKey);
                }

                return KeyEventResult.ignored;
              },
              child: PlTextField(fullWidth: true, autofocus: true, hotKeys: hotKeys),
            ),
            width: 300,
          ),
        );
        await tester.pump();
      }

      testWidgets('runs a bare chord', (WidgetTester tester) async {
        var saved = 0;

        await pumpBound(tester, <String, VoidCallback>{'Enter': () => saved += 1});

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();

        expect(saved, 1);
      });

      testWidgets('reads the same spellings a key cap is written with', (
        WidgetTester tester,
      ) async {
        var cancelled = 0;

        await pumpBound(tester, <String, VoidCallback>{'Esc': () => cancelled += 1});

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        expect(cancelled, 1);
      });

      testWidgets('resolves Mod against the platform, the way the cap does', (
        WidgetTester tester,
      ) async {
        var saved = 0;

        Future<void> press(LogicalKeyboardKey modifier) async {
          await tester.sendKeyDownEvent(modifier);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.sendKeyUpEvent(modifier);
          await tester.pump();
        }

        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

        await pumpBound(tester, <String, VoidCallback>{'Mod+Enter': () => saved += 1});

        await press(LogicalKeyboardKey.metaLeft);
        expect(saved, 1, reason: 'Mod is ⌘ on a Mac');

        await press(LogicalKeyboardKey.controlLeft);
        expect(saved, 1, reason: 'and Ctrl is not');

        debugDefaultTargetPlatformOverride = TargetPlatform.windows;

        await press(LogicalKeyboardKey.controlLeft);
        expect(saved, 2, reason: 'Mod is Ctrl everywhere else');

        // Put back inside the body rather than in a tear-down: the binding
        // checks for a leaked debug variable before tear-downs run.
        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('does not mistake a chord for the bare key inside it', (
        WidgetTester tester,
      ) async {
        var saved = 0;
        var newline = 0;

        await pumpBound(tester, <String, VoidCallback>{
          'Enter': () => saved += 1,
          'Shift+Enter': () => newline += 1,
        });

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();

        expect(newline, 1);
        expect(saved, 0);
      });

      testWidgets('consumes the key it answered and lets every other one by', (
        WidgetTester tester,
      ) async {
        final escaped = <LogicalKeyboardKey>[];
        var cancelled = 0;

        await pumpBound(tester, <String, VoidCallback>{'Escape': () => cancelled += 1}, escaped);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);
        await tester.pump();

        expect(cancelled, 1);
        // The chord stopped at the field; the key nobody claimed carried on.
        expect(escaped, <LogicalKeyboardKey>[LogicalKeyboardKey.f2]);
      });
    });
  });
}
