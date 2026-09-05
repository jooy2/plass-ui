/// The arithmetic a [PlGallery] lays itself out with.
///
/// It is here rather than in the widget for the reason `internal/steps.dart`
/// is: **the React build needs the same answers.** A masonry that dealt its
/// columns differently on the two sides would be one gallery with two orders,
/// and the order is the only thing about a masonry a reader can check.
///
/// [dealColumns] is the half that is shared, character for character, with
/// `internal/gallery.ts`. The two below it have no React counterpart and are
/// not an oversight: CSS does a justified row with `flex-grow` and a quilt with
/// `grid-auto-flow: dense`, so that build never computes either. Flutter has
/// neither, so the packing is written out — and because it is written out it
/// runs inside a `LayoutBuilder`, which is the one measurement in the component
/// and the one honest difference between the two galleries.
///
/// It is not exported from `plass_ui.dart`.
library;

/// The items dealt into columns, shortest column first.
///
/// Not a naive chunking, which fills the first column top to bottom before it
/// starts the second — so a set numbered 1 to 12 reads *down* the left edge,
/// and the first three pictures a reader meets are stacked on top of each
/// other. Dealt this way the first row is items 1, 2 and 3, which is the order
/// they were given in.
///
/// The heights are the ratios rather than anything measured, which is what lets
/// a masonry hold still while the files arrive.
List<List<int>> dealColumns(List<double> ratios, int columns) {
  final lanes = List<List<int>>.generate(columns, (int _) => <int>[]);
  final heights = List<double>.filled(columns, 0);

  for (int index = 0; index < ratios.length; index += 1) {
    int shortest = 0;

    for (int lane = 1; lane < columns; lane += 1) {
      if (heights[lane] < heights[shortest]) {
        shortest = lane;
      }
    }

    lanes[shortest].add(index);
    // One unit of width over the ratio is the height that unit of width draws.
    heights[shortest] += 1 / ratios[index];
  }

  return lanes;
}

/// One row of a justified layout: which items are on it, and how tall it came out.
class PlassJustifiedRow {
  /// Creates a row.
  const PlassJustifiedRow(this.indexes, this.height);

  /// The items on the row, in the order they were given.
  final List<int> indexes;

  /// The height every tile on it is drawn at.
  final double height;
}

/// The items packed into rows that each fill [width] exactly.
///
/// A row takes pictures until adding one more would make the row shorter than
/// [rowHeight] allows, then scales to the width it actually has — which is what
/// makes every tile on a row come out the same height with nothing cropped and
/// no space left over.
///
/// The **last row is not stretched**. A final row holding one landscape
/// photograph, scaled to fill, is one enormous picture under a wall of small
/// ones; left at its natural height it reads as the end of the set.
List<PlassJustifiedRow> justifyRows(
  List<double> ratios,
  double width,
  double rowHeight,
  double gap,
) {
  final rows = <PlassJustifiedRow>[];

  if (ratios.isEmpty || width <= 0) {
    return rows;
  }

  var current = <int>[];
  double sum = 0;

  void close({required bool stretch}) {
    if (current.isEmpty) {
      return;
    }

    final double available = width - gap * (current.length - 1);
    final double height = stretch ? available / sum : rowHeight;

    rows.add(PlassJustifiedRow(current, height <= 0 ? rowHeight : height));
    current = <int>[];
    sum = 0;
  }

  for (int index = 0; index < ratios.length; index += 1) {
    current.add(index);
    sum += ratios[index];

    final double available = width - gap * (current.length - 1);

    // The row is full once scaling it to the width would take it below the
    // height that was asked for.
    if (available / sum <= rowHeight) {
      close(stretch: true);
    }
  }

  close(stretch: false);

  return rows;
}

/// Where one tile sits in a quilt.
class PlassQuiltCell {
  /// Creates a placement.
  const PlassQuiltCell(this.column, this.row, this.columnSpan, this.rowSpan);

  /// The first column it occupies, from zero.
  final int column;

  /// The first row.
  final int row;

  /// How many columns it takes.
  final int columnSpan;

  /// How many rows.
  final int rowSpan;
}

/// The tiles placed on a [columns]-wide grid, filling gaps as it goes.
///
/// The same **dense** flow CSS Grid's `grid-auto-flow: dense` does: a tile too
/// wide for the space left on a row does not push everything down, it is placed
/// on the next row that fits it and a later, narrower tile fills the hole it
/// left. Without that a quilt of mixed spans is mostly holes.
///
/// A span wider than the grid is clamped rather than refused, which is what the
/// caller meant by `cols: 99`.
List<PlassQuiltCell> quiltCells(List<({int cols, int rows})> spans, int columns) {
  final cells = <PlassQuiltCell>[];
  final occupied = <int, List<bool>>{};

  List<bool> rowAt(int row) => occupied.putIfAbsent(row, () => List<bool>.filled(columns, false));

  bool fits(int row, int column, int columnSpan, int rowSpan) {
    if (column + columnSpan > columns) {
      return false;
    }

    for (int r = row; r < row + rowSpan; r += 1) {
      final List<bool> line = rowAt(r);

      for (int c = column; c < column + columnSpan; c += 1) {
        if (line[c]) {
          return false;
        }
      }
    }

    return true;
  }

  for (final ({int cols, int rows}) span in spans) {
    final int columnSpan = span.cols.clamp(1, columns);
    final int rowSpan = span.rows < 1 ? 1 : span.rows;

    int row = 0;
    int column = 0;

    while (!fits(row, column, columnSpan, rowSpan)) {
      column += 1;

      if (column + columnSpan > columns) {
        column = 0;
        row += 1;
      }
    }

    for (int r = row; r < row + rowSpan; r += 1) {
      final List<bool> line = rowAt(r);

      for (int c = column; c < column + columnSpan; c += 1) {
        line[c] = true;
      }
    }

    cells.add(PlassQuiltCell(column, row, columnSpan, rowSpan));
  }

  return cells;
}
