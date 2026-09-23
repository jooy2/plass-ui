import 'package:flutter/services.dart';
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

    group('the keyboard focus', () {
      testWidgets('is on the semantics tree, and follows the arrow keys there', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        await _pump(tester, PlCalendar(value: july27, onChanged: (DateTime? _) {}));

        Focus.of(tester.element(find.text('27'))).requestFocus();
        await tester.pumpAndSettle();

        // A screen reader's cursor follows the node that says it is focused, so
        // a cell the keyboard reached has to say so, or the arrow keys move a
        // ring nobody listening can find.
        expect(
          tester.getSemantics(find.bySemanticsLabel('Monday, July 27, 2026')),
          isSemantics(isFocusable: true, isFocused: true, isButton: true, isSelected: true),
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();

        expect(
          tester.getSemantics(find.bySemanticsLabel('Tuesday, July 28, 2026')),
          isSemantics(isFocusable: true, isFocused: true, isButton: true),
        );
        expect(
          tester.getSemantics(find.bySemanticsLabel('Monday, July 27, 2026')),
          isSemantics(isFocusable: true, isFocused: false, isButton: true, isSelected: true),
        );

        handle.dispose();
      });
    });

    group('the keyboard', () {
      /// The label the day cell for [date] carries, the way the grid writes it.
      String labelOf(DateTime date) {
        const PlDateNames names = PlDateNames();

        return '${names.weekdays[date.weekday % 7]}, ${names.months[date.month - 1]} '
            '${date.day}, ${date.year}';
      }

      /// Whether the cell for [date] is the one holding the focus.
      bool focused(WidgetTester tester, DateTime date) {
        return Focus.of(tester.element(find.bySemanticsLabel(labelOf(date)))).hasFocus;
      }

      testWidgets('puts the tab stop on the chosen day', (WidgetTester tester) async {
        await _pump(
          tester,
          PlCalendar(value: july27, autofocus: true, onChanged: (DateTime? _) {}),
        );

        expect(focused(tester, july27), isTrue);
      });

      testWidgets('puts it on today when nothing is chosen and today is on screen', (
        WidgetTester tester,
      ) async {
        final DateTime now = DateTime.now();

        await _pump(
          tester,
          PlCalendar(value: null, defaultMonth: now, autofocus: true, onChanged: (DateTime? _) {}),
        );

        expect(focused(tester, DateTime(now.year, now.month, now.day)), isTrue);
      });

      testWidgets('puts it on the 1st otherwise', (WidgetTester tester) async {
        await _pump(
          tester,
          PlCalendar(
            value: null,
            defaultMonth: DateTime(1999, 3, 17),
            autofocus: true,
            onChanged: (DateTime? _) {},
          ),
        );

        expect(focused(tester, DateTime(1999, 3, 1)), isTrue);
      });

      testWidgets('moves by a day, a week, and to the ends of the week, and by a month', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlCalendar(
            value: july15,
            weekStartsOn: PlassWeekday.monday,
            autofocus: true,
            onChanged: (DateTime? _) {},
          ),
        );

        // Wednesday, July 15, 2026, in a week that starts on Monday.
        const List<(LogicalKeyboardKey, (int, int, int))> steps =
            <(LogicalKeyboardKey, (int, int, int))>[
              (LogicalKeyboardKey.arrowRight, (2026, 7, 16)),
              (LogicalKeyboardKey.arrowDown, (2026, 7, 23)),
              (LogicalKeyboardKey.arrowLeft, (2026, 7, 22)),
              (LogicalKeyboardKey.arrowUp, (2026, 7, 15)),
              (LogicalKeyboardKey.home, (2026, 7, 13)),
              (LogicalKeyboardKey.end, (2026, 7, 19)),
              (LogicalKeyboardKey.pageDown, (2026, 8, 19)),
              (LogicalKeyboardKey.pageUp, (2026, 7, 19)),
            ];

        for (final (LogicalKeyboardKey key, (int, int, int) lands) in steps) {
          await tester.sendKeyEvent(key);
          await tester.pumpAndSettle();

          expect(
            focused(tester, DateTime(lands.$1, lands.$2, lands.$3)),
            isTrue,
            reason: '${key.keyLabel} should land on $lands',
          );
        }
      });

      testWidgets('steps the month when an arrow runs off its edge', (WidgetTester tester) async {
        await _pump(
          tester,
          PlCalendar(value: DateTime(2026, 7, 31), autofocus: true, onChanged: (DateTime? _) {}),
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();

        expect(focused(tester, DateTime(2026, 8, 1)), isTrue);
        expect(find.text('August'), findsOneWidget);
      });

      testWidgets('moves by a year with Shift and the page keys', (WidgetTester tester) async {
        await _pump(
          tester,
          PlCalendar(value: july15, autofocus: true, onChanged: (DateTime? _) {}),
        );

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pumpAndSettle();

        expect(focused(tester, DateTime(2027, 7, 15)), isTrue);
        expect(find.text('2027'), findsOneWidget);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pumpAndSettle();

        expect(focused(tester, DateTime(2025, 7, 15)), isTrue);

        // Let go of Shift, and the page keys are back to a month.
        await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
        await tester.pumpAndSettle();

        expect(focused(tester, DateTime(2025, 8, 15)), isTrue);
      });

      testWidgets('lands on the last day of a shorter month', (WidgetTester tester) async {
        await _pump(
          tester,
          PlCalendar(value: DateTime(2026, 1, 31), autofocus: true, onChanged: (DateTime? _) {}),
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
        await tester.pumpAndSettle();

        expect(focused(tester, DateTime(2026, 2, 28)), isTrue);
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

      testWidgets('takes the grid out of reach without an onChanged, as disabled does', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlCalendar(value: july27));

        await tester.tap(find.bySemanticsLabel('Next month'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.text('July'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        final BuildContext? focused = FocusManager.instance.primaryFocus?.context;

        expect(focused?.findAncestorWidgetOfExactType<PlCalendar>(), isNull);
      });

      testWidgets('keeps what it had open when disabled is turned on and off', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlCalendar(value: july27, onChanged: (DateTime? _) {}));
        await tester.tap(find.bySemanticsLabel('July'));
        await tester.pumpAndSettle();

        // The month grid, opened from the header.
        expect(find.byType(PlassCalendarCell), findsNWidgets(12));

        for (final bool disabled in <bool>[true, false]) {
          await _pump(
            tester,
            PlCalendar(value: july27, disabled: disabled, onChanged: (DateTime? _) {}),
          );

          // Not built again from nothing, which would open on the day grid.
          expect(find.byType(PlassCalendarCell), findsNWidgets(12), reason: 'disabled: $disabled');
        }
      });

      testWidgets('keeps its header buttons, and what they were showing, across disabled', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlCalendar(value: july27, onChanged: (DateTime? _) {}));

        final Finder next = find.byWidgetPredicate(
          (Widget widget) => widget is PlButton && widget.semanticLabel == 'Next month',
        );
        final State<StatefulWidget> before = tester.state(next);

        for (final bool disabled in <bool>[true, false]) {
          await _pump(
            tester,
            PlCalendar(value: july27, disabled: disabled, onChanged: (DateTime? _) {}),
          );

          // The same button rather than a new one, so a hover or a press it was
          // lit with is still there when the calendar comes back.
          expect(tester.state(next), same(before), reason: 'disabled: $disabled');
        }
      });

      /// The day, the two steppers and the month and year buttons, each with the
      /// hint it carries.
      const Map<String, String?> announced = <String, String?>{
        'Wednesday, July 15, 2026': null,
        'Previous month': null,
        'Next month': null,
        'July': 'Choose a month',
        '2026': 'Choose a year',
      };

      testWidgets('announces its days and its header buttons as enabled while it can be used', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        await _pump(tester, PlCalendar(value: july27, onChanged: (DateTime? _) {}));

        announced.forEach((String label, String? hint) {
          expect(
            tester.getSemantics(find.bySemanticsLabel(label)),
            isSemantics(isButton: true, hasEnabledState: true, isEnabled: true, hint: hint),
            reason: label,
          );
        });

        handle.dispose();
      });

      for (final (String how, PlCalendar calendar) in <(String, PlCalendar)>[
        ('with disabled', PlCalendar(value: july27, disabled: true, onChanged: (DateTime? _) {})),
        ('without an onChanged', PlCalendar(value: july27)),
      ]) {
        testWidgets('announces its days and its header buttons as disabled $how', (
          WidgetTester tester,
        ) async {
          final SemanticsHandle handle = tester.ensureSemantics();
          await _pump(tester, calendar);

          announced.forEach((String label, String? hint) {
            expect(
              tester.getSemantics(find.bySemanticsLabel(label)),
              isSemantics(
                isButton: true,
                hasEnabledState: true,
                isEnabled: false,
                hasTapAction: false,
                hint: hint,
              ),
              reason: label,
            );
          });

          handle.dispose();
        });
      }

      // The month and the year grids, reached here through `precision`, which
      // is the view such a calendar opens on.
      for (final (PlCalendarPrecision precision, String cell) in <(PlCalendarPrecision, String)>[
        (PlCalendarPrecision.month, 'August 2026'),
        (PlCalendarPrecision.year, '2020'),
      ]) {
        final String view = precision.name;

        testWidgets('announces the cells of its $view grid as disabled too', (
          WidgetTester tester,
        ) async {
          final SemanticsHandle handle = tester.ensureSemantics();
          await _pump(
            tester,
            PlCalendar(value: july27, precision: precision, onChanged: (DateTime? _) {}),
          );

          expect(
            tester.getSemantics(find.bySemanticsLabel(cell)),
            isSemantics(isButton: true, hasEnabledState: true, isEnabled: true, hasTapAction: true),
          );

          await _pump(
            tester,
            PlCalendar(
              value: july27,
              precision: precision,
              disabled: true,
              onChanged: (DateTime? _) {},
            ),
          );

          expect(
            tester.getSemantics(find.bySemanticsLabel(cell)),
            isSemantics(
              isButton: true,
              hasEnabledState: true,
              isEnabled: false,
              hasTapAction: false,
            ),
          );

          handle.dispose();
        });
      }
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
