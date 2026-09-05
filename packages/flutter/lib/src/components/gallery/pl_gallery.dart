/// A set of pictures, arranged.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/aspect_ratio/pl_aspect_ratio.dart';
import 'package:plass_ui/src/components/icon_button/pl_icon_button.dart';
import 'package:plass_ui/src/components/image/pl_image.dart';
import 'package:plass_ui/src/components/overlay/pl_overlay.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/gallery.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

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
  /// Nowhere. The words are still read out.
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

  String _where(int index, int total) => widget.itemLabel?.call(index, total) ?? '$index of $total';

  double _ratioOf(PlGalleryItem item) {
    final double? own = item.ratio;

    return own != null && own > 0 ? own : widget.ratio;
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
        ? BorderRadius.circular(PlassTokens.radius[size]!)
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
            return _grid(lanes, gap, width, radius, size, tokens, square: true);
          case PlGalleryLayout.masonry:
            return _masonry(lanes, gap, radius, size, tokens);
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

  Widget _grid(
    int lanes,
    double gap,
    double width,
    BorderRadius radius,
    PlassSize size,
    PlassTokens tokens, {
    required bool square,
  }) {
    final double cell = (width - gap * (lanes - 1)) / lanes;
    final rows = <Widget>[];

    for (int start = 0; start < widget.items.length; start += lanes) {
      final children = <Widget>[];

      for (int at = start; at < start + lanes; at += 1) {
        if (at > start) {
          children.add(SizedBox(width: gap));
        }

        children.add(
          SizedBox(
            width: cell,
            child: at < widget.items.length
                ? _tile(at, radius, size, tokens, ratio: widget.ratio)
                : const SizedBox.shrink(),
          ),
        );
      }

      if (rows.isNotEmpty) {
        rows.add(SizedBox(height: gap));
      }

      rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: children));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }

  Widget _masonry(int lanes, double gap, BorderRadius radius, PlassSize size, PlassTokens tokens) {
    final List<double> ratios = widget.items.map(_ratioOf).toList();
    final List<List<int>> dealt = dealColumns(ratios, lanes);
    final columns = <Widget>[];

    for (int lane = 0; lane < dealt.length; lane += 1) {
      if (lane > 0) {
        columns.add(SizedBox(width: gap));
      }

      final stack = <Widget>[];

      for (final int at in dealt[lane]) {
        if (stack.isNotEmpty) {
          stack.add(SizedBox(height: gap));
        }

        stack.add(_tile(at, radius, size, tokens, ratio: _ratioOf(widget.items[at])));
      }

      columns.add(
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: stack),
        ),
      );
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: columns);
  }

  Widget _justified(
    double gap,
    double width,
    BorderRadius radius,
    PlassSize size,
    PlassTokens tokens,
  ) {
    final List<double> ratios = widget.items.map(_ratioOf).toList();
    final List<PlassJustifiedRow> rows = justifyRows(ratios, width, widget.rowHeight, gap);
    final children = <Widget>[];

    for (final PlassJustifiedRow row in rows) {
      if (children.isNotEmpty) {
        children.add(SizedBox(height: gap));
      }

      final tiles = <Widget>[];

      for (final int at in row.indexes) {
        if (tiles.isNotEmpty) {
          tiles.add(SizedBox(width: gap));
        }

        tiles.add(
          SizedBox(
            width: row.height * ratios[at],
            height: row.height,
            child: _tile(at, radius, size, tokens, ratio: null),
          ),
        );
      }

      children.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: tiles));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
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
    final double cell = (width - gap * (lanes - 1)) / lanes;

    int lastRow = 0;

    for (final PlassQuiltCell placed in cells) {
      final int bottom = placed.row + placed.rowSpan;

      if (bottom > lastRow) {
        lastRow = bottom;
      }
    }

    return SizedBox(
      width: width,
      height: lastRow * widget.rowHeight + (lastRow - 1) * gap,
      child: Stack(
        children: <Widget>[
          for (int at = 0; at < cells.length; at += 1)
            PositionedDirectional(
              // The quilt is packed in reading order, so the first column is the
              // *start* edge — which puts the first picture under a right-to-left
              // reader's eye rather than at the far side of the wall.
              start: cells[at].column * (cell + gap),
              top: cells[at].row * (widget.rowHeight + gap),
              width: cells[at].columnSpan * cell + (cells[at].columnSpan - 1) * gap,
              height: cells[at].rowSpan * widget.rowHeight + (cells[at].rowSpan - 1) * gap,
              child: _tile(at, radius, size, tokens, ratio: null),
            ),
        ],
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
      final Widget picture = PlImage(
        image: item.image,
        semanticLabel: item.semanticLabel,
        ratio: ratio,
        fit: PlAspectFit.cover,
        rounded: false,
        size: size,
        color: _color,
      );

      return ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: ratio == null ? StackFit.expand : StackFit.loose,
          children: <Widget>[
            AnimatedScale(
              scale: widget.hover == PlGalleryHover.zoom && lit ? 1.06 : 1,
              duration: PlassTokens.duration,
              curve: PlassTokens.ease,
              child: AnimatedOpacity(
                opacity: widget.hover == PlGalleryHover.dim && lit ? 0.82 : 1,
                duration: PlassTokens.duration,
                curve: PlassTokens.ease,
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
                  duration: PlassTokens.duration,
                  curve: PlassTokens.ease,
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
      excludeSemantics: true,
      child: PlassInteractive(
        onTap: () => _choose(index),
        builder: (BuildContext context, PlassInteraction state) {
          final bool lit = state.hovered || state.pressed || state.focusVisible;

          Widget tile = AnimatedContainer(
            duration: PlassTokens.duration,
            curve: PlassTokens.ease,
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: widget.hover == PlGalleryHover.lift && lit
                  ? tokens.elevation(2)
                  : const <BoxShadow>[],
            ),
            child: body(lit),
          );

          if (state.focusVisible) {
            tile = CustomPaint(
              foregroundPainter: PlassFocusRingPainter(
                color: tokens.family(_color).ring,
                borderRadius: radius,
              ),
              child: tile,
            );
          }

          return tile;
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
                              maxHeight: MediaQuery.sizeOf(context).height * 0.8,
                              maxWidth: MediaQuery.sizeOf(context).width * 0.9,
                            ),
                            child: Image(
                              // Keyed on the picture, so moving to the next one
                              // starts its own load rather than showing the
                              // previous file under a new caption.
                              key: ValueKey<String>(current.id ?? '${current.image}'),
                              image: current.full ?? current.image,
                              fit: BoxFit.contain,
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
