import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/scales.dart';

import '../../support/host.dart';

class _Build {
  const _Build(this.id, this.branch);

  final String id;
  final String branch;
}

const List<_Build> _rows = <_Build>[
  _Build('#412', 'main'),
  _Build('#411', 'fix/glass-edge'),
  _Build('#410', 'topic/table'),
];

List<PlTableColumn<_Build>> _columns() {
  return <PlTableColumn<_Build>>[
    PlTableColumn<_Build>(
      header: const Text('Build'),
      cell: (_Build row, int index) => Text(row.id),
    ),
    PlTableColumn<_Build>(
      header: const Text('Branch'),
      align: PlassAlign.end,
      cell: (_Build row, int index) => Text(row.branch),
    ),
  ];
}

Widget _table({
  List<_Build> rows = _rows,
  bool striped = false,
  bool hoverable = false,
  Widget? caption,
  Widget? empty,
  bool stickyHeader = false,
  double? maxHeight,
  void Function(_Build row, int index)? onRowPressed,
}) {
  return host(
    PlTable<_Build>(
      rows: rows,
      columns: _columns(),
      striped: striped,
      hoverable: hoverable,
      caption: caption,
      empty: empty,
      stickyHeader: stickyHeader,
      maxHeight: maxHeight,
      onRowPressed: onRowPressed,
    ),
    width: 420,
  );
}

/// Twenty-four rows, which is more than any cap in this suite.
final List<_Build> _many = <_Build>[
  for (var index = 0; index < 24; index += 1) _Build('#${400 + index}', 'topic/$index'),
];

/// Content with a `State` of its own: built again from scratch, it is a
/// different object, where a field would have lost what was typed into it.
class _Probe extends StatefulWidget {
  const _Probe(this.text);

  final String text;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => Text(widget.text);
}

/// Whether the focus is on a row of the grid, or on something inside one.
///
/// Asked of the grid rather than of the whole table: a table capped short of
/// its rows is a stop of its own, round the grid, and that stop is not a row.
bool _holdsRow(WidgetTester tester) {
  final BuildContext? focused = FocusManager.instance.primaryFocus?.context;

  return focused != null &&
      find
          .descendant(
            of: find.byType(Table),
            matching: find.byElementPredicate((Element element) => element == focused),
          )
          .evaluate()
          .isNotEmpty;
}

/// Moves the focus to [before] and presses Tab once, as a keyboard reader
/// arriving at the table does.
Future<void> _tabFrom(WidgetTester tester, FocusNode before) async {
  before.requestFocus();
  await tester.pump();
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pumpAndSettle();
}

/// The decoration row number [index] paints — the header is row `0`.
///
/// The header's is its [TableRow]'s. The rows of data are painted behind the
/// grid, by the painter of the [CustomPaint] around it.
BoxDecoration _rowDecoration(WidgetTester tester, int index) {
  if (index == 0) {
    return tester.widget<Table>(find.byType(Table)).children[0].decoration! as BoxDecoration;
  }

  final CustomPaint bands = tester.widget<CustomPaint>(
    find.ancestor(of: find.byType(Table), matching: find.byType(CustomPaint)).first,
  );

  return (bands.painter! as dynamic).decorationOf(index - 1) as BoxDecoration;
}

