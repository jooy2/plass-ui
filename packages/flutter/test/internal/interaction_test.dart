import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/interaction.dart';

import '../support/host.dart';

/// The key on the surface under test.
const Key _subject = ValueKey<String>('subject');

/// The last state the surface was built with.
PlassInteraction? _seen;

/// A surface under test, pressable or not, available or not.
Widget _surface({required bool pressable, bool enabled = true}) {
  return PlassInteractive(
    key: _subject,
    onTap: () {},
    enabled: enabled && pressable,
    interactive: enabled && pressable,
    pressable: pressable,
    builder: (BuildContext context, PlassInteraction state) {
      _seen = state;

      return const SizedBox.square(dimension: 40);
    },
  );
}

/// [child] after a focus stop of its own, in [mode].
Widget _page(FocusNode before, NavigationMode mode, Widget child) {
  return host(
    MediaQuery(
      data: MediaQueryData(navigationMode: mode),
      child: afterFocusStop(before, child),
    ),
  );
}

/// Whether the focus is on the surface under test.
bool _holdsFocus(WidgetTester tester) {
  final BuildContext? focused = FocusManager.instance.primaryFocus?.context;

  return focused != null &&
      find
          .descendant(
            of: find.byKey(_subject),
            matching: find.byElementPredicate((Element element) => element == focused),
            matchRoot: true,
          )
          .evaluate()
          .isNotEmpty;
}

Future<void> _tabFrom(WidgetTester tester, FocusNode before) async {
  before.requestFocus();
  await tester.pump();
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pump();
}

void main() {
  group('PlassInteractive', () {
    group('pressable', () {
      for (final NavigationMode mode in NavigationMode.values) {
        testWidgets('takes a surface with nothing to press out of the focus order, ${mode.name}', (
          WidgetTester tester,
        ) async {
          final before = FocusNode(debugLabel: 'before');
          addTearDown(before.dispose);

          await tester.pumpWidget(_page(before, mode, _surface(pressable: false)));
          await _tabFrom(tester, before);

          expect(_holdsFocus(tester), isFalse);
        });
      }

      testWidgets('leaves an unavailable control a stop in directional navigation', (
        WidgetTester tester,
      ) async {
        final before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);

        // Where a reader on a remote finds a disabled control. It is the
        // surface with nothing to press that is not one.
        await tester.pumpWidget(
          _page(before, NavigationMode.directional, _surface(pressable: true, enabled: false)),
        );
        await _tabFrom(tester, before);

        expect(_holdsFocus(tester), isTrue);
      });

      for (final NavigationMode mode in NavigationMode.values) {
        testWidgets(
          'gives the focus up as it stops being pressable, and draws no ring once it is again, '
          '${mode.name}',
          (WidgetTester tester) async {
            final before = FocusNode(debugLabel: 'before');
            addTearDown(before.dispose);

            await tester.pumpWidget(_page(before, mode, _surface(pressable: true)));
            await _tabFrom(tester, before);

            expect(_holdsFocus(tester), isTrue);
            expect(_seen!.focusVisible, isTrue);

            await tester.pumpWidget(_page(before, mode, _surface(pressable: false)));
            await tester.pumpAndSettle();

            expect(_holdsFocus(tester), isFalse);
            expect(_seen!.focusVisible, isFalse);

            await tester.pumpWidget(_page(before, mode, _surface(pressable: true)));
            await tester.pumpAndSettle();

            // Nothing holds it, so there is no ring to draw.
            expect(_holdsFocus(tester), isFalse);
            expect(_seen!.focusVisible, isFalse);
          },
        );
      }
    });
  });
}
