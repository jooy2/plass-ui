/// What a component does on a screen narrower than it was drawn for.
///
/// The width of a phone is where a row with no way out reports an overflow, and
/// the demos on the documentation site, a column about 700 wide, say nothing
/// about it. `examples/flutter/test/demos_test.dart` runs every demo at a phone's
/// width; this is the same question, asked of each component on its own.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/host.dart';

Future<void> _lay(WidgetTester tester, Widget child, {double width = 300}) async {
  await tester.pumpWidget(host(SingleChildScrollView(child: child), width: width, overlay: true));
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  final Map<String, Widget Function()> components = <String, Widget Function()>{
    'tabs that share the width': () => PlTabs<int>(
      fullWidth: true,
      value: 0,
      tabs: const <PlTab<int>>[
        PlTab<int>(value: 0, label: Text('Open'), panel: Text('Three')),
        PlTab<int>(value: 1, label: Text('Paid'), panel: Text('Four')),
      ],
    ),
    'solid tabs that share the width': () => PlTabs<int>(
      fullWidth: true,
      variant: PlassVariant.solid,
      value: 0,
      tabs: const <PlTab<int>>[
        PlTab<int>(value: 0, label: Text('Open'), panel: Text('Three')),
        PlTab<int>(value: 1, label: Text('Paid'), panel: Text('Four')),
      ],
    ),
    'a spoiler clamped under what it covers': () => const PlSpoiler(
      maxHeight: 40,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[SizedBox(height: 90), SizedBox(height: 90)],
      ),
    ),
    'a set that appears in a row': () => const PlAnimateAppear(
      orientation: PlassOrientation.horizontal,
      children: <Widget>[Text('One'), Text('Two')],
    ),
    'a set that appears down a row': () => const Row(
      children: <Widget>[
        PlAnimateAppear(children: <Widget>[Text('One'), Text('Two')]),
      ],
    ),
    'a gauge with a caption': () =>
        const PlGaugeChart(value: 72, sweep: 360, caption: Text('of the monthly target')),
    'a pagination with every page shown': () => PlPagination(count: 40, page: 20, showEdges: true),
    'a table footer with a pager': () => PlDataTable<int>(
      rows: List<int>.generate(40, (int index) => index),
      rowKey: (int row, int _) => row,
      paging: PlDataTablePaging.pages,
      pageSize: 5,
      columns: <PlDataTableColumn<int>>[
        PlDataTableColumn<int>(
          key: 'row',
          header: const Text('Row'),
          value: (int row) => row,
          cell: (int row, int _) => Text('$row'),
        ),
      ],
    ),
    'a navigation menu': () => const PlNavigationMenu(
      items: <PlNavigationMenuItem>[
        PlNavigationMenuItem(label: 'Products'),
        PlNavigationMenuItem(label: 'Solutions'),
        PlNavigationMenuItem(label: 'Documents'),
      ],
    ),
    'a header with a wide middle': () => PlHeader(
      brand: const <Widget>[Text('Acme')],
      actions: const <Widget>[Text('Sign in')],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final name in <String>['One', 'Two', 'Three']) Text('$name link'),
        ],
      ),
    ),
    'a stat with a long label': () => const SizedBox(
      width: 80,
      child: PlStat(label: Text('Monthly recurring revenue'), value: Text('£48,120'), change: 12.4),
    ),
    'a segmented button with long labels': () => PlSegmentedButton<int>(
      value: 0,
      segments: const <PlSegment<int>>[
        PlSegment<int>(value: 0, label: Text('Everything at once')),
        PlSegment<int>(value: 1, label: Text('Only the open ones')),
      ],
    ),
    'an eight-digit code': () => const PlOtpField(length: 8, groupSize: 4),
  };

  for (final MapEntry(key: name, value: build) in components.entries) {
    testWidgets('$name lays out', (WidgetTester tester) async {
      await _lay(tester, build());

      expect(tester.takeException(), isNull);
    });
  }

  group('PlPagination', () {
    testWidgets('goes onto a second line', (WidgetTester tester) async {
      await _lay(tester, PlPagination(count: 40, page: 20, showEdges: true));

      final double height = tester.getSize(find.byType(PlPagination)).height;

      await _lay(tester, PlPagination(count: 40, page: 20, showEdges: true), width: 700);

      expect(height, greaterThan(tester.getSize(find.byType(PlPagination)).height));
    });
  });

  group('PlHeader', () {
    testWidgets('scrolls a middle wider than the room it has', (WidgetTester tester) async {
      await _lay(
        tester,
        const PlHeader(
          brand: <Widget>[SizedBox(width: 120)],
          actions: <Widget>[SizedBox(width: 120)],
          child: SizedBox(width: 400, height: 20),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.widget<Scrollable>(find.byType(Scrollable).last).axisDirection, isNotNull);
    });
  });

  group('PlStat', () {
    const Key figure = Key('figure');
    const Key change = Key('change');
    const Widget stat = PlStat(
      value: SizedBox(key: figure, width: 100, height: 30),
      change: 1,
      changeLabel: SizedBox(key: change, width: 60, height: 14),
    );

    testWidgets('keeps the figure whole and puts the change under it', (WidgetTester tester) async {
      await _lay(tester, stat, width: 120);

      expect(tester.getSize(find.byKey(figure)).width, 100);
      expect(
        tester.getRect(find.byKey(change)).top,
        greaterThanOrEqualTo(tester.getRect(find.byKey(figure)).bottom),
      );
    });

    testWidgets('leaves them on one line while they fit', (WidgetTester tester) async {
      await _lay(tester, stat);

      expect(
        tester.getRect(find.byKey(change)).left,
        greaterThan(tester.getRect(find.byKey(figure)).right),
      );
    });

    testWidgets('starts from the other side under RTL', (WidgetTester tester) async {
      await tester.pumpWidget(host(stat, width: 300, textDirection: TextDirection.rtl));

      expect(
        tester.getRect(find.byKey(change)).right,
        lessThan(tester.getRect(find.byKey(figure)).left),
      );
    });
  });
}
