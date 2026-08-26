import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

const List<PlBottomNavigationItem<String>> _items = <PlBottomNavigationItem<String>>[
  PlBottomNavigationItem<String>(
    value: 'home',
    label: 'Home',
    icon: SizedBox(key: ValueKey<String>('home-glyph'), width: 16, height: 16),
  ),
  PlBottomNavigationItem<String>(value: 'search', label: 'Search'),
  PlBottomNavigationItem<String>(value: 'account', label: 'Account'),
];

/// A bar wired to a variable, which is how every caller uses it.
class _Harness extends StatefulWidget {
  const _Harness({
    this.labels = PlBottomNavigationLabels.all,
    this.disabled = false,
    this.items = _items,
  });

  final PlBottomNavigationLabels labels;
  final bool disabled;
  final List<PlBottomNavigationItem<String>> items;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  String? _value = 'home';

  String? get value => _value;

  @override
  Widget build(BuildContext context) {
    return PlBottomNavigation<String>(
      items: widget.items,
      value: _value,
      labels: widget.labels,
      disabled: widget.disabled,
      onChanged: (String next) => setState(() => _value = next),
    );
  }
}

/// A home indicator of a stated height.
///
/// `host` owns the `MediaQuery` a Plass widget reads, so a test about the safe
/// area has to add its inset underneath that one rather than around it.
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

void main() {
  group('PlBottomNavigation', () {
    group('the bar', () {
      testWidgets('draws one destination per item', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlBottomNavigation<String>(items: _items, value: 'home'), width: 360),
        );

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Search'), findsOneWidget);
        expect(find.text('Account'), findsOneWidget);
      });

      testWidgets('draws the glyph it was given', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlBottomNavigation<String>(items: _items, value: 'home'), width: 360),
        );

        expect(find.byKey(const ValueKey<String>('home-glyph')), findsOneWidget);
      });

      testWidgets('is named as one group', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            const PlBottomNavigation<String>(items: _items, value: 'home', label: 'Main'),
            width: 360,
          ),
        );

        expect(find.bySemanticsLabel('Main'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('keeps the sheet running to the bottom of the screen', (
        WidgetTester tester,
      ) async {
        const double indicator = 34;

        await tester.pumpWidget(
          host(
            const _Indicator(
              inset: indicator,
              child: PlBottomNavigation<String>(items: _items, value: 'home'),
            ),
            width: 360,
          ),
        );

        final double tall = tester.getSize(find.byType(PlBottomNavigation<String>)).height;

        await tester.pumpWidget(
          host(
            const _Indicator(
              inset: indicator,
              child: PlBottomNavigation<String>(items: _items, value: 'home', safeArea: false),
            ),
            width: 360,
          ),
        );

        // The whole difference is the inset, and it is inside the sheet: the
        // glass keeps reaching the bottom of the screen either way.
        expect(tall - tester.getSize(find.byType(PlBottomNavigation<String>)).height, indicator);
      });
    });

    group('choosing', () {
      testWidgets('reports the destination that was pressed', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(), width: 360));

        await tester.tap(find.text('Search'));
        await tester.pump();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 'search');
      });

      testWidgets('says which destination the reader is on', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(const PlBottomNavigation<String>(items: _items, value: 'search'), width: 360),
        );

        expect(
          tester.getSemantics(find.bySemanticsLabel('Search')),
          isSemantics(label: 'Search', isSelected: true, isButton: true),
        );

        handle.dispose();
      });

      testWidgets('stays where it is with no callback at all', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlBottomNavigation<String>(items: _items, value: 'home'), width: 360),
        );

        await tester.tap(find.text('Search'));
        await tester.pump();

        // Nothing to change it: a frozen bar is a bar the app is driving from
        // somewhere else.
        expect(find.text('Search'), findsOneWidget);
      });

      testWidgets('does not answer an unavailable destination', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const _Harness(
              items: <PlBottomNavigationItem<String>>[
                PlBottomNavigationItem<String>(value: 'home', label: 'Home'),
                PlBottomNavigationItem<String>(value: 'search', label: 'Search', disabled: true),
              ],
            ),
            width: 360,
          ),
        );

        await tester.tap(find.text('Search'));
        await tester.pump();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 'home');
      });

      testWidgets('goes unavailable with the whole bar', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(disabled: true), width: 360));

        await tester.tap(find.text('Search'));
        await tester.pump();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 'home');
        expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.5);
      });
    });

    group('labels', () {
      testWidgets('names every destination by default', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(), width: 360));

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Search'), findsOneWidget);
      });

      testWidgets('draws only the current one when it is asked to', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const _Harness(labels: PlBottomNavigationLabels.selected), width: 360),
        );

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Search'), findsNothing);
      });

      testWidgets('draws none of them when it is asked to', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const _Harness(labels: PlBottomNavigationLabels.none), width: 360),
        );

        expect(find.text('Home'), findsNothing);
      });

      testWidgets('keeps every name readable with none of them drawn', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(const _Harness(labels: PlBottomNavigationLabels.none), width: 360),
        );

        // Undrawn is not unsaid.
        expect(find.bySemanticsLabel('Search'), findsOneWidget);

        handle.dispose();
      });
    });
  });
}
