import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/color.dart';

import '../../support/host.dart';

void main() {
  group('colour arithmetic', () {
    test('reads hex in all four lengths', () {
      expect(formatColor(parseColor('#f00')!.hsv, 1, PlColorFormat.hex), '#ff0000');
      expect(formatColor(parseColor('#ff0000')!.hsv, 1, PlColorFormat.hex), '#ff0000');
      expect(parseColor('#ff000080')!.alpha, closeTo(0.5, 0.01));
      expect(parseColor('#f008')!.alpha, closeTo(0.53, 0.01));
    });

    test('reads rgb and hsl in both syntaxes', () {
      expect(formatColor(parseColor('rgb(255, 0, 0)')!.hsv, 1, PlColorFormat.hex), '#ff0000');
      expect(formatColor(parseColor('rgb(255 0 0)')!.hsv, 1, PlColorFormat.hex), '#ff0000');
      expect(formatColor(parseColor('hsl(120, 100%, 50%)')!.hsv, 1, PlColorFormat.hex), '#00ff00');
      expect(parseColor('rgba(255, 0, 0, 0.5)')!.alpha, closeTo(0.5, 0.001));
      expect(parseColor('rgb(255 0 0 / 50%)')!.alpha, closeTo(0.5, 0.001));
    });

    test('refuses what it could not write back', () {
      expect(parseColor('rebeccapurple'), isNull);
      expect(parseColor('not a colour'), isNull);
      expect(parseColor(''), isNull);
    });

    test('drops the fourth channel when the colour is opaque', () {
      final PlassHsv red = parseColor('#ff0000')!.hsv;

      expect(formatColor(red, 1, PlColorFormat.rgb), 'rgb(255, 0, 0)');
      expect(formatColor(red, 0.5, PlColorFormat.rgb), 'rgba(255, 0, 0, 0.5)');
      expect(formatColor(red, 1, PlColorFormat.hsl), 'hsl(0, 100%, 50%)');
      expect(formatColor(red, 1, PlColorFormat.hex), '#ff0000');
      expect(formatColor(red, 0.5, PlColorFormat.hex), '#ff000080');
    });

    test('keeps the hue of a colour that has no colour left', () {
      // Through RGB every shade of black is the same colour; the model is what
      // remembers that this black was a blue one.
      const PlassHsv black = PlassHsv(217, 87, 0);

      expect(black.h, 217);
      expect(formatColor(black, 1, PlColorFormat.hex), '#000000');
    });

    test('picks the ink that can be read on the swatch', () {
      expect(readableInk(parseColor('#fde68a')!.hsv), const Color(0xFF000000));
      expect(readableInk(parseColor('#0f172a')!.hsv), const Color(0xFFFFFFFF));
    });
  });

  group('PlColorPicker', () {
    testWidgets('shows the colour it is holding', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PlColorPicker(value: '#ff0000'), width: 400, height: 300, overlay: true),
      );

      expect(find.text('#ff0000'), findsOneWidget);
    });

    testWidgets('says so when there is nothing to show', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PlColorPicker(value: ''), width: 400, height: 300, overlay: true),
      );

      expect(find.text('Pick a colour'), findsOneWidget);
    });

    testWidgets('draws the panel in the screen when it is inline', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          const PlColorPicker(inline: true, value: '#ff0000'),
          width: 400,
          height: 500,
          overlay: true,
        ),
      );

      expect(find.bySemanticsLabel('Saturation and brightness'), findsOneWidget);
      expect(find.bySemanticsLabel('Hue'), findsOneWidget);
      // No opacity rail unless it is asked for.
      expect(find.bySemanticsLabel('Opacity'), findsNothing);

      handle.dispose();
    });

    testWidgets('names the parts that have no text on them', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          const PlColorPicker(inline: true, alpha: true, value: '#ff0000'),
          width: 400,
          height: 560,
          overlay: true,
        ),
      );

      expect(find.bySemanticsLabel('Opacity'), findsOneWidget);
      expect(find.bySemanticsLabel('Colour value'), findsOneWidget);
      expect(find.bySemanticsLabel('Swatches'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('reports the square s two channels together', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          const PlColorPicker(inline: true, value: '#ff0000'),
          width: 400,
          height: 500,
          overlay: true,
        ),
      );

      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Saturation and brightness'))
            .getSemanticsData()
            .value,
        '100%, 100%',
      );
      expect(tester.getSemantics(find.bySemanticsLabel('Hue')).getSemanticsData().value, '0');

      handle.dispose();
    });

    testWidgets('walks the hue round rather than stopping at the ends', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final List<String> seen = <String>[];

      await tester.pumpWidget(
        host(
          PlColorPicker(inline: true, value: '#ff0000', onValueChanged: seen.add),
          width: 400,
          height: 500,
          overlay: true,
        ),
      );

      final SemanticsNode hue = tester.getSemantics(find.bySemanticsLabel('Hue'));
      hue.owner!.performAction(hue.id, SemanticsAction.decrease);
      await tester.pump();

      // Red is 0°, and a step back is 358° rather than 0°.
      expect(seen.single, '#ff0008');

      handle.dispose();
    });

    testWidgets('changes the colour when a swatch is pressed', (WidgetTester tester) async {
      final List<String> seen = <String>[];

      await tester.pumpWidget(
        host(
          PlColorPicker(
            inline: true,
            value: '#ff0000',
            swatches: const <String>['#22c55e'],
            onValueChanged: seen.add,
          ),
          width: 400,
          height: 500,
          overlay: true,
        ),
      );

      await tester.tap(find.bySemanticsLabel('#22c55e'));
      await tester.pumpAndSettle();

      expect(seen.single, '#22c55e');
    });

    testWidgets('writes the format it was asked for', (WidgetTester tester) async {
      final List<String> seen = <String>[];

      await tester.pumpWidget(
        host(
          PlColorPicker(
            inline: true,
            value: '#ff0000',
            format: PlColorFormat.rgb,
            swatches: const <String>['#22c55e'],
            onValueChanged: seen.add,
          ),
          width: 400,
          height: 500,
          overlay: true,
        ),
      );

      await tester.tap(find.bySemanticsLabel('#22c55e'));
      await tester.pumpAndSettle();

      expect(seen.single, 'rgb(34, 197, 94)');
    });

    testWidgets('draws none at all when it is told to', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          const PlColorPicker(inline: true, value: '#ff0000', swatches: <String>[]),
          width: 400,
          height: 500,
          overlay: true,
        ),
      );

      expect(find.bySemanticsLabel('Swatches'), findsNothing);

      handle.dispose();
    });

    testWidgets('takes nothing while it is read-only', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final List<String> seen = <String>[];

      await tester.pumpWidget(
        host(
          PlColorPicker(
            inline: true,
            readOnly: true,
            value: '#ff0000',
            swatches: const <String>['#22c55e'],
            onValueChanged: seen.add,
          ),
          width: 400,
          height: 500,
          overlay: true,
        ),
      );

      await tester.tap(find.bySemanticsLabel('#22c55e'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(seen, isEmpty);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Hue'))
            .getSemanticsData()
            .hasAction(SemanticsAction.increase),
        isFalse,
      );

      handle.dispose();
    });
  });
}
