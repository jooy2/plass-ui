import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// A popconfirm that keeps its own open state, which is what a caller writes.
class _Host extends StatefulWidget {
  const _Host({this.onConfirm, this.onCancel});

  final FutureOr<void> Function()? onConfirm;
  final VoidCallback? onCancel;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return PlPopconfirm(
      open: _open,
      onOpenChanged: (bool next) => setState(() => _open = next),
      title: const Text('Delete this row?'),
      description: const Text('It cannot be undone.'),
      confirmLabel: const Text('Delete it'),
      cancelLabel: const Text('Keep it'),
      onConfirm: widget.onConfirm,
      onCancel: widget.onCancel,
      trigger: PlButton(
        color: PlassColor.danger,
        onPressed: () => setState(() => _open = true),
        child: const Text('Delete'),
      ),
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
  group('PlPopconfirm', () {
    group('opening', () {
      testWidgets('draws nothing until the trigger is pressed', (WidgetTester tester) async {
        await _pump(tester, const _Host());

        expect(find.text('Delete this row?'), findsNothing);
      });

      testWidgets('asks the question against the thing it is about', (WidgetTester tester) async {
        await _pump(tester, const _Host());
        await _press(tester, 'Delete');

        expect(find.text('Delete this row?'), findsOneWidget);
        expect(find.text('It cannot be undone.'), findsOneWidget);
      });
    });

    group('answering', () {
      testWidgets('runs what confirming does, and closes', (WidgetTester tester) async {
        var confirmed = false;

        await _pump(tester, _Host(onConfirm: () => confirmed = true));
        await _press(tester, 'Delete');
        await _press(tester, 'Delete it');

        expect(confirmed, isTrue);
        expect(find.text('Delete this row?'), findsNothing);
      });

      testWidgets('runs what cancelling does, and closes', (WidgetTester tester) async {
        var cancelled = false;

        await _pump(tester, _Host(onCancel: () => cancelled = true));
        await _press(tester, 'Delete');
        await _press(tester, 'Keep it');

        expect(cancelled, isTrue);
        expect(find.text('Delete this row?'), findsNothing);
      });
    });

    group('a confirm that takes time', () {
      testWidgets('waits for the future before closing', (WidgetTester tester) async {
        final Completer<void> work = Completer<void>();

        await _pump(tester, _Host(onConfirm: () => work.future));
        await _press(tester, 'Delete');

        await tester.tap(find.text('Delete it'));
        await tester.pump();

        // Still up, and still asking.
        expect(find.text('Delete this row?'), findsOneWidget);

        work.complete();
        await tester.pumpAndSettle();

        expect(find.text('Delete this row?'), findsNothing);
      });

      testWidgets('leaves the question up when the future fails', (WidgetTester tester) async {
        await _pump(tester, _Host(onConfirm: () => Future<void>.error(StateError('no'))));
        await _press(tester, 'Delete');

        await tester.tap(find.text('Delete it'));
        await tester.pumpAndSettle();

        // A failed request must not look like a finished one — and the error
        // goes no further than the widget.
        expect(find.text('Delete this row?'), findsOneWidget);
      });
    });
  });
}
