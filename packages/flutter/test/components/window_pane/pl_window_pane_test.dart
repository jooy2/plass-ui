import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(600, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, width: 420));
  await tester.pumpAndSettle();
}

void main() {
  group('PlWindowPane', () {
    testWidgets('names the window after its title', (WidgetTester tester) async {
      await _pump(tester, const PlWindowPane(title: Text('Notes'), child: Text('Body')));

      // Twice over, and both are right: the window is a container named after
      // its title, and the title itself is text in the bar.
      expect(find.bySemanticsLabel('Notes'), findsWidgets);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('draws the three buttons with real names', (WidgetTester tester) async {
      await _pump(tester, const PlWindowPane(title: Text('Notes')));

      for (final String name in <String>['Minimize', 'Maximize', 'Close']) {
        expect(find.bySemanticsLabel(name), findsOneWidget);
      }
    });

    testWidgets('draws only the buttons it was given', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlWindowPane(
          title: Text('Notes'),
          controls: <PlWindowControl>{PlWindowControl.close},
        ),
      );

      expect(find.bySemanticsLabel('Close'), findsOneWidget);
      expect(find.bySemanticsLabel('Minimize'), findsNothing);
    });

    testWidgets('takes every system it names', (WidgetTester tester) async {
      for (final PlWindowOs os in PlWindowOs.values) {
        await _pump(tester, PlWindowPane(os: os, title: const Text('Notes')));

        expect(find.byType(PlWindowPane), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('puts the buttons where the system puts them', (WidgetTester tester) async {
      await _pump(tester, const PlWindowPane(os: PlWindowOs.macos, title: Text('Notes')));

      final double macClose = tester.getCenter(find.bySemanticsLabel('Close')).dx;

      await _pump(tester, const PlWindowPane(os: PlWindowOs.windows11, title: Text('Notes')));

      final double winClose = tester.getCenter(find.bySemanticsLabel('Close')).dx;

      // macOS puts close first and Windows puts it last, whichever order the
      // caller wrote the set in.
      expect(macClose, lessThan(winClose));
    });

    testWidgets('tells the caller when a button is pressed', (WidgetTester tester) async {
      bool? closed;
      bool? minimized;
      bool? maximized;

      await _pump(
        tester,
        PlWindowPane(
          title: const Text('Notes'),
          onOpenChanged: (bool value) => closed = value,
          onMinimizedChanged: (bool value) => minimized = value,
          onMaximizedChanged: (bool value) => maximized = value,
        ),
      );

      await tester.tap(find.bySemanticsLabel('Minimize'));
      await tester.tap(find.bySemanticsLabel('Maximize'));
      await tester.tap(find.bySemanticsLabel('Close'));
      await tester.pumpAndSettle();

      expect(minimized, isTrue);
      expect(maximized, isTrue);
      expect(closed, isFalse);
    });

    testWidgets('offers to restore once it is maximized', (WidgetTester tester) async {
      await _pump(tester, const PlWindowPane(title: Text('Notes'), maximized: true));

      expect(find.bySemanticsLabel('Restore'), findsOneWidget);
      expect(find.bySemanticsLabel('Maximize'), findsNothing);
    });

    testWidgets('rolls up to its bar rather than sending itself anywhere', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const PlWindowPane(title: Text('Notes'), minimized: true, child: Text('Body')),
      );

      // The bar stays where it is — a page has nowhere to send a window.
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('renders nothing when it is closed', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlWindowPane(title: Text('Notes'), open: false, child: Text('Body')),
      );

      expect(find.text('Body'), findsNothing);
      expect(find.text('Notes'), findsNothing);
    });

    testWidgets('takes an override for each button name', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlWindowPane(
          title: Text('Notes'),
          minimizeLabel: 'Roll up',
          maximizeLabel: 'Fill',
          closeLabel: 'Dismiss',
        ),
      );

      for (final String name in <String>['Roll up', 'Fill', 'Dismiss']) {
        expect(find.bySemanticsLabel(name), findsOneWidget);
      }
    });

    testWidgets('drags by its bar when it is allowed to', (WidgetTester tester) async {
      Offset? moved;

      await _pump(
        tester,
        PlWindowPane(
          title: const Text('Notes'),
          draggable: true,
          width: 300,
          onOffsetChanged: (Offset value) => moved = value,
        ),
      );

      await tester.drag(find.text('Notes'), const Offset(40, 20));
      await tester.pumpAndSettle();

      expect(moved, isNotNull);
      expect(moved!.dx, greaterThan(0));
    });

    testWidgets('stays where it is when it is not', (WidgetTester tester) async {
      Offset? moved;

      await _pump(
        tester,
        PlWindowPane(
          title: const Text('Notes'),
          width: 300,
          onOffsetChanged: (Offset value) => moved = value,
        ),
      );

      await tester.drag(find.text('Notes'), const Offset(40, 20));
      await tester.pumpAndSettle();

      expect(moved, isNull);
    });

    testWidgets('takes an icon and actions in the bar', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlWindowPane(title: Text('Notes'), icon: Text('◆'), actions: Text('Share')),
      );

      expect(find.text('◆'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('climbs the size ladder without touching the content', (WidgetTester tester) async {
      double? small;

      for (final PlassSize size in <PlassSize>[PlassSize.xs, PlassSize.xl]) {
        await _pump(tester, PlWindowPane(title: const Text('Notes'), size: size));

        final double height = tester.getSize(find.byType(PlWindowPane)).height;

        if (small == null) {
          small = height;
        } else {
          expect(height, greaterThan(small));
        }
      }
    });
  });
}
