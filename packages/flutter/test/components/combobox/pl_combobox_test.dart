import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/anchored.dart';
import 'package:plass_ui/src/internal/notch.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';

import '../../support/host.dart';

const List<PlComboboxOption<String>> _cities = <PlComboboxOption<String>>[
  PlComboboxOption<String>(value: 'seoul', label: 'Seoul'),
  PlComboboxOption<String>(value: 'lisbon', label: 'Lisbon'),
  PlComboboxOption<String>(value: 'quito', label: 'Quito', disabled: true),
];

/// Long enough that the first row, the last one and the chosen ones are all
/// different rows.
const List<PlComboboxOption<String>> _more = <PlComboboxOption<String>>[
  ..._cities,
  PlComboboxOption<String>(value: 'osaka', label: 'Osaka'),
  PlComboboxOption<String>(value: 'porto', label: 'Porto'),
  PlComboboxOption<String>(value: 'rome', label: 'Rome'),
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

/// The rows the open list shows, by their text, in order.
///
/// Read from the list alone: the field's own text would be counted otherwise.
List<String> _listed(WidgetTester tester) {
  return tester
      .widgetList<Text>(
        find.descendant(of: find.byType(SingleChildScrollView), matching: find.byType(Text)),
      )
      .map((Text text) => text.data ?? '')
      .toList();
}

/// A row of the open list, by its text, and not the field's text or a chip.
Finder _inList(String label) {
  return find.descendant(of: find.byType(SingleChildScrollView), matching: find.text(label));
}

/// The row the keyboard is on, by its text, or `null` for none.
///
/// A lit row is the one painting its wash, which it does in a group of its own.
/// The list's sheet and the field's paint groups as well, round the rows and
/// round the text, so the row's is the painting group inside the list with no
/// painting group under it.
String? _lit(WidgetTester tester) {
  bool paints(Widget widget) => widget is PlassContentsGroup && widget.paints;

  final Finder lit = find.descendant(
    of: find.descendant(
      of: find.byType(SingleChildScrollView),
      matching: find.byElementPredicate(
        (Element element) =>
            paints(element.widget) &&
            find
                .descendant(
                  of: find.byElementPredicate((Element other) => other == element),
                  matching: find.byWidgetPredicate(paints),
                )
                .evaluate()
                .isEmpty,
      ),
    ),
    matching: find.byType(Text),
  );

  return lit.evaluate().isEmpty ? null : tester.widget<Text>(lit).data;
}

/// Puts a combobox on screen with an overlay for its list to go into.
Widget _host(Widget child) => host(SizedBox(width: 320, child: child), overlay: true, width: 420);

/// A `multiple` combobox holding Seoul and Lisbon, whose chips come off as they
/// would for a caller.
///
/// With [tapRegions], the tree has the surface a `WidgetsApp` puts under every
/// app, which is what tells a text field about a press outside it.
Future<void> _pumpChips(WidgetTester tester, {bool tapRegions = false}) async {
  List<String> values = <String>['seoul', 'lisbon'];

  final Widget tree = _host(
    StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => PlCombobox<String>.multiple(
        options: _cities,
        values: values,
        onChanged: (List<String> next) => setState(() => values = next),
      ),
    ),
  );

  await tester.pumpWidget(tapRegions ? TapRegionSurface(child: tree) : tree);
}

