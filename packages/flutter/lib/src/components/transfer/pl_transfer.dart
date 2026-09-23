/// Two lists and the arrows between them.
library;

import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/checkbox/pl_checkbox.dart';
import 'package:plass_ui/src/components/icon_button/pl_icon_button.dart';
import 'package:plass_ui/src/components/text_field/pl_text_field.dart';
import 'package:plass_ui/src/internal/date.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/search.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// One thing that can be on either side.
@immutable
class PlTransferItem {
  /// Creates a row.
  const PlTransferItem({required this.value, required this.label, this.disabled = false});

  /// What identifies it, and what the pair's value is a list of.
  final String value;

  /// What the row says.
  ///
  /// A `String` rather than a widget, which the React build allows: the filter
  /// reads it, and a row whose label the filter cannot read is a row that
  /// disappears from a search it could never satisfy. Making it text is what
  /// keeps every row searchable by construction.
  final String label;

  /// In the list but not movable.
  final bool disabled;
}

/// The vertical padding of a panel's own strips, per size.
const Map<PlassSize, double> _panelPadY = <PlassSize, double>{
  PlassSize.xs: 4,
  PlassSize.sm: 6,
  PlassSize.md: 8,
  PlassSize.lg: 10,
  PlassSize.xl: 12,
};

/// And of one row inside the list.
const Map<PlassSize, double> _rowPadY = <PlassSize, double>{
  PlassSize.xs: 2,
  PlassSize.sm: 4,
  PlassSize.md: 4,
  PlassSize.lg: 6,
  PlassSize.xl: 8,
};

/// Two lists and the arrows between them: everything that could be chosen on
/// one side, everything that has been on the other.
///
/// ```dart
/// PlTransfer(
///   items: columns,
///   value: chosen,
///   onValueChanged: (List<String> next) => setState(() => chosen = next),
/// )
/// ```
///
/// It is the shape for a choice that is *long* — the columns in a report, the
/// permissions on a role, the people on a channel — where a [PlCombobox] with
/// forty chips in its field stops being readable and a list of forty checkboxes
/// gives no answer to "what did I actually pick". Below about a dozen options,
/// one of those two is the smaller widget.
///
/// **Ticking is not choosing.** The value is which side a row is on; the ticks
/// are which rows the next press will move, and they are a separate piece of
/// state on purpose. The order of [items] is the order both lists show, so a
/// row does not move when it is sent across and back.
class PlTransfer extends StatefulWidget {
  /// Creates a pair of lists.
  const PlTransfer({
    required this.items,
    this.value,
    this.defaultValue = const <String>[],
    this.onValueChanged,
    this.sourceLabel,
    this.targetLabel,
    this.searchable = false,
    this.searchLabel,
    this.emptyLabel,
    this.selectAllLabel,
    this.toTargetLabel,
    this.toSourceLabel,
    this.movedLabel,
    this.height = 220,
    this.disabled = false,
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
    super.key,
  });

  /// Everything that can be on either side, in the order both lists show it.
  final List<PlTransferItem> items;

  /// What is on the trailing side. Passing it makes the pair controlled.
  final List<String>? value;

  /// What starts there, for an uncontrolled one.
  final List<String> defaultValue;

  /// Called when something moves across or back.
  final ValueChanged<List<String>>? onValueChanged;

  /// The heading over the leading list.
  final String? sourceLabel;

  /// And over the trailing one.
  final String? targetLabel;

  /// Puts a filter above each list.
  final bool searchable;

  /// What that filter says while it is empty.
  final String? searchLabel;

  /// What a list with nothing in it says.
  final String? emptyLabel;

  /// What the tick in a list's heading is announced as, before the name of its
  /// list, so the two ticks are told apart by ear. Left out, the theme's
  /// [PlassLabels.transferSelectAll] says the whole sentence and puts the name
  /// where each language puts it.
  final String? selectAllLabel;

