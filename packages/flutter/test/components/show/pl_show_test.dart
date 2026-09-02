import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// The gate at one window width.
///
/// A breakpoint is the **window's** width rather than the widget's own box —
/// which is what a CSS media query measures, and what makes two widgets side by
/// side agree about which rung they are on however wide each of them ended up.
/// `host` supplies the smallest `MediaQuery` a Plass widget needs and a size is
/// not part of it, so a test about a width has to say what the width is. The
/// same helper `pl_grid_test.dart` uses, for the same reason.
Future<void> at(WidgetTester tester, double width, Widget gate) async {
  await tester.pumpWidget(
    host(
      Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(size: Size(width, 800)),
          child: gate,
        ),
      ),
    ),
  );
}

void main() {
  group('PlShow', () {
    testWidgets('shows everywhere when it was given no bound at all', (WidgetTester tester) async {
      await at(tester, 500, const PlShow(child: Text('Always')));
      expect(find.text('Always'), findsOneWidget);

      await at(tester, 1400, const PlShow(child: Text('Always')));
      expect(find.text('Always'), findsOneWidget);
    });

    testWidgets('opens at its floor and stays open above it', (WidgetTester tester) async {
      const Widget gate = PlShow(from: PlassBreakpointFloor.md, child: Text('Wide'));

      await at(tester, 500, gate);
      expect(find.text('Wide'), findsNothing);

      // 768 is the floor of `md` — the rung it is named for, not one above.
      await at(tester, 768, gate);
      expect(find.text('Wide'), findsOneWidget);

      await at(tester, 1400, gate);
      expect(find.text('Wide'), findsOneWidget);
    });

    testWidgets('closes at its ceiling, exclusively', (WidgetTester tester) async {
      const Widget gate = PlShow(until: PlassBreakpointFloor.md, child: Text('Narrow'));

      await at(tester, 500, gate);
      expect(find.text('Narrow'), findsOneWidget);

      // Exclusive, so `until: md` and `from: md` are the two halves of one
      // decision: no width draws both and none draws neither.
      await at(tester, 768, gate);
      expect(find.text('Narrow'), findsNothing);
    });

    testWidgets('takes both bounds as a band', (WidgetTester tester) async {
      const Widget gate = PlShow(
        from: PlassBreakpointFloor.sm,
        until: PlassBreakpointFloor.lg,
        child: Text('Middle'),
      );

      for (final (double width, Matcher matcher) in <(double, Matcher)>[
        (500, findsNothing),
        (700, findsOneWidget),
        (900, findsOneWidget),
        (1100, findsNothing),
      ]) {
        await at(tester, width, gate);
        expect(find.text('Middle'), matcher, reason: '$width');
      }
    });

    testWidgets('builds nothing at all while it is closed', (WidgetTester tester) async {
      await at(tester, 500, const PlShow(from: PlassBreakpointFloor.lg, child: Text('Filters')));

      // Not an empty box with a size and not an `Offstage` subtree: the widget
      // is never built, which is what makes an expensive one free while it is
      // closed — and what loses its state when the window crosses the boundary.
      expect(find.text('Filters'), findsNothing);
      expect(tester.getSize(find.byType(PlShow)), Size.zero);
    });
  });
}
