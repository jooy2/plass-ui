// That a code block names its language the same way in both builds.
//
// The React build resolves a caller's `language` through a table of the
// spellings people write, `ts` for `typescript` and `yml` for `yaml`, and draws
// the name it resolves to on the bar. This build has the same table written out
// again, and two copies of a table drift. So this reads the one in
// `internal/highlight.ts` and compares it with the Dart one entry for entry.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/languages.dart';

final String _source = File('../react/src/internal/highlight.ts').readAsStringSync();

/// The `aliases` object literal in the TypeScript, as a map.
Map<String, String> _reactAliases() {
  final RegExpMatch? body = RegExp(
    r'const aliases: Record<string, string> = \{([^}]*)\};',
  ).firstMatch(_source);

  if (body == null) {
    throw StateError('internal/highlight.ts has no `aliases` table this test can read');
  }

  final Map<String, String> table = <String, String>{};

  for (final RegExpMatch entry in RegExp(
    r"""(?:'([^']+)'|([\w$]+))\s*:\s*'([^']+)'""",
  ).allMatches(body.group(1)!)) {
    table[entry.group(1) ?? entry.group(2)!] = entry.group(3)!;
  }

  return table;
}

void main() {
  test('holds every spelling the React build does, resolved to the same name', () {
    final Map<String, String> react = _reactAliases();

    // A guard against a regular expression that quietly matched nothing.
    expect(react, isNotEmpty);
    expect(languageAliases, equals(react));
  });

  test('resolves a spelling, and leaves a name the table does not hold as written', () {
    expect(canonicalLanguage('TS'), 'typescript');
    expect(canonicalLanguage(' yml '), 'yaml');
    expect(canonicalLanguage('Dart'), 'dart');
    expect(canonicalLanguage('  '), isNull);
    expect(canonicalLanguage(null), isNull);
  });
}
