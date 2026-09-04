/// A table of contents that follows the reader down the page.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// One heading in the list.
@immutable
class PlAnchorItem {
  /// Creates an entry.
  const PlAnchorItem({required this.target, required this.label, this.depth = 0});

  /// The heading this entry points at.
  ///
  /// A [GlobalKey] on the widget itself rather than a fragment, because a
  /// Flutter screen has no URL to point into: what a list tracks here is a
  /// render object's position, and a key is the only handle on one.
  final GlobalKey target;

  /// What the row says.
  final Widget label;

  /// How deep the heading sits, from `0`. Only the indent depends on it.
  final int depth;
}

/// How far one level of depth indents a row.
const double _indent = 12;

/// A table of contents that follows the reader down the page.
///
/// ```dart
/// PlAnchor(
///   controller: _scroll,
///   items: <PlAnchorItem>[
///     PlAnchorItem(target: _intro, label: const Text('Introduction')),
///     PlAnchorItem(target: _install, label: const Text('Install'), depth: 1),
///   ],
/// )
/// ```
///
/// It takes its headings as **data** rather than as children, which is the
/// opposite of most of this package and the right way round here: a table of
/// contents is generated, and the thing that generates it produces a flat list
/// in document order with a level on each entry.
///
/// **It is a flat list and not a nested one**, and that is a decision rather
/// than a shortcut. Real documents skip levels — a section followed by a
/// sub-sub-section — so a nesting built from a flat list is a guess at a shape
/// nobody wrote. The depth is carried by the indent, and the reading order is
/// the document's own.
///
/// The tracking is the widget. What is lit is **the last heading whose top has
/// passed the reading line**, not whichever heading happens to be on screen:
/// three can be visible at once, and the one the reader is inside is the highest
/// of them that is already above them. [offset] is where that line sits — the
/// height of whatever is pinned over the page — and without it a heading goes on
/// counting as the *next* one after it has slid out of sight behind the bar.
class PlAnchor extends StatefulWidget {
  /// Creates a table of contents.
  const PlAnchor({
    required this.items,
    this.controller,
    this.active,
    this.offset = 0,
    this.onSelect,
    this.label,
    this.semanticLabel = 'On this page',
    this.size,
    this.color,
    super.key,
  });

  /// The headings, in the order they appear on the screen.
  final List<PlAnchorItem> items;

  /// The scroll the list is following.
  ///
  /// Without one the list still draws and still moves the screen when a row is
  /// pressed; it simply lights nothing, because there is nothing to measure
  /// against.
  final ScrollController? controller;

  /// The item that is lit, taking the tracking over.
  ///
  /// For a list driven by something other than the scroll. Leaving it out is
  /// the ordinary case and the reason the widget exists.
  final PlAnchorItem? active;

  /// How far below the top of the viewport the reading line sits, in logical
  /// pixels. The height of whatever is pinned over the page.
  final double offset;

  /// Called with the item that was pressed, before the screen moves.
  final ValueChanged<PlAnchorItem>? onSelect;

  /// A heading for the list itself. Drawn above it.
  final Widget? label;

  /// What a screen reader calls the list.
  final String semanticLabel;

  /// The type scale of the rows.
  final PlassSize? size;

  /// The family the lit row takes.
  final PlassColor? color;

  @override
  State<PlAnchor> createState() => _PlAnchorState();
}

class _PlAnchorState extends State<PlAnchor> {
  PlAnchorItem? _tracked;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_measure);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(PlAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_measure);
      widget.controller?.addListener(_measure);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_measure);
    super.dispose();
  }

  /// Which heading is being read, given where the page is scrolled to.
  ///
  /// Two ends need saying separately. Above the first heading nothing is lit,
  /// because the reader has not reached a section yet. At the very bottom the
  /// last item is lit whatever the measurement says: a short final section never
  /// reaches the line, and a list that could not light its own last row goes
  /// dead exactly where a reader is looking for it.
  void _measure() {
    final controller = widget.controller;

    if (!mounted || controller == null || !controller.hasClients || widget.active != null) {
      return;
    }

    final position = controller.position;

    // Only where there is something to scroll: a screen that fits is *always*
    // at its own bottom, and lighting the last row there would say a reader had
    // reached the end before they had read anything.
    final bool scrollable = position.maxScrollExtent > 0;

    if (scrollable && position.pixels >= position.maxScrollExtent - 1 && widget.items.isNotEmpty) {
      _set(widget.items.last);

      return;
    }

    final RenderObject? viewport = context.findRenderObject();

    if (viewport == null) {
      return;
    }

    PlAnchorItem? current;

    for (final PlAnchorItem item in widget.items) {
      final BuildContext? target = item.target.currentContext;
      final RenderObject? box = target?.findRenderObject();

      if (box == null || !box.attached) {
        continue;
      }

      // Against the scroll view rather than against the window: a list pinned
      // beside the page moves with it, and measuring from the list itself would
      // make every answer depend on where the list happens to be.
      final double top = (box as RenderBox)
          .localToGlobal(Offset.zero, ancestor: position.context.storageContext.findRenderObject())
          .dy;

      if (top - widget.offset <= 1) {
        current = item;
      }
    }

    _set(current);
  }

  void _set(PlAnchorItem? next) {
    if (_tracked == next) {
      return;
    }

    setState(() => _tracked = next);
  }

  void _press(PlAnchorItem item) {
    widget.onSelect?.call(item);

    final BuildContext? target = item.target.currentContext;

    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: PlassTokens.durationSlow,
        curve: PlassTokens.ease,
        alignment: 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.sm;
    final color = widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final text = controlTextLeading[size]!;
    final current = widget.active ?? _tracked;

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: <Widget>[
          if (widget.label != null)
            DefaultTextStyle.merge(
              style: TextStyle(
                color: tokens.fg,
                fontSize: text.size,
                height: text.height,
                fontWeight: FontWeight.w600,
              ),
              child: Semantics(header: true, child: widget.label!),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: <Widget>[
              for (final PlAnchorItem item in widget.items)
                _Row(
                  item: item,
                  lit: identical(item, current),
                  family: family,
                  tokens: tokens,
                  text: text,
                  onPressed: () => _press(item),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One row of the list.
class _Row extends StatelessWidget {
  const _Row({
    required this.item,
    required this.lit,
    required this.family,
    required this.tokens,
    required this.text,
    required this.onPressed,
  });

  final PlAnchorItem item;
  final bool lit;
  final PlassColorFamily family;
  final PlassTokens tokens;
  final PlassTextScale text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PlassInteractive(
      onTap: onPressed,
      cursor: SystemMouseCursors.click,
      builder: (BuildContext context, PlassInteraction state) {
        return AnimatedContainer(
          duration: PlassTokens.duration,
          curve: PlassTokens.ease,
          padding: EdgeInsetsDirectional.only(
            start: 8 + item.depth * _indent,
            end: 8,
            top: 4,
            bottom: 4,
          ),
          decoration: BoxDecoration(
            color: lit
                ? family.soft
                : state.hovered
                ? tokens.glassHover
                : null,
            borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.xs]!),
            border: BorderDirectional(
              start: BorderSide(color: lit ? family.accent : const Color(0x00000000), width: 2),
            ),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: lit ? family.accent : tokens.mutedFg,
              fontSize: text.size,
              height: text.height,
              fontWeight: lit ? FontWeight.w500 : FontWeight.w400,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
            // `selected` rather than a role: a table of contents row is where
            // the reader is *within* the document, which is what
            // `aria-current="location"` says in the React build.
            child: Semantics(selected: lit, child: item.label),
          ),
        );
      },
    );
  }
}
