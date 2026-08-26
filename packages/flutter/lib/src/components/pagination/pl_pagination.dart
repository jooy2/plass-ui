/// A row of page numbers.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/button/pl_button.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// One place in the row: a page, or the `…` that stands for the ones left out.
@immutable
sealed class _Slot {
  const _Slot();
}

class _Page extends _Slot {
  const _Page(this.number);

  final int number;
}

class _Ellipsis extends _Slot {
  const _Ellipsis();
}

List<int> _range(int start, int end) {
  return <int>[for (var value = start; value <= end; value += 1) value];
}

/// Which pages the row actually shows.
///
/// The shape every pagination converges on — a fixed run at each end, a window
/// around the current page, and an ellipsis wherever those leave a gap — with
/// one detail that is easy to get wrong and matters: a gap of exactly one page
/// is filled with that page rather than with an ellipsis. `1 … 3 … 9` hides a
/// single number behind a symbol wider than the number it replaced.
///
/// The row is also pinned to a constant number of slots, whatever page it is on:
/// the window slides toward whichever end it is near instead of being clipped by
/// it, so page 1 shows `1 2 3 4 5 … 20` and page 10 shows `1 … 9 10 11 … 20`.
/// Which slots are pages and which are ellipses changes; how many there are does
/// not. Without that, stepping from page 1 to page 2 would relayout the row and
/// every button would move out from under the pointer that just pressed one.
List<_Slot> _paginationRange(int count, int page, int siblingCount, int boundaryCount) {
  final startPages = _range(1, math.min(boundaryCount, count));
  final endPages = _range(math.max(count - boundaryCount + 1, boundaryCount + 1), count);

  final siblingsStart = math.max(
    math.min(page - siblingCount, count - boundaryCount - siblingCount * 2 - 1),
    boundaryCount + 2,
  );
  final siblingsEnd = math.min(
    math.max(page + siblingCount, boundaryCount + siblingCount * 2 + 2),
    endPages.isNotEmpty ? endPages.first - 2 : count - 1,
  );

  return <_Slot>[
    for (final number in startPages) _Page(number),

    // An ellipsis when more than one page is hidden, the page itself when
    // exactly one is, and nothing when none is.
    if (siblingsStart > boundaryCount + 2)
      const _Ellipsis()
    else if (boundaryCount + 1 < count - boundaryCount)
      _Page(boundaryCount + 1),

    for (final number in _range(siblingsStart, siblingsEnd)) _Page(number),

    if (siblingsEnd < count - boundaryCount - 1)
      const _Ellipsis()
    else if (count - boundaryCount > boundaryCount)
      _Page(count - boundaryCount),

    for (final number in endPages) _Page(number),
  ];
}

