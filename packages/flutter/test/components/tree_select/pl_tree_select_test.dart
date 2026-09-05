import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

const List<PlTreeSelectNode> items = <PlTreeSelectNode>[
  PlTreeSelectNode(
    id: 'europe',
    label: 'Europe',
    children: <PlTreeSelectNode>[
      PlTreeSelectNode(id: 'france', label: 'France'),
      PlTreeSelectNode(id: 'spain', label: 'Spain'),
    ],
  ),
  PlTreeSelectNode(
    id: 'asia',
    label: 'Asia',
    children: <PlTreeSelectNode>[
      PlTreeSelectNode(id: 'korea', label: 'South Korea'),
      PlTreeSelectNode(id: 'japan', label: 'Japan', disabled: true),
    ],
  ),
  PlTreeSelectNode(id: 'antarctica', label: 'Antarctica'),
];

/// A picker that keeps its own value and folds, which is what a caller writes.
class _Host extends StatefulWidget {
  const _Host({
    this.value = const <String>{},
    this.expanded = const <String>{},
    this.multiple = false,
    this.selectableBranches = false,
    this.searchable = false,
    this.closeOnSelect,
    this.onValueChanged,
  });

  final Set<String> value;
  final Set<String> expanded;
  final bool multiple;
  final bool selectableBranches;
  final bool searchable;
  final bool? closeOnSelect;
  final ValueChanged<Set<String>>? onValueChanged;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late Set<String> _value = widget.value;
  late Set<String> _expanded = widget.expanded;

  @override
  Widget build(BuildContext context) {
    return PlTreeSelect(
      items: items,
      value: _value,
      multiple: widget.multiple,
      selectableBranches: widget.selectableBranches,
      searchable: widget.searchable,
      closeOnSelect: widget.closeOnSelect,
      placeholder: const Text('Pick a region'),
      expanded: _expanded,
      onExpandedChanged: (Set<String> next) => setState(() => _expanded = next),
      onValueChanged: (Set<String> next) {
        setState(() => _value = next);
        widget.onValueChanged?.call(next);
      },
    );
  }
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(900, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, overlay: true));
  await tester.pumpAndSettle();
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byType(PlTreeSelect));
  await tester.pumpAndSettle();
}

/// A row, found inside the tree.
///
/// Scoped rather than found by its text alone: the trigger writes the labels of
/// what is held, so a chosen node is on the screen twice — once as the answer
/// and once as the row that gave it.
Finder _row(String label) => find.descendant(of: find.byType(PlTree), matching: find.text(label));

Future<void> _tapRow(WidgetTester tester, String label) async {
  await tester.tap(_row(label));
  await tester.pumpAndSettle();
}

