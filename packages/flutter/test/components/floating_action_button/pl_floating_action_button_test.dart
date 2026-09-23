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

/// A different number on every edge, so a wrong side cannot pass by accident.
const EdgeInsets _safeArea = EdgeInsets.fromLTRB(40, 20, 10, 30);

/// As [_pump], on a screen whose edges are [_safeArea]'s: the home indicator,
/// a cutout, the navigation bar. [safeAreaWidget] puts a [SafeArea] round the
/// stack, the way an app that already clears the edges itself would.
Future<void> _pumpEdgeToEdge(
  WidgetTester tester,
  Widget child, {
  TextDirection textDirection = TextDirection.ltr,
  bool safeAreaWidget = false,
}) async {
  final Widget stack = Stack(children: <Widget>[child]);

  await tester.pumpWidget(
    host(
      Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(padding: _safeArea),
          child: SizedBox(
            key: _field,
            width: 300,
            height: 300,
            child: safeAreaWidget ? SafeArea(child: stack) : stack,
          ),
        ),
      ),
      textDirection: textDirection,
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

      testWidgets('draws the same words when it is extended, and says them once', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(
          tester,
          const PlFloatingActionButton(extended: true, icon: _Glyph(), label: 'New project'),
        );

        expect(find.text('New project'), findsOneWidget);
        // The words on the key are its name. A label on top of them would be
        // read as "New project, New project".
        expect(
          tester.getSemantics(find.text('New project')),
          isSemantics(isButton: true, label: 'New project'),
        );

        handle.dispose();
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

      testWidgets('stands the safe area and the offset off the bottom and the end', (
        WidgetTester tester,
      ) async {
        await _pumpEdgeToEdge(tester, const PlFloatingActionButton(icon: _Glyph(), label: 'New'));

        final Rect box = tester.getRect(find.byType(PlIconButton));
        final Rect stack = tester.getRect(find.byKey(_field));

        // 24 off each edge, and the home indicator and the cutout on top.
        expect(stack.bottom - box.bottom, 54);
        expect(stack.right - box.right, 34);
      });

      testWidgets('takes the safe area of the other side under RTL', (WidgetTester tester) async {
        await _pumpEdgeToEdge(
          tester,
          const PlFloatingActionButton(icon: _Glyph(), label: 'New'),
          textDirection: TextDirection.rtl,
        );

        final Rect box = tester.getRect(find.byType(PlIconButton));
        final Rect stack = tester.getRect(find.byKey(_field));

        // The end is on the left now, and so is the edge whose inset it clears.
        expect(box.left - stack.left, 64);
      });

      testWidgets('clears the top and the start when it is in that corner', (
        WidgetTester tester,
      ) async {
        await _pumpEdgeToEdge(
          tester,
          const PlFloatingActionButton(corner: PlassCorner.topStart, icon: _Glyph(), label: 'New'),
        );

        final Rect box = tester.getRect(find.byType(PlIconButton));
        final Rect stack = tester.getRect(find.byKey(_field));

        expect(box.top - stack.top, 44);
        expect(box.left - stack.left, 64);
      });

      testWidgets('counts the safe area once inside a SafeArea', (WidgetTester tester) async {
        await _pumpEdgeToEdge(
          tester,
          const PlFloatingActionButton(icon: _Glyph(), label: 'New'),
          safeAreaWidget: true,
        );

        final Rect box = tester.getRect(find.byType(PlIconButton));
        final Rect stack = tester.getRect(find.byKey(_field));

        // The `SafeArea` has already moved the stack in, and it hands down a
        // padding of zero, so the button adds nothing more to it.
        expect(stack.bottom - box.bottom, 54);
        expect(stack.right - box.right, 34);
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

      testWidgets('hands a long press on, in both forms', (WidgetTester tester) async {
        int held = 0;

        for (final bool extended in <bool>[false, true]) {
          await _pump(
            tester,
            PlFloatingActionButton(
              extended: extended,
              icon: const _Glyph(),
              label: 'New',
              onPressed: () {},
              onLongPress: () => held += 1,
            ),
          );

          await tester.longPress(find.byType(PlButton));
        }

        expect(held, 2);
      });

      testWidgets('stops the press but keeps the focus when read-only, in both forms', (
        WidgetTester tester,
      ) async {
        int pressed = 0;

        for (final bool extended in <bool>[false, true]) {
          final FocusNode node = FocusNode();
          addTearDown(node.dispose);

          await _pump(
            tester,
            PlFloatingActionButton(
              extended: extended,
              readOnly: true,
              focusNode: node,
              autofocus: true,
              icon: const _Glyph(),
              label: 'New',
              onPressed: () => pressed += 1,
            ),
          );

          await tester.tap(find.byType(PlButton));

          // Inert but not gone: the action exists, and a keyboard reader still
          // lands on it, which is the whole difference from `disabled`.
          expect(node.hasFocus, isTrue);
        }

        expect(pressed, 0);
      });

      testWidgets('changes its padding with density once it is extended', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const PlFloatingActionButton(extended: true, icon: _Glyph(), label: 'New'),
        );
        final double standard = tester.getSize(find.byType(PlButton)).width;

        await _pump(
          tester,
          const PlFloatingActionButton(
            extended: true,
            density: PlassDensity.compact,
            icon: _Glyph(),
            label: 'New',
          ),
        );

        // `lg`, the floating default: 24px each side against 14px.
        expect(standard - tester.getSize(find.byType(PlButton)).width, 20);
      });
    });
  });
}
