import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/watermark.dart';

import '../support/host.dart';

void main() {
  group('PlassWatermarkLayer', () {
    testWidgets('reaches every corner of a picture three times as wide as it is tall', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        host(
          const Stack(
            children: <Widget>[
              PlassWatermarkLayer(
                watermark: PlImageWatermark('PROOF', placement: PlImageWatermarkPlacement.tile),
              ),
            ],
          ),
          width: 1200,
          height: 400,
        ),
      );

      final RenderCustomPaint layer = tester.renderObject<RenderCustomPaint>(
        find.descendant(of: find.byType(PlassWatermarkLayer), matching: find.byType(CustomPaint)),
      );
      final Size size = layer.size;

      expect(size, const Size(1200, 400));

      // What the painter did, in the order it did it: where it moved the origin
      // to, how far it turned the canvas, and where it put every copy on the
      // turned canvas. The copies' own sizes are gone by the time this reads
      // them, because the painter disposes its text once it has drawn it.
      Offset middle = Offset.zero;
      double turn = 0;
      Rect? reach;

      expect(
        layer,
        paints..everything((Symbol method, List<dynamic> arguments) {
          if (method == #translate) {
            middle += Offset(arguments[0] as double, arguments[1] as double);
          } else if (method == #rotate) {
            turn += arguments[0] as double;
          } else if (method == #drawParagraph) {
            final Rect copy = Rect.fromPoints(arguments[1] as Offset, arguments[1] as Offset);

            reach = reach == null ? copy : reach!.expandToInclude(copy);
          }

          return true;
        }),
      );

      expect(turn, isNot(0));
      expect(reach, isNotNull);

      // Each corner of the box, brought onto the turned canvas the copies were
      // laid out on, has to have copies on both sides of it in both directions,
      // so the repeat runs on through it. A grid that is only oversized by a
      // share of each side stops short of the corners the turn swings furthest
      // out.
      for (final Offset corner in <Offset>[
        Offset.zero,
        Offset(size.width, 0),
        Offset(0, size.height),
        Offset(size.width, size.height),
      ]) {
        final Offset from = corner - middle;
        final Offset turned = Offset(
          from.dx * math.cos(turn) + from.dy * math.sin(turn),
          -from.dx * math.sin(turn) + from.dy * math.cos(turn),
        );

        expect(reach!.contains(turned), isTrue, reason: 'the corner at $corner is not covered');
      }
    });
  });
}