void main() {
  group('PlTreeSelect', () {
    group('rendering', () {
      testWidgets('shows the placeholder while nothing is chosen', (WidgetTester tester) async {
        await _pump(tester, const _Host());

        expect(find.text('Pick a region'), findsOneWidget);
      });

      testWidgets('writes the label of what is held', (WidgetTester tester) async {
        await _pump(tester, const _Host(value: <String>{'france'}));

        expect(find.text('France'), findsOneWidget);
      });

      testWidgets('joins more than one label with a comma', (WidgetTester tester) async {
        await _pump(tester, const _Host(multiple: true, value: <String>{'france', 'spain'}));

        expect(find.text('France, Spain'), findsOneWidget);
      });

      testWidgets('takes a format of its own', (WidgetTester tester) async {
        await _pump(
          tester,
          PlTreeSelect(
            items: items,
            value: const <String>{'france', 'spain'},
            multiple: true,
            onValueChanged: (Set<String> _) {},
            format: (List<PlTreeSelectNode> chosen) => '${chosen.length} chosen',
          ),
        );

        expect(find.text('2 chosen'), findsOneWidget);
      });

      testWidgets('renders the label, the description and the error', (WidgetTester tester) async {
        await _pump(
          tester,
          PlTreeSelect(
            items: items,
            onValueChanged: (Set<String> _) {},
            label: const Text('Region'),
            description: const Text('Where it ships from.'),
            error: const Text('Pick a region.'),
          ),
        );

        expect(find.text('Region'), findsOneWidget);
        expect(find.text('Where it ships from.'), findsOneWidget);
        expect(find.text('Pick a region.'), findsOneWidget);
      });
    });

    group('the popup', () {
      testWidgets('opens the tree when the trigger is pressed', (WidgetTester tester) async {
        await _pump(tester, const _Host());
        await _open(tester);

        expect(find.byType(PlTree), findsOneWidget);
        expect(find.text('Europe'), findsOneWidget);
        expect(find.text('Antarctica'), findsOneWidget);
      });

      testWidgets('keeps a branch closed until it is asked', (WidgetTester tester) async {
        await _pump(tester, const _Host());
        await _open(tester);

        expect(find.text('France'), findsNothing);
      });

      testWidgets('opens the branches it was told start open', (WidgetTester tester) async {
        await _pump(tester, const _Host(expanded: <String>{'europe'}));
        await _open(tester);

        expect(find.text('France'), findsOneWidget);
      });

      testWidgets('does not open while read-only', (WidgetTester tester) async {
        await _pump(
          tester,
          PlTreeSelect(items: items, readOnly: true, onValueChanged: (Set<String> _) {}),
        );
        await _open(tester);

        expect(find.byType(PlTree), findsNothing);
      });
    });

    group('choosing', () {
      testWidgets('holds a leaf that was pressed', (WidgetTester tester) async {
        Set<String>? seen;

        await _pump(
          tester,
          _Host(
            expanded: const <String>{'europe'},
            onValueChanged: (Set<String> next) => seen = next,
          ),
        );
        await _open(tester);
        await _tapRow(tester, 'France');

        expect(seen, <String>{'france'});
      });

      testWidgets('closes as soon as a leaf is chosen', (WidgetTester tester) async {
        await _pump(tester, const _Host(expanded: <String>{'europe'}));
        await _open(tester);
        await _tapRow(tester, 'France');

        expect(find.byType(PlTree), findsNothing);
      });

      testWidgets('stays open when closeOnSelect says so', (WidgetTester tester) async {
        await _pump(tester, const _Host(expanded: <String>{'europe'}, closeOnSelect: false));
        await _open(tester);
        await _tapRow(tester, 'France');

        expect(find.byType(PlTree), findsOneWidget);
      });

      testWidgets('replaces what is held unless it is multiple', (WidgetTester tester) async {
        Set<String>? seen;

        await _pump(
          tester,
          _Host(
            value: const <String>{'france'},
            expanded: const <String>{'europe'},
            closeOnSelect: false,
            onValueChanged: (Set<String> next) => seen = next,
          ),
        );
        await _open(tester);
        await _tapRow(tester, 'Spain');

        expect(seen, <String>{'spain'});
      });

      testWidgets('adds to what is held when it is multiple', (WidgetTester tester) async {
        Set<String>? seen;

        await _pump(
          tester,
          _Host(
            multiple: true,
            value: const <String>{'france'},
            expanded: const <String>{'europe'},
            onValueChanged: (Set<String> next) => seen = next,
          ),
        );
        await _open(tester);
        await _tapRow(tester, 'Spain');

        expect(seen, <String>{'france', 'spain'});
      });

      testWidgets('takes a chosen node back out when it is pressed again', (
        WidgetTester tester,
      ) async {
        Set<String>? seen;

        await _pump(
          tester,
          _Host(
            multiple: true,
            value: const <String>{'france'},
            expanded: const <String>{'europe'},
            onValueChanged: (Set<String> next) => seen = next,
          ),
        );
        await _open(tester);
        await _tapRow(tester, 'France');

        expect(seen, isEmpty);
      });

      testWidgets('leaves a disabled node alone', (WidgetTester tester) async {
        Set<String>? seen;

        await _pump(
          tester,
          _Host(
            expanded: const <String>{'asia'},
            onValueChanged: (Set<String> next) => seen = next,
          ),
        );
        await _open(tester);
        await _tapRow(tester, 'Japan');

        expect(seen, isNull);
      });

      testWidgets('empties the control from the clear button', (WidgetTester tester) async {
        Set<String>? seen;

        await _pump(
          tester,
          PlTreeSelect(
            items: items,
            value: const <String>{'france'},
            clearable: true,
            onValueChanged: (Set<String> next) => seen = next,
          ),
        );

        await tester.tap(find.bySemanticsLabel('Clear'));
        await tester.pumpAndSettle();

        expect(seen, isEmpty);
      });
    });

    group('branches', () {
      testWidgets('opens a branch rather than choosing it', (WidgetTester tester) async {
        Set<String>? seen;

        await _pump(tester, _Host(onValueChanged: (Set<String> next) => seen = next));
        await _open(tester);
        await _tapRow(tester, 'Europe');

        expect(seen, isNull);
        expect(find.text('France'), findsOneWidget);
      });

      testWidgets('chooses a branch when selectableBranches says it may', (
        WidgetTester tester,
      ) async {
        Set<String>? seen;

        await _pump(
          tester,
          _Host(
            selectableBranches: true,
            closeOnSelect: false,
            onValueChanged: (Set<String> next) => seen = next,
          ),
        );
        await _open(tester);
        await _tapRow(tester, 'Europe');

        expect(seen, <String>{'europe'});
      });

      testWidgets('lets one node override selectableBranches', (WidgetTester tester) async {
        Set<String>? seen;

        await _pump(
          tester,
          PlTreeSelect(
            items: const <PlTreeSelectNode>[
              PlTreeSelectNode(
                id: 'europe',
                label: 'Europe',
                selectable: true,
                children: <PlTreeSelectNode>[PlTreeSelectNode(id: 'france', label: 'France')],
              ),
            ],
            open: true,
            closeOnSelect: false,
            onValueChanged: (Set<String> next) => seen = next,
          ),
        );
        await _tapRow(tester, 'Europe');

        expect(seen, <String>{'europe'});
      });
    });

    group('searching', () {
      testWidgets('offers no field unless it is searchable', (WidgetTester tester) async {
        await _pump(tester, const _Host());
        await _open(tester);

        expect(find.byType(PlTextField), findsNothing);
      });

      testWidgets('keeps the matches and every ancestor of one', (WidgetTester tester) async {
        await _pump(tester, const _Host(searchable: true));
        await _open(tester);

        await tester.enterText(find.byType(PlTextField), 'france');
        await tester.pumpAndSettle();

        expect(find.text('Europe'), findsOneWidget);
        expect(find.text('France'), findsOneWidget);
        expect(find.text('Asia'), findsNothing);
      });

      testWidgets('folds case away', (WidgetTester tester) async {
        await _pump(tester, const _Host(searchable: true));
        await _open(tester);

        await tester.enterText(find.byType(PlTextField), 'ANTARCTICA');
        await tester.pumpAndSettle();

        expect(find.text('Antarctica'), findsOneWidget);
        expect(find.text('Europe'), findsNothing);
      });

      testWidgets('says so when nothing matched', (WidgetTester tester) async {
        await _pump(tester, const _Host(searchable: true));
        await _open(tester);

        await tester.enterText(find.byType(PlTextField), 'atlantis');
        await tester.pumpAndSettle();

        expect(find.text('Nothing here'), findsOneWidget);
      });

      testWidgets('hands the folds back when the field is emptied', (WidgetTester tester) async {
        await _pump(tester, const _Host(searchable: true));
        await _open(tester);

        await tester.enterText(find.byType(PlTextField), 'france');
        await tester.pumpAndSettle();
        expect(find.text('Asia'), findsNothing);

        await tester.enterText(find.byType(PlTextField), '');
        await tester.pumpAndSettle();

        expect(find.text('Asia'), findsOneWidget);
        expect(find.text('France'), findsNothing);
      });
    });
  });
}
