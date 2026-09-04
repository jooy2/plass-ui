import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Player {
  const Player(this.name, this.country, this.points, this.joined);

  final String name;
  final String country;
  final int points;
  final DateTime joined;
}

final List<Player> _rows = <Player>[
  Player('ólafur', 'Iceland', 92, DateTime(2024, 3)),
  Player('Beatriz', 'Brazil', 140, DateTime(2023, 11)),
  Player('ahmed', 'Egypt', 8, DateTime(2025, 6)),
  Player('Zoë', 'Belgium', 76, DateTime(2022)),
];

const List<String> _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

class DataTableSorting extends StatelessWidget {
  const DataTableSorting({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: PlDataTable<Player>(
        rows: _rows,
        rowKey: (Player row, int _) => row.name,
        initialSort: const PlDataTableSort(key: 'points', direction: PlDataTableSortDirection.desc),
        columns: <PlDataTableColumn<Player>>[
          PlDataTableColumn<Player>(
            key: 'name',
            header: const Text('Name'),
            sortable: true,
            value: (Player row) => row.name,
            cell: (Player row, int _) => Text(row.name),
          ),
          PlDataTableColumn<Player>(
            key: 'country',
            header: const Text('Country'),
            sortable: true,
            value: (Player row) => row.country,
            cell: (Player row, int _) => Text(row.country),
          ),
          PlDataTableColumn<Player>(
            key: 'points',
            header: const Text('Points'),
            align: PlassAlign.end,
            sortable: true,
            value: (Player row) => row.points,
            cell: (Player row, int _) => Text('${row.points}'),
          ),
          PlDataTableColumn<Player>(
            key: 'joined',
            header: const Text('Joined'),
            sortable: true,
            // A date sorts as a date and is drawn as words. Without `value` the
            // sort would compare the two strings the cell happened to print.
            value: (Player row) => row.joined,
            cell: (Player row, int _) =>
                Text('${_months[row.joined.month - 1]} ${row.joined.year}'),
          ),
        ],
      ),
    );
  }
}
