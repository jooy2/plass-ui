// What a field draws its `startIcon` in.
//
// A field's `startIcon` is in the muted ink whether it holds a glyph or a word,
// as the React field's start adornment is: its `text-(--plass-muted-fg)` is the
// `color` of everything inside it. A field that mutes only the icon theme
// leaves a currency sign or a unit written there in the page's ink, one step
// louder than the value it sits beside. Every field that takes a `startIcon` is
// here, so the next one is asked the same question.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

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

final Map<String, Widget Function()> _fields = <String, Widget Function()>{
  'PlTextField': () => const PlTextField(startIcon: _slot),
  'PlNumberField': () => const PlNumberField(value: 42, startIcon: _slot),
  'PlSelect': () => PlSelect<String>(
    options: const <PlSelectOption<String>>[
      PlSelectOption<String>(value: 'kr-11', label: Text('Seoul')),
    ],
    value: null,
    onChanged: (String? value) {},
    startIcon: _slot,
  ),
  'PlCombobox': () => PlCombobox<String>(
    options: const <PlComboboxOption<String>>[
      PlComboboxOption<String>(value: 'kr-11', label: 'Seoul'),
    ],
    value: null,
    onChanged: (String? value) {},
    startIcon: _slot,
  ),
  'PlDatePicker': () => const PlDatePicker(value: null, startIcon: _slot),
  'PlDateRangePicker': () => const PlDateRangePicker(value: PlDateRange(), startIcon: _slot),
  'PlDateTimePicker': () => const PlDateTimePicker(value: null, startIcon: _slot),
  'PlTimePicker': () => const PlTimePicker(value: null, startIcon: _slot),
  'PlTreeSelect': () => const PlTreeSelect(
    items: <PlTreeSelectNode>[PlTreeSelectNode(id: 'kr', label: 'Korea')],
    startIcon: _slot,
  ),
};

void main() {
  group('a field startIcon', () {
    for (final MapEntry<String, Widget Function()> field in _fields.entries) {
      testWidgets('is muted, the words as well as the glyph, on ${field.key}', (
        WidgetTester tester,
      ) async {
        _Glyph.seen = null;

        await tester.pumpWidget(host(field.value(), width: 400));

        final Color muted = PlassTokens.light().mutedFg;

        expect(_Glyph.seen, muted);
        expect(styleOf(tester, 'KRW').color, muted);
      });
    }
  });
}
