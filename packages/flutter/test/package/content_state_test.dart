// That a control drawn on a `PlassSurfaceBox` keeps what it holds as it is made
// read-only and disabled, and as its variant changes, and that a chip and an
// effect keep what they hold as a setting changes.
//
// Each of those changes how a control looks and what it does: the gloss of a
// glass surface goes, the interaction light is put out, a pressable chip stops
// being pressable, a number field puts its steppers away, a `solid` surface
// starts answering the pointer with a brightness, an entrance stops fading and
// a headline's line comes up. None of that may change the shape of the tree
// above what the control holds, because Flutter builds a changed shape again
// from scratch — a stateful slot would start over, and an editor would come
// back as a new one. What is checked here is the content's own `State`, kept
// across all of them, on every variant of every control.
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

/// A widget built with one of its settings on or off, and what in it has to
/// survive the setting changing.
class _Setting {
  const _Setting(this.build, {this.held});

  final Widget Function(bool on) build;

  /// What has to survive, or `null` for a [_Probe].
  final Finder? held;
}

/// Settings that put a wrapper round what a widget holds to work, or stand it
/// down: the press and the brightness of a chip that is handed `onPressed`, the
/// fade of an entrance, and the travel and the fade of a headline's line as it
/// comes up and leaves.
final Map<String, _Setting> _settings = <String, _Setting>{
  'PlChip, its onPressed': _Setting(
    (bool on) => PlChip(onPressed: on ? () {} : null, child: const _Probe()),
  ),
  'PlAnimateAppear, its fade': _Setting(
    (bool on) => PlAnimateAppear(fade: on, children: const <Widget>[_Probe()]),
  ),
  'PlAnimateZoom, its fade': _Setting((bool on) => PlAnimateZoom(fade: on, child: const _Probe())),
  'PlAnimateSlide, its fade': _Setting(
    (bool on) => PlAnimateSlide(fade: on, child: const _Probe()),
  ),
  'PlAnimateGrow, its fade': _Setting((bool on) => PlAnimateGrow(fade: on, child: const _Probe())),
  'PlAnimateRotate, its fade': _Setting(
    (bool on) => PlAnimateRotate(fade: on, child: const _Probe()),
  ),
  'PlAnimateReveal, its fade': _Setting(
    (bool on) => PlAnimateReveal(fade: on, child: const _Probe()),
  ),
  // Its parts are its own words, with no `State` of their own, so what has to
  // survive is the element a word is drawn by.
  'PlAnimateSplit, its fade': _Setting(
    (bool on) => PlAnimateSplit(text: 'Ship it', fade: on),
    held: find.textContaining('Ship'),
  ),
  'PlAnimateHeadline, a line coming up and leaving': _Setting(
    (bool on) =>
        PlAnimateHeadline(index: on ? 1 : 0, children: const <Widget>[Text('faster'), _Probe()]),
  ),
};

/// A control with a field in it, on one variant.
typedef _Holding = Widget Function(PlassVariant variant);

/// Controls that hold what a caller hands them, each with a field in it that
/// has to keep what was typed as the variant changes.
final Map<String, _Holding> _holders = <String, _Holding>{
  'PlPill': (PlassVariant variant) => PlPill(
    variant: variant,
    expanded: true,
    title: const Text('Title'),
    details: const PlTextField(fullWidth: true),
  ),
  'pressable PlPill': (PlassVariant variant) => PlPill(
    variant: variant,
    expanded: true,
    title: const Text('Title'),
    details: const PlTextField(fullWidth: true),
    onPressed: () {},
  ),
};

void main() {
  group('what a widget holds as a setting changes', () {
    _settings.forEach((String name, _Setting setting) {
      testWidgets('survives $name going on and off', (WidgetTester tester) async {
        final Finder held = setting.held ?? find.byType(_Probe);

        Widget build(bool on) => host(setting.build(on), width: 320);

        await tester.pumpWidget(build(false));
        await tester.pumpAndSettle();

        final Element element = tester.element(held);

        for (final bool on in <bool>[true, false]) {
          await tester.pumpWidget(build(on));
          await tester.pumpAndSettle();

          expect(tester.element(held), same(element), reason: on ? 'on' : 'off again');
        }
      });
    });
  });

  group('what a control holds as its variant changes', () {
    _holders.forEach((String name, _Holding build) {
      testWidgets('survives a $name going through every variant', (WidgetTester tester) async {
        Widget holder(PlassVariant variant) => host(build(variant), width: 320, overlay: true);

        await tester.pumpWidget(holder(PlassVariant.values.first));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(EditableText), 'Seoul');
        await tester.pump();

        final State held = tester.state(find.byType(EditableText));

        for (final PlassVariant variant in <PlassVariant>[
          ...PlassVariant.values.skip(1),
          PlassVariant.values.first,
        ]) {
          await tester.pumpWidget(holder(variant));
          await tester.pumpAndSettle();

          expect(tester.state(find.byType(EditableText)), same(held), reason: variant.name);
          expect(
            tester.widget<EditableText>(find.byType(EditableText)).controller.text,
            'Seoul',
            reason: variant.name,
          );
        }
      });
    });
  });

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
