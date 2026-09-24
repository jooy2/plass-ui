/// A set of pictures, arranged.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/aspect_ratio/pl_aspect_ratio.dart';
import 'package:plass_ui/src/components/icon_button/pl_icon_button.dart';
import 'package:plass_ui/src/components/image/pl_image.dart';
import 'package:plass_ui/src/components/overlay/pl_overlay.dart';
import 'package:plass_ui/src/components/skeleton/pl_skeleton.dart';
import 'package:plass_ui/src/internal/decode.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/gallery.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/image.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/near_viewport.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How much of the screen the viewer's picture may take, across and down.
const double _viewerWidth = 0.9;
const double _viewerHeight = 0.8;

/// How the tiles are arranged.
///
/// Four, and they answer four different questions rather than being four looks.
/// [grid] is a contact sheet: every tile the same shape, whatever shape the
/// files are. [masonry] keeps each picture's own proportion and stacks the
/// columns. [justified] keeps the proportions *and* fills every row to the
/// edge, scaling each row to a common height — the arrangement a photograph
/// library uses, and the only one where no tile is cropped and no space is left
/// over. [quilted] is a grid whose tiles may take more than one cell.
enum PlGalleryLayout {
  /// A contact sheet. Every tile the gallery's own ratio.
  grid,

  /// Each picture's own proportion, dealt into columns.
  masonry,

  /// Rows scaled to fill the width, nothing cropped.
  justified,

  /// A grid whose tiles may span more than one cell.
  quilted,
}

/// What a tile does when the pointer is on it.
enum PlGalleryHover {
  /// Nothing.
  none,

  /// A shadow under the frame.
  lift,

  /// The picture darkens.
  dim,

  /// The picture scales inside a frame that stays where it was.
  zoom,
}

/// Where a tile's words go.
enum PlGalleryCaption {
  /// Nowhere. No caption is built, so the title and the description are not read
  /// out either.
  none,

  /// Under the picture.
  below,

  /// Across the foot of it.
  overlay,

  /// Across the foot of it, arriving with the pointer.
  hover,
}

/// One picture in the set.
class PlGalleryItem {
  /// Creates an item.
  const PlGalleryItem({
    required this.image,
    required this.semanticLabel,
    this.id,
    this.title,
    this.description,
    this.full,
    this.ratio,
    this.rotate = 0,
    this.flip = PlImageFlip.none,
    this.position = Alignment.center,
    this.placeholder,
    this.cols = 1,
    this.rows = 1,
  });

  /// The picture.
  final ImageProvider<Object> image;

  /// What the picture says. Required, for the reason [PlImage] requires it.
  final String semanticLabel;

  /// A stable identity. Defaults to the image provider itself.
  final String? id;

  /// The first line of the caption.
  final String? title;

  /// The second, one step down the scale and muted.
  final String? description;

  /// A larger file for the viewer, when the tile is a thumbnail. Falls back to
  /// [image].
  final ImageProvider<Object>? full;

  /// The picture's own proportion — width over height.
  ///
  /// [PlGalleryLayout.masonry] and [PlGalleryLayout.justified] are laid out from
  /// this, and both are laid out *before* anything has loaded, which is the
  /// whole reason it is data rather than a measurement. A set without it falls
  /// back to the gallery's own `ratio`.
  final double? ratio;

  /// Turns the picture clockwise, a quarter at a time, as [PlImage.rotate] does.
  ///
  /// [ratio] stays the file's own proportion. A picture on its side is laid out
  /// on its side in [PlGalleryLayout.masonry] and [PlGalleryLayout.justified],
  /// and in the viewer; a [PlGalleryLayout.grid] tile keeps the gallery's shape,
  /// because that is the shape of the layout.
  final int rotate;

  /// Mirrors the picture, as [PlImage.flip] does.
  final PlImageFlip flip;

  /// Where the picture sits in its tile, as [PlImage.position].
  final Alignment position;

  /// A small copy of the picture to stand in while the file arrives, as
  /// [PlImage.placeholder] takes one.
  final PlImagePlaceholder? placeholder;

  /// How many columns the tile takes in [PlGalleryLayout.quilted].
  final int cols;

  /// How many rows the tile takes in [PlGalleryLayout.quilted].
  final int rows;
}

