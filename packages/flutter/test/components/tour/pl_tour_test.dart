import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// A screen with two things on it, and a tour over them.
///
/// `scrollIntoView` is off throughout: there is nothing to scroll here, and an
/// `ensureVisible` with no scrollable above it is a frame spent on nothing.
class Page extends StatefulWidget {
  const Page({
    this.open = true,
    this.step,
    this.initialStep = 0,
    this.steps,
    this.mask = true,
    this.skippable = true,
    this.dismissible = true,
    this.onOpenChanged,
    this.onStepChanged,
    this.onFinish,
    this.nextLabel,
    super.key,
  });

  final bool open;
  final int? step;
  final int initialStep;
  final List<PlTourStep> Function(GlobalKey filter, GlobalKey export)? steps;
  final bool mask;
  final bool skippable;
  final bool dismissible;
  final ValueChanged<bool>? onOpenChanged;
  final ValueChanged<int>? onStepChanged;
  final VoidCallback? onFinish;
  final Widget? nextLabel;

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  final GlobalKey _filter = GlobalKey();
  final GlobalKey _export = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(key: _filter, width: 120, height: 32, child: const Text('Filter')),
            SizedBox(key: _export, width: 120, height: 32, child: const Text('Export')),
          ],
        ),
        PlTour(
          open: widget.open,
          step: widget.step,
          initialStep: widget.initialStep,
          mask: widget.mask,
          skippable: widget.skippable,
          dismissible: widget.dismissible,
          scrollIntoView: false,
          onOpenChanged: widget.onOpenChanged,
          onStepChanged: widget.onStepChanged,
          onFinish: widget.onFinish,
          nextLabel: widget.nextLabel,
          steps:
              widget.steps?.call(_filter, _export) ??
              <PlTourStep>[
                PlTourStep(
                  target: _filter,
                  title: const Text('Narrow the list'),
                  content: const Text('Type here to filter.'),
                ),
                PlTourStep(target: _export, title: const Text('Take it with you')),
                const PlTourStep(title: Text('That is everything')),
              ],
        ),
      ],
    );
  }
}

Future<void> pump(WidgetTester tester, Widget page) async {
  await tester.pumpWidget(host(page, width: 600, height: 700, overlay: true));
  await tester.pumpAndSettle();
}

/// The clip the scrim is drawn through, or `null` when there is no scrim.
ClipPath? clip(WidgetTester tester) {
  final Finder found = find.byType(ClipPath);

  return found.evaluate().isEmpty ? null : tester.widget<ClipPath>(found.first);
}

