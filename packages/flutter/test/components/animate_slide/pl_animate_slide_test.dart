import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

Offset fractionOf(WidgetTester tester) {
  return tester
      .widget<FractionalTranslation>(
        find.descendant(
          of: find.byType(PlAnimateSlide),
          matching: find.byType(FractionalTranslation),
        ),
      )
      .translation;
}

Offset pixelsOf(WidgetTester tester) {
  final Transform moved = tester.widget<Transform>(
    find.descendant(of: find.byType(PlAnimateSlide), matching: find.byType(Transform)),
  );

  return Offset(moved.transform.storage[12], moved.transform.storage[13]);
}

void main() {
  group('PlAnimateSlide', () {
    group('from', () {
      testWidgets('comes up from below by default, its own height away', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlAnimateSlide(child: Text('Arriving'))));

        expect(fractionOf(tester), const Offset(0, 1));
      });

      testWidgets('travels the other way from the top', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlAnimateSlide(from: PlassSide.top, child: Text('Arriving'))),
        );

        expect(fractionOf(tester), const Offset(0, -1));
      });

      testWidgets('moves along the other axis from the left', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlAnimateSlide(from: PlassSide.left, distance: 40, child: Text('Arriving'))),
        );

        expect(pixelsOf(tester), const Offset(-40, 0));
      });

      testWidgets('takes a physical right edge, not a logical end', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlAnimateSlide(from: PlassSide.right, distance: 40, child: Text('Arriving')),
            textDirection: TextDirection.rtl,
          ),
        );

        expect(pixelsOf(tester), const Offset(40, 0));
      });
    });

    testWidgets('arrives where it belongs once the run is over', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateSlide(
            distance: 40,
            duration: Duration(milliseconds: 200),
            child: Text('Arriving'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(pixelsOf(tester), Offset.zero);
    });

    testWidgets('measures its own size when nobody gave a distance', (WidgetTester tester) async {
      await tester.pumpWidget(host(const PlAnimateSlide(child: Text('Arriving'))));

      expect(
        find.descendant(of: find.byType(PlAnimateSlide), matching: find.byType(Transform)),
        findsNothing,
      );
    });

    testWidgets('leaves by the edge it would have come from', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateSlide(
            mode: PlassAnimateMode.exit,
            from: PlassSide.left,
            duration: Duration(milliseconds: 200),
            child: Text('Leaving'),
          ),
        ),
      );

      expect(fractionOf(tester), Offset.zero);

      await tester.pumpAndSettle();

      expect(fractionOf(tester), const Offset(-1, 0));
    });

    testWidgets('draws no opacity layer at all when the fade is off', (WidgetTester tester) async {
      await tester.pumpWidget(host(const PlAnimateSlide(fade: false, child: Text('Arriving'))));

      expect(
        find.descendant(of: find.byType(PlAnimateSlide), matching: find.byType(Opacity)),
        findsNothing,
      );
    });

    testWidgets('is simply there where the platform has asked for less movement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const PlAnimateSlide(child: Text('Arriving')), disableAnimations: true),
      );

      expect(fractionOf(tester), Offset.zero);
    });
  });
}
