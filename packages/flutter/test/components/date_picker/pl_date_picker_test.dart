import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
// The cell is internal — the grid is what a test counts, and there is no public
// name for one square of it.
import 'package:plass_ui/src/internal/calendar.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/notch.dart';

import '../../support/host.dart';

/// A fixed day to work against, so nothing here depends on when it is run.
final DateTime july27 = DateTime(2026, 7, 27);

/// Puts a picker on screen with an overlay for its calendar to go into.
///
/// The surface is grown first: an open calendar is seven rows of cells plus a
/// header and a footer, which is taller than half of the 600px default — so on
/// that surface the popup has nowhere to go on either side of a centred trigger
/// and lands off the bottom of the world.
///
/// No width, either. A picker that is not `fullWidth` is as wide as the longest
/// date it could hold, and boxing it wider would leave `tester.tap` aiming at
/// the empty half of a box the trigger does not fill.
Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(900, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, overlay: true));
  await tester.pumpAndSettle();
}

/// The trigger, found by the one thing only it draws.
///
/// Walked *up* from rather than found directly: the picker's own `Semantics`
/// sits above the field surface and below the column that holds the label, so
/// the first `Semantics` inside the component is not it.
Finder _triggerGlyph() => find.byWidgetPredicate(
  (Widget widget) => widget is PlassGlyph && widget.shape == PlassGlyphShape.calendar,
);

/// Opens the calendar by pressing the trigger.
Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byType(PlDatePicker));
  await tester.pumpAndSettle();
}

