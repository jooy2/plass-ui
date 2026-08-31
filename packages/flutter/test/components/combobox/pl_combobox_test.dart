import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

const List<PlComboboxOption<String>> _cities = <PlComboboxOption<String>>[
  PlComboboxOption<String>(value: 'seoul', label: 'Seoul'),
  PlComboboxOption<String>(value: 'lisbon', label: 'Lisbon'),
  PlComboboxOption<String>(value: 'quito', label: 'Quito', disabled: true),
];

/// One of the two glyphs at the end of the field.
///
/// Not `find.bySemanticsLabel`: the field merges its descendants' semantics, so
/// that finder lands on the whole control and a tap on it goes to the editor.
/// This is the button itself.
Finder _adornment(String label) {
  return find.byWidgetPredicate(
    (Widget widget) => widget is Semantics && widget.properties.label == label,
  );
}

/// The rows the list is currently showing, by their text.
List<String> _rows(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((Text text) => text.data ?? '')
      .where((String data) => data.isNotEmpty)
      .toList();
}

/// Puts a combobox on screen with an overlay for its list to go into.
Widget _host(Widget child) => host(SizedBox(width: 320, child: child), overlay: true, width: 420);

void main() {
  group('PlCombobox', () {
    group('rendering', () {
      testWidgets('renders a field with its label, description and error', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(
            PlCombobox<String>(
              options: _cities,
              value: null,
              onChanged: (String? _) {},
              label: const Text('City'),
              description: const Text('Where the team sits.'),
              error: const Text('Pick one.'),
            ),
          ),
        );

        expect(find.text('City'), findsOneWidget);
        expect(find.text('Where the team sits.'), findsOneWidget);
        expect(find.text('Pick one.'), findsOneWidget);
      });

      testWidgets('shows the chosen option by its label, not its value', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(PlCombobox<String>(options: _cities, value: 'seoul', onChanged: (String? _) {})),
        );

        expect(find.text('Seoul'), findsOneWidget);
      });

      testWidgets('follows a value handed in from outside', (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(PlCombobox<String>(options: _cities, value: 'seoul', onChanged: (String? _) {})),
        );
        await tester.pumpWidget(
          _host(PlCombobox<String>(options: _cities, value: 'lisbon', onChanged: (String? _) {})),
        );

        expect(find.text('Lisbon'), findsOneWidget);
      });

      testWidgets('shows the placeholder while nothing is typed', (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(
            PlCombobox<String>(
              options: _cities,
              value: null,
              onChanged: (String? _) {},
              placeholder: 'Search…',
            ),
          ),
        );

        expect(find.text('Search…'), findsOneWidget);
      });
    });

    group('choosing', () {
      testWidgets('opens the list and takes a row', (WidgetTester tester) async {
        String? chosen;

        await tester.pumpWidget(
          _host(
            PlCombobox<String>(
              options: _cities,
              value: null,
              onChanged: (String? next) => chosen = next,
            ),
          ),
        );

        await tester.tap(_adornment('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Lisbon'), findsOneWidget);

        await tester.tap(find.text('Lisbon'));
        await tester.pumpAndSettle();

        expect(chosen, equals('lisbon'));
      });

      testWidgets('leaves a row that cannot be taken alone', (WidgetTester tester) async {
        String? chosen;

        await tester.pumpWidget(
          _host(
            PlCombobox<String>(
              options: _cities,
              value: null,
              onChanged: (String? next) => chosen = next,
            ),
          ),
        );

        await tester.tap(_adornment('Open'));
        await tester.pumpAndSettle();

        // Still listed: an option that vanishes when it cannot be picked is an
        // option the reader will look for.
        expect(find.text('Quito'), findsOneWidget);

        await tester.tap(find.text('Quito'));
        await tester.pumpAndSettle();

        expect(chosen, isNull);
      });

      testWidgets('does not open while read-only', (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(
            PlCombobox<String>(
              options: _cities,
              value: 'seoul',
              onChanged: (String? _) {},
              readOnly: true,
            ),
          ),
        );

        await tester.tap(_adornment('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Lisbon'), findsNothing);
      });
    });

    group('filtering', () {
      testWidgets('narrows the list to what was typed', (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(PlCombobox<String>(options: _cities, value: null, onChanged: (String? _) {})),
        );

        await tester.enterText(find.byType(EditableText), 'lis');
        await tester.pumpAndSettle();

        expect(find.text('Lisbon'), findsOneWidget);
        expect(find.text('Seoul'), findsNothing);
      });

      testWidgets('reports what is typed as it changes', (WidgetTester tester) async {
        final typed = <String>[];

        await tester.pumpWidget(
          _host(
            PlCombobox<String>(
              options: _cities,
              value: null,
              onChanged: (String? _) {},
              onQueryChanged: typed.add,
            ),
          ),
        );

        await tester.enterText(find.byType(EditableText), 'qui');
        await tester.pumpAndSettle();

        expect(typed, contains('qui'));
      });

      testWidgets('says so when nothing matched and nothing may be added', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(PlCombobox<String>(options: _cities, value: null, onChanged: (String? _) {})),
        );

        await tester.enterText(find.byType(EditableText), 'nowhere');
        await tester.pumpAndSettle();

        expect(find.text('No matches'), findsOneWidget);
      });

      testWidgets('shows only as many rows as it was allowed', (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(
            PlCombobox<String>(options: _cities, value: null, onChanged: (String? _) {}, limit: 1),
          ),
        );

        await tester.tap(_adornment('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Seoul'), findsOneWidget);
        expect(find.text('Lisbon'), findsNothing);
      });
    });

    group('a value the list does not have', () {
      testWidgets('offers what was typed as its own row', (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(
            PlCombobox<String>(
              options: _cities,
              value: null,
              onChanged: (String? _) {},
              onCreate: (String query) => query,
            ),
          ),
        );

        await tester.enterText(find.byType(EditableText), 'Osaka');
        await tester.pumpAndSettle();

        expect(find.text('Add “Osaka”'), findsOneWidget);
      });

      testWidgets('commits it when that row is taken', (WidgetTester tester) async {
        String? chosen;

        await tester.pumpWidget(
          _host(
            PlCombobox<String>(
              options: _cities,
              value: null,
              onChanged: (String? next) => chosen = next,
              onCreate: (String query) => query,
            ),
          ),
        );

        await tester.enterText(find.byType(EditableText), 'Osaka');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add “Osaka”'));
        await tester.pumpAndSettle();

        expect(chosen, equals('Osaka'));
      });

      testWidgets('offers nothing extra once the text names an option', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(
            PlCombobox<String>(
              options: _cities,
              value: null,
              onChanged: (String? _) {},
              onCreate: (String query) => query,
            ),
          ),
        );

        await tester.enterText(find.byType(EditableText), 'Lisbon');
        await tester.pumpAndSettle();

        expect(find.textContaining('Add'), findsNothing);
      });

      testWidgets('says it in the caller’s own words', (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(
            PlCombobox<String>(
              options: _cities,
              value: null,
              onChanged: (String? _) {},
              onCreate: (String query) => query,
              customLabel: (String query) => Text('Create $query'),
            ),
          ),
        );

        await tester.enterText(find.byType(EditableText), 'Osaka');
        await tester.pumpAndSettle();

        expect(find.text('Create Osaka'), findsOneWidget);
      });

      testWidgets('offers nothing at all without `onCreate`', (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(PlCombobox<String>(options: _cities, value: null, onChanged: (String? _) {})),
        );

        await tester.enterText(find.byType(EditableText), 'Osaka');
        await tester.pumpAndSettle();

        expect(find.textContaining('Add'), findsNothing);
      });
    });

    group('multiple', () {
      testWidgets('holds more than one value, as chips', (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(
            PlCombobox<String>.multiple(
              options: _cities,
              values: const <String>['seoul', 'lisbon'],
              onChanged: (List<String> _) {},
            ),
          ),
        );

        expect(find.byType(PlChip), findsNWidgets(2));
        expect(find.text('Seoul'), findsOneWidget);
        expect(find.text('Lisbon'), findsOneWidget);
      });

      testWidgets('reports the whole set', (WidgetTester tester) async {
        List<String>? reported;

        await tester.pumpWidget(
          _host(
            PlCombobox<String>.multiple(
              options: _cities,
              values: const <String>['seoul'],
              onChanged: (List<String> next) => reported = next,
            ),
          ),
        );

        await tester.tap(_adornment('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Lisbon'));
        await tester.pumpAndSettle();

        expect(reported, equals(<String>['seoul', 'lisbon']));
      });

      testWidgets('names each chip’s × after its chip', (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(
            PlCombobox<String>.multiple(
              options: _cities,
              values: const <String>['seoul'],
              onChanged: (List<String> _) {},
            ),
          ),
        );

        expect(_adornment('Remove Seoul'), findsOneWidget);
      });

      testWidgets('takes a value off when its × is pressed', (WidgetTester tester) async {
        List<String>? reported;

        await tester.pumpWidget(
          _host(
            PlCombobox<String>.multiple(
              options: _cities,
              values: const <String>['seoul', 'lisbon'],
              onChanged: (List<String> next) => reported = next,
            ),
          ),
        );

        await tester.tap(_adornment('Remove Seoul'));
        await tester.pumpAndSettle();

        expect(reported, equals(<String>['lisbon']));
      });

      testWidgets('empties the query after each pick, so the list stays open', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(
            PlCombobox<String>.multiple(
              options: _cities,
              values: const <String>[],
              onChanged: (List<String> _) {},
            ),
          ),
        );

        await tester.enterText(find.byType(EditableText), 'lis');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Lisbon'));
        await tester.pumpAndSettle();

        expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, isEmpty);
      });
    });

    group('clearing', () {
      testWidgets('offers a × only when asked', (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(PlCombobox<String>(options: _cities, value: 'seoul', onChanged: (String? _) {})),
        );

        expect(_adornment('Clear'), findsNothing);

        await tester.pumpWidget(
          _host(
            PlCombobox<String>(
              options: _cities,
              value: 'seoul',
              onChanged: (String? _) {},
              clearable: true,
            ),
          ),
        );

        expect(_adornment('Clear'), findsOneWidget);
      });

      testWidgets('empties the field', (WidgetTester tester) async {
        String? chosen = 'seoul';
        var called = false;

        await tester.pumpWidget(
          _host(
            PlCombobox<String>(
              options: _cities,
              value: chosen,
              onChanged: (String? next) {
                called = true;
                chosen = next;
              },
              clearable: true,
            ),
          ),
        );

        await tester.tap(_adornment('Clear'));
        await tester.pumpAndSettle();

        expect(called, isTrue);
        expect(chosen, isNull);
      });
    });

    group('accessibility', () {
      testWidgets('is a text field that says whether the list is open', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          _host(
            PlCombobox<String>(
              options: _cities,
              value: null,
              onChanged: (String? _) {},
              semanticLabel: 'City',
            ),
          ),
        );

        expect(
          semanticsOf(tester, find.byType(PlCombobox<String>)),
          isSemantics(label: 'City', isTextField: true, isExpanded: false),
        );

        await tester.tap(_adornment('Open'));
        await tester.pumpAndSettle();

        expect(
          semanticsOf(tester, find.byType(PlCombobox<String>)),
          isSemantics(label: 'City', isTextField: true, isExpanded: true),
        );

        handle.dispose();
      });

      testWidgets('leaves the rows unlisted when nothing has opened them', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(PlCombobox<String>(options: _cities, value: null, onChanged: (String? _) {})),
        );

        expect(_rows(tester), isNot(contains('Lisbon')));
      });
    });
    group('hotKeys', () {
      testWidgets('answers a chord pressed in the field, ahead of the list’s own keys', (
        WidgetTester tester,
      ) async {
        var cleared = 0;

        await tester.pumpWidget(
          _host(
            PlCombobox<String>(
              options: _cities,
              value: null,
              onChanged: (String? _) {},
              autofocus: true,
              hotKeys: <String, VoidCallback>{'Escape': () => cleared += 1},
            ),
          ),
        );
        await tester.pump();

        // Focused the way a reader focuses it. `autofocus` alone leaves the field
        // without a text connection, and the chord never reaches the editor.
        await tester.tap(find.byType(EditableText));
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        expect(cleared, 1);
      });
    });
  });
}
