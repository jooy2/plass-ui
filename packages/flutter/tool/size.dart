/// What a consumer's app grows by, measured the way they would pay it.
///
/// `pub.dev`'s package size answers a different question: it is the tarball, and
/// a tarball tells you nothing about what survives compilation. Dart's tree
/// shaker is whole-program, so the number that matters is the difference between
/// an app that imports this package and the same app that does not — and the
/// only way to know it is to compile both.
///
/// This builds a set of fixed scenarios for the web with `--release` (dart2js,
/// the same tree shaker AOT uses) and reports `main.dart.js` gzipped, because
/// every server on the path compresses. The scenarios start from an empty
/// `WidgetsApp` so that the delta is this package and nothing else.
///
/// A Material scenario is in the list without importing this package at all. It
/// is the counterfactual: what one `import 'package:flutter/material.dart'`
/// would have cost, had the library been built on Material the way most are.
///
///   dart run tool/size.dart
///
/// It takes a few minutes — one web build per scenario — so it is a tool you
/// run when you have changed something structural, not a CI step on every pull
/// request. `test/package/framework_surface_test.dart` is the cheap guard that
/// does run every time.
library;

import 'dart:io';

/// `name` is what gets printed; `body` is the widget expression under `home:`.
/// A null `body` means the scenario writes its own `main`, for the Material
/// counterfactual which must not import this package.
const Map<String, String?> scenarios = <String, String?>{
  'empty (기준)': '',
  'PlDivider 1개': 'PlDivider()',
  'PlTypography 1개': "PlTypography('Hi')",
  'PlCard 1개': "PlCard(child: Text('Hi'))",
  'PlButton 1개': "PlButton(child: Text('Save'))",
  'Material 1개 (비교군)': null,
};

String entryPoint(String? body) {
  if (body == null) {
    return '''
import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(body: Center(child: ElevatedButton(onPressed: null, child: Text('Save')))),
  ),
);
''';
  }
  final String home = body.isEmpty ? 'SizedBox.shrink()' : body;
  return '''
import 'package:flutter/widgets.dart';
${body.isEmpty ? '' : "import 'package:plass_ui/plass_ui.dart';"}

void main() => runApp(
  WidgetsApp(
    color: const Color(0xFF000000),
    debugShowCheckedModeBanner: false,
    home: const $home,
  ),
);
''';
}

Future<void> main() async {
  final Directory work = Directory.systemTemp.createTempSync('plass-size-');
  final String package = Directory.current.absolute.path;

  stdout.writeln('앱 하네스 생성 중… ${work.path}');
  await run('flutter', <String>[
    'create',
    '--platforms=web',
    '--project-name=plass_size',
    'app',
  ], cwd: work.path);

  final String app = '${work.path}/app';
  final File pubspec = File('$app/pubspec.yaml');
  pubspec.writeAsStringSync(
    pubspec.readAsStringSync().replaceFirst(
      '  flutter:\n    sdk: flutter\n',
      '  flutter:\n    sdk: flutter\n  plass_ui:\n    path: $package\n',
    ),
  );
  await run('flutter', <String>['pub', 'get'], cwd: app);

  final Map<String, int> sizes = <String, int>{};
  var index = 0;
  for (final MapEntry<String, String?> entry in scenarios.entries) {
    final String file = 'lib/main_${index++}.dart';
    File('$app/$file').writeAsStringSync(entryPoint(entry.value));
    stdout.writeln('빌드: ${entry.key}');
    await run('flutter', <String>['build', 'web', '--release', '-t', file], cwd: app);
    final List<int> bytes = File('$app/build/web/main.dart.js').readAsBytesSync();
    sizes[entry.key] = gzip.encode(bytes).length;
  }

  final int floor = sizes.values.first;
  stdout.writeln('\n${'시나리오'.padRight(24)}${'main.dart.js gz'.padLeft(18)}${'기준 대비'.padLeft(14)}');
  stdout.writeln('-' * 56);
  for (final MapEntry<String, int> entry in sizes.entries) {
    final double kb = entry.value / 1024;
    final double delta = (entry.value - floor) / 1024;
    stdout.writeln(
      entry.key.padRight(24) +
          '${kb.toStringAsFixed(1)} kB'.padLeft(18) +
          (entry.value == floor ? '—' : '+${delta.toStringAsFixed(1)} kB').padLeft(14),
    );
  }

  work.deleteSync(recursive: true);
}

Future<void> run(String executable, List<String> arguments, {required String cwd}) async {
  final ProcessResult result = await Process.run(
    executable,
    arguments,
    workingDirectory: cwd,
    runInShell: true,
  );
  if (result.exitCode != 0) {
    stderr.writeln('$executable ${arguments.join(' ')} 실패:\n${result.stdout}\n${result.stderr}');
    exit(1);
  }
}
