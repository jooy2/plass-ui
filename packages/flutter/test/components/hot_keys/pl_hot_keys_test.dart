import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

void main() {
  group('PlHotKeys', () {
    group('the Mod key', () {
      testWidgets('is Command on a Mac', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlHotKeys(keys: 'Mod+K', os: PlHotKeysOS.mac)));

        expect(find.text('⌘'), findsOneWidget);
        expect(find.text('K'), findsOneWidget);
      });

      testWidgets('is Ctrl everywhere else', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlHotKeys(keys: 'Mod+K', os: PlHotKeysOS.windows)));

        expect(find.text('Ctrl'), findsOneWidget);
        expect(find.text('⌘'), findsNothing);
      });

      testWidgets('follows the platform when nothing is named', (WidgetTester tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        await tester.pumpWidget(host(const PlHotKeys(keys: 'Mod+K')));

        expect(find.text('⌘'), findsOneWidget);

        // Put back inside the test rather than in a `tearDown`: the binding
        // checks the foundation's debug variables at the end of each one.
        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('the separator', () {
      testWidgets('is a plus on Windows', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlHotKeys(keys: 'Ctrl+Shift+P', os: PlHotKeysOS.windows)),
        );

        expect(find.text('+'), findsNWidgets(2));
      });

      testWidgets('is nothing at all on a Mac', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlHotKeys(keys: 'Ctrl+Shift+P', os: PlHotKeysOS.mac)));

        expect(find.text('+'), findsNothing);
      });

      testWidgets('is whatever a caller passed', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlHotKeys(keys: 'Ctrl+P', os: PlHotKeysOS.mac, separator: Text('then'))),
        );

        expect(find.text('then'), findsOneWidget);
      });
    });

    group('tokens', () {
      testWidgets('capitalises a single letter, because that is what is on the key', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlHotKeys(keys: 'mod+k', os: PlHotKeysOS.windows)));

        expect(find.text('K'), findsOneWidget);
      });

      testWidgets('leaves a word as it was written', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlHotKeys(keys: 'F12', os: PlHotKeysOS.windows)));

        expect(find.text('F12'), findsOneWidget);
      });

      testWidgets('takes the list form for a shortcut whose key is a plus', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlHotKeys(keys: <String>['Ctrl', '+'], os: PlHotKeysOS.windows)),
        );

        // Two: the key cap and the separator between it and Ctrl.
        expect(find.text('+'), findsNWidgets(2));
      });

      testWidgets('draws an arrow on every platform', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlHotKeys(keys: 'Up', os: PlHotKeysOS.windows)));

        expect(find.text('↑'), findsOneWidget);
      });

      testWidgets('takes the aliases one key already has', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlHotKeys(keys: 'Command+Option', os: PlHotKeysOS.mac)));

        expect(find.text('⌘'), findsOneWidget);
        expect(find.text('⌥'), findsOneWidget);
      });
    });

    group('cluster', () {
      testWidgets('lays four keys out as an inverted T', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlHotKeys(
              cluster: PlHotKeysCluster(up: 'W', left: 'A', down: 'S', right: 'D'),
            ),
          ),
        );

        final up = tester.getRect(find.text('W'));
        final down = tester.getRect(find.text('S'));

        expect(up.center.dy, lessThan(down.center.dy));
        expect(up.center.dx, closeTo(down.center.dx, 1));
      });
    });

    group('accessibility', () {
      testWidgets('says the name of a key drawn as a glyph', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlHotKeys(keys: 'Mod+K', os: PlHotKeysOS.mac)));

        expect(find.bySemanticsLabel('Command'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('leaves the separator out of what is read', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlHotKeys(keys: 'Ctrl+K', os: PlHotKeysOS.windows)));

        expect(find.bySemanticsLabel('+'), findsNothing);
        handle.dispose();
      });
    });
  });
}