/// The gap ladder, as lengths.
const Map<PlassSize, double> _gapValues = <PlassSize, double>{
  PlassSize.xs: 4,
  PlassSize.sm: 6,
  PlassSize.md: 8,
  PlassSize.lg: 12,
  PlassSize.xl: 16,
};

/// The wash a caption is written on, so the words survive a pale photograph.
const List<Color> _scrim = <Color>[Color(0xB8000000), Color(0x00000000)];

/// A set of pictures, arranged.
///
/// The four layouts are the widget: everything else — the captions, the pointer
/// treatment, the viewer — is the same in all of them, and choosing between a
/// contact sheet, a masonry, a justified library and a quilt is one parameter
/// rather than four widgets.
///
/// A tile's shape comes from the item's own [PlGalleryItem.ratio], so the
/// arrangement is right before anything has loaded and does not move again as
/// the files arrive — the same bargain [PlImage]'s `ratio` makes one level up.
///
/// **Two of the layouts measure and the React build's do not.** CSS does a
/// justified row with `flex-grow` and a quilt with `grid-auto-flow: dense`;
/// there is no such thing here, so those two pack themselves inside a
/// `LayoutBuilder`. The arrangement is the same; what differs is who computed
/// it.
///
/// ```dart
/// PlGallery(
///   items: photos,
///   layout: PlGalleryLayout.masonry,
///   preview: true,
/// )
/// ```
class PlGallery extends StatefulWidget {
  /// Creates a gallery.
  const PlGallery({
    required this.items,
    this.layout = PlGalleryLayout.grid,
    this.columns = const PlassResponsive<int>(2, sm: 3, lg: 4),
    this.gap,
    this.ratio = 1,
    this.rowHeight = 220,
    this.rounded = true,
    this.fit = PlAspectFit.cover,
    this.letterbox,
    this.caption = PlGalleryCaption.none,
    this.hover = PlGalleryHover.lift,
    this.preview = false,
    this.onItemSelected,
    this.semanticLabel,
    this.itemLabel,
    this.empty,
    this.size,
    this.color,
    super.key,
  });

  /// The pictures, in the order they are drawn.
  final List<PlGalleryItem> items;

  /// How the tiles are arranged.
  final PlGalleryLayout layout;

  /// How many tiles across, per breakpoint. Read by every layout but
  /// [PlGalleryLayout.justified], which decides for itself, row by row.
  final PlassResponsive<int> columns;

  /// The space between tiles. A step of the size ladder by default.
  final double? gap;

  /// The shape of a tile in [PlGalleryLayout.grid], and what an item with no
  /// ratio of its own falls back to everywhere else.
  final double ratio;

  /// How tall a row aims to be in [PlGalleryLayout.justified], and how tall one
  /// cell is in [PlGalleryLayout.quilted].
  final double rowHeight;

  /// Rounds the tiles.
  final bool rounded;

  /// How every picture fills its tile, as [PlImage.fit].
  final PlAspectFit fit;

  /// What fills a tile where [fit] leaves it empty, as [PlImage.letterbox].
  final PlImageLetterbox? letterbox;

  /// Where a tile's [PlGalleryItem.title] and [PlGalleryItem.description] go.
  final PlGalleryCaption caption;

  /// What a tile does under the pointer.
  ///
  /// [PlGalleryHover.zoom] is the one that scales, and it is the exception the
  /// design language names: what moves is a photograph inside a frame that
  /// stays exactly where it was, with no text on it to resample.
  final PlGalleryHover hover;

  /// Opens the picture full size when a tile is chosen, with the rest of the
  /// set an arrow key away.
  final bool preview;

  /// Called when a tile is chosen, whether or not there is a viewer.
  final void Function(PlGalleryItem item, int index)? onItemSelected;

  /// The list's accessible name.
  final String? semanticLabel;

  /// How a tile and the viewer's counter say where in the set they are.
  ///
  /// Left out, it is the theme's [PlassLabels.galleryItem], `2 of 4` in
  /// English.
  final String Function(int index, int total)? itemLabel;

  /// What is drawn when [items] is empty. Nothing at all by default.
  final Widget? empty;

  /// Type scale and radius.
  final PlassSize? size;

  /// Semantic colour role. It reaches the focus ring and the placeholders.
  final PlassColor? color;

  @override
  State<PlGallery> createState() => _PlGalleryState();
}

