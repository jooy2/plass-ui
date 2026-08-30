import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

void main() {
  group('PlFooter', () {
    group('the sheet', () {
      testWidgets('holds whatever it was given, with no slots of its own', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlFooter(child: Text('© 2026 Acme')), width: 480));

        expect(find.text('© 2026 Acme'), findsOneWidget);
      });

      testWidgets('spans the width it was given', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlFooter(child: Text('© 2026')), width: 480));

        expect(tester.getSize(find.byType(PlFooter)).width, 480);
      });

      testWidgets('is never dyed, whatever colour it is given', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlFooter(color: PlassColor.danger, child: Text('© 2026')), width: 480),
        );

        expect(
          decorationsOf(
            tester,
            find.byType(PlFooter),
          ).every((BoxDecoration decoration) => decoration.gradient == null),
          isTrue,
        );
      });

      testWidgets('rules its top edge by default and can be told not to', (
        WidgetTester tester,
      ) async {
        bool rulesTop() => decorationsOf(tester, find.byType(PlFooter)).any(
          (BoxDecoration decoration) =>
              decoration.border is Border &&
              (decoration.border! as Border).top.width > 0 &&
              (decoration.border! as Border).bottom == BorderSide.none,
        );

        await tester.pumpWidget(host(const PlFooter(child: Text('© 2026')), width: 480));

        expect(rulesTop(), isTrue);

        await tester.pumpWidget(
          host(const PlFooter(divider: false, child: Text('© 2026')), width: 480),
        );

        expect(rulesTop(), isFalse);
      });

      testWidgets('has no corners, because it spans an edge', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlFooter(child: Text('© 2026')), width: 480));

        expect(
          decorationsOf(tester, find.byType(PlFooter)).every(
            (BoxDecoration decoration) =>
                decoration.borderRadius == null || decoration.borderRadius == BorderRadius.zero,
          ),
          isTrue,
        );
      });
    });

    group('the content box', () {
      testWidgets('pads on both axes, on the sheet ladder', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlFooter(child: Text('©')), width: 480));

        final Rect bar = tester.getRect(find.byType(PlFooter));
        final Rect text = tester.getRect(find.text('©'));

        expect(text.left - bar.left, sheetPaddingXStandardMd);
        expect(text.top - bar.top, greaterThan(0));
      });

      testWidgets('packs tighter on compact', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlFooter(child: Text('©')), width: 480));

        final double standard = tester.getTopLeft(find.text('©')).dx;

        await tester.pumpWidget(
          host(const PlFooter(density: PlassDensity.compact, child: Text('©')), width: 480),
        );

        expect(tester.getTopLeft(find.text('©')).dx, lessThan(standard));
      });

      testWidgets('gives the padding up when it is told to', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlFooter(padded: false, child: Text('©')), width: 480));

        expect(tester.getTopLeft(find.text('©')).dx, tester.getTopLeft(find.byType(PlFooter)).dx);
      });

      testWidgets('holds the content to a measure while the sheet spans the width', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlFooter(maxWidth: PlassSize.xs, padded: false, child: Text('©')), width: 700),
        );

        expect(tester.getSize(find.byType(PlFooter)).width, 700);
        // 480 wide and centred, so the content starts (700 − 480) / 2 in.
        expect(
          tester.getTopLeft(find.text('©')).dx - tester.getTopLeft(find.byType(PlFooter)).dx,
          closeTo(110, 1),
        );
      });
    });

    group('semantics', () {
      testWidgets('claims the contentInfo landmark', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(host(const PlFooter(child: Text('© 2026')), width: 480));

        expect(
          semanticsOf(tester, find.byType(PlFooter)).getSemanticsData().role,
          SemanticsRole.contentInfo,
        );

        handle.dispose();
      });

      testWidgets('takes a name for the screen that has two of them', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(const PlFooter(semanticLabel: 'Site', child: Text('© 2026')), width: 480),
        );

        expect(semanticsOf(tester, find.byType(PlFooter)).getSemanticsData().label, 'Site');

        handle.dispose();
      });
    });

    group('inside a PlPageLayout', () {
      testWidgets('sits under the content and under the columns', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlPageLayout(
              footer: PlFooter(child: Text('© 2026')),
              sidebar: SizedBox(width: 120, child: Text('Nav')),
              child: Text('Body'),
            ),
            width: 780,
            height: 600,
          ),
        );

        expect(
          tester.getTopLeft(find.text('© 2026')).dy,
          greaterThan(tester.getTopLeft(find.text('Nav')).dy),
        );
        expect(
          tester.getTopLeft(find.byType(PlFooter)).dx,
          tester.getTopLeft(find.byType(PlPageLayout)).dx,
        );
      });
    });
  });
}

/// `sheetPaddingX[standard][md]`, written out because the scales are internal.
const double sheetPaddingXStandardMd = 20;
