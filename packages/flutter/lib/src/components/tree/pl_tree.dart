/// A hierarchy, opened one branch at a time.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// One node. A branch is a node with [children]; a leaf is one without.
@immutable
class PlTreeNode {
  /// Creates a node.
  const PlTreeNode({
    required this.id,
    required this.label,
    this.icon,
    this.children,
    this.disabled = false,
  });

  /// What identifies it. Unique across the whole tree.
  final String id;

  /// What the row says.
  final Widget label;

  /// A glyph before the label.
  final Widget? icon;

  /// Its own children.
  ///
  /// An **empty list is a branch with nothing in it**, which is not the same as
  /// a leaf: the first opens and shows nothing, the second has no twisty at all.
  /// `null` is the leaf. That is what makes a lazily-loaded tree possible — give
  /// a folder an empty list, and fill it in when [PlTree.onExpandedChanged] says
  /// it was opened.
  final List<PlTreeNode>? children;

  /// In the tree but not selectable, and not a stop for the arrow keys.
  final bool disabled;
}

/// How many rows a press can leave selected.
enum PlTreeSelection {
  /// None. The tree is a browser rather than a chooser — rows still expand and
  /// a press still reports, but nothing stays lit.
  none,

  /// One at a time.
  single,

  /// As many as are pressed.
  multiple,
}

/// How far one level is indented, per size.
const Map<PlassSize, double> _indent = <PlassSize, double>{
  PlassSize.xs: 14,
  PlassSize.sm: 16,
  PlassSize.md: 20,
  PlassSize.lg: 24,
  PlassSize.xl: 28,
};

const Map<PlassDensity, Map<PlassSize, double>> _rowPadding =
    <PlassDensity, Map<PlassSize, double>>{
      PlassDensity.standard: <PlassSize, double>{
        PlassSize.xs: 4,
        PlassSize.sm: 4,
        PlassSize.md: 6,
        PlassSize.lg: 8,
        PlassSize.xl: 10,
      },
      PlassDensity.compact: <PlassSize, double>{
        PlassSize.xs: 2,
        PlassSize.sm: 2,
        PlassSize.md: 4,
        PlassSize.lg: 4,
        PlassSize.xl: 6,
      },
    };

/// One row of the flattened tree — the node, and how deep it sits.
@immutable
class _Row {
  const _Row(this.node, this.level);

  final PlTreeNode node;
  final int level;
}

/// A hierarchy, opened one branch at a time.
///
/// It takes its nodes as **data** rather than as children, which is the opposite
/// of what most of this library does and is the right way round here for one
/// reason: a tree is recursive, and recursion written in widgets is a widget
/// every caller has to write for themselves. `PlTable` takes its columns the
/// same way and for the same reason.
///
/// The keyboard is the tree pattern and it is most of what makes this a tree
/// rather than a nested column: **one tab stop** for the whole thing, the up and
/// down arrows walking the rows that are actually visible, and the left and
/// right arrows opening a branch, stepping into it, and going back out to the
/// parent. A tree where Tab walked four hundred rows would be one nobody reaches
/// the end of.
///
/// ```dart
/// PlTree(
///   items: nodes,
///   expanded: open,
///   onExpandedChanged: (Set<String> next) => setState(() => open = next),
/// )
/// ```
class PlTree extends StatefulWidget {
  /// Creates a tree.
  const PlTree({
    required this.items,
    this.expanded = const <String>{},
    this.onExpandedChanged,
    this.selected = const <String>{},
    this.onSelectedChanged,
    this.selection = PlTreeSelection.single,
    this.onItemPressed,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.semanticLabel,
    super.key,
  });

  /// The whole tree, as data.
  final List<PlTreeNode> items;

  /// The ids of the branches that are open.
  final Set<String> expanded;

  /// Called with the whole open set after a branch is opened or closed.
  final ValueChanged<Set<String>>? onExpandedChanged;

  /// The ids of the selected rows.
  final Set<String> selected;

  /// Called with the whole selection after a row is pressed.
  final ValueChanged<Set<String>>? onSelectedChanged;

  /// How many rows a press can leave selected.
  final PlTreeSelection selection;

  /// Called when a row is pressed, selectable or not.
  final ValueChanged<PlTreeNode>? onItemPressed;

  /// Row height, indent and type scale.
  final PlassSize size;

  /// The family a selected row takes.
  final PlassColor color;

  /// A row's vertical padding, and nothing else.
  final PlassDensity density;

  /// The name a screen reader gives the whole tree.
  final String? semanticLabel;