class _PlGalleryState extends State<PlGallery> {
  int? _openAt;

  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

  String _where(int index, int total) =>
      widget.itemLabel?.call(index, total) ??
      PlassTheme.labelsOf(context).galleryItem(index, total);

  /// The proportion an item is shown at: its own, or the gallery's where it
  /// has none, turned for a picture on its side.
  double _ratioOf(PlGalleryItem item) {
    final double? own = item.ratio;

    return shownRatio(own != null && own > 0 ? own : widget.ratio, item.rotate);
  }

  void _choose(int index) {
    widget.onItemSelected?.call(widget.items[index], index);

    if (widget.preview) {
      setState(() => _openAt = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.empty ?? const SizedBox.shrink();
    }

    final tokens = PlassTheme.of(context);
    final labels = PlassTheme.labelsOf(context);
    final PlassSize size = _size;
    final double gap = widget.gap ?? _gapValues[size]!;
    final BorderRadius radius = widget.rounded
        ? BorderRadius.circular(tokens.radii[size]!)
        : BorderRadius.zero;

    final Widget board = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final PlassBreakpoint breakpoint = PlassBreakpoint.of(MediaQuery.sizeOf(context).width);
        final int lanes = widget.columns.resolve(breakpoint).clamp(1, 24);
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        switch (widget.layout) {
          case PlGalleryLayout.grid:
            return _grid(lanes, gap, width, radius, size, tokens);
          case PlGalleryLayout.masonry:
            return _masonry(lanes, gap, width, radius, size, tokens);
          case PlGalleryLayout.justified:
            return _justified(gap, width, radius, size, tokens);
          case PlGalleryLayout.quilted:
            return _quilted(lanes, gap, width, radius, size, tokens);
        }
      },
    );

