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
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/icons.dart';

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

/// A glass mark, found again by [key].
Widget glass(String key) {
  return PlBadge(key: ValueKey<String>(key), variant: PlassVariant.glass, content: const Text('3'));
}

/// A fill with a glass mark on it, and how to bring the fill out.
class _Fill {
  _Fill(
    this.name,
    this.build, {
    this.hover = false,
    this.open,
    this.keys = const <LogicalKeyboardKey>[],
    Finder? on,
    Finder? beside,
  }) : on = on ?? find.byKey(const ValueKey<String>('on')),
       beside = beside ?? find.byKey(const ValueKey<String>('beside'));

  /// What the fill is, for the test's name.
  final String name;

  /// The component, with a mark keyed `on` on the fill.
  final Widget Function() build;

  /// Whether the fill appears only under the pointer, which is put on the mark.
  final bool hover;

  /// What is pressed first to open the popup the fill is in.
  final Finder? open;

  /// What is typed once it is open, to light the row the mark is on.
  final List<LogicalKeyboardKey> keys;

  /// The mark on the fill.
  final Finder on;

  /// A mark in the group round the fill but not on the fill, keyed `beside`,
  /// whose read the mark on the fill must not share. Where there is none, the
  /// read it must not share is the page's.
  final Finder beside;
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

