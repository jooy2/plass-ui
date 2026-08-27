import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/surface.dart';

import '../../support/host.dart';

const List<PlFloatingBottomNavigationItem<String>> _items =
    <PlFloatingBottomNavigationItem<String>>[
      PlFloatingBottomNavigationItem<String>(
        value: 'home',
        label: 'Home',
        icon: SizedBox(key: ValueKey<String>('home-glyph'), width: 16, height: 16),
      ),
      PlFloatingBottomNavigationItem<String>(value: 'search', label: 'Search'),
      PlFloatingBottomNavigationItem<String>(value: 'account', label: 'Account'),
    ];

/// A home indicator of a stated height. See the bottom-navigation suite.
class _Indicator extends StatelessWidget {
  const _Indicator({required this.inset, required this.child});

  final double inset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(padding: EdgeInsets.only(bottom: inset)),
      child: child,
    );
  }
}

/// A bar wired to a variable, which is how every caller uses it.
class _Harness extends StatefulWidget {
  const _Harness({this.disabled = false, this.items = _items});

  final bool disabled;
  final List<PlFloatingBottomNavigationItem<String>> items;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  String? _value = 'home';

  String? get value => _value;

  @override
  Widget build(BuildContext context) {
    return PlFloatingBottomNavigation<String>(
      items: widget.items,
      value: _value,
      disabled: widget.disabled,
      onChanged: (String next) => setState(() => _value = next),
    );
  }
}

