import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/calendar.dart';
import 'package:plass_ui/src/internal/date.dart';

import '../../support/host.dart';

/// Half past nine on 27 July 2026, so nothing here depends on when it is run.
final DateTime moment = DateTime(2026, 7, 27, 9, 30);

/// Puts a picker on screen with room for a calendar and a clock side by side.
Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1200, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, overlay: true));
  await tester.pumpAndSettle();
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byType(PlDateTimePicker));
  await tester.pumpAndSettle();
}

/// One cell of either panel, by the whole name it carries.
Finder _cellFinder(String label) =>
    find.byWidgetPredicate((Widget widget) => widget is PlassCalendarCell && widget.label == label);

PlassCalendarCell _cell(WidgetTester tester, String label) =>
    tester.widget<PlassCalendarCell>(_cellFinder(label));

/// Presses a cell, scrolling its own column until it is on screen first.
Future<void> _tap(WidgetTester tester, String label) async {
  await tester.ensureVisible(_cellFinder(label));
  await tester.pumpAndSettle();
  await tester.tap(_cellFinder(label));
  await tester.pumpAndSettle();
}

void main() {
  group('PlDateTimePicker', () {
    group('rendering', () {
      testWidgets('writes the day and the time together', (WidgetTester tester) async {
        await _pump(tester, PlDateTimePicker(value: moment, onChanged: (DateTime? _) {}));

        expect(find.text('Jul 27, 2026 09:30'), findsOneWidget);
      });

      testWidgets('writes it the caller’s own way when told how', (WidgetTester tester) async {
        await _pump(
          tester,
          PlDateTimePicker(
            value: moment,
            onChanged: (DateTime? _) {},
            formatValue: (DateTime value) => '${value.day}/${value.month} at ${value.hour}',
          ),
        );

        expect(find.text('27/7 at 9'), findsOneWidget);
      });

      testWidgets('shows the placeholder while nothing is chosen', (WidgetTester tester) async {
        await _pump(
          tester,
          PlDateTimePicker(
            value: null,
            onChanged: (DateTime? _) {},
            placeholder: const Text('Pick a moment'),
          ),
        );

        // Once for real, and once more holding the trigger's width open.
        expect(find.text('Pick a moment'), findsNWidgets(2));
      });
    });

    group('the popup', () {
      testWidgets('holds a calendar and a clock side by side', (WidgetTester tester) async {
        await _pump(tester, PlDateTimePicker(value: moment, onChanged: (DateTime? _) {}));
        await _open(tester);

        expect(find.text('July'), findsOneWidget);
        expect(find.bySemanticsLabel('Hour'), findsOneWidget);
        expect(find.bySemanticsLabel('Minute'), findsOneWidget);
      });

      testWidgets('gives both panels the same height', (WidgetTester tester) async {
        await _pump(tester, PlDateTimePicker(value: moment, onChanged: (DateTime? _) {}));
        await _open(tester);

        // The calendar's grid is seven cells tall counting its header, and the
        // clock's columns are seven of the same cell — which is what makes the
        // popup one rectangle rather than two of different heights.
        final double clock = tester
            .getSize(
              find
                  .ancestor(of: find.text('09'), matching: find.byType(SingleChildScrollView))
                  .first,
            )
            .height;

        expect(clock, equals(cellSize[PlassSize.md]! * 7));
      });
    });

    group('choosing', () {
      testWidgets('changes the day and leaves the clock alone', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlDateTimePicker(value: moment, onChanged: (DateTime? next) => chosen = next),
        );
        await _open(tester);
        await _tap(tester, 'Wednesday, July 15, 2026');

        expect(chosen, equals(DateTime(2026, 7, 15, 9, 30)));
      });

      testWidgets('changes the clock and leaves the day alone', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlDateTimePicker(value: moment, onChanged: (DateTime? next) => chosen = next),
        );
        await _open(tester);
        await _tap(tester, '14 Hour');

        expect(chosen, equals(DateTime(2026, 7, 27, 14, 30)));
      });

      testWidgets('stays open after a day, because a moment is two answers', (
        WidgetTester tester,
      ) async {
        await _pump(tester, PlDateTimePicker(value: moment, onChanged: (DateTime? _) {}));
        await _open(tester);
        await _tap(tester, 'Wednesday, July 15, 2026');

        expect(find.bySemanticsLabel('Hour'), findsOneWidget);
      });

      testWidgets('closes after a day when told to', (WidgetTester tester) async {
        await _pump(
          tester,
          PlDateTimePicker(value: moment, closeOnSelect: true, onChanged: (DateTime? _) {}),
        );
        await _open(tester);
        await _tap(tester, 'Wednesday, July 15, 2026');

        expect(find.bySemanticsLabel('Hour'), findsNothing);
      });

      testWidgets('writes the clock onto today while no day has been chosen', (
        WidgetTester tester,
      ) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlDateTimePicker(value: null, onChanged: (DateTime? next) => chosen = next),
        );
        await _open(tester);
        await _tap(tester, '07 Hour');

        final DateTime now = todayDate();

        expect(chosen, equals(DateTime(now.year, now.month, now.day, 7)));
      });
    });

    group('bounds', () {
      testWidgets('leaves the bound day selectable and greys out the hours before it', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlDateTimePicker(
            value: DateTime(2026, 7, 27, 12),
            minDate: DateTime(2026, 7, 27, 9, 30),
            onChanged: (DateTime? _) {},
          ),
        );
        await _open(tester);

        // The 27th itself is still available — the bound is inside it.
        expect(_cell(tester, 'Monday, July 27, 2026').disabled, isFalse);
        expect(_cell(tester, '08 Hour').disabled, isTrue);
        expect(_cell(tester, '09 Hour').disabled, isFalse);
      });

      testWidgets('blocks the day before the bound entirely', (WidgetTester tester) async {
        await _pump(
          tester,
          PlDateTimePicker(
            value: DateTime(2026, 7, 27, 12),
            minDate: DateTime(2026, 7, 27, 9, 30),
            onChanged: (DateTime? _) {},
          ),
        );
        await _open(tester);

        expect(_cell(tester, 'Sunday, July 26, 2026').disabled, isTrue);
      });

      testWidgets('blocks the rows a rule says are unavailable', (WidgetTester tester) async {
        await _pump(
          tester,
          PlDateTimePicker(
            value: moment,
            onChanged: (DateTime? _) {},
            shouldDisableTime: (DateTime value, PlassTimeUnit unit) =>
                unit == PlassTimeUnit.hour && value.hour < 8,
          ),
        );
        await _open(tester);

        expect(_cell(tester, '03 Hour').disabled, isTrue);
        expect(_cell(tester, '09 Hour').disabled, isFalse);
      });
    });

    group('the footer', () {
      testWidgets('always offers Done, because the popup stays up', (WidgetTester tester) async {
        await _pump(tester, PlDateTimePicker(value: moment, onChanged: (DateTime? _) {}));
        await _open(tester);

        expect(find.text('Done'), findsOneWidget);
      });

      testWidgets('jumps to this moment without closing', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlDateTimePicker(value: moment, onChanged: (DateTime? next) => chosen = next),
        );
        await _open(tester);
        await tester.tap(find.text('Now'));
        await tester.pumpAndSettle();

        expect(chosen?.day, equals(DateTime.now().day));
        // Still up: Now is a shortcut, not an answer.
        expect(find.bySemanticsLabel('Hour'), findsOneWidget);
      });
    });

    group('states', () {
      testWidgets('does not open while read-only', (WidgetTester tester) async {
        await _pump(
          tester,
          PlDateTimePicker(value: moment, readOnly: true, onChanged: (DateTime? _) {}),
        );
        await _open(tester);

        expect(find.byType(PlassCalendarCell), findsNothing);
      });
    });
  });
}
