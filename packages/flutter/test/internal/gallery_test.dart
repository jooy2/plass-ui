import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/gallery.dart';

void main() {
  group('dealColumns', () {
    test('deals across before it deals down', () {
      // Four squares into two lanes: 1 and 3 on the left, 2 and 4 on the right —
      // which is the order they were given in, read across.
      expect(dealColumns(<double>[1, 1, 1, 1], 2), <List<int>>[
        <int>[0, 2],
        <int>[1, 3],
      ]);
    });

    test('puts each picture in the shortest lane', () {
      // A tall picture fills its lane, so the next two both go in the other one.
      expect(dealColumns(<double>[0.5, 1, 1], 2), <List<int>>[
        <int>[0],
        <int>[1, 2],
      ]);
    });

    test('gives back one lane per column, empty ones included', () {
      expect(dealColumns(<double>[1], 3), <List<int>>[
        <int>[0],
        <int>[],
        <int>[],
      ]);
    });

    test('handles an empty set', () {
      expect(dealColumns(<double>[], 2), <List<int>>[<int>[], <int>[]]);
    });
  });

  group('justifyRows', () {
    test('fills a row and then starts another', () {
      // Four squares at a target height of 100 into 400 wide, with no gap:
      // four of them exactly fill one row.
      final List<PlassJustifiedRow> rows = justifyRows(<double>[1, 1, 1, 1], 400, 100, 0);

      expect(rows.length, 1);
      expect(rows.first.indexes, <int>[0, 1, 2, 3]);
      expect(rows.first.height, closeTo(100, 0.001));
    });

    test('scales a row to the width it actually has', () {
      // Two squares into 400 wide is 200 each, taller than the 100 asked for.
      final List<PlassJustifiedRow> rows = justifyRows(<double>[1, 1], 400, 100, 0);

      expect(rows.length, 1);
      expect(rows.first.height, closeTo(100, 0.001));
    });

    test('counts the gaps out of the width before it scales', () {
      final List<PlassJustifiedRow> rows = justifyRows(<double>[1, 1], 210, 100, 10);

      expect(rows.first.height, closeTo(100, 0.001));
    });

    test('leaves the last row at its natural height', () {
      // Five squares into 400 wide at 100 high: four fill a row, and the fifth
      // is left alone rather than blown up to fill the width by itself.
      final List<PlassJustifiedRow> rows = justifyRows(<double>[1, 1, 1, 1, 1], 400, 100, 0);

      expect(rows.length, 2);
      expect(rows.last.indexes, <int>[4]);
      expect(rows.last.height, closeTo(100, 0.001));
    });

    test('gives back nothing for an empty set or no width', () {
      expect(justifyRows(<double>[], 400, 100, 0), isEmpty);
      expect(justifyRows(<double>[1], 0, 100, 0), isEmpty);
    });
  });

  group('quiltCells', () {
    test('lays plain tiles out in reading order', () {
      final List<PlassQuiltCell> cells = quiltCells(<({int cols, int rows})>[
        (cols: 1, rows: 1),
        (cols: 1, rows: 1),
        (cols: 1, rows: 1),
      ], 2);

      expect(<int>[cells[0].column, cells[0].row], <int>[0, 0]);
      expect(<int>[cells[1].column, cells[1].row], <int>[1, 0]);
      expect(<int>[cells[2].column, cells[2].row], <int>[0, 1]);
    });

    test('spans a tile over the cells it asked for', () {
      final List<PlassQuiltCell> cells = quiltCells(<({int cols, int rows})>[
        (cols: 2, rows: 2),
        (cols: 1, rows: 1),
      ], 3);

      expect(cells[0].columnSpan, 2);
      expect(cells[0].rowSpan, 2);
      expect(<int>[cells[1].column, cells[1].row], <int>[2, 0]);
    });

    test('fills the hole a wide tile left rather than pushing everything down', () {
      // A 2-wide tile cannot start at column 1 of a 3-wide grid, so it drops to
      // the next row — and the narrow tile after it fills the gap it left.
      final List<PlassQuiltCell> cells = quiltCells(<({int cols, int rows})>[
        (cols: 1, rows: 1),
        (cols: 3, rows: 1),
        (cols: 1, rows: 1),
      ], 3);

      expect(<int>[cells[0].column, cells[0].row], <int>[0, 0]);
      expect(<int>[cells[1].column, cells[1].row], <int>[0, 1]);
      // Dense: back up to the hole on row 0 rather than on to row 2.
      expect(<int>[cells[2].column, cells[2].row], <int>[1, 0]);
    });

    test('clamps a span wider than the grid rather than refusing it', () {
      final List<PlassQuiltCell> cells = quiltCells(<({int cols, int rows})>[
        (cols: 99, rows: 1),
      ], 3);

      expect(cells.first.columnSpan, 3);
    });
  });
}
