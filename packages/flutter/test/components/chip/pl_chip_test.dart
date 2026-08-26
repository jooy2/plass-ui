import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

void main() {
  group('PlChip', () {
    group('rendering', () {
      testWidgets('renders its label', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlChip(child: Text('Unread'))));

        expect(find.text('Unread'), findsOneWidget);
      });

      testWidgets('sits one step down the control ladder', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlChip(child: Text('Unread'))));

        // An `md` chip is an `sm` control: 32px, not 40.
        expect(tester.getSize(find.byType(PlChip)).height, 32);
      });

      testWidgets('keeps `xs` from falling off the bottom of the ladder', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlChip(size: PlassSize.xs, child: Text('Tag'))));

        expect(tester.getSize(find.byType(PlChip)).height, 24);
      });

      testWidgets('sets a count on its own plate', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlChip(count: Text('12'), child: Text('Errors'))));

        expect(find.text('12'), findsOneWidget);
        expect(find.text('Errors'), findsOneWidget);
      });
    });

    group('pressing', () {
      testWidgets('is not a focus stop until it can be pressed', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlChip(child: Text('Tag'))));

        expect(tester.getSemantics(find.byType(PlChip)), isNot(matchesSemantics(isButton: true)));

        handle.dispose();
      });

      testWidgets('fires when pressed', (WidgetTester tester) async {
        var pressed = 0;
        await tester.pumpWidget(
          host(PlChip(onPressed: () => pressed += 1, child: const Text('Tag'))),
        );

        await tester.tap(find.byType(PlChip));
        expect(pressed, 1);
      });

      testWidgets('does not fire while disabled', (WidgetTester tester) async {
        var pressed = 0;
        await tester.pumpWidget(
          host(PlChip(onPressed: () => pressed += 1, disabled: true, child: const Text('Tag'))),
        );

        await tester.tap(find.byType(PlChip));
        expect(pressed, 0);
      });

      testWidgets('reports whether it is chosen', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(PlChip(onPressed: () {}, selected: true, child: const Text('Tag'))),
        );

        // Asked from inside: the chip's node is built by the `Semantics` under
        // the interaction wrapper rather than by `PlChip` itself.
        expect(
          tester.getSemantics(find.text('Tag')).flagsCollection.isSelected,
          ui.Tristate.isTrue,
        );
        handle.dispose();
      });
    });

    group('selected', () {
      testWidgets('moves a glass chip one step up its own ladder', (WidgetTester tester) async {
        final tokens = PlassTokens.light();

        await tester.pumpWidget(host(const PlChip(child: Text('Tag'))));
        expect(
          decorationWhere(
            tester,
            find.byType(PlChip),
            (BoxDecoration decoration) => decoration.border != null,
          ).color,
          tokens.glass,
        );

        await tester.pumpWidget(host(const PlChip(selected: true, child: Text('Tag'))));
        await tester.pumpAndSettle();

        expect(
          decorationWhere(
            tester,
            find.byType(PlChip),
            (BoxDecoration decoration) => decoration.border != null,
          ).color,
          tokens.glassPress,
        );
      });

      testWidgets('lifts a solid chip rather than recolouring it', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlChip(variant: PlassVariant.solid, child: Text('Tag'))),
        );

        final flat = decorationWhere(
          tester,
          find.byType(PlChip),
          (BoxDecoration decoration) => decoration.gradient != null,
        );

        await tester.pumpWidget(
          host(const PlChip(variant: PlassVariant.solid, selected: true, child: Text('Tag'))),
        );
        await tester.pumpAndSettle();

        final lifted = decorationsOf(
          tester,
          find.byType(PlChip),
        ).firstWhere((BoxDecoration decoration) => decoration.boxShadow?.isNotEmpty ?? false);

        expect(flat.gradient, isNotNull);
        expect(lifted.boxShadow!.last.color, PlassTokens.light().family(PlassColor.primary).tint);
      });
    });

    group('delete', () {
      testWidgets('has no affordance until one is asked for', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlChip(child: Text('Tag'))));

        expect(find.bySemanticsLabel('Remove'), findsNothing);
        handle.dispose();
      });

      testWidgets('fires on its own, without the chip', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        var removed = 0;
        var pressed = 0;

        await tester.pumpWidget(
          host(
            PlChip(
              onPressed: () => pressed += 1,
              onDeleted: () => removed += 1,
              child: const Text('Tag'),
            ),
          ),
        );

        // The × is its own focus stop and its own hit target, which is the
        // whole reason it is not inside the chip's own gesture recogniser.
        await tester.tap(find.bySemanticsLabel('Remove'));
        expect(removed, 1);
        expect(pressed, 0);
        handle.dispose();
      });
    });
  });
}