void main() {
  group('PlTour', () {
    group('running', () {
      testWidgets('draws nothing until it is opened', (WidgetTester tester) async {
        await pump(tester, const Page(open: false));

        expect(find.text('Narrow the list'), findsNothing);
        expect(clip(tester), isNull);
      });

      testWidgets('shows the first step when it starts open', (WidgetTester tester) async {
        await pump(tester, const Page());

        expect(find.text('Narrow the list'), findsOneWidget);
        expect(find.text('Type here to filter.'), findsOneWidget);
      });

      testWidgets('renders nothing at all when it has no steps', (WidgetTester tester) async {
        await pump(tester, Page(steps: (GlobalKey _, GlobalKey _) => const <PlTourStep>[]));

        expect(clip(tester), isNull);
      });
    });

    group('stepping', () {
      testWidgets('walks forward and back', (WidgetTester tester) async {
        await pump(tester, const Page());

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        expect(find.text('Take it with you'), findsOneWidget);

        await tester.tap(find.text('Previous'));
        await tester.pumpAndSettle();
        expect(find.text('Narrow the list'), findsOneWidget);
      });

      testWidgets('counts the steps rather than spelling them', (WidgetTester tester) async {
        // Two numbers, because "3 of 7" is a word order that differs by
        // language and the count itself does not.
        await pump(tester, const Page());

        expect(find.text('1 / 3'), findsOneWidget);
      });

      testWidgets('offers no Previous on the first step', (WidgetTester tester) async {
        await pump(tester, const Page());

        expect(find.text('Previous'), findsNothing);
      });

      testWidgets('turns Next into Done on the last step, and finishes there', (
        WidgetTester tester,
      ) async {
        var finished = false;
        var closed = false;

        await pump(
          tester,
          Page(
            initialStep: 2,
            onFinish: () => finished = true,
            onOpenChanged: (bool next) => closed = !next,
          ),
        );

        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();

        expect(finished, isTrue);
        expect(closed, isTrue);
      });

      testWidgets('reports the step and draws what it is told when it is controlled', (
        WidgetTester tester,
      ) async {
        int? reported;

        await pump(tester, Page(step: 0, onStepChanged: (int next) => reported = next));

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(reported, 1);
        // Still the first step: the position belongs to whoever passed it.
        expect(find.text('Narrow the list'), findsOneWidget);
      });

      testWidgets('clamps a step past the end onto the last one', (WidgetTester tester) async {
        await pump(tester, const Page(initialStep: 9));

        expect(find.text('That is everything'), findsOneWidget);
      });
    });

    group('leaving', () {
      testWidgets('skips out of the tour', (WidgetTester tester) async {
        bool? asked;

        await pump(tester, Page(onOpenChanged: (bool next) => asked = next));

        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();

        expect(asked, isFalse);
      });

      testWidgets('offers no Skip on the last step, where Done is the way out', (
        WidgetTester tester,
      ) async {
        await pump(tester, const Page(initialStep: 2));

        expect(find.text('Skip'), findsNothing);
      });

      testWidgets('leaves the Skip button out entirely when it was not asked for', (
        WidgetTester tester,
      ) async {
        await pump(tester, const Page(skippable: false));

        expect(find.text('Skip'), findsNothing);
      });

      testWidgets('closes on the × in the corner', (WidgetTester tester) async {
        bool? asked;

        await pump(tester, Page(onOpenChanged: (bool next) => asked = next));

        await tester.tap(find.bySemanticsLabel('Close'));
        await tester.pumpAndSettle();

        expect(asked, isFalse);
      });

      testWidgets('draws no × and ignores Escape when it cannot be dismissed', (
        WidgetTester tester,
      ) async {
        bool? asked;

        await pump(tester, Page(dismissible: false, onOpenChanged: (bool next) => asked = next));

        expect(find.bySemanticsLabel('Close'), findsNothing);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(asked, isNull);
      });
    });

    group('the light', () {
      testWidgets('cuts the target out of the dimming', (WidgetTester tester) async {
        await pump(tester, const Page());

        final Path path = clip(tester)!.clipper!.getClip(const Size(600, 700));
        final Rect target = tester.getRect(find.text('Filter'));

        // Inside the light is outside the scrim, which is what makes the
        // control under it reachable.
        expect(path.contains(target.center), isFalse);
        expect(path.contains(const Offset(590, 690)), isTrue);
      });

      testWidgets('cuts nothing out of a step that is about the screen', (
        WidgetTester tester,
      ) async {
        await pump(tester, const Page(initialStep: 2));

        final Path path = clip(tester)!.clipper!.getClip(const Size(600, 700));

        expect(path.contains(const Offset(300, 350)), isTrue);
      });

      testWidgets('follows the target when the step changes', (WidgetTester tester) async {
        await pump(tester, const Page());

        final Rect filter = tester.getRect(find.text('Filter'));
        final Rect export = tester.getRect(find.text('Export'));

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        final Path path = clip(tester)!.clipper!.getClip(const Size(600, 700));

        expect(path.contains(export.center), isFalse);
        expect(path.contains(filter.center), isTrue);
      });

      testWidgets('draws no dimming at all when it was not asked for', (WidgetTester tester) async {
        await pump(tester, const Page(mask: false));

        expect(clip(tester), isNull);
        expect(find.text('Narrow the list'), findsOneWidget);
      });
    });

    group('the card', () {
      testWidgets('sits under the target it is pointing at', (WidgetTester tester) async {
        await pump(tester, const Page());

        expect(
          tester.getRect(find.text('Narrow the list')).top,
          greaterThan(tester.getRect(find.text('Filter')).bottom),
        );
      });

      testWidgets('takes its words from the labels in scope', (WidgetTester tester) async {
        await pump(
          tester,
          PlassTheme.merge(
            defaults: const PlassDefaults(
              labels: PlassLabels(skip: '건너뛰기', next: '다음'),
            ),
            child: const Page(),
          ),
        );

        expect(find.text('다음'), findsOneWidget);
        expect(find.text('건너뛰기'), findsOneWidget);
      });

      testWidgets('still loses to a label written on the tour itself', (WidgetTester tester) async {
        await pump(tester, const Page(nextLabel: Text('Show me')));

        expect(find.text('Show me'), findsOneWidget);
      });
    });
  });
}
