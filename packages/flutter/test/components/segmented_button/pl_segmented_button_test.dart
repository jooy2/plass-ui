import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/glow.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';

import '../../support/host.dart';

const List<PlSegment<String>> views = <PlSegment<String>>[
  PlSegment<String>(value: 'list', label: Text('List')),
  PlSegment<String>(value: 'board', label: Text('Board')),
  PlSegment<String>(value: 'calendar', label: Text('Calendar')),
];

/// A `solid` set starting on [initial], which takes whatever is pressed.
Widget solidSet(String? initial) {
  String? value = initial;

  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) => PlSegmentedButton<String>(
      segments: views,
      value: value,
      variant: PlassVariant.solid,
      onChanged: (String next) => setState(() => value = next),
    ),
  );
}

/// The gradient a `solid` tile of the set's family is drawn in at rest.
Gradient familyFill(WidgetTester tester) {
  return PlassTheme.of(
    tester.element(find.byType(PlSegmentedButton<String>)),
  ).family(PlassColor.primary).fill;
}

/// Pumps a frame at a time until the tile is in the groove, which is the frame
/// after the one that chose a segment.
Future<void> pumpUntilTile(WidgetTester tester) async {
  for (var frame = 0; frame < 10; frame += 1) {
    if (find.byType(AnimatedPositioned).evaluate().isNotEmpty) {
      return;
    }

    await tester.pump(const Duration(milliseconds: 16));
  }

  fail('the tile never arrived');
}

/// The colour the words [text] are drawn in.
Color inkOf(WidgetTester tester, String text) {
  return tester.renderObject<RenderParagraph>(find.text(text)).text.style!.color!;
}

/// The gradient the tile riding in the groove is drawn in, or `null` while it
/// paints none.
Gradient? tileFill(WidgetTester tester) {
  final DecoratedBox tile = tester.widget<DecoratedBox>(
    find.descendant(of: find.byType(AnimatedPositioned), matching: find.byType(DecoratedBox)),
  );

  return (tile.decoration as BoxDecoration).gradient;
}

/// The opacity [finder] is painted at, every fade above it multiplied in.
double opacityOf(WidgetTester tester, Finder finder) {
  return tester
      .widgetList<PlassFiltered>(find.ancestor(of: finder, matching: find.byType(PlassFiltered)))
      .fold(1, (double opacity, PlassFiltered filtered) => opacity * filtered.opacity);
}

/// How many filters above [finder] drain its colour.
int drainsOf(WidgetTester tester, Finder finder) {
  return tester
      .widgetList<PlassFiltered>(find.ancestor(of: finder, matching: find.byType(PlassFiltered)))
      .where((PlassFiltered filtered) => filtered.colorFilter != null)
      .length;
}

/// The segment reading [label], found only while it holds the focus.
Finder focusedSegment(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byWidgetPredicate(
      (Widget widget) => widget is Focus && (widget.focusNode?.hasPrimaryFocus ?? false),
    ),
  );
}

