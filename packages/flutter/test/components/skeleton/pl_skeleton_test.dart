import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

void main() {
  group('PlSkeleton', () {
    group('shape', () {
      testWidgets('a line is as tall as the type it stands in for', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlSkeleton(), width: 200));

        expect(tester.getSize(find.byType(PlSkeleton)).height, 13);
      });

      testWidgets('a circle is exactly an avatar at the same size', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlSkeleton(shape: PlSkeletonShape.circle, size: PlassSize.lg)),
        );

        expect(tester.getSize(find.byType(PlSkeleton)), const Size(48, 48));
      });

      testWidgets('a rect falls back to a thumbnail height', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlSkeleton(shape: PlSkeletonShape.rect), width: 200));

        expect(tester.getSize(find.byType(PlSkeleton)).height, 80);
      });

      testWidgets('takes an explicit width and height over either', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlSkeleton(shape: PlSkeletonShape.rect, width: 120, height: 40)),
        );

        expect(tester.getSize(find.byType(PlSkeleton)), const Size(120, 40));
      });
    });

    group('lines', () {
      testWidgets('draws one bar per line', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlSkeleton(lines: 3), width: 200));

        expect(find.byType(FractionallySizedBox), findsNWidgets(3));
      });

      testWidgets('draws the last line short, the way a paragraph ends', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlSkeleton(lines: 3), width: 200));

        final factors = tester
            .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
            .map((FractionallySizedBox box) => box.widthFactor)
            .toList();

        expect(factors, <double>[1, 1, 0.6]);
      });

      testWidgets('is one bar and no stack at a single line', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlSkeleton(), width: 200));

        expect(find.byType(FractionallySizedBox), findsNothing);
      });
    });

    group('surface', () {
      testWidgets('is a flat tint rather than glass', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlSkeleton(), width: 200));

        final fill = decorationWhere(
          tester,
          find.byType(PlSkeleton),
          (BoxDecoration decoration) => decoration.color != null,
        );

        expect(fill.color, PlassTokens.light().family(PlassColor.secondary).softHover);
        expect(fill.border, isNull);
        expect(fill.boxShadow, isNull);
      });

      testWidgets('defaults to the secondary family', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlSkeleton(color: PlassColor.info), width: 200));

        expect(
          decorationWhere(
            tester,
            find.byType(PlSkeleton),
            (BoxDecoration decoration) => decoration.color != null,
          ).color,
          PlassTokens.light().family(PlassColor.info).softHover,
        );
      });
    });

    group('animated', () {
      testWidgets('sweeps by default', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlSkeleton(), width: 200));

        expect(find.byType(AnimatedBuilder), findsWidgets);
        // Left running, so the frame scheduler has to be drained by hand.
        await tester.pump(const Duration(milliseconds: 100));
      });

      testWidgets('holds still when asked to', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlSkeleton(animated: false), width: 200));

        expect(find.byType(AnimatedBuilder), findsNothing);
      });
    });

    group('accessibility', () {
      testWidgets('says nothing by default', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlSkeleton(animated: false), width: 200));

        expect(find.bySemanticsLabel('Loading'), findsNothing);
        handle.dispose();
      });

      testWidgets('reports the wait when it is the one that speaks for the region', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const PlSkeleton(animated: false, label: 'Loading results'), width: 200),
        );

        expect(find.bySemanticsLabel('Loading results'), findsOneWidget);
        handle.dispose();
      });
    });
  });
}
