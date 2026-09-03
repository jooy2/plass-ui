import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

const List<PlTreeNode> items = <PlTreeNode>[
  PlTreeNode(
    id: 'src',
    label: Text('src'),
    children: <PlTreeNode>[
      PlTreeNode(id: 'index', label: Text('index.ts')),
      PlTreeNode(
        id: 'components',
        label: Text('components'),
        children: <PlTreeNode>[PlTreeNode(id: 'button', label: Text('PlButton.tsx'))],
      ),
    ],
  ),
  PlTreeNode(id: 'readme', label: Text('README.md')),
  PlTreeNode(id: 'lock', label: Text('package-lock.json'), disabled: true),
];

/// A tree that keeps its own open and selected sets, which is what a caller
/// writes and what makes the interaction tests about the widget.
class _Host extends StatefulWidget {
  const _Host({this.expanded = const <String>{}});

  final Set<String> expanded;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late Set<String> _expanded = widget.expanded;
  Set<String> _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    return PlTree(
      items: items,
      expanded: _expanded,
      onExpandedChanged: (Set<String> next) => setState(() => _expanded = next),
      selected: _selected,
      onSelectedChanged: (Set<String> next) => setState(() => _selected = next),
    );
  }
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(host(child, width: 400));
  await tester.pumpAndSettle();
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

/// Which row holds the focus, by the id in its node's debug label.
///
/// The tree gives every row's `FocusNode` a `debugLabel` of `PlTree <id>`,
/// which is the only thing that identifies a focused row from outside — a tap
/// does not move the focus in Flutter the way a click does in a browser, so
/// these tests reach the tree with `Tab` and then drive it with the arrows,
/// which is also how a keyboard reader gets there.
String? _focused() {
  final String? label = FocusManager.instance.primaryFocus?.debugLabel;

  return label != null && label.startsWith('PlTree ') ? label.substring('PlTree '.length) : null;
}

/// Every row's focus node, in the order they are drawn.
List<FocusNode> _rowNodes(WidgetTester tester) {
  return tester
      .widgetList<Focus>(find.byType(Focus))
      .map((Focus focus) => focus.focusNode)
      .whereType<FocusNode>()
      .where((FocusNode node) => node.debugLabel?.startsWith('PlTree ') ?? false)
      .toList(growable: false);
}

/// Puts the focus on one row, the way tabbing into the tree would.
///
/// Directly rather than with a `Tab` key: the test host is deliberately not a
/// `WidgetsApp`, so nothing has installed the traversal shortcuts that turn a
/// `Tab` into a `NextFocusIntent`. What is under test here is the arrow keys.
Future<void> _focusRow(WidgetTester tester, String text) async {
  final Focus focus = tester.widget<Focus>(
    find.ancestor(of: find.text(text), matching: find.byType(Focus)).first,
  );

  focus.focusNode!.requestFocus();
  await tester.pumpAndSettle();
}

