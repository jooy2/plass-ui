import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  // No height on the host: the widget's own bound is what is under test, and a
  // tight constraint from outside would answer for it.
  await tester.pumpWidget(host(child, width: 300));
  await tester.pumpAndSettle();
}

/// Tall and wide content, so there is always something to scroll either way.
Widget _long() => const SizedBox(height: 900, width: 900, child: Text('Long'));

List<SingleChildScrollView> _views(WidgetTester tester) {
  return tester.widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView)).toList();
}

List<RawScrollbar> _bars(WidgetTester tester) {
  return tester.widgetList<RawScrollbar>(find.byType(RawScrollbar)).toList();
}

void main() {
  group('PlScrollArea', () {
    group('the box', () {
      testWidgets('holds itself to the height it was given', (WidgetTester tester) async {
        await _pump(tester, PlScrollArea(height: 200, child: _long()));

        expect(tester.getSize(find.byType(PlScrollArea)).height, 200);
      });

      testWidgets('stops growing at a maximum without insisting on it', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const PlScrollArea(maxHeight: 200, child: SizedBox(height: 60, child: Text('Short'))),
        );

        // Short content keeps its own height; the bound is a ceiling rather
        // than a size.
        expect(tester.getSize(find.byType(PlScrollArea)).height, 60);
      });

      testWidgets('scrolls what it was given', (WidgetTester tester) async {
        await _pump(tester, PlScrollArea(height: 200, child: _long()));

        final ScrollController controller = _views(tester).first.controller!;

        controller.jumpTo(120);
        await tester.pump();

        expect(controller.offset, 120);
      });

      testWidgets('clips to the house radius', (WidgetTester tester) async {
        await _pump(tester, PlScrollArea(height: 200, child: _long()));

        expect(find.byType(ClipRRect), findsWidgets);
      });
    });

    group('orientation', () {
      testWidgets('scrolls down the page by default', (WidgetTester tester) async {
        await _pump(tester, PlScrollArea(height: 200, child: _long()));

        expect(_views(tester).length, 1);
        expect(_views(tester).single.scrollDirection, Axis.vertical);
      });

      testWidgets('scrolls along the row when it was told to', (WidgetTester tester) async {
        await _pump(
          tester,
          PlScrollArea(orientation: PlScrollAreaAxis.horizontal, width: 200, child: _long()),
        );

        expect(_views(tester).length, 1);
        expect(_views(tester).single.scrollDirection, Axis.horizontal);
      });

      testWidgets('takes both axes, one scrollable inside the other', (WidgetTester tester) async {
        await _pump(
          tester,
          PlScrollArea(orientation: PlScrollAreaAxis.both, height: 200, width: 200, child: _long()),
        );

        expect(_views(tester).map((SingleChildScrollView view) => view.scrollDirection), <Axis>[
          Axis.vertical,
          Axis.horizontal,
        ]);
        expect(_bars(tester).length, 2);
      });
    });

    group('the scrollbars', () {
      testWidgets('are out of the way until the pointer arrives', (WidgetTester tester) async {
        await _pump(tester, PlScrollArea(height: 200, child: _long()));

        expect(_bars(tester).single.thumbVisibility, false);

        final TestGesture pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await pointer.addPointer(location: tester.getCenter(find.byType(PlScrollArea)));
        addTearDown(pointer.removePointer);
        await tester.pumpAndSettle();

        expect(_bars(tester).single.thumbVisibility, true);
      });

      testWidgets('are held open when they were asked to be', (WidgetTester tester) async {
        await _pump(
          tester,
          PlScrollArea(height: 200, scrollbars: PlScrollbars.always, child: _long()),
        );

        expect(_bars(tester).single.thumbVisibility, true);
      });

      testWidgets('are cut in the same neutral ink a rail is', (WidgetTester tester) async {
        await _pump(tester, PlScrollArea(height: 200, child: _long()));

        expect(
          _bars(tester).single.thumbColor,
          PlassTheme.of(tester.element(find.byType(PlScrollArea))).track,
        );
      });
    });

    group('semantics', () {
      testWidgets('is named when it was given a name', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, PlScrollArea(height: 200, label: 'Release notes', child: _long()));

        expect(find.bySemanticsLabel('Release notes'), findsOneWidget);

        handle.dispose();
      });
    });
  });
}
