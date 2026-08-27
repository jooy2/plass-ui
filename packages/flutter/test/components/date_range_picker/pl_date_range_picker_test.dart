import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/calendar.dart';
import 'package:plass_ui/src/internal/date.dart';

import '../../support/host.dart';

final PlDateRange july = PlDateRange(start: DateTime(2026, 7, 10), end: DateTime(2026, 7, 20));

/// Puts a picker on screen with room for two calendars. See the date picker's
/// test for why the surface has to be grown first.
Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1400, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, overlay: true));
  await tester.pumpAndSettle();
}

/// One cell, by the whole date it is named after.
///
/// Not by the number it draws: with two panels up, `15` is July's and August's.
PlassCalendarCell _cell(WidgetTester tester, String label) {
  return tester.widget<PlassCalendarCell>(
    find.byWidgetPredicate((Widget widget) => widget is PlassCalendarCell && widget.label == label),
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byType(PlDateRangePicker));
  await tester.pumpAndSettle();
}

/// A stateful wrapper, because the picker is controlled and a range is chosen in
/// two presses — the first has to land somewhere before the second is made.
class _Harness extends StatefulWidget {
  const _Harness({
    this.initial = PlDateRange.empty,
    this.monthCount = 2,
    this.defaultMonth,
    this.presets = const <PlDateRangePreset>[],
    this.clearable = false,
    this.readOnly = false,
    this.onChanged,
  });

  final PlDateRange initial;
  final int monthCount;
  final DateTime? defaultMonth;
  final List<PlDateRangePreset> presets;
  final bool clearable;
  final bool readOnly;
  final ValueChanged<PlDateRange>? onChanged;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late PlDateRange _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return PlDateRangePicker(
      value: _value,
      monthCount: widget.monthCount,
      defaultMonth: widget.defaultMonth,
      presets: widget.presets,
      clearable: widget.clearable,
      readOnly: widget.readOnly,
      startPlaceholder: const Text('Check in'),
      endPlaceholder: const Text('Check out'),
      onChanged: (PlDateRange next) {
        setState(() => _value = next);
        widget.onChanged?.call(next);
      },
    );
  }
}