void main() {
  group('PlTree', () {
    group('rendering', () {
      testWidgets('draws the top level and nothing under it', (WidgetTester tester) async {
        await _pump(tester, const _Host());

        expect(find.text('src'), findsOneWidget);
        expect(find.text('README.md'), findsOneWidget);
        expect(find.text('index.ts'), findsNothing);
      });

      testWidgets('opens the branches it was told start open', (WidgetTester tester) async {
        await _pump(tester, const _Host(expanded: <String>{'src'}));

        expect(find.text('index.ts'), findsOneWidget);
      });

      testWidgets('indents each level', (WidgetTester tester) async {
        await _pump(tester, const _Host(expanded: <String>{'src'}));

        expect(
          tester.getTopLeft(find.text('index.ts')).dx,
          greaterThan(tester.getTopLeft(find.text('src')).dx),
        );
      });
    });

    group('opening and closing', () {
      testWidgets('opens a branch when it is pressed', (WidgetTester tester) async {
        await _pump(tester, const _Host());
        await tester.tap(find.text('src'));
        await tester.pumpAndSettle();

        expect(find.text('index.ts'), findsOneWidget);
      });

      testWidgets('closes it again', (WidgetTester tester) async {
        await _pump(tester, const _Host(expanded: <String>{'src'}));
        await tester.tap(find.text('src'));
        await tester.pumpAndSettle();

        expect(find.text('index.ts'), findsNothing);
      });

      testWidgets('turns the twisty rather than jumping it between two angles', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const _Host());

        double turnsOf(String label) {
          return tester
              .widget<AnimatedRotation>(
                find
                    .descendant(
                      of: find.ancestor(of: find.text(label), matching: find.byType(Row)).last,
                      matching: find.byType(AnimatedRotation),
                    )
                    .first,
              )
              .turns;
        }

        expect(turnsOf('src'), -0.25);

        await tester.tap(find.text('src'));
        await tester.pump();
        await tester.pump(PlassTokens.duration ~/ 2);

        // Mid-turn there is a rotation on the way to zero rather than a glyph
        // that has already arrived at it.
        final RotationTransition turning = tester.widget<RotationTransition>(
          find
              .descendant(
                of: find.ancestor(of: find.text('src'), matching: find.byType(Row)).last,
                matching: find.byType(RotationTransition),
              )
              .first,
        );

        expect(turning.turns.value, greaterThan(-0.25));
        expect(turning.turns.value, lessThan(0));

        await tester.pumpAndSettle();

        expect(turnsOf('src'), 0);
      });

      testWidgets('reports the whole open set', (WidgetTester tester) async {
        Set<String>? open;

        await _pump(
          tester,
          PlTree(items: items, onExpandedChanged: (Set<String> next) => open = next),
        );
        await tester.tap(find.text('src'));
        await tester.pumpAndSettle();

        expect(open, equals(<String>{'src'}));
      });
    });

    group('selection', () {
      testWidgets('reports one row at a time', (WidgetTester tester) async {
        Set<String>? chosen;

        await _pump(
          tester,
          PlTree(items: items, onSelectedChanged: (Set<String> next) => chosen = next),
        );
        await tester.tap(find.text('README.md'));
        await tester.pumpAndSettle();

        expect(chosen, equals(<String>{'readme'}));
      });

      testWidgets('adds to the set when there can be more than one', (WidgetTester tester) async {
        Set<String>? chosen;

        await _pump(
          tester,
          PlTree(
            items: items,
            selection: PlTreeSelection.multiple,
            selected: const <String>{'src'},
            onSelectedChanged: (Set<String> next) => chosen = next,
          ),
        );
        await tester.tap(find.text('README.md'));
        await tester.pumpAndSettle();

        expect(chosen, equals(<String>{'src', 'readme'}));
      });

      testWidgets('reports nothing when there is no selection to make', (
        WidgetTester tester,
      ) async {
        Set<String>? chosen;
        PlTreeNode? pressed;

        await _pump(
          tester,
          PlTree(
            items: items,
            selection: PlTreeSelection.none,
            onSelectedChanged: (Set<String> next) => chosen = next,
            onItemPressed: (PlTreeNode node) => pressed = node,
          ),
        );
        await tester.tap(find.text('README.md'));
        await tester.pumpAndSettle();

        // A browser rather than a chooser: the press still reports, and nothing
        // stays lit.
        expect(chosen, isNull);
        expect(pressed?.id, equals('readme'));
      });
    });

    group('the keyboard', () {
      testWidgets('hands Tab exactly one row', (WidgetTester tester) async {
        await _pump(tester, const _Host(expanded: <String>{'src'}));

        // A tree where Tab walked four hundred rows would be one nobody reaches
        // the end of. Every row but the current one is out of the traversal
        // order while staying in the focus tree, so the arrows can still get to
        // it.
        final List<FocusNode> nodes = _rowNodes(tester);

        expect(nodes.length, greaterThan(1));
        expect(nodes.where((FocusNode node) => !node.skipTraversal).length, equals(1));
      });

      testWidgets('moves that one tab stop to wherever the focus went', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const _Host(expanded: <String>{'src'}));
        await _focusRow(tester, 'index.ts');

        // It follows the focus rather than leading it, so tabbing back into a
        // tree returns to the row you left.
        final FocusNode stop = _rowNodes(
          tester,
        ).firstWhere((FocusNode node) => !node.skipTraversal);

        expect(stop.debugLabel, equals('PlTree index'));
      });

      testWidgets('walks down the rows that are visible', (WidgetTester tester) async {
        await _pump(tester, const _Host(expanded: <String>{'src'}));
        await _focusRow(tester, 'src');
        await _press(tester, LogicalKeyboardKey.arrowDown);

        expect(_focused(), equals('index'));

        await _press(tester, LogicalKeyboardKey.arrowUp);

        expect(_focused(), equals('src'));
      });

      testWidgets('opens a closed branch with the right arrow, then steps in', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const _Host());
        await _focusRow(tester, 'src');
        await _press(tester, LogicalKeyboardKey.arrowRight);

        expect(find.text('index.ts'), findsOneWidget);
        // Still on the branch — one press opens, the next enters.
        expect(_focused(), equals('src'));

        await _press(tester, LogicalKeyboardKey.arrowRight);

        expect(_focused(), equals('index'));
      });

      testWidgets('closes an open branch with the left arrow', (WidgetTester tester) async {
        await _pump(tester, const _Host(expanded: <String>{'src'}));
        await _focusRow(tester, 'src');
        await _press(tester, LogicalKeyboardKey.arrowLeft);

        expect(find.text('index.ts'), findsNothing);
      });

      testWidgets('steps out to the parent from a leaf', (WidgetTester tester) async {
        await _pump(tester, const _Host(expanded: <String>{'src'}));
        await _focusRow(tester, 'src');
        await _press(tester, LogicalKeyboardKey.arrowDown);

        expect(_focused(), equals('index'));

        await _press(tester, LogicalKeyboardKey.arrowLeft);

        expect(_focused(), equals('src'));
      });

      testWidgets('jumps to the ends', (WidgetTester tester) async {
        await _pump(tester, const _Host(expanded: <String>{'src'}));
        await _focusRow(tester, 'src');
        await _press(tester, LogicalKeyboardKey.end);

        // The last row a reader can get to, which is not the disabled one.
        expect(_focused(), equals('readme'));

        await _press(tester, LogicalKeyboardKey.home);

        expect(_focused(), equals('src'));
      });
    });

    group('a disabled row', () {
      testWidgets('does not report when it is pressed', (WidgetTester tester) async {
        PlTreeNode? pressed;

        await _pump(
          tester,
          PlTree(items: items, onItemPressed: (PlTreeNode node) => pressed = node),
        );
        await tester.tap(find.text('package-lock.json'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(pressed, isNull);
      });

      testWidgets('is not a stop for the arrow keys', (WidgetTester tester) async {
        await _pump(tester, const _Host());
        await _focusRow(tester, 'README.md');

        expect(_focused(), equals('readme'));

        await _press(tester, LogicalKeyboardKey.arrowDown);

        // It is left in the tree rather than removed — a hierarchy with a hole
        // in it is one nobody can read — but the arrows walk past it.
        expect(_focused(), equals('readme'));
      });
    });

    group('an empty branch', () {
      testWidgets('is a branch rather than a leaf', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlTree(
            items: <PlTreeNode>[
              PlTreeNode(id: 'empty', label: Text('Archive'), children: <PlTreeNode>[]),
            ],
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // `children: []` opens and shows nothing; `null` has no twisty at all.
        expect(
          find.byWidgetPredicate(
            (Widget widget) => widget is Semantics && widget.properties.expanded == false,
          ),
          findsOneWidget,
        );

        handle.dispose();
      });
    });
  });
}
