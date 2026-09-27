import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/icons.dart';

import '../../support/host.dart';

/// Content with a `State` of its own: built again from scratch, it is a
/// different object, where a picture would have been decoded again.
class _Probe extends StatefulWidget {
  const _Probe(this.text);

  final String text;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => Text(widget.text);
}

/// Whether the focus is on something inside the trail.
bool _holdsFocus(WidgetTester tester) {
  final BuildContext? focused = FocusManager.instance.primaryFocus?.context;

  return focused != null &&
      find
          .descendant(
            of: find.byType(PlBreadcrumb),
            matching: find.byElementPredicate((Element element) => element == focused),
          )
          .evaluate()
          .isNotEmpty;
}

/// Moves the focus to [before] and presses Tab once, as a keyboard reader
/// arriving at the trail does.
Future<void> _tabFrom(WidgetTester tester, FocusNode before) async {
  before.requestFocus();
  await tester.pump();
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pump();
}

List<PlBreadcrumbItem> trail(int steps) {
  return <PlBreadcrumbItem>[
    for (var index = 0; index < steps; index += 1)
      PlBreadcrumbItem(label: Text('Step $index'), onPressed: () {}),
  ];
}

void main() {
  group('PlBreadcrumb', () {
    group('rendering', () {
      testWidgets('draws every step', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlBreadcrumb(items: trail(3)), width: 480));

        for (var index = 0; index < 3; index += 1) {
          expect(find.text('Step $index'), findsOneWidget);
        }
      });

      testWidgets('draws a mark between two steps and not before the first', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(PlBreadcrumb(items: trail(3)), width: 480));

        expect(find.byType(PlassGlyph), findsNWidgets(2));
      });

      testWidgets('takes a mark of its own', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(PlBreadcrumb(items: trail(3), separator: PlBreadcrumbSeparator.slash), width: 480),
        );

        expect(find.text('/'), findsNWidgets(2));
      });
    });

    group('the current step', () {
      testWidgets('is the last one, and stops answering', (WidgetTester tester) async {
        var pressed = 0;
        await tester.pumpWidget(
          host(
            PlBreadcrumb(
              items: <PlBreadcrumbItem>[
                PlBreadcrumbItem(label: const Text('Home'), onPressed: () {}),
                PlBreadcrumbItem(label: const Text('Billing'), onPressed: () => pressed += 1),
              ],
            ),
            width: 480,
          ),
        );

        await tester.tap(find.text('Billing'));
        expect(pressed, 0);
      });

      testWidgets('moves when a step claims it', (WidgetTester tester) async {
        var pressed = 0;
        await tester.pumpWidget(
          host(
            PlBreadcrumb(
              items: <PlBreadcrumbItem>[
                const PlBreadcrumbItem(label: Text('Home'), current: true),
                PlBreadcrumbItem(label: const Text('Billing'), onPressed: () => pressed += 1),
              ],
            ),
            width: 480,
          ),
        );

        await tester.tap(find.text('Billing'));
        expect(pressed, 1);
      });

      testWidgets('is announced as the place the reader is', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            PlBreadcrumb(
              items: <PlBreadcrumbItem>[
                PlBreadcrumbItem(label: const Text('Home'), onPressed: () {}),
                const PlBreadcrumbItem(label: Text('Billing')),
              ],
            ),
            width: 480,
          ),
        );

        expect(tester.getSemantics(find.text('Billing')), isSemantics(isHeader: true));
        handle.dispose();
      });
    });

    group('folding', () {
      testWidgets('folds the middle away past maxItems', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlBreadcrumb(items: trail(6), maxItems: 3), width: 640));

        expect(find.text('Step 0'), findsOneWidget);
        expect(find.text('Step 5'), findsOneWidget);
        expect(find.text('Step 2'), findsNothing);
      });

      testWidgets('does not fold when the fold would remove one step', (WidgetTester tester) async {
        await tester.pumpWidget(host(PlBreadcrumb(items: trail(3), maxItems: 2), width: 640));

        expect(find.text('Step 1'), findsOneWidget);
      });

      testWidgets('unfolds in place when the mark is pressed', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(PlBreadcrumb(items: trail(6), maxItems: 3), width: 640));

        await tester.tap(find.bySemanticsLabel('Show the hidden steps'));
        await tester.pump();

        expect(find.text('Step 2'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('leaves the fold as a plain mark when it is not expandable', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(PlBreadcrumb(items: trail(6), maxItems: 3, expandable: false), width: 640),
        );

        expect(find.bySemanticsLabel('Show the hidden steps'), findsNothing);
        handle.dispose();
      });
    });

    group('accessibility', () {
      testWidgets('names the trail', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(PlBreadcrumb(items: trail(2)), width: 480));

        expect(find.bySemanticsLabel('Breadcrumb'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('a step that goes somewhere is a link', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(PlBreadcrumb(items: trail(2)), width: 480));

        expect(tester.getSemantics(find.text('Step 0')), isSemantics(isLink: true));
        handle.dispose();
      });
    });

    group('a step that changes what it does', () {
      testWidgets('keeps what it holds as it gets onPressed, becomes current or is disabled', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        final before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);

        Widget trail({bool pressable = false, bool current = false, bool disabled = false}) {
          return host(
            afterFocusStop(
              before,
              PlBreadcrumb(
                items: <PlBreadcrumbItem>[
                  PlBreadcrumbItem(
                    label: const _Probe('Settings'),
                    startIcon: const _Probe('S'),
                    endIcon: const _Probe('E'),
                    onPressed: pressable ? () {} : null,
                    current: current ? true : null,
                    disabled: disabled,
                  ),
                  const PlBreadcrumbItem(label: Text('Billing')),
                ],
              ),
            ),
            width: 480,
          );
        }

        await tester.pumpWidget(trail());

        final List<State<_Probe>> resting = tester
            .stateList<State<_Probe>>(find.byType(_Probe))
            .toList();

        expect(resting, hasLength(3));

        // Every way a step can stop being followable, and back.
        for (final (bool pressable, bool current, bool disabled) in <(bool, bool, bool)>[
          (true, false, false),
          (true, true, false),
          (true, false, false),
          (true, false, true),
          (true, false, false),
          (false, true, false),
          (false, false, true),
          (false, false, false),
        ]) {
          final String reason = 'pressable $pressable, current $current, disabled $disabled';
          final bool interactive = pressable && !current && !disabled;

          await tester.pumpWidget(
            trail(pressable: pressable, current: current, disabled: disabled),
          );

          // Built again from scratch, a probe is a different object, and a
          // picture in its place would have been decoded again.
          final List<State<_Probe>> now = tester
              .stateList<State<_Probe>>(find.byType(_Probe))
              .toList();

          for (var index = 0; index < resting.length; index += 1) {
            expect(now[index], same(resting[index]), reason: 'probe $index, $reason');
          }

          // A link with its tap only while it can be followed, and otherwise
          // plain text that says whether it is the page and whether it is
          // available, as it always said.
          expect(
            tester.getSemantics(find.text('Settings')),
            interactive
                ? isSemantics(isLink: true, hasTapAction: true, hasEnabledState: false)
                : isSemantics(
                    isLink: false,
                    hasTapAction: false,
                    isHeader: current,
                    hasEnabledState: true,
                    isEnabled: !disabled,
                  ),
            reason: reason,
          );

          await _tabFrom(tester, before);

          expect(_holdsFocus(tester), interactive, reason: reason);
        }

        handle.dispose();
      });

      testWidgets('is not a focus stop while it cannot be followed, on a remote either', (
        WidgetTester tester,
      ) async {
        final before = FocusNode(debugLabel: 'before');
        addTearDown(before.dispose);

        // Directional navigation is where an unavailable control is still a
        // stop, so a reader can find it. A step that cannot be followed was
        // never one: plain text, the page the reader is on, or disabled.
        for (final PlBreadcrumbItem step in <PlBreadcrumbItem>[
          const PlBreadcrumbItem(label: Text('Settings'), current: false),
          PlBreadcrumbItem(label: const Text('Settings'), onPressed: () {}, current: true),
          PlBreadcrumbItem(label: const Text('Settings'), onPressed: () {}, disabled: true),
        ]) {
          await tester.pumpWidget(
            host(
              MediaQuery(
                data: const MediaQueryData(navigationMode: NavigationMode.directional),
                child: afterFocusStop(
                  before,
                  PlBreadcrumb(
                    items: <PlBreadcrumbItem>[
                      step,
                      const PlBreadcrumbItem(label: Text('Billing')),
                    ],
                  ),
                ),
              ),
              width: 480,
            ),
          );

          await _tabFrom(tester, before);

          expect(_holdsFocus(tester), isFalse);
        }
      });
    });
  });
}
