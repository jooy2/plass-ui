import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

void main() {
  group('PlSlider', () {
    group('rendering', () {
      testWidgets('draws one thumb per value', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlSlider(values: const <double>[20, 60], onChanged: (List<double> _) {}),
            width: 300,
          ),
        );

        // One thumb per value: each is a `MouseRegion` with a grab cursor.
        expect(
          tester
              .widgetList<MouseRegion>(find.byType(MouseRegion))
              .where((MouseRegion region) => region.cursor == SystemMouseCursors.grab)
              .length,
          2,
        );
      });

      testWidgets('shows the value beside the label when asked', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlSlider(values: <double>[42], label: Text('Volume'), showValue: true),
            width: 300,
          ),
        );

        expect(find.text('Volume'), findsOneWidget);
        expect(find.text('42'), findsOneWidget);
      });

      testWidgets('formats the value when told how', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlSlider(
              values: const <double>[42],
              showValue: true,
              formatValue: (List<double> values) => '${values.first.round()}%',
            ),
            width: 300,
          ),
        );

        expect(find.text('42%'), findsOneWidget);
      });
    });

    group('the rail', () {
      testWidgets('is the groove, and the run over it is the family gradient', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlSlider(values: <double>[50]), width: 300));

        final painted = decorationsOf(tester, find.byType(PlSlider));

        expect(painted.any((BoxDecoration one) => one.color == PlassTokens.light().track), isTrue);
        expect(painted.any((BoxDecoration one) => one.gradient != null), isTrue);
      });
    });

    group('dragging', () {
      testWidgets('moves the nearest thumb when the rail is pressed', (WidgetTester tester) async {
        List<double>? reported;
        await tester.pumpWidget(
          host(
            PlSlider(values: const <double>[0], onChanged: (List<double> next) => reported = next),
            width: 300,
          ),
        );

        final rail = tester.getRect(find.byType(PlSlider));
        await tester.tapAt(Offset(rail.center.dx, rail.center.dy));

        expect(reported!.first, closeTo(50, 2));
      });

      testWidgets('does not move while disabled', (WidgetTester tester) async {
        List<double>? reported;
        await tester.pumpWidget(
          host(
            PlSlider(
              values: const <double>[0],
              disabled: true,
              onChanged: (List<double> next) => reported = next,
            ),
            width: 300,
          ),
        );

        await tester.tapAt(tester.getCenter(find.byType(PlSlider)));
        expect(reported, isNull);
      });
    });

    group('the keyboard', () {
      testWidgets('moves a thumb by one step', (WidgetTester tester) async {
        List<double>? reported;
        await tester.pumpWidget(
          host(
            PlSlider(
              values: const <double>[50],
              autofocus: true,
              onChanged: (List<double> next) => reported = next,
            ),
            width: 300,
          ),
        );
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        expect(reported!.first, 51);
      });

      testWidgets('takes the step it was given', (WidgetTester tester) async {
        List<double>? reported;
        await tester.pumpWidget(
          host(
            PlSlider(
              values: const <double>[50],
              step: 10,
              autofocus: true,
              onChanged: (List<double> next) => reported = next,
            ),
            width: 300,
          ),
        );
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        expect(reported!.first, 40);
      });

      testWidgets('goes to the ends on Home and End', (WidgetTester tester) async {
        List<double>? reported;
        await tester.pumpWidget(
          host(
            PlSlider(
              values: const <double>[50],
              autofocus: true,
              onChanged: (List<double> next) => reported = next,
            ),
            width: 300,
          ),
        );
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        expect(reported!.first, 0);
      });
    });

    group('a range', () {
      testWidgets('does not let the thumbs cross', (WidgetTester tester) async {
        List<double>? reported;
        await tester.pumpWidget(
          host(
            PlSlider(
              values: const <double>[40, 60],
              autofocus: true,
              step: 100,
              onChanged: (List<double> next) => reported = next,
            ),
            width: 300,
          ),
        );
        await tester.pump();

        // A step of 100 would take the first thumb past the second.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        expect(reported!.first, 60);
      });
    });

    group('accessibility', () {
      testWidgets('is a slider with a value', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlSlider(
              values: const <double>[42],
              semanticLabel: 'Volume',
              onChanged: (List<double> _) {},
            ),
            width: 300,
          ),
        );

        expect(
          semanticsOf(tester, find.byType(PlSlider)),
          isSemantics(isSlider: true, label: 'Volume', value: '42'),
        );

        handle.dispose();
      });
    });
  });
}
