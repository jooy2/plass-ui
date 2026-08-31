import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// The decoration carrying the lozenge's own fill.
BoxDecoration _shell(WidgetTester tester) {
  return decorationWhere(
    tester,
    find.byType(PlPill),
    (BoxDecoration decoration) => decoration.gradient != null || decoration.color != null,
  );
}

void main() {
  group('PlPill', () {
    group('the lozenge', () {
      testWidgets('draws the title and the line under it', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlPill(title: Text('Recording'), description: Text('00:41')), width: 320),
        );

        expect(find.text('Recording'), findsOneWidget);
        expect(find.text('00:41'), findsOneWidget);
      });

      testWidgets('is a stadium cut to half its own row', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlPill(title: Text('Recording')), width: 320));

        // Half the row's *minimum* height, not half of whatever the pill has
        // grown to: a corner half the height of a two-line box eats the first
        // two words of every line.
        expect(_shell(tester).borderRadius, BorderRadius.circular(16));
      });

      testWidgets('keeps the corner it always had once it has grown', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlPill(
              expanded: true,
              title: Text('Two updates'),
              details: Text('Billing moved to the new provider.'),
            ),
            width: 320,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.getSize(find.byType(PlPill)).height, greaterThan(32));
        expect(_shell(tester).borderRadius, BorderRadius.circular(16));
      });

      testWidgets('floats rather than lying flat', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlPill(title: Text('Recording')), width: 320));

        // Every other surface in the library rests on the screen; this one
        // hovers over whatever is underneath it.
        expect(
          decorationsOf(
            tester,
            find.byType(PlPill),
          ).any((BoxDecoration d) => d.boxShadow != null && d.boxShadow!.isNotEmpty),
          isTrue,
        );
      });

      testWidgets('takes the tint on its own surface, the way a control does', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlPill(color: PlassColor.danger, title: Text('Recording')), width: 320),
        );

        // A pill is the thing being coloured rather than a sheet holding
        // somebody else's content.
        expect(_shell(tester).gradient, PlassTokens.light().family(PlassColor.danger).fill);
      });

      testWidgets('is as tall as its row until a second line asks for more', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlPill(title: Text('Recording')), width: 320));

        expect(tester.getSize(find.byType(PlPill)).height, 32);

        await tester.pumpWidget(
          host(const PlPill(title: Text('Recording'), description: Text('00:41')), width: 320),
        );

        // A fixed height would have clipped the second line.
        expect(tester.getSize(find.byType(PlPill)).height, greaterThan(32));
      });
    });

    group('pressing it', () {
      testWidgets('is not a control until it is given something to do', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlPill(title: Text('Recording')), width: 320));

        expect(tester.getSemantics(find.text('Recording')), isNot(isSemantics(isButton: true)));

        handle.dispose();
      });

      testWidgets('answers a press once it has one', (WidgetTester tester) async {
        var pressed = 0;

        await tester.pumpWidget(
          host(PlPill(title: const Text('Recording'), onPressed: () => pressed += 1), width: 320),
        );

        await tester.tap(find.text('Recording'));
        await tester.pumpAndSettle();

        expect(pressed, 1);
      });

      testWidgets('keeps the trailing slot outside what answers a press', (
        WidgetTester tester,
      ) async {
        var pressed = 0;
        var stopped = 0;

        await tester.pumpWidget(
          host(
            PlPill(
              title: const Text('Recording'),
              onPressed: () => pressed += 1,
              endIcon: PlIconButton(
                size: PlassSize.xs,
                variant: PlassVariant.ghost,
                icon: const Text('■'),
                label: 'Stop',
                onPressed: () => stopped += 1,
              ),
            ),
            width: 320,
          ),
        );

        await tester.tap(find.text('■'));
        await tester.pumpAndSettle();

        // A control inside another control's gesture takes one tap twice.
        expect(stopped, 1);
        expect(pressed, 0);
      });
    });

    group('details', () {
      testWidgets('is collapsed to nothing and out of the way while it is closed', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlPill(title: Text('Two updates'), details: Text('Billing moved.')),
            width: 320,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.getSize(find.text('Billing moved.')).height, greaterThan(0));
        // Clipped to nothing *and* taken off the semantics tree: a panel nobody
        // can see is not one a screen reader should be reading out.
        expect(
          find.ancestor(of: find.text('Billing moved.'), matching: find.byType(ExcludeSemantics)),
          findsWidgets,
        );
        expect(tester.getSize(find.byType(PlPill)).height, 32);
      });

      testWidgets('opens to whatever the body measures', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlPill(title: Text('Two updates'), details: Text('Billing moved.')),
            width: 320,
          ),
        );
        await tester.pumpAndSettle();

        final double closed = tester.getSize(find.byType(PlPill)).height;

        await tester.pumpWidget(
          host(
            const PlPill(
              expanded: true,
              title: Text('Two updates'),
              details: Text('Billing moved.'),
            ),
            width: 320,
          ),
        );
        await tester.pumpAndSettle();

        // The pill grew downward into it: one object saying more, rather than a
        // different shape.
        expect(tester.getSize(find.byType(PlPill)).height, greaterThan(closed));
      });
    });

    group('how wide it is', () {
      testWidgets('fills a width it is given', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlPill(title: Text('Recording')), width: 320));

        expect(tester.getSize(find.byType(PlPill)).width, 320);
      });

      testWidgets('fills a loose one too, which is what a Wrap hands out', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const Wrap(children: <Widget>[PlPill(title: Text('Recording'))]), width: 320),
        );

        // Loose is still bounded: a `Wrap` offers the whole line and the pill
        // takes it, so a row of pills is a column of them. Worth knowing before
        // reaching for one where a `PlChip` was meant.
        expect(tester.getSize(find.byType(PlPill)).width, 320);
      });

      // Every one of these hands the pill an *unbounded* width, and each one is
      // somewhere a lozenge is ordinarily put — beside something in a row, or
      // floating over a screen from a corner. A pill that could only stand in a
      // box of a known width could not be used in any of them.
      for (final (String where, Widget Function(Widget pill) put)
          in <(String, Widget Function(Widget))>[
            ('a Row', (Widget pill) => Row(children: <Widget>[const Text('Live'), pill])),
            (
              'a Positioned that named one corner',
              (Widget pill) => Stack(
                children: <Widget>[
                  const SizedBox.expand(),
                  PositionedDirectional(top: 16, start: 16, child: pill),
                ],
              ),
            ),
          ]) {
        testWidgets('stands in $where, and takes its own width there', (WidgetTester tester) async {
          await tester.pumpWidget(
            host(put(const PlPill(title: Text('Recording'))), width: 320, height: 200),
          );

          expect(tester.takeException(), isNull);

          final double width = tester.getSize(find.byType(PlPill)).width;

          expect(width, greaterThan(0));
          expect(width, lessThan(320), reason: 'it took the room rather than its own width');
        });
      }

      testWidgets('is as wide as its widest part once the panel is open', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            Row(
              children: <Widget>[
                const PlPill(
                  expanded: true,
                  title: Text('Rec'),
                  details: Text('A line longer than the row above it'),
                ),
              ],
            ),
            width: 640,
            height: 200,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        // The panel is the widest part, so it is the panel that sets the width
        // — the same thing `stretch` does inside a box, without one.
        final Size pill = tester.getSize(find.byType(PlPill));
        final Size details = tester.getSize(find.text('A line longer than the row above it'));

        expect(pill.width, greaterThan(details.width));
      });
    });
  });
}
