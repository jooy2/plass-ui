import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/interaction.dart';

import '../support/host.dart';

/// The key on the surface under test.
const Key _subject = ValueKey<String>('subject');

/// The last state the surface was built with.
PlassInteraction? _seen;

/// A surface under test, pressable or not, available or not, on [focusNode]
/// when it is handed one.
Widget _surface({
  required bool pressable,
  bool enabled = true,
  FocusNode? focusNode,
  Key key = _subject,
}) {
  return PlassInteractive(
    key: key,
    onTap: () {},
    enabled: enabled && pressable,
    interactive: enabled && pressable,
    pressable: pressable,
    focusNode: focusNode,
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

/// The node the surface under test is using, its own or a handed one.
FocusNode _nodeOf(WidgetTester tester) {
  return Focus.of(
    tester.element(find.descendant(of: find.byKey(_subject), matching: find.byType(SizedBox))),
  );
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

    group('focus', () {
      for (final NavigationMode mode in NavigationMode.values) {
        for (final bool handed in <bool>[false, true]) {
          final String node = handed ? 'a node it was handed' : 'its own node';

          testWidgets(
            'is a stop only while it can be pressed and reached, on $node, ${mode.name}',
            (WidgetTester tester) async {
              final before = FocusNode(debugLabel: 'before');
              addTearDown(before.dispose);
              final given = FocusNode(debugLabel: 'given');
              addTearDown(given.dispose);

              // One surface, told each thing in turn and back again. A remote
              // still finds an unavailable control; nothing finds a surface with
              // nothing to press, whichever node it is on.
              for (final (bool pressable, bool enabled) in <(bool, bool)>[
                (true, true),
                (false, true),
                (true, false),
                (false, true),
                (true, true),
              ]) {
                final String reason = 'pressable $pressable, enabled $enabled';
                final bool stop = pressable && (enabled || mode == NavigationMode.directional);

                await tester.pumpWidget(
                  _page(
                    before,
                    mode,
                    _surface(
                      pressable: pressable,
                      enabled: enabled,
                      focusNode: handed ? given : null,
                    ),
                  ),
                );
                await _tabFrom(tester, before);

                expect(_holdsFocus(tester), stop, reason: reason);
                expect(_seen!.focusVisible, stop, reason: reason);
              }
            },
          );

          testWidgets(
            'draws its ring for a keyboard and not for a pointer, on $node, ${mode.name}',
            (WidgetTester tester) async {
              final before = FocusNode(debugLabel: 'before');
              addTearDown(before.dispose);
              final given = FocusNode(debugLabel: 'given');
              addTearDown(given.dispose);

              await tester.pumpWidget(
                _page(before, mode, _surface(pressable: true, focusNode: handed ? given : null)),
              );

              await _tabFrom(tester, before);
              expect(_seen!.focusVisible, isTrue);

              // A finger on the screen: the surface keeps the focus, and the
              // ring goes until a key is pressed again.
              await tester.tap(find.byKey(_subject));
              await tester.pump();

              expect(_holdsFocus(tester), isTrue);
              expect(_seen!.focusVisible, isFalse);

              await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
              await tester.pump();

              expect(_seen!.focusVisible, isTrue);

              // Given the focus while the reader is using a pointer.
              await tester.tap(find.byKey(_subject));
              before.requestFocus();
              await tester.pump();
              _nodeOf(tester).requestFocus();
              await tester.pump();

              expect(_holdsFocus(tester), isTrue);
              expect(_seen!.focusVisible, isFalse);
            },
          );
        }
      }
    });

    group('semantics', () {
      testWidgets('adds no node round the component\'s own, available or not', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        const Key outer = ValueKey<String>('outer');

        for (final bool enabled in <bool>[true, false, true]) {
          // A parent that keeps its children apart makes a node of anything
          // said inside it, so an annotation of the surface's own would be an
          // empty node wrapped round the one the component made.
          await tester.pumpWidget(
            host(
              Semantics(
                key: outer,
                container: true,
                explicitChildNodes: true,
                child: PlassInteractive(
                  onTap: () {},
                  enabled: enabled,
                  interactive: enabled,
                  pressable: enabled,
                  builder: (BuildContext context, PlassInteraction state) {
                    return Semantics(
                      container: true,
                      button: true,
                      label: 'Surface',
                      child: const SizedBox.square(dimension: 40),
                    );
                  },
                ),
              ),
            ),
          );

          final List<SemanticsNode> children = <SemanticsNode>[];
          tester.getSemantics(find.byKey(outer)).visitChildren((SemanticsNode child) {
            children.add(child);
            return true;
          });

          expect(children, hasLength(1), reason: 'enabled $enabled');
          expect(children.single.label, 'Surface', reason: 'enabled $enabled');
        }

        handle.dispose();
      });
    });

    group('a handed node', () {
      testWidgets('is given back as the caller set it once the surface lets go of it', (
        WidgetTester tester,
      ) async {
        final before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);
        final given = FocusNode(debugLabel: 'given');
        addTearDown(given.dispose);

        Widget page(Widget child) => _page(before, NavigationMode.traditional, child);

        await tester.pumpWidget(page(_surface(pressable: false, focusNode: given)));
        expect(given.canRequestFocus, isFalse);

        // Swapped for the surface's own node.
        await tester.pumpWidget(page(_surface(pressable: false)));
        expect(given.canRequestFocus, isTrue);

        await tester.pumpWidget(page(_surface(pressable: true, enabled: false, focusNode: given)));
        expect(given.canRequestFocus, isFalse);

        // Swapped for another handed node.
        final other = FocusNode(debugLabel: 'other');
        addTearDown(other.dispose);

        await tester.pumpWidget(page(_surface(pressable: true, enabled: false, focusNode: other)));
        expect(given.canRequestFocus, isTrue);
        expect(other.canRequestFocus, isFalse);

        // The surface gone.
        await tester.pumpWidget(page(const SizedBox()));
        expect(other.canRequestFocus, isTrue);

        // A node its caller keeps from the focus: the surface decides while it
        // holds it, and the caller's word stands again once it lets go.
        given.canRequestFocus = false;

        await tester.pumpWidget(page(_surface(pressable: true, focusNode: given)));
        expect(given.canRequestFocus, isTrue);

        await tester.pumpWidget(page(const SizedBox()));
        expect(given.canRequestFocus, isFalse);
      });

      testWidgets('is given back only once the last surface holding it lets go', (
        WidgetTester tester,
      ) async {
        final before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);
        final given = FocusNode(debugLabel: 'given');
        addTearDown(given.dispose);

        Widget page(Key key, {required bool enabled}) {
          return _page(
            before,
            NavigationMode.traditional,
            _surface(key: key, pressable: true, enabled: enabled, focusNode: given),
          );
        }

        await tester.pumpWidget(page(const ValueKey<int>(1), enabled: false));
        expect(given.canRequestFocus, isFalse);

        // A new surface takes the node before the old one lets go of it. The
        // old one must not give it back over the new one's decision, and the
        // new one must not take what the old one decided for the caller's.
        await tester.pumpWidget(page(const ValueKey<int>(2), enabled: false));
        expect(given.canRequestFocus, isFalse);

        await tester.pumpWidget(page(const ValueKey<int>(2), enabled: true));
        expect(given.canRequestFocus, isTrue);

        await tester.pumpWidget(page(const ValueKey<int>(3), enabled: false));
        expect(given.canRequestFocus, isFalse);

        await tester.pumpWidget(_page(before, NavigationMode.traditional, const SizedBox()));
        expect(given.canRequestFocus, isTrue);
      });

      testWidgets('is not given back as the focus a node above it had kept from it', (
        WidgetTester tester,
      ) async {
        final given = FocusNode(debugLabel: 'given');
        addTearDown(given.dispose);

        // The node is still under the `ExcludeFocus` as the surface takes it,
        // where it reads as unable to take the focus whatever it says itself.
        await tester.pumpWidget(
          host(
            ExcludeFocus(
              child: Focus(focusNode: given, child: const SizedBox.square(dimension: 40)),
            ),
          ),
        );
        expect(given.canRequestFocus, isFalse);

        await tester.pumpWidget(host(_surface(pressable: true, enabled: false, focusNode: given)));
        expect(given.canRequestFocus, isFalse);

        await tester.pumpWidget(host(const SizedBox()));
        expect(given.canRequestFocus, isTrue);
      });
    });
  });
}
