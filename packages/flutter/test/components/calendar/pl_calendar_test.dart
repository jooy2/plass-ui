import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
// The cell is internal — the grid is what a test counts, and there is no public
// name for one square of it.
import 'package:plass_ui/src/internal/calendar.dart';

import '../../support/host.dart';

/// Fixed days to work against, so nothing here depends on when it is run.
final DateTime july27 = DateTime(2026, 7, 27);
final DateTime july15 = DateTime(2026, 7, 15);
final DateTime august3 = DateTime(2026, 8, 3);

/// A calendar on a surface big enough to hold seven rows of cells.
Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(900, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child));
  await tester.pumpAndSettle();
}

void main() {
  group('PlCalendar', () {
    group('rendering', () {
      testWidgets('draws a grid without anything having to be opened', (WidgetTester tester) async {
        await _pump(tester, PlCalendar(value: july27, onChanged: (DateTime? _) {}));

        // The whole difference from a PlDatePicker: there is no trigger, and the
        // grid is simply there.
        expect(find.byType(PlassCalendarCell), findsNWidgets(42));
      });

      testWidgets('opens on the month of its value', (WidgetTester tester) async {
        await _pump(tester, PlCalendar(value: august3, onChanged: (DateTime? _) {}));

        expect(find.text('August'), findsOneWidget);
      });

      testWidgets('opens on defaultMonth when there is no value', (WidgetTester tester) async {
        await _pump(
          tester,
          PlCalendar(value: null, defaultMonth: july27, onChanged: (DateTime? _) {}),
        );

        expect(find.text('July'), findsOneWidget);
      });
    });

    group('choosing a day', () {
      testWidgets('reports the day that was pressed', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlCalendar(value: july27, onChanged: (DateTime? next) => chosen = next),
        );
        await tester.tap(find.bySemanticsLabel('Wednesday, July 15, 2026'));
        await tester.pumpAndSettle();

        expect(chosen, equals(july15));
      });

      testWidgets('keeps the time of day a value already carried', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlCalendar(
            value: DateTime(2026, 7, 27, 9, 30),
            onChanged: (DateTime? next) => chosen = next,
          ),
        );
        await tester.tap(find.bySemanticsLabel('Wednesday, July 15, 2026'));
        await tester.pumpAndSettle();

        expect(chosen, equals(DateTime(2026, 7, 15, 9, 30)));
      });

      testWidgets('does not move a value nothing changed', (WidgetTester tester) async {
        await _pump(tester, PlCalendar(value: july27, onChanged: (DateTime? _) {}));
        await tester.tap(find.bySemanticsLabel('Wednesday, July 15, 2026'));
        await tester.pumpAndSettle();

        // The value is the caller's; the widget draws what it was handed.
        expect(find.bySemanticsLabel('Monday, July 27, 2026'), findsOneWidget);
      });
    });

    group('the month on screen', () {
      testWidgets('moves with its own header', (WidgetTester tester) async {
        await _pump(tester, PlCalendar(value: july27, onChanged: (DateTime? _) {}));
        await tester.tap(find.bySemanticsLabel('Next month'));
        await tester.pumpAndSettle();

        expect(find.text('August'), findsOneWidget);
      });

      testWidgets('reports the month it moved to', (WidgetTester tester) async {
        DateTime? moved;

        await _pump(
          tester,
          PlCalendar(
            value: july27,
            onChanged: (DateTime? _) {},
            onMonthChanged: (DateTime next) => moved = next,
          ),
        );
        await tester.tap(find.bySemanticsLabel('Next month'));
        await tester.pumpAndSettle();

        expect(moved?.month, equals(8));
      });

      testWidgets('stays where a controlling caller put it', (WidgetTester tester) async {
        await _pump(
          tester,
          PlCalendar(
            value: null,
            month: DateTime(2026, 7),
            onMonthChanged: (DateTime _) {},
            onChanged: (DateTime? _) {},
          ),
        );
        await tester.tap(find.bySemanticsLabel('Next month'));
        await tester.pumpAndSettle();

        // Controlled: the header asked, and nothing answered.
        expect(find.text('July'), findsOneWidget);
      });
    });

    group('precision', () {
      testWidgets('stops at the month grid when asked for a month', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlCalendar(
            value: july27,
            precision: PlCalendarPrecision.month,
            onChanged: (DateTime? next) => chosen = next,
          ),
        );

        // Twelve months, and no day grid under them.
        expect(find.byType(PlassCalendarCell), findsNWidgets(12));

        await tester.tap(find.bySemanticsLabel('October 2026'));
        await tester.pumpAndSettle();

        // The 1st of October, never whichever day the cursor was resting on.
        expect(chosen, equals(DateTime(2026, 10)));
      });
    });

    group('bounds', () {
      testWidgets('blocks a day outside minDate', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlCalendar(
            value: july27,
            minDate: DateTime(2026, 7, 18),
            onChanged: (DateTime? next) => chosen = next,
          ),
        );
        await tester.tap(find.bySemanticsLabel('Wednesday, July 15, 2026'));
        await tester.pumpAndSettle();

        expect(chosen, isNull);
      });

      testWidgets('blocks the days shouldDisableDate rejects', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlCalendar(
            value: july27,
            shouldDisableDate: (DateTime date) => date.day == 15,
            onChanged: (DateTime? next) => chosen = next,
          ),
        );
        await tester.tap(find.bySemanticsLabel('Wednesday, July 15, 2026'));
        await tester.pumpAndSettle();

        expect(chosen, isNull);

        await tester.tap(find.bySemanticsLabel('Saturday, July 18, 2026'));
        await tester.pumpAndSettle();

        expect(chosen, equals(DateTime(2026, 7, 18)));
      });
    });

    group('disabled', () {
      testWidgets('takes the whole grid out of reach', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlCalendar(value: july27, disabled: true, onChanged: (DateTime? next) => chosen = next),
        );
        await tester.tap(find.bySemanticsLabel('Wednesday, July 15, 2026'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(chosen, isNull);
      });

      testWidgets('is inert without an onChanged, like every other control', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const PlCalendar(value: null));

        // Still drawn, still readable — the grid is the content.
        expect(find.byType(PlassCalendarCell), findsNWidgets(42));
      });
    });

    group('the words', () {
      testWidgets('draws the names it was given', (WidgetTester tester) async {
        await _pump(
          tester,
          PlCalendar(
            value: july27,
            onChanged: (DateTime? _) {},
            names: const PlDateNames(
              months: <String>[
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
            ),
          ),
        );

        expect(find.text('7월'), findsOneWidget);
      });

      testWidgets('says its own name when it is given one', (WidgetTester tester) async {
        await _pump(
          tester,
          PlCalendar(value: july27, onChanged: (DateTime? _) {}, semanticLabel: 'Departure date'),
        );

        // The widget's own `Semantics`, not the merged node: `bySemanticsLabel`
        // lands on whatever the label was merged into, which for a container
        // holding forty-two named cells is not this.
        expect(
          find.byWidgetPredicate(
            (Widget widget) => widget is Semantics && widget.properties.label == 'Departure date',
          ),
          findsOneWidget,
        );
      });
    });
  });
}
