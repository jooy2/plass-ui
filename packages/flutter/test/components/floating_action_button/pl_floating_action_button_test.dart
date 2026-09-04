import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// The box the button positions itself inside, so a test never has to pick one
/// `Stack` out of the two the host builds.
final GlobalKey _field = GlobalKey();

class _Glyph extends StatelessWidget {
  const _Glyph();

  @override
  Widget build(BuildContext context) => const SizedBox.square(dimension: 16);
}

/// A floating button positions itself, so it belongs in a stack.
Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    host(
      SizedBox(
        key: _field,
        width: 300,
        height: 300,
        child: Stack(children: <Widget>[child]),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('PlFloatingActionButton', () {
    group('the name', () {
      testWidgets('is the label whether or not the words are drawn', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, const PlFloatingActionButton(icon: _Glyph(), label: 'New project'));

        // A floating button is a disc with a mark in it nine times out of ten,
        // and an unnamed one is the defect this pattern ships with everywhere.
        expect(find.bySemanticsLabel('New project'), findsOneWidget);
        expect(find.text('New project'), findsNothing);

        handle.dispose();
      });

      testWidgets('draws the same words when it is extended', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlFloatingActionButton(extended: true, icon: _Glyph(), label: 'New project'),
        );

        expect(find.text('New project'), findsOneWidget);
      });
    });

    group('the shape', () {
      testWidgets('is a disc while it is a glyph alone', (WidgetTester tester) async {
        await _pump(tester, const PlFloatingActionButton(icon: _Glyph(), label: 'New'));

        expect(find.byType(PlIconButton), findsOneWidget);
        expect(find.byType(PlButton), findsOneWidget);
      });

      testWidgets('is a labelled key once it has words along its edge', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const PlFloatingActionButton(extended: true, icon: _Glyph(), label: 'New'),
        );

        expect(find.byType(PlIconButton), findsNothing);
        expect(find.byType(PlButton), findsOneWidget);
      });
    });

    group('the pinning', () {
      testWidgets('sits in the bottom trailing corner by default', (WidgetTester tester) async {
        await _pump(tester, const PlFloatingActionButton(icon: _Glyph(), label: 'New'));

        final Rect box = tester.getRect(find.byType(PlIconButton));
        final Rect stack = tester.getRect(find.byKey(_field));

        expect(stack.bottom - box.bottom, 24);
        expect(stack.right - box.right, 24);
      });

      testWidgets('takes any corner, and goes the other way under RTL', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            SizedBox(
              key: _field,
              width: 300,
              height: 300,
              child: Stack(
                children: const <Widget>[
                  PlFloatingActionButton(
                    corner: PlassCorner.topStart,
                    icon: _Glyph(),
                    label: 'New',
                  ),
                ],
              ),
            ),
            textDirection: TextDirection.rtl,
          ),
        );
        await tester.pumpAndSettle();

        final Rect box = tester.getRect(find.byType(PlIconButton));
        final Rect stack = tester.getRect(find.byKey(_field));

        // `start` and not `left`: the leading corner is on the right here.
        expect(box.top - stack.top, 24);
        expect(stack.right - box.right, 24);
      });

      testWidgets('takes an offset of its own', (WidgetTester tester) async {
        await _pump(tester, const PlFloatingActionButton(offset: 8, icon: _Glyph(), label: 'New'));

        final Rect box = tester.getRect(find.byType(PlIconButton));
        final Rect stack = tester.getRect(find.byKey(_field));

        expect(stack.bottom - box.bottom, 8);
      });

      testWidgets('positions nothing when it was told not to float', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlFloatingActionButton(floating: false, icon: _Glyph(), label: 'New')),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PositionedDirectional), findsNothing);
      });
    });

    group('it is a button', () {
      testWidgets('does what it was given to do', (WidgetTester tester) async {
        int pressed = 0;

        await _pump(
          tester,
          PlFloatingActionButton(icon: const _Glyph(), label: 'New', onPressed: () => pressed += 1),
        );

        await tester.tap(find.byType(PlIconButton));

        expect(pressed, 1);
      });
    });
  });
}