  /// What the outward arrow is announced as.
  final String? toTargetLabel;

  /// What the returning arrow is announced as.
  final String? toSourceLabel;

  /// What is announced once rows have moved, given how many and the name of
  /// the list they went to. Left out, it is the theme's
  /// [PlassLabels.transferMoved].
  final String Function(int count, String list)? movedLabel;

  /// How tall each list is.
  final double height;

  /// Nothing can be ticked or moved.
  final bool disabled;

  /// What the two panels are made of. The same shell a field wears: a list
  /// holds a value rather than being pressed.
  final PlassVariant variant;

  /// The checkboxes, the arrows, the type scale and the padding, together.
  final PlassSize? size;

  /// Semantic colour role. It reaches the ticks, the arrows and the focus
  /// rings; neither panel is dyed.
  final PlassColor? color;

  /// Changes the padding and nothing else.
  final PlassDensity? density;

  @override
  State<PlTransfer> createState() => _PlTransferState();
}

class _PlTransferState extends State<PlTransfer> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  late List<String> _ownValue = List<String>.of(widget.defaultValue);
  final Set<String> _ticked = <String>{};
  final TextEditingController _sourceSearch = TextEditingController();
  final TextEditingController _targetSearch = TextEditingController();

  /// One node per row, so the first row a move sends across can take the focus
  /// the pressed arrow is about to lose.
  final Map<String, FocusNode> _rowFocus = <String, FocusNode>{};

  /// And one per list, for a move whose rows did not arrive.
  final FocusNode _sourceListFocus = FocusNode(skipTraversal: true);
  final FocusNode _targetListFocus = FocusNode(skipTraversal: true);

  /// Each list's scroll position. The lists are built lazily, so a row a move
  /// sends further down than the list is scrolled has to be scrolled to before
  /// it exists to take the focus.
  final ScrollController _sourceScroll = ScrollController();
  final ScrollController _targetScroll = ScrollController();

  /// The row widgets of the last build, by value. See [_row].
  final Map<String, _PlTransferRow> _rows = <String, _PlTransferRow>{};

  List<String> get _value => widget.value ?? _ownValue;

  FocusNode _focusFor(String value) => _rowFocus.putIfAbsent(value, FocusNode.new);

  @override
  void didUpdateWidget(PlTransfer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final Set<String> present = widget.items.map((PlTransferItem item) => item.value).toSet();

    // A tick says "this row moves on the next press", and a row that has left
    // the lists is not going to move. Nothing reads a tick without narrowing to
    // the rows first, so an abandoned one draws nothing and counts for nothing
    // — until the value comes back, and comes back ticked. The frame this is
    // called from is about to be built, so there is nothing to notify.
    _ticked.removeWhere((String value) => !present.contains(value));
    _rows.removeWhere((String value, _PlTransferRow row) => !present.contains(value));

    if (_rowFocus.keys.any((String value) => !present.contains(value))) {
      WidgetsBinding.instance.addPostFrameCallback((Duration _) => _releaseRowFocus());
    }
  }

  /// Lets go of the nodes of rows whose values have left [PlTransfer.items].
  ///
  /// Not in [didUpdateWidget] itself: the rows that hold those nodes are still
  /// in the tree until this frame is built, and a node disposed under a mounted
  /// row, or under the focus, breaks the row. Once the frame is done they are
  /// gone, and a value that came back in the meantime keeps its node.
  void _releaseRowFocus() {
    if (!mounted) {
      return;
    }

    final Set<String> present = widget.items.map((PlTransferItem item) => item.value).toSet();

    _rowFocus.removeWhere((String value, FocusNode node) {
      if (present.contains(value)) {
        return false;
      }

      node.dispose();
      return true;
    });
  }

  @override
  void dispose() {
    _sourceSearch.dispose();
    _targetSearch.dispose();
    for (final FocusNode node in _rowFocus.values) {
      node.dispose();
    }
    _sourceListFocus.dispose();
    _targetListFocus.dispose();
    _sourceScroll.dispose();
    _targetScroll.dispose();
    super.dispose();
  }

  void _commit(List<String> next) {
    if (widget.value == null) {
      setState(() => _ownValue = next);
    }

    widget.onValueChanged?.call(next);
  }

  void _tick(String value, bool on) {
    setState(() {
      if (on) {
        _ticked.add(value);
      } else {
        _ticked.remove(value);
      }
    });
  }

  void _tickAll(List<PlTransferItem> rows, bool on) {
    setState(() {
      for (final PlTransferItem row in rows) {
        if (row.disabled) continue;
        if (on) {
          _ticked.add(row.value);
        } else {
          _ticked.remove(row.value);
        }
      }
    });
  }

  /// Moving drops the ticks on what moved and keeps the rest. A row that has
  /// arrived on the other side is not still waiting to be sent there, and a row
  /// the filter was hiding was never part of this press.
  void _move(List<PlTransferItem> moving, {required bool toTarget}) {
    final List<PlTransferItem> moved = moving
        .where((PlTransferItem item) => !item.disabled && _ticked.contains(item.value))
        .toList(growable: false);

    if (moved.isEmpty) return;

    final Set<String> ids = moved.map((PlTransferItem item) => item.value).toSet();
    final Set<String> chosen = _value.toSet();

    final List<String> next = toTarget
        ? widget.items
              .where(
                (PlTransferItem item) => chosen.contains(item.value) || ids.contains(item.value),
              )
              .map((PlTransferItem item) => item.value)
              .toList(growable: false)
        : _value.where((String item) => !ids.contains(item)).toList(growable: false);

    setState(() => _ticked.removeAll(ids));
    _commit(next);

    final PlassLabels words = PlassTheme.labelsOf(context);
    final String list = toTarget
        ? widget.targetLabel ?? words.transferSelected
        : widget.sourceLabel ?? words.transferAvailable;
    final String Function(int count, String list) say = widget.movedLabel ?? words.transferMoved;

    // The pressed arrow is disabled by the rebuild this move causes, since
    // nothing on its side is ticked any more, and a disabled control lets the
    // focus go. So once the frame is laid out the first row that arrived takes
    // it, and the count is said out loud. A controlled pair whose owner refused
    // the rows sends the focus to the list they were sent to and says nothing,
    // because nothing moved.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) return;

      final Set<String> now = _value.toSet();
      final List<String> arrived = moved
          .map((PlTransferItem item) => item.value)
          .where((String value) => now.contains(value) == toTarget)
          .toList(growable: false);

      if (arrived.isEmpty) {
        (toTarget ? _targetListFocus : _sourceListFocus).requestFocus();
        return;
      }

      _focusRow(arrived.first, toTarget: toTarget);

      unawaited(
        SemanticsService.sendAnnouncement(
          View.of(context),
          say(arrived.length, list),
          Directionality.of(context),
        ),
      );
    });
  }

  /// Hands the focus to the row of [value] in the list on one side, and brings
  /// the row into view.
  ///
  /// A list builds only the rows near what it shows, and a node whose row has
  /// not been built cannot take the focus. So a row that arrived further down
  /// than its list is scrolled is scrolled to first, to where it would be if
  /// every row were as tall as the ones built so far, which they are unless a
  /// label wraps, and handed the focus a frame later, once it is there. A row
  /// that is still not there leaves the focus with the list itself, where a
  /// move whose rows were refused puts it too.
  void _focusRow(String value, {required bool toTarget, bool scrolled = false}) {
    final FocusNode? row = _rowFocus[value];
    // A node keeps the context of the last row it was in after that row has
    // left the tree, which is what a moved row's node holds until its row is
    // built again on the other side, so the context has to be a live one.
    final BuildContext? built = row?.context;

    if (row != null && built != null && built.mounted) {
      unawaited(Scrollable.ensureVisible(built));
      row.requestFocus();
      return;
    }

    final ScrollController scroll = toTarget ? _targetScroll : _sourceScroll;
    final List<PlTransferItem> rows = _rowsOf(target: toTarget);
    final int index = rows.indexWhere((PlTransferItem item) => item.value == value);

    if (scrolled || index < 0 || !scroll.hasClients) {
      (toTarget ? _targetListFocus : _sourceListFocus).requestFocus();
      return;
    }

    final ScrollPosition position = scroll.position;
    final double extent = (position.maxScrollExtent + position.viewportDimension) / rows.length;

    scroll.jumpTo((index * extent).clamp(position.minScrollExtent, position.maxScrollExtent));

    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) {
        _focusRow(value, toTarget: toTarget, scrolled: true);
      }
    });
  }

  /// One side's rows as its list draws them: the items on that side, in the
  /// order of [PlTransfer.items], narrowed by that side's filter.
  List<PlTransferItem> _rowsOf({required bool target}) {
    final Set<String> chosen = _value.toSet();
    final List<PlTransferItem> side = widget.items
        .where((PlTransferItem item) => chosen.contains(item.value) == target)
        .toList(growable: false);

    return _narrow(side, (target ? _targetSearch : _sourceSearch).text);
  }

  /// The widget for one row, and the same one as last time while nothing about
  /// the row has changed.
  ///
  /// A list calls its builder for every row it has built whenever the transfer
  /// rebuilds, which is on every tick, and Flutter passes over a widget it is
  /// handed again. So a tick rebuilds the one row it changed rather than every
  /// row near the screen.
  Widget _row(PlTransferItem item, PlassSize size) {
    final bool ticked = _ticked.contains(item.value);
    final bool disabled = widget.disabled || item.disabled;
    final FocusNode node = _focusFor(item.value);
    final _PlTransferRow? last = _rows[item.value];

    if (last != null &&
        last.label == item.label &&
        last.ticked == ticked &&
        last.disabled == disabled &&
        last.size == size &&
        last.color == _color &&
        identical(last.focusNode, node)) {
      return last;
    }

    return _rows[item.value] = _PlTransferRow(
      key: ValueKey<String>(item.value),
      label: item.label,
      ticked: ticked,
      disabled: disabled,
      size: size,
      color: _color,
      focusNode: node,
      onChanged: (bool next) => _tick(item.value, next),
    );
  }

  /// One side's rows, narrowed by what was typed at that side's box.
  List<PlTransferItem> _narrow(List<PlTransferItem> rows, String query) {
    final String needle = searchText(query);

    if (needle.isEmpty) return rows;

    return rows
        .where((PlTransferItem item) => searchText(item.label).contains(needle))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final List<PlTransferItem> sourceRows = _rowsOf(target: false);
    final List<PlTransferItem> targetRows = _rowsOf(target: true);
    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    final bool canSend = sourceRows.any(
      (PlTransferItem item) => !item.disabled && _ticked.contains(item.value),
    );
    final bool canReturn = targetRows.any(
      (PlTransferItem item) => !item.disabled && _ticked.contains(item.value),
    );

    final PlassVariant arrows = widget.variant == PlassVariant.ghost
        ? PlassVariant.ghost
        : PlassVariant.glass;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: <Widget>[
        Expanded(
          child: _panel(
            title: widget.sourceLabel ?? PlassTheme.labelsOf(context).transferAvailable,
            fallback: PlassTheme.labelsOf(context).transferAvailable,
            rows: sourceRows,
            controller: _sourceSearch,
            scroll: _sourceScroll,
            listFocus: _sourceListFocus,
            onTickAll: (bool on) => _tickAll(sourceRows, on),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: <Widget>[
            PlIconButton(
              size: _size,
              color: _color,
              variant: arrows,
              label: widget.toTargetLabel ?? PlassTheme.labelsOf(context).transferToSelected,
              onPressed: widget.disabled || !canSend
                  ? null
                  : () => _move(sourceRows, toTarget: true),
              // The glyph points right, and the selected list is at the end of
              // the row, which is the left under RTL, so both arrows turn there.
              icon: PlassGlyph(PlassGlyphShape.arrowRight, quarterTurns: rtl ? 2 : 0),
            ),
            PlIconButton(
              size: _size,
              color: _color,
              variant: arrows,
              label: widget.toSourceLabel ?? PlassTheme.labelsOf(context).transferToAvailable,
              onPressed: widget.disabled || !canReturn
                  ? null
                  : () => _move(targetRows, toTarget: false),
              // The same glyph turned, which is the one allowance the
              // no-transform rule makes: a wedge has no text in it to resample.
              icon: PlassGlyph(PlassGlyphShape.arrowRight, quarterTurns: rtl ? 0 : 2),
            ),
          ],
        ),
        Expanded(
          child: _panel(
            title: widget.targetLabel ?? PlassTheme.labelsOf(context).transferSelected,
            fallback: PlassTheme.labelsOf(context).transferSelected,
            rows: targetRows,
            controller: _targetSearch,
            scroll: _targetScroll,
            listFocus: _targetListFocus,
            onTickAll: (bool on) => _tickAll(targetRows, on),
          ),
        ),
      ],
    );
  }

  /// The heading tick's name for the list called [list].
  ///
  /// A caller's [PlTransfer.selectAllLabel] goes before the name, which is what
  /// it has always meant; the theme's sentence places the name itself.
  String _selectAllName(String list) {
    final String? words = widget.selectAllLabel;

    if (words == null) {
      return PlassTheme.labelsOf(context).transferSelectAll(list);
    }

    return <String>[words, list].where((String part) => part.isNotEmpty).join(' ');
  }

  /// What a caller sees of one side, so the two panels are literally one method.
  ///
  /// [fallback] is the theme's name for the list, which the heading tick says
  /// in place of a [title] with no words in it.
  Widget _panel({
    required String title,
    required String fallback,
    required List<PlTransferItem> rows,
    required TextEditingController controller,
    required ScrollController scroll,
    required FocusNode listFocus,
    required ValueChanged<bool> onTickAll,
  }) {
    final PlassTokens tokens = PlassTheme.of(context);
    final PlassSize size = _size;
    final double insetX = paddingX[_density]![size]!;
    final double padY = _panelPadY[size]!;
    final double caption = metaText[size]!;

    final List<PlTransferItem> movable = rows
        .where((PlTransferItem row) => !row.disabled)
        .toList(growable: false);
    final int tickedHere = movable
        .where((PlTransferItem row) => _ticked.contains(row.value))
        .length;
    final bool all = movable.isNotEmpty && tickedHere == movable.length;
    final bool some = tickedHere > 0 && !all;

    final Widget header = Padding(
      padding: EdgeInsets.symmetric(horizontal: insetX, vertical: padY),
      child: Row(
        spacing: 8,
        children: <Widget>[
          PlCheckbox(
            size: size,
            color: _color,
            value: all,
            indeterminate: some,
            disabled: widget.disabled || movable.isEmpty,
            // One sentence with the list's name in it, so the two lists' ticks
            // are told apart by ear as they are by eye, and a language puts the
            // name where its own grammar puts it: Korean and Japanese before the
            // verb, English after it.
            semanticLabel: _selectAllName(title.trim().isEmpty ? fallback : title),
            onChanged: (bool next) => onTickAll(next),
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: caption, fontWeight: FontWeight.w500, color: tokens.fg),
            ),
          ),
          Text(
            '$tickedHere/${rows.length}',
            style: TextStyle(fontSize: caption, color: tokens.mutedFg),
          ),
        ],
      ),
    );

    final EdgeInsetsGeometry listPadding = EdgeInsets.symmetric(horizontal: insetX, vertical: padY);

    // Where each row is, by value, made only if the list asks.
    late final Map<String, int> places = <String, int>{
      for (int index = 0; index < rows.length; index += 1) rows[index].value: index,
    };

    // Built lazily: a list of thousands builds the rows near what it shows
    // rather than every one of them, on the first frame and on every tick.
    final Widget list = SizedBox(
      height: widget.height,
      child: rows.isEmpty
          ? ListView(
              controller: scroll,
              padding: listPadding,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: _rowPadY[size]!),
                  child: Text(
                    widget.emptyLabel ?? PlassTheme.labelsOf(context).empty,
                    style: TextStyle(fontSize: caption, color: tokens.mutedFg),
                  ),
                ),
              ],
            )
          : ListView.builder(
              controller: scroll,
              padding: listPadding,
              itemCount: rows.length,
              // A move shifts the rows, and a row is found again by its value
              // rather than by the place it used to be at, so it keeps its own
              // element and whatever its checkbox was holding.
              findChildIndexCallback: (Key key) => places[(key as ValueKey<String>).value],
              itemBuilder: (BuildContext context, int index) => _row(rows[index], size),
            ),
    );

    return PlassSurfaceBox(
      surface: fieldSurface(
        tokens,
        tokens.family(_color),
        variant: widget.variant,
        elevation: 0,
        disabled: widget.disabled,
      ),
      borderRadius: BorderRadius.circular(tokens.radii[size]!),
      duration: tokens.motionDurationSlow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: tokens.divider, width: hairline),
              ),
            ),
            child: header,
          ),
          if (widget.searchable)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: insetX, vertical: padY),
              child: PlTextField(
                controller: controller,
                size: size,
                color: _color,
                density: _density,
                variant: PlassVariant.ghost,
                fullWidth: true,
                disabled: widget.disabled,
                placeholder: widget.searchLabel ?? PlassTheme.labelsOf(context).search,
                semanticLabel: widget.searchLabel ?? PlassTheme.labelsOf(context).search,
                onChanged: (String _) => setState(() {}),
              ),
            ),
          // Named by its heading, and able to hold the focus without being a
          // stop in the traversal: it is where the focus lands after a move
          // whose rows did not arrive.
          Focus(
            focusNode: listFocus,
            child: Semantics(container: true, label: title, child: list),
          ),
        ],
      ),
    );
  }
}

