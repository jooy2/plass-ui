import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

void main() {
  group('PlHeader', () {
    group('the three slots', () {
      testWidgets('lays them out in order', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlHeader(
              brand: <Widget>[Text('Acme')],
              actions: <Widget>[Text('Sign in')],
              child: Text('Docs'),
            ),
            width: 600,
          ),
        );

        final double brand = tester.getTopLeft(find.text('Acme')).dx;
        final double middle = tester.getTopLeft(find.text('Docs')).dx;
        final double actions = tester.getTopLeft(find.text('Sign in')).dx;

        expect(brand, lessThan(middle));
        expect(middle, lessThan(actions));
      });

      testWidgets('draws nothing for a slot nobody filled', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlHeader(brand: <Widget>[Text('Acme')]), width: 600));

        expect(find.byType(Text), findsOneWidget);
      });

      testWidgets('packs the middle against the actions on end', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlHeader(
              align: PlassAlign.end,
              brand: <Widget>[Text('Acme')],
              child: Text('Docs'),
            ),
            width: 600,
          ),
        );

        expect(tester.getTopRight(find.text('Docs')).dx, greaterThan(400));
      });
    });

    group('align: center', () {
      testWidgets('puts the middle on the bar own midline', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlHeader(
              align: PlassAlign.center,
              brand: <Widget>[Text('Acme')],
              actions: <Widget>[Text('X')],
              child: Text('Docs'),
            ),
            width: 600,
          ),
        );

        final Rect middle = tester.getRect(find.text('Docs'));
        final Rect bar = tester.getRect(find.byType(PlHeader));

        expect(middle.center.dx, closeTo(bar.center.dx, 0.5));
      });

      testWidgets('and keeps it there when the brand grows', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlHeader(
              align: PlassAlign.center,
              brand: <Widget>[Text('Acme Group')],
              actions: <Widget>[Text('X')],
              child: Text('Docs'),
            ),
            width: 600,
          ),
        );

        final Rect middle = tester.getRect(find.text('Docs'));
        final Rect bar = tester.getRect(find.byType(PlHeader));

        expect(middle.center.dx, closeTo(bar.center.dx, 0.5));
      });

      testWidgets('still holds the leading half open with no brand', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlHeader(
              align: PlassAlign.center,
              actions: <Widget>[Text('Sign in')],
              child: Text('Docs'),
            ),
            width: 600,
          ),
        );

        final Rect middle = tester.getRect(find.text('Docs'));
        final Rect bar = tester.getRect(find.byType(PlHeader));

        expect(middle.center.dx, closeTo(bar.center.dx, 0.5));
      });
    });

    group('the bar', () {
      testWidgets('keeps a floor a control can sit inside', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlHeader(brand: <Widget>[Text('Acme')]), width: 600));

        expect(tester.getSize(find.byType(PlHeader)).height, 64);
      });

      testWidgets('grows past the floor rather than clipping', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlHeader(brand: <Widget>[SizedBox(height: 96, child: Text('Acme'))]),
            width: 600,
          ),
        );

        // The floor is a floor: the air above and below it is kept.
        expect(tester.getSize(find.byType(PlHeader)).height, 96 + 12 + 12);
      });

      testWidgets('walks the floor up the size ladder', (WidgetTester tester) async {
        for (final MapEntry<PlassSize, double> entry in <PlassSize, double>{
          PlassSize.xs: 40,
          PlassSize.sm: 48,
          PlassSize.md: 64,
          PlassSize.lg: 80,
          PlassSize.xl: 96,
        }.entries) {
          await tester.pumpWidget(
            host(PlHeader(size: entry.key, brand: const <Widget>[Text('Acme')]), width: 600),
          );

          expect(tester.getSize(find.byType(PlHeader)).height, entry.value);
        }
      });

      testWidgets('packs the gutter tighter on compact without moving the floor', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlHeader(brand: <Widget>[Text('Acme')]), width: 600));

        final double standard = tester.getTopLeft(find.text('Acme')).dx;

        await tester.pumpWidget(
          host(
            const PlHeader(density: PlassDensity.compact, brand: <Widget>[Text('Acme')]),
            width: 600,
          ),
        );

        expect(tester.getTopLeft(find.text('Acme')).dx, lessThan(standard));
        expect(tester.getSize(find.byType(PlHeader)).height, 64);
      });

      testWidgets('gives the gutter up when it is told to', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlHeader(padded: false, brand: <Widget>[Text('Acme')]), width: 600),
        );

        expect(
          tester.getTopLeft(find.text('Acme')).dx,
          tester.getTopLeft(find.byType(PlHeader)).dx,
        );
      });

      testWidgets('holds the row to a measure while the sheet spans the width', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlHeader(
              maxWidth: PlassResponsive<PlContainerWidth?>(PlContainerWidth.rung(PlassSize.xs)),
              brand: <Widget>[Text('Acme')],
            ),
            width: 700,
          ),
        );

        expect(tester.getSize(find.byType(PlHeader)).width, 700);
        // 480 wide, centred: the row starts at (700 − 480) / 2.
        expect(tester.getTopLeft(find.text('Acme')).dx, greaterThan(105));
      });
    });

    group('the sheet', () {
      testWidgets('is never dyed, whatever colour it is given', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlHeader(color: PlassColor.danger, brand: <Widget>[Text('Acme')]), width: 600),
        );

        final List<BoxDecoration> decorations = decorationsOf(tester, find.byType(PlHeader));

        expect(
          decorations.every((BoxDecoration decoration) => decoration.gradient == null),
          isTrue,
        );
      });

      testWidgets('rules its bottom edge by default and can be told not to', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlHeader(brand: <Widget>[Text('Acme')]), width: 600));

        expect(
          decorationsOf(tester, find.byType(PlHeader)).any(
            (BoxDecoration decoration) =>
                decoration.border is Border &&
                (decoration.border! as Border).bottom.width > 0 &&
                (decoration.border! as Border).top == BorderSide.none,
          ),
          isTrue,
        );

        await tester.pumpWidget(
          host(const PlHeader(divider: false, brand: <Widget>[Text('Acme')]), width: 600),
        );

        expect(
          decorationsOf(tester, find.byType(PlHeader)).any(
            (BoxDecoration decoration) =>
                decoration.border is Border &&
                (decoration.border! as Border).bottom.width > 0 &&
                (decoration.border! as Border).top == BorderSide.none,
          ),
          isFalse,
        );
      });

      testWidgets('has no corners, because it spans an edge', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlHeader(brand: <Widget>[Text('Acme')]), width: 600));

        expect(
          decorationsOf(tester, find.byType(PlHeader)).every(
            (BoxDecoration decoration) =>
                decoration.borderRadius == null || decoration.borderRadius == BorderRadius.zero,
          ),
          isTrue,
        );
      });
    });

    group('semantics', () {
      testWidgets('claims nothing until it is named', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(host(const PlHeader(brand: <Widget>[Text('Acme')]), width: 600));

        expect(find.byType(Semantics), findsNothing);

        handle.dispose();
      });

      testWidgets('is a named region once it is', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(const PlHeader(semanticLabel: 'Site', brand: <Widget>[Text('Acme')]), width: 600),
        );

        final SemanticsNode node = semanticsOf(tester, find.byType(PlHeader));

        expect(node.getSemanticsData().role, SemanticsRole.region);
        expect(node.getSemanticsData().label, 'Site');

        handle.dispose();
      });
    });

    group('inside a PlPageLayout', () {
      testWidgets('sits above the columns and the columns start under it', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlPageLayout(
              header: PlHeader(brand: <Widget>[Text('Acme')]),
              sidebar: SizedBox(width: 120, child: Text('Nav')),
              child: Text('Body'),
            ),
            width: 780,
            height: 600,
          ),
        );

        // No measurement is needed for this: the Column already left the band
        // exactly what the header did not take.
        expect(tester.getTopLeft(find.text('Nav')).dy, greaterThanOrEqualTo(64));
      });
    });
  });
}
