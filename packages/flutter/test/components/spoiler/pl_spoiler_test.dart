import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// The blur the cover is drawn with, or `null` while it is uncovered.
///
/// The filter is built in both states and switched off on reveal, so what says
/// the content is uncovered is `enabled` rather than a missing widget.
ui.ImageFilter? _blur(WidgetTester tester) {
  final Finder filtered = find.descendant(
    of: find.byType(PlSpoiler),
    matching: find.byType(ImageFiltered),
  );

  if (filtered.evaluate().isEmpty) {
    return null;
  }

  final ImageFiltered filter = tester.widget<ImageFiltered>(filtered.first);

  return filter.enabled ? filter.imageFilter : null;
}

/// An [ExcludeFocus] that is actually excluding, as opposed to one held in the
/// tree with `excluding: false` so the tree keeps its shape.
final Finder _excludingFocus = find.byWidgetPredicate(
  (Widget widget) => widget is ExcludeFocus && widget.excluding,
);

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
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(const PlSpoiler(child: Text('He was the killer all along.')), width: 360),
        );

        await tester.tap(find.text('Reveal'));
        await tester.pumpAndSettle();

        // The one widget in the package that is happy uncontrolled: what is
        // being remembered is a thing the reader did to this box.
        //
        // The cover keeps its space so the sheet does not change height, so what
        // says it is gone is the semantics tree rather than the widget tree.
        expect(_blur(tester), isNull);
        // Read off the live tree rather than with `find.bySemanticsLabel`, which
        // matches the node a render object last had. The cover is kept in the
        // tree across a reveal, so its button still holds a node that has left
        // the tree, and the finder would find it.
        expect(semanticsLabels(tester), isNot(contains('Reveal')));

        handle.dispose();
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

      testWidgets('keeps the state of what it covers across a reveal and back', (
        WidgetTester tester,
      ) async {
        var created = 0;

        await tester.pumpWidget(
          host(
            PlSpoiler(reversible: true, child: _Remembers(onCreated: () => created += 1)),
            width: 360,
          ),
        );

        expect(created, 1);

        await tester.tap(find.text('Reveal'));
        await tester.pumpAndSettle();

        // The wrappers that cover the child are switched rather than added and
        // removed, so the child sits at the same depth in both states and keeps
        // its State. It used to be built again from nothing on reveal.
        expect(created, 1);

        await tester.tap(find.text('Hide'));
        await tester.pumpAndSettle();

        expect(created, 1);
      });

      group('from the keyboard', () {
        /// Whether the node holding the focus is [finder] or one of its ancestors.
        bool focusIsAround(Finder finder) {
          final BuildContext? focused = FocusManager.instance.primaryFocus?.context;

          return focused != null &&
              find
                  .ancestor(
                    of: finder,
                    matching: find.byElementPredicate((Element element) => element == focused),
                  )
                  .evaluate()
                  .isNotEmpty;
        }

        Future<FocusNode> pumpAfterStop(WidgetTester tester) async {
          final FocusNode before = FocusNode();
          addTearDown(before.dispose);

          await tester.pumpWidget(
            host(
              afterFocusStop(
                before,
                const PlSpoiler(reversible: true, child: Text('He was the killer all along.')),
              ),
              width: 360,
            ),
          );

          before.requestFocus();
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();

          return before;
        }

        testWidgets('hands the focus to the content it uncovered', (WidgetTester tester) async {
          final FocusNode before = await pumpAfterStop(tester);

          expect(focusIsAround(find.text('Reveal')), isTrue);

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();

          // The pressed button is excluded from the focus by the build that
          // acts on the press, and its scope would hand the focus back to
          // whatever held it before — here the stop above the spoiler, so the
          // next Tab would walk the reader back in from the outside.
          expect(before.hasFocus, isFalse);
          expect(focusIsAround(find.text('He was the killer all along.')), isTrue);

          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();

          expect(focusIsAround(find.text('Hide')), isTrue);
        });

        testWidgets('hands the focus back to Reveal when it is covered again', (
          WidgetTester tester,
        ) async {
          final FocusNode before = await pumpAfterStop(tester);

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          FocusManager.instance.primaryFocus!.nextFocus();
          await tester.pump();

          expect(focusIsAround(find.text('Hide')), isTrue);

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();

          expect(before.hasFocus, isFalse);
          expect(focusIsAround(find.text('Reveal')), isTrue);
        });
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
          find.ancestor(of: find.text('He was the killer all along.'), matching: _excludingFocus),
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
          find.ancestor(of: find.text('He was the killer all along.'), matching: _excludingFocus),
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

      testWidgets('is the same height when the cover is the taller of the two', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlSpoiler(child: Text('One short line.')), width: 360));

        final double covered = tester.getSize(find.byType(PlSpoiler)).height;

        await tester.tap(find.text('Reveal'));
        await tester.pumpAndSettle();

        // The case the long-content test above cannot see. A cover is a line of
        // explanation and a button, so against one short line it is the taller
        // of the two and it is the cover holding the sheet open — drop it on the
        // way in and the sheet collapses to the line, taking the whole page
        // under it up with it.
        expect(tester.getSize(find.byType(PlSpoiler)).height, covered);
      });

      testWidgets('offers no way back in to a spoiler that is already open', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlSpoiler(revealed: true, child: Text('One short line.')), width: 360),
        );

        // Reserved space rather than a live control, exactly as the Hide row is
        // while the content is covered.
        expect(find.text('Reveal'), findsOneWidget);
        expect(
          find.descendant(of: find.byType(PlSpoiler), matching: find.bySemanticsLabel('Reveal')),
          findsNothing,
        );
      });

      testWidgets('lets a maxHeight clamp go, which is the one thing that may resize it', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlSpoiler(maxHeight: 40, child: SizedBox(height: 400, child: Text('Plot.'))),
            width: 360,
          ),
        );

        final double covered = tester.getSize(find.byType(PlSpoiler)).height;

        await tester.tap(find.text('Reveal'));
        await tester.pumpAndSettle();

        // Keeping the clamp would leave the reader a scrollbar where they asked
        // for the content, so this one is meant to grow.
        expect(tester.getSize(find.byType(PlSpoiler)).height, greaterThan(covered));
        expect(tester.getSize(find.byType(PlSpoiler)).height, greaterThan(400));
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

/// A child that counts how many times its [State] is created.
class _Remembers extends StatefulWidget {
  const _Remembers({required this.onCreated});

  final VoidCallback onCreated;

  @override
  State<_Remembers> createState() => _RemembersState();
}

class _RemembersState extends State<_Remembers> {
  @override
  void initState() {
    super.initState();
    widget.onCreated();
  }

  @override
  Widget build(BuildContext context) => const Text('He was the killer all along.');
}
