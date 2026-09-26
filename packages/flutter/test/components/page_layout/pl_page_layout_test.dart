import 'package:flutter/gestures.dart';
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

      testWidgets('leaves the main role to a layout it is inside', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            const PlPageLayout(
              mainSemanticLabel: 'Report',
              child: PlPageLayout(mainSemanticLabel: 'Pane', child: Text('Body')),
            ),
            width: 900,
            height: 600,
          ),
        );

        // A screen has one main region, and an inner layout is a part of that
        // screen rather than a second one. The name goes with the role.
        final List<SemanticsNode> mains = <SemanticsNode>[];

        bool visit(SemanticsNode node) {
          if (node.getSemanticsData().role == SemanticsRole.main) {
            mains.add(node);
          }

          node.visitChildren(visit);

          return true;
        }

        tester.binding.renderViews.first.debugSemantics?.visitChildren(visit);

        expect(mains, hasLength(1));
        expect(mains.single.label, 'Report');
        expect(find.bySemanticsLabel('Pane'), findsNothing);
        expect(find.bySemanticsLabel('Body'), findsOneWidget);

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

    group('a resizable sidebar', () {
      testWidgets(
        'widens a start column on a drag from the half of its handle over a scroll view',
        (WidgetTester tester) async {
          final List<double> settled = <double>[];

          await tester.pumpWidget(
            host(_Resizable(onResizeEnd: settled.add), width: 800, height: 600),
          );

          // The handle is 8px wide and straddles the edge, so its outer half
          // lies over the start of the scroll view beside the column, which
          // takes a press anywhere in it.
          final Rect box = tester.getRect(find.byType(PlSidebar).first);
          final TestGesture gesture = await tester.startGesture(
            Offset(box.right + 3, box.center.dy),
            kind: PointerDeviceKind.mouse,
          );
          await gesture.moveBy(const Offset(40, 0));
          await tester.pump();
          await gesture.up();
          await tester.pump();

          expect(settled, hasLength(1));
          expect(settled.single, closeTo(260, 2));
          expect(tester.getSize(find.byType(PlSidebar).first).width, closeTo(260, 2));
        },
      );

      testWidgets('and under RTL, where the start column is on the right', (
        WidgetTester tester,
      ) async {
        final List<double> settled = <double>[];

        await tester.pumpWidget(
          host(
            _Resizable(onResizeEnd: settled.add),
            width: 800,
            height: 600,
            textDirection: TextDirection.rtl,
          ),
        );

        final Rect box = tester.getRect(find.byType(PlSidebar).first);
        final TestGesture gesture = await tester.startGesture(
          Offset(box.left - 3, box.center.dy),
          kind: PointerDeviceKind.mouse,
        );
        await gesture.moveBy(const Offset(-40, 0));
        await tester.pump();
        await gesture.up();
        await tester.pump();

        expect(settled, hasLength(1));
        expect(settled.single, closeTo(260, 2));
      });

      testWidgets('draws a start column\'s handle over the content beside it', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const _Resizable(), width: 800, height: 600));

        // Lit from its inner half, which only the column holds, so the wash is
        // there whichever of the two is asked about a pointer first.
        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        final Rect box = tester.getRect(find.byType(PlSidebar).first);

        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(Offset(box.right - 2, box.center.dy));
        await tester.pumpAndSettle();

        final Color wash = PlassTokens.light().family(PlassColor.primary).soft;

        // The wash runs 4px past the edge, over the content's fill, and is
        // painted after it rather than under it.
        expect(
          tester.renderObject(find.byType(PlPageLayout)),
          paints
            ..something(_fills(_contentFill))
            ..something(_fills(wash)),
        );
      });

      testWidgets('keeps the size and the place of every part, in both directions', (
        WidgetTester tester,
      ) async {
        for (final TextDirection direction in TextDirection.values) {
          await tester.pumpWidget(
            host(
              const _Resizable(headerSpan: PlPageLayoutSpan.content),
              width: 800,
              height: 600,
              textDirection: direction,
            ),
          );

          final bool rtl = direction == TextDirection.rtl;
          final Rect header = tester.getRect(find.text('Header'));

          expect(
            tester.getRect(find.byType(PlSidebar).first),
            Rect.fromLTWH(rtl ? 580 : 0, 0, 220, 600),
          );
          expect(header.left, 220);
          expect(header.right, 580);
          expect(
            tester.getRect(find.byKey(const Key('content'))),
            Rect.fromLTRB(220, header.bottom, 580, 600),
          );
          expect(
            tester.getRect(find.byType(PlSidebar).last),
            Rect.fromLTWH(rtl ? 0 : 580, 0, 220, 600),
          );
        }
      });

      testWidgets(
        'reads and tabs through the start column, the content and the end column in order',
        (WidgetTester tester) async {
          final SemanticsHandle handle = tester.ensureSemantics();
          final FocusNode nav = FocusNode(debugLabel: 'nav');
          final FocusNode body = FocusNode(debugLabel: 'body');
          final FocusNode outline = FocusNode(debugLabel: 'outline');

          addTearDown(nav.dispose);
          addTearDown(body.dispose);
          addTearDown(outline.dispose);

          // Once as an app reads it, in the order the stops sit on screen, and
          // once in the order they are built.
          for (final FocusTraversalPolicy policy in <FocusTraversalPolicy>[
            ReadingOrderTraversalPolicy(),
            WidgetOrderTraversalPolicy(),
          ]) {
            await tester.pumpWidget(
              host(
                FocusTraversalGroup(
                  policy: policy,
                  child: _Resizable(nav: nav, body: body, outline: outline),
                ),
                width: 800,
                height: 600,
              ),
            );

            expect(_readingOrder(tester), <String>[
              'Header',
              'Navigation',
              'Links',
              'Resize sidebar',
              'Page',
              'Body',
              'Outline',
              'Contents',
            ]);

            nav.requestFocus();
            await tester.pump();

            final List<FocusNode> stops = <FocusNode>[];

            for (int i = 0; i < 5; i++) {
              stops.add(FocusManager.instance.primaryFocus!);
              FocusManager.instance.primaryFocus!.nextFocus();
              await tester.pump();
            }

            // The handle is a stop of its own, between the column's links and
            // the content.
            expect(
              <FocusNode>[stops[0], stops[2], stops[3], stops[4]],
              <FocusNode>[nav, body, outline, nav],
            );
            expect(
              find.descendant(
                of: find.byType(PlSidebar).first,
                matching: find.byElementPredicate((Element element) => element == stops[1].context),
              ),
              findsOneWidget,
            );
          }

          handle.dispose();
        },
      );
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

