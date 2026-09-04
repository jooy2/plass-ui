/// A list of labels and the values that go with them.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// The space between one row and the next.
const Map<PlassDensity, Map<PlassSize, double>> _rowGap = <PlassDensity, Map<PlassSize, double>>{
  PlassDensity.standard: <PlassSize, double>{
    PlassSize.xs: 8,
    PlassSize.sm: 10,
    PlassSize.md: 12,
    PlassSize.lg: 14,
    PlassSize.xl: 16,
  },
  PlassDensity.compact: <PlassSize, double>{
    PlassSize.xs: 4,
    PlassSize.sm: 6,
    PlassSize.md: 8,
    PlassSize.lg: 8,
    PlassSize.xl: 10,
  },
};

/// The space between a label and its value once they are stacked.
const Map<PlassSize, double> _stackGap = <PlassSize, double>{
  PlassSize.xs: 2,
  PlassSize.sm: 2,
  PlassSize.md: 4,
  PlassSize.lg: 4,
  PlassSize.xl: 6,
};

/// The gap between a label column and the value beside it.
const double _columnGap = 16;

/// How wide the label column is, unless the list says otherwise.
const double _labelWidth = 160;

/// What a row inherits from the list around it.
///
/// Local rather than in `internal/`, because only these two widgets exist and a
/// row is meaningless outside its list.
class _DataListScope extends InheritedWidget {
  const _DataListScope({
    required this.orientation,
    required this.size,
    required this.density,
    required this.labelWidth,
    required this.divider,
    required super.child,
  });

  final PlassOrientation orientation;
  final PlassSize size;
  final PlassDensity density;
  final double labelWidth;
  final bool divider;

  static _DataListScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_DataListScope>();

    assert(scope != null, 'PlDataListItem has to be inside a PlDataList.');

    return scope!;
  }

  @override
  bool updateShouldNotify(_DataListScope oldWidget) {
    return orientation != oldWidget.orientation ||
        size != oldWidget.size ||
        density != oldWidget.density ||
        labelWidth != oldWidget.labelWidth ||
        divider != oldWidget.divider;
  }
}

/// A list of labels and the values that go with them.
///
/// ```dart
/// PlDataList(
///   children: <Widget>[
///     PlDataListItem(label: Text('Owner'), value: Text('Ada Lovelace')),
///     PlDataListItem(label: Text('Plan'), value: Text('Team')),
///   ],
/// )
/// ```
///
/// The panel every detail screen ends with — a plan, an owner, a created date, a
/// status. It is **one thing and its fields**, which is what separates it from a
/// `PlTable`: a table is many things with the same fields, and a details panel
/// built as a two-column table claims a row and column relationship that is not
/// there. It is not a `PlList` either, which is a run of items of the same kind.
///
/// The rows are children rather than data, unlike a `PlTable`'s columns. A
/// details panel is written out once and read in source order, and every value
/// in it is a different shape — a chip, a date, an avatar, a link — so a list of
/// descriptions would be a list of builders.
///
/// Each pair is announced together, which is the Dart half of what a `<dl>` does
/// in the React build: a label read on its own is a word, and a value read on
/// its own is a fact nobody can place.
class PlDataList extends StatelessWidget {
  /// Creates a data list.
  const PlDataList({
    required this.children,
    this.orientation = PlassOrientation.horizontal,
    this.labelWidth,
    this.divider = false,
    this.size,
    this.density,
    super.key,
  });

  /// The [PlDataListItem]s.
  final List<Widget> children;

  /// Where the label sits.
  ///
  /// [PlassOrientation.horizontal] puts it beside the value in a column of its
  /// own, which is the shape a details panel takes.
  /// [PlassOrientation.vertical] puts it above, for a narrow column or for
  /// values long enough that a label beside them leaves the value nowhere to go.
  final PlassOrientation orientation;

  /// How wide the label column is, while the labels are beside the values.
  ///
  /// A fixed width rather than the longest label, so two panels on one screen
  /// line up with each other.
  final double? labelWidth;

  /// Draws a hairline between the rows.
  final bool divider;

  /// The type scale of the labels and the values.
  final PlassSize? size;

  /// The space between the rows.
  final PlassDensity? density;

  /// The rows with a hairline between each pair of them, and none at either end.
  List<Widget> _divided(Color line) {
    final divided = <Widget>[];

    for (final Widget row in children) {
      if (divided.isNotEmpty) {
        divided.add(
          SizedBox(
            height: hairline,
            child: ColoredBox(color: line),
          ),
        );
      }

      divided.add(row);
    }

    return divided;
  }

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final density = this.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

    return _DataListScope(
      orientation: orientation,
      size: size,
      density: density,
      labelWidth: labelWidth ?? _labelWidth,
      divider: divider,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        // A divided list holds its own spacing: the hairline needs padding
        // either side of it rather than a gap around it, or the line sits in
        // the middle of empty space instead of between two rows. The list draws
        // the lines rather than the rows, because a row does not know whether
        // it is the first one.
        spacing: divider ? 0 : _rowGap[density]![size]!,
        children: divider ? _divided(PlassTheme.of(context).divider) : children,
      ),
    );
  }
}

/// One label and its value.
class PlDataListItem extends StatelessWidget {
  /// Creates a row. It has to be inside a [PlDataList].
  const PlDataListItem({this.label, this.value, this.icon, super.key});

  /// What the value is of.
  final Widget? label;

  /// The value.
  final Widget? value;

  /// A glyph before the label.
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final scope = _DataListScope.of(context);
    final tokens = PlassTheme.of(context);
    final text = controlTextLeading[scope.size]!;
    final horizontal = scope.orientation == PlassOrientation.horizontal;

    final labelSide = DefaultTextStyle.merge(
      style: TextStyle(color: tokens.mutedFg, fontSize: text.size, height: text.height),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: <Widget>[
          if (icon != null)
            ExcludeSemantics(
              child: IconTheme.merge(
                data: IconThemeData(color: tokens.mutedFg, size: text.size * 1.15),
                child: icon!,
              ),
            ),
          if (label != null) Flexible(child: label!),
        ],
      ),
    );

    final valueSide = DefaultTextStyle.merge(
      style: TextStyle(color: tokens.fg, fontSize: text.size, height: text.height),
      child: value ?? const SizedBox.shrink(),
    );

    Widget row = horizontal
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: _columnGap,
            children: <Widget>[
              SizedBox(width: scope.labelWidth, child: labelSide),
              Expanded(child: valueSide),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: _stackGap[scope.size]!,
            children: <Widget>[labelSide, valueSide],
          );

    if (scope.divider) {
      final gap = _rowGap[scope.density]![scope.size]!;

      row = Padding(
        padding: EdgeInsets.symmetric(vertical: gap / 2),
        child: row,
      );
    }

    // Merged, so the label and the value are announced as one pair. A label read
    // on its own is a word, and a value read on its own is a fact nobody can
    // place.
    return MergeSemantics(child: row);
  }
}
