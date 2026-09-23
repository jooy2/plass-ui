// Where the × on everything that can be dismissed can be pressed from.
//
// The × is drawn at the size of the text beside it, smaller than the 24px
// target WCAG 2.5.8 asks for. It is pressed from a 24px square instead, which
// takes a scope round the surface the × sits on, and a surface that forgets
// its scope has a × that is only as large as it is drawn. Each surface is drawn
// at its smallest step, where the × is furthest below 24px.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/host.dart';

/// Just inside the edge of a 24px square centred on the ×.
const double _reach = 11.5;

/// Taps just inside the 24px square round the ×, on each side, where every
/// × here is not drawn.
///
/// A surface that closes on the first press is drawn again by [reopen] between
/// taps, so every side is asked about.
Future<void> _tapAround(
  WidgetTester tester,
  String label, {
  Future<void> Function()? reopen,
}) async {
  for (final Offset side in const <Offset>[
    Offset(-1, 0),
    Offset(1, 0),
    Offset(0, -1),
    Offset(0, 1),
  ]) {
    await reopen?.call();

    final Rect mark = tester.getRect(find.bySemanticsLabel(label).last);

    expect(mark.shortestSide, lessThan(24), reason: 'the × is drawn under 24px');

    await tester.tapAt(mark.center + side * _reach);
    await tester.pump();
  }
}

void main() {
  group('the dismiss ×', () {
    testWidgets('is pressed from a 24px square on an alert', (WidgetTester tester) async {
      final handle = tester.ensureSemantics();
      var closed = 0;

      await tester.pumpWidget(
        host(
          PlAlert(size: PlassSize.xs, onClose: () => closed += 1, child: const Text('Saved.')),
          width: 400,
        ),
      );
      await _tapAround(tester, 'Dismiss');

      expect(closed, 4);
      handle.dispose();
    });

    testWidgets('is pressed from a 24px square on a modal', (WidgetTester tester) async {
      final handle = tester.ensureSemantics();
      var closed = 0;

      await tester.pumpWidget(
        host(
          PlModal(
            open: true,
            size: PlassSize.xs,
            label: 'Rename',
            title: const Text('Rename'),
            onOpenChanged: (bool open) => closed += open ? 0 : 1,
          ),
          overlay: true,
        ),
      );
      await tester.pumpAndSettle();
      await _tapAround(tester, 'Close');

      expect(closed, 4);
      handle.dispose();
    });

    testWidgets('is pressed from a 24px square on a drawer', (WidgetTester tester) async {
      final handle = tester.ensureSemantics();
      var closed = 0;

      await tester.pumpWidget(
        host(
          PlDrawer(
            open: true,
            size: PlassSize.xs,
            label: 'Filters',
            title: const Text('Filters'),
            onOpenChanged: (bool open) => closed += open ? 0 : 1,
          ),
          overlay: true,
          width: 480,
          height: 640,
        ),
      );
      await tester.pumpAndSettle();
      await _tapAround(tester, 'Close');

      expect(closed, 4);
      handle.dispose();
    });

    testWidgets('is pressed from a 24px square on a popover', (WidgetTester tester) async {
      final handle = tester.ensureSemantics();
      var closed = 0;

      await tester.pumpWidget(
        host(
          PlPopover(
            open: true,
            size: PlassSize.xs,
            showClose: true,
            title: const Text('Rates'),
            onOpenChanged: (bool open) => closed += open ? 0 : 1,
            trigger: const SizedBox(width: 80, height: 32, child: Text('Explain')),
            child: const Text('How the number is worked out.'),
          ),
          overlay: true,
        ),
      );
      await tester.pumpAndSettle();
      await _tapAround(tester, 'Close');

      expect(closed, 4);
      handle.dispose();
    });

    testWidgets('is pressed from a 24px square on a tour', (WidgetTester tester) async {
      final handle = tester.ensureSemantics();
      var closed = 0;

      // A tour closes itself when its × is pressed, so it is opened afresh for
      // every side.
      await _tapAround(
        tester,
        'Close',
        reopen: () async {
          await tester.pumpWidget(
            host(
              PlTour(
                key: UniqueKey(),
                open: true,
                size: PlassSize.xs,
                scrollIntoView: false,
                onOpenChanged: (bool open) => closed += open ? 0 : 1,
                steps: const <PlTourStep>[PlTourStep(title: Text('Welcome'))],
              ),
              overlay: true,
              width: 600,
              height: 700,
            ),
          );
          await tester.pumpAndSettle();
        },
      );

      expect(closed, 4);
      handle.dispose();
    });

    testWidgets('is pressed from a 24px square on a toast', (WidgetTester tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          PlToastProvider(
            size: PlassSize.xs,
            timeout: Duration.zero,
            child: Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () =>
                      PlToastProvider.of(context).show(const PlToast(title: Text('Saved'))),
                  child: const SizedBox(width: 200, height: 60, child: Text('Raise')),
                );
              },
            ),
          ),
          width: 600,
          height: 500,
        ),
      );

      var raised = 0;

      await _tapAround(
        tester,
        'Close',
        reopen: () async {
          await tester.tap(find.text('Raise'));
          await tester.pumpAndSettle();
          raised += 1;
        },
      );
      await tester.pumpAndSettle();

      // Every toast raised was taken away by its ×.
      expect(raised, 4);
      expect(find.text('Saved'), findsNothing);
      handle.dispose();
    });

    testWidgets('is pressed from a 24px square on a file', (WidgetTester tester) async {
      final handle = tester.ensureSemantics();
      var removed = 0;

      await tester.pumpWidget(
        host(
          PlFilePicker(
            size: PlassSize.xs,
            value: const <PlFile>[PlFile(name: 'notes.txt', size: 800)],
            onFilesChanged: (List<PlFile> next) => removed += 1,
          ),
          width: 420,
        ),
      );
      await _tapAround(tester, 'Remove notes.txt');

      expect(removed, 4);
      handle.dispose();
    });
  });
}
