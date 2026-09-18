// That a page can make the library's glass read the backdrop once.
//
// The σ22 blur behind every sheet is the most expensive thing the library
// draws, and a screen with dozens of them — a list of cards, a gallery — paid
// for it once per sheet. Flutter shares the read between filters that carry the
// same `BackdropKey`, which `BackdropFilter.grouped` takes from the nearest
// `BackdropGroup`.
//
// Where that group goes is the app's decision, because two sheets that overlap
// must not share a key and only the app knows its own layout. What is asserted
// here is that the library opts in, so an app's `BackdropGroup` reaches its
// sheets — and that the two full-screen barriers stay out of it, because they
// overlap everything under them by definition.
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

  testWidgets("a modal's barrier stays out of the page's group", (WidgetTester tester) async {
    // A barrier covers the viewport, so it overlaps every sheet under it. A
    // `BackdropGroup` is inherited and an `OverlayPortal` child sits under the
    // widget that opened it, so this is the one filter that has to refuse the
    // group the app put around the page.
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

    // The modal's own sheet joins the group — it is an `OverlayPortal` child,
    // which sits under the widget that opened it — and the barrier does not.
    expect(keys, contains(shared));
    expect(keys, contains(null));
  });
}