    return Semantics(
      container: true,
      label: widget.semanticLabel ?? labels.gallery,
      explicitChildNodes: true,
      child: Stack(
        children: <Widget>[
          board,
          if (widget.preview)
            _Viewer(
              items: widget.items,
              index: _openAt,
              onIndexChanged: (int? next) => setState(() => _openAt = next),
              size: size,
              color: _color,
              label: widget.semanticLabel ?? labels.gallery,
              previousLabel: labels.previous,
              nextLabel: labels.next,
              itemLabel: _where,
            ),
        ],
      ),
    );
  }

  /* -------------------------------------------------------------------------
   * The layouts
   * ---------------------------------------------------------------------- */

  /// The tiles in one list, in the order they were given, with the rows drawn
  /// by [_Rows] rather than built as a `Row` each.
  ///
  /// A `Row` per row made the row a tile sat on part of where it sat in the
  /// tree, so a tile that moved to another row when the number of columns
  /// changed was built again from nothing, as a masonry's tile was when it
  /// changed lanes.
  Widget _grid(
    int lanes,
    double gap,
    double width,
    BorderRadius radius,
    PlassSize size,
    PlassTokens tokens,
  ) {
    // Held at zero, as a masonry's lane is, for a board narrower than its gaps.
    final double cell = math.max(0, (width - gap * (lanes - 1)) / lanes);

    return _Rows(
      rowOf: <int>[for (int at = 0; at < widget.items.length; at += 1) at ~/ lanes],
      gap: gap,
      width: width,
      textDirection: Directionality.of(context),
      children: <Widget>[
        for (int at = 0; at < widget.items.length; at += 1)
          SizedBox(
            width: cell,
            child: _tile(at, radius, size, tokens, ratio: widget.ratio),
          ),
      ],
    );
  }

  /// The tiles in one list, in the order they were given, with the lanes drawn
  /// by [_Lanes] rather than built as a column each.
  ///
  /// A column per lane made the lane a tile was dealt into part of where it sat
  /// in the tree, so a tile that moved to another lane when the number of lanes
  /// changed was built again from nothing: its picture loaded again and the
  /// focus it held was lost. In one list a tile keeps its place whatever lane
  /// it is drawn in, which is what the React build gets from its grid.
  Widget _masonry(
    int lanes,
    double gap,
    double width,
    BorderRadius radius,
    PlassSize size,
    PlassTokens tokens,
  ) {
    final List<double> ratios = widget.items.map(_ratioOf).toList();
    final List<List<int>> dealt = dealColumns(ratios, lanes);
    final List<int> laneOf = List<int>.filled(ratios.length, 0);

    for (int lane = 0; lane < dealt.length; lane += 1) {
      for (final int at in dealt[lane]) {
        laneOf[at] = lane;
      }
    }

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: _Lanes(
        count: lanes,
        laneOf: laneOf,
        gap: gap,
        width: width,
        textDirection: Directionality.of(context),
        children: <Widget>[
          for (int at = 0; at < ratios.length; at += 1)
            _inOrder(at, _tile(at, radius, size, tokens, ratio: ratios[at])),
        ],
      ),
    );
  }

  /// A masonry or quilted tile, handed back its place in the list.
  ///
  /// A screen reader and the Tab key both order what they visit by where it is
  /// drawn, not by where it sits in the tree, and neither board is drawn in the
  /// list's order. A masonry's lanes are not rows: the screen reader read down
  /// the first lane before it started the second, and Tab took whichever tile
  /// was nearest the top, which is a different order again once the shapes are
  /// mixed. A quilt is packed densely, so a later, narrower tile fills a gap an
  /// earlier, wider one left, and is drawn before it. Each tile is told its
  /// index instead, so both follow the set as it was given — which is what the
  /// React build gets from keeping its tiles in one list.
  ///
  /// The node is a container so that a tile that is not a button keeps its
  /// picture and its caption as the separate nodes they were, rather than
  /// merging them into one.
  Widget _inOrder(int index, Widget tile) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      sortKey: OrdinalSortKey(index.toDouble()),
      child: FocusTraversalOrder(order: NumericFocusOrder(index.toDouble()), child: tile),
    );
  }

  /// The tiles in one list, drawn on the rows [justifyRows] broke them into.
  ///
  /// The rows are broken again whenever the width changes, so with a `Row` per
  /// row a tile that moved to the next row, or back, was built again.
  Widget _justified(
    double gap,
    double width,
    BorderRadius radius,
    PlassSize size,
    PlassTokens tokens,
  ) {
    final List<double> ratios = widget.items.map(_ratioOf).toList();
    final List<PlassJustifiedRow> rows = justifyRows(ratios, width, widget.rowHeight, gap);
    final rowOf = <int>[];
    final tiles = <Widget>[];

    for (int line = 0; line < rows.length; line += 1) {
      final PlassJustifiedRow row = rows[line];

      for (final int at in row.indexes) {
        rowOf.add(line);
        tiles.add(
          SizedBox(
            width: row.height * ratios[at],
            height: row.height,
            child: _tile(at, radius, size, tokens, ratio: null),
          ),
        );
      }
    }

    return _Rows(
      rowOf: rowOf,
      gap: gap,
      width: width,
      textDirection: Directionality.of(context),
      children: tiles,
    );
  }

  Widget _quilted(
    int lanes,
    double gap,
    double width,
    BorderRadius radius,
    PlassSize size,
    PlassTokens tokens,
  ) {
    final List<({int cols, int rows})> spans = widget.items
        .map((PlGalleryItem item) => (cols: item.cols, rows: item.rows))
        .toList();
    final List<PlassQuiltCell> cells = quiltCells(spans, lanes);
    // Held at zero, as a masonry's lane is, for a board narrower than its gaps.
    final double cell = math.max(0, (width - gap * (lanes - 1)) / lanes);

    int lastRow = 0;

    for (final PlassQuiltCell placed in cells) {
      final int bottom = placed.row + placed.rowSpan;

      if (bottom > lastRow) {
        lastRow = bottom;
      }
    }

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: SizedBox(
        width: width,
        height: lastRow * widget.rowHeight + (lastRow - 1) * gap,
        child: Stack(
          children: <Widget>[
            for (int at = 0; at < cells.length; at += 1)
              PositionedDirectional(
                // The quilt is packed in reading order, so the first column is
                // the *start* edge — which puts the first picture under a
                // right-to-left reader's eye rather than at the far side of the
                // wall.
                start: cells[at].column * (cell + gap),
                top: cells[at].row * (widget.rowHeight + gap),
                width: cells[at].columnSpan * cell + (cells[at].columnSpan - 1) * gap,
                height: cells[at].rowSpan * widget.rowHeight + (cells[at].rowSpan - 1) * gap,
                child: _inOrder(at, _tile(at, radius, size, tokens, ratio: null)),
              ),
          ],
        ),
      ),
    );
  }

  /* -------------------------------------------------------------------------
   * One tile
   * ---------------------------------------------------------------------- */

  Widget _tile(
    int index,
    BorderRadius radius,
    PlassSize size,
    PlassTokens tokens, {
    required double? ratio,
  }) {
    final PlGalleryItem item = widget.items[index];
    final bool words = item.title != null || item.description != null;
    final bool shown = widget.caption != PlGalleryCaption.none && words;
    final bool over =
        widget.caption == PlGalleryCaption.overlay || widget.caption == PlGalleryCaption.hover;

    Widget frame(bool lit) {
      /* Held back until the tile is within a screen of the view, because a
         Flutter picture resolves the moment it is mounted and a board of sixty
         would otherwise ask for sixty decodes before one of them is on screen.
         The web gets the same from `<img loading="lazy">`.

         What stands in the box is what the picture itself draws while it loads,
         so the swap reads as the picture arriving rather than as a second thing
         appearing — and it takes the same box, which on a tile that carries a
         `ratio` means carrying it here too. `PlImage` is what applies one, so a
         stand-in without it would let the board fall in on itself until the
         pictures came. */
      final Widget standIn =
          item.placeholder ?? PlSkeleton(shape: PlSkeletonShape.rect, size: size, color: _color);
      final Widget picture = PlassNearViewport(
        placeholder: ratio == null ? standIn : AspectRatio(aspectRatio: ratio, child: standIn),
        child: PlImage(
          image: item.image,
          semanticLabel: item.semanticLabel,
          ratio: ratio,
          fit: widget.fit,
          letterbox: widget.letterbox,
          rotate: item.rotate,
          flip: item.flip,
          position: item.position,
          placeholder: item.placeholder,
          rounded: false,
          size: size,
          color: _color,
        ),
      );

      return ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: ratio == null ? StackFit.expand : StackFit.loose,
          children: <Widget>[
            AnimatedScale(
              scale: widget.hover == PlGalleryHover.zoom && lit ? 1.06 : 1,
              duration: tokens.motionDuration,
              curve: tokens.motionEase,
              child: AnimatedOpacity(
                opacity: widget.hover == PlGalleryHover.dim && lit ? 0.82 : 1,
                duration: tokens.motionDuration,
                curve: tokens.motionEase,
                child: picture,
              ),
            ),
            if (over && shown)
              PositionedDirectional(
                start: 0,
                end: 0,
                bottom: 0,
                child: AnimatedOpacity(
                  opacity: widget.caption == PlGalleryCaption.hover && !lit ? 0 : 1,
                  duration: tokens.motionDuration,
                  curve: tokens.motionEase,
                  child: _legend(item, size, tokens, over: true),
                ),
              ),
          ],
        ),
      );
    }

    Widget body(bool lit) {
      final Widget framed = frame(lit);

      if (over || !shown) {
        return framed;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ratio == null ? Expanded(child: framed) : framed,
          _legend(item, size, tokens, over: false),
        ],
      );
    }

    if (!widget.preview && widget.onItemSelected == null) {
      return body(false);
    }

    return Semantics(
      button: true,
      label: '${item.semanticLabel} — ${_where(index + 1, widget.items.length)}',
      // The caption is drawn inside the tile, whose own semantics replace
      // everything under it, so the words it shows are said here instead.
      hint: shown ? <String?>[item.title, item.description].nonNulls.join('\n') : null,
      excludeSemantics: true,
      child: PlassInteractive(
        onTap: () => _choose(index),
        builder: (BuildContext context, PlassInteraction state) {
          final bool lit = state.hovered || state.pressed || state.focusVisible;

          // The ring's `CustomPaint` stays in the tree and only its painter
          // comes and goes. Put in only while focused, it moved the tile a
          // level down the tree, which built the tile again and loaded its
          // picture again every time the focus arrived or left.
          return CustomPaint(
            foregroundPainter: state.focusVisible
                ? PlassFocusRingPainter(color: tokens.family(_color).ring, borderRadius: radius)
                : null,
            child: AnimatedContainer(
              duration: tokens.motionDuration,
              curve: tokens.motionEase,
              decoration: BoxDecoration(
                borderRadius: radius,
                boxShadow: widget.hover == PlGalleryHover.lift && lit
                    ? tokens.elevation(2)
                    : const <BoxShadow>[],
              ),
              child: body(lit),
            ),
          );
        },
      ),
    );
  }

  Widget _legend(PlGalleryItem item, PlassSize size, PlassTokens tokens, {required bool over}) {
    final double meta = metaText[size]!;
    final Color titleInk = over ? const Color(0xFFFFFFFF) : tokens.fg;
    final Color bodyInk = over ? const Color(0xCCFFFFFF) : tokens.mutedFg;

    final Widget words = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (item.title != null)
          Text(
            item.title!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: meta, fontWeight: FontWeight.w500, color: titleInk),
          ),
        if (item.description != null)
          Text(
            item.description!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: meta, color: bodyInk),
          ),
      ],
    );

    if (!over) {
      return Padding(padding: const EdgeInsets.only(top: 6), child: words);
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: _scrim,
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(10), child: words),
    );
  }
}

