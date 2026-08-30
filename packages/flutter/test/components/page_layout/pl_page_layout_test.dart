import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/page_layout.dart';

import '../../support/host.dart';

void main() {
  group('PlPageLayout', () {
    group('the arrangement', () {
      testWidgets('stacks the header, the band and the footer', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlPageLayout(header: Text('Header'), footer: Text('Footer'), child: Text('Body')),
            width: 900,
            height: 600,
          ),
        );

        expect(
          tester.getTopLeft(find.text('Header')).dy,
          lessThan(tester.getTopLeft(find.text('Body')).dy),
        );
        expect(
          tester.getTopLeft(find.text('Body')).dy,
          lessThan(tester.getTopLeft(find.text('Footer')).dy),
        );
      });

      testWidgets('puts the sidebars either side of the content', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlPageLayout(
              sidebar: SizedBox(width: 120, child: Text('Nav')),
              endSidebar: SizedBox(width: 120, child: Text('Aside')),
              child: Text('Body'),
            ),
            width: 900,
            height: 600,
          ),
        );

        final double nav = tester.getTopLeft(find.text('Nav')).dx;
        final double body = tester.getTopLeft(find.text('Body')).dx;
        final double aside = tester.getTopLeft(find.text('Aside')).dx;

        expect(nav, lessThan(body));
        expect(body, lessThan(aside));
      });

      testWidgets('draws nothing for a slot nobody filled', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlPageLayout(child: Text('Body')), width: 900, height: 600),
        );

        expect(find.byType(Text), findsOneWidget);
      });

      testWidgets('runs the columns the other way under RTL', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlPageLayout(
              sidebar: SizedBox(width: 120, child: Text('Nav')),
              child: Text('Body'),
            ),
            width: 900,
            height: 600,
            textDirection: TextDirection.rtl,
          ),
        );

        expect(
          tester.getTopLeft(find.text('Nav')).dx,
          greaterThan(tester.getTopLeft(find.text('Body')).dx),
        );
      });
    });

    group('spans', () {
      testWidgets('puts a full header above the columns', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlPageLayout(
              header: Text('Header'),
              sidebar: SizedBox(width: 120, child: Text('Nav')),
              child: Text('Body'),
            ),
            width: 900,
            height: 600,
          ),
        );

        expect(
          tester.getTopLeft(find.text('Header')).dy,
          lessThan(tester.getTopLeft(find.text('Nav')).dy),
        );
        expect(tester.getTopLeft(find.text('Header')).dx, 0);
      });

      testWidgets('puts a content header beside them instead', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlPageLayout(
              headerSpan: PlPageLayoutSpan.content,
              header: Text('Header'),
              sidebar: SizedBox(width: 120, child: Text('Nav')),
              child: Text('Body'),
            ),
            width: 900,
            height: 600,
          ),
        );

        // The column takes the corner; the bar starts where the column ends.
        expect(
          tester.getTopLeft(find.text('Nav')).dy,
          lessThan(tester.getTopLeft(find.text('Header')).dy + 1),
        );
        expect(tester.getTopLeft(find.text('Header')).dx, greaterThan(0));
      });

      testWidgets('answers the same question for the footer separately', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlPageLayout(
              footerSpan: PlPageLayoutSpan.content,
              footer: Text('Footer'),
              sidebar: SizedBox(width: 120, child: Text('Nav')),
              child: Text('Body'),
            ),
            width: 900,
            height: 600,
          ),
        );

        expect(tester.getTopLeft(find.text('Footer')).dx, greaterThan(0));
      });
    });

    group('semantics', () {
      testWidgets('claims the main role around what it was given', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(const PlPageLayout(child: Text('Body')), width: 900, height: 600),
        );

        final SemanticsNode node = tester.getSemantics(
          find.descendant(of: find.byType(PlPageLayout), matching: find.byType(Semantics)).first,
        );

        expect(node.getSemanticsData().role, SemanticsRole.main);

        handle.dispose();
      });

      testWidgets('takes a name for that region', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            const PlPageLayout(mainSemanticLabel: 'Report', child: Text('Body')),
            width: 900,
            height: 600,
          ),
        );

        expect(find.bySemanticsLabel('Report'), findsOneWidget);

        handle.dispose();
      });
    });

    group('collapsing', () {
      testWidgets('tells the band it is narrow below the breakpoint', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlPageLayout(sidebar: const _Probe(), child: const Text('Body')),
            width: 400,
            height: 600,
          ),
        );

        expect(find.text('drawer closed'), findsOneWidget);
      });

      testWidgets('and wide above it', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlPageLayout(sidebar: const _Probe(), child: const Text('Body')),
            width: 900,
            height: 600,
          ),
        );

        expect(find.text('column start'), findsOneWidget);
      });

      testWidgets('never collapses when nobody named a floor', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlPageLayout(collapseBelow: null, sidebar: const _Probe(), child: const Text('Body')),
            width: 320,
            height: 600,
          ),
        );

        expect(find.text('column start'), findsOneWidget);
      });

      testWidgets('names the end each sidebar is on', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlPageLayout(
              sidebar: const _Probe(),
              endSidebar: const _Probe(),
              child: const Text('Body'),
            ),
            width: 900,
            height: 600,
          ),
        );

        expect(find.text('column start'), findsOneWidget);
        expect(find.text('column end'), findsOneWidget);
      });
    });

    group('the drawers', () {
      testWidgets('holds the open state itself and hands it back', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlPageLayout(sidebar: const _Probe(), child: const Text('Body')),
            width: 400,
            height: 600,
          ),
        );

        expect(find.text('drawer closed'), findsOneWidget);

        await tester.tap(find.byType(_Probe));
        await tester.pump();

        expect(find.text('drawer open'), findsOneWidget);
      });

      testWidgets('answers with what a controlled layout is given', (WidgetTester tester) async {
        final List<bool> seen = <bool>[];

        await tester.pumpWidget(
          host(
            PlPageLayout(
              sidebarOpen: false,
              onSidebarOpenChanged: seen.add,
              sidebar: const _Probe(),
              child: const Text('Body'),
            ),
            width: 400,
            height: 600,
          ),
        );

        await tester.tap(find.byType(_Probe));
        await tester.pump();

        // The layout reported the ask and changed nothing: the state is the
        // caller's now.
        expect(seen, <bool>[true]);
        expect(find.text('drawer closed'), findsOneWidget);
      });
    });
  });
}

/// A stand-in for a sidebar: it reports what the layout told it and can ask to
/// be opened. `PlSidebar` is the real reader of the same three facts.
class _Probe extends StatelessWidget {
  const _Probe();

  @override
  Widget build(BuildContext context) {
    final PlassPageLayoutScope? layout = PlassPageLayoutScope.maybeOf(context);
    final PlassSidebarSide side = PlassSidebarSideScope.maybeOf(context) ?? PlassSidebarSide.start;
    final bool collapsed = layout?.collapsed ?? false;
    final bool open = layout?.open[side] ?? false;

    return GestureDetector(
      onTap: () => layout?.setOpen(side, !open),
      child: SizedBox(
        width: 120,
        child: Text(
          collapsed ? 'drawer ${open ? 'open' : 'closed'}' : 'column ${side.name}',
          textDirection: TextDirection.ltr,
        ),
      ),
    );
  }
}
