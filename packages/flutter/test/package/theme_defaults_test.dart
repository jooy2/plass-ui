// That a `PlassTheme`'s defaults are exactly the same as writing the parameter.
//
// A test of a *contract* rather than of a widget, which is why it is here
// rather than under `test/components/`. It deliberately asserts no design value
// — no radius, no height, no colour — because those move with the design
// language and a test that pinned them would turn every deliberate change into
// a failure. What it compares is **one widget against itself**: the tree a
// `size:` parameter builds, against the tree the same widget builds under a
// theme that said the same thing.
//
// The second half is the one that catches the next widget rather than this
// week's: it reads every component's source and fails on a style axis that
// still has a default baked into its constructor, where no theme can reach it.
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/host.dart';

/// One rendering per widget, taking whichever axis is being asked about, with
/// the type to find it by.
final Map<String, (Type, Widget Function({PlassSize? size}))>
cases = <String, (Type, Widget Function({PlassSize? size}))>{
  'PlButton': (PlButton, ({PlassSize? size}) => PlButton(size: size, child: const Text('Save'))),
  'PlTextField': (
    PlTextField,
    ({PlassSize? size}) => PlTextField(size: size, label: const Text('Email')),
  ),
  'PlCheckbox': (
    PlCheckbox,
    ({PlassSize? size}) => PlCheckbox(size: size, value: false, label: const Text('Remember me')),
  ),
  'PlSwitch': (PlSwitch, ({PlassSize? size}) => PlSwitch(size: size, value: false)),
  'PlChip': (PlChip, ({PlassSize? size}) => PlChip(size: size, child: const Text('Draft'))),
  'PlAlert': (
    PlAlert,
    ({PlassSize? size}) =>
        PlAlert(size: size, title: const Text('Saved'), child: const Text('Live.')),
  ),
  'PlCard': (PlCard, ({PlassSize? size}) => PlCard(size: size, child: const Text('Ten seats.'))),
  'PlAvatar': (PlAvatar, ({PlassSize? size}) => PlAvatar(size: size, name: 'Ada Lovelace')),
  'PlBadge': (
    PlBadge,
    ({PlassSize? size}) =>
        PlBadge(size: size, content: const Text('3'), child: const Text('Inbox')),
  ),
  'PlSkeleton': (PlSkeleton, ({PlassSize? size}) => PlSkeleton(size: size, animated: false)),
  'PlStat': (
    PlStat,
    ({PlassSize? size}) =>
        PlStat(size: size, label: const Text('Revenue'), value: const Text('48,120')),
  ),
  'PlEmpty': (
    PlEmpty,
    ({PlassSize? size}) => PlEmpty(size: size, title: const Text('Nothing here')),
  ),
  'PlDivider': (PlDivider, ({PlassSize? size}) => PlDivider(size: size, child: const Text('or'))),
};

/// What the widget *built*, as text — its subtree, starting below it.
///
/// Below, not from, on purpose: the widget's own description carries the
/// parameter it was given, so a `size: xs` and a `size: null` under a theme that
/// says `xs` differ there and nowhere else. What is being compared is the tree
/// they produce.
///
/// The `#hash` identities are normalised out and they are the only other thing
/// that legitimately differs between two builds. Everything else is the failure
/// this is looking for.
Future<String> subtree(WidgetTester tester, Widget child, Type type) async {
  await tester.pumpWidget(host(SizedBox(width: 300, child: child)));
  await tester.pump();

  final List<String> all = tester.allElements
      .map((Element element) => element.widget.toStringShallow())
      .toList();
  final int at = all.indexWhere((String line) => line.startsWith('$type'));

  expect(at, isNonNegative, reason: 'no $type in the tree');

  return all.sublist(at + 1).join('\n').replaceAll(RegExp('#[0-9a-f]{5}'), '#');
}