void main() {
  group('PlTable', () {
    group('shapes', () {
      testWidgets('draws a heading per column and a cell per row', (WidgetTester tester) async {
        await tester.pumpWidget(_table());

        expect(find.text('Build'), findsOneWidget);
        expect(find.text('Branch'), findsOneWidget);
        expect(find.text('#412'), findsOneWidget);
        expect(find.text('topic/table'), findsOneWidget);
      });

      testWidgets('still draws its headings with no rows at all', (WidgetTester tester) async {
        await tester.pumpWidget(_table(rows: const <_Build>[]));

        expect(find.text('Build'), findsOneWidget);
        expect(find.text('No data'), findsOneWidget);
      });

      testWidgets('takes the empty line it was given', (WidgetTester tester) async {
        await tester.pumpWidget(
          _table(rows: const <_Build>[], empty: const Text('Nothing built yet.')),
        );

        expect(find.text('Nothing built yet.'), findsOneWidget);
        expect(find.text('No data'), findsNothing);
      });

      testWidgets('draws the caption above the grid', (WidgetTester tester) async {
        await tester.pumpWidget(_table(caption: const Text('Recent builds')));

        final caption = tester.getTopLeft(find.text('Recent builds'));
        final heading = tester.getTopLeft(find.text('Build'));

        expect(caption.dy, lessThan(heading.dy));
      });
    });

    group('columns', () {
      testWidgets('measures a column from its content and shares what is left', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_table());

        final widths = tester.widget<Table>(find.byType(Table)).columnWidths!;

        expect(widths[0], isA<IntrinsicColumnWidth>());
        expect(widths[1], isA<IntrinsicColumnWidth>());
      });

      testWidgets('a stated width is the width', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlTable<_Build>(
              rows: _rows,
              columns: <PlTableColumn<_Build>>[
                PlTableColumn<_Build>(
                  header: const Text('Build'),
                  width: 120,
                  cell: (_Build row, int index) => Text(row.id),
                ),
              ],
            ),
            width: 420,
          ),
        );

        expect(tester.widget<Table>(find.byType(Table)).columnWidths![0], isA<FixedColumnWidth>());
        expect(tester.getSize(find.text('#412')).width, lessThanOrEqualTo(120));
      });

      testWidgets('align moves the cell to the trailing edge', (WidgetTester tester) async {
        await tester.pumpWidget(_table());

        final aligned = tester.widget<Align>(
          find.ancestor(of: find.text('main'), matching: find.byType(Align)).first,
        );
        final start = tester.widget<Align>(
          find.ancestor(of: find.text('#412'), matching: find.byType(Align)).first,
        );

        expect(aligned.alignment, AlignmentDirectional.centerEnd);
        expect(start.alignment, AlignmentDirectional.centerStart);
      });

      group('what a cell holds', () {
        /// A column whose heading and cells each have a `State`, told apart by
        /// the [name] every one of them starts with.
        PlTableColumn<_Build> probed(String name, {String? key}) {
          return PlTableColumn<_Build>(
            key: key,
            header: _Probe(name),
            cell: (_Build row, int index) => _Probe('$name ${row.id}'),
          );
        }

        Widget table(List<PlTableColumn<_Build>> columns) {
          return host(PlTable<_Build>(rows: _rows, columns: columns), width: 640);
        }

        /// Every probe in the grid by what it says.
        Map<String, _ProbeState> probes(WidgetTester tester) {
          return <String, _ProbeState>{
            for (final _ProbeState state in tester.stateList<_ProbeState>(
              find.descendant(of: find.byType(Table), matching: find.byType(_Probe)),
            ))
              state.widget.text: state,
          };
        }

        /// Checks that every probe that was in [before] is still there, the
        /// same object.
        void expectKept(Map<String, _ProbeState> before, WidgetTester tester, String reason) {
          final Map<String, _ProbeState> now = probes(tester);

          for (final MapEntry<String, _ProbeState> probe in before.entries) {
            expect(now[probe.key], same(probe.value), reason: '${probe.key}, $reason');
          }
        }

        testWidgets('stays with a keyed column as a column is put in front of it and taken away', (
          WidgetTester tester,
        ) async {
          final List<PlTableColumn<_Build>> keyed = <PlTableColumn<_Build>>[
            probed('Build', key: 'build'),
            probed('Branch', key: 'branch'),
          ];

          await tester.pumpWidget(table(keyed));

          final Map<String, _ProbeState> resting = probes(tester);

          expect(resting, hasLength(8));

          await tester.pumpWidget(
            table(<PlTableColumn<_Build>>[probed('Note', key: 'note'), ...keyed]),
          );
          expectKept(resting, tester, 'a column in front');

          await tester.pumpWidget(table(keyed));
          expectKept(resting, tester, 'taken away again');
        });

        testWidgets('stays with the place of a column that has no key', (
          WidgetTester tester,
        ) async {
          final List<PlTableColumn<_Build>> unkeyed = <PlTableColumn<_Build>>[
            probed('Build'),
            probed('Branch'),
          ];

          await tester.pumpWidget(table(unkeyed));

          final Map<String, _ProbeState> resting = probes(tester);

          // A keyed column in front moves none of them from their place among
          // the columns with no key.
          await tester.pumpWidget(
            table(<PlTableColumn<_Build>>[probed('Note', key: 'note'), ...unkeyed]),
          );
          expectKept(resting, tester, 'a keyed column in front');

          await tester.pumpWidget(table(unkeyed));
          expectKept(resting, tester, 'taken away again');

          // One with no key in front takes the first place over, and with it
          // what the column that was there held, as a table with no keys
          // always has.
          await tester.pumpWidget(table(<PlTableColumn<_Build>>[probed('Note'), ...unkeyed]));

          final Map<String, _ProbeState> now = probes(tester);

          expect(now['Note'], same(resting['Build']));
          expect(now['Note #412'], same(resting['Build #412']));
          expect(now['Build #412'], same(resting['Branch #412']));
        });
      });
    });

    group('rules', () {
      testWidgets('the header sits on the firmer of the two rules', (WidgetTester tester) async {
        await tester.pumpWidget(_table());

        final tokens = PlassTokens.light();

        expect(_rowDecoration(tester, 0).border!.bottom.color, tokens.border);
        expect(_rowDecoration(tester, 2).border!.top.color, tokens.divider);
      });

      testWidgets('the first row has no rule of its own', (WidgetTester tester) async {
        await tester.pumpWidget(_table());

        expect(_rowDecoration(tester, 1).border, isNull);
      });

      testWidgets('striped tints every other row and leaves the rest bare', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_table(striped: true));

        expect(_rowDecoration(tester, 1).color, isNull);
        expect(_rowDecoration(tester, 2).color, PlassTokens.light().stripe);
      });
    });

    group('rows', () {
      testWidgets('a press reports the row and where it was', (WidgetTester tester) async {
        final pressed = <String>[];
        await tester.pumpWidget(
          _table(onRowPressed: (_Build row, int index) => pressed.add('${row.id}@$index')),
        );

        await tester.tap(find.text('#411'));
        expect(pressed, <String>['#411@1']);
      });

      testWidgets('a row nothing listens to is not pressable', (WidgetTester tester) async {
        await tester.pumpWidget(_table());

        // The detectors are there either way, so a row keeps its cells as it
        // becomes pressable. Nothing listens to them, and nothing changes the
        // cursor.
        expect(
          tester
              .widgetList<GestureDetector>(
                find.descendant(of: find.byType(Table), matching: find.byType(GestureDetector)),
              )
              .where((GestureDetector detector) => detector.onTap != null),
          isEmpty,
        );
        expect(
          tester
              .widgetList<MouseRegion>(
                find.descendant(of: find.byType(Table), matching: find.byType(MouseRegion)),
              )
              .where((MouseRegion region) => region.cursor != MouseCursor.defer),
          isEmpty,
        );
      });

      testWidgets(
        'keeps what its cells hold as onRowPressed, hoverable, maxHeight and stickyHeader change',
        (WidgetTester tester) async {
          final SemanticsHandle handle = tester.ensureSemantics();
          final before = FocusNode(debugLabel: 'before');
          addTearDown(before.dispose);

          Widget table({
            bool pressable = false,
            bool hoverable = false,
            bool capped = false,
            bool pinned = false,
          }) {
            return host(
              afterFocusStop(
                before,
                PlTable<_Build>(
                  rows: _rows,
                  hoverable: hoverable,
                  onRowPressed: pressable ? (_Build row, int index) {} : null,
                  // A cap the rows fit under, so that the grid is no stop of its
                  // own and Tab goes straight to a row.
                  maxHeight: capped ? 400 : null,
                  stickyHeader: pinned,
                  columns: <PlTableColumn<_Build>>[
                    PlTableColumn<_Build>(
                      header: const Text('Build'),
                      cell: (_Build row, int index) => _Probe(row.id),
                    ),
                    PlTableColumn<_Build>(
                      header: const Text('Branch'),
                      cell: (_Build row, int index) => _Probe(row.branch),
                    ),
                  ],
                ),
              ),
              width: 420,
            );
          }

          await tester.pumpWidget(table());
          await tester.pumpAndSettle();

          final List<State<_Probe>> resting = tester
              .stateList<State<_Probe>>(find.byType(_Probe))
              .toList();

          expect(resting, hasLength(6));

          // Every wrapper the grid has, on and off, alone and together.
          for (final (bool pressable, bool hoverable, bool capped, bool pinned)
              in <(bool, bool, bool, bool)>[
                (true, false, false, false),
                (false, false, false, false),
                (false, true, false, false),
                (true, true, false, false),
                (false, false, true, false),
                (false, false, true, true),
                (true, false, true, true),
                (false, true, false, true),
                (false, false, false, false),
              ]) {
            final String reason =
                'pressable $pressable, hoverable $hoverable, capped $capped, pinned $pinned';

            await tester.pumpWidget(
              table(pressable: pressable, hoverable: hoverable, capped: capped, pinned: pinned),
            );
            await tester.pumpAndSettle();

            // Built again from scratch, a probe is a different object, and a
            // field in its place would have lost what was typed into it.
            final List<State<_Probe>> now = tester
                .stateList<State<_Probe>>(find.byType(_Probe))
                .toList();

            expect(now, hasLength(resting.length), reason: reason);

            for (var index = 0; index < resting.length; index += 1) {
              expect(now[index], same(resting[index]), reason: 'probe $index, $reason');
            }

            // A stop with a tap in the first cell and a tap in the rest only
            // while the row can be pressed, and no more than the words
            // otherwise, as it always said.
            expect(
              tester.getSemantics(find.text('#412')),
              isSemantics(
                label: '#412',
                isFocusable: pressable,
                hasFocusAction: pressable,
                hasTapAction: pressable,
              ),
              reason: reason,
            );
            expect(
              tester.getSemantics(find.text('main')),
              isSemantics(label: 'main', isFocusable: false, hasTapAction: pressable),
              reason: reason,
            );

            await _tabFrom(tester, before);

            expect(_holdsRow(tester), pressable, reason: reason);
          }

          handle.dispose();
        },
      );

      testWidgets(
        'keeps what is typed into a field in a row, and the focus, as it becomes pressable',
        (WidgetTester tester) async {
          Widget table({required bool pressable}) {
            return host(
              PlTable<_Build>(
                rows: _rows,
                onRowPressed: pressable ? (_Build row, int index) {} : null,
                columns: <PlTableColumn<_Build>>[
                  // In the first cell, which is inside the row's own stop.
                  PlTableColumn<_Build>(
                    header: const Text('Note'),
                    cell: (_Build row, int index) =>
                        index == 0 ? const PlTextField(semanticLabel: 'Note') : Text(row.id),
                  ),
                  PlTableColumn<_Build>(
                    header: const Text('Branch'),
                    cell: (_Build row, int index) => Text(row.branch),
                  ),
                ],
              ),
              width: 420,
            );
          }

          await tester.pumpWidget(table(pressable: false));
          await tester.enterText(find.byType(EditableText), 'flaky');
          await tester.pump();

          for (final bool pressable in <bool>[true, false, true]) {
            await tester.pumpWidget(table(pressable: pressable));
            await tester.pumpAndSettle();

            final EditableText field = tester.widget<EditableText>(find.byType(EditableText));

            expect(field.controller.text, 'flaky', reason: 'pressable $pressable');
            expect(field.focusNode.hasPrimaryFocus, isTrue, reason: 'pressable $pressable');
          }
        },
      );

      for (final NavigationMode mode in NavigationMode.values) {
        testWidgets('is no focus stop while nothing listens to its rows, ${mode.name}', (
          WidgetTester tester,
        ) async {
          final before = FocusNode(debugLabel: 'before');
          addTearDown(before.dispose);

          // Directional navigation is where an unavailable control is still a
          // stop, so a reader on a remote can find it. A row that cannot be
          // pressed is not a control, lit by the pointer or not.
          for (final bool hoverable in <bool>[false, true]) {
            await tester.pumpWidget(
              host(
                MediaQuery(
                  data: MediaQueryData(navigationMode: mode),
                  child: afterFocusStop(
                    before,
                    PlTable<_Build>(rows: _rows, columns: _columns(), hoverable: hoverable),
                  ),
                ),
                width: 420,
              ),
            );

            await _tabFrom(tester, before);

            expect(_holdsRow(tester), isFalse, reason: 'hoverable $hoverable');
          }
        });

        testWidgets('gives the focus up as its rows stop being pressable, ${mode.name}', (
          WidgetTester tester,
        ) async {
          FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
          addTearDown(
            () => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic,
          );

          final before = FocusNode(debugLabel: 'before');
          addTearDown(before.dispose);

          Widget table({required bool pressable}) {
            return host(
              MediaQuery(
                data: MediaQueryData(navigationMode: mode),
                child: afterFocusStop(
                  before,
                  PlTable<_Build>(
                    rows: _rows,
                    columns: _columns(),
                    onRowPressed: pressable ? (_Build row, int index) {} : null,
                  ),
                ),
              ),
              width: 420,
            );
          }

          await tester.pumpWidget(table(pressable: true));
          await _tabFrom(tester, before);

          expect(_holdsRow(tester), isTrue);
          expect(_rowDecoration(tester, 1).border!.top.width, focusRingWidth);

          await tester.pumpWidget(table(pressable: false));
          await tester.pumpAndSettle();

          expect(_holdsRow(tester), isFalse);
          expect(_rowDecoration(tester, 1).border, isNull);

          await tester.pumpWidget(table(pressable: true));
          await tester.pumpAndSettle();

          // Nothing holds it, so there is no ring to draw.
          expect(_holdsRow(tester), isFalse);
          expect(_rowDecoration(tester, 1).border, isNull);
        });
      }

      testWidgets('the pointer lights the row it is over, not the cell', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_table(hoverable: true));

        final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(pointer.removePointer);
        await pointer.addPointer(location: Offset.zero);
        await pointer.moveTo(tester.getCenter(find.text('main')));
        await tester.pump();

        // Hovered on the branch cell, lit on the row the build number is in.
        expect(
          _rowDecoration(tester, 1).color,
          PlassTokens.light().family(PlassColor.primary).soft,
        );
        expect(_rowDecoration(tester, 2).color, isNull);
      });

      testWidgets('lights the row the pointer rests on as it starts lighting rows, and not after', (
        WidgetTester tester,
      ) async {
        final Color soft = PlassTokens.light().family(PlassColor.primary).soft;

        await tester.pumpWidget(_table());

        final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(pointer.removePointer);
        await pointer.addPointer(location: Offset.zero);
        await pointer.moveTo(tester.getCenter(find.text('main')));
        await tester.pump();

        expect(_rowDecoration(tester, 1).color, isNull);

        // The pointer has not moved: the row it is resting on lights up as the
        // table starts lighting rows, and goes out as it stops.
        for (final (bool hoverable, bool pressable, Color? lit) in <(bool, bool, Color?)>[
          (true, false, soft),
          (false, false, null),
          (false, true, soft),
          (false, false, null),
        ]) {
          await tester.pumpWidget(
            _table(
              hoverable: hoverable,
              onRowPressed: pressable ? (_Build row, int index) {} : null,
            ),
          );
          await tester.pump();

          expect(
            _rowDecoration(tester, 1).color,
            lit,
            reason: 'hoverable $hoverable, pressable $pressable',
          );
          expect(_rowDecoration(tester, 2).color, isNull);
        }
      });

      testWidgets('moving between rows neither builds the cells again nor lays the grid out', (
        WidgetTester tester,
      ) async {
        var built = 0;

        await tester.pumpWidget(
          host(
            PlTable<_Build>(
              rows: _rows,
              hoverable: true,
              columns: <PlTableColumn<_Build>>[
                PlTableColumn<_Build>(
                  header: const Text('Build'),
                  cell: (_Build row, int index) {
                    built += 1;

                    return Text(row.id);
                  },
                ),
              ],
            ),
            width: 420,
          ),
        );

        final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(pointer.removePointer);
        await pointer.addPointer(location: Offset.zero);
        await pointer.moveTo(tester.getCenter(find.text('#412')));
        await tester.pump();

        final int before = built;
        // A [Table] built again is a grid laid out again, every column measured
        // from every cell, so the same widget has to still be there.
        final Table grid = tester.widget<Table>(find.byType(Table));

        await pointer.moveTo(tester.getCenter(find.text('#411')));
        await tester.pump();

        expect(built, before);
        expect(identical(tester.widget<Table>(find.byType(Table)), grid), isTrue);

        // And the band is drawn, as one rectangle the size of the row the grid
        // laid out.
        final RenderTable laid = tester.renderObject<RenderTable>(find.byType(Table));

        expect(
          tester.renderObject(
            find.ancestor(of: find.byType(Table), matching: find.byType(CustomPaint)).first,
          ),
          paints..rect(
            rect: laid.getRowBox(2),
            color: PlassTokens.light().family(PlassColor.primary).soft,
          ),
        );
        expect(_rowDecoration(tester, 1).color, isNull);
        expect(
          _rowDecoration(tester, 2).color,
          PlassTokens.light().family(PlassColor.primary).soft,
        );
      });

      testWidgets('keyboard focus rings the whole row', (WidgetTester tester) async {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
        await tester.pumpWidget(_table(onRowPressed: (_Build row, int index) {}));

        Focus.of(tester.element(find.text('#412'))).requestFocus();
        await tester.pumpAndSettle();

        final ring = _rowDecoration(tester, 1).border!;

        expect(ring.top.color, PlassTokens.light().family(PlassColor.primary).ring);
        expect(ring.bottom.color, PlassTokens.light().family(PlassColor.primary).ring);
      });

      testWidgets('the focused row answers Enter', (WidgetTester tester) async {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
        final pressed = <String>[];
        await tester.pumpWidget(
          _table(onRowPressed: (_Build row, int index) => pressed.add(row.id)),
        );

        Focus.of(tester.element(find.text('#412'))).requestFocus();
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(pressed, <String>['#412']);
      });
    });

    group('accessibility', () {
      testWidgets('is announced as a table', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_table());

        expect(tester.getSemantics(find.byType(Table)).role, SemanticsRole.table);

        handle.dispose();
      });

      testWidgets('a heading is announced as one', (WidgetTester tester) async {
        await tester.pumpWidget(_table());

        final heading = tester.widget<Semantics>(
          find.ancestor(of: find.text('Build'), matching: find.byType(Semantics)).first,
        );

        expect(heading.properties.role, SemanticsRole.columnHeader);
      });
    });

    group('a capped height', () {
      testWidgets('is as tall as its rows until it is capped', (WidgetTester tester) async {
        await tester.pumpWidget(_table(rows: _many));

        final Size uncapped = tester.getSize(find.byType(PlTable<_Build>));

        await tester.pumpWidget(_table(rows: _many, maxHeight: 200));

        expect(uncapped.height, greaterThan(200));
        expect(tester.getSize(find.byType(PlTable<_Build>)).height, 200);
      });

      testWidgets('scrolls the rows inside the sheet', (WidgetTester tester) async {
        await tester.pumpWidget(_table(rows: _many, maxHeight: 200));

        final double before = tester.getTopLeft(find.text('#400')).dy;

        await tester.drag(find.text('#400'), const Offset(0, -120));
        await tester.pumpAndSettle();

        expect(tester.getTopLeft(find.text('#400')).dy, lessThan(before));
      });

      testWidgets('lays out where nothing bounds its height', (WidgetTester tester) async {
        // A table inside the page's own scroll view is handed an unbounded
        // height, and has to lay out in one as tall as its rows.
        await tester.pumpWidget(
          host(
            SingleChildScrollView(
              child: PlTable<_Build>(rows: _many, columns: _columns()),
            ),
            width: 420,
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('#400'), findsOneWidget);
      });

      testWidgets('keeps what its cells hold as the height around it is bounded and then not', (
        WidgetTester tester,
      ) async {
        Widget table({required bool bounded}) {
          return host(
            // One widget either way, so only the constraints change.
            OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: bounded ? 200 : double.infinity,
              child: PlTable<_Build>(
                rows: _many,
                columns: <PlTableColumn<_Build>>[
                  PlTableColumn<_Build>(
                    header: const Text('Build'),
                    cell: (_Build row, int index) => _Probe(row.id),
                  ),
                ],
              ),
            ),
            width: 420,
          );
        }

        await tester.pumpWidget(table(bounded: true));
        await tester.pumpAndSettle();

        final List<State<_Probe>> resting = tester
            .stateList<State<_Probe>>(find.byType(_Probe))
            .toList();

        expect(resting, hasLength(_many.length));

        for (final bool bounded in <bool>[false, true, false]) {
          await tester.pumpWidget(table(bounded: bounded));
          await tester.pumpAndSettle();

          expect(
            tester.getSize(find.byType(PlTable<_Build>)).height,
            bounded ? 200 : greaterThan(200),
            reason: 'bounded $bounded',
          );

          final List<State<_Probe>> now = tester
              .stateList<State<_Probe>>(find.byType(_Probe))
              .toList();

          expect(now, hasLength(resting.length), reason: 'bounded $bounded');

          for (var index = 0; index < resting.length; index += 1) {
            expect(now[index], same(resting[index]), reason: 'probe $index, bounded $bounded');
          }
        }
      });

      testWidgets('leaves the caption above what scrolls', (WidgetTester tester) async {
        await tester.pumpWidget(
          _table(rows: _many, maxHeight: 200, caption: const Text('Recent builds')),
        );

        final double caption = tester.getTopLeft(find.text('Recent builds')).dy;

        await tester.drag(find.text('#400'), const Offset(0, -120));
        await tester.pumpAndSettle();

        // A title that slid away would take the table's name with it.
        expect(tester.getTopLeft(find.text('Recent builds')).dy, caption);
      });
    });

    group('the keyboard', () {
      /// A table after a stop of its own, reached with Tab the way a keyboard
      /// reader reaches it.
      Future<void> tabInto(WidgetTester tester, Widget table) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        await tester.pumpWidget(host(afterFocusStop(before, table), width: 420));
        await tester.pumpAndSettle();

        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
      }

      ScrollController controllerOf(WidgetTester tester) {
        return tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView)).controller!;
      }

      testWidgets('scrolls a grid past its cap from a stop of its own', (
        WidgetTester tester,
      ) async {
        await tabInto(tester, PlTable<_Build>(rows: _many, columns: _columns(), maxHeight: 200));

        expect(tester.binding.focusManager.primaryFocus?.debugLabel, 'PlassKeyboardScroll');

        final ScrollController controller = controllerOf(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(controller.offset, 40);

        await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
        await tester.pumpAndSettle();
        expect(controller.offset, 40 + controller.position.viewportDimension);

        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pumpAndSettle();
        expect(controller.offset, controller.position.maxScrollExtent);

        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pumpAndSettle();
        expect(controller.offset, 0);
      });

      testWidgets('names the stop with `semanticLabel`', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tabInto(
          tester,
          PlTable<_Build>(
            rows: _many,
            columns: _columns(),
            maxHeight: 200,
            semanticLabel: 'Recent builds',
          ),
        );

        expect(
          tester.getSemantics(find.bySemanticsLabel('Recent builds')),
          isSemantics(label: 'Recent builds', isFocusable: true, isFocused: true),
        );
        // Still the one table, inside the stop that names it.
        expect(tester.getSemantics(find.byType(Table)).role, SemanticsRole.table);

        handle.dispose();
      });

      testWidgets('names the stop with the words of a caption, and reads them only there', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tabInto(
          tester,
          PlTable<_Build>(
            rows: _many,
            columns: _columns(),
            maxHeight: 200,
            caption: const Text('Recent builds'),
          ),
        );

        expect(
          tester.getSemantics(find.bySemanticsLabel('Recent builds')),
          isSemantics(label: 'Recent builds', isFocusable: true, isFocused: true),
        );
        expect(
          semanticsLabels(tester).where((String label) => label == 'Recent builds'),
          hasLength(1),
        );

        handle.dispose();
      });

      testWidgets('reads a caption as a line of its own when `semanticLabel` names the stop', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tabInto(
          tester,
          PlTable<_Build>(
            rows: _many,
            columns: _columns(),
            maxHeight: 200,
            caption: const Text('Recent builds'),
            semanticLabel: 'Builds on main',
          ),
        );

        expect(
          tester.getSemantics(find.bySemanticsLabel('Builds on main')),
          isSemantics(label: 'Builds on main', isFocusable: true, isFocused: true),
        );
        expect(semanticsLabels(tester).take(2), <String>['Recent builds', 'Builds on main']);

        handle.dispose();
      });

      testWidgets('is a stop in a box that bounds its height, with no cap of its own', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        await tester.pumpWidget(
          host(
            afterFocusStop(
              before,
              SizedBox(
                height: 200,
                child: PlTable<_Build>(rows: _many, columns: _columns()),
              ),
            ),
            width: 420,
          ),
        );
        await tester.pumpAndSettle();

        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        expect(controllerOf(tester).offset, 40);
      });

      testWidgets('is no stop while every row fits', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tabInto(
          tester,
          PlTable<_Build>(rows: _rows, columns: _columns(), semanticLabel: 'Recent builds'),
        );

        expect(tester.binding.focusManager.primaryFocus?.debugLabel, isNot('PlassKeyboardScroll'));
        expect(
          tester.getSemantics(find.bySemanticsLabel('Recent builds')),
          isSemantics(label: 'Recent builds', isFocusable: false),
        );

        handle.dispose();
      });

      testWidgets('rings the stop inside the sheet, in the table\'s own colour', (
        WidgetTester tester,
      ) async {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
        addTearDown(
          () => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic,
        );

        await tabInto(
          tester,
          PlTable<_Build>(
            rows: _many,
            columns: _columns(),
            maxHeight: 200,
            color: PlassColor.danger,
          ),
        );

        final PlassFocusRingPainter ring = tester
            .widgetList<CustomPaint>(find.byType(CustomPaint))
            .map((CustomPaint paint) => paint.foregroundPainter)
            .whereType<PlassFocusRingPainter>()
            .single;

        // The sheet clips at its rounded corner, so a ring outside the grid
        // would be cut off with it.
        expect(ring.offset, -focusRingWidth);
        expect(ring.color, PlassTokens.light().family(PlassColor.danger).ring);
      });
    });

    group('a pinned header', () {
      testWidgets('draws no band until it is asked for one', (WidgetTester tester) async {
        await tester.pumpWidget(_table(rows: _many, maxHeight: 200));
        await tester.pumpAndSettle();

        expect(find.text('Build'), findsOneWidget);
      });

      testWidgets('repeats the header over the top of the scroll', (WidgetTester tester) async {
        await tester.pumpWidget(_table(rows: _many, maxHeight: 200, stickyHeader: true));
        await tester.pumpAndSettle();

        // The real header inside the grid, and the band laid over it.
        expect(find.text('Build'), findsNWidgets(2));
      });

      testWidgets('gives the band the widths the grid laid out', (WidgetTester tester) async {
        await tester.pumpWidget(_table(rows: _many, maxHeight: 200, stickyHeader: true));
        await tester.pumpAndSettle();

        final List<Element> headers = find.text('Build').evaluate().toList();

        // One grid still decides every column; the band only repeats what it
        // decided, so the two cannot disagree about where a column starts.
        expect(
          tester.getTopLeft(find.byElementPredicate((Element e) => e == headers.first)).dx,
          tester.getTopLeft(find.byElementPredicate((Element e) => e == headers.last)).dx,
        );
      });

      testWidgets(
        'lines the band up with the grid again as a row, a heading, the text scale and the band itself change',
        (WidgetTester tester) async {
          Widget table({
            List<_Build> rows = _rows,
            String heading = 'Build',
            double scale = 1,
            bool pinned = true,
          }) {
            return host(
              Builder(
                builder: (BuildContext context) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
                  child: PlTable<_Build>(
                    rows: rows,
                    stickyHeader: pinned,
                    maxHeight: 200,
                    columns: <PlTableColumn<_Build>>[
                      PlTableColumn<_Build>(
                        header: Text(heading),
                        cell: (_Build row, int index) => Text(row.id),
                      ),
                      PlTableColumn<_Build>(
                        header: const Text('Branch'),
                        cell: (_Build row, int index) => Text(row.branch),
                      ),
                      PlTableColumn<_Build>(
                        header: const Text('State'),
                        cell: (_Build row, int index) => const Text('green'),
                      ),
                    ],
                  ),
                ),
              ),
              width: 640,
            );
          }

          // Where the band starts each heading after the first, against where
          // the grid does: the grid's heading is built first, the band's last.
          void expectLinedUp(String reason) {
            for (final String name in <String>['Branch', 'State']) {
              final List<Element> both = find.text(name).evaluate().toList();

              expect(both, hasLength(2), reason: '$name, $reason');
              expect(
                tester.getTopLeft(find.byElementPredicate((Element e) => e == both.last)).dx,
                tester.getTopLeft(find.byElementPredicate((Element e) => e == both.first)).dx,
                reason: '$name, $reason',
              );
            }
          }

          const List<_Build> longer = <_Build>[
            _Build('#412 nightly build', 'main'),
            _Build('#411', 'fix/glass-edge'),
            _Build('#410', 'topic/table'),
          ];

          await tester.pumpWidget(table());
          await tester.pumpAndSettle();
          expectLinedUp('at rest');

          final double resting = tester.getTopLeft(find.text('Branch').first).dx;

          await tester.pumpWidget(table(rows: longer));
          await tester.pumpAndSettle();

          // The first column really is wider, or the band has nothing to follow.
          expect(tester.getTopLeft(find.text('Branch').first).dx, greaterThan(resting));
          expectLinedUp('a longer cell');

          await tester.pumpWidget(table(rows: longer, heading: 'Build and its run'));
          await tester.pumpAndSettle();
          expectLinedUp('a longer heading');

          await tester.pumpWidget(table());
          await tester.pumpAndSettle();
          expectLinedUp('narrower again');

          await tester.pumpWidget(table(scale: 1.3));
          await tester.pumpAndSettle();
          expectLinedUp('a larger text scale');

          // Turned off, the rows change under a band that is not there to be
          // measured for, and turned on it has to catch up.
          await tester.pumpWidget(table(pinned: false));
          await tester.pumpAndSettle();
          await tester.pumpWidget(table(rows: longer, pinned: false));
          await tester.pumpAndSettle();
          await tester.pumpWidget(table(rows: longer));
          await tester.pumpAndSettle();
          expectLinedUp('turned off and on again');
        },
      );

      testWidgets('stays put while the rows go under it', (WidgetTester tester) async {
        await tester.pumpWidget(_table(rows: _many, maxHeight: 200, stickyHeader: true));
        await tester.pumpAndSettle();

        final double band = tester.getTopLeft(find.byType(IntrinsicHeight)).dy;
        final double row = tester.getTopLeft(find.text('#400')).dy;

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -120));
        await tester.pumpAndSettle();

        expect(tester.getTopLeft(find.byType(IntrinsicHeight)).dy, band);
        expect(tester.getTopLeft(find.text('#400')).dy, lessThan(row));
      });

      testWidgets('stays put in a box that bounds its height, with no cap of its own', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlTable<_Build>(rows: _many, columns: _columns(), stickyHeader: true),
            width: 420,
            height: 200,
          ),
        );
        await tester.pumpAndSettle();

        final double band = tester.getTopLeft(find.byType(IntrinsicHeight)).dy;
        final double row = tester.getTopLeft(find.text('#400')).dy;

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -120));
        await tester.pumpAndSettle();

        expect(tester.getTopLeft(find.byType(IntrinsicHeight)).dy, band);
        expect(tester.getTopLeft(find.text('#400')).dy, lessThan(row));
      });

      testWidgets('is opaque, because rows pass underneath it', (WidgetTester tester) async {
        await tester.pumpWidget(_table(rows: _many, maxHeight: 200, stickyHeader: true));
        await tester.pumpAndSettle();

        final BoxDecoration band = decorationWhere(
          tester,
          find
              .ancestor(of: find.byType(IntrinsicHeight), matching: find.byType(DecoratedBox))
              .first,
          (BoxDecoration decoration) => decoration.color != null,
        );

        expect(band.color!.a, 1.0);
      });

      testWidgets('names every column once, not twice', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_table(rows: _many, maxHeight: 200, stickyHeader: true));
        await tester.pumpAndSettle();

        // Two of them are drawn and one of them is read: the band is a copy, and
        // a copy that spoke would name every column twice.
        expect(find.bySemanticsLabel('Build'), findsOneWidget);

        handle.dispose();
      });
    });
  });
}
