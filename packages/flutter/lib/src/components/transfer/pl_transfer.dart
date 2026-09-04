/// Two lists and the arrows between them.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/checkbox/pl_checkbox.dart';
import 'package:plass_ui/src/components/icon_button/pl_icon_button.dart';
import 'package:plass_ui/src/components/text_field/pl_text_field.dart';
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

  /// What the tick in a list's heading is announced as.
  final String? selectAllLabel;

  /// What the outward arrow is announced as.
  final String? toTargetLabel;

  /// What the returning arrow is announced as.
  final String? toSourceLabel;

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

  List<String> get _value => widget.value ?? _ownValue;

  @override
  void dispose() {
    _sourceSearch.dispose();
    _targetSearch.dispose();
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
    final Set<String> chosen = _value.toSet();
    final List<PlTransferItem> source = widget.items
        .where((PlTransferItem item) => !chosen.contains(item.value))
        .toList(growable: false);
    final List<PlTransferItem> target = widget.items
        .where((PlTransferItem item) => chosen.contains(item.value))
        .toList(growable: false);

    final List<PlTransferItem> sourceRows = _narrow(source, _sourceSearch.text);
    final List<PlTransferItem> targetRows = _narrow(target, _targetSearch.text);

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
            rows: sourceRows,
            controller: _sourceSearch,
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
              icon: const PlassGlyph(PlassGlyphShape.arrowRight),
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
              icon: const PlassGlyph(PlassGlyphShape.arrowRight, quarterTurns: 2),
            ),
          ],
        ),
        Expanded(
          child: _panel(
            title: widget.targetLabel ?? PlassTheme.labelsOf(context).transferSelected,
            rows: targetRows,
            controller: _targetSearch,
            onTickAll: (bool on) => _tickAll(targetRows, on),
          ),
        ),
      ],
    );
  }

  /// What a caller sees of one side, so the two panels are literally one method.
  Widget _panel({
    required String title,
    required List<PlTransferItem> rows,
    required TextEditingController controller,
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
            semanticLabel: widget.selectAllLabel ?? PlassTheme.labelsOf(context).selectAll,
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

    final Widget list = SizedBox(
      height: widget.height,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: insetX, vertical: padY),
          child: rows.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: _rowPadY[size]!),
                  child: Text(
                    widget.emptyLabel ?? PlassTheme.labelsOf(context).empty,
                    style: TextStyle(fontSize: caption, color: tokens.mutedFg),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final PlTransferItem row in rows)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: _rowPadY[size]!),
                        child: PlCheckbox(
                          size: size,
                          color: _color,
                          value: _ticked.contains(row.value),
                          disabled: widget.disabled || row.disabled,
                          label: Text(row.label),
                          onChanged: (bool next) => _tick(row.value, next),
                        ),
                      ),
                  ],
                ),
        ),
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
      borderRadius: BorderRadius.circular(PlassTokens.radius[size]!),
      duration: PlassTokens.durationSlow,
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
          list,
        ],
      ),
    );
  }
}