/* ---------------------------------------------------------------------------
 * The lanes and the rows
 * ------------------------------------------------------------------------- */

/// A masonry's tiles, drawn down the lanes they were dealt into.
///
/// The children stay in the order they were given and each is told its lane,
/// so a change in the number of lanes moves a tile without building it again.
/// Every tile is laid out at the width of a lane and as tall as it comes out,
/// under the one before it in the same lane — what a column per lane did, with
/// the lane no longer part of the tree.
class _Lanes extends MultiChildRenderObjectWidget {
  const _Lanes({
    required this.count,
    required this.laneOf,
    required this.gap,
    required this.width,
    required this.textDirection,
    required super.children,
  });

  /// How many lanes there are.
  final int count;

  /// The lane each child goes down, by the child's index.
  final List<int> laneOf;

  final double gap;

  /// The width the lanes share, which the layouts around this one measure too.
  final double width;
  final TextDirection textDirection;

  @override
  _RenderLanes createRenderObject(BuildContext context) {
    return _RenderLanes(
      count: count,
      laneOf: laneOf,
      gap: gap,
      width: width,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderLanes renderObject) {
    renderObject
      ..count = count
      ..laneOf = laneOf
      ..gap = gap
      ..width = width
      ..textDirection = textDirection;
  }
}

/// A grid's or a justified board's tiles, drawn along the rows they fall on.
///
/// The children stay in the order they were given and each is told its row,
/// so a tile that moves to another row when the columns or the width change
/// keeps the element it had. Every tile is laid out at the size it asks for,
/// after the one before it on the same row, and a row is as tall as its
/// tallest tile — what a `Row` per row did, with the row no longer part of the
/// tree.
class _Rows extends MultiChildRenderObjectWidget {
  const _Rows({
    required this.rowOf,
    required this.gap,
    required this.width,
    required this.textDirection,
    required super.children,
  });

