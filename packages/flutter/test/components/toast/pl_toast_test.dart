import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/disposal.dart';
import '../../support/host.dart';

/// A provider with a button under it that raises whatever it was handed.
Widget _app({
  PlToastPosition position = PlToastPosition.bottomEnd,
  Duration timeout = const Duration(seconds: 5),
  int limit = 3,
  required List<PlToast> messages,
}) {
  return host(
    PlToastProvider(
      position: position,
      timeout: timeout,
      limit: limit,
      child: Builder(
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              for (final message in messages) {
                PlToastProvider.of(context).show(message);
              }
            },
            child: const SizedBox(width: 200, height: 60, child: Text('Raise')),
          );
        },
      ),
    ),
    width: 600,
    height: 500,
  );
}

/// Puts the keyboard focus on the control that draws [text].
///
/// Directly rather than with a `Tab` key: the test host is deliberately not a
/// `WidgetsApp`, so nothing has installed the traversal shortcuts.
void _focus(WidgetTester tester, String text) {
  Focus.of(tester.element(find.text(text))).requestFocus();
}

Future<void> _raise(WidgetTester tester) async {
  await tester.tap(find.text('Raise'));
  await tester.pumpAndSettle();
}

/// Pumps a provider with nothing under it, under [tokens] when there are any,
/// and hands back its controller.
Future<PlToastController> _provider(WidgetTester tester, {PlassTokens? tokens}) async {
  late PlToastController controller;
  final Widget provider = PlToastProvider(
    child: Builder(
      builder: (BuildContext context) {
        controller = PlToastProvider.of(context);

        return const SizedBox.shrink();
      },
    ),
  );

  await tester.pumpWidget(
    host(
      tokens == null ? provider : PlassTheme.tokens(tokens: tokens, child: provider),
      width: 600,
      height: 500,
    ),
  );

  return controller;
}

/// A title with a `State` of its own, so a test can tell a toast that was kept
/// from one that was built again.
class _Kept extends StatefulWidget {
  const _Kept(this.label);

  final String label;

  @override
  State<_Kept> createState() => _KeptState();
}

class _KeptState extends State<_Kept> {
  @override
  Widget build(BuildContext context) => Text(widget.label);
}

