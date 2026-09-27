import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/glow.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';

import '../../support/host.dart';

/// A control with a `State` of its own: built again from scratch, it is a
/// different object.
class _Probe extends StatefulWidget {
  const _Probe();

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => const Text('Street');
}

const List<PlSelectOption<String>> _cities = <PlSelectOption<String>>[
  PlSelectOption<String>(value: 'lisbon', label: Text('Lisbon')),
  PlSelectOption<String>(value: 'seoul', label: Text('Seoul')),
];

/// A control drawn with or without a `disabled` of its own.
typedef _Control = Widget Function({bool disabled});

/// Every control a form is built from. Inside a disabled fieldset each has to be
/// drawn exactly as it is with a `disabled` of its own.
final Map<String, _Control> _controls = <String, _Control>{
  'PlTextField': ({bool disabled = false}) =>
      PlTextField(label: const Text('Street'), disabled: disabled),
  'PlNumberField': ({bool disabled = false}) =>
      PlNumberField(value: 2, label: const Text('Quantity'), disabled: disabled),
  'PlSelect': ({bool disabled = false}) => PlSelect<String>(
    options: _cities,
    value: null,
    label: const Text('City'),
    onChanged: (String? value) {},
    disabled: disabled,
  ),
  'PlCombobox': ({bool disabled = false}) => PlCombobox<String>(
    options: const <PlComboboxOption<String>>[
      PlComboboxOption<String>(value: 'lisbon', label: 'Lisbon'),
    ],
    value: null,
    label: const Text('City'),
    onChanged: (String? value) {},
    disabled: disabled,
  ),
  'PlDatePicker': ({bool disabled = false}) => PlDatePicker(
    value: null,
    label: const Text('Departure'),
    onChanged: (DateTime? value) {},
    disabled: disabled,
  ),
  'PlColorPicker': ({bool disabled = false}) =>
      PlColorPicker(value: '#1a58d1', label: const Text('Colour'), disabled: disabled),
  'PlOtpField': ({bool disabled = false}) =>
      PlOtpField(label: const Text('Code'), disabled: disabled),
  'PlFilePicker': ({bool disabled = false}) => PlFilePicker(
    value: const <PlFile>[],
    onBrowse: () async => const <PlFile>[],
    onFilesChanged: (List<PlFile> files) {},
    disabled: disabled,
  ),
  'PlCheckbox': ({bool disabled = false}) => PlCheckbox(
    value: false,
    onChanged: (bool value) {},
    label: const Text('Business address'),
    disabled: disabled,
  ),
  'PlSwitch': ({bool disabled = false}) => PlSwitch(
    value: false,
    onChanged: (bool value) {},
    label: const Text('Invoices by email'),
    disabled: disabled,
  ),
  'PlRadioGroup': ({bool disabled = false}) => PlRadioGroup<String>(
    options: const <PlRadioOption<String>>[
      PlRadioOption<String>(value: 'starter', label: Text('Starter')),
      PlRadioOption<String>(value: 'team', label: Text('Team')),
    ],
    value: 'team',
    onChanged: (String value) {},
    disabled: disabled,
  ),
  'PlSlider': ({bool disabled = false}) => PlSlider(
    values: const <double>[40],
    onChanged: (List<double> values) {},
    label: const Text('Volume'),
    disabled: disabled,
  ),
  'PlRating': ({bool disabled = false}) =>
      PlRating(value: 3, onChanged: (double value) {}, disabled: disabled),
  'PlSegmentedButton': ({bool disabled = false}) => PlSegmentedButton<String>(
    segments: const <PlSegment<String>>[
      PlSegment<String>(value: 'day', label: Text('Day')),
      PlSegment<String>(value: 'week', label: Text('Week')),
    ],
    value: 'day',
    onChanged: (String value) {},
    disabled: disabled,
  ),
  'PlToggle': ({bool disabled = false}) =>
      PlToggle(onPressedChanged: (bool value) {}, disabled: disabled, child: const Text('Bold')),
  'PlButton': ({bool disabled = false}) =>
      PlButton(onPressed: () {}, disabled: disabled, child: const Text('Verify')),
  'PlCalendar': ({bool disabled = false}) =>
      PlCalendar(value: DateTime(2026, 7, 27), onChanged: (DateTime? value) {}, disabled: disabled),
  'PlPagination': ({bool disabled = false}) =>
      PlPagination(count: 5, page: 2, onPageChanged: (int page) {}, disabled: disabled),
  'PlTransfer': ({bool disabled = false}) => PlTransfer(
    items: const <PlTransferItem>[
      PlTransferItem(value: 'lisbon', label: 'Lisbon'),
      PlTransferItem(value: 'seoul', label: 'Seoul'),
    ],
    value: const <String>['seoul'],
    onValueChanged: (List<String> value) {},
    disabled: disabled,
  ),
};

