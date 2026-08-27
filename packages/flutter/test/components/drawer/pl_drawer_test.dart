import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// A drawer wired to a variable, which is how every caller uses one.
class _Harness extends StatefulWidget {
  const _Harness({
    this.mode = PlDrawerMode.overlay,
    this.side = PlassSide.left,
    this.startOpen = true,
    this.dismissible = true,
    this.showClose,
    this.dividers = false,
    this.extent,
    this.actions,
  });

  final PlDrawerMode mode;
  final PlassSide side;
  final bool startOpen;
  final bool dismissible;
  final bool? showClose;
  final bool dividers;
  final double? extent;
  final List<Widget>? actions;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late bool _open = widget.startOpen;

  bool get open => _open;

  @override
  Widget build(BuildContext context) {
    return PlDrawer(
      open: _open,
      onOpenChanged: (bool next) => setState(() => _open = next),
      mode: widget.mode,
      side: widget.side,
      dismissible: widget.dismissible,
      showClose: widget.showClose,
      dividers: widget.dividers,
      extent: widget.extent,
      actions: widget.actions,
      title: const Text('Filters'),
      description: const Text('Nothing is applied yet'),
      child: const Text('Everything you can narrow by.'),
    );
  }
}

void main() {
  group('PlDrawer', () {
    group('overlay mode', () {
      testWidgets('lifts itself over the screen and names itself', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const _Harness(), overlay: true, width: 480, height: 640));
        await tester.pumpAndSettle();

        expect(find.text('Filters'), findsOneWidget);
        expect(find.text('Everything you can narrow by.'), findsOneWidget);
        expect(find.bySemanticsLabel('Close'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('is not there at all while it is closed', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const _Harness(startOpen: false), overlay: true, width: 480, height: 640),
        );
        await tester.pumpAndSettle();

        expect(find.text('Filters'), findsNothing);
      });

      testWidgets('reports a press on the ×', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(), overlay: true, width: 480, height: 640));
        await tester.pumpAndSettle();

        await tester.tap(find.bySemanticsLabel('Close'));
        await tester.pumpAndSettle();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).open, isFalse);
      });

      testWidgets('closes on Escape, and refuses it when it is not dismissible', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const _Harness(dismissible: false), overlay: true, width: 480, height: 640),
        );
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        // A drawer that has to be answered has no other way out, which is why
        // one that refuses Escape should be given actions that answer it.
        expect(tester.state<_HarnessState>(find.byType(_Harness)).open, isTrue);

        await tester.pumpWidget(host(const _Harness(), overlay: true, width: 480, height: 640));
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).open, isFalse);
      });

      testWidgets('drops the × when it is told to, and draws it otherwise', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const _Harness(showClose: false), overlay: true, width: 480, height: 640),
        );
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Close'), findsNothing);

        handle.dispose();
      });
    });

    group('inline mode', () {
      testWidgets('is in the layout rather than over it', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const _Harness(mode: PlDrawerMode.inline), width: 480, height: 640),
        );
        await tester.pumpAndSettle();

        // No overlay was needed to draw it, which is the whole difference.
        expect(find.text('Everything you can narrow by.'), findsOneWidget);
      });

      testWidgets('shows no × unless it is asked to', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const _Harness(mode: PlDrawerMode.inline), width: 480, height: 640),
        );
        await tester.pumpAndSettle();

        // A × that closes a fixed sidebar with nothing to reopen it is a
        // one-way door.
        expect(find.bySemanticsLabel('Close'), findsNothing);

        await tester.pumpWidget(
          host(const _Harness(mode: PlDrawerMode.inline, showClose: true), width: 480, height: 640),
        );
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Close'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('is not in the layout at all while it is closed', (WidgetTester tester) async {
        // No width and no height on the host: a panel that decides its own
        // extent cannot be measured inside a box that has already decided it.
        await tester.pumpWidget(host(const _Harness(mode: PlDrawerMode.inline, startOpen: false)));
        await tester.pumpAndSettle();

        expect(find.text('Filters'), findsNothing);
        expect(tester.getSize(find.byType(PlDrawer)), Size.zero);
      });
    });

    group('the panel', () {
      testWidgets('takes the width its size implies along the sides', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(mode: PlDrawerMode.inline), height: 640));
        await tester.pumpAndSettle();

        expect(tester.getSize(find.byType(PlDrawer)).width, 320);
      });

      testWidgets('takes an extent as a width along the sides', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const _Harness(mode: PlDrawerMode.inline, extent: 220), height: 640),
        );
        await tester.pumpAndSettle();

        expect(tester.getSize(find.byType(PlDrawer)).width, 220);
      });

      testWidgets('is as tall as its content at the ends, up to a ceiling', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const _Harness(mode: PlDrawerMode.inline, side: PlassSide.bottom), width: 480),
        );
        await tester.pumpAndSettle();

        // A bottom sheet holding three lines should be three lines tall.
        final Size panel = tester.getSize(find.byType(PlDrawer));

        expect(panel.width, 480);
        expect(panel.height, lessThan(600 * 0.85));
      });

      testWidgets('cuts only the corners that face the screen', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const _Harness(mode: PlDrawerMode.inline), width: 480, height: 640),
        );
        await tester.pumpAndSettle();

        final BoxDecoration sheet = decorationWhere(
          tester,
          find.byType(PlDrawer),
          (BoxDecoration decoration) => decoration.borderRadius != null,
        );

        // Square against the screen edge: a corner cut off something with no
        // visible end is a corner cut off nothing.
        expect(
          sheet.borderRadius,
          BorderRadius.horizontal(right: Radius.circular(PlassTokens.radius[PlassSize.md]!)),
        );
      });

      testWidgets('draws its hairline on the free edge only', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const _Harness(mode: PlDrawerMode.inline), width: 480, height: 640),
        );
        await tester.pumpAndSettle();

        final BoxDecoration sheet = decorationWhere(
          tester,
          find.byType(PlDrawer),
          (BoxDecoration decoration) => decoration.border != null,
        );
        final Border border = sheet.border! as Border;

        expect(border.right.width, greaterThan(0));
        expect(border.left, BorderSide.none);
      });

      testWidgets('lies flat in the layout and floats over the screen', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const _Harness(mode: PlDrawerMode.inline), width: 480, height: 640),
        );
        await tester.pumpAndSettle();

        expect(
          decorationsOf(
            tester,
            find.byType(PlDrawer),
          ).every((BoxDecoration d) => d.boxShadow == null || d.boxShadow!.isEmpty),
          isTrue,
        );

        await tester.pumpWidget(host(const _Harness(), overlay: true, width: 480, height: 640));
        await tester.pumpAndSettle();

        expect(
          decorationsOf(
            tester,
            find.byType(PlDrawer),
          ).any((BoxDecoration d) => d.boxShadow != null && d.boxShadow!.isNotEmpty),
          isTrue,
        );
      });

      testWidgets('scores the sections when it is asked to', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            _Harness(
              mode: PlDrawerMode.inline,
              dividers: true,
              actions: <Widget>[PlButton(onPressed: () {}, child: const Text('Apply'))],
            ),
            width: 480,
            height: 640,
          ),
        );
        await tester.pumpAndSettle();

        final Iterable<BoxDecoration> rules = decorationsOf(
          tester,
          find.byType(PlDrawer),
        ).where((BoxDecoration d) => d.border is Border && (d.border! as Border).top.width > 0);

        expect(rules, isNotEmpty);
      });
    });
  });
}
