import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

void main() {
  group('PlSidebar', () {
    group('as a column', () {
      testWidgets('claims the complementary landmark, named', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(column(const PlSidebar(child: Text('Links'))), width: 400, height: 400),
        );

        final SemanticsData data = semanticsOf(tester, find.byType(PlSidebar)).getSemanticsData();

        expect(data.role, SemanticsRole.complementary);
        expect(data.label, 'Sidebar');

        handle.dispose();
      });

      testWidgets('takes a name of its own', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            column(const PlSidebar(semanticLabel: 'Filters', child: Text('Links'))),
            width: 400,
            height: 400,
          ),
        );

        expect(semanticsOf(tester, find.byType(PlSidebar)).getSemanticsData().label, 'Filters');

        handle.dispose();
      });

      testWidgets('takes the width its size implies, and any width it is given', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(column(const PlSidebar(child: Text('Links'))), width: 500, height: 400),
        );

        expect(tester.getSize(find.byType(PlSidebar)).width, 256);

        await tester.pumpWidget(
          host(column(const PlSidebar(width: 220, child: Text('Links'))), width: 500, height: 400),
        );

        expect(tester.getSize(find.byType(PlSidebar)).width, 220);
      });

      testWidgets('walks the width up the size ladder', (WidgetTester tester) async {
        for (final MapEntry<PlassSize, double> entry in <PlassSize, double>{
          PlassSize.xs: 176,
          PlassSize.sm: 208,
          PlassSize.md: 256,
          PlassSize.lg: 288,
          PlassSize.xl: 336,
        }.entries) {
          await tester.pumpWidget(
            host(
              column(PlSidebar(size: entry.key, child: const Text('Links'))),
              width: 500,
              height: 400,
            ),
          );

          expect(tester.getSize(find.byType(PlSidebar)).width, entry.value);
        }
      });

      testWidgets('rules the inner edge, which is the one facing the content', (
        WidgetTester tester,
      ) async {
        // The rule the sidebar draws is on one vertical edge only, and it is
        // directional — the edge facing the content is the far one in both
        // writing directions. The sheet's own glass hairline is a `Border` on
        // all four, which is what tells the two apart.
        BorderDirectional? ruleOf(WidgetTester tester) =>
            decorationsOf(tester, find.byType(PlSidebar))
                .map((BoxDecoration decoration) => decoration.border)
                .whereType<BorderDirectional>()
                .firstOrNull;

        await tester.pumpWidget(
          host(column(const PlSidebar(child: Text('Links'))), width: 500, height: 400),
        );

        expect(ruleOf(tester)!.end, isNot(BorderSide.none));
        expect(ruleOf(tester)!.start, BorderSide.none);

        await tester.pumpWidget(
          host(
            column(const PlSidebar(side: PlassSidebarSide.end, child: Text('Links'))),
            width: 500,
            height: 400,
          ),
        );

        expect(ruleOf(tester)!.start, isNot(BorderSide.none));
        expect(ruleOf(tester)!.end, BorderSide.none);

        await tester.pumpWidget(
          host(
            column(const PlSidebar(divider: false, child: Text('Links'))),
            width: 500,
            height: 400,
          ),
        );

        expect(ruleOf(tester), isNull);
      });

      testWidgets('is never dyed, whatever colour it is given', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            column(const PlSidebar(color: PlassColor.danger, child: Text('Links'))),
            width: 500,
            height: 400,
          ),
        );

        expect(
          decorationsOf(
            tester,
            find.byType(PlSidebar),
          ).every((BoxDecoration decoration) => decoration.gradient == null),
          isTrue,
        );
      });

      testWidgets('takes the side the layout slot puts it on, with no prop of its own', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlPageLayout(
              collapseBelow: null,
              endSidebar: PlSidebar(semanticLabel: 'Contents', child: Text('Links')),
              child: Text('Body'),
            ),
            width: 700,
            height: 400,
          ),
        );

        final BorderDirectional rule = decorationsOf(
          tester,
          find.byType(PlSidebar),
        ).map((BoxDecoration decoration) => decoration.border).whereType<BorderDirectional>().first;

        // The trailing slot, so the rule is on the leading edge.
        expect(rule.end, BorderSide.none);
        expect(rule.start, isNot(BorderSide.none));
      });
    });

    group('the resize handle', () {
      testWidgets('is not there until it is asked for', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(column(const PlSidebar(child: Text('Links'))), width: 500, height: 400),
        );

        expect(find.bySemanticsLabel('Resize sidebar'), findsNothing);

        handle.dispose();
      });

      testWidgets('is a named slider that reports the width', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            column(const PlSidebar(resizable: true, width: 220, child: Text('Links'))),
            width: 500,
            height: 400,
          ),
        );

        final SemanticsData data = tester
            .getSemantics(find.bySemanticsLabel('Resize sidebar'))
            .getSemanticsData();

        expect(data.label, 'Resize sidebar');
        expect(data.value, '220');

        handle.dispose();
      });

      testWidgets('widens the column on a drag and reports every step', (
        WidgetTester tester,
      ) async {
        final List<double> seen = <double>[];
        final List<double> settled = <double>[];

        await tester.pumpWidget(
          host(
            column(
              PlSidebar(
                resizable: true,
                width: 220,
                onResize: seen.add,
                onResizeEnd: settled.add,
                child: const Text('Links'),
              ),
            ),
            width: 500,
            height: 400,
          ),
        );

        final Rect box = tester.getRect(find.byType(PlSidebar));
        final Offset edge = Offset(box.right - 1, box.center.dy);
        final TestGesture gesture = await tester.startGesture(edge, kind: PointerDeviceKind.mouse);
        await gesture.moveBy(const Offset(40, 0));
        await tester.pump();
        await gesture.up();
        await tester.pump();

        expect(seen, isNotEmpty);
        expect(seen.last, closeTo(260, 2));
        expect(settled.single, closeTo(260, 2));
        expect(tester.getSize(find.byType(PlSidebar)).width, closeTo(260, 2));
      });

      testWidgets('clamps what a drag may set', (WidgetTester tester) async {
        final List<double> settled = <double>[];

        await tester.pumpWidget(
          host(
            column(
              PlSidebar(
                resizable: true,
                width: 220,
                maxWidth: 240,
                onResizeEnd: settled.add,
                child: const Text('Links'),
              ),
            ),
            width: 500,
            height: 400,
          ),
        );

        final Rect box = tester.getRect(find.byType(PlSidebar));
        final Offset edge = Offset(box.right - 1, box.center.dy);
        final TestGesture gesture = await tester.startGesture(edge, kind: PointerDeviceKind.mouse);
        await gesture.moveBy(const Offset(200, 0));
        await tester.pump();
        await gesture.up();
        await tester.pump();

        expect(settled.single, 240);
      });

      testWidgets('moves the edge from the semantics action too', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        final List<double> settled = <double>[];

        await tester.pumpWidget(
          host(
            column(
              PlSidebar(
                resizable: true,
                width: 220,
                onResizeEnd: settled.add,
                child: const Text('Links'),
              ),
            ),
            width: 500,
            height: 400,
          ),
        );

        final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Resize sidebar'));
        node.owner!.performAction(node.id, SemanticsAction.increase);
        await tester.pump();

        // A key press is a whole gesture on its own, so the settled callback
        // fires with it.
        expect(settled.single, 236);

        handle.dispose();
      });
    });

    group('as a drawer', () {
      testWidgets('is not on screen while it is closed', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlSidebar(collapseBelow: PlassBreakpoint.md, child: Text('Links')),
            width: 400,
            height: 400,
            overlay: true,
          ),
        );

        expect(find.text('Links'), findsNothing);
      });

      testWidgets('is a panel once it is opened, named by the sidebar', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlSidebar(collapseBelow: PlassBreakpoint.md, open: true, child: Text('Links')),
            width: 400,
            height: 400,
            overlay: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Sidebar'), findsOneWidget);
        expect(find.text('Links'), findsOneWidget);
      });

      testWidgets('takes a title instead, once it has covered the screen', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlSidebar(
              collapseBelow: PlassBreakpoint.md,
              open: true,
              title: Text('Navigation'),
              child: Text('Links'),
            ),
            width: 400,
            height: 400,
            overlay: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Navigation'), findsOneWidget);
        expect(find.text('Sidebar'), findsNothing);
      });

      testWidgets('builds its child once, not twice', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlSidebar(collapseBelow: PlassBreakpoint.md, open: true, child: Text('Links')),
            width: 400,
            height: 400,
            overlay: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Links'), findsOneWidget);
      });
    });
  });

  group('PlSidebarTrigger', () {
    testWidgets('draws nothing outside a layout', (WidgetTester tester) async {
      await tester.pumpWidget(host(const PlSidebarTrigger(), width: 400, height: 200));

      expect(find.byType(PlIconButton), findsNothing);
    });

    testWidgets('draws nothing while the sidebar is still a column', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlPageLayout(
            header: PlHeader(brand: <Widget>[PlSidebarTrigger()]),
            sidebar: PlSidebar(child: Text('Links')),
            child: Text('Body'),
          ),
          width: 780,
          height: 500,
          overlay: true,
        ),
      );

      expect(find.byType(PlIconButton), findsNothing);
    });

    testWidgets('opens the layout sidebar it names', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlPageLayout(
            header: PlHeader(brand: <Widget>[PlSidebarTrigger()]),
            sidebar: PlSidebar(child: Text('Links')),
            child: Text('Body'),
          ),
          width: 400,
          height: 500,
          overlay: true,
        ),
      );

      expect(find.byType(PlIconButton), findsOneWidget);
      expect(find.text('Links'), findsNothing);

      await tester.tap(find.byType(PlIconButton));
      await tester.pumpAndSettle();

      expect(find.text('Links'), findsOneWidget);
    });
  });
}

/// A sidebar in column mode, given loose constraints.
///
/// The host wraps what it is given in a `SizedBox` of the width the test asked
/// for, which would force the column to that width instead of letting it take
/// the one it decided on.
Widget column(Widget sidebar) => Align(alignment: Alignment.centerLeft, child: sidebar);