void main() {
  group('PlCombobox', () {
    group('a long list', () {
      final List<PlComboboxOption<int>> many = <PlComboboxOption<int>>[
        for (int i = 0; i < 500; i += 1) PlComboboxOption<int>(value: i, label: 'Option $i'),
      ];

      Future<void> open(WidgetTester tester) async {
        await tester.pumpWidget(
          _host(PlCombobox<int>(options: many, value: null, onChanged: (int? _) {})),
        );
        await tester.tap(_adornment('Open'));
        await tester.pumpAndSettle();
      }

      testWidgets('builds only the rows near the view', (WidgetTester tester) async {
        await open(tester);

        expect(find.text('Option 0'), findsOneWidget);
        expect(find.text('Option 499'), findsNothing);
      });

      testWidgets('keeps the highlighted row in view, even round the end', (
        WidgetTester tester,
      ) async {
        await open(tester);

        // Opened by a press with nothing chosen, so nothing is lit until the
        // first arrow key lights the first row.
        for (int i = 0; i < 21; i += 1) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
        }
        await tester.pumpAndSettle();

        Rect list = tester.getRect(find.byType(ListView));
        Rect row = tester.getRect(find.text('Option 20'));

        expect(row.top, greaterThanOrEqualTo(list.top));
        expect(row.bottom, lessThanOrEqualTo(list.bottom));

        // Back past the first row, to the last one, which was never built.
        for (int i = 0; i < 21; i += 1) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
          await tester.pump();
        }
        await tester.pumpAndSettle();

        list = tester.getRect(find.byType(ListView));
        row = tester.getRect(find.text('Option 499'));

        expect(row.top, greaterThanOrEqualTo(list.top));
        expect(row.bottom, lessThanOrEqualTo(list.bottom));
      });
    });

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

      for (final (String length, int count) in <(String, int)>[('short', 3), ('long', 500)]) {
        testWidgets('drops a $length list exactly as wide as the field', (
          WidgetTester tester,
        ) async {
          await tester.pumpWidget(
            _host(
              PlCombobox<int>(
                options: <PlComboboxOption<int>>[
                  for (int i = 0; i < count; i += 1)
                    PlComboboxOption<int>(value: i, label: 'Option $i'),
                ],
                value: null,
                onChanged: (int? _) {},
              ),
            ),
          );
          await tester.tap(_adornment('Open'));
          await tester.pumpAndSettle();

          final Rect field = tester.getRect(find.byType(PlassAnchoredPortal));
          final Rect list = tester.getRect(
            find.ancestor(of: find.text('Option 0'), matching: find.byType(PlassSurfaceBox)).first,
          );

          expect(list.width, field.width);
          expect(list.left, field.left);
        });
      }

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

      testWidgets('adds an opacity layer only for the row that cannot be taken', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(PlCombobox<String>(options: _cities, value: null, onChanged: (String? _) {})),
        );
        await tester.tap(_adornment('Open'));
        await tester.pumpAndSettle();

        final Iterable<int> alphas = tester.layers.whereType<OpacityLayer>().map(
          (OpacityLayer layer) => layer.alpha!,
        );

        // The list fades in as one, which is the one layer at full strength.
        // A row that can be taken is not painted through an opacity of 1 as
        // well, which would be a layer on every row for nothing.
        expect(alphas.where((int alpha) => alpha == 255), hasLength(1));
        expect(alphas.where((int alpha) => alpha != 255), <int>[
          Color.getAlphaFromOpacity(disabledOpacity),
        ]);
      });

      group('a press on the field', () {
        Future<void> pump(WidgetTester tester) {
          return tester.pumpWidget(
            _host(PlCombobox<String>(options: _cities, value: null, onChanged: (String? _) {})),
          );
        }

        testWidgets('on the text opens the list, and opens it again once it is shut', (
          WidgetTester tester,
        ) async {
          await pump(tester);

          // The field is the chevron's equivalent: the glyph keeps the size it
          // is drawn at, and the field is a target the size of a control.
          await tester.tap(find.byType(EditableText));
          await tester.pumpAndSettle();

          expect(find.text('Lisbon'), findsOneWidget);

          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          expect(find.text('Lisbon'), findsNothing);

          // Already focused, with the caret where the press puts it again.
          await tester.tap(find.byType(EditableText));
          await tester.pumpAndSettle();

          expect(find.text('Lisbon'), findsOneWidget);
        });

        testWidgets('beside the text opens the list too', (WidgetTester tester) async {
          await pump(tester);

          final Rect box = tester.getRect(
            find
                .descendant(
                  of: find.byType(PlCombobox<String>),
                  matching: find.byType(PlassSurfaceBox),
                )
                .first,
          );
          await tester.tapAt(box.centerLeft + const Offset(4, 0));
          await tester.pumpAndSettle();

          expect(find.text('Lisbon'), findsOneWidget);
        });

        testWidgets('that drags across the text leaves the list shut', (WidgetTester tester) async {
          await pump(tester);

          await tester.drag(find.byType(EditableText), const Offset(-60, 0));
          await tester.pumpAndSettle();

          expect(find.text('Lisbon'), findsNothing);
        });
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

      testWidgets('takes the row a mouse presses on a desktop, after a query', (
        WidgetTester tester,
      ) async {
        // Where a press outside the text takes the focus out of it, and puts the
        // chosen label back in the field. Put back however the test ends.
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

        try {
          String? chosen;

          await tester.pumpWidget(
            TapRegionSurface(
              child: _host(
                PlCombobox<String>(
                  options: _cities,
                  value: null,
                  onChanged: (String? next) => chosen = next,
                ),
              ),
            ),
          );

          await tester.tap(find.byType(EditableText), kind: PointerDeviceKind.mouse);
          await tester.pumpAndSettle();
          tester.testTextInput.enterText('lis');
          await tester.pumpAndSettle();

          await tester.tap(_inList('Lisbon'), kind: PointerDeviceKind.mouse);
          await tester.pumpAndSettle();

          expect(chosen, 'lisbon');
          expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus, isTrue);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });

      group('while read-only', () {
        testWidgets('opens to be looked through, and takes nothing from it', (
          WidgetTester tester,
        ) async {
          int changed = 0;

          await tester.pumpWidget(
            _host(
              PlCombobox<String>(
                options: _cities,
                value: null,
                onChanged: (String? _) => changed += 1,
                readOnly: true,
              ),
            ),
          );

          // As Base UI opens a read-only combobox: the value is locked, not
          // the list.
          await tester.tap(find.byType(EditableText));
          await tester.pumpAndSettle();

          expect(find.text('Lisbon'), findsOneWidget);

          await tester.tap(find.text('Lisbon'));
          await tester.pumpAndSettle();

          expect(changed, 0);
          expect(find.text('Lisbon'), findsOneWidget);
          expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, isEmpty);

          // The chevron closes it and opens it again.
          await tester.tap(_adornment('Open'));
          await tester.pumpAndSettle();
          expect(find.text('Lisbon'), findsNothing);

          await tester.tap(_adornment('Open'));
          await tester.pumpAndSettle();
          expect(find.text('Lisbon'), findsOneWidget);
        });

        testWidgets('lists every row with one of them chosen', (WidgetTester tester) async {
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

          await tester.tap(find.byType(EditableText));
          await tester.pumpAndSettle();

          expect(_listed(tester), <String>['Seoul', 'Lisbon', 'Quito']);
          expect(_lit(tester), 'Seoul');
        });

        testWidgets('opens with the arrow keys and takes nothing on Enter', (
          WidgetTester tester,
        ) async {
          final List<List<String>> reported = <List<String>>[];

          await tester.pumpWidget(
            _host(
              PlCombobox<String>.multiple(
                options: _cities,
                values: const <String>['seoul'],
                onChanged: reported.add,
                readOnly: true,
              ),
            ),
          );

          await tester.tap(find.byType(EditableText));
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          expect(find.text('Lisbon'), findsNothing);

          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
          expect(find.text('Lisbon'), findsOneWidget);

          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();

          expect(reported, isEmpty);
          expect(find.byType(PlChip), findsOneWidget);
        });

        testWidgets('does not open while disabled as well', (WidgetTester tester) async {
          await tester.pumpWidget(
            _host(
              PlCombobox<String>(
                options: _cities,
                value: null,
                onChanged: (String? _) {},
                readOnly: true,
                disabled: true,
              ),
            ),
          );

          await tester.tap(_adornment('Open'), warnIfMissed: false);
          await tester.pumpAndSettle();
          await tester.tap(find.byType(EditableText), warnIfMissed: false);
          await tester.pumpAndSettle();

          expect(find.text('Lisbon'), findsNothing);
        });
      });

      group('a press on the field while the list is up', () {
        testWidgets('on the text leaves it open and moves the caret', (WidgetTester tester) async {
          await tester.pumpWidget(
            _host(PlCombobox<String>(options: _cities, value: null, onChanged: (String? _) {})),
          );

          await tester.enterText(find.byType(EditableText), 'lis');
          await tester.pumpAndSettle();

          final TextEditingController text = tester
              .widget<EditableText>(find.byType(EditableText))
              .controller;
          expect(find.text('Lisbon'), findsOneWidget);
          expect(text.selection, const TextSelection.collapsed(offset: 3));

          await tester.tapAt(tester.getTopLeft(find.byType(EditableText)) + const Offset(1, 8));
          await tester.pumpAndSettle();

          expect(find.text('Lisbon'), findsOneWidget);
          expect(text.selection, const TextSelection.collapsed(offset: 0));
        });

        testWidgets('on a chip’s × takes the chip off and leaves it open', (
          WidgetTester tester,
        ) async {
          await _pumpChips(tester);

          await tester.tap(_adornment('Open'));
          await tester.pumpAndSettle();
          expect(find.text('Quito'), findsOneWidget);

          await tester.tap(_adornment('Remove Seoul'));
          await tester.pumpAndSettle();

          expect(find.byType(PlChip), findsOneWidget);
          expect(find.text('Quito'), findsOneWidget);
        });

        testWidgets('on a chip’s × does the same with a mouse on a desktop', (
          WidgetTester tester,
        ) async {
          // Where a press outside the text takes the focus out of it, and the
          // list goes with the focus. Put back however the test ends, so a
          // failure here is not a failure of every test after it.
          debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

          try {
            await _pumpChips(tester, tapRegions: true);

            await tester.tap(find.byType(EditableText), kind: PointerDeviceKind.mouse);
            await tester.pumpAndSettle();
            expect(find.text('Quito'), findsOneWidget);

            await tester.tap(_adornment('Remove Seoul'), kind: PointerDeviceKind.mouse);
            await tester.pumpAndSettle();

            expect(find.byType(PlChip), findsOneWidget);
            expect(find.text('Quito'), findsOneWidget);
            expect(
              tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
              isTrue,
            );
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        });

        testWidgets('on the chevron closes it', (WidgetTester tester) async {
          await _pumpChips(tester);

          await tester.tap(_adornment('Open'));
          await tester.pumpAndSettle();
          expect(find.text('Quito'), findsOneWidget);

          await tester.tap(_adornment('Open'));
          await tester.pumpAndSettle();

          expect(find.text('Quito'), findsNothing);
          expect(find.byType(PlChip), findsNWidgets(2));
        });

        testWidgets('beside the field closes it', (WidgetTester tester) async {
          await _pumpChips(tester);

          await tester.tap(_adornment('Open'));
          await tester.pumpAndSettle();
          expect(find.text('Quito'), findsOneWidget);

          await tester.tapAt(const Offset(4, 4));
          await tester.pumpAndSettle();

          expect(find.text('Quito'), findsNothing);
        });
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

      testWidgets('lists every row as it opens on a chosen one, until the text changes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(PlCombobox<String>(options: _cities, value: 'lisbon', onChanged: (String? _) {})),
        );

        // The chosen row's label is in the field, and it is not a query.
        await tester.tap(_adornment('Open'));
        await tester.pumpAndSettle();

        expect(_listed(tester), <String>['Seoul', 'Lisbon', 'Quito']);
        expect(_lit(tester), 'Lisbon');

        // Down from the chosen row, past the one that cannot be taken.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expect(_lit(tester), 'Seoul');

        // Typed, even back to the chosen label, the text filters.
        tester.testTextInput.enterText('Lis');
        await tester.pumpAndSettle();
        expect(_listed(tester), <String>['Lisbon']);

        tester.testTextInput.enterText('Lisbon');
        await tester.pumpAndSettle();
        expect(_listed(tester), <String>['Lisbon']);

        // Until the list opens again on the label it holds.
        await tester.tap(_adornment('Open'));
        await tester.pumpAndSettle();
        expect(_listed(tester), isEmpty);

        await tester.tap(_adornment('Open'));
        await tester.pumpAndSettle();
        expect(_listed(tester), <String>['Seoul', 'Lisbon', 'Quito']);
        expect(_lit(tester), 'Lisbon');
      });

      testWidgets('puts the chosen label back as Escape closes it, and opens on every row again', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(PlCombobox<String>(options: _cities, value: 'lisbon', onChanged: (String? _) {})),
        );

        final EditableText editor = tester.widget<EditableText>(find.byType(EditableText));

        await tester.tap(find.byType(EditableText));
        await tester.pumpAndSettle();
        tester.testTextInput.enterText('se');
        await tester.pumpAndSettle();
        expect(_listed(tester), <String>['Seoul']);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        expect(editor.controller.text, 'Lisbon');
        expect(editor.focusNode.hasFocus, isTrue);

        // On its way out the list is still the one the query left, rather than
        // every row the label that has just gone back in lists.
        await tester.pump(const Duration(milliseconds: 50));
        expect(_listed(tester), <String>['Seoul']);

        await tester.pumpAndSettle();
        expect(_listed(tester), isEmpty);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        expect(_listed(tester), <String>['Seoul', 'Lisbon', 'Quito']);
        expect(_lit(tester), 'Lisbon');
      });

      testWidgets('empties the text as the list closes with nothing chosen, or with `multiple`', (
        WidgetTester tester,
      ) async {
        for (final Widget combobox in <Widget>[
          PlCombobox<String>(
            key: const ValueKey<String>('single'),
            options: _cities,
            value: null,
            onChanged: (String? _) {},
          ),
          PlCombobox<String>.multiple(
            key: const ValueKey<String>('multiple'),
            options: _cities,
            values: const <String>['seoul'],
            onChanged: (List<String> _) {},
          ),
        ]) {
          await tester.pumpWidget(_host(combobox));

          final EditableText editor = tester.widget<EditableText>(find.byType(EditableText));

          await tester.tap(find.byType(EditableText));
          await tester.pumpAndSettle();
          tester.testTextInput.enterText('lis');
          await tester.pumpAndSettle();
          expect(_listed(tester), <String>['Lisbon']);

          // Closed by the chevron this time, which is a close all the same.
          await tester.tap(_adornment('Open'));
          await tester.pumpAndSettle();
          expect(editor.controller.text, isEmpty);

          await tester.tap(_adornment('Open'));
          await tester.pumpAndSettle();
          expect(_listed(tester), <String>['Seoul', 'Lisbon', 'Quito']);
        }
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

        expect(find.text('Nothing here'), findsOneWidget);
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

    group('the highlight', () {
      testWidgets('lights no row as a press opens the list with nothing chosen', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(PlCombobox<String>(options: _more, value: null, onChanged: (String? _) {})),
        );

        // A press on the text, and one on the chevron.
        await tester.tap(find.byType(EditableText));
        await tester.pumpAndSettle();
        expect(_listed(tester), isNotEmpty);
        expect(_lit(tester), isNull);

        // From there up is the last row, rather than one short of it.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();
        expect(_lit(tester), 'Rome');

        await tester.tap(_adornment('Open'));
        await tester.pumpAndSettle();
        await tester.tap(_adornment('Open'));
        await tester.pumpAndSettle();
        expect(_lit(tester), isNull);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expect(_lit(tester), 'Seoul');

        // Opened from the keyboard, the first row is lit straight away.
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(_lit(tester), 'Seoul');
      });

      testWidgets('opens a `multiple` list on its first chosen row, and keeps the row just taken', (
        WidgetTester tester,
      ) async {
        List<String> values = <String>['osaka', 'lisbon'];

        await tester.pumpWidget(
          _host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => PlCombobox<String>.multiple(
                options: _more,
                values: values,
                onChanged: (List<String> next) => setState(() => values = next),
              ),
            ),
          ),
        );

        // The first chosen row down the list, not the first value in the set.
        await tester.tap(find.byType(EditableText));
        await tester.pumpAndSettle();
        expect(_lit(tester), 'Lisbon');

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(_lit(tester), 'Lisbon');

        // Two rows down, past the one that cannot be taken.
        for (int i = 0; i < 2; i += 1) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
        }
        expect(_lit(tester), 'Porto');

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(values, <String>['osaka', 'lisbon', 'porto']);
        expect(_lit(tester), 'Porto');

        // After a query, where the whole list puts the row once it is spent.
        tester.testTextInput.enterText('rom');
        await tester.pumpAndSettle();
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(values, <String>['osaka', 'lisbon', 'porto', 'rome']);
        expect(_listed(tester), <String>['Seoul', 'Lisbon', 'Quito', 'Osaka', 'Porto', 'Rome']);
        expect(_lit(tester), 'Rome');
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

      testWidgets('takes a press from 24px square round a chip’s ×', (WidgetTester tester) async {
        var removed = 0;

        await tester.pumpWidget(
          _host(
            PlCombobox<String>.multiple(
              // Its chips are the smallest there are.
              size: PlassSize.sm,
              options: _cities,
              values: const <String>['seoul'],
              onChanged: (List<String> _) => removed += 1,
            ),
          ),
        );

        final Rect mark = tester.getRect(_adornment('Remove Seoul'));

        // Just outside the drawn ×, before it and under it.
        await tester.tapAt(mark.center - Offset(mark.width / 2 + 3, 0));
        await tester.pumpAndSettle();
        await tester.tapAt(mark.center + Offset(0, mark.height / 2 + 3));
        await tester.pumpAndSettle();

        expect(removed, 2);
      });

      testWidgets('takes a chosen value back out when its row is taken again', (
        WidgetTester tester,
      ) async {
        List<String> values = <String>['seoul', 'lisbon'];

        await tester.pumpWidget(
          _host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => PlCombobox<String>.multiple(
                options: _cities,
                values: values,
                onChanged: (List<String> next) => setState(() => values = next),
              ),
            ),
          ),
        );

        await tester.tap(_adornment('Open'));
        await tester.pumpAndSettle();
        await tester.tap(_inList('Seoul'));
        await tester.pumpAndSettle();

        expect(values, <String>['lisbon']);
        expect(_adornment('Remove Seoul'), findsNothing);
        expect(_inList('Seoul'), findsOneWidget);

        // The row stays lit, so Enter puts the value back, and takes it out
        // again the next time.
        expect(_lit(tester), 'Seoul');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(values, <String>['lisbon', 'seoul']);

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(values, <String>['lisbon']);
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

      testWidgets('takes one row after another with a mouse on a desktop, and stays open', (
        WidgetTester tester,
      ) async {
        // Where a press outside the text takes the focus out of it, and the list
        // goes with the focus. Put back however the test ends.
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

        try {
          List<String> values = <String>[];

          await tester.pumpWidget(
            TapRegionSurface(
              child: _host(
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) =>
                      PlCombobox<String>.multiple(
                        options: _cities,
                        values: values,
                        onChanged: (List<String> next) => setState(() => values = next),
                      ),
                ),
              ),
            ),
          );

          final EditableText editor = tester.widget<EditableText>(find.byType(EditableText));

          await tester.tap(find.byType(EditableText), kind: PointerDeviceKind.mouse);
          await tester.pumpAndSettle();

          await tester.tap(_inList('Seoul'), kind: PointerDeviceKind.mouse);
          await tester.pumpAndSettle();

          expect(values, <String>['seoul']);
          expect(editor.focusNode.hasFocus, isTrue);
          expect(_inList('Lisbon'), findsOneWidget);

          // And after a query, the row pressed rather than the one that takes
          // its place in the whole list.
          tester.testTextInput.enterText('lis');
          await tester.pumpAndSettle();
          await tester.tap(_inList('Lisbon'), kind: PointerDeviceKind.mouse);
          await tester.pumpAndSettle();

          expect(values, <String>['seoul', 'lisbon']);
          expect(editor.focusNode.hasFocus, isTrue);
          expect(_inList('Quito'), findsOneWidget);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    });

    group('Enter', () {
      /// Gives the field the focus the way a reader does, by pressing it.
      Future<void> focus(WidgetTester tester) async {
        await tester.tap(find.byType(EditableText));
        await tester.pumpAndSettle();
      }

      /// Types [query] and presses Enter on the keyboard.
      ///
      /// Both go through the connection the focus opened, never asking for the
      /// keyboard again, so a field that loses its connection fails here.
      Future<void> submit(WidgetTester tester, String query) async {
        expect(tester.testTextInput.hasAnyClients, isTrue);
        tester.testTextInput.enterText(query);
        await tester.pumpAndSettle();
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      testWidgets('takes the lit row and leaves the field focused, so more can be taken', (
        WidgetTester tester,
      ) async {
        List<String> taken = <String>[];

        await tester.pumpWidget(
          _host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => PlCombobox<String>.multiple(
                options: _cities,
                values: taken,
                onChanged: (List<String> next) => setState(() => taken = next),
              ),
            ),
          ),
        );

        await focus(tester);
        await submit(tester, 'lis');

        expect(taken, <String>['lisbon']);
        expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus, isTrue);

        await submit(tester, 'seo');

        expect(taken, <String>['lisbon', 'seoul']);
      });

      testWidgets('takes nothing once the list has been closed', (WidgetTester tester) async {
        final List<String?> taken = <String?>[];

        await tester.pumpWidget(
          _host(PlCombobox<String>(options: _cities, value: null, onChanged: taken.add)),
        );

        await focus(tester);
        tester.testTextInput.enterText('se');
        await tester.pumpAndSettle();
        expect(find.text('Seoul'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('Seoul'), findsNothing);

        // The row that was lit is no longer on screen, and a press of Enter must
        // not commit something the reader can no longer see.
        expect(tester.testTextInput.hasAnyClients, isTrue);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(taken, isEmpty);
      });
    });

    group('Escape', () {
      /// Gives the field the focus without opening its list.
      Future<void> focus(WidgetTester tester) async {
        tester.widget<EditableText>(find.byType(EditableText)).focusNode.requestFocus();
        await tester.pumpAndSettle();
      }

      /// Presses Escape and reports whether it went past the field, to a
      /// handler round it.
      Future<bool> escape(WidgetTester tester, List<int> heard) async {
        final int before = heard.length;

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        return heard.length > before;
      }

      /// [child] with a handler round it that counts the Escapes reaching it,
      /// bound the way a route or a modal binds its own.
      Widget around(Widget child, List<int> heard) {
        return Actions(
          actions: <Type, Action<Intent>>{
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (DismissIntent intent) {
                heard.add(1);

                return null;
              },
            ),
          },
          child: child,
        );
      }

      testWidgets('closes the list, then empties the field, then goes on to what is round it', (
        WidgetTester tester,
      ) async {
        final List<int> heard = <int>[];
        String? value = 'seoul';

        await tester.pumpWidget(
          _host(
            around(
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) => PlCombobox<String>(
                  options: _cities,
                  value: value,
                  onChanged: (String? next) => setState(() => value = next),
                ),
              ),
              heard,
            ),
          ),
        );

        await tester.tap(find.byType(EditableText));
        await tester.pumpAndSettle();
        expect(_inList('Lisbon'), findsOneWidget);

        expect(await escape(tester, heard), isFalse);
        expect(_inList('Lisbon'), findsNothing);
        expect(value, 'seoul');

        expect(await escape(tester, heard), isFalse);
        expect(value, isNull);
        expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, isEmpty);

        expect(await escape(tester, heard), isTrue);
      });

      testWidgets('empties a `multiple` field with its list closed', (WidgetTester tester) async {
        final List<int> heard = <int>[];
        List<String> values = <String>['seoul', 'lisbon'];

        await tester.pumpWidget(
          _host(
            around(
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) =>
                    PlCombobox<String>.multiple(
                      options: _cities,
                      values: values,
                      onChanged: (List<String> next) => setState(() => values = next),
                    ),
              ),
              heard,
            ),
          ),
        );

        await focus(tester);

        expect(await escape(tester, heard), isFalse);
        expect(values, isEmpty);

        expect(await escape(tester, heard), isTrue);
      });

      testWidgets('empties the field in a modal, and then closes the modal', (
        WidgetTester tester,
      ) async {
        final List<bool> modal = <bool>[];
        String? value = 'seoul';

        await tester.pumpWidget(
          host(
            PlModal(
              open: true,
              onOpenChanged: modal.add,
              title: const Text('Settings'),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) => PlCombobox<String>(
                  options: _cities,
                  value: value,
                  onChanged: (String? next) => setState(() => value = next),
                ),
              ),
            ),
            overlay: true,
          ),
        );
        await tester.pumpAndSettle();
        await focus(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(value, isNull);
        expect(modal, isEmpty);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(modal, <bool>[false]);
      });

      testWidgets('leaves the key to what is round a read-only field', (WidgetTester tester) async {
        final List<int> heard = <int>[];
        final List<String?> reported = <String?>[];

        await tester.pumpWidget(
          _host(
            around(
              PlCombobox<String>(
                options: _cities,
                value: 'seoul',
                readOnly: true,
                onChanged: reported.add,
              ),
              heard,
            ),
          ),
        );

        await focus(tester);

        expect(await escape(tester, heard), isTrue);
        expect(reported, isEmpty);
      });
    });

    group('clearing', () {
      testWidgets('empties a single value as its text is emptied', (WidgetTester tester) async {
        final List<String?> reported = <String?>[];

        await tester.pumpWidget(
          _host(PlCombobox<String>(options: _cities, value: 'seoul', onChanged: reported.add)),
        );

        await tester.tap(find.byType(EditableText));
        await tester.pumpAndSettle();
        tester.testTextInput.enterText('Seo');
        await tester.pumpAndSettle();

        expect(reported, isEmpty);

        tester.testTextInput.enterText('');
        await tester.pumpAndSettle();

        expect(reported, <String?>[null]);
      });

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

      testWidgets('takes a press from 24px square round the ×, and leaves the chevron its middle', (
        WidgetTester tester,
      ) async {
        var cleared = 0;

        await tester.pumpWidget(
          _host(
            PlCombobox<String>(
              // The smallest field, where the × is drawn furthest below 24px.
              size: PlassSize.xs,
              options: _cities,
              value: 'seoul',
              onChanged: (String? _) => cleared += 1,
              clearable: true,
            ),
          ),
        );

        final Rect mark = tester.getRect(_adornment('Clear'));
        final double across = mark.width / 2 + 3;
        final double down = mark.height / 2 + 3;

        // Just outside the drawn × on every side, and inside the square.
        for (final Offset offset in <Offset>[
          Offset(-across, 0),
          Offset(across, 0),
          Offset(0, -down),
          Offset(0, down),
        ]) {
          await tester.tapAt(mark.center + offset);
          await tester.pumpAndSettle();
        }

        expect(cleared, 4);
        expect(tester.widget<PlassAnchoredPortal>(find.byType(PlassAnchoredPortal)).open, isFalse);

        // The chevron keeps the size it is drawn at, and its middle is its own.
        await tester.tap(_adornment('Open'));
        await tester.pumpAndSettle();

        expect(cleared, 4);
        expect(tester.widget<PlassAnchoredPortal>(find.byType(PlassAnchoredPortal)).open, isTrue);
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

    group('labelPlacement', () {
      testWidgets('puts the label in the field\'s own top edge', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlCombobox<String>(
              options: _cities,
              value: null,
              label: const Text('City'),
              labelPlacement: PlassFieldLabelPlacement.notch,
              onChanged: (String? _) {},
            ),
            width: 320,
          ),
        );

        expect(find.byType(PlassFieldNotch), findsOneWidget);
        expect(find.text('City'), findsOneWidget);
      });
    });
  });
}
