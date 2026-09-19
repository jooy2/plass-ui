// That every surface the design language says answers a pointer actually does.
//
// A test of a *contract* rather than of a widget, which is why it is here and
// not under `test/components/`. The light is two layers a widget has to hand
// four things to — where the pointer is, two colours and two visibilities — and
// a widget given three of them looks completely finished: the light simply
// never appears. Nothing else in the suite notices, because a missing bloom
// breaks no assertion anywhere.
//
// The second list is the half that keeps this honest. The light wants a surface
// big enough for a gradient to be a gradient, so a tick-scale control is
// deliberately without one, and an entry moved from the second list to the
// first has to be a decision somebody made rather than a line somebody copied.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/glow.dart';

import '../support/host.dart';

const List<PlSelectOption<String>> _cities = <PlSelectOption<String>>[
  PlSelectOption<String>(value: 'kr-11', label: Text('Seoul')),
  PlSelectOption<String>(value: 'jp-13', label: Text('Tokyo')),
];

const List<PlComboboxOption<String>> _options = <PlComboboxOption<String>>[
  PlComboboxOption<String>(value: 'kr-11', label: 'Seoul'),
  PlComboboxOption<String>(value: 'jp-13', label: 'Tokyo'),
];

const List<PlSegment<String>> _views = <PlSegment<String>>[
  PlSegment<String>(value: 'list', label: Text('List')),
  PlSegment<String>(value: 'board', label: Text('Board')),
];

/// One rendering per widget, built three ways: as it ships, held still by
/// `readOnly`, and taken out of reach by `disabled`.
typedef Build = Widget Function({bool disabled, bool readOnly});

final Map<String, Build> lit = <String, Build>{
  'PlTextField': ({bool disabled = false, bool readOnly = false}) =>
      PlTextField(label: const Text('City'), disabled: disabled, readOnly: readOnly),
  'PlNumberField': ({bool disabled = false, bool readOnly = false}) =>
      PlNumberField(value: null, label: const Text('Age'), disabled: disabled, readOnly: readOnly),
  'PlSelect': ({bool disabled = false, bool readOnly = false}) => PlSelect<String>(
    options: _cities,
    value: null,
    label: const Text('City'),
    onChanged: (String? value) {},
    disabled: disabled,
    readOnly: readOnly,
  ),
  'PlCombobox': ({bool disabled = false, bool readOnly = false}) => PlCombobox<String>(
    options: _options,
    value: null,
    label: const Text('City'),
    onChanged: (String? value) {},
    disabled: disabled,
    readOnly: readOnly,
  ),
  'PlDatePicker': ({bool disabled = false, bool readOnly = false}) => PlDatePicker(
    value: null,
    label: const Text('Day'),
    onChanged: (DateTime? value) {},
    disabled: disabled,
    readOnly: readOnly,
  ),
  'PlTimePicker': ({bool disabled = false, bool readOnly = false}) => PlTimePicker(
    value: null,
    label: const Text('Time'),
    onChanged: (DateTime? value) {},
    disabled: disabled,
    readOnly: readOnly,
  ),
  'PlColorPicker': ({bool disabled = false, bool readOnly = false}) => PlColorPicker(
    value: '#ff0000',
    label: const Text('Brand'),
    disabled: disabled,
    readOnly: readOnly,
  ),
  'PlFilePicker': ({bool disabled = false, bool readOnly = false}) => PlFilePicker(
    value: const <PlFile>[],
    onBrowse: () async => const <PlFile>[],
    onFilesChanged: (List<PlFile> files) {},
    disabled: disabled,
    readOnly: readOnly,
  ),
};

void main() {
  group('the interaction light', () {
    lit.forEach((String name, Build build) {
      testWidgets('$name carries both layers', (WidgetTester tester) async {
        await tester.pumpWidget(host(build(), width: 420));

        // The bloom and the press flash. One of the two missing is the usual
        // way this goes wrong, because they are handed over separately.
        expect(find.byType(PlassGlowLayer), findsNWidgets(2));
      });

      testWidgets('$name puts it out while it is disabled or read-only', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(build(disabled: true), width: 420));
        expect(find.byType(PlassGlowLayer), findsNothing);

        await tester.pumpWidget(host(build(readOnly: true), width: 420));
        expect(find.byType(PlassGlowLayer), findsNothing);
      });
    });

    testWidgets('a pressable PlChip carries it and a plain one does not', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(PlChip(onPressed: () {}, child: const Text('Seoul')), width: 420),
      );
      expect(find.byType(PlassGlowLayer), findsNWidgets(2));

      await tester.pumpWidget(host(const PlChip(child: Text('Seoul')), width: 420));
      expect(find.byType(PlassGlowLayer), findsNothing);
    });

    testWidgets('each segment of a PlSegmentedButton carries it', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlSegmentedButton<String>(segments: _views, value: 'list', onChanged: (String value) {}),
          width: 480,
        ),
      );

      expect(find.byType(PlassGlowLayer), findsNWidgets(4));
    });
  });

  // A tick, a radio and a switch track are the size of the text beside them,
  // and a bloom of the light's radius inside a 20px box is not a bloom — it is
  // a flat wash that moves, which reads as a rendering fault rather than as
  // light. The design language already draws this line for the edge a tick
  // takes; it is the same line.
  //
  // A `PlOtpField` is out for a reason of its own: its slots are separate boxes
  // with gaps between them, so there is no one surface for a light to cross.
  group('what the light is deliberately not on', () {
    final Map<String, Widget> unlit = <String, Widget>{
      'PlCheckbox': const PlCheckbox(value: false, label: Text('Remember me')),
      'PlSwitch': const PlSwitch(value: false, label: Text('Dark mode')),
      'PlRating': const PlRating(value: 3),
      'PlOtpField': const PlOtpField(),
    };

    unlit.forEach((String name, Widget widget) {
      testWidgets(name, (WidgetTester tester) async {
        await tester.pumpWidget(host(widget, width: 420));

        expect(find.byType(PlassGlowLayer), findsNothing);
      });
    });
  });
}
