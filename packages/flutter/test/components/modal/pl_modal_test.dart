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

/// A modal whose `open` its parent reads from [open], over a page with one
/// thing on it to press. The parent takes the modal out of the tree when [open]
/// holds `null`.
Widget _handedDown(
  ValueNotifier<bool?> open, {
  VoidCallback? onBehind,
  bool disableAnimations = true,
}) {
  return host(
    Column(
      children: <Widget>[
        GestureDetector(onTap: onBehind, child: const Text('Behind')),
        ValueListenableBuilder<bool?>(
          valueListenable: open,
          builder: (BuildContext context, bool? value, Widget? child) {
            if (value == null) {
              return const SizedBox.shrink();
            }

            return PlModal(open: value, title: const Text('Settings'));
          },
        ),
      ],
    ),
    disableAnimations: disableAnimations,
    overlay: true,
  );
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

      testWidgets('fades at the slow duration rather than the control one', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const _Harness());

        double opacity() {
          return tester.widget<FadeTransition>(find.byType(FadeTransition).first).opacity.value;
        }

        expect(opacity(), 1);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();
        await tester.pump(PlassTokens.duration);

        // Still travelling a whole control duration in, which is the point:
        // 150ms on a sheet the size of the window is a cut with a hint of blur
        // on it rather than a fade.
        expect(opacity(), greaterThan(0));

        await tester.pumpAndSettle();

        expect(find.text('This cannot be undone.'), findsNothing);
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

    // With no fade to wait for, the layer is closed inside the build that
    // closed it, where it cannot be taken down yet.
    group('under reduced motion', () {
      testWidgets('goes the frame after its parent closes it, and gives the page back', (
        WidgetTester tester,
      ) async {
        final ValueNotifier<bool?> open = ValueNotifier<bool?>(true);
        addTearDown(open.dispose);
        var pressed = 0;

        await tester.pumpWidget(_handedDown(open, onBehind: () => pressed += 1));
        await tester.pumpAndSettle();
        expect(find.text('Settings'), findsOneWidget);

        open.value = false;
        await tester.pump();
        await tester.pump();

        expect(find.text('Settings'), findsNothing);

        // Its backdrop goes with it rather than staying behind, unseen, over a
        // page that no longer answers.
        await tester.tap(find.text('Behind'));
        expect(pressed, 1);
      });

      testWidgets('goes as fast when it closes in the frame reduced motion turns on', (
        WidgetTester tester,
      ) async {
        final ValueNotifier<bool?> open = ValueNotifier<bool?>(true);
        addTearDown(open.dispose);

        await tester.pumpWidget(_handedDown(open, disableAnimations: false));
        await tester.pumpAndSettle();

        open.value = false;
        await tester.pumpWidget(_handedDown(open));
        await tester.pump();

        expect(find.text('Settings'), findsNothing);
      });

      testWidgets('stays up when it opens again before the frame it closed in is over', (
        WidgetTester tester,
      ) async {
        final ValueNotifier<bool?> open = ValueNotifier<bool?>(true);
        addTearDown(open.dispose);

        await tester.pumpWidget(_handedDown(open));
        await tester.pumpAndSettle();

        rebuildBeforeDeferredWork(tester, () => open.value = true);
        open.value = false;
        await tester.pump();
        await tester.pump();

        // Not taken down and put back up a frame later, which would lose what
        // the layer was holding and blink on the way.
        expect(find.text('Settings'), findsOneWidget);

        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);
      });

      testWidgets('leaves nothing to do once it leaves the tree in the frame it closed in', (
        WidgetTester tester,
      ) async {
        final ValueNotifier<bool?> open = ValueNotifier<bool?>(true);
        addTearDown(open.dispose);

        await tester.pumpWidget(_handedDown(open));
        await tester.pumpAndSettle();

        rebuildBeforeDeferredWork(tester, () => open.value = null);
        open.value = false;
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsNothing);
      });
    });

    group('accessibility', () {
      testWidgets('the heading is announced as one', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, const _Harness());

        expect(tester.getSemantics(find.text('Delete this project?')), isSemantics(isHeader: true));

        handle.dispose();
      });

      testWidgets('names the layer when it is given a label', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            const PlModal(open: true, label: 'Delete project', title: Text('Delete this project?')),
            overlay: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          semanticsNodeLabelled(tester, 'Delete project'),
          isSemantics(label: 'Delete project', scopesRoute: true, namesRoute: true),
        );

        handle.dispose();
      });

      testWidgets('keeps a full-screen sheet s header out from under the status bar', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const MediaQuery(
              data: MediaQueryData(padding: EdgeInsets.only(top: 100, bottom: 30)),
              child: PlModal(
                open: true,
                fullScreen: true,
                title: Text('Title'),
                // Taller than the screen, so the sheet runs from the top edge.
                child: SizedBox(height: 2000),
              ),
            ),
            overlay: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.getTopLeft(find.text('Title')).dy, greaterThanOrEqualTo(100));
      });

      testWidgets('ends above a soft keyboard', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const MediaQuery(
              data: MediaQueryData(viewInsets: EdgeInsets.only(bottom: 250)),
              child: PlModal(
                open: true,
                title: Text('Title'),
                actions: <Widget>[Text('Save')],
                child: SizedBox(height: 400),
              ),
            ),
            overlay: true,
          ),
        );
        await tester.pumpAndSettle();

        final double screen = tester.view.physicalSize.height / tester.view.devicePixelRatio;

        expect(tester.getBottomLeft(find.text('Save')).dy, lessThanOrEqualTo(screen - 250));
      });

      testWidgets('takes the page behind it off the semantics tree while it is open', (
        WidgetTester tester,
      ) async {
        Widget tree(bool open) {
          return host(
            Column(
              children: <Widget>[
                Semantics(
                  button: true,
                  label: 'Behind',
                  onTap: () {},
                  child: const SizedBox(width: 10, height: 10),
                ),
                PlModal(open: open, title: const Text('Title'), child: const Text('Body')),
              ],
            ),
            overlay: true,
          );
        }

        await tester.pumpWidget(tree(false));
        await tester.pumpAndSettle();
        expect(semanticsLabels(tester), contains('Behind'));

        await tester.pumpWidget(tree(true));
        await tester.pumpAndSettle();
        expect(semanticsLabels(tester), isNot(contains('Behind')));
        expect(semanticsLabels(tester), contains('Body'));

        await tester.pumpWidget(tree(false));
        await tester.pumpAndSettle();
        expect(semanticsLabels(tester), contains('Behind'));
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
