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
            const PlContainer(maxWidth: PlassSize.xs, padded: false, child: _probe),
            width: 700,
            height: 100,
          ),
        );

        expect(_inner(tester).width, 480);
      });

      testWidgets('is a limit rather than a width', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlContainer(maxWidth: PlassSize.xl, padded: false, child: _probe),
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
            const PlContainer(maxWidth: PlassSize.xs, padded: false, child: _probe),
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
              maxWidth: PlassSize.xs,
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
              maxWidth: PlassSize.xs,
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
          host(const PlContainer(maxWidth: PlassSize.xs, child: _probe), width: 700, height: 100),
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
