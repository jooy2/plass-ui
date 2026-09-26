// What a field draws its adornments in.
//
// A field's `startIcon` and `endIcon` are drawn as the React field's are: its
// adornment is a box one line of the field's type tall, `h-[1lh]`, inside a
// shell whose `text-[x]/[y]` sets the size and the line of everything in it,
// and whose `text-(--plass-muted-fg)` is the `color` of everything in the box.
// So a word there is in the muted ink and at the size the value is, and a
// picture taller than a line hangs over the box rather than making the field
// taller. A field that mutes only the icon theme leaves a currency sign or a
// unit written there in the page's ink, one step louder than the value beside
// it, and one that sizes only the icon theme leaves it at Flutter's default 14
// whatever the field's `size`. Every field that takes an adornment is here, so
// the next one is asked the same questions.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/scales.dart';

import '../support/host.dart';

/// A glyph with no colour of its own, recording the one it is handed.
class _Glyph extends StatelessWidget {
  const _Glyph();

  static Color? seen;

  @override
  Widget build(BuildContext context) {
    seen = IconTheme.of(context).color;

    return const SizedBox.square(dimension: 12);
  }
}

/// A glyph and a word, which is what a `startIcon` holds when it is a unit.
const Widget _slot = Row(mainAxisSize: MainAxisSize.min, children: <Widget>[_Glyph(), Text('KRW')]);

/// A picture taller than any field's line.
const Widget _tall = SizedBox(width: 12, height: 64);

/// The sizes the type is checked at: the one where a 14 is clipped, the
/// default, and one above it.
const List<PlassSize> _sizes = <PlassSize>[PlassSize.xs, PlassSize.md, PlassSize.lg];

/// Every field that takes a `startIcon`, built at [size] with [start] in it.
final Map<String, Widget Function(PlassSize size, Widget start)> _fields =
    <String, Widget Function(PlassSize size, Widget start)>{
      'PlTextField': (PlassSize size, Widget start) => PlTextField(size: size, startIcon: start),
      'PlNumberField': (PlassSize size, Widget start) =>
          PlNumberField(value: 42, size: size, startIcon: start),
      'PlSelect': (PlassSize size, Widget start) => PlSelect<String>(
        options: const <PlSelectOption<String>>[
          PlSelectOption<String>(value: 'kr-11', label: Text('Seoul')),
        ],
        value: null,
        onChanged: (String? value) {},
        size: size,
        startIcon: start,
      ),
      'PlCombobox': (PlassSize size, Widget start) => PlCombobox<String>(
        options: const <PlComboboxOption<String>>[
          PlComboboxOption<String>(value: 'kr-11', label: 'Seoul'),
        ],
        value: null,
        onChanged: (String? value) {},
        size: size,
        startIcon: start,
      ),
      'PlDatePicker': (PlassSize size, Widget start) =>
          PlDatePicker(value: null, size: size, startIcon: start),
      'PlDateRangePicker': (PlassSize size, Widget start) =>
          PlDateRangePicker(value: const PlDateRange(), size: size, startIcon: start),
      'PlDateTimePicker': (PlassSize size, Widget start) =>
          PlDateTimePicker(value: null, size: size, startIcon: start),
      'PlTimePicker': (PlassSize size, Widget start) =>
          PlTimePicker(value: null, size: size, startIcon: start),
      'PlTreeSelect': (PlassSize size, Widget start) => PlTreeSelect(
        items: const <PlTreeSelectNode>[PlTreeSelectNode(id: 'kr', label: 'Korea')],
        size: size,
        startIcon: start,
      ),
    };

/// Every field that takes an `endIcon`, built at [size] with [end] in it.
final Map<String, Widget Function(PlassSize size, Widget end)> _endFields =
    <String, Widget Function(PlassSize size, Widget end)>{
      'PlTextField': (PlassSize size, Widget end) => PlTextField(size: size, endIcon: end),
      'PlNumberField': (PlassSize size, Widget end) =>
          PlNumberField(value: 42, size: size, endIcon: end),
    };

const Key _field = ValueKey<String>('field');

void main() {
  group('a field startIcon', () {
    for (final MapEntry<String, Widget Function(PlassSize, Widget)> field in _fields.entries) {
      testWidgets('is muted, the words as well as the glyph, on ${field.key}', (
        WidgetTester tester,
      ) async {
        _Glyph.seen = null;

        await tester.pumpWidget(host(field.value(PlassSize.md, _slot), width: 400));

        final Color muted = PlassTokens.light().mutedFg;

        expect(_Glyph.seen, muted);
        expect(styleOf(tester, 'KRW').color, muted);
      });

      for (final PlassSize size in _sizes) {
        testWidgets('sets its words in the field type on ${field.key} at ${size.name}', (
          WidgetTester tester,
        ) async {
          await tester.pumpWidget(host(field.value(size, _slot), width: 400));

          final PlassTextScale scale = controlTextLeading[size]!;
          final TextStyle style = styleOf(tester, 'KRW');

          expect(style.fontSize, scale.size);
          expect(style.height, scale.height);
          expect(tester.getSize(find.text('KRW')).height, moreOrLessEquals(scale.line));
        });

        testWidgets('is held to one line on ${field.key} at ${size.name}', (
          WidgetTester tester,
        ) async {
          await tester.pumpWidget(
            host(KeyedSubtree(key: _field, child: field.value(size, _tall)), width: 400),
          );

          expect(tester.getSize(find.byKey(_field)).height, controlHeight[size]);
        });
      }
    }
  });

  group('a field endIcon', () {
    for (final MapEntry<String, Widget Function(PlassSize, Widget)> field in _endFields.entries) {
      for (final PlassSize size in _sizes) {
        testWidgets('sets its words muted and in the field type on ${field.key} at ${size.name}', (
          WidgetTester tester,
        ) async {
          await tester.pumpWidget(host(field.value(size, const Text('kg')), width: 400));

          final PlassTextScale scale = controlTextLeading[size]!;
          final TextStyle style = styleOf(tester, 'kg');

          expect(style.color, PlassTokens.light().mutedFg);
          expect(style.fontSize, scale.size);
          expect(style.height, scale.height);
          expect(tester.getSize(find.text('kg')).height, moreOrLessEquals(scale.line));
        });

        testWidgets('is held to one line on ${field.key} at ${size.name}', (
          WidgetTester tester,
        ) async {
          await tester.pumpWidget(
            host(KeyedSubtree(key: _field, child: field.value(size, _tall)), width: 400),
          );

          expect(tester.getSize(find.byKey(_field)).height, controlHeight[size]);
        });
      }
    }
  });
}