  @override
  State<PlTree> createState() => _PlTreeState();
}

class _PlTreeState extends State<PlTree> {
  /// One node per row that can hold the focus, kept across rebuilds so the tree
  /// hands `Tab` back to the row it was left on.
  final Map<String, FocusNode> _nodes = <String, FocusNode>{};

  String? _tabStop;

  @override
  void dispose() {
    for (final FocusNode node in _nodes.values) {
      node.dispose();
    }

    super.dispose();
  }

  FocusNode _nodeFor(String id) {
    return _nodes.putIfAbsent(id, () => FocusNode(debugLabel: 'PlTree $id'));
  }

  /// Every row the arrow keys can reach, in the order they are drawn.
  List<_Row> _visible(List<PlTreeNode> items, [int level = 1, List<_Row>? into]) {
    final rows = into ?? <_Row>[];

    for (final PlTreeNode node in items) {
      rows.add(_Row(node, level));

      if (node.children != null && widget.expanded.contains(node.id)) {
        _visible(node.children!, level + 1, rows);
      }
    }

    return rows;
  }

  void _toggle(String id, {bool? open}) {
    final next = Set<String>.from(widget.expanded);
    final shouldOpen = open ?? !next.contains(id);

    if (shouldOpen) {
      next.add(id);
    } else {
      next.remove(id);
    }

    widget.onExpandedChanged?.call(next);
  }

  void _select(PlTreeNode node) {
    if (widget.selection == PlTreeSelection.none) {
      return;
    }

    final Set<String> next;

    if (widget.selection == PlTreeSelection.multiple) {
      next = Set<String>.from(widget.selected);

      if (!next.remove(node.id)) {
        next.add(node.id);
      }
    } else {
      next = <String>{node.id};
    }

    widget.onSelectedChanged?.call(next);
  }

  void _press(PlTreeNode node) {
    if (node.children != null) {
      _toggle(node.id);
    }

    _select(node);
    widget.onItemPressed?.call(node);
  }

  void _focus(String id) {
    setState(() => _tabStop = id);
    _nodeFor(id).requestFocus();
  }

  KeyEventResult _onKey(_Row row, List<_Row> reachable, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final index = reachable.indexWhere((_Row candidate) => candidate.node.id == row.node.id);
    final isBranch = row.node.children != null;
    final isOpen = widget.expanded.contains(row.node.id);

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        if (index + 1 < reachable.length) {
          _focus(reachable[index + 1].node.id);
        }

        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        if (index > 0) {
          _focus(reachable[index - 1].node.id);
        }

        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        // Open, then step in. Two presses rather than one, which is the pattern
        // and is what lets a reader open a branch without leaving the row that
        // told them it was there.
        if (isBranch && !isOpen) {
          _toggle(row.node.id, open: true);
        } else if (isBranch && index + 1 < reachable.length) {
          _focus(reachable[index + 1].node.id);
        }

        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
        if (isBranch && isOpen) {
          _toggle(row.node.id, open: false);

          return KeyEventResult.handled;
        }

        // Out to the parent, which is the nearest row above at a shallower
        // level — the tree is flat by the time the keyboard sees it.
        for (var back = index - 1; back >= 0; back -= 1) {
          if (reachable[back].level < row.level) {
            _focus(reachable[back].node.id);
            break;
          }
        }

        return KeyEventResult.handled;
      case LogicalKeyboardKey.home:
        if (reachable.isNotEmpty) {
          _focus(reachable.first.node.id);
        }

        return KeyEventResult.handled;
      case LogicalKeyboardKey.end:
        if (reachable.isNotEmpty) {
          _focus(reachable.last.node.id);
        }

        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(widget.color);
    final rows = _visible(widget.items);
    final reachable = rows.where((_Row row) => !row.node.disabled).toList(growable: false);

    // The one row the whole tree hands `Tab` to. It follows the focus rather
    // than leading it, so tabbing back into a tree returns to where you left it.
    final current = _tabStop != null && reachable.any((_Row row) => row.node.id == _tabStop)
        ? _tabStop
        : (reachable.isEmpty ? null : reachable.first.node.id);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final _Row row in rows)
            _TreeRow(
              row: row,
              tokens: tokens,
              family: family,
              size: widget.size,
              density: widget.density,
              expanded: row.node.children != null && widget.expanded.contains(row.node.id),
              selected: widget.selected.contains(row.node.id),
              selectable: widget.selection != PlTreeSelection.none,
              focusNode: row.node.disabled ? null : _nodeFor(row.node.id),
              isTabStop: row.node.id == current,
              onPressed: row.node.disabled ? null : () => _press(row.node),
              onFocused: () => setState(() => _tabStop = row.node.id),
              onKey: row.node.disabled ? null : (KeyEvent event) => _onKey(row, reachable, event),
            ),
        ],
      ),
    );
  }
}