  /// The row each child is drawn on, by the child's index. The rows run in the
  /// order the children do.
  final List<int> rowOf;

  final double gap;

  /// The width the rows fill, which the layouts around this one measure too.
  final double width;
  final TextDirection textDirection;

  @override
  _RenderRows createRenderObject(BuildContext context) {
    return _RenderRows(rowOf: rowOf, gap: gap, width: width, textDirection: textDirection);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderRows renderObject) {
    renderObject
      ..rowOf = rowOf
      ..gap = gap
      ..width = width
      ..textDirection = textDirection;
  }
}

class _TilesParentData extends ContainerBoxParentData<RenderBox> {}

/// What [_RenderLanes] and [_RenderRows] share: one list of tiles, the gap
/// between them, the width they divide, and the side a reader starts from.
abstract class _RenderTiles extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TilesParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _TilesParentData> {
  _RenderTiles({required double gap, required double width, required TextDirection textDirection})
    : _gap = gap,
      _width = width,
      _textDirection = textDirection;

  /// The space between two tiles.
  ///
  /// Read as `this.gap` in the subclasses, where a bare `gap` is the table of
  /// the same name in `internal/scales.dart`.
  double _gap;
  double get gap => _gap;
  set gap(double value) {
    if (_gap == value) return;
    _gap = value;
    markNeedsLayout();
  }

