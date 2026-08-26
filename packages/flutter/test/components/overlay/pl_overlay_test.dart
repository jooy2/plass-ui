import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// An overlay wired to a variable, which is how every caller uses it.
class _Harness extends StatefulWidget {
  const _Harness({
    this.tone = PlOverlayTone.scrim,
    this.dismissible = false,
    this.startOpen = true,
  });

  final PlOverlayTone tone;
  final bool dismissible;
  final bool startOpen;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late bool _open = widget.startOpen;

  bool get open => _open;

  void set(bool next) => setState(() => _open = next);

  @override
  Widget build(BuildContext context) {
    return PlOverlay(
      open: _open,
      tone: widget.tone,
      dismissible: widget.dismissible,
      onOpenChanged: set,
      child: const Text('Saving your work…'),
    );
  }
}

Future<_HarnessState> _pump(WidgetTester tester, _Harness harness) async {
  await tester.pumpWidget(host(harness, overlay: true));
  await tester.pumpAndSettle();

  return tester.state<_HarnessState>(find.byType(_Harness));
}

void main() {
  group('PlOverlay', () {
    group('showing', () {
      testWidgets('draws nothing until it is open', (WidgetTester tester) async {
        await _pump(tester, const _Harness(startOpen: false));

        expect(find.text('Saving your work…'), findsNothing);
      });

      testWidgets('lifts its content over the page when it is', (WidgetTester tester) async {
        await _pump(tester, const _Harness());

        expect(find.text('Saving your work…'), findsOneWidget);
      });

      testWidgets('takes itself down again', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness());

        state.set(false);
        await tester.pumpAndSettle();

        expect(find.text('Saving your work…'), findsNothing);
      });
    });

    group('tone', () {
      testWidgets('the neutral dim is the same ink a modal puts behind itself', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const _Harness());

        final wash = tester.widgetList<ColoredBox>(find.byType(ColoredBox));

        expect(wash.map((ColoredBox box) => box.color), contains(PlassTokens.light().scrim));
      });

      testWidgets('clear paints nothing at all', (WidgetTester tester) async {
        await _pump(tester, const _Harness(tone: PlOverlayTone.clear));

        expect(find.byType(ColoredBox), findsNothing);
        expect(find.text('Saving your work…'), findsOneWidget);
      });

      testWidgets('solid is the page surface', (WidgetTester tester) async {
        await _pump(tester, const _Harness(tone: PlOverlayTone.solid));

        final wash = tester.widgetList<ColoredBox>(find.byType(ColoredBox));

        expect(wash.map((ColoredBox box) => box.color), contains(PlassTokens.light().surface));
      });
    });

    group('dismissing', () {
      testWidgets('a press outside does nothing by default', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness());

        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(state.open, isTrue);
      });

      testWidgets('and closes it when it is dismissible', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness(dismissible: true));

        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(state.open, isFalse);
      });

      testWidgets('a press on the content is not a press outside it', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness(dismissible: true));

        await tester.tap(find.text('Saving your work…'));
        await tester.pumpAndSettle();

        expect(state.open, isTrue);
      });

      testWidgets('Escape closes a dismissible overlay and not a plain one', (
        WidgetTester tester,
      ) async {
        final plain = await _pump(tester, const _Harness());

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(plain.open, isTrue);

        final state = await _pump(tester, const _Harness(dismissible: true));

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(state.open, isFalse);
      });
    });

    group('accessibility', () {
      testWidgets('the layer has a name even when it holds nothing readable', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlOverlay(open: true), overlay: true));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Overlay'), findsOneWidget);

        handle.dispose();
      });
    });
  });
}
