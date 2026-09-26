import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/wedge.dart';
import 'package:plass_ui/src/types.dart';

import '../support/host.dart';

const Key sheetKey = Key('sheet');

/// A sheet with its wedge on [side], and where each of the two landed.
Future<({Rect sheet, Rect wedge})> wedged(
  WidgetTester tester, {
  required PlassSide side,
  required TextDirection direction,
}) async {
  await tester.pumpWidget(
    host(
      PlassWedged(
        side: side,
        size: 12,
        fill: const Color(0xFFFFFFFF),
        line: const Color(0xFF000000),
        child: const SizedBox(key: sheetKey, width: 100, height: 60),
      ),
      textDirection: direction,
    ),
  );

  return (
    sheet: tester.getRect(find.byKey(sheetKey)),
    wedge: tester.getRect(
      find.descendant(of: find.byType(PlassWedged), matching: find.byType(CustomPaint)),
    ),
  );
}

void main() {
  group('PlassWedged', () {
    // A side is a side of the screen, so the wedge is on it in either writing
    // direction, a hairline into the sheet.
    for (final TextDirection direction in TextDirection.values) {
      testWidgets('points right from a sheet on the left under $direction', (
        WidgetTester tester,
      ) async {
        final placed = await wedged(tester, side: PlassSide.left, direction: direction);

        expect(placed.wedge.left, placed.sheet.right - 1);
        expect(placed.wedge.center.dy, placed.sheet.center.dy);
      });

      testWidgets('points left from a sheet on the right under $direction', (
        WidgetTester tester,
      ) async {
        final placed = await wedged(tester, side: PlassSide.right, direction: direction);

        expect(placed.wedge.right, placed.sheet.left + 1);
        expect(placed.wedge.center.dy, placed.sheet.center.dy);
      });

      testWidgets('points down from a sheet above under $direction', (WidgetTester tester) async {
        final placed = await wedged(tester, side: PlassSide.top, direction: direction);

        expect(placed.wedge.top, placed.sheet.bottom - 1);
        expect(placed.wedge.center.dx, placed.sheet.center.dx);
      });

      testWidgets('points up from a sheet below under $direction', (WidgetTester tester) async {
        final placed = await wedged(tester, side: PlassSide.bottom, direction: direction);

        expect(placed.wedge.bottom, placed.sheet.top + 1);
        expect(placed.wedge.center.dx, placed.sheet.center.dx);
      });
    }
  });
}