void main() {
  group('PlSegmentedButton', () {
    group('rendering', () {
      testWidgets('draws every segment', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlSegmentedButton<String>(segments: views, value: 'list'), width: 480),
        );

        for (final label in <String>['List', 'Board', 'Calendar']) {
          expect(find.text(label), findsOneWidget);
        }
      });

      testWidgets('is one control-height row', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlSegmentedButton<String>(segments: views, value: 'list'), width: 480),
        );

        // A control height plus the groove's own inset, top and bottom.
        expect(tester.getSize(find.byType(PlSegmentedButton<String>)).height, 48);
      });

      testWidgets('a ghost set keeps no groove', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlSegmentedButton<String>(
              segments: views,
              value: 'list',
              variant: PlassVariant.ghost,
            ),
            width: 480,
          ),
        );

        expect(tester.getSize(find.byType(PlSegmentedButton<String>)).height, 40);
      });
    });

    group('the tile', () {
      testWidgets('is measured onto the chosen segment', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlSegmentedButton<String>(segments: views, value: 'board'), width: 480),
        );
        await tester.pumpAndSettle();

        final tile = tester.widgetList<AnimatedPositioned>(find.byType(AnimatedPositioned));

        expect(tile, hasLength(1));
        expect(tile.first.width, greaterThan(0));
      });

      testWidgets('is measured again when the set changes size without a rebuild', (
        WidgetTester tester,
      ) async {
        var width = 480.0;
        late StateSetter resize;

        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                resize = setState;

                // The set is const, so the resize reaches it through layout
                // alone and never through `didUpdateWidget`.
                return Align(
                  alignment: AlignmentDirectional.topStart,
                  child: SizedBox(
                    width: width,
                    child: const PlSegmentedButton<String>(
                      segments: views,
                      value: 'board',
                      fullWidth: true,
                    ),
                  ),
                );
              },
            ),
            width: 700,
          ),
        );
        await tester.pumpAndSettle();

        resize(() => width = 560);
        await tester.pumpAndSettle();

        final tile = tester.widget<AnimatedPositioned>(find.byType(AnimatedPositioned));
        final set = tester.getSize(find.byType(PlSegmentedButton<String>)).width;

        // Three equal segments inside the groove's inset on either side.
        expect(set, 560);
        expect(tile.width, closeTo((set - 8) / 3, 0.5));
      });

      testWidgets('draws no tile when nothing is chosen', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlSegmentedButton<String>(segments: views, value: null), width: 480),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AnimatedPositioned), findsNothing);
      });

      testWidgets('a solid one fades its fill in where the first choice of an empty set lands', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(solidSet(null), width: 480));
        await tester.pumpAndSettle();

        final Gradient fill = familyFill(tester);
        final double whole = fill.colors.first.a;

        await tester.tap(find.text('Board'));

        // How opaque the fill is on every frame the tile is drawn, until it has
        // long settled.
        final List<double> seen = <double>[];

        for (var frame = 0; frame < 20; frame += 1) {
          await tester.pump(const Duration(milliseconds: 16));

          if (find.byType(AnimatedPositioned).evaluate().isNotEmpty) {
            seen.add(tileFill(tester)?.colors.first.a ?? 0);
          }
        }

        expect(seen, isNotEmpty);
        expect(seen.first, lessThan(whole), reason: 'the tile arrived with its fill whole');
        expect(
          seen.any((double alpha) => alpha > 0 && alpha < whole),
          isTrue,
          reason: 'the fill was never part of the way in: $seen',
        );

        await tester.pumpAndSettle();

        // At rest it is the family's own gradient, exactly.
        expect(tileFill(tester), fill);
      });

      testWidgets('a solid one the set is built with has its fill from its first frame', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(solidSet('board'), width: 480));

        await pumpUntilTile(tester);

        expect(tileFill(tester), familyFill(tester));
      });

      testWidgets('the label the set is built with takes the ink on the fill only with the tile', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(solidSet('board'), width: 480));

        final Color onFill = PlassTheme.of(
          tester.element(find.byType(PlSegmentedButton<String>)),
        ).family(PlassColor.primary).onSolid;

        // The tile is placed by a measurement, so the first frame is drawn
        // without it: the chosen words stand on the pale groove there, and the
        // white written on the fill would be lost on it.
        expect(find.byType(AnimatedPositioned), findsNothing);
        expect(inkOf(tester, 'Board'), isNot(onFill));

        await pumpUntilTile(tester);

        // The tile arrives with its fill whole, and the words take the ink on
        // it in the same frame rather than easing to it over the gradient.
        expect(tileFill(tester), familyFill(tester));
        expect(inkOf(tester, 'Board'), onFill);
      });

      testWidgets('a solid one has its fill at once under reduced motion', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(solidSet(null), width: 480, disableAnimations: true));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Board'));

        await pumpUntilTile(tester);

        expect(tileFill(tester), familyFill(tester));
      });
    });

    group('choosing', () {
      testWidgets('reports the segment that was pressed', (WidgetTester tester) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            PlSegmentedButton<String>(
              segments: views,
              value: 'list',
              onChanged: (String next) => chosen = next,
            ),
            width: 480,
          ),
        );

        await tester.tap(find.text('Calendar'));
        expect(chosen, 'calendar');
      });

      testWidgets('does not fire for a disabled segment', (WidgetTester tester) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            PlSegmentedButton<String>(
              value: 'a',
              onChanged: (String next) => chosen = next,
              segments: const <PlSegment<String>>[
                PlSegment<String>(value: 'a', label: Text('A')),
                PlSegment<String>(value: 'b', label: Text('B'), disabled: true),
              ],
            ),
            width: 480,
          ),
        );

        await tester.tap(find.text('B'));
        expect(chosen, isNull);
      });

      testWidgets('does not fire while read-only', (WidgetTester tester) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            PlSegmentedButton<String>(
              segments: views,
              value: 'list',
              readOnly: true,
              onChanged: (String next) => chosen = next,
            ),
            width: 480,
          ),
        );

        await tester.tap(find.text('Board'));
        expect(chosen, isNull);
      });
    });

    group('disabled', () {
      testWidgets('draws the segments of a disabled set at the one fade the set is drawn at', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlSegmentedButton<String>(
              segments: views,
              value: 'list',
              onChanged: (String _) {},
              disabled: true,
            ),
            width: 480,
          ),
        );
        await tester.pumpAndSettle();

        // The set's own fade, and not a second one of each segment's, which
        // would draw it at a quarter.
        for (final String label in <String>['List', 'Board', 'Calendar']) {
          expect(opacityOf(tester, find.text(label)), disabledOpacity);
          expect(drainsOf(tester, find.text(label)), 1);
        }

        expect(find.byType(PlassGlowLayer), findsNothing);
      });

      testWidgets('draws the segments of a set in a disabled fieldset at that one fade too', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlFieldset(
              disabled: true,
              children: <Widget>[
                PlSegmentedButton<String>(
                  segments: const <PlSegment<String>>[
                    PlSegment<String>(value: 'list', label: Text('List')),
                    PlSegment<String>(value: 'board', label: Text('Board'), disabled: true),
                  ],
                  value: 'list',
                  onChanged: (String _) {},
                ),
              ],
            ),
            width: 480,
          ),
        );
        await tester.pumpAndSettle();

        for (final String label in <String>['List', 'Board']) {
          expect(opacityOf(tester, find.text(label)), disabledOpacity);
          expect(drainsOf(tester, find.text(label)), 1);
        }
      });

      testWidgets('fades a segment disabled on its own in a live set, once', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            PlSegmentedButton<String>(
              segments: const <PlSegment<String>>[
                PlSegment<String>(value: 'list', label: Text('List')),
                PlSegment<String>(value: 'board', label: Text('Board'), disabled: true),
              ],
              value: 'list',
              onChanged: (String _) {},
            ),
            width: 480,
          ),
        );
        await tester.pumpAndSettle();

        expect(opacityOf(tester, find.text('List')), 1);
        expect(drainsOf(tester, find.text('List')), 0);
        expect(opacityOf(tester, find.text('Board')), disabledOpacity);
        expect(drainsOf(tester, find.text('Board')), 1);
      });
    });

    group('the arrow keys', () {
      testWidgets('move the choice within the set, wrapping', (WidgetTester tester) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            PlSegmentedButton<String>(
              segments: views,
              value: 'list',
              autofocus: true,
              onChanged: (String next) => chosen = next,
            ),
            width: 480,
          ),
        );
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        expect(chosen, 'calendar');
      });

      testWidgets('keep focus on the segment the value follows them to', (
        WidgetTester tester,
      ) async {
        String value = 'list';
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => afterFocusStop(
                before,
                PlSegmentedButton<String>(
                  segments: views,
                  value: value,
                  onChanged: (String next) => setState(() => value = next),
                ),
              ),
            ),
            width: 480,
          ),
        );
        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();

        expect(value, 'calendar');
        expect(before.hasFocus, isFalse);
      });

      testWidgets('move the focus and not the choice while read-only, wrapping', (
        WidgetTester tester,
      ) async {
        String? chosen;
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);
        await tester.pumpWidget(
          host(
            afterFocusStop(
              before,
              PlSegmentedButton<String>(
                segments: const <PlSegment<String>>[
                  PlSegment<String>(value: 'list', label: Text('List')),
                  PlSegment<String>(value: 'board', label: Text('Board')),
                  PlSegment<String>(value: 'calendar', label: Text('Calendar'), disabled: true),
                ],
                value: 'list',
                readOnly: true,
                onChanged: (String next) => chosen = next,
              ),
            ),
            width: 480,
          ),
        );
        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(focusedSegment('List'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();

        expect(focusedSegment('Board'), findsOneWidget);

        // Past the disabled one and round to the start.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();

        expect(focusedSegment('List'), findsOneWidget);
        expect(chosen, isNull);
        expect(before.hasFocus, isFalse);
      });

      testWidgets('give the focus back to the chosen segment as a read-only set turns live', (
        WidgetTester tester,
      ) async {
        bool readOnly = true;
        late StateSetter rebuild;
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                rebuild = setState;

                return PlSegmentedButton<String>(
                  segments: views,
                  value: 'list',
                  readOnly: readOnly,
                  autofocus: true,
                  onChanged: (String _) {},
                );
              },
            ),
            width: 480,
          ),
        );
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();

        expect(focusedSegment('Board'), findsOneWidget);

        rebuild(() => readOnly = false);
        await tester.pumpAndSettle();

        expect(focusedSegment('List'), findsOneWidget);
      });

      for (final NavigationMode mode in NavigationMode.values) {
        testWidgets(
          'go round past the first segment only in traditional navigation, ${mode.name}',
          (WidgetTester tester) async {
            for (final bool readOnly in <bool>[false, true]) {
              String value = 'list';
              final FocusNode before = FocusNode(debugLabel: 'before');
              addTearDown(before.dispose);

              // Under directional navigation the arrows are the only way out of
              // the set, so the one past the end goes on to the stop above
              // rather than round to the last segment.
              await tester.pumpWidget(
                host(
                  inNavigationMode(
                    mode,
                    StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) => afterFocusStop(
                        before,
                        PlSegmentedButton<String>(
                          key: ValueKey<bool>(readOnly),
                          segments: views,
                          value: value,
                          readOnly: readOnly,
                          onChanged: (String next) => setState(() => value = next),
                        ),
                      ),
                    ),
                  ),
                  width: 480,
                ),
              );
              before.requestFocus();
              await tester.pump();
              await tester.sendKeyEvent(LogicalKeyboardKey.tab);
              await tester.pumpAndSettle();

              expect(focusedSegment('List'), findsOneWidget);

              await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
              await tester.pumpAndSettle();

              final String reason = 'read-only $readOnly';

              if (mode == NavigationMode.traditional) {
                expect(focusedSegment('Calendar'), findsOneWidget, reason: reason);
                expect(value, readOnly ? 'list' : 'calendar', reason: reason);
              } else {
                expect(before.hasPrimaryFocus, isTrue, reason: reason);
                expect(value, 'list', reason: reason);
              }
            }
          },
        );
      }

      testWidgets('hand the key on in a disabled set under directional navigation', (
        WidgetTester tester,
      ) async {
        String? chosen;

        // Directional navigation is where a disabled segment can still hold the
        // focus, so the arrows reach the set at all.
        await tester.pumpWidget(
          host(
            inNavigationMode(
              NavigationMode.directional,
              PlSegmentedButton<String>(
                segments: views,
                value: 'board',
                disabled: true,
                autofocus: true,
                onChanged: (String next) => chosen = next,
              ),
            ),
            width: 480,
          ),
        );
        await tester.pump();

        expect(focusedSegment('Board'), findsOneWidget);

        final bool handled = await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();

        expect(handled, isFalse);
        expect(focusedSegment('Board'), findsOneWidget);
        expect(chosen, isNull);
      });
    });

    group('accessibility', () {
      testWidgets('a segment says it is one of a set', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlSegmentedButton<String>(segments: views, value: 'board', onChanged: (String _) {}),
            width: 480,
          ),
        );

        expect(
          tester.getSemantics(find.text('Board')),
          isSemantics(isInMutuallyExclusiveGroup: true, isChecked: true),
        );

        handle.dispose();
      });

      testWidgets('the set and its segments are read-only rather than disabled while read-only', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlSegmentedButton<String>(
              segments: const <PlSegment<String>>[
                PlSegment<String>(value: 'list', label: Text('List')),
                PlSegment<String>(value: 'board', label: Text('Board')),
                PlSegment<String>(value: 'calendar', label: Text('Calendar'), disabled: true),
              ],
              value: 'list',
              readOnly: true,
              semanticLabel: 'View',
              onChanged: (String _) {},
            ),
            width: 480,
          ),
        );

        // The set keeps its focus stop, so a screen reader has to hear segments
        // that cannot be changed rather than segments that are unavailable.
        expect(
          semanticsNodeLabelled(tester, 'View'),
          isSemantics(hasEnabledState: true, isEnabled: true, isReadOnly: true),
        );

        expect(
          tester.getSemantics(find.text('List')),
          isSemantics(
            isInMutuallyExclusiveGroup: true,
            hasCheckedState: true,
            isChecked: true,
            hasEnabledState: true,
            isEnabled: true,
            isReadOnly: true,
            hasTapAction: false,
          ),
        );
        expect(
          tester.getSemantics(find.text('Board')),
          isSemantics(
            isInMutuallyExclusiveGroup: true,
            hasCheckedState: true,
            isChecked: false,
            hasEnabledState: true,
            isEnabled: true,
            isReadOnly: true,
            hasTapAction: false,
          ),
        );
        expect(
          tester.getSemantics(find.text('Calendar')),
          isSemantics(hasEnabledState: true, isEnabled: false, hasTapAction: false),
        );

        handle.dispose();
      });

      testWidgets('a segment disabled on its own in a live set is the only one unavailable', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlSegmentedButton<String>(
              segments: const <PlSegment<String>>[
                PlSegment<String>(value: 'list', label: Text('List')),
                PlSegment<String>(value: 'board', label: Text('Board'), disabled: true),
              ],
              value: 'list',
              semanticLabel: 'View',
              onChanged: (String _) {},
            ),
            width: 480,
          ),
        );

        expect(
          semanticsNodeLabelled(tester, 'View'),
          isSemantics(hasEnabledState: true, isEnabled: true, isReadOnly: false),
        );
        expect(
          tester.getSemantics(find.text('List')),
          isSemantics(hasEnabledState: true, isEnabled: true, hasTapAction: true),
        );
        expect(
          tester.getSemantics(find.text('Board')),
          isSemantics(hasEnabledState: true, isEnabled: false, hasTapAction: false),
        );

        handle.dispose();
      });

      testWidgets('a disabled set, or one without `onChanged`, is unavailable throughout', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();

        for (final bool disabled in <bool>[true, false]) {
          await tester.pumpWidget(
            host(
              PlSegmentedButton<String>(
                segments: views,
                value: 'list',
                semanticLabel: 'View',
                disabled: disabled,
                onChanged: disabled ? (String _) {} : null,
              ),
              width: 480,
            ),
          );

          expect(
            semanticsNodeLabelled(tester, 'View'),
            isSemantics(hasEnabledState: true, isEnabled: false),
          );

          for (final String label in <String>['List', 'Board', 'Calendar']) {
            expect(
              tester.getSemantics(find.text(label)),
              isSemantics(hasEnabledState: true, isEnabled: false, hasTapAction: false),
            );
          }
        }

        handle.dispose();
      });

      testWidgets('the set takes one focus stop', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlSegmentedButton<String>(segments: views, value: 'board', onChanged: (String _) {}),
            width: 480,
          ),
        );

        final inOrder = tester
            .widgetList<ExcludeFocus>(find.byType(ExcludeFocus))
            .where((ExcludeFocus excluded) => !excluded.excluding)
            .length;

        expect(inOrder, 1);
      });
    });
  });
}
