import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// Where the child has drifted to, as a vertical offset from where it started.
double _drift(WidgetTester tester) {
  return tester.getTopLeft(find.text('Mark')).dy;
}

double _driftX(WidgetTester tester) {
  return tester.getTopLeft(find.text('Mark')).dx;
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(host(child, width: 200, height: 200));
  await tester.pump();
}

void main() {
  group('PlAnimateFloat', () {
    testWidgets('draws its child', (WidgetTester tester) async {
      await _pump(tester, const PlAnimateFloat(child: Text('Mark')));

      expect(find.text('Mark'), findsOneWidget);
    });

    testWidgets('starts where the child would have been', (WidgetTester tester) async {
      await _pump(tester, const PlAnimateFloat(child: Text('Mark')));

      final double home = _drift(tester);

      // Home at the start of the cycle, so nothing has moved before it began.
      await tester.pump(const Duration(milliseconds: 1));

      expect(_drift(tester), closeTo(home, 0.5));
    });

    testWidgets('drifts up and comes back', (WidgetTester tester) async {
      await _pump(tester, const PlAnimateFloat(child: Text('Mark')));

      final double home = _drift(tester);

      await tester.pump(const Duration(milliseconds: 1500));

      // Up, which is what floating means everywhere it is used.
      expect(_drift(tester), lessThan(home));

      await tester.pump(const Duration(milliseconds: 1500));

      // Symmetric: a run that ends leaves the widget where it found it.
      expect(_drift(tester), closeTo(home, 0.5));

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('takes a distance of its own', (WidgetTester tester) async {
      await _pump(tester, const PlAnimateFloat(distance: 40, child: Text('Mark')));

      final double home = _drift(tester);

      await tester.pump(const Duration(milliseconds: 1500));

      expect(home - _drift(tester), closeTo(40, 0.5));

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('drifts along the row when it was told to', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlAnimateFloat(orientation: PlassOrientation.horizontal, child: Text('Mark')),
      );

      final double home = _driftX(tester);
      final double top = _drift(tester);

      await tester.pump(const Duration(milliseconds: 1500));

      expect(_driftX(tester), greaterThan(home));
      expect(_drift(tester), closeTo(top, 0.5));

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('holds still where the platform asked for less motion', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const PlAnimateFloat(child: Text('Mark')),
          width: 200,
          height: 200,
          disableAnimations: true,
        ),
      );
      await tester.pump();

      final double home = _drift(tester);

      await tester.pump(const Duration(milliseconds: 1500));

      expect(_drift(tester), closeTo(home, 0.5));
    });
  });
}
