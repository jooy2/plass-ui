import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// A modal wired to a variable, which is how every caller uses it.
class _Harness extends StatefulWidget {
  const _Harness({
    this.startOpen = true,
    this.dismissible = true,
    this.showClose = true,
    this.dividers = false,
    this.withActions = false,
    this.width,
  });

  final bool startOpen;
  final bool dismissible;
  final bool showClose;
  final bool dividers;
  final bool withActions;
  final double? width;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late bool _open = widget.startOpen;

  bool get open => _open;

  @override
  Widget build(BuildContext context) {
    return PlModal(
      open: _open,
      onOpenChanged: (bool next) => setState(() => _open = next),
      dismissible: widget.dismissible,
      showClose: widget.showClose,
      dividers: widget.dividers,
      width: widget.width,
      title: const Text('Delete this project?'),
      description: const Text('Everything in it goes with it.'),
      actions: widget.withActions ? <Widget>[const Text('Cancel'), const Text('Delete')] : null,
      child: const Text('This cannot be undone.'),
    );
  }
}

Future<_HarnessState> _pump(WidgetTester tester, _Harness harness) async {
  await tester.pumpWidget(host(harness, overlay: true));
  await tester.pumpAndSettle();

  return tester.state<_HarnessState>(find.byType(_Harness));
}

void main() {
  group('PlModal', () {
    group('shapes', () {
      testWidgets('draws nothing until it is open', (WidgetTester tester) async {
        await _pump(tester, const _Harness(startOpen: false));

        expect(find.text('Delete this project?'), findsNothing);
      });

      testWidgets('lays out the heading, the body and the actions in order', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const _Harness(withActions: true));

        final title = tester.getTopLeft(find.text('Delete this project?')).dy;
        final description = tester.getTopLeft(find.text('Everything in it goes with it.')).dy;
        final body = tester.getTopLeft(find.text('This cannot be undone.')).dy;
        final actions = tester.getTopLeft(find.text('Delete')).dy;

        expect(title, lessThan(description));
        expect(description, lessThan(body));
        expect(body, lessThan(actions));
      });

      testWidgets('the actions sit against the trailing edge', (WidgetTester tester) async {
        await _pump(tester, const _Harness(withActions: true));

        final row = tester.getRect(find.byType(Wrap));
        final last = tester.getRect(find.text('Delete'));

        expect(row.right - last.right, lessThan(1));
        expect(tester.getRect(find.text('Cancel')).right, lessThan(last.left));
      });

      testWidgets('width overrides the ladder the size implies', (WidgetTester tester) async {
        await _pump(tester, const _Harness(width: 280));

        expect(tester.getSize(find.text('This cannot be undone.')).width, lessThanOrEqualTo(280));
      });

      testWidgets('scores the sheet when asked', (WidgetTester tester) async {
        await _pump(tester, const _Harness(dividers: true));

        final rules = tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .map((DecoratedBox box) => box.decoration)
            .whereType<BoxDecoration>()
            .where((BoxDecoration decoration) => decoration.border is Border)
            .map((BoxDecoration decoration) => (decoration.border! as Border).top.color);

        expect(rules, contains(PlassTokens.light().divider));
      });
    });

    group('dismissing', () {
      testWidgets('the × reports rather than acts', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        final state = await _pump(tester, const _Harness());

        await tester.tap(find.bySemanticsLabel('Close'));
        await tester.pumpAndSettle();

        expect(state.open, isFalse);
        handle.dispose();
      });

      testWidgets('there is no × when it is turned off', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, const _Harness(showClose: false));

        expect(find.bySemanticsLabel('Close'), findsNothing);
        handle.dispose();
      });

      testWidgets('Escape closes it', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness());

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(state.open, isFalse);
      });

      testWidgets('and does not when it has to be answered', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness(dismissible: false));

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(4, 4));
        await tester.pumpAndSettle();

        expect(state.open, isTrue);
      });

      testWidgets('a press on the sheet is not a press outside it', (WidgetTester tester) async {
        final state = await _pump(tester, const _Harness());

        await tester.tap(find.text('This cannot be undone.'));
        await tester.pumpAndSettle();

        expect(state.open, isTrue);
      });
    });

    group('accessibility', () {
      testWidgets('the heading is announced as one', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, const _Harness());

        expect(tester.getSemantics(find.text('Delete this project?')), isSemantics(isHeader: true));

        handle.dispose();
      });

      testWidgets('focus goes into the sheet and comes back out again', (
        WidgetTester tester,
      ) async {
        final outside = FocusNode();
        addTearDown(outside.dispose);

        Widget tree(bool open) {
          return host(
            Column(
              children: <Widget>[
                Focus(focusNode: outside, child: const SizedBox(width: 10, height: 10)),
                PlModal(open: open, title: const Text('Title'), child: const Text('Body')),
              ],
            ),
            overlay: true,
          );
        }

        await tester.pumpWidget(tree(false));
        outside.requestFocus();
        await tester.pump();
        expect(outside.hasPrimaryFocus, isTrue);

        await tester.pumpWidget(tree(true));
        await tester.pumpAndSettle();
        expect(outside.hasPrimaryFocus, isFalse);

        await tester.pumpWidget(tree(false));
        await tester.pumpAndSettle();
        expect(outside.hasPrimaryFocus, isTrue);
      });
    });
  });
}