/// A row of page numbers.
///
/// ```dart
/// PlPagination(
///   count: 20,
///   page: page,
///   onPageChanged: (int next) => setState(() => page = next),
/// )
/// ```
///
/// Every button in it is a real [PlButton], which is the point: a pagination is
/// not a new kind of control, it is buttons in a row that happen to know about
/// each other. Reusing the widget means the row inherits the glass, the pointer
/// bloom, the press signature, the focus ring and every future change to any of
/// them for free — and it means an `lg` pagination lines up with an `lg` button
/// beside it, because it *is* one.
///
/// [variant] sets how the pages at rest look; the current page is always
/// [PlassVariant.solid], which is the one thing the row has to say without being
/// read. That is why the default here is `ghost` rather than the `solid` a lone
/// button takes — nine panes of tinted glass in a row say that all nine are the
/// primary action.
class PlPagination extends StatelessWidget {
  /// Creates a row.
  const PlPagination({
    required this.count,
    required this.page,
    this.onPageChanged,
    this.variant = PlassVariant.ghost,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.compact,
    this.elevation = 0,
    this.siblingCount = 1,
    this.boundaryCount = 1,
    this.showEdges = false,
    this.showArrows = true,
    this.disabled = false,
    this.label = 'Pagination',
    this.pageLabel = _defaultPageLabel,
    this.previousLabel = 'Previous page',
    this.nextLabel = 'Next page',
    this.firstLabel = 'First page',
    this.lastLabel = 'Last page',
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// How many pages there are. Fewer than two and the whole row draws nothing.
  final int count;

  /// The current page, 1-based.
  final int page;

  /// Called with the page that was chosen.
  final ValueChanged<int>? onPageChanged;

  /// How the pages at rest look.
  final PlassVariant variant;

  /// Height and type scale.
  final PlassSize size;

  /// Semantic colour role.
  final PlassColor color;

  /// How tightly a page button packs its digits. `compact` by default, because
  /// a page number is one or two characters.
  final PlassDensity density;

  /// Drop shadow depth of the page buttons.
  ///
  /// `0` is the default: a row of nine keys each casting its own shadow is nine
  /// shadows.
  final PlassElevation elevation;

  /// How many pages are always shown on either side of the current one.
  final int siblingCount;

  /// How many pages are always shown at each end, whatever the current page is.
  /// `0` drops the first and last page from the row, leaving only the window.
  final int boundaryCount;

  /// Shows the jump-to-first and jump-to-last steppers.
  final bool showEdges;

  /// Shows the previous and next steppers.
  final bool showArrows;

  /// Unavailable. Every button in the row stops answering.
  final bool disabled;

  /// The name the row is announced by. Never drawn.
  ///
  /// The names are parameters rather than being read from a message catalogue
  /// for the same reason a table takes its empty line as one: a library that
  /// shipped translations would have to be told which language a screen is in,
  /// and the screen already knows.
  final String label;

  /// The name of a page button. Never drawn.
  final String Function(int page) pageLabel;

  /// The name of the previous stepper.
  final String previousLabel;

  /// The next one's.
  final String nextLabel;

  /// The jump-to-first stepper's.
  final String firstLabel;

  /// The jump-to-last one's.
  final String lastLabel;

  static String _defaultPageLabel(int page) => 'Page $page';

  @override
  Widget build(BuildContext context) {
    // One page is not a set of pages, and no pages is not a thing to say out
    // loud. A row that draws a lone disabled "1" is a control advertising that
    // it has nothing to do.
    if (count < 2) {
      return const SizedBox.shrink();
    }

    final tokens = PlassTheme.of(context);
    final current = page.clamp(1, count);
    final slots = _paginationRange(count, current, siblingCount, boundaryCount);
    final atStart = current <= 1;
    final atEnd = current >= count;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    void go(int next) {
      final clamped = next.clamp(1, count);

      if (clamped != current) {
        onPageChanged?.call(clamped);
      }
    }

    // Every stepper is icon-only, which gives it the same footprint as a
    // single-digit page — a row whose ends are a different width from its middle
    // reads as two controls pushed together.
    Widget stepper(String name, int to, bool inert, PlassGlyphShape glyph, int quarterTurns) {
      return PlButton(
        variant: variant,
        size: size,
        color: color,
        density: density,
        elevation: elevation,
        disabled: disabled || inert,
        semanticLabel: name,
        onPressed: () => go(to),
        startIcon: PlassGlyph(glyph, quarterTurns: rtl ? -quarterTurns : quarterTurns),
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: gap[size]!,
        children: <Widget>[
          if (showEdges) stepper(firstLabel, 1, atStart, PlassGlyphShape.doubleChevron, 1),
          if (showArrows) stepper(previousLabel, current - 1, atStart, PlassGlyphShape.chevron, 1),
          for (final slot in slots)
            switch (slot) {
              _Page(:final int number) => PlButton(
                // The current page is always filled, whatever the row's resting
                // variant is: it is the one thing here that has to be legible
                // without being read.
                variant: number == current ? PlassVariant.solid : variant,
                size: size,
                color: color,
                density: density,
                elevation: elevation,
                disabled: disabled,
                semanticLabel: pageLabel(number),
                onPressed: () => go(number),
                // The digit is drawn and not read: `semanticLabel` already says
                // "Page 3", and a label that merged both would announce the
                // number twice.
                child: ExcludeSemantics(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              // The ellipsis is punctuation rather than a control that happens
              // to be unavailable, so it is neither a button nor a disabled one.
              _Ellipsis() => ExcludeSemantics(
                child: SizedBox(
                  height: controlHeight[size]!,
                  width: controlHeight[size]!,
                  child: Center(
                    child: PlassGlyph(
                      PlassGlyphShape.ellipsis,
                      size: controlText[size]! * iconScale,
                      color: tokens.mutedFg,
                    ),
                  ),
                ),
              ),
            },
          if (showArrows) stepper(nextLabel, current + 1, atEnd, PlassGlyphShape.chevron, -1),
          if (showEdges) stepper(lastLabel, count, atEnd, PlassGlyphShape.doubleChevron, -1),
        ],
      ),
    );
  }
}