class _TreeRow extends StatelessWidget {
  const _TreeRow({
    required this.row,
    required this.tokens,
    required this.family,
    required this.size,
    required this.density,
    required this.expanded,
    required this.selected,
    required this.selectable,
    required this.focusNode,
    required this.isTabStop,
    required this.onPressed,
    required this.onFocused,
    required this.onKey,
  });

  final _Row row;
  final PlassTokens tokens;
  final PlassColorFamily family;
  final PlassSize size;
  final PlassDensity density;
  final bool expanded;
  final bool selected;
  final bool selectable;
  final FocusNode? focusNode;
  final bool isTabStop;
  final VoidCallback? onPressed;
  final VoidCallback onFocused;
  final KeyEventResult Function(KeyEvent)? onKey;

  @override
  Widget build(BuildContext context) {
    final node = row.node;
    final isBranch = node.children != null;

    if (focusNode != null) {
      // Written onto the node itself rather than into a second `Focus` around
      // the one `PlassInteractive` already owns — one `FocusNode` may only be
      // attached to one `Focus`, and the alternative is two focusable nodes per
      // row.
      //
      // `skipTraversal` is what makes the whole tree one tab stop: every row but
      // the current one is out of the Tab order while staying in the focus tree,
      // so the arrow keys can still move to it.
      focusNode!.skipTraversal = !isTabStop;
      focusNode!.onKeyEvent = onKey == null ? null : (FocusNode _, KeyEvent event) => onKey!(event);
    }
    final radius = BorderRadius.circular(PlassTokens.radius[size]!);
    final pad = _rowPadding[density]![size]!;

    final content = Padding(
      padding: EdgeInsetsDirectional.only(
        start: (row.level - 1) * _indent[size]! + 6,
        end: 6,
        top: pad,
        bottom: pad,
      ),
      child: Row(
        children: <Widget>[
          // A leaf keeps the twisty's space rather than losing it, so every
          // label at one level starts on the same edge.
          Opacity(
            opacity: isBranch ? 1 : 0,
            child: PlassGlyph(
              PlassGlyphShape.chevron,
              size: iconSize[size]!,
              color: tokens.mutedFg,
              quarterTurns: expanded ? 0 : -1,
            ),
          ),
          SizedBox(width: gap[size]!),
          if (node.icon != null) ...<Widget>[
            IconTheme.merge(
              data: IconThemeData(size: iconSize[size]!, color: tokens.mutedFg),
              child: node.icon!,
            ),
            SizedBox(width: gap[size]!),
          ],
          Flexible(
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: node.disabled
                    ? tokens.mutedFg
                    : selected
                    ? family.accent
                    : tokens.fg,
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                fontSize: controlTextLeading[size]!.size,
                height: controlTextLeading[size]!.height,
                leadingDistribution: TextLeadingDistribution.even,
                overflow: TextOverflow.ellipsis,
              ),
              child: node.label,
            ),
          ),
        ],
      ),
    );

    Widget body = Semantics(
      container: true,
      button: onPressed != null,
      enabled: !node.disabled,
      expanded: isBranch ? expanded : null,
      selected: selectable ? selected : null,
      child: PlassInteractive(
        onTap: onPressed,
        enabled: !node.disabled,
        interactive: !node.disabled,
        focusNode: focusNode,
        onFocusChange: (bool has) {
          if (has) onFocused();
        },
        builder: (BuildContext context, PlassInteraction state) {
          Widget surface = AnimatedContainer(
            duration: PlassTokens.duration,
            curve: PlassTokens.ease,
            decoration: BoxDecoration(
              color: node.disabled
                  ? null
                  : selected
                  ? family.soft
                  : state.hovered || state.pressed
                  ? family.soft
                  : null,
              borderRadius: radius,
            ),
            child: content,
          );

          if (state.focusVisible) {
            surface = CustomPaint(
              foregroundPainter: PlassFocusRingPainter(color: family.ring, borderRadius: radius),
              child: surface,
            );
          }

          return surface;
        },
      ),
    );

    if (node.disabled) {
      body = Opacity(opacity: 0.5, child: body);
    }

    return body;
  }
}