const Key _control = ValueKey<String>('control');

/// Every drain and fade under the control, in the order they are painted.
List<(double, ColorFilter?)> _drawing(WidgetTester tester) {
  return tester
      .widgetList<PlassFiltered>(
        find.descendant(of: find.byKey(_control), matching: find.byType(PlassFiltered)),
      )
      .map((PlassFiltered filtered) => (filtered.opacity, filtered.colorFilter))
      .toList();
}

/// How many layers of the interaction light are drawn under the control.
int _lights(WidgetTester tester) {
  return find
      .descendant(of: find.byKey(_control), matching: find.byType(PlassGlowLayer))
      .evaluate()
      .length;
}

/// The editor of the text field labelled [label].
Finder _editorOf(String label) {
  return find.descendant(
    of: find.widgetWithText(PlTextField, label),
    matching: find.byType(EditableText),
  );
}

/// The opacity [finder] is painted at, every fade above it multiplied in.
double _opacityOf(WidgetTester tester, Finder finder) {
  return tester
      .widgetList<PlassFiltered>(find.ancestor(of: finder, matching: find.byType(PlassFiltered)))
      .fold(1, (double opacity, PlassFiltered filtered) => opacity * filtered.opacity);
}

void main() {
  group('PlFieldset', () {
    testWidgets('draws the legend and the description above the controls', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const PlFieldset(
            legend: Text('Billing address'),
            description: Text('Where the invoice goes'),
            children: <Widget>[Text('Street')],
          ),
          width: 400,
          height: 300,
        ),
      );

      expect(
        tester.getTopLeft(find.text('Billing address')).dy,
        lessThan(tester.getTopLeft(find.text('Where the invoice goes')).dy),
      );
      expect(
        tester.getTopLeft(find.text('Where the invoice goes')).dy,
        lessThan(tester.getTopLeft(find.text('Street')).dy),
      );
    });

    testWidgets('draws no heading block when there is nothing to say', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PlFieldset(children: <Widget>[Text('Street')]), width: 400, height: 300),
      );

      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('draws no surface, because a grouping is not a sheet', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlFieldset(legend: Text('Group'), children: <Widget>[Text('Street')]),
          width: 400,
          height: 300,
        ),
      );

      expect(decorationsOf(tester, find.byType(PlFieldset)), isEmpty);
    });

    testWidgets('stands its controls apart on the sheet ladder', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlFieldset(size: PlassSize.xs, children: <Widget>[Text('One'), Text('Two')]),
          width: 400,
          height: 300,
        ),
      );

      final Column column = tester.widget<Column>(
        find.descendant(of: find.byType(PlFieldset), matching: find.byType(Column)).first,
      );

      expect(column.spacing, 6);
    });

    group('disabled', () {
      testWidgets('takes the pointer away from everything inside', (WidgetTester tester) async {
        int pressed = 0;

        await tester.pumpWidget(
          host(
            PlFieldset(
              disabled: true,
              legend: const Text('Billing address'),
              children: <Widget>[
                PlButton(onPressed: () => pressed += 1, child: const Text('Save')),
              ],
            ),
            width: 400,
            height: 300,
          ),
        );

        await tester.tap(find.text('Save'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(pressed, 0);
      });

      testWidgets('reaches one it never heard of, three levels down', (WidgetTester tester) async {
        int pressed = 0;

        await tester.pumpWidget(
          host(
            PlFieldset(
              disabled: true,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        PlButton(onPressed: () => pressed += 1, child: const Text('Save')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            width: 400,
            height: 300,
          ),
        );

        await tester.tap(find.text('Save'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(pressed, 0);
      });

      testWidgets('takes the focus away as well', (WidgetTester tester) async {
        final FocusNode save = FocusNode();
        addTearDown(save.dispose);

        Widget group({bool disabled = false}) {
          return host(
            PlFieldset(
              disabled: disabled,
              children: <Widget>[
                PlButton(onPressed: () {}, focusNode: save, child: const Text('Save')),
              ],
            ),
            width: 400,
            height: 300,
          );
        }

        await tester.pumpWidget(group(disabled: true));
        save.requestFocus();
        await tester.pump();

        expect(save.hasFocus, isFalse, reason: 'disabled');

        await tester.pumpWidget(group());
        save.requestFocus();
        await tester.pump();

        expect(save.hasFocus, isTrue, reason: 'enabled');
      });

      testWidgets('keeps what the group holds as it is disabled and enabled again', (
        WidgetTester tester,
      ) async {
        Widget group({bool disabled = false}) {
          return host(
            PlFieldset(
              disabled: disabled,
              legend: const Text('Billing address'),
              children: const <Widget>[_Probe()],
            ),
            width: 400,
            height: 300,
          );
        }

        await tester.pumpWidget(group());
        final State<_Probe> held = tester.state(find.byType(_Probe));

        for (final (String reason, Widget next) in <(String, Widget)>[
          ('disabled', group(disabled: true)),
          ('enabled again', group()),
        ]) {
          await tester.pumpWidget(next);
          await tester.pumpAndSettle();

          // A field built again from scratch would have lost what was typed
          // into it.
          expect(tester.state(find.byType(_Probe)), same(held), reason: reason);
        }
      });

      group('draws every control inside as disabled', () {
        _controls.forEach((String name, _Control control) {
          testWidgets('draws a $name as one with its own disabled', (WidgetTester tester) async {
            await tester.pumpWidget(
              host(KeyedSubtree(key: _control, child: control(disabled: true)), width: 420),
            );
            await tester.pumpAndSettle();

            final List<(double, ColorFilter?)> expected = _drawing(tester);
            final int lights = _lights(tester);

            await tester.pumpWidget(
              host(
                PlFieldset(
                  disabled: true,
                  children: <Widget>[KeyedSubtree(key: _control, child: control())],
                ),
                width: 420,
              ),
            );
            await tester.pumpAndSettle();

            // Drained by the control itself and by nothing round it, so once.
            expect(_drawing(tester), expected);
            expect(
              _drawing(tester).map(((double, ColorFilter?) layer) => layer.$1),
              contains(disabledOpacity),
            );
            expect(_lights(tester), lights);
          });
        });
      });

      testWidgets('drains a field that is disabled twice over once', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlFieldset(
              disabled: true,
              children: <Widget>[PlTextField(label: Text('Street'), disabled: true)],
            ),
            width: 420,
          ),
        );

        expect(_opacityOf(tester, _editorOf('Street')), disabledOpacity);
      });

      testWidgets('drains a field in a fieldset further out', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlFieldset(
              disabled: true,
              children: <Widget>[
                PlFieldset(children: <Widget>[PlTextField(label: Text('Street'))]),
              ],
            ),
            width: 420,
          ),
        );

        expect(_opacityOf(tester, _editorOf('Street')), disabledOpacity);
        expect(find.byType(PlassGlowLayer), findsNothing);
      });

      testWidgets('puts out the light of a field inside', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlFieldset(
              disabled: true,
              children: <Widget>[
                const PlTextField(label: Text('Street')),
                PlSelect<String>(
                  options: _cities,
                  value: null,
                  label: const Text('City'),
                  onChanged: (String? value) {},
                ),
              ],
            ),
            width: 420,
          ),
        );

        expect(find.byType(PlassGlowLayer), findsNothing);
      });

      testWidgets('tells a screen reader a control inside is unavailable', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            PlFieldset(
              disabled: true,
              children: <Widget>[
                PlCheckbox(
                  value: false,
                  onChanged: (bool value) {},
                  label: const Text('Business address'),
                ),
              ],
            ),
            width: 420,
          ),
        );

        expect(
          semanticsOf(tester, find.byType(PlCheckbox)),
          isSemantics(hasEnabledState: true, isEnabled: false),
        );

        handle.dispose();
      });

      testWidgets('leaves what is not a control as it is', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlFieldset(
              disabled: true,
              legend: Text('Billing address'),
              children: <Widget>[Text('Where the invoice goes')],
            ),
            width: 420,
          ),
        );

        expect(_opacityOf(tester, find.text('Billing address')), 1);
        expect(_opacityOf(tester, find.text('Where the invoice goes')), 1);
      });

      testWidgets('leaves a field outside it alone', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                PlFieldset(disabled: true, children: <Widget>[PlTextField(label: Text('Street'))]),
                PlTextField(label: Text('Email')),
              ],
            ),
            width: 420,
          ),
        );

        expect(_opacityOf(tester, _editorOf('Street')), disabledOpacity);
        expect(_opacityOf(tester, _editorOf('Email')), 1);
        expect(
          find.descendant(
            of: find.widgetWithText(PlTextField, 'Email'),
            matching: find.byType(PlassGlowLayer),
          ),
          findsNWidgets(2),
        );
      });

      testWidgets('leaves them alone when it is off', (WidgetTester tester) async {
        int pressed = 0;

        await tester.pumpWidget(
          host(
            PlFieldset(
              children: <Widget>[
                PlButton(onPressed: () => pressed += 1, child: const Text('Save')),
              ],
            ),
            width: 400,
            height: 300,
          ),
        );

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(pressed, 1);
      });
    });
  });
}
