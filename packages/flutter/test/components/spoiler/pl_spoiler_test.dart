import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// The blur the cover is drawn with, or `null` while it is uncovered.
ui.ImageFilter? _blur(WidgetTester tester) {
  final Finder filtered = find.descendant(
    of: find.byType(PlSpoiler),
    matching: find.byType(ImageFiltered),
  );

  return filtered.evaluate().isEmpty
      ? null
      : tester.widget<ImageFiltered>(filtered.first).imageFilter;
}

void main() {
  group('PlSpoiler', () {
    group('the cover', () {
      testWidgets('blurs the content rather than removing it', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlSpoiler(child: Text('He was the killer all along.')), width: 360),
        );

        // A reader can see that there is something there, and roughly how much
        // of it. What they cannot do is read it by accident.
        expect(find.text('He was the killer all along.'), findsOneWidget);
        expect(_blur(tester), isNotNull);
      });

      testWidgets('says why the content is covered, and can be told to say nothing', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlSpoiler(child: Text('He was the killer all along.')), width: 360),
        );

        expect(find.text('This may contain spoilers'), findsOneWidget);

        await tester.pumpWidget(
          host(
            const PlSpoiler(description: null, child: Text('He was the killer all along.')),
            width: 360,
          ),
        );

        expect(find.text('This may contain spoilers'), findsNothing);
      });

      testWidgets('clamps a long cover and lets go on the way out', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlSpoiler(
              maxHeight: 160,
              child: SizedBox(height: 400, child: Text('He was the killer all along.')),
            ),
            width: 360,
          ),
        );

        expect(tester.getSize(find.byType(PlSpoiler)).height, lessThanOrEqualTo(160));

        await tester.pumpWidget(
          host(
            const PlSpoiler(
              revealed: true,
              maxHeight: 160,
              child: SizedBox(height: 400, child: Text('He was the killer all along.')),
            ),
            width: 360,
          ),
        );

        // Revealing something and leaving it in a box with a scrollbar is
        // answering the wrong question.
        expect(tester.getSize(find.byType(PlSpoiler)).height, greaterThan(160));
      });
    });

    group('revealing', () {
      testWidgets('uncovers on the button, on its own', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlSpoiler(child: Text('He was the killer all along.')), width: 360),
        );

        await tester.tap(find.text('Reveal'));
        await tester.pumpAndSettle();

        // The one widget in the package that is happy uncontrolled: what is
        // being remembered is a thing the reader did to this box.
        expect(_blur(tester), isNull);
        expect(find.text('Reveal'), findsNothing);
      });

      testWidgets('reports the change and stays where a controlled value put it', (
        WidgetTester tester,
      ) async {
        var reported = 0;

        await tester.pumpWidget(
          host(
            PlSpoiler(
              revealed: false,
              onRevealedChanged: (bool _) => reported += 1,
              child: const Text('He was the killer all along.'),
            ),
            width: 360,
          ),
        );

        await tester.tap(find.text('Reveal'));
        await tester.pumpAndSettle();

        expect(reported, 1);
        expect(_blur(tester), isNotNull);
      });

      testWidgets('offers a way back when it is reversible', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlSpoiler(
              revealed: true,
              reversible: true,
              child: Text('He was the killer all along.'),
            ),
            width: 360,
          ),
        );

        expect(find.text('Hide'), findsOneWidget);
      });

      testWidgets('takes a control of its own in place of the button', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlSpoiler(
              action: PlButton(onPressed: () {}, child: const Text('Show me')),
              child: const Text('He was the killer all along.'),
            ),
            width: 360,
          ),
        );

        expect(find.text('Show me'), findsOneWidget);
        expect(find.text('Reveal'), findsNothing);
      });
    });

    group('while it is covered', () {
      testWidgets('is off the semantics tree and out of the focus order', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(const PlSpoiler(child: Text('He was the killer all along.')), width: 360),
        );

        // A spoiler somebody can tab into is not a spoiler, and one a screen
        // reader reads out is not one either.
        expect(find.bySemanticsLabel('He was the killer all along.'), findsNothing);
        expect(
          find.ancestor(
            of: find.text('He was the killer all along.'),
            matching: find.byType(ExcludeFocus),
          ),
          findsOneWidget,
        );

        handle.dispose();
      });

      testWidgets('lets go of all three the moment it is revealed', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            const PlSpoiler(revealed: true, child: Text('He was the killer all along.')),
            width: 360,
          ),
        );

        expect(find.bySemanticsLabel('He was the killer all along.'), findsOneWidget);
        expect(
          find.ancestor(
            of: find.text('He was the killer all along.'),
            matching: find.byType(ExcludeFocus),
          ),
          findsNothing,
        );

        handle.dispose();
      });
    });

    group('the sheet', () {
      testWidgets('is at least as tall as its own cover', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlSpoiler(child: Text('.')), width: 360));

        // A one-character spoiler is as tall as the button it is asking somebody
        // to press, rather than clipping it: the cover's own text and button
        // count toward the sheet's size.
        expect(
          tester.getRect(find.text('Reveal')).bottom,
          lessThanOrEqualTo(tester.getRect(find.byType(PlSpoiler)).bottom),
        );
      });

      testWidgets('is the same height covered and uncovered, way back out included', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlSpoiler(reversible: true, child: Text('He was the killer all along.')),
            width: 360,
          ),
        );

        final double covered = tester.getSize(find.byType(PlSpoiler)).height;

        await tester.tap(find.text('Reveal'));
        await tester.pumpAndSettle();

        // The Hide row is built from the start and held invisible under the
        // cover, so revealing does not grow the sheet by a button and covering
        // it again does not shrink it back. A page that moves twice around the
        // control somebody is pressing is the bug the reserved space answers.
        expect(tester.getSize(find.byType(PlSpoiler)).height, covered);

        await tester.tap(find.text('Hide'));
        await tester.pumpAndSettle();

        expect(tester.getSize(find.byType(PlSpoiler)).height, covered);
      });

      testWidgets('keeps the way back out unreachable while the content is covered', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlSpoiler(reversible: true, child: Text('He was the killer all along.')),
            width: 360,
          ),
        );

        // Reserved space rather than a live control: the row holds its size so
        // the box does not move, and is off the semantics tree with it.
        expect(find.text('Hide'), findsOneWidget);
        expect(
          find.descendant(of: find.byType(PlSpoiler), matching: find.bySemanticsLabel('Hide')),
          findsNothing,
        );
      });

      testWidgets('is never dyed, whatever colour it is given', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlSpoiler(color: PlassColor.danger, child: Text('He was the killer all along.')),
            width: 360,
          ),
        );

        final BoxDecoration sheet = decorationWhere(
          tester,
          find.byType(PlSpoiler),
          (BoxDecoration decoration) => decoration.color != null,
        );

        expect(sheet.gradient, isNull);
        expect(sheet.color, PlassTokens.light().glass);
      });
    });
  });
}
