import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/scales.dart';

import '../../support/host.dart';

/// A page with three headings in it and a table of contents beside them.
class _Page extends StatefulWidget {
  const _Page({this.offset = 0, this.active = -1, this.onSelect, this.short = false});

  final double offset;
  final int active;
  final ValueChanged<PlAnchorItem>? onSelect;

  /// A page with nothing to scroll, for the rule about a screen that fits.
  final bool short;

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> {
  final ScrollController _scroll = ScrollController();
  final List<GlobalKey> _keys = <GlobalKey>[GlobalKey(), GlobalKey(), GlobalKey()];
  late final List<PlAnchorItem> _items = <PlAnchorItem>[
    PlAnchorItem(target: _keys[0], label: const Text('One')),
    PlAnchorItem(target: _keys[1], label: const Text('Two'), depth: 1),
    PlAnchorItem(target: _keys[2], label: const Text('Three')),
  ];

  ScrollController get scroll => _scroll;
  List<PlAnchorItem> get items => _items;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: 500,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 160,
            child: PlAnchor(
              controller: _scroll,
              items: _items,
              offset: widget.offset,
              active: widget.active >= 0 ? _items[widget.active] : null,
              onSelect: widget.onSelect,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              child: Column(
                children: <Widget>[
                  SizedBox(height: widget.short ? 500 : 400),
                  SizedBox(key: _keys[0], height: 30, child: const Text('H One')),
                  if (!widget.short) ...<Widget>[
                    const SizedBox(height: 600),
                    SizedBox(key: _keys[1], height: 30, child: const Text('H Two')),
                    const SizedBox(height: 600),
                    SizedBox(key: _keys[2], height: 30, child: const Text('H Three')),
                    const SizedBox(height: 600),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(host(child));
  await tester.pumpAndSettle();
}

_PageState _state(WidgetTester tester) => tester.state<_PageState>(find.byType(_Page));

/// Which row is lit, by the text on it.
String? _lit(WidgetTester tester) {
  for (final String label in <String>['One', 'Two', 'Three']) {
    final SemanticsNode node = tester.getSemantics(
      find.descendant(of: find.byType(PlAnchor), matching: find.text(label)),
    );

    if (node.getSemanticsData().flagsCollection.isSelected == Tristate.isTrue) {
      return label;
    }
  }

  return null;
}

Future<void> _scrollTo(WidgetTester tester, double offset) async {
  _state(tester).scroll.jumpTo(offset);
  await tester.pumpAndSettle();
}

void main() {
  group('PlAnchor', () {
    group('the list', () {
      testWidgets('draws one row per heading, in document order', (WidgetTester tester) async {
        await _pump(tester, const _Page());

        expect(
          find.descendant(of: find.byType(PlAnchor), matching: find.byType(Text)),
          findsNWidgets(3),
        );
      });

      testWidgets('indents by depth rather than nesting', (WidgetTester tester) async {
        await _pump(tester, const _Page());

        final double first = tester
            .getTopLeft(find.descendant(of: find.byType(PlAnchor), matching: find.text('One')))
            .dx;
        final double second = tester
            .getTopLeft(find.descendant(of: find.byType(PlAnchor), matching: find.text('Two')))
            .dx;

        // Real documents skip levels, so a nesting built from a flat list is a
        // guess at a shape nobody wrote.
        expect(second - first, 12);
      });

      testWidgets('keeps the words above its list out of its name, and out of the outline', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(
          tester,
          PlAnchor(
            semanticLabel: 'Contents',
            label: const Text('On this page'),
            items: <PlAnchorItem>[PlAnchorItem(target: GlobalKey(), label: const Text('Intro'))],
          ),
        );

        // The list is named "Contents" and the words above it are a node of
        // their own inside it, as the words inside the React `<nav>` are, and
        // not a heading, as the React `<span>` is not one. Merged, the two ran
        // together as one name.
        expect(
          semanticsNodeLabelled(tester, 'Contents'),
          isSemantics(label: 'Contents', isHeader: false),
        );
        expect(
          semanticsNodeLabelled(tester, 'On this page'),
          isSemantics(label: 'On this page', isHeader: false),
        );

        handle.dispose();
      });

      testWidgets('says on each row\'s own node that it can take the focus', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(
          tester,
          PlAnchor(
            items: <PlAnchorItem>[
              PlAnchorItem(target: GlobalKey(), label: const Text('Intro')),
              PlAnchorItem(target: GlobalKey(), label: const Text('Usage')),
            ],
          ),
        );

        // Beside the link and its tap on the node that names the row, and on
        // no node round it.
        for (final String label in <String>['Intro', 'Usage']) {
          expect(
            semanticsNodeLabelled(tester, label),
            isSemantics(
              label: label,
              isLink: true,
              isFocusable: true,
              hasTapAction: true,
              hasFocusAction: true,
            ),
            reason: label,
          );
        }

        expect(find.semantics.byFlag(SemanticsFlag.isFocusable), findsExactly(2));

        handle.dispose();
      });

      testWidgets('draws the focus ring round a row only while the keyboard has it there', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);
        addTearDown(
          () => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic,
        );

        await _pump(
          tester,
          afterFocusStop(
            before,
            PlAnchor(
              color: PlassColor.danger,
              items: <PlAnchorItem>[
                PlAnchorItem(target: GlobalKey(), label: const Text('Intro')),
                PlAnchorItem(target: GlobalKey(), label: const Text('Usage')),
              ],
            ),
          ),
        );

        List<PlassFocusRingPainter> rings() => tester
            .widgetList<CustomPaint>(
              find.descendant(of: find.byType(PlAnchor), matching: find.byType(CustomPaint)),
            )
            .map((CustomPaint paint) => paint.foregroundPainter)
            .whereType<PlassFocusRingPainter>()
            .toList();

        Finder ringRound(String label) => find.ancestor(
          of: find.text(label),
          matching: find.byWidgetPredicate(
            (Widget widget) =>
                widget is CustomPaint && widget.foregroundPainter is PlassFocusRingPainter,
          ),
        );

        expect(rings(), isEmpty, reason: 'at rest');

        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // The house ring, flush round the row in the list's own family, as
        // the React row's `focusRingClasses` draws it.
        final PlassTokens tokens = PlassTheme.of(tester.element(find.byType(PlAnchor)));

        expect(rings(), hasLength(1));
        expect(ringRound('Intro'), findsOneWidget);
        expect(rings().single.color, tokens.family(PlassColor.danger).ring);
        expect(rings().single.borderRadius, BorderRadius.circular(tokens.radii[PlassSize.xs]!));
        expect(rings().single.offset, focusRingOffset);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(rings(), hasLength(1));
        expect(ringRound('Usage'), findsOneWidget);

        // The row keeps the focus; a touch screen draws no ring round it.
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTouch;
        await tester.pump();

        expect(rings(), isEmpty, reason: 'in the touch highlight mode');
      });
    });

    group('the tracking', () {
      testWidgets('lights nothing above the first heading', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, const _Page());

        expect(_lit(tester), isNull);

        handle.dispose();
      });

      testWidgets('lights the last heading whose top has passed the line', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, const _Page());

        await _scrollTo(tester, 420);
        expect(_lit(tester), 'One');

        await _scrollTo(tester, 1100);
        expect(_lit(tester), 'Two');

        handle.dispose();
      });

      testWidgets('lights the one above while the next is still on screen', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, const _Page());

        // Two headings visible at once. The one being read is the higher of
        // them, which is already above the reader.
        await _scrollTo(tester, 900);

        expect(_lit(tester), 'One');

        handle.dispose();
      });

      testWidgets('lights the last row at the bottom, whatever the measurement says', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, const _Page());

        await _scrollTo(tester, _state(tester).scroll.position.maxScrollExtent);

        // A short final section never reaches the line, and a list that could
        // not light its own last row goes dead where a reader looks for it.
        expect(_lit(tester), 'Three');

        handle.dispose();
      });

      testWidgets('leaves a screen that fits to the measurement', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(host(const _Page(short: true)));
        await tester.pumpAndSettle();

        // A screen with nothing to scroll is always at its own bottom, and
        // lighting the last row there would say the reader had reached the end
        // before they had read anything.
        expect(_lit(tester), isNull);

        handle.dispose();
      });

      testWidgets('moves the line down by `offset`', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, const _Page(offset: 120));

        // 100 above the top with no bar over the page is not read yet; under a
        // 120 bar it has already slid out of sight.
        await _scrollTo(tester, 300);

        expect(_lit(tester), 'One');

        handle.dispose();
      });
    });

    group('taking it over', () {
      testWidgets('lights what it was told to and stops measuring', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, const _Page(active: 2));

        expect(_lit(tester), 'Three');

        await _scrollTo(tester, 420);

        expect(_lit(tester), 'Three');

        handle.dispose();
      });

      testWidgets('reports a press and moves the screen to the heading', (
        WidgetTester tester,
      ) async {
        final List<String> pressed = <String>[];

        await _pump(
          tester,
          _Page(onSelect: (PlAnchorItem item) => pressed.add((item.label as Text).data!)),
        );

        await tester.tap(find.descendant(of: find.byType(PlAnchor), matching: find.text('Two')));
        await tester.pumpAndSettle();

        expect(pressed, <String>['Two']);
        expect(_state(tester).scroll.offset, greaterThan(0));
      });

      testWidgets('stops `offset` above the heading, and jumps when animations are off', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: _Page(offset: 100),
          ),
        );

        await tester.tap(find.descendant(of: find.byType(PlAnchor), matching: find.text('Two')));
        await tester.pump();

        // "Two" starts 1030 pixels down the page: 400 of space, the first
        // heading's 30 and 600 more. One frame, and it is already there.
        expect(_state(tester).scroll.offset, 1030 - 100);
      });

      testWidgets('is a link a screen reader can follow', (WidgetTester tester) async {
        final List<String> pressed = <String>[];

        await _pump(
          tester,
          _Page(onSelect: (PlAnchorItem item) => pressed.add((item.label as Text).data!)),
        );

        tester.semantics.tap(find.semantics.byLabel('Three'));
        await tester.pumpAndSettle();

        expect(pressed, <String>['Three']);
        expect(
          tester.getSemantics(
            find.descendant(of: find.byType(PlAnchor), matching: find.text('Three')),
          ),
          isSemantics(isLink: true, hasTapAction: true),
        );
      });
    });
  });
}
