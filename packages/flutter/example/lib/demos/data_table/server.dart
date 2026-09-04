import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Order {
  const Order(this.id, this.city);

  final String id;
  final String city;
}

const List<String> _cities = <String>['Seoul', 'Lisbon', 'Osaka', 'Cairo', 'Oslo', 'Quito'];

/// Stands in for a request. A real one would send these as query parameters.
List<Order> _load(PlDataTableSort? sort, int page) {
  final all = <Order>[
    for (var index = 0; index < _cities.length; index += 1)
      Order('ORD-${100 + index}', _cities[index]),
  ];

  if (sort != null) {
    final direction = sort.direction == PlDataTableSortDirection.asc ? 1 : -1;

    all.sort((Order a, Order b) {
      final left = sort.key == 'id' ? a.id : a.city;
      final right = sort.key == 'id' ? b.id : b.city;

      return left.compareTo(right) * direction;
    });
  }

  return all.sublist((page - 1) * 3, (page * 3).clamp(0, all.length));
}

class DataTableServer extends StatefulWidget {
  const DataTableServer({super.key});

  @override
  State<DataTableServer> createState() => _DataTableServerState();
}

class _DataTableServerState extends State<DataTableServer> {
  PlDataTableSort? _sort;
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    // The table reports what the reader asked for and draws what it is handed.
    return SizedBox(
      width: 448,
      child: PlDataTable<Order>(
        rows: _load(_sort, _page),
        rowKey: (Order row, int _) => row.id,
        manual: const <PlDataTableStage>[PlDataTableStage.sort, PlDataTableStage.pages],
        rowCount: _cities.length,
        paging: PlDataTablePaging.pages,
        pageSize: 3,
        sort: _sort,
        onSortChanged: (PlDataTableSort? next) => setState(() {
          _sort = next;
          _page = 1;
        }),
        page: _page,
        onPageChanged: (int next) => setState(() => _page = next),
        columns: <PlDataTableColumn<Order>>[
          PlDataTableColumn<Order>(
            key: 'id',
            header: const Text('Order'),
            sortable: true,
            cell: (Order row, int _) => Text(row.id),
          ),
          PlDataTableColumn<Order>(
            key: 'city',
            header: const Text('City'),
            sortable: true,
            cell: (Order row, int _) => Text(row.city),
          ),
        ],
      ),
    );
  }
}
