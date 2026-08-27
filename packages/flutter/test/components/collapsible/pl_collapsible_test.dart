import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// A fold wired to a variable, which is how every caller uses one.
class _Harness extends StatefulWidget {
  const _Harness({
    this.disabled = false,
    this.keepMounted = false,
    this.indicator = true,
    this.action,
    this.triggerBuilder,
  });

  final bool disabled;
  final bool keepMounted;
  final bool indicator;
  final Widget? action;
  final Widget Function(BuildContext context, bool open, VoidCallback toggle)? triggerBuilder;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  bool _open = false;

  bool get open => _open;

  @override
  Widget build(BuildContext context) {
    return PlCollapsible(
      open: _open,
      onOpenChanged: (bool next) => setState(() => _open = next),
      disabled: widget.disabled,
      keepMounted: widget.keepMounted,
      indicator: widget.indicator,
      action: widget.action,
      triggerBuilder: widget.triggerBuilder,
      title: const Text('Advanced'),
      subtitle: const Text('Nine settings'),
      child: const Text('Everything else.'),
    );
  }
}

void main() {
  group('PlCollapsible', () {
    group('the header', () {
      testWidgets('is announced as a button that reports the state', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const _Harness(), width: 360));

        expect(
          tester.getSemantics(find.text('Advanced')),
          isSemantics(
            isButton: true,
            hasExpandedState: true,
            isExpanded: false,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
            label: 'Advanced\nNine settings',
          ),
        );

        await tester.tap(find.text('Advanced'));
        await tester.pumpAndSettle();

        expect(
          tester.getSemantics(find.text('Advanced')),
          isSemantics(hasExpandedState: true, isExpanded: true),
        );

        handle.dispose();
      });

      testWidgets('draws the subtitle', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(), width: 360));

        expect(find.text('Nine settings'), findsOneWidget);
      });

      testWidgets('keeps an action outside the trigger', (WidgetTester tester) async {
        var pressed = 0;

        await tester.pumpWidget(
          host(
            _Harness(
              action: PlSwitch(
                value: false,
                onChanged: (bool _) => pressed += 1,
                label: const Text('On'),
              ),
            ),
            width: 360,
          ),
        );

        await tester.tap(find.byType(PlSwitch));
        await tester.pumpAndSettle();

        // The switch answered and the fold did not: a header that both folds
        // and holds a control has two things to press, and a gesture inside
        // another recogniser takes one tap twice.
        expect(pressed, 1);
        expect(tester.state<_HarnessState>(find.byType(_Harness)).open, isFalse);
      });

      testWidgets('takes a trigger of its own', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            _Harness(
              triggerBuilder: (BuildContext context, bool open, VoidCallback toggle) =>
                  PlButton(onPressed: toggle, child: Text(open ? 'Less' : 'More')),
            ),
            width: 360,
          ),
        );

        expect(find.text('More'), findsOneWidget);

        await tester.tap(find.text('More'));
        await tester.pumpAndSettle();

        expect(find.text('Less'), findsOneWidget);
        expect(find.text('Everything else.'), findsOneWidget);
      });
    });

    group('folding', () {
      testWidgets('opens on a press and closes again', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(), width: 360));

        expect(find.text('Everything else.'), findsNothing);

        await tester.tap(find.text('Advanced'));
        await tester.pumpAndSettle();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).open, isTrue);
        expect(find.text('Everything else.'), findsOneWidget);

        await tester.tap(find.text('Advanced'));
        await tester.pumpAndSettle();

        // Dropped from the tree once it has finished closing, so a fold nobody
        // opened costs nothing.
        expect(find.text('Everything else.'), findsNothing);
      });

      testWidgets('is a window rather than content being squashed', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(), width: 360));

        await tester.tap(find.text('Advanced'));
        await tester.pump();
        await tester.pump(PlassTokens.durationSlow ~/ 2);

        final double halfway = tester.getSize(find.byType(PlCollapsible)).height;
        final double bodyHalfway = tester.getSize(find.text('Everything else.')).height;

        await tester.pumpAndSettle();

        final double open = tester.getSize(find.byType(PlCollapsible)).height;

        // The sheet grew, and the body inside it never changed size — it was
        // clipped, which is what makes the panel a window.
        expect(halfway, lessThan(open));
        expect(bodyHalfway, tester.getSize(find.text('Everything else.')).height);
        expect(find.byType(ClipRect), findsWidgets);
      });

      testWidgets('does not answer while it is unavailable', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(disabled: true), width: 360));

        await tester.tap(find.text('Advanced'));
        await tester.pumpAndSettle();

        expect(tester.state<_HarnessState>(find.byType(_Harness)).open, isFalse);
      });

      testWidgets('keeps a closed panel in the tree when it is asked to', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const _Harness(keepMounted: true), width: 360));
        await tester.pumpAndSettle();

        // In the tree and clipped to nothing: a `State` goes with its widget
        // when it leaves the tree, so a folded-away field would forget what was
        // typed into it.
        expect(find.text('Everything else.'), findsOneWidget);
        expect(tester.getSize(find.text('Everything else.')).height, greaterThan(0));
        expect(
          find.ancestor(of: find.text('Everything else.'), matching: find.byType(ExcludeFocus)),
          findsOneWidget,
        );
      });

      testWidgets('drops the chevron when it is asked to', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(indicator: false), width: 360));

        expect(find.byType(AnimatedRotation), findsNothing);
      });
    });

    group('the sheet', () {
      testWidgets('is never dyed, whatever colour it is given', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlCollapsible(
              open: false,
              color: PlassColor.danger,
              title: Text('Advanced'),
              child: Text('Everything else.'),
            ),
            width: 360,
          ),
        );

        final BoxDecoration sheet = decorationWhere(
          tester,
          find.byType(PlCollapsible),
          (BoxDecoration decoration) => decoration.color != null,
        );

        expect(sheet.gradient, isNull);
        expect(sheet.color, PlassTokens.light().glass);
      });
    });
  });
}
