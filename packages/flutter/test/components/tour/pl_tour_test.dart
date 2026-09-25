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

      testWidgets('takes the focus when it opens, closes on Escape, and hands the focus back', (
        WidgetTester tester,
      ) async {
        final FocusNode opener = FocusNode(debugLabel: 'opener');
        addTearDown(opener.dispose);
        var open = false;
        late StateSetter setOpen;

        await pump(
          tester,
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              setOpen = setState;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Focus(focusNode: opener, child: const Text('Start the tour')),
                  Expanded(
                    child: Page(
                      open: open,
                      onOpenChanged: (bool next) => setState(() => open = next),
                    ),
                  ),
                ],
              );
            },
          ),
        );

        opener.requestFocus();
        await tester.pump();
        expect(opener.hasFocus, isTrue);

        setOpen(() => open = true);
        await tester.pumpAndSettle();

        expect(find.text('Narrow the list'), findsOneWidget);
        expect(opener.hasFocus, isFalse);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(open, isFalse);
        expect(find.text('Narrow the list'), findsNothing);
        expect(opener.hasFocus, isTrue);
      });

      testWidgets('stays as it was when it is closed and opened again in one frame', (
        WidgetTester tester,
      ) async {
        final FocusNode opener = FocusNode(debugLabel: 'opener');
        addTearDown(opener.dispose);
        final ValueNotifier<bool> open = ValueNotifier<bool>(false);
        addTearDown(open.dispose);

        await pump(
          tester,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Focus(focusNode: opener, child: const Text('Start the tour')),
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: open,
                  builder: (BuildContext context, bool value, Widget? child) => Page(open: value),
                ),
              ),
            ],
          ),
        );

        opener.requestFocus();
        await tester.pump();
        open.value = true;
        await tester.pumpAndSettle();

        // The reader has gone on from the card to its Next button.
        final FocusNode next = Focus.of(tester.element(find.text('Next')));
        next.requestFocus();
        await tester.pump();
        expect(next.hasPrimaryFocus, isTrue);

        final Element card = tester.element(find.text('Narrow the list'));
        final List<FocusNode?> moves = <FocusNode?>[];
        void track() => moves.add(FocusManager.instance.primaryFocus);
        FocusManager.instance.addListener(track);
        addTearDown(() => FocusManager.instance.removeListener(track));

        rebuildBeforeDeferredWork(tester, () => open.value = true);
        open.value = false;
        await tester.pump();
        await tester.pump();
        await tester.pump();
        await tester.pumpAndSettle();

        // The same card rather than one built again after a trip out of the
        // overlay, and the focus never handed back to the opener or taken to
        // the card on the way.
        expect(tester.element(find.text('Narrow the list')), same(card));
        expect(moves, isEmpty);
        expect(next.hasPrimaryFocus, isTrue);
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

    group('scrolling', () {
      /// A target two screens down a scroll view, with a tour that brings it up.
      Future<ScrollController> far(WidgetTester tester, {required bool disableAnimations}) async {
        final ScrollController scroll = ScrollController();
        final GlobalKey target = GlobalKey();

        addTearDown(scroll.dispose);

        await tester.pumpWidget(
          host(
            Stack(
              children: <Widget>[
                SingleChildScrollView(
                  controller: scroll,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 1500),
                      SizedBox(key: target, width: 120, height: 32, child: const Text('Far')),
                      const SizedBox(height: 1500),
                    ],
                  ),
                ),
                PlTour(
                  open: true,
                  controller: scroll,
                  steps: <PlTourStep>[PlTourStep(target: target, title: const Text('Down here'))],
                ),
              ],
            ),
            width: 600,
            height: 600,
            overlay: true,
            disableAnimations: disableAnimations,
          ),
        );

        return scroll;
      }

      double offCentre(WidgetTester tester) {
        return (tester.getCenter(find.text('Far').first).dy -
                tester.getCenter(find.byType(SingleChildScrollView)).dy)
            .abs();
      }

      testWidgets('carries the screen to the target over the slow duration', (
        WidgetTester tester,
      ) async {
        final ScrollController scroll = await far(tester, disableAnimations: false);

        // The tour opens after its first frame, and asks for the scroll then.
        await tester.pump();
        await tester.pump();

        expect(scroll.offset, 0);

        await tester.pumpAndSettle();

        expect(offCentre(tester), lessThan(20));
      });

      testWidgets('jumps to the target when the reader has asked for less motion', (
        WidgetTester tester,
      ) async {
        final ScrollController scroll = await far(tester, disableAnimations: true);

        await tester.pump();
        await tester.pump();

        expect(scroll.offset, greaterThan(0));
        expect(offCentre(tester), lessThan(20));

        // The light is read once the jump has been laid out, not left where the
        // target was before it.
        await tester.pump();

        final Path path = clip(tester)!.clipper!.getClip(const Size(600, 600));

        expect(path.contains(tester.getCenter(find.text('Far').first)), isFalse);
      });
    });

    group('the card', () {
      testWidgets('says the next step when the focus stays on Next', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await pump(
          tester,
          Page(
            steps: (GlobalKey filter, GlobalKey export) => <PlTourStep>[
              PlTourStep(
                target: filter,
                title: const Text('Narrow the list'),
                content: const Text('Type here to filter.'),
              ),
              PlTourStep(target: export, title: const Text('Take it with you')),
              const PlTourStep(content: Text('That is everything')),
            ],
          ),
        );

        // The heading names itself and nothing else, with the content beside it
        // rather than inside it.
        expect(
          tester.getSemantics(find.text('Narrow the list')),
          matchesSemantics(label: 'Narrow the list', isHeader: true, isLiveRegion: true),
        );
        expect(
          tester.getSemantics(find.text('Type here to filter.')),
          matchesSemantics(label: 'Type here to filter.'),
        );

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        expect(
          tester.getSemantics(find.text('Take it with you')),
          matchesSemantics(label: 'Take it with you', isHeader: true, isLiveRegion: true),
        );

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        expect(
          tester.getSemantics(find.text('That is everything')),
          matchesSemantics(label: 'That is everything', isLiveRegion: true),
        );

        handle.dispose();
      });

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
