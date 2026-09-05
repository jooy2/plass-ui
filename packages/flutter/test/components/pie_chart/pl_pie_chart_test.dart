import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

const List<PlassChartDatum> traffic = <PlassChartDatum>[
  PlassChartDatum(40),
  PlassChartDatum(25),
  PlassChartDatum(20),
  PlassChartDatum(15),
];

const List<PlassChartCategory> sources = <PlassChartCategory>[
  PlassChartCategory.text('Search'),
  PlassChartCategory.text('Social'),
  PlassChartCategory.text('Direct'),
  PlassChartCategory.text('Referral'),
];

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(500, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: 500));
  await tester.pumpAndSettle();
}

void main() {
  group('PlPieChart', () {
    testWidgets('draws a disc and names itself', (WidgetTester tester) async {
      await _pump(tester, const PlPieChart(data: traffic, categories: sources));

      expect(find.bySemanticsLabel('Chart'), findsOneWidget);
    });

    testWidgets('names every slice in the legend rather than the series', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const PlPieChart(data: traffic, categories: sources));

      for (final PlassChartCategory source in sources) {
        expect(find.text(source.toString()), findsOneWidget);
      }
    });

    testWidgets('reads out every slice and its share', (WidgetTester tester) async {
      await _pump(tester, const PlPieChart(data: traffic, categories: sources));

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, contains('Search 40 · 40%'));
      expect(node.value, contains('Referral 15 · 15%'));
    });

    testWidgets('takes every shape it names', (WidgetTester tester) async {
      for (final PlPieShape shape in PlPieShape.values) {
        await _pump(tester, PlPieChart(data: traffic, categories: sources, shape: shape));

        expect(find.byType(PlPieChart), findsOneWidget);
      }
    });

    testWidgets('leaves a gap and a zero out of the reading', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlPieChart(
          data: <PlassChartDatum>[
            PlassChartDatum(40),
            PlassChartDatum.gap(),
            PlassChartDatum(0),
            PlassChartDatum(60),
          ],
          categories: sources,
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, contains('Search'));
      expect(node.value, isNot(contains('Social')));
    });

    testWidgets('says nothing is there when the total is zero', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlPieChart(data: <PlassChartDatum>[PlassChartDatum(0), PlassChartDatum(0)]),
      );

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('puts the caller content in the hole of a donut', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlPieChart(
          data: <PlassChartDatum>[PlassChartDatum(40), PlassChartDatum(60)],
          shape: PlPieShape.donut,
          center: Text('100'),
        ),
      );

      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('leaves it out of a pie, which has no hole to put it in', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const PlPieChart(
          data: <PlassChartDatum>[PlassChartDatum(40), PlassChartDatum(60)],
          center: Text('100'),
        ),
      );

      expect(find.text('100'), findsNothing);
    });

    testWidgets('takes a slice out of the ring and shares its angle out again', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const PlPieChart(data: traffic, categories: sources));

      await tester.tap(find.bySemanticsLabel('Social'));
      await tester.pumpAndSettle();

      final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Chart'));

      expect(node.value, isNot(contains('Social')));
      expect(node.value, contains('Search 40 · 53.3%'));
    });

    testWidgets('shows a readout for the slice under the press', (WidgetTester tester) async {
      await _pump(tester, const PlPieChart(data: traffic, categories: sources, height: 240));

      // Up and to the right of the middle: the first slice starts at twelve
      // o'clock and runs clockwise through forty percent of the turn.
      await tester.tapAt(tester.getCenter(find.byType(CustomPaint).first) + const Offset(30, -50));
      await tester.pumpAndSettle();

      expect(find.text('40 · 40%'), findsOneWidget);
    });

    testWidgets('takes a second press on the same slice as a dismissal', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const PlPieChart(data: traffic, categories: sources, height: 240));

      final Offset inside =
          tester.getCenter(find.byType(CustomPaint).first) + const Offset(30, -50);

      await tester.tapAt(inside);
      await tester.pumpAndSettle();
      expect(find.text('40 · 40%'), findsOneWidget);

      await tester.tapAt(inside);
      await tester.pumpAndSettle();
      expect(find.text('40 · 40%'), findsNothing);
    });

    testWidgets('says nothing when the press lands off the disc', (WidgetTester tester) async {
      await _pump(tester, const PlPieChart(data: traffic, categories: sources, height: 240));

      await tester.tapAt(tester.getCenter(find.byType(CustomPaint).first) + const Offset(0, -119));
      await tester.pumpAndSettle();

      expect(find.textContaining('·'), findsNothing);
    });
  });
}