  group('what a fill painted outside a surface box holds', () {
    // A row's wash, a table's bands, a window's body: fills a component paints
    // itself rather than through `PlassSurfaceBox`, each with a caller's widget
    // on it. A glass mark there has to read a backdrop the fill is in, so it
    // must not share a read with the page or with a mark beside the fill.
    final PlAnchorItem heading = PlAnchorItem(target: GlobalKey(), label: glass('on'));

    final List<_Fill> fills = <_Fill>[
      _Fill(
        'a striped table row',
        () => PlTable<int>(
          variant: PlassVariant.ghost,
          striped: true,
          rows: const <int>[0, 1],
          columns: <PlTableColumn<int>>[
            PlTableColumn<int>(
              cell: (int row, int index) => row == 1 ? glass('on') : const Text('-'),
            ),
          ],
        ),
      ),
      _Fill(
        'a table row under the pointer',
        () => PlTable<int>(
          variant: PlassVariant.ghost,
          hoverable: true,
          rows: const <int>[0],
          columns: <PlTableColumn<int>>[
            PlTableColumn<int>(cell: (int row, int index) => glass('on')),
          ],
        ),
        hover: true,
      ),
      _Fill(
        "a table's pinned header",
        () => PlTable<int>(
          variant: PlassVariant.ghost,
          stickyHeader: true,
          maxHeight: 200,
          rows: const <int>[0],
          columns: <PlTableColumn<int>>[
            PlTableColumn<int>(header: glass('on'), cell: (int row, int index) => const Text('-')),
          ],
        ),
        // The band is a copy of the header row laid over the real one, which is
        // on no fill of its own.
        on: find.byKey(const ValueKey<String>('on')).last,
        beside: find.byKey(const ValueKey<String>('on')).first,
      ),
      _Fill(
        'a step bullet',
        () => PlStepper(
          active: 0,
          steps: <PlStep>[
            PlStep(label: const Text('Cart'), bullet: glass('on')),
            const PlStep(label: Text('Pay')),
          ],
        ),
      ),
      _Fill(
        'a step under the pointer',
        () => PlStepper(
          active: 1,
          onActiveChanged: (int _) {},
          steps: <PlStep>[
            PlStep(label: glass('on')),
            const PlStep(label: Text('Pay')),
          ],
        ),
        hover: true,
      ),
      _Fill(
        'the chosen bottom navigation item',
        () => PlBottomNavigation<int>(
          variant: PlassVariant.ghost,
          value: 0,
          onChanged: (int _) {},
          items: <PlBottomNavigationItem<int>>[
            PlBottomNavigationItem<int>(value: 0, label: 'Inbox', icon: glass('on')),
            PlBottomNavigationItem<int>(value: 1, label: 'Sent', icon: glass('beside')),
          ],
        ),
      ),
      _Fill(
        'a selected tree row',
        () => PlTree(
          selected: const <String>{'a'},
          items: <PlTreeNode>[
            PlTreeNode(id: 'a', label: glass('on')),
            PlTreeNode(id: 'b', label: glass('beside')),
          ],
        ),
      ),
      _Fill(
        'an open accordion header',
        () => PlAccordion<String>(
          variant: PlassVariant.ghost,
          value: const <String>{'a'},
          items: <PlAccordionItem<String>>[
            PlAccordionItem<String>(value: 'a', title: glass('on')),
            PlAccordionItem<String>(value: 'b', title: glass('beside')),
          ],
          onChanged: (Set<String> _) {},
        ),
      ),
      _Fill(
        'an open collapsible header',
        () => PlCollapsible(
          open: true,
          variant: PlassVariant.ghost,
          title: glass('on'),
          child: const Text('Body'),
        ),
      ),
      _Fill(
        'a selected list row',
        () => PlList(
          variant: PlassVariant.ghost,
          children: <Widget>[
            PlListItem(selected: true, endIcon: glass('on'), child: const Text('Inbox')),
            PlListItem(endIcon: glass('beside'), child: const Text('Sent')),
          ],
        ),
      ),
      _Fill(
        'a highlighted menu row',
        () => PlMenu(
          trigger: (BuildContext context, VoidCallback open, bool isOpen) =>
              PlButton(onPressed: open, child: const Text('Open')),
          items: <PlMenuEntry>[
            PlMenuItem(label: 'Copy', startIcon: glass('on'), onPressed: () {}),
            PlMenuItem(label: 'Paste', startIcon: glass('beside'), onPressed: () {}),
          ],
        ),
        open: find.text('Open'),
        keys: const <LogicalKeyboardKey>[LogicalKeyboardKey.arrowDown],
      ),
      _Fill(
        'a highlighted select option',
        () => PlSelect<String>(
          value: null,
          placeholder: const Text('Pick'),
          onChanged: (String? _) {},
          options: <PlSelectOption<String>>[
            PlSelectOption<String>(value: 'a', label: glass('on')),
            PlSelectOption<String>(value: 'b', label: glass('beside')),
          ],
        ),
        // The first option is lit as the list opens.
        open: find.byWidgetPredicate(
          (Widget widget) => widget is PlassGlyph && widget.shape == PlassGlyphShape.chevron,
        ),
      ),
      _Fill(
        'a breadcrumb step under the pointer',
        () => PlBreadcrumb(
          items: <PlBreadcrumbItem>[
            PlBreadcrumbItem(label: const Text('Home'), startIcon: glass('on'), onPressed: () {}),
            const PlBreadcrumbItem(label: Text('Billing')),
          ],
        ),
        hover: true,
      ),
      _Fill(
        'the current anchor row',
        () => PlAnchor(items: <PlAnchorItem>[heading], active: heading),
      ),
      _Fill(
        "a chip's count",
        () => PlChip(startIcon: glass('beside'), count: glass('on'), child: const Text('Tags')),
      ),
      _Fill('a code block', () => PlCodeBlock(code: 'let a = 1;', title: glass('on'))),
      _Fill(
        'a link preview',
        () => PlChatBubble(
          preview: PlChatBubbleLinkPreview(title: glass('on')),
          child: glass('beside'),
        ),
      ),
      _Fill(
        "a window's title bar",
        () => PlWindowPane(title: const Text('Notes'), actions: glass('on')),
      ),
      _Fill("a window's body", () => PlWindowPane(title: const Text('Notes'), child: glass('on'))),
      _Fill(
        "a device's screen",
        () => PlMockup(device: PlMockupDevice.mobile, width: 240, child: glass('on')),
      ),
      _Fill('a lit surface', () => PlAnimateLighting(paused: true, child: glass('on'))),
      _Fill(
        'the chosen segment of a ghost set',
        () => PlSegmentedButton<int>(
          variant: PlassVariant.ghost,
          value: 0,
          onChanged: (int _) {},
          segments: <PlSegment<int>>[
            PlSegment<int>(value: 0, label: glass('on')),
            const PlSegment<int>(value: 1, label: Text('Week')),
          ],
        ),
      ),
      _Fill(
        'the current disc of a ghost floating bar',
        () => PlFloatingBottomNavigation<int>(
          variant: PlassVariant.ghost,
          value: 0,
          onChanged: (int _) {},
          items: <PlFloatingBottomNavigationItem<int>>[
            PlFloatingBottomNavigationItem<int>(value: 0, label: 'Inbox', icon: glass('on')),
            const PlFloatingBottomNavigationItem<int>(value: 1, label: 'Sent', icon: Text('S')),
          ],
        ),
      ),
      _Fill(
        "a letterboxed picture's fallback",
        () => PlImage(
          image: MemoryImage(Uint8List.fromList(<int>[1, 2, 3, 4])),
          semanticLabel: 'A portrait',
          width: 200,
          height: 120,
          letterbox: const PlImageLetterbox(BoxDecoration(color: Color(0xFF101010))),
          fallback: glass('on'),
        ),
      ),
      _Fill(
        "a spoiler's cover",
        () => PlSpoiler(
          variant: PlassVariant.ghost,
          action: glass('on'),
          child: const Text('The butler did it.'),
        ),
      ),
    ];

    for (final _Fill fill in fills) {
      testWidgets('reads the backdrop in a group of its own on ${fill.name}', (
        WidgetTester tester,
      ) async {
        final BackdropKey shared = BackdropKey();

        await tester.pumpWidget(
          host(
            BackdropGroup(backdropKey: shared, child: fill.build()),
            width: 600,
            height: 600,
            overlay: true,
          ),
        );
        await tester.pumpAndSettle();

        final Finder? open = fill.open;

        if (open != null) {
          await tester.tap(open);
          await tester.pumpAndSettle();
        }

        for (final LogicalKeyboardKey key in fill.keys) {
          await tester.sendKeyEvent(key);
          await tester.pumpAndSettle();
        }

        if (fill.hover) {
          final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
          await mouse.addPointer(location: tester.getCenter(fill.on));
          addTearDown(mouse.removePointer);
          await tester.pumpAndSettle();
        }

        final BackdropKey? on = keyOf(tester, fill.on);
        final BackdropKey? around = fill.beside.evaluate().isEmpty
            ? shared
            : keyOf(tester, fill.beside);

        expect(on, isNotNull);
        expect(on, isNot(around));
      });
    }
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

  testWidgets("a toast reads the backdrop in a group of its own, not in the app's", (
    WidgetTester tester,
  ) async {
    // The stack is laid over the app beside it rather than lifted into an
    // overlay, so a `BackdropGroup` round the provider reaches the stack just
    // as it reaches the app.
    final BackdropKey shared = BackdropKey();
    late PlToastController toasts;

    await tester.pumpWidget(
      host(
        BackdropGroup(
          backdropKey: shared,
          child: PlToastProvider(
            timeout: Duration.zero,
            child: Builder(
              builder: (BuildContext context) {
                toasts = PlToastProvider.of(context);

                return const PlCard(child: Text('Inbox'));
              },
            ),
          ),
        ),
        width: 600,
        height: 400,
      ),
    );

    toasts.show(const PlToast(title: Text('Saved')));
    await tester.pumpAndSettle();

    final Set<BackdropKey?> keys = tester
        .renderObjectList<RenderBackdropFilter>(find.byType(BackdropFilter))
        .map((RenderBackdropFilter filter) => filter.backdropKey)
        .toSet();

    // The card in the app's group, and the toast in one that is neither the
    // app's nor nothing.
    expect(keys, hasLength(2));
    expect(keys, contains(shared));
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
