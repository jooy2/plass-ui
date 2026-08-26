import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

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

Future<void> _raise(WidgetTester tester) async {
  await tester.tap(find.text('Raise'));
  await tester.pumpAndSettle();
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

    group('accessibility', () {
      testWidgets('interrupts only for what is worth interrupting for', (
        WidgetTester tester,
      ) async {
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

        expect(tester.getSemantics(find.text('Quiet')), isSemantics(isLiveRegion: false));
        expect(tester.getSemantics(find.text('Loud')), isSemantics(isLiveRegion: true));

        handle.dispose();
      });
    });
  });
}
