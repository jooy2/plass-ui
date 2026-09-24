// That a page can make the library's glass read the backdrop once.
//
// The σ22 blur behind every sheet is the most expensive thing the library
// draws, and a screen with dozens of them — a list of cards, a gallery — paid
// for it once per sheet. Flutter shares the read between filters that carry the
// same `BackdropKey`, which `BackdropFilter.grouped` takes from the nearest
// `BackdropGroup`, and the one read is taken where the first of them is painted.
//
// Where that group goes is the app's decision, because two sheets that overlap
// must not share a key and only the app knows its own layout. What is asserted
// here is that the library opts in, so an app's `BackdropGroup` reaches its
// sheets; that what a surface holds reads the backdrop in a group of its own
// whenever the surface paints something, glass or a fill, so a field on a card
// blurs the card rather than the page; that a layer lifted over the page does
// too; and that the two full-screen barriers stay out of every group, because
// they overlap everything under them by definition.
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/host.dart';

/// Every [RenderBackdropFilter] under [finder], outermost first.
List<RenderBackdropFilter> backdrops(WidgetTester tester, Finder finder) {
  return tester
      .renderObjectList<RenderBackdropFilter>(
        find.descendant(of: finder, matching: find.byType(BackdropFilter)),
      )
      .toList();
}

/// The backdrop key of the first filter under [finder], which is the one the
/// outermost surface there draws for itself.
BackdropKey? keyOf(WidgetTester tester, Finder finder) {
  return backdrops(tester, finder).first.backdropKey;
}

