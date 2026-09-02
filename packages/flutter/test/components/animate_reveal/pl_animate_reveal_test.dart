import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// The rectangle the reveal is currently painting, for a box of [size].
Rect clipOf(WidgetTester tester, {Size size = const Size(200, 40)}) {
  final ClipRect clip = tester.widget<ClipRect>(
    find.descendant(of: find.byType(PlAnimateReveal), matching: find.byType(ClipRect)),
  );

  return clip.clipper!.getClip(size);
}

void main() {
  group('PlAnimateReveal', () {
    testWidgets('paints nothing of itself before it runs', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateReveal(trigger: PlassAnimateTrigger.manual, child: Text('Uncovered')),
          width: 200,
        ),
      );

      // The waiting state is the effect's own first frame, exactly as a paused
      // CSS animation held on `fill-mode: both` is in the other package.
      expect(clipOf(tester).width, 0);
    });

    testWidgets('leaves the box its own size while it is clipped', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateReveal(
            trigger: PlassAnimateTrigger.manual,
            child: SizedBox(width: 120, height: 40),
          ),
        ),
      );

      // The whole argument for a clipper over an `Align` with a width factor:
      // the layout never hears about the wipe, so nothing beside it moves.
      expect(tester.getSize(find.byType(PlAnimateReveal)), const Size(120, 40));
    });

    group('from', () {
      testWidgets('uncovers from the left edge by default', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAnimateReveal(child: Text('Uncovered')), width: 200));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 260));

        final Rect clip = clipOf(tester);

        expect(clip.left, 0);
        expect(clip.width, greaterThan(0));
        expect(clip.width, lessThan(200));
      });

      testWidgets('uncovers towards the left from the right edge', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlAnimateReveal(from: PlassSide.right, child: Text('Uncovered')), width: 200),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 260));

        final Rect clip = clipOf(tester);

        expect(clip.right, 200);
        expect(clip.left, greaterThan(0));
      });

      testWidgets('takes a physical left edge, not a logical start', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlAnimateReveal(child: Text('Uncovered')),
            width: 200,
            textDirection: TextDirection.rtl,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 260));

        // PlassSide is physical everywhere in the package: a heading uncovered
        // from the left is uncovered from the left in every writing direction.
        expect(clipOf(tester).left, 0);
      });

      testWidgets('runs down the box from the top', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlAnimateReveal(from: PlassSide.top, child: Text('Uncovered')), width: 200),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 260));

        final Rect clip = clipOf(tester);

        expect(clip.top, 0);
        expect(clip.width, 200);
        expect(clip.height, lessThan(40));
      });
    });

    group('fade', () {
      testWidgets('changes no colour unless it is asked to', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAnimateReveal(child: Text('Uncovered')), width: 200));

        // The whole reason to reach for a reveal is that the ink does not move
        // and does not change.
        expect(
          find.descendant(of: find.byType(PlAnimateReveal), matching: find.byType(Opacity)),
          findsNothing,
        );
      });

      testWidgets('fades behind the wipe when both are wanted', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlAnimateReveal(fade: true, child: Text('Uncovered')), width: 200),
        );

        expect(
          find.descendant(of: find.byType(PlAnimateReveal), matching: find.byType(Opacity)),
          findsOneWidget,
        );
      });
    });

    testWidgets('is fully painted once it has finished', (WidgetTester tester) async {
      await tester.pumpWidget(host(const PlAnimateReveal(child: Text('Uncovered')), width: 200));
      await tester.pumpAndSettle();

      expect(clipOf(tester), const Rect.fromLTWH(0, 0, 200, 40));
    });
  });
}
