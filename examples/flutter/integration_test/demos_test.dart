/// Every demo the documentation shows, on a real device or simulator.
///
/// ```bash
/// flutter drive --driver test_driver/integration_test.dart \
///   --target integration_test/demos_test.dart --keep-app-running -d <device>
/// ```
///
/// `--keep-app-running` keeps the app, and so the screenshots it saved, for
/// `tool/pull_screenshots.sh`. Pass `--dart-define=PLASS_THEME=dark` for the
/// other theme and `--dart-define=PLASS_DEMOS=button,card` for some of the
/// components.
/// `test/demos_test.dart` runs the same check on the host at three widths; this
/// one is what shows how the device's own renderer draws a demo.
library;

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/canvas.dart';
import 'package:plass_ui_example/demos/registry.dart';

import 'support.dart';

const String _theme = String.fromEnvironment('PLASS_THEME', defaultValue: 'light');
const String _only = String.fromEnvironment('PLASS_DEMOS');

/// How long a demo gets to settle before its picture is taken. A demo of a
/// picture off the network needs longer: `--dart-define=PLASS_SETTLE_MS=2000`.
const int _settleMs = int.fromEnvironment('PLASS_SETTLE_MS', defaultValue: 500);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('every demo', (WidgetTester tester) async {
    final brightness = _theme == 'dark' ? Brightness.dark : Brightness.light;
    final wanted = _only.isEmpty ? null : _only.split(',').toSet();
    final failures = <String, List<String>>{};

    for (final MapEntry(key: name, value: build) in demos.entries) {
      if (wanted != null && !wanted.contains(name.split('/').first)) {
        continue;
      }

      final errors = await collectErrors(() async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: DefaultTextStyle(
              style: const TextStyle(fontFamily: 'Inter', package: 'plass_ui_example'),
              child: PlassTheme(
                brightness: brightness,
                child: Overlay.wrap(
                  child: SafeArea(
                    child: PlassCanvas(
                      key: ValueKey<String>(name),
                      child: Builder(builder: build),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        // Real time rather than a pump, which holds back what a picture off the
        // network is waiting for.
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: _settleMs)));
        await tester.pump(const Duration(milliseconds: 16));
        await saveShot(tester, '$_theme-$name');
        await tester.pumpWidget(const SizedBox());
      });

      if (errors.isNotEmpty) {
        failures[name] = errors;
      }
    }

    final report = failures.entries
        .map((MapEntry<String, List<String>> one) => '${one.key}: ${one.value.join(' | ')}')
        .join('\n');

    await File('${shotDirectory.path}/$_theme-errors.txt').writeAsString('$report\n');
    expect(failures, isEmpty, reason: report);
  }, timeout: Timeout.none);
}