void main() {
  testWidgets('a sheet under a `BackdropGroup` shares its backdrop key', (
    WidgetTester tester,
  ) async {
    final BackdropKey shared = BackdropKey();

    await tester.pumpWidget(
      host(
        BackdropGroup(
          backdropKey: shared,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              PlCard(child: Text('One')),
              PlCard(child: Text('Two')),
            ],
          ),
        ),
      ),
    );

    final List<RenderBackdropFilter> filters = backdrops(tester, find.byType(BackdropGroup));

    expect(filters, isNotEmpty);
    for (final RenderBackdropFilter filter in filters) {
      expect(filter.backdropKey, shared);
    }
  });

  testWidgets('a sheet with no group above it reads the backdrop on its own', (
    WidgetTester tester,
  ) async {
    // The other half of `.grouped`: with no `BackdropGroup` in scope the key is
    // null, which is exactly what the plain constructor gave. Nothing about a
    // page that does not ask for grouping changes.
    await tester.pumpWidget(host(const PlCard(child: Text('One'))));

    final List<RenderBackdropFilter> filters = backdrops(tester, find.byType(PlCard));

    expect(filters, isNotEmpty);
    for (final RenderBackdropFilter filter in filters) {
      expect(filter.backdropKey, isNull);
    }
  });

  group('what a glass surface holds', () {
    Widget page(BackdropKey shared, {String label = 'Name'}) {
      return BackdropGroup(
        backdropKey: shared,
        child: PlCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              PlTextField(label: Text(label), fullWidth: true),
              const PlTextField(label: Text('Email'), fullWidth: true),
            ],
          ),
        ),
      );
    }

    testWidgets("reads the backdrop in a group of its own rather than the page's", (
      WidgetTester tester,
    ) async {
      // A field that shared the card's key would be handed the read taken for
      // the card, before the card was drawn, and blur the page through it.
      final BackdropKey shared = BackdropKey();

      await tester.pumpWidget(host(page(shared), width: 320));

      final BackdropKey? name = keyOf(tester, find.byType(PlTextField).at(0));
      final BackdropKey? email = keyOf(tester, find.byType(PlTextField).at(1));

      // The card still joins the page's group.
      expect(keyOf(tester, find.byType(PlCard)), shared);

      // The fields do not, and they share one read between them.
      expect(name, isNotNull);
      expect(name, isNot(shared));
      expect(email, same(name));
    });

    testWidgets('keeps that group across a rebuild', (WidgetTester tester) async {
      final BackdropKey shared = BackdropKey();

      await tester.pumpWidget(host(page(shared), width: 320));
      final BackdropKey? before = keyOf(tester, find.byType(PlTextField).first);

      await tester.pumpWidget(host(page(shared, label: 'Full name'), width: 320));
      final BackdropKey? after = keyOf(tester, find.byType(PlTextField).first);

      expect(after, isNotNull);
      expect(after, same(before));
    });

    testWidgets('reads the backdrop in a group of its own on a glass button too', (
      WidgetTester tester,
    ) async {
      final BackdropKey shared = BackdropKey();

      await tester.pumpWidget(
        host(
          BackdropGroup(
            backdropKey: shared,
            child: PlButton(
              onPressed: () {},
              variant: PlassVariant.glass,
              endIcon: const PlBadge(variant: PlassVariant.glass, content: Text('3')),
              child: const Text('Inbox'),
            ),
          ),
        ),
      );

      expect(keyOf(tester, find.byType(PlButton)), shared);

      final BackdropKey? badge = keyOf(tester, find.byType(PlBadge));

      expect(badge, isNotNull);
      expect(badge, isNot(shared));
    });
  });

  group('what a filled surface holds', () {
    testWidgets('reads the backdrop in a group of its own on a solid container', (
      WidgetTester tester,
    ) async {
      // A solid alert paints a gradient and no glass. A glass button on it that
      // shared the page's key would be handed a read taken before the gradient
      // was drawn, and blur the page through the alert.
      final BackdropKey shared = BackdropKey();

      await tester.pumpWidget(
        host(
          BackdropGroup(
            backdropKey: shared,
            child: PlAlert(
              variant: PlassVariant.solid,
              title: const Text('Saved'),
              action: PlButton(
                onPressed: () {},
                variant: PlassVariant.glass,
                child: const Text('Undo'),
              ),
            ),
          ),
          width: 480,
        ),
      );

      final BackdropKey? button = keyOf(tester, find.byType(PlButton));

      expect(button, isNotNull);
      expect(button, isNot(shared));
    });

    testWidgets('reads the backdrop in a group of its own on a solid button', (
      WidgetTester tester,
    ) async {
      final BackdropKey shared = BackdropKey();

      await tester.pumpWidget(
        host(
          BackdropGroup(
            backdropKey: shared,
            child: PlButton(
              onPressed: () {},
              endIcon: const PlBadge(variant: PlassVariant.glass, content: Text('3')),
              child: const Text('Inbox'),
            ),
          ),
        ),
      );

      final BackdropKey? badge = keyOf(tester, find.byType(PlBadge));

      expect(badge, isNotNull);
      expect(badge, isNot(shared));
    });

    testWidgets('passes the group through on a ghost key until its wash arrives', (
      WidgetTester tester,
    ) async {
      // A ghost key paints nothing at rest, so what it holds reads where the
      // rest of the page does. Under the pointer it paints a wash, and from
      // then on what it holds has to read the wash.
      final BackdropKey shared = BackdropKey();

      await tester.pumpWidget(
        host(
          BackdropGroup(
            backdropKey: shared,
            child: PlButton(
              onPressed: () {},
              variant: PlassVariant.ghost,
              endIcon: const PlBadge(variant: PlassVariant.glass, content: Text('3')),
              child: const Text('Inbox'),
            ),
          ),
        ),
      );

      expect(keyOf(tester, find.byType(PlBadge)), shared);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.byType(PlButton)));
      addTearDown(mouse.removePointer);
      await tester.pumpAndSettle();

      final BackdropKey? hovered = keyOf(tester, find.byType(PlBadge));

      expect(hovered, isNotNull);
      expect(hovered, isNot(shared));
    });

    testWidgets('keeps the editor of a ghost field when the focus brings its wash', (
      WidgetTester tester,
    ) async {
      // The group stays in the tree and only its key changes. One that came and
      // went with the wash would build the editor again from scratch the moment
      // the field was focused, and drop the focus with it.
      final TextEditingController controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        host(
          PlTextField(
            label: const Text('Name'),
            variant: PlassVariant.ghost,
            controller: controller,
          ),
          width: 320,
        ),
      );

      final EditableTextState before = tester.state(find.byType(EditableText));

      await tester.tap(find.byType(EditableText));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'Ada');
      await tester.pumpAndSettle();

      final EditableTextState after = tester.state(find.byType(EditableText));

      expect(after, same(before));
      expect(after.widget.focusNode.hasFocus, isTrue);
      expect(controller.text, 'Ada');
    });
  });

  testWidgets("a popup reads the backdrop in a group of its own, not in its anchor's", (
    WidgetTester tester,
  ) async {
    // An `OverlayPortal` child sits under the widget that opened it, so the
    // popup would otherwise join the group its trigger reads in — and be handed
    // the read taken when the trigger was drawn, under everything painted since.
    final BackdropKey shared = BackdropKey();

    await tester.pumpWidget(
      host(
        BackdropGroup(
          backdropKey: shared,
          child: PlCard(
            child: PlPopover(
              open: true,
              trigger: PlButton(
                onPressed: () {},
                variant: PlassVariant.glass,
                child: const Text('Explain'),
              ),
              child: const Text('The base rate plus your plan.'),
            ),
          ),
        ),
        overlay: true,
      ),
    );
    await tester.pumpAndSettle();

    final BackdropKey? trigger = keyOf(tester, find.byType(PlButton));
    final Set<BackdropKey?> keys = tester
        .renderObjectList<RenderBackdropFilter>(find.byType(BackdropFilter))
        .map((RenderBackdropFilter filter) => filter.backdropKey)
        .toSet();

    // The card, the trigger on it and the popup: three reads, none shared.
    expect(keys, hasLength(3));
    expect(keys, containsAll(<BackdropKey?>[shared, trigger]));
    expect(keys, isNot(contains(null)));
  });

  testWidgets("a tour's dimming and its card stay out of the page's group", (
    WidgetTester tester,
  ) async {
    final BackdropKey shared = BackdropKey();

    await tester.pumpWidget(
      host(
        BackdropGroup(
          backdropKey: shared,
          child: const PlTour(
            open: true,
            scrollIntoView: false,
            steps: <PlTourStep>[PlTourStep(title: Text('Welcome'))],
          ),
        ),
        width: 600,
        height: 700,
        overlay: true,
      ),
    );
    await tester.pumpAndSettle();

    final List<BackdropKey?> keys = tester
        .renderObjectList<RenderBackdropFilter>(find.byType(BackdropFilter))
        .map((RenderBackdropFilter filter) => filter.backdropKey)
        .toList();

    expect(keys, contains(null));
    expect(keys.where((BackdropKey? key) => key != null), isNotEmpty);
    expect(keys, isNot(contains(shared)));
  });

  testWidgets("a modal's barrier and its sheet stay out of the page's group", (
    WidgetTester tester,
  ) async {
    // A barrier covers the viewport, so it overlaps every sheet under it and
    // the sheet laid over it. A `BackdropGroup` is inherited and an
    // `OverlayPortal` child sits under the widget that opened it, so the layer
    // has to refuse the group the app put around the page, and the barrier has
    // to refuse the layer's own.
    final BackdropKey shared = BackdropKey();

    await tester.pumpWidget(
      host(
        BackdropGroup(
          backdropKey: shared,
          child: PlModal(open: true, title: const Text('Sure?'), child: const Text('Body')),
        ),
        overlay: true,
      ),
    );
    await tester.pumpAndSettle();

    final List<BackdropKey?> keys = tester
        .renderObjectList<RenderBackdropFilter>(find.byType(BackdropFilter))
        .map((RenderBackdropFilter filter) => filter.backdropKey)
        .toList();

    // The barrier reads on its own, and the modal's sheet reads in the layer's
    // group, which is neither the page's nor nothing.
    expect(keys, contains(null));
    expect(keys.where((BackdropKey? key) => key != null), isNotEmpty);
    expect(keys, isNot(contains(shared)));
  });
}