void main() {
  group('PlDateRangePicker', () {
    group('rendering', () {
      testWidgets('writes both ends', (WidgetTester tester) async {
        await _pump(tester, _Harness(initial: july));

        expect(find.text('Jul 10, 2026'), findsOneWidget);
        expect(find.text('Jul 20, 2026'), findsOneWidget);
      });

      testWidgets('shows a placeholder in each half', (WidgetTester tester) async {
        await _pump(tester, const _Harness());

        // Once for real, and once more holding that half's width open.
        expect(find.text('Check in'), findsNWidgets(2));
        expect(find.text('Check out'), findsNWidgets(2));
      });
    });

    group('the two panels', () {
      testWidgets('shows two months, a month apart', (WidgetTester tester) async {
        await _pump(tester, _Harness(initial: july));
        await _open(tester);

        expect(find.text('July'), findsOneWidget);
        expect(find.text('August'), findsOneWidget);
      });

      testWidgets('shows one when asked', (WidgetTester tester) async {
        await _pump(tester, _Harness(initial: july, monthCount: 1));
        await _open(tester);

        expect(find.text('July'), findsOneWidget);
        expect(find.text('August'), findsNothing);
      });

      testWidgets('gives the pair one back stepper and one forward stepper', (
        WidgetTester tester,
      ) async {
        await _pump(tester, _Harness(initial: july));
        await _open(tester);

        expect(find.bySemanticsLabel('Previous month'), findsOneWidget);
        expect(find.bySemanticsLabel('Next month'), findsOneWidget);
      });

      testWidgets('moves both panels together', (WidgetTester tester) async {
        await _pump(tester, _Harness(initial: july));
        await _open(tester);
        await tester.tap(find.bySemanticsLabel('Next month'));
        await tester.pumpAndSettle();

        expect(find.text('August'), findsOneWidget);
        expect(find.text('September'), findsOneWidget);
      });

      testWidgets('names no day twice, so it draws no outside days', (WidgetTester tester) async {
        await _pump(tester, _Harness(initial: july));
        await _open(tester);

        // 1 August is the first day of the right panel; the left panel leaves a
        // hole where its trailing days would be rather than naming it twice.
        expect(find.bySemanticsLabel('Saturday, August 1, 2026'), findsOneWidget);
      });
    });

    group('choosing', () {
      testWidgets('takes the first press as the start and leaves the end open', (
        WidgetTester tester,
      ) async {
        final reported = <PlDateRange>[];

        await _pump(tester, _Harness(defaultMonth: DateTime(2026, 7), onChanged: reported.add));
        await _open(tester);
        await tester.tap(find.bySemanticsLabel('Wednesday, July 15, 2026'));
        await tester.pumpAndSettle();

        expect(reported.single.start, equals(DateTime(2026, 7, 15)));
        expect(reported.single.end, isNull);
      });

      testWidgets('takes the second press as the end', (WidgetTester tester) async {
        final reported = <PlDateRange>[];

        await _pump(tester, _Harness(defaultMonth: DateTime(2026, 7), onChanged: reported.add));
        await _open(tester);
        await tester.tap(find.bySemanticsLabel('Wednesday, July 15, 2026'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Monday, July 20, 2026'));
        await tester.pumpAndSettle();

        expect(reported.length, equals(2));
        expect(reported.last.start, equals(DateTime(2026, 7, 15)));
        expect(reported.last.end, equals(DateTime(2026, 7, 20)));
      });

      testWidgets('accepts a range pressed backwards, in the order it was meant', (
        WidgetTester tester,
      ) async {
        final reported = <PlDateRange>[];

        await _pump(tester, _Harness(defaultMonth: DateTime(2026, 7), onChanged: reported.add));
        await _open(tester);
        await tester.tap(find.bySemanticsLabel('Monday, July 20, 2026'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Wednesday, July 15, 2026'));
        await tester.pumpAndSettle();

        expect(reported.last.start, equals(DateTime(2026, 7, 15)));
        expect(reported.last.end, equals(DateTime(2026, 7, 20)));
      });

      testWidgets('bands the days between the two ends', (WidgetTester tester) async {
        await _pump(tester, _Harness(initial: july));
        await _open(tester);

        final PlassCalendarCell between = _cell(tester, 'Wednesday, July 15, 2026');

        expect(between.inRange, isTrue);
        expect(between.selected, isFalse);
        expect(between.rangeEdge, equals(PlassRangeEdge.middle));
      });

      testWidgets('rounds the band only where the run stops', (WidgetTester tester) async {
        await _pump(tester, _Harness(initial: july));
        await _open(tester);

        expect(_cell(tester, 'Friday, July 10, 2026').rangeEdge, equals(PlassRangeEdge.start));
        expect(_cell(tester, 'Monday, July 20, 2026').rangeEdge, equals(PlassRangeEdge.end));
      });

      testWidgets('marks both ends as chosen', (WidgetTester tester) async {
        await _pump(tester, _Harness(initial: july));
        await _open(tester);

        expect(_cell(tester, 'Friday, July 10, 2026').selected, isTrue);
        expect(_cell(tester, 'Monday, July 20, 2026').selected, isTrue);
      });

      testWidgets('says which end it is asking for', (WidgetTester tester) async {
        await _pump(tester, _Harness(defaultMonth: DateTime(2026, 7)));
        await _open(tester);

        expect(find.text('Start'), findsOneWidget);

        await tester.tap(find.bySemanticsLabel('Wednesday, July 15, 2026'));
        await tester.pumpAndSettle();

        expect(find.text('End'), findsOneWidget);
      });
    });

    group('presets', () {
      testWidgets('commits the whole range at once', (WidgetTester tester) async {
        final reported = <PlDateRange>[];

        await _pump(
          tester,
          _Harness(
            defaultMonth: DateTime(2026, 7),
            onChanged: reported.add,
            presets: <PlDateRangePreset>[
              PlDateRangePreset(label: const Text('That week'), build: () => july),
            ],
          ),
        );
        await _open(tester);
        await tester.tap(find.text('That week'));
        await tester.pumpAndSettle();

        expect(reported.single, equals(july));
      });

      testWidgets('builds a range that depends on today when it is taken', (
        WidgetTester tester,
      ) async {
        final reported = <PlDateRange>[];

        await _pump(
          tester,
          _Harness(
            onChanged: reported.add,
            presets: <PlDateRangePreset>[
              PlDateRangePreset(
                label: const Text('Today'),
                build: () => PlDateRange(start: todayDate(), end: todayDate()),
              ),
            ],
          ),
        );
        await _open(tester);
        await tester.tap(find.text('Today'));
        await tester.pumpAndSettle();

        expect(reported.single.start, equals(todayDate()));
      });
    });

    group('states', () {
      testWidgets('does not open while read-only', (WidgetTester tester) async {
        await _pump(tester, _Harness(initial: july, readOnly: true));
        await _open(tester);

        expect(find.byType(PlassCalendarCell), findsNothing);
      });

      testWidgets('empties both ends', (WidgetTester tester) async {
        final reported = <PlDateRange>[];

        await _pump(tester, _Harness(initial: july, clearable: true, onChanged: reported.add));
        await tester.tap(find.bySemanticsLabel('Clear'));
        await tester.pumpAndSettle();

        expect(reported.single, equals(PlDateRange.empty));
      });
    });
  });
}