  double _width;
  double get width => _width;
  set width(double value) {
    if (_width == value) return;
    _width = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  /// Where a box [extent] wide starts, [start] in from the reader's starting
  /// side.
  ///
  /// Under RTL that side is the right-hand one. Mirrored in layout rather than
  /// in `paint`, because a hit test and a semantics rectangle read the offsets
  /// too.
  double left(double start, double extent) {
    return textDirection == TextDirection.rtl ? width - start - extent : start;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TilesParentData) {
      child.parentData = _TilesParentData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}

class _RenderLanes extends _RenderTiles {
  _RenderLanes({
    required int count,
    required List<int> laneOf,
    required super.gap,
    required super.width,
    required super.textDirection,
  }) : _count = count,
       _laneOf = laneOf;

  int _count;
  int get count => _count;
  set count(int value) {
    if (_count == value) return;
    _count = value;
    markNeedsLayout();
  }

  List<int> _laneOf;
  List<int> get laneOf => _laneOf;
  set laneOf(List<int> value) {
    if (listEquals(_laneOf, value)) return;
    _laneOf = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final double laneWidth = math.max(0, (width - this.gap * (count - 1)) / count);
    final List<double> depths = List<double>.filled(count, 0);
    final List<bool> started = List<bool>.filled(count, false);
    int index = 0;

    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      final _TilesParentData data = child.parentData! as _TilesParentData;
      final int lane = index < laneOf.length ? laneOf[index].clamp(0, count - 1) : 0;
      final double top = started[lane] ? depths[lane] + this.gap : 0;

      child.layout(BoxConstraints.tightFor(width: laneWidth), parentUsesSize: true);

      // The first lane is on the reader's starting side.
      data.offset = Offset(left(lane * (laneWidth + this.gap), laneWidth), top);
      depths[lane] = top + child.size.height;
      started[lane] = true;
      index += 1;
    }

    size = constraints.constrain(Size(width, depths.reduce(math.max)));
  }
}

class _RenderRows extends _RenderTiles {
  _RenderRows({
    required List<int> rowOf,
    required super.gap,
    required super.width,
    required super.textDirection,
  }) : _rowOf = rowOf;

  List<int> _rowOf;
  List<int> get rowOf => _rowOf;
  set rowOf(List<int> value) {
    if (listEquals(_rowOf, value)) return;
    _rowOf = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final BoxConstraints loose = BoxConstraints(maxWidth: width);
    int? row;
    double top = 0;
    double height = 0;
    double along = 0;
    int index = 0;

    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      final _TilesParentData data = child.parentData! as _TilesParentData;
      final int line = index < rowOf.length ? rowOf[index] : (row ?? 0);

      if (row == null) {
        row = line;
      } else if (line != row) {
        row = line;
        top += height + this.gap;
        height = 0;
        along = 0;
      } else {
        along += this.gap;
      }

      child.layout(loose, parentUsesSize: true);

      // A row starts on the reader's starting side, as a `Row` does.
      data.offset = Offset(left(along, child.size.width), top);
      along += child.size.width;
      height = math.max(height, child.size.height);
      index += 1;
    }

    size = constraints.constrain(Size(width, top + height));
  }
}

/// One picture from a [PlGallery], full size, with the rest of the set an arrow
/// key away.
///
/// It is not a `PlCarousel`. A carousel is a set somebody is being shown in
/// order; this is one picture with a way to the next — so there is no autoplay,
/// no wrap, and the arrows stop at the ends rather than looping back to a
/// photograph the reader has already seen.
class _Viewer extends StatelessWidget {
  const _Viewer({
    required this.items,
    required this.index,
    required this.onIndexChanged,
    required this.size,
    required this.color,
    required this.label,
    required this.previousLabel,
    required this.nextLabel,
    required this.itemLabel,
  });

  final List<PlGalleryItem> items;
  final int? index;
  final ValueChanged<int?> onIndexChanged;
  final PlassSize size;
  final PlassColor color;
  final String label;
  final String previousLabel;
  final String nextLabel;
  final String Function(int index, int total) itemLabel;

  void _go(int to) {
    if (to >= 0 && to < items.length) {
      onIndexChanged(to);
    }
  }

  /// [child] turned and mirrored the way [item] asks, as its tile is.
  /// The picture [item] opens as, decoded to fit the viewer's caps.
  ImageProvider<Object> _sized(BuildContext context, PlGalleryItem item) {
    final Size screen = MediaQuery.sizeOf(context);
    final double width = screen.width * _viewerWidth;
    final double height = screen.height * _viewerHeight;
    final bool sideways = isSideways(quartersOf(item.rotate));

    return sizedForDecode(
      item.full ?? item.image,
      width: sideways ? height : width,
      height: sideways ? width : height,
      devicePixelRatio: MediaQuery.maybeDevicePixelRatioOf(context) ?? 1,
      cover: false,
    );
  }

