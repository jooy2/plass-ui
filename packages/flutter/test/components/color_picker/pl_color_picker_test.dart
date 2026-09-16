import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
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

    testWidgets('groups an inline panel under its label, its description and its error', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          const SingleChildScrollView(
            child: Column(
              children: <Widget>[
                PlColorPicker(
                  inline: true,
                  value: '#ff0000',
                  label: Text('Accent'),
                  description: Text('Links and focus rings.'),
                  error: Text('Too light to read.'),
                ),
                PlColorPicker(inline: true, value: '#ffffff', label: Text('Background')),
              ],
            ),
          ),
          width: 400,
          height: 1200,
          overlay: true,
        ),
      );

      /// The nearest node above [node] that carries a name of its own.
      String groupOf(SemanticsNode node) {
        SemanticsNode? parent = node.parent;

        while (parent != null && parent.label.isEmpty) {
          parent = parent.parent;
        }

        return parent?.label ?? '';
      }

      // Two inline pickers are otherwise two sets of sliders called "Hue".
      final SemanticsNode accent = tester.getSemantics(find.bySemanticsLabel('Hue').at(0));
      final SemanticsNode background = tester.getSemantics(find.bySemanticsLabel('Hue').at(1));

      expect(groupOf(accent), 'Accent\nLinks and focus rings.\nToo light to read.');
      expect(groupOf(background), 'Background');
      expect(accent.getSemanticsData().validationResult, SemanticsValidationResult.invalid);
      expect(background.getSemanticsData().validationResult, SemanticsValidationResult.none);

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

    testWidgets('moves the rails with the vertical keys and Home and End too', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      String value = '#ff0000';

      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => PlColorPicker(
              inline: true,
              alpha: true,
              value: value,
              onValueChanged: (String next) => setState(() => value = next),
            ),
          ),
          width: 400,
          height: 560,
          overlay: true,
        ),
      );

      String now(String rail) =>
          tester.getSemantics(find.bySemanticsLabel(rail)).getSemanticsData().value;

      Future<void> press(String rail, LogicalKeyboardKey key) async {
        Focus.of(
          tester.element(
            find.descendant(of: find.bySemanticsLabel(rail), matching: find.byType(Stack)).first,
          ),
        ).requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(key);
        await tester.pump();
      }

      // The same keys every other slider answers: up is more, down is less, and
      // Home and End are the two ends.
      await press('Hue', LogicalKeyboardKey.arrowUp);
      expect(now('Hue'), '2');
      await press('Hue', LogicalKeyboardKey.arrowDown);
      expect(now('Hue'), '0');
      await press('Hue', LogicalKeyboardKey.end);
      expect(now('Hue'), '360');
      await press('Hue', LogicalKeyboardKey.home);
      expect(now('Hue'), '0');

      await press('Opacity', LogicalKeyboardKey.arrowDown);
      expect(now('Opacity'), '99');
      await press('Opacity', LogicalKeyboardKey.home);
      expect(now('Opacity'), '0');
      await press('Opacity', LogicalKeyboardKey.arrowUp);
      expect(now('Opacity'), '1');
      await press('Opacity', LogicalKeyboardKey.end);
      expect(now('Opacity'), '100');

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

    testWidgets('reaches a swatch with Tab and chooses it with Enter', (WidgetTester tester) async {
      final List<String> seen = <String>[];
      final FocusNode before = FocusNode();
      addTearDown(before.dispose);

      await tester.pumpWidget(
        host(
          afterFocusStop(
            before,
            PlColorPicker(
              inline: true,
              value: '#ff0000',
              swatches: const <String>['#22c55e', '#3b82f6'],
              onValueChanged: seen.add,
            ),
          ),
          width: 400,
          height: 500,
          overlay: true,
        ),
      );

      /// Whether the keyboard focus is on the swatch for [colour].
      bool onSwatch(String colour) {
        String? named;

        FocusManager.instance.primaryFocus?.context?.visitAncestorElements((Element element) {
          final Widget widget = element.widget;

          named = widget is Semantics ? widget.properties.label : null;

          return named == null;
        });

        return named == colour;
      }

      before.requestFocus();
      await tester.pump();

      // The square, the hue rail, the value field and the first swatch come first.
      for (var step = 0; step < 12 && !onSwatch('#3b82f6'); step += 1) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }

      expect(onSwatch('#3b82f6'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(seen.single, '#3b82f6');
    });

    testWidgets('centres a thumb on its value along the rail at every size', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      for (final PlassSize size in <PlassSize>[PlassSize.xs, PlassSize.xl]) {
        // Cyan is a hue of 180, halfway along the rail.
        await tester.pumpWidget(
          host(
            PlColorPicker(inline: true, value: '#00ffff', size: size),
            width: 400,
            height: 600,
            overlay: true,
          ),
        );

        final Finder rail = find
            .descendant(of: find.bySemanticsLabel('Hue'), matching: find.byType(Stack))
            .first;
        final Finder thumb = find.descendant(of: rail, matching: find.byType(IgnorePointer));

        expect(tester.getCenter(thumb).dx, closeTo(tester.getRect(rail).center.dx, 0.01));
      }

      handle.dispose();
    });

    testWidgets('centres a thumb on its value down the square and the rail at every size', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      // Teal is a brightness of about 50, so its thumb is about halfway down the
      // square, and a hue thumb sits halfway down its rail.
      const String teal = '#008080';
      final double down = 1 - parseColor(teal)!.hsv.v / 100;

      for (final PlassSize size in <PlassSize>[PlassSize.xs, PlassSize.xl]) {
        await tester.pumpWidget(
          host(
            PlColorPicker(inline: true, value: teal, size: size),
            width: 400,
            height: 600,
            overlay: true,
          ),
        );

        for (final (String label, double fraction) in <(String, double)>[
          ('Saturation and brightness', down),
          ('Hue', 0.5),
        ]) {
          // The `Stack` is the box inside the hairline border, which is what the
          // value is a fraction of.
          final Finder track = find
              .descendant(of: find.bySemanticsLabel(label), matching: find.byType(Stack))
              .first;
          final Finder thumb = find.descendant(of: track, matching: find.byType(IgnorePointer));
          final Rect box = tester.getRect(track);

          expect(tester.getCenter(thumb).dy, closeTo(box.top + box.height * fraction, 0.01));
        }
      }

      handle.dispose();
    });

    testWidgets('sets the value where the press landed', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final List<String> seen = <String>[];

      await tester.pumpWidget(
        host(
          PlColorPicker(inline: true, value: '#ff0000', onValueChanged: seen.add),
          width: 400,
          height: 600,
          overlay: true,
        ),
      );

      // The `Stack` is the box inside the hairline border, and the thumb is
      // placed across it, so a press on its leading edge is a hue of zero and
      // one on its far edge is the far end of the wheel. Read against the box
      // outside the border, each of them lands about a degree away.
      final Finder rail = find
          .descendant(of: find.bySemanticsLabel('Hue'), matching: find.byType(Stack))
          .first;
      final Rect box = tester.getRect(rail);

      await tester.tapAt(Offset(box.left, box.center.dy));
      await tester.pumpAndSettle();

      expect(seen.last, '#ff0000');

      await tester.tapAt(Offset(box.right, box.center.dy));
      await tester.pumpAndSettle();

      expect(seen.last, '#ff0000');

      handle.dispose();
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

    testWidgets('keeps the value field focused while a colour is typed into it', (
      WidgetTester tester,
    ) async {
      String value = '#ff0000';

      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => PlColorPicker(
              inline: true,
              value: value,
              onValueChanged: (String next) => setState(() => value = next),
            ),
          ),
          width: 400,
          height: 500,
          overlay: true,
        ),
      );

      await tester.showKeyboard(find.byType(EditableText));
      tester.testTextInput.enterText('#00f');
      await tester.pump();
      tester.testTextInput.enterText('#00ff00');
      await tester.pump();

      expect(value, '#00ff00');
      expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus, isTrue);
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

    testWidgets('leaves out a swatch it cannot read', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          const PlColorPicker(inline: true, value: '#ff0000', swatches: <String>['red', '#22c55e']),
          width: 400,
          height: 500,
          overlay: true,
        ),
      );

      expect(find.bySemanticsLabel('red'), findsNothing);
      expect(find.bySemanticsLabel('#22c55e'), findsOneWidget);

      await tester.pumpWidget(
        host(
          const PlColorPicker(inline: true, value: '#ff0000', swatches: <String>['red']),
          width: 400,
          height: 500,
          overlay: true,
        ),
      );

      // With nothing it can read, there is no group left to name.
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
