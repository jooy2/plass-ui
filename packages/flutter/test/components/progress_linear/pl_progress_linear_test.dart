import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// What a screen reader is actually handed.
///
/// `SemanticsNode`'s own fields are the node's *unmerged* config, and everything
/// this component says lives one level down inside its merge boundary — so the
/// question is only ever about the merged data.
SemanticsData merged(WidgetTester tester, Finder finder) {
  return tester.getSemantics(finder).getSemanticsData();
}

/// The filled segment: the one box in the bar with a gradient in it.
Finder _fill() {
  return find.descendant(
    of: find.byType(PlProgressLinear),
    matching: find.byWidgetPredicate(
      (Widget widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).gradient != null,
    ),
  );
}

/// The width it was actually laid out at.
double _fillWidth(WidgetTester tester) => tester.getSize(_fill()).width;

void main() {
  group('PlProgressLinear', () {
    group('the groove', () {
      testWidgets('is as thick as its size says and no thicker', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressLinear(value: 40), width: 320));

        final double medium = tester.getSize(find.byType(ClipRRect).first).height;

        await tester.pumpWidget(
          host(const PlProgressLinear(value: 40, size: PlassSize.xl), width: 320),
        );

        expect(tester.getSize(find.byType(ClipRRect).first).height, greaterThan(medium));
      });

      testWidgets('fills in proportion to the value', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressLinear(value: 25), width: 320));
        await tester.pumpAndSettle();

        expect(_fillWidth(tester), closeTo(80, 0.5));

        await tester.pumpWidget(host(const PlProgressLinear(value: 75), width: 320));
        await tester.pumpAndSettle();

        expect(_fillWidth(tester), closeTo(240, 0.5));
      });

      testWidgets('reads the value against its own range', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressLinear(value: 3, max: 4), width: 320));
        await tester.pumpAndSettle();

        expect(_fillWidth(tester), closeTo(240, 0.5));
      });

      testWidgets('clamps a value past either end of the range', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressLinear(value: 180), width: 320));
        await tester.pumpAndSettle();

        expect(_fillWidth(tester), closeTo(320, 0.5));

        await tester.pumpWidget(host(const PlProgressLinear(value: -40), width: 320));
        await tester.pumpAndSettle();

        expect(_fillWidth(tester), closeTo(0, 0.5));
      });

      testWidgets('is cut in the neutral groove ink, not the family wash', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlProgressLinear(value: 40), width: 320));

        final PlassTokens tokens = PlassTheme.of(tester.element(find.byType(PlProgressLinear)));
        final BoxDecoration groove = decorationWhere(
          tester,
          find.byType(PlProgressLinear),
          (BoxDecoration decoration) => decoration.color != null,
        );

        expect(groove.color, equals(tokens.track));
      });

      testWidgets('fills with the family gradient', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlProgressLinear(value: 40, color: PlassColor.success), width: 320),
        );

        final PlassTokens tokens = PlassTheme.of(tester.element(find.byType(PlProgressLinear)));
        final BoxDecoration fill = decorationWhere(
          tester,
          find.byType(PlProgressLinear),
          (BoxDecoration decoration) => decoration.gradient != null,
        );

        expect(fill.gradient, equals(tokens.family(PlassColor.success).fill));
      });
    });

    group('indeterminate', () {
      testWidgets('sweeps when it has no value', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressLinear(), width: 320));
        await tester.pump(const Duration(milliseconds: 100));

        final double first = tester.getTopLeft(_fill()).dx;

        await tester.pump(const Duration(milliseconds: 300));

        final double later = tester.getTopLeft(_fill()).dx;

        expect(later, isNot(closeTo(first, 0.5)));

        // Left running, so the tree is torn down rather than left pumping.
        await tester.pumpWidget(host(const SizedBox.shrink()));
      });

      testWidgets('covers only part of the groove while it travels', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressLinear(), width: 320));
        await tester.pump(const Duration(milliseconds: 100));

        expect(_fillWidth(tester), closeTo(320 * 0.45, 0.5));

        await tester.pumpWidget(host(const SizedBox.shrink()));
      });

      testWidgets('holds still and fills the groove under reduced motion', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlProgressLinear(), width: 320, disableAnimations: true),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(_fillWidth(tester), closeTo(320, 0.5));

        await tester.pumpWidget(host(const SizedBox.shrink()));
      });

      testWidgets('stops sweeping once it is given a value', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressLinear(), width: 320));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.pumpWidget(host(const PlProgressLinear(value: 50), width: 320));
        await tester.pumpAndSettle();

        expect(_fillWidth(tester), closeTo(160, 0.5));
      });
    });

    group('the value', () {
      testWidgets('draws a percentage of the range rather than of 100', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlProgressLinear(value: 3, max: 4, showValue: true), width: 320),
        );

        expect(find.text('75%'), findsOneWidget);
      });

      testWidgets('draws nothing while there is nothing to say', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlProgressLinear(showValue: true), width: 320));

        expect(find.textContaining('%'), findsNothing);

        await tester.pumpWidget(host(const SizedBox.shrink()));
      });

      testWidgets('writes the value the caller’s own way when told how', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlProgressLinear(
              value: 148,
              max: 512,
              showValue: true,
              formatValue: (double value) => '${value.round()} MB',
            ),
            width: 320,
          ),
        );

        expect(find.text('148 MB'), findsOneWidget);
      });

      testWidgets('draws the label beside it', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlProgressLinear(value: 40, label: Text('Uploading'), showValue: true),
            width: 320,
          ),
        );

        expect(find.text('Uploading'), findsOneWidget);
        expect(
          tester.getTopLeft(find.text('Uploading')).dx,
          lessThan(tester.getTopLeft(find.text('40%')).dx),
        );
      });
    });

    group('accessibility', () {
      testWidgets('is a progress bar carrying its value', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const PlProgressLinear(value: 3, max: 4, label: Text('Uploading')), width: 320),
        );

        // The merge boundary the component draws, which is the node a screen
        // reader is actually handed.
        final SemanticsData node = merged(tester, find.byType(PlProgressLinear));

        expect(node.role, equals(SemanticsRole.progressBar));
        expect(node.value, equals('75%'));
        // Merged, so the label and the bar are one node rather than a name
        // floating beside an unnamed progress bar.
        expect(node.label, equals('Uploading'));

        handle.dispose();
      });

      testWidgets('says it is indeterminate rather than saying zero', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlProgressLinear(label: Text('Working')), width: 320));

        final SemanticsData node = merged(tester, find.byType(PlProgressLinear));

        expect(node.role, equals(SemanticsRole.loadingSpinner));
        expect(node.value, isEmpty);
        expect(node.label, equals('Working'));

        handle.dispose();
        await tester.pumpWidget(host(const SizedBox.shrink()));
      });

      testWidgets('reads the drawn value once, not twice', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const PlProgressLinear(value: 40, showValue: true), width: 320),
        );

        // The drawn number is excluded, so `40%` is the node's value and not
        // also its label.
        final SemanticsData node = merged(tester, find.byType(PlProgressLinear));

        expect(node.value, equals('40%'));
        expect(node.label, isEmpty);

        handle.dispose();
      });
    });
  });
}
