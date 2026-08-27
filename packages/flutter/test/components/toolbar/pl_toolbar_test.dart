import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

void main() {
  group('PlToolbar', () {
    group('the row', () {
      testWidgets('lays out its three slots in order', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlToolbar(
              start: <Widget>[Text('Logo')],
              end: <Widget>[Text('Save')],
              child: Text('Middle'),
            ),
            width: 480,
          ),
        );

        final double logo = tester.getTopLeft(find.text('Logo')).dx;
        final double middle = tester.getTopLeft(find.text('Middle')).dx;
        final double save = tester.getTopLeft(find.text('Save')).dx;

        expect(logo, lessThan(middle));
        expect(middle, lessThan(save));
      });

      testWidgets('keeps the ends apart even with nothing in the middle', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlToolbar(start: <Widget>[Text('Logo')], end: <Widget>[Text('Save')]),
            width: 480,
          ),
        );

        // Expanded even when empty, or the two ends collapse together in the
        // middle of the bar.
        expect(
          tester.getTopRight(find.text('Save')).dx,
          greaterThan(tester.getSize(find.byType(PlToolbar)).width / 2),
        );
      });

      testWidgets('takes no height of its own', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlToolbar(child: Text('Middle')), width: 480));

        final double short = tester.getSize(find.byType(PlToolbar)).height;

        await tester.pumpWidget(
          host(const PlToolbar(child: SizedBox(height: 80, child: Text('Middle'))), width: 480),
        );

        // A toolbar is as tall as the controls in it plus its padding.
        expect(tester.getSize(find.byType(PlToolbar)).height, greaterThan(short));
      });

      testWidgets('packs tighter on compact', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlToolbar(start: <Widget>[Text('Logo')], child: SizedBox.shrink()),
            width: 480,
          ),
        );

        final double standard = tester.getTopLeft(find.text('Logo')).dx;

        await tester.pumpWidget(
          host(
            const PlToolbar(
              density: PlassDensity.compact,
              start: <Widget>[Text('Logo')],
              child: SizedBox.shrink(),
            ),
            width: 480,
          ),
        );

        expect(tester.getTopLeft(find.text('Logo')).dx, lessThan(standard));
      });
    });

    group('the sheet', () {
      testWidgets('is never dyed, whatever colour it is given', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlToolbar(color: PlassColor.danger, child: Text('Middle')), width: 480),
        );

        final BoxDecoration sheet = decorationWhere(
          tester,
          find.byType(PlToolbar),
          (BoxDecoration decoration) => decoration.color != null,
        );

        // A toolbar holds other people's controls, and those arrive with
        // colours of their own.
        expect(sheet.gradient, isNull);
        expect(sheet.color, PlassTokens.light().glass);
      });

      testWidgets('is flat', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlToolbar(child: Text('Middle')), width: 480));

        // A shadow under a header says "there is content beneath this", and
        // that is only true once the screen has been scrolled.
        expect(
          decorationsOf(
            tester,
            find.byType(PlToolbar),
          ).every((BoxDecoration d) => d.boxShadow == null || d.boxShadow!.isEmpty),
          isTrue,
        );
      });

      testWidgets('is a sheet with corners until it is held against an edge', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlToolbar(child: Text('Middle')), width: 480));

        expect(
          decorationWhere(
            tester,
            find.byType(PlToolbar),
            (BoxDecoration d) => d.borderRadius != null,
          ).borderRadius,
          BorderRadius.circular(PlassTokens.radius[PlassSize.md]!),
        );

        await tester.pumpWidget(
          host(const PlToolbar(rounded: false, child: Text('Middle')), width: 480),
        );
        await tester.pumpAndSettle();

        // A rounded corner against the edge of the screen is a gap with nothing
        // behind it.
        expect(
          decorationsOf(tester, find.byType(PlToolbar)).every(
            (BoxDecoration d) => d.borderRadius == null || d.borderRadius == BorderRadius.zero,
          ),
          isTrue,
        );
      });
    });

    group('divider', () {
      testWidgets('faces the content, and moves with the side', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlToolbar(divider: true, child: Text('Middle')), width: 480),
        );

        final Border top =
            decorationWhere(
                  tester,
                  find.byType(PlToolbar),
                  // The sheet's own edge is a uniform `Border.all`; the rule
                  // the toolbar draws on itself is one side of one.
                  (BoxDecoration d) => d.border is Border && !(d.border! as Border).isUniform,
                ).border!
                as Border;

        expect(top.bottom.width, greaterThan(0));
        expect(top.top, BorderSide.none);

        await tester.pumpWidget(
          host(
            const PlToolbar(divider: true, side: PlassSide.bottom, child: Text('Middle')),
            width: 480,
          ),
        );

        final Border bottom =
            decorationWhere(
                  tester,
                  find.byType(PlToolbar),
                  // The sheet's own edge is a uniform `Border.all`; the rule
                  // the toolbar draws on itself is one side of one.
                  (BoxDecoration d) => d.border is Border && !(d.border! as Border).isUniform,
                ).border!
                as Border;

        expect(bottom.top.width, greaterThan(0));
        expect(bottom.bottom, BorderSide.none);
      });
    });

    group('accessibility', () {
      testWidgets('claims nothing about its own keyboard behaviour', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlToolbar(
              child: PlButton(onPressed: () {}, child: const Text('Save')),
            ),
            width: 480,
          ),
        );

        // The controls inside are ordinary controls, each with its own focus
        // stop — which is what a bar that has not promised roving focus owes a
        // keyboard reader.
        expect(tester.getSemantics(find.text('Save')), isSemantics(isButton: true));

        handle.dispose();
      });

      testWidgets('takes a name of its own when it is given one', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const PlToolbar(semanticLabel: 'Page actions', child: Text('Middle')), width: 480),
        );

        // `explicitChildNodes`, so the name is the bar's own rather than the
        // bar's and everything in it read as one blob.
        expect(semanticsOf(tester, find.byType(PlToolbar)).label, 'Page actions');

        handle.dispose();
      });
    });
  });
}
