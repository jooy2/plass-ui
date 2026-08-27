import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/calendar.dart';

import '../../support/host.dart';

/// Half past nine on a fixed day, so nothing here depends on when it is run.
final DateTime nineThirty = DateTime(2026, 7, 27, 9, 30);

/// Puts a picker on screen with room for its columns. See the date picker's test
/// for why the surface has to be grown first.
Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(900, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, overlay: true));
  await tester.pumpAndSettle();
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byType(PlTimePicker));
  await tester.pumpAndSettle();
}

/// One row of one column, by the whole name it carries.
Finder _row(String label) =>
    find.byWidgetPredicate((Widget widget) => widget is PlassCalendarCell && widget.label == label);

PlassCalendarCell _cell(WidgetTester tester, String label) =>
    tester.widget<PlassCalendarCell>(_row(label));

/// Presses a row, scrolling its own column until it is on screen first.
///
/// A column of twenty-four hours is nine hundred pixels of rows inside a
/// two-hundred-and-eighty-pixel window, so most of what a test wants to press is
/// below the fold.
Future<void> _tapRow(WidgetTester tester, String label) async {
  await tester.ensureVisible(_row(label));
  await tester.pumpAndSettle();
  await tester.tap(_row(label));
  await tester.pumpAndSettle();
}

void main() {
  group('PlTimePicker', () {
    group('rendering', () {
      testWidgets('writes the chosen time on a 24-hour clock', (WidgetTester tester) async {
        await _pump(tester, PlTimePicker(value: nineThirty, onChanged: (DateTime? _) {}));

        expect(find.text('09:30'), findsOneWidget);
      });

      testWidgets('and on a 12-hour one', (WidgetTester tester) async {
        await _pump(
          tester,
          PlTimePicker(value: nineThirty, hour12: true, onChanged: (DateTime? _) {}),
        );

        expect(find.text('9:30 AM'), findsOneWidget);
      });

      testWidgets('adds the seconds when they are shown', (WidgetTester tester) async {
        await _pump(
          tester,
          PlTimePicker(
            value: DateTime(2026, 7, 27, 9, 30, 5),
            showSeconds: true,
            onChanged: (DateTime? _) {},
          ),
        );

        expect(find.text('09:30:05'), findsOneWidget);
      });

      testWidgets('writes it the caller’s own way when told how', (WidgetTester tester) async {
        await _pump(
          tester,
          PlTimePicker(
            value: nineThirty,
            onChanged: (DateTime? _) {},
            formatValue: (DateTime value) => '${value.hour}h${value.minute}',
          ),
        );

        expect(find.text('9h30'), findsOneWidget);
      });
    });

    group('the columns', () {
      testWidgets('draws hours and minutes, and no seconds', (WidgetTester tester) async {
        await _pump(tester, PlTimePicker(value: nineThirty, onChanged: (DateTime? _) {}));
        await _open(tester);

        expect(find.bySemanticsLabel('Hour'), findsOneWidget);
        expect(find.bySemanticsLabel('Minute'), findsOneWidget);
        expect(find.bySemanticsLabel('Second'), findsNothing);
      });

      testWidgets('adds seconds when asked', (WidgetTester tester) async {
        await _pump(
          tester,
          PlTimePicker(value: nineThirty, showSeconds: true, onChanged: (DateTime? _) {}),
        );
        await _open(tester);

        expect(find.bySemanticsLabel('Second'), findsOneWidget);
      });

      testWidgets('draws no AM/PM column on a 24-hour dial', (WidgetTester tester) async {
        await _pump(tester, PlTimePicker(value: nineThirty, onChanged: (DateTime? _) {}));
        await _open(tester);

        expect(find.bySemanticsLabel('AM/PM'), findsNothing);
      });

      testWidgets('adds one on a 12-hour dial', (WidgetTester tester) async {
        await _pump(
          tester,
          PlTimePicker(value: nineThirty, hour12: true, onChanged: (DateTime? _) {}),
        );
        await _open(tester);

        expect(find.bySemanticsLabel('AM/PM'), findsOneWidget);
      });

      testWidgets('runs a 24-hour dial from 00 to 23', (WidgetTester tester) async {
        await _pump(tester, PlTimePicker(value: nineThirty, onChanged: (DateTime? _) {}));
        await _open(tester);

        expect(_row('00 Hour'), findsOneWidget);
        expect(_row('23 Hour'), findsOneWidget);
        expect(_row('24 Hour'), findsNothing);
      });

      testWidgets('reads a 12-hour dial as 12, 1, 2 rather than 0, 1, 2', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlTimePicker(value: nineThirty, hour12: true, onChanged: (DateTime? _) {}),
        );
        await _open(tester);

        expect(_row('12 Hour'), findsOneWidget);
        expect(_row('0 Hour'), findsNothing);
        expect(_row('13 Hour'), findsNothing);
      });

      testWidgets('steps the columns as far apart as it was told', (WidgetTester tester) async {
        await _pump(
          tester,
          PlTimePicker(value: nineThirty, minuteStep: 15, onChanged: (DateTime? _) {}),
        );
        await _open(tester);

        expect(_row('00 Minute'), findsOneWidget);
        expect(_row('15 Minute'), findsOneWidget);
        expect(_row('16 Minute'), findsNothing);
      });

      testWidgets('marks the chosen row in each column', (WidgetTester tester) async {
        await _pump(tester, PlTimePicker(value: nineThirty, onChanged: (DateTime? _) {}));
        await _open(tester);

        expect(_cell(tester, '09 Hour').selected, isTrue);
        expect(_cell(tester, '30 Minute').selected, isTrue);
        expect(_cell(tester, '08 Hour').selected, isFalse);
      });

      testWidgets('marks nothing while there is no value', (WidgetTester tester) async {
        await _pump(tester, PlTimePicker(value: null, onChanged: (DateTime? _) {}));
        await _open(tester);

        expect(_cell(tester, '09 Hour').selected, isFalse);
      });
    });

    group('choosing', () {
      testWidgets('sets the hour and leaves the minutes alone', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlTimePicker(value: nineThirty, onChanged: (DateTime? next) => chosen = next),
        );
        await _open(tester);
        await _tapRow(tester, '14 Hour');

        expect(chosen, equals(DateTime(2026, 7, 27, 14, 30)));
      });

      testWidgets('stays open, because a time is two answers', (WidgetTester tester) async {
        await _pump(tester, PlTimePicker(value: nineThirty, onChanged: (DateTime? _) {}));
        await _open(tester);
        await _tapRow(tester, '45 Minute');

        expect(find.bySemanticsLabel('Hour'), findsOneWidget);
      });

      testWidgets('closes on the first touch when told to', (WidgetTester tester) async {
        await _pump(
          tester,
          PlTimePicker(value: nineThirty, closeOnSelect: true, onChanged: (DateTime? _) {}),
        );
        await _open(tester);
        await _tapRow(tester, '45 Minute');

        expect(find.bySemanticsLabel('Hour'), findsNothing);
      });

      testWidgets('moves the whole clock when the meridiem is switched', (
        WidgetTester tester,
      ) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlTimePicker(
            value: nineThirty,
            hour12: true,
            onChanged: (DateTime? next) => chosen = next,
          ),
        );
        await _open(tester);
        await _tapRow(tester, 'PM AM/PM');

        expect(chosen?.hour, equals(21));
      });

      testWidgets('writes a chosen time onto the reference day', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlTimePicker(
            value: null,
            referenceDate: DateTime(2026, 1, 15),
            onChanged: (DateTime? next) => chosen = next,
          ),
        );
        await _open(tester);
        await _tapRow(tester, '07 Hour');

        expect(chosen, equals(DateTime(2026, 1, 15, 7)));
      });
    });

    group('bounds', () {
      testWidgets('leaves the hour available when only some of its minutes are', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlTimePicker(
            value: nineThirty,
            minTime: DateTime(2026, 7, 27, 9, 30),
            onChanged: (DateTime? _) {},
          ),
        );
        await _open(tester);

        // 9 covers 09:00:00–09:59:59, which overlaps what is allowed — hiding it
        // would make half past nine unreachable.
        expect(_cell(tester, '09 Hour').disabled, isFalse);
        expect(_cell(tester, '08 Hour').disabled, isTrue);
      });

      testWidgets('greys out the minutes before the bound in that hour', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlTimePicker(
            value: nineThirty,
            minTime: DateTime(2026, 7, 27, 9, 30),
            onChanged: (DateTime? _) {},
          ),
        );
        await _open(tester);

        expect(_cell(tester, '25 Minute').disabled, isTrue);
        expect(_cell(tester, '30 Minute').disabled, isFalse);
      });

      testWidgets('blocks the rows a rule says are unavailable', (WidgetTester tester) async {
        await _pump(
          tester,
          PlTimePicker(
            value: nineThirty,
            onChanged: (DateTime? _) {},
            shouldDisableTime: (DateTime value, PlassTimeUnit unit) =>
                unit == PlassTimeUnit.hour && value.hour >= 12,
          ),
        );
        await _open(tester);

        expect(_cell(tester, '13 Hour').disabled, isTrue);
        expect(_cell(tester, '09 Hour').disabled, isFalse);
      });

      testWidgets('does not commit a blocked row', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlTimePicker(
            value: nineThirty,
            minTime: DateTime(2026, 7, 27, 9, 0),
            onChanged: (DateTime? next) => chosen = next,
          ),
        );
        await _open(tester);
        await _tapRow(tester, '03 Hour');

        expect(chosen, isNull);
      });
    });

    group('the footer', () {
      testWidgets('offers Done while the popup stays open', (WidgetTester tester) async {
        await _pump(tester, PlTimePicker(value: nineThirty, onChanged: (DateTime? _) {}));
        await _open(tester);

        expect(find.text('Done'), findsOneWidget);
      });

      testWidgets('offers no Done when the popup closes on the first touch', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          PlTimePicker(value: nineThirty, closeOnSelect: true, onChanged: (DateTime? _) {}),
        );
        await _open(tester);

        expect(find.text('Done'), findsNothing);
      });

      testWidgets('jumps to now', (WidgetTester tester) async {
        DateTime? chosen;

        await _pump(
          tester,
          PlTimePicker(value: nineThirty, onChanged: (DateTime? next) => chosen = next),
        );
        await _open(tester);
        await tester.tap(find.text('Now'));
        await tester.pumpAndSettle();

        expect(chosen?.hour, equals(DateTime.now().hour));
      });
    });

    group('states', () {
      testWidgets('does not open while read-only', (WidgetTester tester) async {
        await _pump(
          tester,
          PlTimePicker(value: nineThirty, readOnly: true, onChanged: (DateTime? _) {}),
        );
        await _open(tester);

        expect(find.bySemanticsLabel('Hour'), findsNothing);
      });

      testWidgets('empties the picker', (WidgetTester tester) async {
        DateTime? chosen = nineThirty;
        var called = false;

        await _pump(
          tester,
          PlTimePicker(
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
    });
  });
}
