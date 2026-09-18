import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// The marked runs, in the order they appear.
///
/// A mark is the one `Text` in the tree that sits inside a `DecoratedBox` — the
/// plain runs between them are spans of the outer paragraph rather than widgets
/// of their own.
List<String> marked(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.descendant(of: find.byType(DecoratedBox), matching: find.byType(Text)))
      .map((Text text) => text.data!)
      .toList();
}

void main() {
  group('PlHighlight', () {
    group('matching', () {
      testWidgets('marks the term it was given', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlHighlight('The quick brown fox', query: 'quick'), width: 400),
        );

        expect(marked(tester), <String>['quick']);
      });

      testWidgets('marks every occurrence', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlHighlight('one two one two', query: 'one'), width: 400),
        );

        expect(marked(tester), <String>['one', 'one']);
      });

      testWidgets('ignores case by default', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlHighlight('Quick and quick', query: 'quick'), width: 400),
        );

        expect(marked(tester), <String>['Quick', 'quick']);
      });

      testWidgets('respects case when asked to', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlHighlight('Quick and quick', query: 'quick', caseSensitive: true),
            width: 400,
          ),
        );

        expect(marked(tester), <String>['quick']);
      });

      testWidgets('tries the longest term first', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlHighlight('the database', query: <String>['data', 'database']), width: 400),
        );

        expect(marked(tester), <String>['database']);
      });

      testWidgets('marks whole words only when asked to', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlHighlight('cat concatenate', query: 'cat', wholeWord: true), width: 400),
        );

        expect(marked(tester), <String>['cat']);
      });

      testWidgets('takes a regular expression as written', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlHighlight('a1 b2 c3', query: RegExp(r'\d')), width: 400));

        expect(marked(tester), <String>['1', '2', '3']);
      });

      testWidgets('takes every term of a list as literal text', (WidgetTester tester) async {
        // The reason the list is `List<String>` rather than a list of patterns:
        // it is what a search box is wired to, and a reader typing `1 + 1` is
        // looking for `1 + 1` rather than writing a broken expression. A
        // pattern goes in on its own.
        await tester.pumpWidget(
          host(
            const PlHighlight(r'a+b and \d and a+b', query: <String>[r'a+b', r'\d']),
            width: 400,
          ),
        );

        expect(marked(tester), <String>[r'a+b', r'\d', r'a+b']);
      });

      test('refuses a list with a pattern in it', () {
        // The list is literal text, so a pattern in one has no way to mean what
        // it looks like it means — it used to be escaped and searched for as
        // the characters it is written with, marking nothing and saying
        // nothing. `query` is typed `Object` because Dart has no union, so the
        // constructor's assert is where the union is enforced.
        expect(
          () => PlHighlight('a1 b2', query: <RegExp>[RegExp(r'\d')]),
          throwsA(isA<AssertionError>()),
        );
      });

      testWidgets('tests wholeWord against a regular expression match too', (
        WidgetTester tester,
      ) async {
        // `caseSensitive` is the one the expression's own flags decide.
        // `wholeWord` is read off the text around the match, so it holds
        // however the match was found.
        await tester.pumpWidget(
          host(PlHighlight('cat concatenate', query: RegExp('cat'), wholeWord: true), width: 400),
        );

        expect(marked(tester), <String>['cat']);
      });

      testWidgets('leaves the text alone when there is nothing to look for', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlHighlight('untouched', query: ''), width: 400));

        expect(marked(tester), isEmpty);
        expect(find.byType(Text), findsOneWidget);
      });
    });

    group('the mark', () {
      testWidgets('is the family gradient with its own ink on it', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlHighlight('the quick fox', query: 'quick'), width: 400),
        );

        final family = PlassTokens.light().family(PlassColor.warning);
        final mark = tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .map((DecoratedBox box) => box.decoration as BoxDecoration)
            .firstWhere((BoxDecoration decoration) => decoration.gradient != null);

        expect((mark.gradient! as LinearGradient).colors.first, family.solid);
        expect(styleOf(tester, 'quick').color, family.onSolid);
      });

      testWidgets('a glass mark is a hairline box with a soft tint', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlHighlight('the quick fox', query: 'quick', variant: PlassVariant.glass),
            width: 400,
          ),
        );

        final family = PlassTokens.light().family(PlassColor.warning);
        final mark = tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .map((DecoratedBox box) => box.decoration as BoxDecoration)
            .firstWhere((BoxDecoration decoration) => decoration.border != null);

        expect(mark.color, family.soft);
        expect(styleOf(tester, 'quick').color, family.accent);
      });

      testWidgets('a ghost mark is the accent and no surface', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlHighlight('the quick fox', query: 'quick', variant: PlassVariant.ghost),
            width: 400,
          ),
        );

        final mark = tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .map((DecoratedBox box) => box.decoration as BoxDecoration)
            .first;

        expect(mark.color, isNull);
        expect(mark.gradient, isNull);
      });

      testWidgets('takes the weight of the text around it unless told otherwise', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlHighlight('the quick fox', query: 'quick'), width: 400),
        );

        expect(styleOf(tester, 'quick').fontWeight, isNull);
      });

      testWidgets('underlines under the descenders when asked', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlHighlight('the quick fox', query: 'quick', underline: true), width: 400),
        );

        expect(styleOf(tester, 'quick').decoration, TextDecoration.underline);
      });
    });

    group('text size', () {
      testWidgets('grows a mark with the reader\'s text size once, like the words around it', (
        WidgetTester tester,
      ) async {
        Future<double> heightAt(double scale) async {
          await tester.pumpWidget(
            host(
              MediaQuery.withClampedTextScaling(
                minScaleFactor: scale,
                maxScaleFactor: scale,
                child: const PlHighlight('the quick fox', query: 'quick'),
              ),
              width: 400,
            ),
          );

          return tester.getRect(find.text('quick')).height;
        }

        final double normal = await heightAt(1);

        expect(await heightAt(2), moreOrLessEquals(normal * 2, epsilon: 0.5));
      });
    });

    group('accessibility', () {
      testWidgets('reads as the whole string it started as', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const PlHighlight('The quick brown fox', query: 'quick'), width: 400),
        );

        expect(find.bySemanticsLabel('The quick brown fox'), findsOneWidget);
        handle.dispose();
      });
    });
  });
}
