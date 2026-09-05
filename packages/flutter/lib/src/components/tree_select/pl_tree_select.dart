/// A value chosen out of a hierarchy rather than out of a list.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/text_field/pl_text_field.dart';
import 'package:plass_ui/src/components/tree/pl_tree.dart';
import 'package:plass_ui/src/internal/picker.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/search.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// How wide the popup stands, and how far down it goes before it scrolls.
const double _popupWidth = 256;
const double _popupMaxHeight = 320;

/// One node of the tree a reader is choosing from.
///
/// A [PlTreeNode]'s answers plus one more: whether the node is one of the
/// answers or only the road to one.
///
/// **Its label is a `String` and a [PlTreeNode]'s is a `Widget`**, which is the
/// same divergence [PlTransferItem] carries and it is here for the same reason.
/// The filter reads the label, and a node whose label the filter cannot read is
/// a node that disappears from a search it could never satisfy. Text is what
/// keeps every node searchable by construction — and it is also what the
/// trigger writes and what a screen reader is handed. The React build takes a
/// node instead and asks for a `searchLabel` beside it; there is no `Intl`-free
/// way to read the words out of a widget, so this side asks for the words.
class PlTreeSelectNode {
  /// Creates a node.
  const PlTreeSelectNode({
    required this.id,
    required this.label,
    this.icon,
    this.children,
    this.disabled = false,
    this.selectable,
  });

  /// What identifies it. Unique across the whole tree.
  final String id;

  /// What the row says, what the filter matches, and what the trigger writes.
  final String label;

  /// A glyph before the label.
  final Widget? icon;

  /// Its own children. An empty list is a **branch** with nothing in it; `null`
  /// is a **leaf**. They are different things.
  final List<PlTreeSelectNode>? children;

  /// In the tree but not selectable, and not a stop for the arrow keys.
  final bool disabled;

  /// Whether this node may itself be chosen.
  ///
  /// Defaults to `true` for a leaf and to [PlTreeSelect.selectableBranches] for
  /// a node that has children. Set it either way to override both.
  final bool? selectable;
}

/// Every node, flattened, so an id can be looked up without walking twice.
Map<String, PlTreeSelectNode> _flatten(
  List<PlTreeSelectNode> items, [
  Map<String, PlTreeSelectNode>? into,
]) {
  final map = into ?? <String, PlTreeSelectNode>{};

  for (final PlTreeSelectNode node in items) {
    map[node.id] = node;

    if (node.children != null) {
      _flatten(node.children!, map);
    }
  }

  return map;
}

/// The nodes that match, and every ancestor of one.
///
/// The ancestors are the point. A tree filtered to bare matches is a list, and a
/// list of leaves is exactly what a tree was chosen over. A node that matched
/// keeps all of its children — you asked for it, so you get what is in it — and
/// a node kept only because something under it matched keeps just that.
List<PlTreeSelectNode> _filter(List<PlTreeSelectNode> items, String needle) {
  final kept = <PlTreeSelectNode>[];

  for (final PlTreeSelectNode node in items) {
    final List<PlTreeSelectNode>? children = node.children == null
        ? null
        : _filter(node.children!, needle);
    final bool hit = searchHaystack(<String>[node.label]).contains(needle);

    if (hit) {
      kept.add(node);
    } else if (children != null && children.isNotEmpty) {
      kept.add(
        PlTreeSelectNode(
          id: node.id,
          label: node.label,
          icon: node.icon,
          children: children,
          disabled: node.disabled,
          selectable: node.selectable,
        ),
      );
    }
  }

  return kept;
}

/// Every branch in a tree — what a filter opens so its matches are visible.
Set<String> _branchIds(List<PlTreeSelectNode> items, [Set<String>? into]) {
  final ids = into ?? <String>{};

  for (final PlTreeSelectNode node in items) {
    if (node.children != null && node.children!.isNotEmpty) {
      ids.add(node.id);
      _branchIds(node.children!, ids);
    }
  }

  return ids;
}

