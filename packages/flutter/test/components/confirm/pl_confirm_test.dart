import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// A button that asks, and writes the answer where a test can read it.
class _Asker extends StatelessWidget {
  const _Asker({required this.answer, this.options = const PlConfirmOptions()});

  final void Function(Object? value) answer;
  final PlConfirmOptions options;

  @override
  Widget build(BuildContext context) {
    return PlButton(
      onPressed: () async => answer(await PlConfirmProvider.of(context).confirm(options)),
      child: const Text('Delete'),
    );
  }
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(800, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(host(child, overlay: true));
  await tester.pumpAndSettle();
}

Future<void> _press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  group('PlConfirmProvider', () {
    group('asking', () {
      testWidgets('draws nothing until something asks', (WidgetTester tester) async {
        await _pump(tester, PlConfirmProvider(child: _Asker(answer: (Object? _) {})));

        expect(find.text('Delete this project?'), findsNothing);
      });

      testWidgets('opens with the question it was given', (WidgetTester tester) async {
        await _pump(
          tester,
          PlConfirmProvider(
            child: _Asker(
              answer: (Object? _) {},
              options: const PlConfirmOptions(
                title: Text('Delete this project?'),
                description: Text('Ten members lose access.'),
              ),
            ),
          ),
        );
        await _press(tester, 'Delete');

        expect(find.text('Delete this project?'), findsOneWidget);
        expect(find.text('Ten members lose access.'), findsOneWidget);
      });

      testWidgets('falls back to the provider’s labels', (WidgetTester tester) async {
        await _pump(
          tester,
          PlConfirmProvider(
            confirmLabel: const Text('삭제'),
            cancelLabel: const Text('취소'),
            child: _Asker(answer: (Object? _) {}),
          ),
        );
        await _press(tester, 'Delete');

        expect(find.text('삭제'), findsOneWidget);
        expect(find.text('취소'), findsOneWidget);
      });
    });

    group('the answer', () {
      testWidgets('completes true when the question is confirmed', (WidgetTester tester) async {
        Object? answer;

        await _pump(
          tester,
          PlConfirmProvider(
            child: _Asker(
              answer: (Object? value) => answer = value,
              options: const PlConfirmOptions(confirmLabel: Text('Delete it')),
            ),
          ),
        );
        await _press(tester, 'Delete');
        await _press(tester, 'Delete it');

        expect(answer, isTrue);
      });

      testWidgets('completes false when it is cancelled', (WidgetTester tester) async {
        Object? answer;

        await _pump(
          tester,
          PlConfirmProvider(
            child: _Asker(
              answer: (Object? value) => answer = value,
              options: const PlConfirmOptions(cancelLabel: Text('Keep it')),
            ),
          ),
        );
        await _press(tester, 'Delete');
        await _press(tester, 'Keep it');

        expect(answer, isFalse);
      });

      testWidgets('closes once it has been answered', (WidgetTester tester) async {
        await _pump(
          tester,
          PlConfirmProvider(
            child: _Asker(
              answer: (Object? _) {},
              options: const PlConfirmOptions(
                title: Text('Delete this project?'),
                confirmLabel: Text('Delete it'),
              ),
            ),
          ),
        );
        await _press(tester, 'Delete');
        await _press(tester, 'Delete it');

        expect(find.text('Delete this project?'), findsNothing);
      });
    });

    group('a question asked while one is open', () {
      testWidgets('is queued rather than dropped', (WidgetTester tester) async {
        final List<bool> answers = <bool>[];

        await _pump(
          tester,
          PlConfirmProvider(
            child: Builder(
              builder: (BuildContext context) {
                return PlButton(
                  onPressed: () {
                    // Both are asked in the same turn, so the second lands while
                    // the first is up. A dropped future here is a button that
                    // spins for the rest of the session.
                    final PlConfirmController confirm = PlConfirmProvider.of(context);

                    unawaited(
                      confirm
                          .confirm(const PlConfirmOptions(title: Text('First?')))
                          .then(answers.add),
                    );
                    unawaited(
                      confirm
                          .confirm(const PlConfirmOptions(title: Text('Second?')))
                          .then(answers.add),
                    );
                  },
                  child: const Text('Ask twice'),
                );
              },
            ),
          ),
        );
        await _press(tester, 'Ask twice');

        expect(find.text('First?'), findsOneWidget);

        await _press(tester, 'Confirm');

        expect(find.text('Second?'), findsOneWidget);

        await _press(tester, 'Confirm');

        expect(answers, equals(<bool>[true, true]));
      });
    });

    group('alert', () {
      testWidgets('draws one button and completes when it is pressed', (WidgetTester tester) async {
        var done = false;

        await _pump(
          tester,
          PlConfirmProvider(
            child: Builder(
              builder: (BuildContext context) {
                return PlButton(
                  onPressed: () async {
                    await PlConfirmProvider.of(
                      context,
                    ).alert(const PlConfirmOptions(title: Text('Your session expired.')));
                    done = true;
                  },
                  child: const Text('Tell me'),
                );
              },
            ),
          ),
        );
        await _press(tester, 'Tell me');

        expect(find.text('Your session expired.'), findsOneWidget);
        expect(find.text('Cancel'), findsNothing);

        await _press(tester, 'OK');

        expect(done, isTrue);
      });
    });

    group('outside a provider', () {
      testWidgets('asserts rather than quietly answering no', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            Builder(
              builder: (BuildContext context) {
                return PlButton(
                  onPressed: () => PlConfirmProvider.of(context),
                  child: const Text('Ask'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Ask'));
        await tester.pump();

        // A silent `false` is a delete button that does nothing, which is worse
        // than a missing provider that says so on the first press. The assertion
        // is thrown inside a gesture handler, so it reaches the test through
        // `takeException` rather than out of `tap`.
        expect(tester.takeException(), isAssertionError);
      });
    });
  });
}
