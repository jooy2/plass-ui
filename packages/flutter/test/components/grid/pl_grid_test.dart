import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// A cell with something in it to measure.
PlGridItem cell(
  String name, {
  PlassResponsive<int>? span,
  PlassResponsive<int>? offset,
  PlassAlignSelf? alignSelf,
  double height = 20,
}) {
  return PlGridItem(
    span: span,
    offset: offset,
    alignSelf: alignSelf,
    child: SizedBox(key: ValueKey<String>(name), height: height),
  );
}

Rect box(WidgetTester tester, String name) => tester.getRect(find.byKey(ValueKey<String>(name)));

/// A window of a stated width.
///
/// The grid resolves its breakpoints against the **window** rather than against
/// its own box — which is what a CSS media query measures — so a test about a
/// responsive value has to say how wide the window is. `host` deliberately
/// supplies the smallest `MediaQuery` a Plass widget needs, and a size is not
/// part of it.
Widget window(double width, {required Widget child}) {
  return Builder(
    builder: (BuildContext context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(size: Size(width, 800)),
      child: child,
    ),
  );
}

void main() {
  group('PlGrid', () {
    group('span', () {
      testWidgets('divides the row by the column count', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlGrid(
              spacing: const PlassResponsive<double>(0),
              items: <PlGridItem>[
                cell('a', span: const PlassResponsive<int>(6)),
                cell('b', span: const PlassResponsive<int>(6)),
              ],
            ),
            width: 480,
          ),
        );

        expect(box(tester, 'a').width, 240);
        expect(box(tester, 'b').width, 240);
      });

      testWidgets('reads a span against whatever the column count is', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlGrid(
              columns: const PlassResponsive<int>(24),
              spacing: const PlassResponsive<double>(0),
              items: <PlGridItem>[cell('a', span: const PlassResponsive<int>(6))],
            ),
            width: 480,
          ),
        );

        expect(box(tester, 'a').width, 120);
      });

      testWidgets('fills the row when it is given no span at all', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlGrid(spacing: const PlassResponsive<double>(0), items: <PlGridItem>[cell('a')]),
            width: 480,
          ),
        );

        expect(box(tester, 'a').width, 480);
      });

      testWidgets('clamps a span wider than the row rather than overflowing', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlGrid(
              spacing: const PlassResponsive<double>(0),
              items: <PlGridItem>[cell('a', span: const PlassResponsive<int>(99))],
            ),
            width: 480,
          ),
        );

        expect(box(tester, 'a').width, 480);
      });

      testWidgets('never divides by zero columns', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlGrid(
              columns: const PlassResponsive<int>(0),
              spacing: const PlassResponsive<double>(0),
              items: <PlGridItem>[cell('a')],
            ),
            width: 480,
          ),
        );

        expect(box(tester, 'a').width, 480);
      });
    });

    group('spacing', () {
      testWidgets('takes the gutter out of the cell and not out of the row', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlGrid(
              spacing: const PlassResponsive<double>(4),
              items: <PlGridItem>[
                cell('a', span: const PlassResponsive<int>(6)),
                cell('b', span: const PlassResponsive<int>(6)),
              ],
            ),
            width: 480,
          ),
        );

        // (480 + 16) / 12 × 6 − 16, twice, plus the one gutter between them, is
        // exactly the row.
        expect(box(tester, 'a').width, 232);
        expect(box(tester, 'b').left - box(tester, 'a').right, 16);
      });

      testWidgets('measures a fraction of a step', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlGrid(
              spacing: const PlassResponsive<double>(1.5),
              items: <PlGridItem>[
                cell('a', span: const PlassResponsive<int>(6)),
                cell('b', span: const PlassResponsive<int>(6)),
              ],
            ),
            width: 480,
          ),
        );

        expect(box(tester, 'b').left - box(tester, 'a').right, 6);
      });

      testWidgets('lets one axis be set on its own', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlGrid(
              spacing: const PlassResponsive<double>(0),
              rowSpacing: const PlassResponsive<double>(8),
              items: <PlGridItem>[
                cell('a', span: const PlassResponsive<int>(12)),
                cell('b', span: const PlassResponsive<int>(12)),
              ],
            ),
            width: 480,
          ),
        );

        expect(box(tester, 'b').top - box(tester, 'a').bottom, 32);
      });
    });

    group('offset', () {
      testWidgets('pushes a cell along by whole columns', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlGrid(
              spacing: const PlassResponsive<double>(0),
              items: <PlGridItem>[
                cell(
                  'a',
                  span: const PlassResponsive<int>(4),
                  offset: const PlassResponsive<int>(4),
                ),
              ],
            ),
            width: 480,
          ),
        );

        expect(box(tester, 'a').left - tester.getRect(find.byType(PlGrid)).left, 160);
      });

      testWidgets('is space ahead of the cell rather than a position in the row', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlGrid(
              spacing: const PlassResponsive<double>(0),
              items: <PlGridItem>[
                cell('a', span: const PlassResponsive<int>(4)),
                cell(
                  'b',
                  span: const PlassResponsive<int>(4),
                  offset: const PlassResponsive<int>(4),
                ),
              ],
            ),
            width: 480,
          ),
        );

        expect(box(tester, 'b').left - tester.getRect(find.byType(PlGrid)).left, 320);
      });

      testWidgets('counts against the row it is packed into', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlGrid(
              spacing: const PlassResponsive<double>(0),
              items: <PlGridItem>[
                cell('a', span: const PlassResponsive<int>(8)),
                cell(
                  'b',
                  span: const PlassResponsive<int>(4),
                  offset: const PlassResponsive<int>(4),
                ),
              ],
            ),
            width: 480,
          ),
        );

        expect(box(tester, 'b').top, greaterThan(box(tester, 'a').top));
      });
    });

    group('wrap', () {
      testWidgets('continues on the next row when the columns run out', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlGrid(
              spacing: const PlassResponsive<double>(0),
              items: <PlGridItem>[
                cell('a', span: const PlassResponsive<int>(8)),
                cell('b', span: const PlassResponsive<int>(8)),
              ],
            ),
            width: 480,
          ),
        );

        expect(box(tester, 'b').top, box(tester, 'a').bottom);
      });

      testWidgets('runs on past the end when it is told not to wrap', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlGrid(
              wrap: false,
              spacing: const PlassResponsive<double>(0),
              items: <PlGridItem>[
                cell('a', span: const PlassResponsive<int>(8)),
                cell('b', span: const PlassResponsive<int>(8)),
              ],
            ),
            width: 480,
          ),
        );

        expect(box(tester, 'b').top, box(tester, 'a').top);
      });
    });

    group('alignment', () {
      testWidgets('makes every cell the height of the row by default', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlGrid(
              spacing: const PlassResponsive<double>(0),
              items: <PlGridItem>[
                cell('a', span: const PlassResponsive<int>(6), height: 60),
                cell('b', span: const PlassResponsive<int>(6), height: 20),
              ],
            ),
            width: 480,
          ),
        );

        expect(box(tester, 'b').height, 60);
      });

      testWidgets('leaves a cell its own height once it is aligned', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlGrid(
              alignItems: PlassAlignItems.start,
              spacing: const PlassResponsive<double>(0),
              items: <PlGridItem>[
                cell('a', span: const PlassResponsive<int>(6), height: 60),
                cell('b', span: const PlassResponsive<int>(6), height: 20),
              ],
            ),
            width: 480,
          ),
        );

        expect(box(tester, 'b').height, 20);
        expect(box(tester, 'b').top, box(tester, 'a').top);
      });

      testWidgets('lets one cell overrule the row', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlGrid(
              alignItems: PlassAlignItems.start,
              spacing: const PlassResponsive<double>(0),
              items: <PlGridItem>[
                cell('a', span: const PlassResponsive<int>(6), height: 60),
                cell(
                  'b',
                  span: const PlassResponsive<int>(6),
                  height: 20,
                  alignSelf: PlassAlignSelf.end,
                ),
              ],
            ),
            width: 480,
          ),
        );

        expect(box(tester, 'b').bottom, box(tester, 'a').bottom);
      });

      testWidgets('keeps a cell the full width of its span whatever it is aligned to', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlGrid(
              alignItems: PlassAlignItems.center,
              spacing: const PlassResponsive<double>(0),
              items: <PlGridItem>[cell('a', span: const PlassResponsive<int>(6))],
            ),
            width: 480,
          ),
        );

        expect(box(tester, 'a').width, 240);
      });
    });

    group('responsive values', () {
      testWidgets('resolves against the width of the window', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            window(
              500,
              child: PlGrid(
                spacing: const PlassResponsive<double>(0),
                items: <PlGridItem>[cell('a', span: const PlassResponsive<int>(12, md: 6))],
              ),
            ),
            width: 480,
          ),
        );

        // A 500-wide window is below `md`, so the base value is the one in
        // force — even though the grid's own box is 480 either way.
        expect(box(tester, 'a').width, 480);
      });

      testWidgets('takes the override once the window is wide enough', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            window(
              900,
              child: PlGrid(
                spacing: const PlassResponsive<double>(0),
                items: <PlGridItem>[cell('a', span: const PlassResponsive<int>(12, md: 6))],
              ),
            ),
            width: 480,
          ),
        );

        expect(box(tester, 'a').width, 240);
      });

      testWidgets('cascades an override up through the breakpoints above it', (
        WidgetTester tester,
      ) async {
        const PlassResponsive<int> span = PlassResponsive<int>(12, md: 6);

        expect(span.resolve(PlassBreakpoint.xs), 12);
        expect(span.resolve(PlassBreakpoint.sm), 12);
        expect(span.resolve(PlassBreakpoint.md), 6);
        expect(span.resolve(PlassBreakpoint.lg), 6);
        expect(span.resolve(PlassBreakpoint.xl), 6);
      });

      testWidgets('names the breakpoint a width is in', (WidgetTester tester) async {
        expect(PlassBreakpoint.of(0), PlassBreakpoint.xs);
        expect(PlassBreakpoint.of(639), PlassBreakpoint.xs);
        expect(PlassBreakpoint.of(640), PlassBreakpoint.sm);
        expect(PlassBreakpoint.of(768), PlassBreakpoint.md);
        expect(PlassBreakpoint.of(1024), PlassBreakpoint.lg);
        expect(PlassBreakpoint.of(4000), PlassBreakpoint.xl);
      });
    });
  });
}