  Widget _pose(PlGalleryItem item, Widget child) {
    return posed(
      child,
      quartersOf(item.rotate),
      mirrorAcross: item.flip == PlImageFlip.horizontal || item.flip == PlImageFlip.both,
      mirrorDown: item.flip == PlImageFlip.vertical || item.flip == PlImageFlip.both,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int? at = index;
    final tokens = PlassTheme.of(context);
    final PlGalleryItem? current = at == null ? null : items[at];

    return PlOverlay(
      open: at != null,
      onOpenChanged: (bool next) {
        if (!next) {
          onIndexChanged(null);
        }
      },
      tone: PlOverlayTone.glass,
      dismissible: true,
      size: size,
      label: label,
      child: current == null
          ? const SizedBox.shrink()
          // The arrows are bound on the sheet rather than on the buttons,
          // because the focus is wherever the reader last put it — and a key
          // that only worked from one place is a key that looks broken
          // everywhere else. Escape is the overlay's own and is left alone.
          : Shortcuts(
              shortcuts: <ShortcutActivator, Intent>{
                const SingleActivator(LogicalKeyboardKey.arrowRight): _StepIntent(1),
                const SingleActivator(LogicalKeyboardKey.arrowLeft): _StepIntent(-1),
              },
              child: Actions(
                actions: <Type, Action<Intent>>{
                  _StepIntent: CallbackAction<_StepIntent>(
                    onInvoke: (_StepIntent intent) {
                      _go(at! + intent.by);

                      return null;
                    },
                  ),
                },
                child: Focus(
                  autofocus: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.sizeOf(context).height * _viewerHeight,
                              maxWidth: MediaQuery.sizeOf(context).width * _viewerWidth,
                            ),
                            // Turned and mirrored the way its tile is, so the
                            // picture opens the way it was shown. A `RotatedBox`
                            // hands the picture the two caps the other way round,
                            // so a turned one fits under them once it is turned.
                            child: _pose(
                              current,
                              Image(
                                // Keyed on the picture, so moving to the next
                                // one starts its own load rather than showing the
                                // previous file under a new caption.
                                key: ValueKey<String>(current.id ?? '${current.image}'),
                                // Decoded to fit the caps it is shown under,
                                // turned with the picture. A `full` file is the
                                // one most worth it: it is the largest there is.
                                image: _sized(context, current),
                                semanticLabel: current.semanticLabel,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          if (items.length > 1)
                            Positioned.directional(
                              textDirection: Directionality.of(context),
                              start: 4,
                              child: PlIconButton(
                                variant: PlassVariant.solid,
                                elevation: 1,
                                size: size,
                                color: color,
                                label: previousLabel,
                                onPressed: at! <= 0 ? null : () => _go(at - 1),
                                icon: const PlassGlyph(PlassGlyphShape.chevron, quarterTurns: 1),
                              ),
                            ),
                          if (items.length > 1)
                            Positioned.directional(
                              textDirection: Directionality.of(context),
                              end: 4,
                              child: PlIconButton(
                                variant: PlassVariant.solid,
                                elevation: 1,
                                size: size,
                                color: color,
                                label: nextLabel,
                                onPressed: at! >= items.length - 1 ? null : () => _go(at + 1),
                                icon: const PlassGlyph(PlassGlyphShape.chevron, quarterTurns: -1),
                              ),
                            ),
                        ],
                      ),
                      if (current.title != null || current.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              if (current.title != null)
                                Text(
                                  current.title!,
                                  style: TextStyle(fontWeight: FontWeight.w500, color: tokens.fg),
                                ),
                              if (current.description != null)
                                Text(
                                  current.description!,
                                  style: TextStyle(
                                    fontSize: metaText[size]!,
                                    color: tokens.mutedFg,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      if (items.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              itemLabel(at! + 1, items.length),
                              style: TextStyle(fontSize: metaText[size]!, color: tokens.mutedFg),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

/// One step through the set, in the direction it carries.
class _StepIntent extends Intent {
  const _StepIntent(this.by);

  final int by;
}
