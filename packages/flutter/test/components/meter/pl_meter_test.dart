import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(host(child, width: 300));
  await tester.pumpAndSettle();
}

/// How much of the groove is filled, as a fraction.
double _fill(WidgetTester tester) {
  return tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox)).widthFactor!;
}

/// The gradient the filled part was painted with.
Gradient _fillGradient(WidgetTester tester) {
  final RenderDecoratedBox box = tester.renderObject<RenderDecoratedBox>(
    find.descendant(of: find.byType(FractionallySizedBox), matching: find.byType(DecoratedBox)),
  );

  return (box.decoration as BoxDecoration).gradient!;
}

/// The first stop of that gradient, which is the family's `solid`.
Color _band(WidgetTester tester) {
  return (_fillGradient(tester) as LinearGradient).colors.first;
}

Color _solid(WidgetTester tester, PlassColor color) {
  return PlassTheme.of(tester.element(find.byType(PlMeter))).family(color).solid;
}

void main() {
  group('PlMeter', () {
    group('the quantity', () {
      testWidgets('fills the groove by the fraction of the range', (WidgetTester tester) async {
        await _pump(tester, const PlMeter(value: 40));

        expect(_fill(tester), closeTo(0.4, 0.0001));
      });

      testWidgets('reads the fraction against the range it was given', (WidgetTester tester) async {
        await _pump(tester, const PlMeter(value: 3, max: 4));

        expect(_fill(tester), closeTo(0.75, 0.0001));
      });

      testWidgets('clamps a value outside the range rather than overflowing', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const PlMeter(value: 140));

        expect(_fill(tester), 1);

        await _pump(tester, const PlMeter(value: -20));

        expect(_fill(tester), 0);
      });

      testWidgets('sits at nothing when the range is empty, and still says the value', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const PlMeter(value: 5, min: 10, max: 10, showValue: true));

        expect(_fill(tester), 0);
        expect(find.text('0%'), findsOneWidget);
      });
    });

    group('the value it writes out', () {
      testWidgets('is a percentage of the range when nothing said otherwise', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const PlMeter(value: 3, max: 4, showValue: true));

        expect(find.text('75%'), findsOneWidget);
      });

      testWidgets('takes `formatValue` when the number means something', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlMeter(
            value: 2,
            max: 8,
            showValue: true,
            formatValue: (double value) => '${value.toStringAsFixed(0)} GB',
          ),
        );

        expect(find.text('2 GB'), findsOneWidget);
        expect(find.text('25%'), findsNothing);
      });

      testWidgets('draws nothing at all unless it was asked to', (WidgetTester tester) async {
        await _pump(tester, const PlMeter(value: 30));

        expect(find.byType(Text), findsNothing);
      });
    });

    group('thresholds', () {
      const List<PlMeterThreshold> bands = <PlMeterThreshold>[
        PlMeterThreshold(from: 75, color: PlassColor.warning),
        PlMeterThreshold(from: 90, color: PlassColor.danger),
      ];

      testWidgets('takes the widget colour while the value is under all of them', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const PlMeter(value: 20, thresholds: bands));

        expect(_band(tester), _solid(tester, PlassColor.primary));
      });

      testWidgets('takes the highest band at or below the value', (WidgetTester tester) async {
        await _pump(tester, const PlMeter(value: 80, thresholds: bands));

        expect(_band(tester), _solid(tester, PlassColor.warning));

        await _pump(tester, const PlMeter(value: 95, thresholds: bands));

        expect(_band(tester), _solid(tester, PlassColor.danger));
      });

      testWidgets('does not care what order the bands were written in', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const PlMeter(
            value: 95,
            thresholds: <PlMeterThreshold>[
              PlMeterThreshold(from: 90, color: PlassColor.danger),
              PlMeterThreshold(from: 75, color: PlassColor.warning),
            ],
          ),
        );

        expect(_band(tester), _solid(tester, PlassColor.danger));
      });

      testWidgets('enters a band exactly at its own value', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlMeter(
            value: 75,
            thresholds: <PlMeterThreshold>[PlMeterThreshold(from: 75, color: PlassColor.warning)],
          ),
        );

        expect(_band(tester), _solid(tester, PlassColor.warning));
      });
    });

    group('semantics', () {
      testWidgets('carries the value it drew', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, const PlMeter(value: 3, max: 4, label: Text('Disk used')));

        // `SemanticsRole` has no meter, and claiming `progressBar` would
        // announce the one thing this widget exists to say it is not — so what
        // it reports is a named node with a value.
        expect(
          tester.getSemantics(find.byType(PlMeter)),
          matchesSemantics(label: 'Disk used', value: '75%'),
        );

        handle.dispose();
      });

      testWidgets('reads the value once when it is also drawn', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, const PlMeter(value: 40, label: Text('Disk used'), showValue: true));

        expect(
          tester.getSemantics(find.byType(PlMeter)),
          matchesSemantics(label: 'Disk used', value: '40%'),
        );

        handle.dispose();
      });
    });
  });
}