void main() {
  group('PlDatePicker', () {
    group('rendering', () {
      testWidgets('writes the chosen day out of its names', (WidgetTester tester) async {
        await _pump(tester, PlDatePicker(value: july27, onChanged: (DateTime? _) {}));

        expect(find.text('Jul 27, 2026'), findsOneWidget);
      });

      testWidgets('writes it the caller’s own way when told how', (WidgetTester tester) async {
        await _pump(
          tester,
          PlDatePicker(
            value: july27,
            onChanged: (DateTime? _) {},
            formatValue: (DateTime date) =>
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day}',
          ),
        );

        expect(find.text('2026-07-27'), findsOneWidget);
      });

      testWidgets('writes it in the caller’s own words', (WidgetTester tester) async {
        await _pump(
          tester,
          PlDatePicker(
            value: july27,
            onChanged: (DateTime? _) {},
            names: const PlDateNames(
              monthsShort: <String>[
                '1월',
                '2월',
                '3월',
                '4월',
                '5월',
                '6월',
                '7월',
                '8월',
                '9월',
                '10월',
                '11월',
                '12월',
              ],
              monthBeforeYear: false,
            ),
          ),
        );

        expect(find.text('2026 7월 27'), findsWidgets);
      });

      testWidgets('shows the placeholder while nothing is chosen', (WidgetTester tester) async {
        await _pump(
          tester,
          PlDatePicker(
            value: null,
            onChanged: (DateTime? _) {},
            placeholder: const Text('Pick a day'),
          ),
        );

        // Once for real, and once more holding the trigger's width open — a
        // placeholder is easily longer than any date, and a trigger that shrank
        // the moment the first day was chosen is the same jump the samples
        // exist to prevent, from the other direction.
        expect(find.text('Pick a day'), findsNWidgets(2));
      });

      testWidgets('renders the label, the description and the error', (WidgetTester tester) async {
        await _pump(
          tester,
          PlDatePicker(
            value: null,
            onChanged: (DateTime? _) {},
            label: const Text('Departure'),
            description: const Text('When you leave.'),
            error: const Text('Pick a day.'),
          ),
        );

        expect(find.text('Departure'), findsOneWidget);
        expect(find.text('When you leave.'), findsOneWidget);
        expect(find.text('Pick a day.'), findsOneWidget);
      });

      testWidgets('follows a value handed in from outside', (WidgetTester tester) async {
        await _pump(tester, PlDatePicker(value: july27, onChanged: (DateTime? _) {}));
        await _pump(tester, PlDatePicker(value: DateTime(2026, 8, 3), onChanged: (DateTime? _) {}));

        expect(find.text('Aug 3, 2026'), findsWidgets);
      });
    });

    group('the calendar', () {
      testWidgets('opens on the chosen month', (WidgetTester tester) async {
        await _pump(tester, PlDatePicker(value: july27, onChanged: (DateTime? _) {}));
        await _open(tester);

        expect(find.text('July'), findsOneWidget);
        expect(find.text('2026'), findsOneWidget);
      });

      testWidgets('closes on Escape', (WidgetTester tester) async {
        await _pump(tester, PlDatePicker(value: july27, onChanged: (DateTime? _) {}));
        await _open(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(find.text('July'), findsNothing);
      });

      testWidgets('closes on a press on the trigger, and stays closed', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlDatePicker(value: july27, onChanged: (DateTime? _) {}));
        await _open(tester);
        expect(find.text('July'), findsOneWidget);

        await tester.tap(_triggerGlyph());
        await tester.pumpAndSettle();

        expect(find.text('July'), findsNothing);
      });

      testWidgets('always draws six weeks, so stepping never resizes it', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlDatePicker(value: DateTime(2026, 2, 1), onChanged: (DateTime? _) {}));
        await _open(tester);

        // February 2026 needs five rows; the grid draws six whatever the month.
        expect(find.byType(PlassCalendarCell), findsNWidgets(42));
      });

      testWidgets('chooses a day', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlDatePicker(value: july27, onChanged: (DateTime? next) => chosen = next),
        );
        await _open(tester);
        await tester.tap(find.bySemanticsLabel('Wednesday, July 15, 2026'));
        await tester.pumpAndSettle();

        expect(chosen, equals(DateTime(2026, 7, 15)));
      });

      testWidgets('keeps the time of day a value already carried', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlDatePicker(
            value: DateTime(2026, 7, 27, 9, 30),
            onChanged: (DateTime? next) => chosen = next,
          ),
        );
        await _open(tester);
        await tester.tap(find.bySemanticsLabel('Wednesday, July 15, 2026'));
        await tester.pumpAndSettle();

        expect(chosen, equals(DateTime(2026, 7, 15, 9, 30)));
      });

      testWidgets('steps a month at a time', (WidgetTester tester) async {
        await _pump(tester, PlDatePicker(value: july27, onChanged: (DateTime? _) {}));
        await _open(tester);
        await tester.tap(find.bySemanticsLabel('Next month'));
        await tester.pumpAndSettle();

        expect(find.text('August'), findsOneWidget);
      });

      testWidgets('opens the year grid from the header, then the month grid', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlDatePicker(value: july27, onChanged: (DateTime? _) {}));
        await _open(tester);

        // The year button, by the year it says: its own semantic label is
        // merged with that text, so the label alone is not an exact match.
        await tester.tap(find.text('2026'));
        await tester.pumpAndSettle();

        // Twelve years at a time, so any year at all is three presses away.
        expect(find.text('2020'), findsOneWidget);

        await tester.tap(find.text('2020'));
        await tester.pumpAndSettle();

        // Choosing a year drops into the month grid rather than back to the days.
        expect(find.bySemanticsLabel('March 2020'), findsOneWidget);
      });

      testWidgets('and comes back down to the days', (WidgetTester tester) async {
        await _pump(tester, PlDatePicker(value: july27, onChanged: (DateTime? _) {}));
        await _open(tester);

        await tester.tap(find.text('2026'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2020'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('March 2020'));
        await tester.pumpAndSettle();

        // Six weeks of March 2020, and nothing overflowing on the way: cells
        // re-used across a view change would animate three columns into seven.
        expect(find.byType(PlassCalendarCell), findsNWidgets(42));
      });

      testWidgets('writes the header in the order the names ask for', (WidgetTester tester) async {
        await _pump(
          tester,
          PlDatePicker(
            value: july27,
            onChanged: (DateTime? _) {},
            names: const PlDateNames(monthBeforeYear: false),
          ),
        );
        await _open(tester);

        expect(
          tester.getTopLeft(find.text('2026')).dx,
          lessThan(tester.getTopLeft(find.text('July')).dx),
        );
      });

      testWidgets('starts the week where it is told to', (WidgetTester tester) async {
        await _pump(
          tester,
          PlDatePicker(
            value: july27,
            onChanged: (DateTime? _) {},
            weekStartsOn: PlassWeekday.monday,
          ),
        );
        await _open(tester);

        expect(
          tester.getTopLeft(find.text('Mon')).dx,
          lessThan(tester.getTopLeft(find.text('Sun')).dx),
        );
      });
    });

    group('bounds', () {
      testWidgets('blocks a day before minDate', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlDatePicker(
            value: july27,
            onChanged: (DateTime? next) => chosen = next,
            minDate: DateTime(2026, 7, 20),
          ),
        );
        await _open(tester);
        await tester.tap(find.bySemanticsLabel('Wednesday, July 15, 2026'));
        await tester.pumpAndSettle();

        expect(chosen, isNull);
      });

      testWidgets('blocks a day after maxDate', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlDatePicker(
            value: DateTime(2026, 7, 1),
            onChanged: (DateTime? next) => chosen = next,
            maxDate: DateTime(2026, 7, 10),
          ),
        );
        await _open(tester);
        await tester.tap(find.bySemanticsLabel('Wednesday, July 15, 2026'));
        await tester.pumpAndSettle();

        expect(chosen, isNull);
      });

      testWidgets('blocks the days a rule says are unavailable', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlDatePicker(
            value: july27,
            onChanged: (DateTime? next) => chosen = next,
            shouldDisableDate: (DateTime date) =>
                date.weekday == DateTime.saturday || date.weekday == DateTime.sunday,
          ),
        );
        await _open(tester);

        await tester.tap(find.bySemanticsLabel('Saturday, July 18, 2026'));
        await tester.pumpAndSettle();
        expect(chosen, isNull);

        await tester.tap(find.bySemanticsLabel('Wednesday, July 15, 2026'));
        await tester.pumpAndSettle();
        expect(chosen, equals(DateTime(2026, 7, 15)));
      });

      testWidgets('leaves a blocked day in the grid', (WidgetTester tester) async {
        await _pump(
          tester,
          PlDatePicker(value: july27, onChanged: (DateTime? _) {}, minDate: DateTime(2026, 7, 20)),
        );
        await _open(tester);

        // Still there, and still in the arrow-key path: a reader arrowing across
        // a month must not fall into a hole at every blocked day.
        expect(find.bySemanticsLabel('Wednesday, July 15, 2026'), findsOneWidget);
      });
    });

    group('precision', () {
      testWidgets('opens a month picker on the month grid, with no day grid under it', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlDatePicker(
            value: july27,
            onChanged: (DateTime? _) {},
            precision: PlDatePickerPrecision.month,
          ),
        );
        await _open(tester);

        // Twelve months rather than forty-two days, and the day grid is not
        // merely hidden — there is no way down to it.
        expect(find.byType(PlassCalendarCell), findsNWidgets(12));
        expect(find.bySemanticsLabel('Monday, July 27, 2026'), findsNothing);
        expect(
          find.byWidgetPredicate(
            (Widget widget) => widget is Semantics && widget.properties.hint == 'Choose a month',
          ),
          findsNothing,
        );
      });

      testWidgets('commits the 1st of the month it was handed', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlDatePicker(
            value: july27,
            onChanged: (DateTime? next) => chosen = next,
            precision: PlDatePickerPrecision.month,
          ),
        );
        await _open(tester);
        await tester.tap(find.bySemanticsLabel('October 2026'));
        await tester.pumpAndSettle();

        expect(chosen, equals(DateTime(2026, 10)));
      });

      testWidgets('still reaches every year, and comes back to the months', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlDatePicker(
            value: july27,
            onChanged: (DateTime? _) {},
            precision: PlDatePickerPrecision.month,
          ),
        );
        await _open(tester);

        await tester.tap(find.text('2026'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2020'));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('March 2020'), findsOneWidget);
      });

      testWidgets('opens a year picker on the year grid and commits 1 January', (
        WidgetTester tester,
      ) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlDatePicker(
            value: july27,
            onChanged: (DateTime? next) => chosen = next,
            precision: PlDatePickerPrecision.year,
          ),
        );
        await _open(tester);

        expect(find.bySemanticsLabel('July 2026'), findsNothing);

        await tester.tap(find.text('2020'));
        await tester.pumpAndSettle();

        expect(chosen, equals(DateTime(2020)));
      });

      testWidgets('writes the trigger at the precision it asked for', (WidgetTester tester) async {
        await _pump(
          tester,
          PlDatePicker(
            value: july27,
            onChanged: (DateTime? _) {},
            precision: PlDatePickerPrecision.month,
          ),
        );

        expect(find.text('July 2026'), findsOneWidget);

        await _pump(
          tester,
          PlDatePicker(
            value: july27,
            onChanged: (DateTime? _) {},
            precision: PlDatePickerPrecision.year,
          ),
        );

        expect(find.text('2026'), findsOneWidget);
      });

      testWidgets('reads the bounds at the same precision', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlDatePicker(
            value: july27,
            onChanged: (DateTime? next) => chosen = next,
            precision: PlDatePickerPrecision.month,
            // Mid-July, so July itself is still reachable and June is not.
            minDate: DateTime(2026, 7, 15),
          ),
        );
        await _open(tester);

        await tester.tap(find.bySemanticsLabel('June 2026'));
        await tester.pumpAndSettle();
        expect(chosen, isNull);

        await tester.tap(find.bySemanticsLabel('July 2026'));
        await tester.pumpAndSettle();
        expect(chosen, equals(DateTime(2026, 7)));
      });

      testWidgets('renames the footer shortcut after the unit it jumps to', (
        WidgetTester tester,
      ) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlDatePicker(
            value: july27,
            onChanged: (DateTime? next) => chosen = next,
            precision: PlDatePickerPrecision.month,
          ),
        );
        await _open(tester);

        expect(find.text('Today'), findsNothing);

        await tester.tap(find.text('This month'));
        await tester.pumpAndSettle();

        final DateTime now = DateTime.now();

        expect(chosen, equals(DateTime(now.year, now.month)));
      });
    });

    group('the footer', () {
      testWidgets('jumps to today', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlDatePicker(value: july27, onChanged: (DateTime? next) => chosen = next),
        );
        await _open(tester);
        await tester.tap(find.text('Today'));
        await tester.pumpAndSettle();

        final DateTime now = DateTime.now();

        expect(chosen, equals(DateTime(now.year, now.month, now.day)));
      });

      testWidgets('offers a × only when asked', (WidgetTester tester) async {
        await _pump(tester, PlDatePicker(value: july27, onChanged: (DateTime? _) {}));

        expect(find.bySemanticsLabel('Clear'), findsNothing);

        await _pump(
          tester,
          PlDatePicker(value: july27, onChanged: (DateTime? _) {}, clearable: true),
        );

        expect(find.bySemanticsLabel('Clear'), findsOneWidget);
      });

      testWidgets('empties the picker', (WidgetTester tester) async {
        DateTime? chosen = july27;
        var called = false;

        await _pump(
          tester,
          PlDatePicker(
            value: chosen,
            clearable: true,
            onChanged: (DateTime? next) {
              called = true;
              chosen = next;
            },
          ),
        );

        await tester.tap(find.bySemanticsLabel('Clear'));
        await tester.pumpAndSettle();

        expect(called, isTrue);
        expect(chosen, isNull);
      });

      testWidgets('empties the picker while it is open, and closes it', (
        WidgetTester tester,
      ) async {
        DateTime? chosen = july27;

        await _pump(
          tester,
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => PlDatePicker(
              value: chosen,
              clearable: true,
              onChanged: (DateTime? next) => setState(() => chosen = next),
            ),
          ),
        );

        // Found before the calendar opens, whose footer has a Clear of its own.
        final Offset mark = tester.getCenter(find.bySemanticsLabel('Clear'));

        await tester.tap(_triggerGlyph());
        await tester.pumpAndSettle();
        expect(find.text('Today'), findsOneWidget);

        await tester.tapAt(mark);
        await tester.pumpAndSettle();

        expect(chosen, isNull);
        expect(find.text('Today'), findsNothing);
      });

      testWidgets('empties the picker from the keyboard', (WidgetTester tester) async {
        final FocusNode before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);
        DateTime? chosen = july27;

        await _pump(
          tester,
          afterFocusStop(
            before,
            PlDatePicker(
              value: chosen,
              clearable: true,
              onChanged: (DateTime? next) => chosen = next,
            ),
          ),
        );

        before.requestFocus();
        await tester.pump();

        // Past the trigger and on to the ×, which is a focus stop of its own.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // Ringed on its own, with the trigger round it no longer ringed too.
        final Iterable<CustomPaint> rings = tester
            .widgetList<CustomPaint>(find.byType(CustomPaint))
            .where((CustomPaint paint) => paint.foregroundPainter is PlassFocusRingPainter);

        expect(rings, hasLength(1));

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(chosen, isNull);
        // Cleared rather than opened.
        expect(find.text('Today'), findsNothing);
      });

      testWidgets('hands the focus back to the trigger once the × has gone', (
        WidgetTester tester,
      ) async {
        final FocusNode trigger = FocusNode(debugLabel: 'trigger');
        final FocusNode after = FocusNode(debugLabel: 'after');
        addTearDown(trigger.dispose);
        addTearDown(after.dispose);
        DateTime? chosen = july27;

        await _pump(
          tester,
          Shortcuts(
            shortcuts: WidgetsApp.defaultShortcuts,
            child: Actions(
              actions: WidgetsApp.defaultActions,
              child: FocusScope(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) => PlDatePicker(
                        value: chosen,
                        clearable: true,
                        focusNode: trigger,
                        onChanged: (DateTime? next) => setState(() => chosen = next),
                      ),
                    ),
                    Focus(focusNode: after, child: const SizedBox.square(dimension: 1)),
                  ],
                ),
              ),
            ),
          ),
        );

        // Back from the stop after the picker, which lands on the × without
        // passing the trigger, as a reader moving backwards through a form does.
        after.requestFocus();
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pumpAndSettle();

        expect(trigger.hasFocus, isTrue);
        expect(trigger.hasPrimaryFocus, isFalse);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        // The × left with the value, and the reader is still on the field.
        expect(chosen, isNull);
        expect(find.bySemanticsLabel('Clear'), findsNothing);
        expect(trigger.hasPrimaryFocus, isTrue);
      });

      testWidgets(
        'takes a press from 24px square round the ×, and leaves the rest to the trigger',
        (WidgetTester tester) async {
          var cleared = 0;

          await _pump(
            tester,
            PlDatePicker(
              // The smallest trigger, where the × is drawn furthest below 24px.
              size: PlassSize.xs,
              value: july27,
              clearable: true,
              onChanged: (DateTime? _) => cleared += 1,
            ),
          );

          final Rect mark = tester.getRect(find.bySemanticsLabel('Clear'));
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
          expect(find.text('Today'), findsNothing);

          await tester.tapAt(mark.center - const Offset(14, 0));
          await tester.pumpAndSettle();

          expect(cleared, 4);
          expect(find.text('Today'), findsOneWidget);
        },
      );

      testWidgets('takes the caller’s own words', (WidgetTester tester) async {
        await _pump(
          tester,
          PlDatePicker(
            value: july27,
            onChanged: (DateTime? _) {},
            labels: const PlPickerLabels(today: '오늘'),
          ),
        );
        await _open(tester);

        expect(find.text('오늘'), findsOneWidget);
      });
    });

    group('states', () {
      testWidgets('does not open while read-only', (WidgetTester tester) async {
        await _pump(
          tester,
          PlDatePicker(value: july27, onChanged: (DateTime? _) {}, readOnly: true),
        );
        await _open(tester);

        expect(find.byType(PlassCalendarCell), findsNothing);
      });

      testWidgets('does not open while disabled', (WidgetTester tester) async {
        await _pump(
          tester,
          PlDatePicker(value: july27, onChanged: (DateTime? _) {}, disabled: true),
        );
        await _open(tester);

        expect(find.byType(PlassCalendarCell), findsNothing);
      });
    });

    group('accessibility', () {
      testWidgets('names every cell with the whole date, never the number', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlDatePicker(value: july27, onChanged: (DateTime? _) {}));
        await _open(tester);

        expect(find.bySemanticsLabel('Monday, July 27, 2026'), findsOneWidget);
      });

      testWidgets('names the month and year buttons by what they show, and hints what they do', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();

        await _pump(tester, PlDatePicker(value: july27, onChanged: (DateTime? _) {}));
        await _open(tester);

        // The words on the button are its name, so a reader hears `July` first
        // and a voice command saying `July` finds it. The purpose follows.
        expect(
          tester.getSemantics(find.text('July')),
          isSemantics(label: 'July', hint: 'Choose a month', isButton: true),
        );
        expect(
          tester.getSemantics(find.text('2026')),
          isSemantics(label: '2026', hint: 'Choose a year', isButton: true),
        );

        handle.dispose();
      });

      testWidgets('says whether the calendar is open', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();

        await _pump(
          tester,
          PlDatePicker(value: july27, onChanged: (DateTime? _) {}, semanticLabel: 'Departure'),
        );

        expect(
          tester.getSemantics(_triggerGlyph()),
          isSemantics(label: 'Departure', isButton: true, isExpanded: false),
        );

        await _open(tester);

        expect(
          tester.getSemantics(_triggerGlyph()),
          isSemantics(label: 'Departure', isButton: true, isExpanded: true),
        );

        handle.dispose();
      });
    });

    group('labelPlacement', () {
      testWidgets('puts the label in the trigger\'s own top edge', (WidgetTester tester) async {
        // Every picker draws `internal/picker`'s shell, so this one stands for
        // the six of them.
        await _pump(
          tester,
          PlDatePicker(
            value: july27,
            label: const Text('Departure'),
            labelPlacement: PlassFieldLabelPlacement.notch,
            onChanged: (DateTime? _) {},
          ),
        );

        expect(find.byType(PlassFieldNotch), findsOneWidget);
        expect(find.text('Departure'), findsOneWidget);
      });
    });
  });
}
