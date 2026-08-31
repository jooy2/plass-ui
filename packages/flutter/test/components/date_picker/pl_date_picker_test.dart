import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
// The cell is internal — the grid is what a test counts, and there is no public
// name for one square of it.
import 'package:plass_ui/src/internal/calendar.dart';
import 'package:plass_ui/src/internal/icons.dart';

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
        expect(find.bySemanticsLabel('Choose a month'), findsNothing);
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
  });
}
