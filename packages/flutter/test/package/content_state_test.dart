// That a control drawn on a `PlassSurfaceBox` keeps what it holds as it is made
// read-only and disabled.
//
// Both states change how a control looks and what it does: the gloss of a glass
// surface goes, the interaction light is put out, a pressable chip stops being
// pressable and a number field puts its steppers away. None of that may change
// the shape of the tree above what the control holds, because Flutter builds a
// changed shape again from scratch — a stateful slot would start over, and an
// editor would come back as a new one. What is checked here is the content's
// own `State`, kept across both, on every variant of every control.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/host.dart';

/// A slot with a `State` of its own: built again from scratch, it is a different
/// object.
class _Probe extends StatefulWidget {
  const _Probe();

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => const Text('Seoul');
}

const List<PlSelectOption<String>> _cities = <PlSelectOption<String>>[
  PlSelectOption<String>(value: 'kr-11', label: Text('Seoul')),
  PlSelectOption<String>(value: 'jp-13', label: Text('Tokyo')),
];

const List<PlComboboxOption<String>> _options = <PlComboboxOption<String>>[
  PlComboboxOption<String>(value: 'kr-11', label: 'Seoul'),
  PlComboboxOption<String>(value: 'jp-13', label: 'Tokyo'),
];

/// One control on one variant, built as it ships, held still by `readOnly`
/// where it has one, and taken out of reach by `disabled`.
typedef Build = Widget Function(PlassVariant variant, {bool disabled, bool readOnly});

/// A control, what in it has to survive, and what is typed into it first.
class _Control {
  const _Control(this.build, {this.readOnly = true, this.editor = false, this.typed});

  final Build build;

  /// Whether the control has a `readOnly` to change.
  final bool readOnly;

  /// Whether what has to survive is the control's editor rather than a
  /// [_Probe] in one of its slots.
  final bool editor;

  /// What is typed into the editor before the state changes, and has to be
  /// there after, or `null` to type nothing.
  final String? typed;

  Finder get held => editor ? find.byType(EditableText) : find.byType(_Probe);
}

final Map<String, _Control> _controls = <String, _Control>{
  'PlChip': _Control(
    (PlassVariant variant, {bool disabled = false, bool readOnly = false}) =>
        PlChip(variant: variant, disabled: disabled, child: const _Probe()),
    readOnly: false,
  ),
  'pressable PlChip': _Control(
    (PlassVariant variant, {bool disabled = false, bool readOnly = false}) =>
        PlChip(variant: variant, disabled: disabled, onPressed: () {}, child: const _Probe()),
    readOnly: false,
  ),
  'PlToggle': _Control(
    (PlassVariant variant, {bool disabled = false, bool readOnly = false}) =>
        PlToggle(variant: variant, disabled: disabled, child: const _Probe()),
    readOnly: false,
  ),
  'PlTextField': _Control(
    (PlassVariant variant, {bool disabled = false, bool readOnly = false}) =>
        PlTextField(variant: variant, fullWidth: true, disabled: disabled, readOnly: readOnly),
    editor: true,
    typed: 'Seoul',
  ),
  'PlSelect': _Control(
    (PlassVariant variant, {bool disabled = false, bool readOnly = false}) => PlSelect<String>(
      options: _cities,
      value: null,
      variant: variant,
      startIcon: const _Probe(),
      onChanged: (String? value) {},
      disabled: disabled,
      readOnly: readOnly,
    ),
  ),
  'PlCombobox': _Control(
    (PlassVariant variant, {bool disabled = false, bool readOnly = false}) => PlCombobox<String>(
      options: _options,
      value: null,
      variant: variant,
      fullWidth: true,
      onChanged: (String? value) {},
      disabled: disabled,
      readOnly: readOnly,
    ),
    editor: true,
    typed: 'Seo',
  ),
  // Held rather than typed: a number field goes back to the value its parent
  // holds when the focus leaves it, as it does when the field is disabled, and
  // that is not what is being asked here.
  'PlNumberField': _Control(
    (PlassVariant variant, {bool disabled = false, bool readOnly = false}) => PlNumberField(
      value: 42,
      variant: variant,
      fullWidth: true,
      disabled: disabled,
      readOnly: readOnly,
    ),
    editor: true,
  ),
  'split PlNumberField': _Control(
    (PlassVariant variant, {bool disabled = false, bool readOnly = false}) => PlNumberField(
      value: 42,
      variant: variant,
      steppers: PlNumberFieldSteppers.split,
      fullWidth: true,
      disabled: disabled,
      readOnly: readOnly,
    ),
    editor: true,
  ),
  'PlFilePicker': _Control(
    (PlassVariant variant, {bool disabled = false, bool readOnly = false}) => PlFilePicker(
      value: const <PlFile>[],
      variant: variant,
      title: const _Probe(),
      onBrowse: () async => const <PlFile>[],
      onFilesChanged: (List<PlFile> files) {},
      disabled: disabled,
      readOnly: readOnly,
    ),
  ),
};

void main() {
  group('what a control holds', () {
    _controls.forEach((String name, _Control control) {
      for (final PlassVariant variant in PlassVariant.values) {
        final String made = control.readOnly ? 'made read-only and disabled' : 'disabled';

        testWidgets('survives a ${variant.name} $name being $made', (WidgetTester tester) async {
          Widget build({bool disabled = false, bool readOnly = false}) {
            return host(
              control.build(variant, disabled: disabled, readOnly: readOnly),
              width: 320,
              overlay: true,
            );
          }

          await tester.pumpWidget(build());

          final String? typed = control.typed;

          if (typed != null) {
            await tester.enterText(control.held, typed);
            await tester.pump();

            // And the first two letters of it chosen.
            tester.widget<EditableText>(control.held).controller.selection = const TextSelection(
              baseOffset: 0,
              extentOffset: 2,
            );
            await tester.pump();
          }

          final State held = tester.state(control.held);

          for (final (String reason, bool disabled, bool readOnly) in <(String, bool, bool)>[
            if (control.readOnly) ...<(String, bool, bool)>[
              ('read-only', false, true),
              ('writable again', false, false),
            ],
            ('disabled', true, false),
            ('enabled again', false, false),
          ]) {
            await tester.pumpWidget(build(disabled: disabled, readOnly: readOnly));
            await tester.pumpAndSettle();

            expect(tester.state(control.held), same(held), reason: reason);

            if (typed != null) {
              final TextEditingValue value = tester
                  .widget<EditableText>(control.held)
                  .controller
                  .value;

              expect(value.text, typed, reason: reason);
              expect(
                value.selection,
                const TextSelection(baseOffset: 0, extentOffset: 2),
                reason: reason,
              );
            }
          }
        });
      }
    });
  });
}