/// A value chosen out of a hierarchy rather than out of a list.
///
/// The gap between a [PlSelect] and a [PlTree]: the first is a flat list behind
/// a field, the second is a hierarchy that shows what it holds but has no field
/// to put it in. A category, a folder, a region and an org chart node are all
/// chosen from a shape a flat list flattens away.
///
/// It is the two of them composed and almost nothing else — the trigger is the
/// shell all the pickers wear, and what is in the popup is a [PlTree] with a
/// [PlTextField] over it. What it adds is the arithmetic between them: which
/// nodes a query keeps, which branches that opens, and which of the ids coming
/// back out of the tree are answers rather than roads.
///
/// ```dart
/// PlTreeSelect(
///   items: regions,
///   value: chosen,
///   onValueChanged: (Set<String> next) => setState(() => chosen = next),
/// )
/// ```
class PlTreeSelect extends StatefulWidget {
  /// Creates a tree select.
  const PlTreeSelect({
    required this.items,
    this.value = const <String>{},
    this.onValueChanged,
    this.multiple = false,
    this.selectableBranches = false,
    this.expanded,
    this.onExpandedChanged,
    this.open,
    this.onOpenChanged,
    this.placeholder,
    this.clearable = false,
    this.closeOnSelect,
    this.searchable = false,
    this.searchLabel,
    this.emptyLabel,
    this.format,
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.startIcon,
    this.fullWidth = false,
    this.readOnly = false,
    this.disabled = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// The whole tree, as data.
  final List<PlTreeSelectNode> items;

  /// The ids of the chosen nodes. Controlled.
  final Set<String> value;

  /// Called with the whole selection after a node is chosen or dropped.
  final ValueChanged<Set<String>>? onValueChanged;

  /// Whether more than one node may be held at once.
  final bool multiple;

  /// Whether a node that has children may itself be chosen.
  ///
  /// Off by default, which is the shape most of these trees have: the branches
  /// are the taxonomy and the leaves are the answers, and a "Europe" held
  /// alongside "France" is usually a data model nobody meant. A node's own
  /// [PlTreeSelectNode.selectable] overrides it either way, and a branch that
  /// cannot be chosen still opens and closes — pressing it is how you get at
  /// what is under it.
  final bool selectableBranches;

  /// The ids of the branches that are open. Leave it out and the picker holds
  /// its own.
  final Set<String>? expanded;

  /// Called with the whole open set after a branch is opened or closed.
  final ValueChanged<Set<String>>? onExpandedChanged;

  /// Whether the popup is up. Leave it out and the picker holds its own.
  final bool? open;

  /// Called when the popup should open or close.
  final ValueChanged<bool>? onOpenChanged;

  /// Shown in the trigger while nothing is chosen.
  final Widget? placeholder;

  /// Offers the × that empties the control.
  final bool clearable;

  /// Closes the popup as soon as a node is chosen. Defaults to `!multiple`.
  final bool? closeOnSelect;

  /// Offers a field above the tree that filters it.
  ///
  /// A match keeps its ancestors, because a node with its parents cut away is a
  /// node the reader cannot place — a "Seoul" under nothing at all does not say
  /// which taxonomy it came out of. Every branch a filter keeps is opened, since
  /// a match folded inside a shut parent is a match nobody was shown.
  final bool searchable;

  /// The word in the filter field.
  final String? searchLabel;

  /// What the popup says when the filter matched nothing.
  final String? emptyLabel;

  /// How the trigger writes what is held. Defaults to the labels, comma-joined.
  final String Function(List<PlTreeSelectNode> chosen)? format;

  /// What the trigger's well is cut into.
  final PlassVariant variant;

  /// Height and type scale.
  final PlassSize? size;

  /// Semantic colour role.
  final PlassColor? color;

  /// Horizontal padding. Never the height.
  final PlassDensity? density;

  /// Drop shadow depth of the **trigger**. `0`, like a [PlTextField].
  final PlassElevation elevation;

  /// Label above the trigger.
  final Widget? label;

  /// Helper text below it.
  final Widget? description;

  /// Error message below it. Its presence also turns the picker invalid.
  final Widget? error;

  /// Forces the invalid state without a message.
  final bool? invalid;

  /// The glyph before the value.
  final Widget? startIcon;

  /// Stretches to the width of the container.
  final bool fullWidth;

  /// The value is shown but cannot be changed, and the popup does not open.
  final bool readOnly;

  /// Unavailable.
  final bool disabled;

  /// The name a screen reader gives the trigger.
  final String? semanticLabel;

  /// Drive focus from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  @override
  State<PlTreeSelect> createState() => _PlTreeSelectState();
}

class _PlTreeSelectState extends State<PlTreeSelect> {
  final TextEditingController _query = TextEditingController();

  bool _ownOpen = false;
  Set<String> _ownExpanded = <String>{};

  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  bool get _open => widget.open ?? _ownOpen;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _setOpen(bool next) {
    // A read-only picker does not open. What it holds is something to read.
    if (next && (widget.disabled || widget.readOnly)) {
      return;
    }

    setState(() {
      _ownOpen = next;

      if (!next) {
        _query.clear();
      }
    });

    widget.onOpenChanged?.call(next);
  }

  bool _isSelectable(PlTreeSelectNode node) {
    if (node.disabled) {
      return false;
    }

    return node.selectable ??
        (node.children != null && node.children!.isNotEmpty ? widget.selectableBranches : true);
  }

  /// What comes back out of the tree, filtered down to the answers.
  ///
  /// A branch that cannot be chosen still expands, so a press on one arrives
  /// here as a selection that has to be turned down rather than as nothing at
  /// all. Turning it down is not the same as clearing: a single-value picker
  /// hands back exactly one id, and treating an unusable one as an empty answer
  /// would empty the field every time somebody opened a folder.
  void _onSelectedChanged(Set<String> next, Map<String, PlTreeSelectNode> byId) {
    if (!widget.multiple) {
      final PlTreeSelectNode? node = next.length == 1 ? byId[next.first] : null;

      if (node == null || !_isSelectable(node)) {
        return;
      }

      widget.onValueChanged?.call(<String>{node.id});

      if (widget.closeOnSelect ?? true) {
        _setOpen(false);
      }

      return;
    }

    final allowed = next.where((String id) {
      final PlTreeSelectNode? node = byId[id];

      return node != null && _isSelectable(node);
    }).toSet();

    if (allowed.length == widget.value.length && allowed.containsAll(widget.value)) {
      return;
    }

    widget.onValueChanged?.call(allowed);

    if (widget.closeOnSelect ?? false) {
      _setOpen(false);
    }
  }

  /// The select's nodes as the tree's, which is where the label becomes a widget.
  List<PlTreeNode> _toTree(List<PlTreeSelectNode> items) {
    return items
        .map(
          (PlTreeSelectNode node) => PlTreeNode(
            id: node.id,
            label: Text(node.label),
            icon: node.icon,
            children: node.children == null ? null : _toTree(node.children!),
            disabled: node.disabled,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final labels = PlassTheme.labelsOf(context);
    final String searchLabel = widget.searchLabel ?? labels.search;
    final String emptyLabel = widget.emptyLabel ?? labels.empty;

    final String needle = searchText(_query.text);
    final bool filtered = needle.isNotEmpty;
    final List<PlTreeSelectNode> shown = filtered ? _filter(widget.items, needle) : widget.items;

    final Map<String, PlTreeSelectNode> byId = _flatten(widget.items);

    // A filter drives the folds itself, and hands them back the moment the
    // field is emptied — the branches the reader had opened are still in
    // whichever state holds them, untouched.
    final Set<String> expanded = filtered ? _branchIds(shown) : (widget.expanded ?? _ownExpanded);

    final List<PlTreeSelectNode> chosen = widget.value
        .map((String id) => byId[id])
        .whereType<PlTreeSelectNode>()
        .toList();

    final String written = widget.format != null
        ? widget.format!(chosen)
        : chosen.map((PlTreeSelectNode node) => node.label).join(', ');

    return PlassPickerShell(
      variant: widget.variant,
      size: _size,
      color: _color,
      density: _density,
      elevation: widget.elevation,
      label: widget.label,
      description: widget.description,
      error: widget.error,
      invalid: widget.invalid,
      startIcon: widget.startIcon,
      fullWidth: widget.fullWidth,
      readOnly: widget.readOnly,
      disabled: widget.disabled,
      semanticLabel: widget.semanticLabel,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      clearable: widget.clearable,
      clearLabel: labels.clear,
      onClear: () => widget.onValueChanged?.call(<String>{}),
      empty: chosen.isEmpty,
      open: _open,
      onOpenChanged: _setOpen,
      display: chosen.isEmpty ? (widget.placeholder ?? const Text('')) : Text(written),
      semanticValue: chosen.isEmpty ? null : written,
      popup: SizedBox(
        width: _popupWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (widget.searchable) ...<Widget>[
              PlTextField(
                controller: _query,
                size: _size,
                color: _color,
                density: _density,
                variant: PlassVariant.ghost,
                fullWidth: true,
                placeholder: searchLabel,
                semanticLabel: searchLabel,
                onChanged: (String _) => setState(() {}),
              ),
              const SizedBox(height: 6),
            ],
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: _popupMaxHeight),
              child: shown.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Text(
                        emptyLabel,
                        style: TextStyle(
                          fontSize: metaText[_size]!,
                          color: PlassTheme.of(context).mutedFg,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: PlTree(
                        items: _toTree(shown),
                        size: _size,
                        color: _color,
                        density: _density,
                        selection: widget.multiple
                            ? PlTreeSelection.multiple
                            : PlTreeSelection.single,
                        selected: widget.value,
                        onSelectedChanged: (Set<String> next) => _onSelectedChanged(next, byId),
                        expanded: expanded,
                        onExpandedChanged: (Set<String> next) {
                          // While a filter is driving the folds, what the tree
                          // reports is the filter's own answer coming back.
                          // Writing it down would leave the reader's branches
                          // open once they cleared the field.
                          if (filtered) {
                            return;
                          }

                          if (widget.expanded == null) {
                            setState(() => _ownExpanded = next);
                          }

                          widget.onExpandedChanged?.call(next);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
