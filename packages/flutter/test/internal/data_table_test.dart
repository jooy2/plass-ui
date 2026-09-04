import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/data_table.dart';

void main() {
  group('compareValues', () {
    test('orders numbers as numbers rather than as text', () {
      // The bug this catches: `[2, 10]` sorted as strings puts 10 first.
      expect(compareValues(2, 10), lessThan(0));
    });

    test('orders dates by the moment they name', () {
      expect(compareValues(DateTime(2026), DateTime(2026, 6)), lessThan(0));
    });

    test('orders booleans with false first', () {
      expect(compareValues(false, true), lessThan(0));
    });

    test('orders text without letting a capital jump the queue', () {
      // `'a'.compareTo('B')` is positive by code point, which puts every
      // capitalised word above every lower-case one.
      expect(compareValues('apple', 'Banana'), lessThan(0));
    });

    test('falls back to the code points for the same word in two cases', () {
      expect(compareValues('Apple', 'apple'), isNot(0));
    });

    test('puts nothing last, whichever way round it is asked', () {
      expect(compareValues(null, 5), greaterThan(0));
      expect(compareValues(5, null), lessThan(0));
      expect(compareValues('', 5), greaterThan(0));
    });

    test('leaves two missing values equal', () {
      expect(compareValues(null, ''), 0);
    });
  });

  group('nextSort', () {
    test('starts a column ascending', () {
      expect(
        nextSort(null, 'name'),
        const PlassSort(key: 'name', direction: PlassSortDirection.asc),
      );
    });

    test('turns an ascending column round', () {
      expect(
        nextSort(const PlassSort(key: 'name', direction: PlassSortDirection.asc), 'name'),
        const PlassSort(key: 'name', direction: PlassSortDirection.desc),
      );
    });

    test('puts the rows back on the third press', () {
      // The order the rows arrived in is information, and a table that can
      // never be put back has thrown it away.
      expect(
        nextSort(const PlassSort(key: 'name', direction: PlassSortDirection.desc), 'name'),
        isNull,
      );
    });

    test('starts a different column ascending rather than inheriting the direction', () {
      expect(
        nextSort(const PlassSort(key: 'name', direction: PlassSortDirection.desc), 'total'),
        const PlassSort(key: 'total', direction: PlassSortDirection.asc),
      );
    });
  });

  group('keysBetween', () {
    const List<String> keys = <String>['a', 'b', 'c', 'd'];

    test('takes both ends of the range', () {
      expect(keysBetween(keys, 'b', 'd'), <String>['b', 'c', 'd']);
    });

    test('reads the same range dragged upwards', () {
      expect(keysBetween(keys, 'd', 'b'), <String>['b', 'c', 'd']);
    });

    test('is one row when both ends are the same row', () {
      expect(keysBetween(keys, 'c', 'c'), <String>['c']);
    });

    test('selects nothing when an end is no longer there', () {
      // The anchor can legitimately have been filtered away between two presses.
      expect(keysBetween(keys, 'z', 'c'), isEmpty);
    });
  });

  group('pageBounds', () {
    test('slices the page asked for', () {
      expect(pageBounds(25, 2, 10), (10, 20));
    });

    test('stops the last page at the end of the rows', () {
      expect(pageBounds(25, 3, 10), (20, 25));
    });

    test('shows the last page when the page asked for has gone past the end', () {
      // The usual way: a filter shortened the list under a reader on page nine.
      expect(pageBounds(25, 9, 10), (20, 25));
    });

    test('shows the first page when the page asked for is below one', () {
      expect(pageBounds(25, 0, 10), (0, 10));
    });

    test('has one empty page rather than none when there are no rows', () {
      expect(pageBounds(0, 1, 10), (0, 0));
    });
  });
}
