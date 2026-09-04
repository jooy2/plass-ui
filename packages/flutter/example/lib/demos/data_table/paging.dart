import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Entry {
  const Entry(this.id, this.event, this.at);

  final int id;
  final String event;
  final String at;
}

const List<String> _events = <String>[
  'Signed in',
  'Changed password',
  'Exported a report',
  'Invited a colleague',
];

final List<Entry> _rows = <Entry>[
  for (var index = 0; index < 23; index += 1)
    Entry(23 - index, _events[index % _events.length], '${index + 1} days ago'),
];

class DataTablePaging extends StatelessWidget {
  const DataTablePaging({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: PlDataTable<Entry>(
        rows: _rows,
        rowKey: (Entry row, int _) => row.id,
        paging: PlDataTablePaging.pages,
        pageSize: 6,
        searchable: true,
        columns: <PlDataTableColumn<Entry>>[
          PlDataTableColumn<Entry>(
            key: 'id',
            header: const Text('#'),
            width: 64,
            align: PlassAlign.end,
            value: (Entry row) => row.id,
            cell: (Entry row, int _) => Text('${row.id}'),
          ),
          PlDataTableColumn<Entry>(
            key: 'event',
            header: const Text('Event'),
            value: (Entry row) => row.event,
            cell: (Entry row, int _) => Text(row.event),
          ),
          PlDataTableColumn<Entry>(
            key: 'at',
            header: const Text('When'),
            value: (Entry row) => row.at,
            cell: (Entry row, int _) => Text(row.at),
          ),
        ],
      ),
    );
  }
}
