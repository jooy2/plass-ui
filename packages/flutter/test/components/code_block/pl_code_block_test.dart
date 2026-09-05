import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

const String code = 'const answer = 42;\nprint(answer);';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(host(child, width: 480));
  await tester.pumpAndSettle();
}

/// Every line the block drew, in order, as the text on it.
///
/// A line's code is one `Text.rich`, so the runs come back joined — which is
/// what a reader sees and is the only thing worth asserting about a line. It
/// takes every rich text under the block, so a caller of this passes
/// `toolbar: false` and neither numbers nor a prompt: those are rich text too.
List<String> _lines(WidgetTester tester) {
  return tester
      .widgetList<RichText>(
        find.descendant(of: find.byType(PlCodeBlock), matching: find.byType(RichText)),
      )
      .map((RichText text) => text.text.toPlainText())
      .toList();
}

void main() {
  group('PlCodeBlock', () {
    group('rendering', () {
      testWidgets('draws the code one line at a time', (WidgetTester tester) async {
        await _pump(tester, const PlCodeBlock(code: code, toolbar: false));

        expect(_lines(tester), <String>['const answer = 42;', 'print(answer);']);
      });

      testWidgets('trims the blank a raw string leaves behind', (WidgetTester tester) async {
        await _pump(tester, const PlCodeBlock(code: 'a\nb\n\n  ', toolbar: false));

        expect(_lines(tester), <String>['a', 'b']);
      });

      testWidgets('normalises a file written on Windows', (WidgetTester tester) async {
        await _pump(tester, const PlCodeBlock(code: 'a\r\nb', toolbar: false));

        expect(_lines(tester), <String>['a', 'b']);
      });

      testWidgets('keeps a blank line in the middle a line high', (WidgetTester tester) async {
        await _pump(tester, const PlCodeBlock(code: 'a\n\nb', toolbar: false));

        expect(_lines(tester).length, 3);
      });

      testWidgets('names itself after the language', (WidgetTester tester) async {
        await _pump(tester, const PlCodeBlock(code: code, language: 'dart', toolbar: false));

        expect(find.bySemanticsLabel('dart'), findsOneWidget);
      });

      testWidgets('falls back to the word for code', (WidgetTester tester) async {
        await _pump(tester, const PlCodeBlock(code: code, toolbar: false));

        expect(find.bySemanticsLabel('Code'), findsOneWidget);
      });
    });

    group('the palettes', () {
      testWidgets('paints its own ground rather than the page\'s', (WidgetTester tester) async {
        await _pump(tester, const PlCodeBlock(code: code, theme: 'dracula', toolbar: false));

        final BoxDecoration box = tester
            .widgetList<DecoratedBox>(
              find.descendant(of: find.byType(PlCodeBlock), matching: find.byType(DecoratedBox)),
            )
            .map((DecoratedBox node) => node.decoration as BoxDecoration)
            .firstWhere((BoxDecoration node) => node.color != null);

        expect(box.color, const Color(0xFF282A36));
      });

      testWidgets('takes a palette of the caller\'s own', (WidgetTester tester) async {
        const PlCodeTheme mine = PlCodeTheme(
          background: Color(0xFF102030),
          foreground: Color(0xFFEEEEEE),
          comment: Color(0xFF888888),
          keyword: Color(0xFFFF0000),
          string: Color(0xFF00FF00),
          number: Color(0xFF0000FF),
          function: Color(0xFFFFFF00),
          type: Color(0xFF00FFFF),
          variable: Color(0xFFFF00FF),
          tag: Color(0xFFFFFFFF),
          attribute: Color(0xFF999999),
          meta: Color(0xFF777777),
          addition: Color(0xFF00AA00),
          deletion: Color(0xFFAA0000),
        );

        await _pump(tester, const PlCodeBlock(code: code, customTheme: mine, toolbar: false));

        final BoxDecoration box = tester
            .widgetList<DecoratedBox>(
              find.descendant(of: find.byType(PlCodeBlock), matching: find.byType(DecoratedBox)),
            )
            .map((DecoratedBox node) => node.decoration as BoxDecoration)
            .firstWhere((BoxDecoration node) => node.color != null);

        expect(box.color, const Color(0xFF102030));
      });

      test('derives the five nobody declares', () {
        const PlCodeTheme dracula = PlCodeTheme(
          background: Color(0xFF282A36),
          foreground: Color(0xFFF8F8F2),
          comment: Color(0xFF6272A4),
          keyword: Color(0xFFFF79C6),
          string: Color(0xFFF1FA8C),
          number: Color(0xFFBD93F9),
          function: Color(0xFF50FA7B),
          type: Color(0xFF8BE9FD),
          variable: Color(0xFFF8F8F2),
          tag: Color(0xFFFF79C6),
          attribute: Color(0xFF50FA7B),
          meta: Color(0xFF6272A4),
          addition: Color(0xFF50FA7B),
          deletion: Color(0xFFFF5555),
        );

        // A mix of the ground and the ink, so every one of them follows
        // whichever theme won without being restated fourteen times.
        expect(dracula.dim, isNot(dracula.foreground));
        expect(dracula.dim, isNot(dracula.background));
        expect(dracula.rule.a, closeTo(0.14, 0.01));
        expect(dracula.mark.a, closeTo(0.10, 0.01));
        expect(dracula.markEdge.a, closeTo(0.45, 0.01));
      });

      test('falls back to the house dark set for a name nothing knows', () {
        final PlassTokens tokens = PlassTokens.light();

        expect(
          resolveCodeTheme('nonsense', tokens).background,
          resolveCodeTheme('dark', tokens).background,
        );
      });

      test('follows the page on auto and on mono', () {
        expect(
          resolveCodeTheme('auto', PlassTokens.dark()).background,
          resolveCodeTheme('dark', PlassTokens.light()).background,
        );
        expect(
          resolveCodeTheme('auto', PlassTokens.light()).background,
          resolveCodeTheme('light', PlassTokens.light()).background,
        );
        // `mono` is the one with no hue in it at all.
        final PlCodeTheme mono = resolveCodeTheme('mono', PlassTokens.light());

        expect(mono.keyword, mono.foreground);
        expect(mono.string, mono.comment);
        expect(mono.boldFor(PlCodeTokenKind.keyword), isTrue);
      });
    });

    group('the bar', () {
      testWidgets('names the language', (WidgetTester tester) async {
        await _pump(tester, const PlCodeBlock(code: code, language: 'dart'));

        expect(find.text('DART'), findsOneWidget);
      });

      testWidgets('drops the whole bar when it is turned off', (WidgetTester tester) async {
        await _pump(tester, const PlCodeBlock(code: code, language: 'dart', toolbar: false));

        expect(find.text('DART'), findsNothing);
        expect(find.bySemanticsLabel('Copy'), findsNothing);
      });

      testWidgets('offers the raw toggle only when there is colour to drop', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const PlCodeBlock(code: code, rawToggle: true));

        expect(find.bySemanticsLabel('Raw'), findsNothing);

        await _pump(
          tester,
          PlCodeBlock(
            code: code,
            rawToggle: true,
            lines: const <PlCodeLine>[
              <PlCodeToken>[PlCodeToken('const', PlCodeTokenKind.keyword)],
            ],
          ),
        );

        expect(find.bySemanticsLabel('Raw'), findsOneWidget);
      });

      testWidgets('drops the colouring while raw is pressed', (WidgetTester tester) async {
        await _pump(
          tester,
          PlCodeBlock(
            code: 'const a = 1;',
            rawToggle: true,
            lines: const <PlCodeLine>[
              <PlCodeToken>[PlCodeToken('const', PlCodeTokenKind.keyword), PlCodeToken(' a = 1;')],
            ],
          ),
        );

        await tester.tap(find.bySemanticsLabel('Raw'));
        await tester.pumpAndSettle();

        final RichText text = tester.widget<RichText>(
          find.descendant(of: find.byType(PlCodeBlock), matching: find.byType(RichText)).last,
        );
        final inks = <Color?>[];

        text.text.visitChildren((InlineSpan span) {
          if (span is TextSpan && span.text != null) {
            inks.add(span.style?.color);
          }

          return true;
        });

        // One run in one ink: the colouring is gone, not merely re-drawn.
        expect(text.text.toPlainText(), 'const a = 1;');
        expect(inks.toSet().length, 1);
      });
    });

    group('copying', () {
      testWidgets('puts the code on the clipboard and says so', (WidgetTester tester) async {
        String? written;

        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall call,
        ) async {
          if (call.method == 'Clipboard.setData') {
            written = (call.arguments as Map<Object?, Object?>)['text'] as String?;
          }

          return null;
        });
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );

        String? seen;

        await _pump(tester, PlCodeBlock(code: code, onCopy: (String value) => seen = value));

        await tester.tap(find.bySemanticsLabel('Copy'));
        await tester.pump();

        expect(written, 'const answer = 42;\nprint(answer);');
        expect(seen, 'const answer = 42;\nprint(answer);');
        expect(find.text('Copied'), findsOneWidget);

        await tester.pump(const Duration(seconds: 3));
      });

      testWidgets('offers no button when it is not copyable', (WidgetTester tester) async {
        await _pump(tester, const PlCodeBlock(code: code, copyable: false));

        expect(find.bySemanticsLabel('Copy'), findsNothing);
      });

      testWidgets('takes its own word for the button', (WidgetTester tester) async {
        await _pump(tester, const PlCodeBlock(code: code, copyLabel: 'Take it'));

        expect(find.text('Take it'), findsOneWidget);
      });
    });

    group('the gutter', () {
      testWidgets('numbers nothing by default', (WidgetTester tester) async {
        await _pump(tester, const PlCodeBlock(code: code, toolbar: false));

        expect(find.text('1'), findsNothing);
      });

      testWidgets('numbers the lines when it is asked', (WidgetTester tester) async {
        await _pump(tester, const PlCodeBlock(code: code, toolbar: false, lineNumbers: true));

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
      });

      testWidgets('starts where it was told to', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlCodeBlock(code: code, toolbar: false, lineNumbers: true, startLine: 286),
        );

        expect(find.text('286'), findsOneWidget);
        expect(find.text('287'), findsOneWidget);
      });
    });

    group('marked lines', () {
      test('reads one line, a range and a list', () {
        expect(parseLineSpec('2'), <int>{2});
        expect(parseLineSpec('2-4'), <int>{2, 3, 4});
        expect(parseLineSpec('1,3-4'), <int>{1, 3, 4});
      });

      test('reads a range written the wrong way round', () {
        expect(parseLineSpec('4-2'), <int>{2, 3, 4});
      });

      test('drops what it cannot read rather than throwing', () {
        expect(parseLineSpec('nonsense,2'), <int>{2});
        expect(parseLineSpec(null), isEmpty);
      });

      testWidgets('tints the line it was told to', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlCodeBlock(code: 'a\nb\nc', toolbar: false, highlightLines: '2'),
        );

        final List<Color?> grounds = tester
            .widgetList<Container>(
              find.descendant(of: find.byType(PlCodeBlock), matching: find.byType(Container)),
            )
            .map((Container node) => (node.decoration as BoxDecoration?)?.color)
            .toList();

        expect(grounds.where((Color? color) => color != null).length, 1);
      });
    });

    group('the prompt', () {
      testWidgets('puts one in front of every line that has something on it', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const PlCodeBlock(code: 'npm i\n\nnpm test', toolbar: false, prompt: r'$'),
        );

        expect(find.text(r'$'), findsNWidgets(2));
      });

      testWidgets('leaves it out of what the clipboard is given', (WidgetTester tester) async {
        String? written;

        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall call,
        ) async {
          if (call.method == 'Clipboard.setData') {
            written = (call.arguments as Map<Object?, Object?>)['text'] as String?;
          }

          return null;
        });
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );

        await _pump(tester, const PlCodeBlock(code: 'npm i', prompt: r'$'));

        await tester.tap(find.bySemanticsLabel('Copy'));
        await tester.pump();

        expect(written, 'npm i');

        await tester.pump(const Duration(seconds: 3));
      });
    });

    group('colouring', () {
      testWidgets('draws the runs it was handed', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlCodeBlock(
            code: 'const a = 1;',
            theme: 'dracula',
            toolbar: false,
            lines: <PlCodeLine>[
              <PlCodeToken>[
                PlCodeToken('const', PlCodeTokenKind.keyword),
                PlCodeToken(' a = '),
                PlCodeToken('1', PlCodeTokenKind.number),
                PlCodeToken(';'),
              ],
            ],
          ),
        );

        final RichText text = tester.widget<RichText>(
          find.descendant(of: find.byType(PlCodeBlock), matching: find.byType(RichText)).first,
        );
        final List<Color?> inks = <Color?>[];

        text.text.visitChildren((InlineSpan span) {
          if (span is TextSpan && span.text != null) {
            inks.add(span.style?.color);
          }

          return true;
        });

        expect(inks, <Color>[
          const Color(0xFFFF79C6),
          const Color(0xFFF8F8F2),
          const Color(0xFFBD93F9),
          const Color(0xFFF8F8F2),
        ]);
      });
    });
  });
}