/// What the scroll view beside the columns is filled with.
const Color _contentFill = Color(0xFF123456);

/// A layout with a resizable start column, a scroll view that fills the band
/// to its edges, and a plain end column.
class _Resizable extends StatelessWidget {
  const _Resizable({
    this.onResizeEnd,
    this.headerSpan = PlPageLayoutSpan.full,
    this.nav,
    this.body,
    this.outline,
  });

  final ValueChanged<double>? onResizeEnd;
  final PlPageLayoutSpan headerSpan;
  final FocusNode? nav;
  final FocusNode? body;
  final FocusNode? outline;

  @override
  Widget build(BuildContext context) {
    return PlPageLayout(
      collapseBelow: null,
      headerSpan: headerSpan,
      header: const Text('Header'),
      mainSemanticLabel: 'Page',
      sidebar: PlSidebar(
        resizable: true,
        width: 220,
        semanticLabel: 'Navigation',
        onResizeEnd: onResizeEnd,
        child: Focus(focusNode: nav, child: const Text('Links')),
      ),
      endSidebar: PlSidebar(
        width: 220,
        semanticLabel: 'Outline',
        child: Focus(focusNode: outline, child: const Text('Contents')),
      ),
      child: SingleChildScrollView(
        key: const Key('content'),
        child: ColoredBox(
          color: _contentFill,
          child: Focus(
            focusNode: body,
            child: const SizedBox(height: 1200, child: Text('Body')),
          ),
        ),
      ),
    );
  }
}

/// Matches a rectangle filled with [color], after any number of other calls.
///
/// Compared as 8-bit channels, because a [Paint] hands its colour back through
/// single-precision storage.
PaintPatternPredicate _fills(Color color) {
  return (Symbol method, List<dynamic> arguments) =>
      method == #drawRect && (arguments[1] as Paint).color.toARGB32() == color.toARGB32();
}

/// Every label on the semantics tree, in the order a screen reader reads it.
List<String> _readingOrder(WidgetTester tester) {
  final List<String> labels = <String>[];

  void visit(SemanticsNode node) {
    if (node.label.isNotEmpty) {
      labels.add(node.label);
    }

    for (final SemanticsNode child in node.debugListChildrenInOrder(
      DebugSemanticsDumpOrder.traversalOrder,
    )) {
      visit(child);
    }
  }

  visit(tester.binding.renderViews.first.debugSemantics!);

  return labels;
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