void main() {
  group('PlassTheme defaults', () {
    for (final MapEntry<String, (Type, Widget Function({PlassSize? size}))> entry
        in cases.entries) {
      final (Type type, Widget Function({PlassSize? size}) build) = entry.value;

      testWidgets('${entry.key} — a theme is the same as the parameter', (
        WidgetTester tester,
      ) async {
        final String written = await subtree(tester, build(size: PlassSize.xs), type);
        final String themed = await subtree(
          tester,
          PlassTheme.merge(
            defaults: const PlassDefaults(size: PlassSize.xs),
            child: build(),
          ),
          type,
        );

        expect(themed, equals(written));
      });

      testWidgets('${entry.key} — its own parameter wins over the theme', (
        WidgetTester tester,
      ) async {
        final String written = await subtree(tester, build(size: PlassSize.xl), type);
        final String themed = await subtree(
          tester,
          PlassTheme.merge(
            defaults: const PlassDefaults(size: PlassSize.xs),
            child: build(size: PlassSize.xl),
          ),
          type,
        );

        expect(themed, equals(written));
      });
    }

    testWidgets('a nested theme keeps what it did not say', (WidgetTester tester) async {
      late PlassDefaults seen;

      await tester.pumpWidget(
        host(
          PlassTheme.merge(
            defaults: const PlassDefaults(size: PlassSize.xs, color: PlassColor.danger),
            child: PlassTheme.merge(
              defaults: const PlassDefaults(size: PlassSize.xl),
              child: Builder(
                builder: (BuildContext context) {
                  seen = PlassTheme.defaultsOf(context);

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      expect(seen.size, equals(PlassSize.xl));
      // The inner theme said nothing about colour, so the outer one still holds.
      expect(seen.color, equals(PlassColor.danger));
    });

    testWidgets('a plain theme replaces rather than merging', (WidgetTester tester) async {
      late PlassDefaults seen;

      await tester.pumpWidget(
        host(
          PlassTheme.merge(
            defaults: const PlassDefaults(size: PlassSize.xs, color: PlassColor.danger),
            child: PlassTheme(
              brightness: Brightness.light,
              defaults: const PlassDefaults(size: PlassSize.xl),
              child: Builder(
                builder: (BuildContext context) {
                  seen = PlassTheme.defaultsOf(context);

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      // `DefaultTextStyle`'s bargain: the constructor replaces and `merge`
      // merges, because an `InheritedWidget` has no context of its own to read
      // an ancestor with.
      expect(seen.size, equals(PlassSize.xl));
      expect(seen.color, isNull);
    });

    testWidgets('merge keeps the brightness in scope', (WidgetTester tester) async {
      late PlassTokens tokens;

      await tester.pumpWidget(
        host(
          PlassTheme(
            brightness: Brightness.dark,
            child: PlassTheme.merge(
              defaults: const PlassDefaults(size: PlassSize.xs),
              child: Builder(
                builder: (BuildContext context) {
                  tokens = PlassTheme.of(context);

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      // A section of a dark screen can be made compact without going light.
      expect(tokens, equals(PlassTokens.of(Brightness.dark)));
    });
  });

  group('every widget reads the theme', () {
    final List<File> sources = Directory('lib/src/components')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.path.endsWith('.dart'))
        .toList(growable: false);

    for (final String axis in <String>['size', 'color', 'density']) {
      test('no constructor bakes a default for `$axis`', () {
        // A literal default in a constructor is an axis the theme can never
        // reach: the widget resolved it before anybody could say otherwise.
        final RegExp baked = RegExp('this\\.$axis = Plass\\w+\\.', multiLine: true);

        final List<String> offenders = <String>[
          for (final File file in sources)
            if (baked.hasMatch(file.readAsStringSync())) file.path,
        ];

        expect(offenders, isEmpty);
      });
    }

    test('no date widget bakes its own vocabulary', () {
      final List<String> offenders = <String>[
        for (final File file in sources)
          if (file.readAsStringSync().contains('this.names = PlDateNames.') ||
              file.readAsStringSync().contains('this.labels = PlPickerLabels.'))
            file.path,
      ];

      expect(offenders, isEmpty);
    });
  });
}
