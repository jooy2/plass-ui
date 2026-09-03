import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// Something to measure: the box the container actually hands its child,
/// gutter and all.
const Widget _probe = SizedBox.expand(key: ValueKey<String>('probe'));

Rect _inner(WidgetTester tester) => tester.getRect(find.byKey(const ValueKey<String>('probe')));

void main() {
  group('PlContainer', () {
    group('maxWidth', () {
      /// The limit the container is currently imposing, whatever room it was
      /// given — asserted on the constraint rather than on a laid-out width,
      /// which is the test surface's answer as much as the container's.
      double? limitOf(WidgetTester tester) {
        final Iterable<ConstrainedBox> boxes = tester.widgetList<ConstrainedBox>(
          find.descendant(of: find.byType(PlContainer), matching: find.byType(ConstrainedBox)),
        );

        for (final ConstrainedBox box in boxes) {
          if (box.constraints.maxWidth.isFinite) {
            return box.constraints.maxWidth;
          }
        }

        return null;
      }

      Future<void> atWidth(WidgetTester tester, double width, Widget child) async {
        await tester.pumpWidget(
          host(
            Builder(
              builder: (BuildContext context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(size: Size(width, 800)),
                child: child,
              ),
            ),
          ),
        );
      }

      testWidgets('changes with the window, and takes an exact width', (WidgetTester tester) async {
        const Widget page = PlContainer(
          padded: false,
          maxWidth: PlassResponsive<PlContainerWidth?>(
            null,
            md: PlContainerWidth.rung(PlassSize.lg),
            xl: PlContainerWidth.pixels(720),
          ),
          child: Text('page'),
        );

        // `null` as an entry is a real answer — no limit at all below `md`.
        await atWidth(tester, 500, page);
        expect(limitOf(tester), isNull);

        await atWidth(tester, 900, page);
        expect(limitOf(tester), 1024);

        // The exact width is the one worth having: a measure in characters is
        // what a paragraph wants, and no ladder of five numbers can spell it.
        await atWidth(tester, 1400, page);
        expect(limitOf(tester), 720);
      });

      testWidgets('reads the same ladder a header and a footer do', (WidgetTester tester) async {
        // Three widgets hold content to a measure and there is one ladder
        // behind them — a header whose measure did not line up with the
        // container under it is what that prevents. Asserted through the three
        // rather than against the table, which is internal.
        const PlassResponsive<PlContainerWidth?> lg = PlassResponsive<PlContainerWidth?>(
          PlContainerWidth.rung(PlassSize.lg),
        );

        await atWidth(tester, 1400, const PlContainer(maxWidth: lg, child: Text('page')));
        final double? container = limitOf(tester);

        await tester.pumpWidget(
          host(
            Builder(
              builder: (BuildContext context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(size: const Size(1400, 800)),
                child: const PlHeader(maxWidth: lg, brand: <Widget>[Text('Acme')]),
              ),
            ),
          ),
        );

        final ConstrainedBox header = tester
            .widgetList<ConstrainedBox>(
              find.descendant(of: find.byType(PlHeader), matching: find.byType(ConstrainedBox)),
            )
            .firstWhere((ConstrainedBox box) => box.constraints.maxWidth.isFinite);

        expect(container, 1024);
        expect(header.constraints.maxWidth, container);
      });

      testWidgets('holds the content to nothing unless it is asked to', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlContainer(padded: false, child: _probe), width: 700, height: 100),
        );

        expect(_inner(tester).width, 700);
      });

      testWidgets('takes the step it was named', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlContainer(
              maxWidth: PlassResponsive<PlContainerWidth?>(PlContainerWidth.rung(PlassSize.xs)),
              padded: false,
              child: _probe,
            ),
            width: 700,
            height: 100,
          ),
        );

        expect(_inner(tester).width, 480);
      });

      testWidgets('is a limit rather than a width', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlContainer(
              maxWidth: PlassResponsive<PlContainerWidth?>(PlContainerWidth.rung(PlassSize.xl)),
              padded: false,
              child: _probe,
            ),
            width: 400,
            height: 100,
          ),
        );

        expect(_inner(tester).width, 400);
      });
    });

    group('centered', () {
      testWidgets('centres what is left over by default', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlContainer(
              maxWidth: PlassResponsive<PlContainerWidth?>(PlContainerWidth.rung(PlassSize.xs)),
              padded: false,
              child: _probe,
            ),
            width: 700,
            height: 100,
          ),
        );

        final Rect page = tester.getRect(find.byType(PlContainer));

        expect(_inner(tester).center.dx, page.center.dx);
      });

      testWidgets('leaves it against the start when it is turned off', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlContainer(
              maxWidth: PlassResponsive<PlContainerWidth?>(PlContainerWidth.rung(PlassSize.xs)),
              padded: false,
              centered: false,
              child: _probe,
            ),
            width: 700,
            height: 100,
          ),
        );

        expect(_inner(tester).left, tester.getRect(find.byType(PlContainer)).left);
      });

      testWidgets('follows the writing direction rather than the left edge', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlContainer(
              maxWidth: PlassResponsive<PlContainerWidth?>(PlContainerWidth.rung(PlassSize.xs)),
              padded: false,
              centered: false,
              child: _probe,
            ),
            width: 700,
            height: 100,
            textDirection: TextDirection.rtl,
          ),
        );

        expect(_inner(tester).right, tester.getRect(find.byType(PlContainer)).right);
      });
    });

    group('padded', () {
      testWidgets('pads on the sheet track', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlContainer(child: _probe), width: 700, height: 100));

        expect(_inner(tester).width, 700 - 20 * 2);
      });

      testWidgets('takes the compact track when it is asked to', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlContainer(density: PlassDensity.compact, child: _probe),
            width: 700,
            height: 100,
          ),
        );

        expect(_inner(tester).width, 700 - 14 * 2);
      });

      testWidgets('is measured inside the limit, not outside it', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlContainer(
              maxWidth: PlassResponsive<PlContainerWidth?>(PlContainerWidth.rung(PlassSize.xs)),
              child: _probe,
            ),
            width: 700,
            height: 100,
          ),
        );

        expect(_inner(tester).width, 480 - 20 * 2);
      });

      testWidgets('gives the gutter up entirely when it is turned off', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlContainer(padded: false, child: _probe), width: 700, height: 100),
        );

        expect(_inner(tester).width, 700);
      });
    });

    group('the box', () {
      testWidgets('is as tall as what it holds', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlContainer(child: SizedBox(height: 40)), width: 700));

        expect(tester.getSize(find.byType(PlContainer)).height, 40);
      });

      testWidgets('renders what it was given', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlContainer(child: Text('The page')), width: 400));

        expect(find.text('The page'), findsOneWidget);
      });
    });
  });
}