/// One row of a list: its checkbox, held to its own width.
///
/// Its own widget, so that [_PlTransferState._row] can hand the same instance
/// back while nothing about the row has changed.
class _PlTransferRow extends StatefulWidget {
  const _PlTransferRow({
    required this.label,
    required this.ticked,
    required this.disabled,
    required this.size,
    required this.color,
    required this.focusNode,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool ticked;
  final bool disabled;
  final PlassSize size;
  final PlassColor color;
  final FocusNode focusNode;
  final ValueChanged<bool> onChanged;

  @override
  State<_PlTransferRow> createState() => _PlTransferRowState();
}

class _PlTransferRowState extends State<_PlTransferRow> with AutomaticKeepAliveClientMixin {
  /// A row that holds the focus stays built when its list is scrolled away
  /// from it. A lazy list lets go of a row past its edge, and a row that goes
  /// takes the focus with it, where the column the rows used to be in kept
  /// every one of them.
  @override
  bool get wantKeepAlive => widget.focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(updateKeepAlive);
  }

  @override
  void didUpdateWidget(_PlTransferRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(updateKeepAlive);
      widget.focusNode.addListener(updateKeepAlive);
      updateKeepAlive();
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(updateKeepAlive);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // A list stretches its children across, where the column the rows used to
    // be in let each one keep its own width. The press target is the box and
    // its label, not the width of the panel.
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: _rowPadY[widget.size]!),
        child: PlCheckbox(
          size: widget.size,
          color: widget.color,
          value: widget.ticked,
          focusNode: widget.focusNode,
          disabled: widget.disabled,
          label: Text(widget.label),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
