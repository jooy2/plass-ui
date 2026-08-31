import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/icons.dart';

import '../../support/host.dart';

const List<PlSelectOption<String>> _cities = <PlSelectOption<String>>[
  PlSelectOption<String>(value: 'kr-11', label: Text('Seoul')),
  PlSelectOption<String>(value: 'jp-13', label: Text('Tokyo')),
  PlSelectOption<String>(value: 'sg-01', label: Text('Singapore'), disabled: true),
  PlSelectOption<String>(value: 'tw-01', label: Text('Taipei')),
];

/// A select wired to a variable, which is how every caller uses it.
class _Harness extends StatefulWidget {
  const _Harness({this.value, this.readOnly = false, this.disabled = false, this.error});

  final String? value;
  final bool readOnly;
  final bool disabled;
  final Widget? error;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late String? _value = widget.value;

  String? get value => _value;

  @override
  Widget build(BuildContext context) {
    return PlSelect<String>(
      options: _cities,
      value: _value,
      readOnly: widget.readOnly,
      disabled: widget.disabled,
      error: widget.error,
      placeholder: const Text('Choose a city'),
      label: const Text('City'),
      onChanged: (String? next) => setState(() => _value = next),
    );
  }
}

Future<_HarnessState> _pump(WidgetTester tester, _Harness harness) async {
  await tester.pumpWidget(host(harness, width: 320, overlay: true));
  await tester.pumpAndSettle();

  return tester.state<_HarnessState>(find.byType(_Harness));
}

/// The trigger, found by the one thing only it draws.
///
/// Every label the select could say is in the trigger twice — once laid out and
/// not painted, holding the width open, and once for real — so a label is not a
/// way to point at it.
Finder _trigger() => find.byWidgetPredicate(
  (Widget widget) => widget is PlassGlyph && widget.shape == PlassGlyphShape.chevron,
);

/// A row of the open list, rather than the same words in the trigger.
Finder _row(String label) =>
    find.descendant(of: find.byType(SingleChildScrollView), matching: find.text(label));

void main() {
  group('PlSelect', () {
    group('trigger', () {
      testWidgets('says the placeholder while nothing is chosen', (WidgetTester tester) async {
        await _pump(tester, const _Harness());

        // Once for real, and once more holding the trigger's width open.
        expect(find.text('Choose a city'), findsNWidgets(2));
      });

      testWidgets('and the chosen label once there is one', (WidgetTester tester) async {
        await _pump(tester, const _Harness(value: 'jp-13'));

        // Once for real, and once for each sample holding the width open.
        expect(find.text('Tokyo'), findsNWidgets(2));
      });

      testWidgets('holds its width at the longest thing it could say', (WidgetTester tester) async {
        await _pump(tester, const _Harness(value: 'kr-11'));
        final wide = tester.getSize(find.byType(PlSelect<String>)).width;

        await _pump(tester, const _Harness(value: 'sg-01'));

        expect(tester.getSize(find.byType(PlSelect<String>)).width, wide);
      });
    });

    group('opening', () {
      testWidgets('a press opens the list', (WidgetTester tester) async {
        await _pump(tester, const _Harness());

        expect(_row('Seoul'), findsNothing);
        await tester.tap(_trigger());
        await tester.pumpAndSettle();

        expect(_row('Seoul'), findsOneWidget);
        expect(_row('Taipei'), findsOneWidget);
      });

      testWidgets('a read-only select does not open', (WidgetTester tester) async {
        await _pump(tester, const _Harness(value: 'kr-11', readOnly: true));

        await tester.tap(_trigger());
        await tester.pumpAndSettle();

        expect(_row('Tokyo'), findsNothing);
      });

      testWidgets('nor does a disabled one', (WidgetTester tester) async {
        await _pump(tester, const _Harness(value: 'kr-11', disabled: true));

        await tester.tap(_trigger(), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(_row('Tokyo'), findsNothing);
      });

      testWidgets('a press outside closes it', (WidgetTester tester) async {
        await _pump(tester, const _Harness());

        await tester.tap(_trigger());
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(4, 4));
        await tester.pumpAndSettle();

        expect(_row('Seoul'), findsNothing);
      });
    });

    group('choosing', () {
      testWidgets('a press on a row reports it and closes the list', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness());

        await tester.tap(_trigger());
        await tester.pumpAndSettle();
        await tester.tap(_row('Tokyo'));
        await tester.pumpAndSettle();

        expect(state.value, 'jp-13');
        expect(_row('Tokyo'), findsNothing);
      });

      testWidgets('an unavailable row cannot be taken', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness());

        await tester.tap(_trigger());
        await tester.pumpAndSettle();
        await tester.tap(_row('Singapore'));
        await tester.pumpAndSettle();

        expect(state.value, isNull);
        expect(_row('Singapore'), findsOneWidget);
      });

      testWidgets('the arrow keys move the highlight and Enter takes it', (
        WidgetTester tester,
      ) async {
        final state = await _pump(tester, const _Harness());

        await tester.tap(_trigger());
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(state.value, 'jp-13');
      });

      testWidgets('and step over the row that cannot be taken', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness(value: 'jp-13'));

        await tester.tap(_trigger());
        await tester.pumpAndSettle();

        // Tokyo is chosen, so the highlight opens on it; the next available row
        // is Taipei, because Singapore is not one.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(state.value, 'tw-01');
      });

      testWidgets('Escape closes without choosing', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness());

        await tester.tap(_trigger());
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(state.value, isNull);
        expect(_row('Seoul'), findsNothing);
      });
    });

    group('accessibility', () {
      testWidgets('is announced as a button holding what it says', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, const _Harness(value: 'kr-11'));

        expect(
          tester.getSemantics(_trigger()),
          isSemantics(isButton: true, value: 'Seoul', isExpanded: false),
        );

        handle.dispose();
      });

      testWidgets('and says so when the list is open', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, const _Harness(value: 'kr-11'));

        await tester.tap(_trigger());
        await tester.pumpAndSettle();

        expect(tester.getSemantics(_trigger()), isSemantics(isButton: true, isExpanded: true));

        handle.dispose();
      });

      testWidgets('an error re-points the family at danger', (WidgetTester tester) async {
        await _pump(tester, const _Harness(error: Text('Pick one.')));

        expect(
          styleOf(tester, 'Pick one.').color,
          PlassTokens.light().family(PlassColor.danger).accent,
        );
      });
    });
    group('hotKeys', () {
      testWidgets('answers a chord pressed on the trigger, ahead of the list’s own keys', (
        WidgetTester tester,
      ) async {
        var cleared = 0;

        await tester.pumpWidget(
          host(
            PlSelect<String>(
              options: _cities,
              value: null,
              onChanged: (String? _) {},
              autofocus: true,
              hotKeys: <String, VoidCallback>{'Escape': () => cleared += 1},
            ),
            width: 320,
            overlay: true,
          ),
        );
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        expect(cleared, 1);
      });
    });
  });
}