void main() {
  group('PlFloatingBottomNavigation', () {
    group('the bar', () {
      testWidgets('draws no names at all', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlFloatingBottomNavigation<String>(items: _items, value: 'home'), width: 360),
        );

        expect(find.text('Home'), findsNothing);
        expect(find.text('Search'), findsNothing);
      });

      testWidgets('reads every name back all the same', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(const PlFloatingBottomNavigation<String>(items: _items, value: 'home'), width: 360),
        );

        expect(find.bySemanticsLabel('Home'), findsOneWidget);
        expect(find.bySemanticsLabel('Search'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('draws the glyph it was given', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlFloatingBottomNavigation<String>(items: _items, value: 'home'), width: 360),
        );

        expect(find.byKey(const ValueKey<String>('home-glyph')), findsOneWidget);
      });

      testWidgets('is named as one group', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            const PlFloatingBottomNavigation<String>(items: _items, value: 'home', label: 'Main'),
            width: 360,
          ),
        );

        expect(find.bySemanticsLabel('Main'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('is as wide as its capsule rather than as wide as the screen', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlFloatingBottomNavigation<String>(items: _items, value: 'home'), width: 360),
        );

        // Three 40px discs, two 6px gaps and 6px of air each side.
        expect(tester.getSize(find.byType(PlassSurfaceBox).first).width, 3 * 40 + 2 * 6 + 12);
      });

      testWidgets('holds itself off the floor', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlFloatingBottomNavigation<String>(items: _items, value: 'home'), width: 360),
        );

        final Rect bar = tester.getRect(find.byType(PlFloatingBottomNavigation<String>));
        final Rect capsule = tester.getRect(find.byType(PlassSurfaceBox).first);

        expect(bar.bottom - capsule.bottom, 16);
      });

      testWidgets('adds the home indicator to the gap under it', (WidgetTester tester) async {
        const double indicator = 34;

        await tester.pumpWidget(
          host(
            const _Indicator(
              inset: indicator,
              child: PlFloatingBottomNavigation<String>(items: _items, value: 'home'),
            ),
            width: 360,
          ),
        );

        final Rect bar = tester.getRect(find.byType(PlFloatingBottomNavigation<String>));
        final Rect capsule = tester.getRect(find.byType(PlassSurfaceBox).first);

        expect(bar.bottom - capsule.bottom, 16 + indicator);
      });
    });

    group('choosing', () {
      testWidgets('reports the destination that was pressed', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(), width: 360));

        await tester.tap(find.bySemanticsLabel('Search'));
        await tester.pump();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 'search');
      });

      testWidgets('says which destination the reader is on', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            const PlFloatingBottomNavigation<String>(items: _items, value: 'search'),
            width: 360,
          ),
        );

        expect(
          tester.getSemantics(find.bySemanticsLabel('Search')),
          isSemantics(label: 'Search', isSelected: true, isButton: true),
        );

        handle.dispose();
      });

      testWidgets('does not answer an unavailable destination', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const _Harness(
              items: <PlFloatingBottomNavigationItem<String>>[
                PlFloatingBottomNavigationItem<String>(value: 'home', label: 'Home'),
                PlFloatingBottomNavigationItem<String>(
                  value: 'search',
                  label: 'Search',
                  disabled: true,
                ),
              ],
            ),
            width: 360,
          ),
        );

        await tester.tap(find.bySemanticsLabel('Search'));
        await tester.pump();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 'home');
      });

      testWidgets('goes unavailable with the whole bar', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(disabled: true), width: 360));

        await tester.tap(find.bySemanticsLabel('Search'));
        await tester.pump();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 'home');
        expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, 0.5);
      });
    });

    group('the capsule', () {
      testWidgets('is there by default and gone with ghost', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlFloatingBottomNavigation<String>(items: _items, value: 'home'), width: 360),
        );

        final int withCapsule = find.byType(PlassSurfaceBox).evaluate().length;

        await tester.pumpWidget(
          host(
            const PlFloatingBottomNavigation<String>(
              items: _items,
              value: 'home',
              variant: PlassVariant.ghost,
            ),
            width: 360,
          ),
        );

        // One box per disc either way; the capsule is the extra one.
        expect(withCapsule - find.byType(PlassSurfaceBox).evaluate().length, 1);
      });
    });

    group('the key', () {
      /// The one box in the bar carrying the family's gradient.
      BoxDecoration keyOf(WidgetTester tester) {
        return decorationWhere(
          tester,
          find.byType(PlFloatingBottomNavigation<String>),
          (BoxDecoration decoration) => decoration.gradient != null,
        );
      }

      testWidgets('is a key of tinted glass, and only one of them', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlFloatingBottomNavigation<String>(items: _items, value: 'home'), width: 360),
        );
        await tester.pumpAndSettle();

        final Iterable<BoxDecoration> tinted = decorationsOf(
          tester,
          find.byType(PlFloatingBottomNavigation<String>),
        ).where((BoxDecoration decoration) => decoration.gradient != null);

        expect(tinted, hasLength(1));
        expect(keyOf(tester).shape, BoxShape.circle);
        expect(keyOf(tester).boxShadow, isNotEmpty);
      });

      testWidgets('is not drawn while no destination is current', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlFloatingBottomNavigation<String>(items: _items, value: null), width: 360),
        );
        await tester.pumpAndSettle();

        expect(
          decorationsOf(
            tester,
            find.byType(PlFloatingBottomNavigation<String>),
          ).where((BoxDecoration decoration) => decoration.gradient != null),
          isEmpty,
        );
      });

      testWidgets('sits under the disc it belongs to', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlFloatingBottomNavigation<String>(items: _items, value: 'search'),
            width: 360,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          tester.getRect(find.byType(AnimatedPositioned)),
          tester.getRect(find.bySemanticsLabel('Search')),
        );
      });

      testWidgets('travels to the destination that was pressed', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(), width: 360));
        await tester.pumpAndSettle();

        final Rect from = tester.getRect(find.byType(AnimatedPositioned));

        await tester.tap(find.bySemanticsLabel('Account'));
        // Two frames: the first rebuilds the row on the new value and measures
        // it, the second hands the key its new rectangle and starts it moving.
        await tester.pump();
        await tester.pump();
        // Halfway through the house duration the key is between the two discs,
        // which is the whole of what "travels" means. A fill that appeared on
        // one disc as it vanished from another would be at its destination
        // already.
        await tester.pump(PlassTokens.duration ~/ 2);

        final Rect midway = tester.getRect(find.byType(AnimatedPositioned));

        expect(midway.left, greaterThan(from.left));
        expect(midway.left, lessThan(tester.getRect(find.bySemanticsLabel('Account')).left));

        await tester.pumpAndSettle();

        expect(
          tester.getRect(find.byType(AnimatedPositioned)),
          tester.getRect(find.bySemanticsLabel('Account')),
        );
      });

      testWidgets('arrives in place rather than flying in', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlFloatingBottomNavigation<String>(items: _items, value: 'search'),
            width: 360,
          ),
        );

        // One frame past the measurement, and no settling: a key that has only
        // just mounted has nowhere to travel *from*, so the destination a bar
        // opens on is already under its own disc rather than sliding in from
        // the left edge of the capsule.
        await tester.pump();

        expect(
          tester.getRect(find.byType(AnimatedPositioned)),
          tester.getRect(find.bySemanticsLabel('Search')),
        );
      });

      testWidgets('goes out with the destination it is under', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const _Harness(
              items: <PlFloatingBottomNavigationItem<String>>[
                PlFloatingBottomNavigationItem<String>(
                  value: 'home',
                  label: 'Home',
                  disabled: true,
                ),
                PlFloatingBottomNavigationItem<String>(value: 'search', label: 'Search'),
              ],
            ),
            width: 360,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(of: find.byType(AnimatedPositioned), matching: find.byType(Opacity)),
          findsOneWidget,
        );
      });
    });
  });
}
