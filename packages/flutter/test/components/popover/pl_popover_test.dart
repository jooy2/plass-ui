import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/surface.dart';

import '../../support/host.dart';

/// A popover wired to a variable, which is how every caller uses one.
class _Harness extends StatefulWidget {
  const _Harness({
    this.startOpen = false,
    this.dismissible = true,
    this.showClose = false,
    this.arrow = false,
    this.side = PlassSide.bottom,
    this.width,
  });

  final bool startOpen;
  final bool dismissible;
  final bool showClose;
  final bool arrow;
  final PlassSide side;
  final double? width;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late bool _open = widget.startOpen;

  bool get open => _open;

  @override
  Widget build(BuildContext context) {
    return PlPopover(
      open: _open,
      onOpenChanged: (bool next) => setState(() => _open = next),
      dismissible: widget.dismissible,
      showClose: widget.showClose,
      arrow: widget.arrow,
      side: widget.side,
      width: widget.width,
      title: const Text('Effective rate'),
      description: const Text('Updated hourly'),
      trigger: PlButton(
        onPressed: () => setState(() => _open = true),
        child: const Text('Explain'),
      ),
      child: const Text('The base rate plus whatever your plan adds to it.'),
    );
  }
}

Future<_HarnessState> _pump(WidgetTester tester, _Harness harness) async {
  // No width and no height on the host: the popup is placed against its anchor,
  // and a box taller than the test window would push the anchor — and the popup
  // with it — off the bottom of the screen.
  await tester.pumpWidget(host(harness, overlay: true));
  await tester.pumpAndSettle();

  return tester.state<_HarnessState>(find.byType(_Harness));
}

void main() {
  group('PlPopover', () {
    group('opening and closing', () {
      testWidgets('draws nothing until it is open', (WidgetTester tester) async {
        await _pump(tester, const _Harness());

        expect(find.text('Explain'), findsOneWidget);
        expect(find.text('Effective rate'), findsNothing);
      });

      testWidgets('opens from its trigger', (WidgetTester tester) async {
        await _pump(tester, const _Harness());

        await tester.tap(find.text('Explain'));
        await tester.pumpAndSettle();

        expect(find.text('Effective rate'), findsOneWidget);
        expect(find.text('The base rate plus whatever your plan adds to it.'), findsOneWidget);
      });

      testWidgets('reports a press on the ×', (WidgetTester tester) async {
        await _pump(tester, const _Harness(startOpen: true, showClose: true));

        await tester.tap(find.bySemanticsLabel('Close'));
        await tester.pumpAndSettle();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).open, isFalse);
      });

      testWidgets('closes on a press outside', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness(startOpen: true));

        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(state.open, isFalse);
      });

      testWidgets('refuses a press outside when it is not dismissible', (
        WidgetTester tester,
      ) async {
        final state = await _pump(tester, const _Harness(startOpen: true, dismissible: false));

        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        // A popup that refuses to be dismissed needs a way out of its own, which
        // is why turning this off is something to be deliberate about.
        expect(state.open, isTrue);
      });
    });

    group('the popup', () {
      testWidgets('names itself as a heading and describes itself under it', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, const _Harness(startOpen: true));

        expect(
          tester.getSemantics(find.text('Effective rate')),
          isSemantics(isHeader: true, label: 'Effective rate'),
        );
        expect(find.text('Updated hourly'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('leaves the screen working behind it', (WidgetTester tester) async {
        await _pump(tester, const _Harness(startOpen: true));

        // A popover is a detail beside the screen, not instead of it: the
        // trigger is still there and still reachable.
        expect(find.text('Explain'), findsOneWidget);
      });

      testWidgets('caps its width off the size ladder', (WidgetTester tester) async {
        await _pump(tester, const _Harness(startOpen: true));

        expect(
          tester.getSize(find.text('The base rate plus whatever your plan adds to it.')).width,
          lessThanOrEqualTo(320),
        );
      });

      testWidgets('takes a cap of its own over the one size implies', (WidgetTester tester) async {
        await _pump(tester, const _Harness(startOpen: true, width: 200));

        expect(
          tester.getSize(find.text('The base rate plus whatever your plan adds to it.')).width,
          lessThanOrEqualTo(200),
        );
      });

      testWidgets('floats at the top of the ladder', (WidgetTester tester) async {
        await _pump(tester, const _Harness(startOpen: true));

        final BoxDecoration sheet = decorationWhere(
          tester,
          find
              .ancestor(of: find.text('Updated hourly'), matching: find.byType(PlassSurfaceBox))
              .last,
          (BoxDecoration decoration) => decoration.boxShadow != null,
        );

        expect(sheet.boxShadow, PlassTokens.light().elevation(plassElevationMax));
      });

      testWidgets('hangs off the edge it was asked for', (WidgetTester tester) async {
        await _pump(tester, const _Harness(startOpen: true, side: PlassSide.top));

        // Above the trigger, with room to spare — a flip only happens when the
        // side that was asked for has none, and it is a flip rather than a
        // slide: the popup never creeps along the edge it is on, which is what
        // keeps an arrow pointing at the thing it belongs to.
        expect(
          tester.getRect(find.text('Effective rate')).top,
          lessThan(tester.getRect(find.text('Explain')).top),
        );
      });

      testWidgets('draws no wedge until it is asked for one', (WidgetTester tester) async {
        await _pump(tester, const _Harness(startOpen: true));

        final int without = find.byType(CustomPaint).evaluate().length;

        // A fresh tree, because a `State` that is reused keeps the open flag it
        // already had.
        await tester.pumpWidget(const SizedBox.shrink());
        await _pump(tester, const _Harness(startOpen: true, arrow: true));

        // A tooltip is a filled plate whose wedge is the same solid colour; this
        // surface is translucent over a blurred backdrop, and a wedge past the
        // popup's own box cannot carry that backdrop with it.
        expect(find.byType(CustomPaint).evaluate().length, greaterThan(without));
      });
    });
  });
}