void main() {
  group('PlToast', () {
    group('raising', () {
      testWidgets('a message appears and says what it was given', (WidgetTester tester) async {
        await tester.pumpWidget(_app(messages: const <PlToast>[PlToast(title: Text('Saved'))]));

        expect(find.text('Saved'), findsNothing);
        await _raise(tester);
        expect(find.text('Saved'), findsOneWidget);
      });

      testWidgets('keeps a top stack out from under the status bar', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            MediaQuery(
              data: const MediaQueryData(padding: EdgeInsets.only(top: 40)),
              child: PlToastProvider(
                position: PlToastPosition.topEnd,
                child: Builder(
                  builder: (BuildContext context) => GestureDetector(
                    onTap: () =>
                        PlToastProvider.of(context).show(const PlToast(title: Text('Saved'))),
                    child: const SizedBox(width: 200, height: 60, child: Text('Raise')),
                  ),
                ),
              ),
            ),
            width: 600,
            height: 500,
          ),
        );
        await _raise(tester);

        final double top = tester.getTopLeft(find.byType(PlToastProvider)).dy;

        // The inset, then the status bar, then the plate's own padding.
        expect(tester.getTopLeft(find.text('Saved')).dy - top, greaterThanOrEqualTo(16 + 40));
      });

      testWidgets('takes itself away when its time is up', (WidgetTester tester) async {
        await tester.pumpWidget(
          _app(
            timeout: const Duration(seconds: 2),
            messages: const <PlToast>[PlToast(title: Text('Saved'))],
          ),
        );

        await _raise(tester);
        expect(find.text('Saved'), findsOneWidget);

        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(find.text('Saved'), findsNothing);
      });

      testWidgets('and stays until it is closed when it has no clock', (WidgetTester tester) async {
        await tester.pumpWidget(
          _app(
            timeout: Duration.zero,
            messages: const <PlToast>[PlToast(title: Text('Confirm this'))],
          ),
        );

        await _raise(tester);
        await tester.pump(const Duration(seconds: 30));
        await tester.pumpAndSettle();

        expect(find.text('Confirm this'), findsOneWidget);
      });

      testWidgets('shows only as many as the limit allows', (WidgetTester tester) async {
        await tester.pumpWidget(
          _app(
            limit: 2,
            timeout: Duration.zero,
            messages: const <PlToast>[
              PlToast(title: Text('One')),
              PlToast(title: Text('Two')),
              PlToast(title: Text('Three')),
            ],
          ),
        );

        await _raise(tester);

        expect(find.text('One'), findsOneWidget);
        expect(find.text('Two'), findsOneWidget);
        expect(find.text('Three'), findsNothing);
      });

      testWidgets('and shows the rest as the stack drains', (WidgetTester tester) async {
        await tester.pumpWidget(
          _app(
            limit: 1,
            timeout: const Duration(seconds: 2),
            messages: const <PlToast>[
              PlToast(title: Text('One')),
              PlToast(title: Text('Two')),
            ],
          ),
        );

        await _raise(tester);
        expect(find.text('Two'), findsNothing);

        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(find.text('One'), findsNothing);
        expect(find.text('Two'), findsOneWidget);
      });
    });

    group('closing', () {
      testWidgets('the × takes it away and reports it', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        var closed = 0;
        await tester.pumpWidget(
          _app(
            timeout: Duration.zero,
            messages: <PlToast>[PlToast(title: const Text('Saved'), onClose: () => closed += 1)],
          ),
        );

        await _raise(tester);
        await tester.tap(find.bySemanticsLabel('Close'));
        await tester.pumpAndSettle();

        expect(find.text('Saved'), findsNothing);
        expect(closed, 1);
        handle.dispose();
      });

      testWidgets('a toast closed as another arrives is closed once, and nothing throws later', (
        WidgetTester tester,
      ) async {
        late PlToastController controller;
        var closed = 0;

        await tester.pumpWidget(
          host(
            PlToastProvider(
              child: Builder(
                builder: (BuildContext context) {
                  controller = PlToastProvider.of(context);

                  return const SizedBox.shrink();
                },
              ),
            ),
            width: 600,
            height: 500,
          ),
        );

        controller.show(PlToast(id: 'a', title: const Text('First'), onClose: () => closed += 1));
        controller.show(const PlToast(id: 'b', title: Text('Second')));
        await tester.pumpAndSettle();

        // Closed, and a new toast raised while the first is still fading out,
        // which is what hands every toast on the stack its clock again.
        controller.close('a');
        await tester.pump(const Duration(milliseconds: 50));
        controller.show(const PlToast(id: 'c', title: Text('Third')));
        await tester.pumpAndSettle();

        await tester.pump(const Duration(seconds: 6));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(closed, 1);
      });

      testWidgets('the action fires and takes the toast with it', (WidgetTester tester) async {
        var undone = 0;
        await tester.pumpWidget(
          _app(
            timeout: Duration.zero,
            messages: <PlToast>[
              PlToast(
                title: const Text('Deleted'),
                actionLabel: const Text('Undo'),
                onAction: () => undone += 1,
              ),
            ],
          ),
        );

        await _raise(tester);
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        expect(undone, 1);
        expect(find.text('Deleted'), findsNothing);
      });

      testWidgets('a toast keeps its state when the one above it leaves', (
        WidgetTester tester,
      ) async {
        final PlToastController controller = await _provider(tester);

        controller.show(const PlToast(id: 'a', title: _Kept('First'), timeout: Duration.zero));
        controller.show(const PlToast(id: 'b', title: _Kept('Second'), timeout: Duration.zero));
        await tester.pumpAndSettle();

        // A bottom stack reads oldest first, so the first is drawn above.
        expect(
          tester.getTopLeft(find.text('First')).dy,
          lessThan(tester.getTopLeft(find.text('Second')).dy),
        );
        final State second = tester.state(find.widgetWithText(_Kept, 'Second'));

        controller.close('a');
        await tester.pumpAndSettle();

        expect(find.text('First'), findsNothing);
        expect(tester.state(find.widgetWithText(_Kept, 'Second')), same(second));
      });

      testWidgets('lets go of the curve a toast fades on', (WidgetTester tester) async {
        // One toast closed and one still up when the provider leaves, which are
        // the two ways a toast's fade is let go of.
        final curves = await disposalOf(tester, 'CurvedAnimation', () async {
          final PlToastController controller = await _provider(tester);

          controller.show(const PlToast(id: 'a', title: Text('Gone'), timeout: Duration.zero));
          controller.show(const PlToast(id: 'b', title: Text('Kept'), timeout: Duration.zero));
          await tester.pumpAndSettle();
          controller.close('a');
          await tester.pumpAndSettle();
        });

        expect(curves.made, greaterThan(0));
        expect(curves.kept, 0);
      });
    });

    group('fading', () {
      testWidgets("runs in and out on the theme's curve", (WidgetTester tester) async {
        const Duration duration = Duration(seconds: 1);
        const Curve steep = Curves.easeInCubic;
        final PlToastController controller = await _provider(
          tester,
          tokens: PlassTokens.light().copyWith(motionDuration: duration, motionEase: steep),
        );

        double opacity() {
          return tester
              .widgetList<FadeTransition>(
                find.ancestor(of: find.text('Saved'), matching: find.byType(FadeTransition)),
              )
              .first
              .opacity
              .value;
        }

        controller.show(const PlToast(id: 'saved', title: Text('Saved'), timeout: Duration.zero));
        // The fade starts on the first frame after the toast is raised.
        await tester.pump();
        await tester.pump(duration ~/ 2);

        // Half the time on the steep curve is little of the way in, where a
        // linear fade would be half the way.
        expect(opacity(), closeTo(steep.transform(0.5), 0.02));

        await tester.pumpAndSettle();
        controller.close('saved');
        await tester.pump();
        await tester.pump(duration ~/ 2);

        // And the way out runs the curve forwards in time, as the way in did,
        // rather than reading it backwards.
        expect(opacity(), closeTo(1 - steep.transform(0.5), 0.02));
      });
    });

    group('updating', () {
      testWidgets('the same id changes the toast in place', (WidgetTester tester) async {
        late PlToastController toasts;
        await tester.pumpWidget(
          host(
            PlToastProvider(
              timeout: Duration.zero,
              child: Builder(
                builder: (BuildContext context) {
                  toasts = PlToastProvider.of(context);

                  return const SizedBox(width: 200, height: 60);
                },
              ),
            ),
            width: 600,
            height: 500,
          ),
        );

        toasts.show(const PlToast(id: 'upload', title: Text('Uploading…')));
        await tester.pumpAndSettle();
        expect(find.text('Uploading…'), findsOneWidget);

        toasts.show(const PlToast(id: 'upload', title: Text('Uploaded')));
        await tester.pumpAndSettle();

        expect(find.text('Uploading…'), findsNothing);
        expect(find.text('Uploaded'), findsOneWidget);
      });

      testWidgets('a future becomes its own answer', (WidgetTester tester) async {
        late PlToastController toasts;
        await tester.pumpWidget(
          host(
            PlToastProvider(
              timeout: Duration.zero,
              child: Builder(
                builder: (BuildContext context) {
                  toasts = PlToastProvider.of(context);

                  return const SizedBox(width: 200, height: 60);
                },
              ),
            ),
            width: 600,
            height: 500,
          ),
        );

        final work = Completer<String>();
        unawaited(
          toasts.showFuture<String>(
            work.future,
            loading: const PlToast(title: Text('Working…')),
            success: (String value) => PlToast(title: Text(value)),
            failure: (Object error) => const PlToast(title: Text('Failed')),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Working…'), findsOneWidget);

        work.complete('Done');
        await tester.pumpAndSettle();

        expect(find.text('Working…'), findsNothing);
        expect(find.text('Done'), findsOneWidget);
      });
    });

    group('holding the clock', () {
      testWidgets('the keyboard focus on a toast stops it, and moving away starts it again', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _app(
            timeout: const Duration(seconds: 2),
            messages: const <PlToast>[PlToast(title: Text('Deleted'), actionLabel: Text('Undo'))],
          ),
        );
        await _raise(tester);

        _focus(tester, 'Undo');
        await tester.pump();

        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(find.text('Deleted'), findsOneWidget);

        FocusManager.instance.primaryFocus!.unfocus();
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(find.text('Deleted'), findsNothing);
      });

      testWidgets('a finger resting on a toast stops it, and lifting it starts it again', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _app(
            timeout: const Duration(seconds: 2),
            messages: const <PlToast>[PlToast(title: Text('Saved'))],
          ),
        );
        await _raise(tester);

        final TestGesture finger = await tester.startGesture(
          tester.getCenter(find.text('Saved')),
          kind: PointerDeviceKind.touch,
        );
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(find.text('Saved'), findsOneWidget);

        await finger.up();
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(find.text('Saved'), findsNothing);
      });

      testWidgets('an app in the background stops it, and coming back starts it again', (
        WidgetTester tester,
      ) async {
        var closed = 0;
        await tester.pumpWidget(
          _app(
            timeout: const Duration(seconds: 2),
            messages: <PlToast>[PlToast(title: const Text('Saved'), onClose: () => closed += 1)],
          ),
        );
        await _raise(tester);

        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        // A backgrounded app draws no frames, so the toast is still in the tree
        // either way. Whether its clock ran out is what `onClose` says.
        await tester.pump(const Duration(seconds: 3));
        expect(closed, 0);

        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(closed, 1);
        expect(find.text('Saved'), findsNothing);
      });

      testWidgets('what held the last toast does not hold the next one', (
        WidgetTester tester,
      ) async {
        late PlToastController toasts;
        await tester.pumpWidget(
          host(
            PlToastProvider(
              timeout: const Duration(seconds: 2),
              child: Builder(
                builder: (BuildContext context) {
                  toasts = PlToastProvider.of(context);

                  return const SizedBox(width: 200, height: 60);
                },
              ),
            ),
            width: 600,
            height: 500,
          ),
        );

        toasts.show(const PlToast(title: Text('First'), actionLabel: Text('Undo')));
        await tester.pumpAndSettle();

        // The focus on the action, and the action pressed from the keyboard.
        _focus(tester, 'Undo');
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(find.text('First'), findsNothing);

        toasts.show(const PlToast(title: Text('Second')));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(find.text('Second'), findsNothing);
      });
    });

    group('a slow future', () {
      testWidgets('keeps its loading toast up past the timeout, and answers in its place', (
        WidgetTester tester,
      ) async {
        late PlToastController toasts;
        await tester.pumpWidget(
          host(
            PlToastProvider(
              child: Builder(
                builder: (BuildContext context) {
                  toasts = PlToastProvider.of(context);

                  return const SizedBox(width: 200, height: 60);
                },
              ),
            ),
            width: 600,
            height: 500,
          ),
        );

        final work = Completer<String>();
        unawaited(
          toasts.showFuture<String>(
            work.future,
            loading: const PlToast(title: Text('Working…')),
            success: (String value) => PlToast(title: Text(value)),
            failure: (Object error) => const PlToast(title: Text('Failed')),
          ),
        );
        await tester.pumpAndSettle();

        // Another toast arriving starts the clocks again.
        toasts.show(const PlToast(title: Text('Something else')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 6));
        await tester.pumpAndSettle();

        expect(find.text('Something else'), findsNothing);
        expect(find.text('Working…'), findsOneWidget);

        work.complete('Done');
        await tester.pumpAndSettle();

        expect(find.text('Working…'), findsNothing);
        expect(find.text('Done'), findsOneWidget);

        await tester.pump(const Duration(seconds: 6));
        await tester.pumpAndSettle();
      });
    });

    group('accessibility', () {
      testWidgets('announces every toast, whatever its priority', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          _app(
            timeout: Duration.zero,
            messages: const <PlToast>[
              PlToast(title: Text('Quiet')),
              PlToast(title: Text('Loud'), priority: PlToastPriority.high),
            ],
          ),
        );

        await _raise(tester);

        // A default toast is the one a screen reader most needs told about: a
        // "Saved" that is not a live region appears and leaves in silence.
        expect(tester.getSemantics(find.text('Quiet')), isSemantics(isLiveRegion: true));
        expect(tester.getSemantics(find.text('Loud')), isSemantics(isLiveRegion: true));

        handle.dispose();
      });
    });
  });
}
