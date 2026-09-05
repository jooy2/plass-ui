import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(600, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: 300, height: 500));
  await tester.pumpAndSettle();
}

void main() {
  group('PlMockup', () {
    testWidgets('lays the screen out at the device own resolution', (WidgetTester tester) async {
      await _pump(tester, const PlMockup(device: PlMockupDevice.mobile));

      // An `md` phone is 390 by 844, whatever the mockup measures on the page.
      final Finder inner = find.byType(FittedBox);

      expect(inner, findsOneWidget);
      expect(
        tester.getSize(find.descendant(of: inner, matching: find.byType(SizedBox)).first),
        const Size(416, 870),
      );
    });

    testWidgets('climbs a ladder of real machines rather than of control heights', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const PlMockup(device: PlMockupDevice.mobile, size: PlassSize.xs));

      final Size small = tester.getSize(
        find.descendant(of: find.byType(FittedBox), matching: find.byType(SizedBox)).first,
      );

      await _pump(tester, const PlMockup(device: PlMockupDevice.mobile, size: PlassSize.xl));

      final Size large = tester.getSize(
        find.descendant(of: find.byType(FittedBox), matching: find.byType(SizedBox)).first,
      );

      expect(large.width, greaterThan(small.width));
    });

    testWidgets('turns the screen with the device', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlMockup(device: PlMockupDevice.mobile, orientation: PlMockupOrientation.landscape),
      );

      final Size turned = tester.getSize(
        find.descendant(of: find.byType(FittedBox), matching: find.byType(SizedBox)).first,
      );

      expect(turned.width, greaterThan(turned.height));
    });

    testWidgets('leaves a desktop where it is, because its stand does not turn', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const PlMockup(device: PlMockupDevice.desktop, orientation: PlMockupOrientation.landscape),
      );

      final Size drawn = tester.getSize(
        find.descendant(of: find.byType(FittedBox), matching: find.byType(SizedBox)).first,
      );

      expect(drawn.width, greaterThan(drawn.height));
      expect(tester.takeException(), isNull);
    });

    testWidgets('puts the content on the screen', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlMockup(
          device: PlMockupDevice.mobile,
          child: Center(child: Text('Hello from the phone')),
        ),
      );

      expect(find.text('Hello from the phone'), findsOneWidget);
    });

    testWidgets('draws the clock the caller gave it', (WidgetTester tester) async {
      await _pump(tester, const PlMockup(device: PlMockupDevice.mobile, time: '11:11'));

      expect(find.text('11:11'), findsOneWidget);
    });

    testWidgets('draws no bars at all when systemUi is off', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlMockup(device: PlMockupDevice.mobile, time: '11:11', systemUi: false),
      );

      expect(find.text('11:11'), findsNothing);
    });

    testWidgets('falls back to a system the device actually runs', (WidgetTester tester) async {
      // `windows` is not a phone system, so an iOS status bar is drawn instead.
      await _pump(
        tester,
        const PlMockup(device: PlMockupDevice.mobile, os: PlMockupOs.windows, time: '11:11'),
      );

      expect(find.text('11:11'), findsOneWidget);
    });

    testWidgets('takes every device, bezel and finish it names', (WidgetTester tester) async {
      for (final PlMockupDevice device in PlMockupDevice.values) {
        for (final PlMockupBezel bezel in PlMockupBezel.values) {
          await _pump(tester, PlMockup(device: device, bezel: bezel));

          expect(find.byType(PlMockup), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      }

      for (final PlMockupFinish finish in PlMockupFinish.values) {
        await _pump(tester, PlMockup(device: PlMockupDevice.mobile, finish: finish));

        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('takes every system it names on the device that runs it', (
      WidgetTester tester,
    ) async {
      for (final PlMockupOs os in PlMockupOs.values) {
        for (final PlMockupDevice device in PlMockupDevice.values) {
          await _pump(tester, PlMockup(device: device, os: os));

          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('holds a desktop up with a stand or a keyboard', (WidgetTester tester) async {
      for (final PlMockupHardware hardware in PlMockupHardware.values) {
        await _pump(tester, PlMockup(device: PlMockupDevice.desktop, hardware: hardware));

        expect(find.byType(ClipPath), findsWidgets);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('takes a resolution of its own over the ladder', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlMockup(
          device: PlMockupDevice.desktop,
          bezel: PlMockupBezel.none,
          resolution: PlMockupResolution(1200, 600),
        ),
      );

      final Size drawn = tester.getSize(
        find.descendant(of: find.byType(FittedBox), matching: find.byType(SizedBox)).first,
      );

      // No hardware, so the frame is the screen and its proportion is the
      // caller's own two numbers.
      expect(drawn.width / drawn.height, closeTo(2, 0.01));
    });
  });
}
