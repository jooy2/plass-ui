import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Reading {
  const Reading(this.at, this.sensor, this.value, this.state);

  final String at;
  final String sensor;
  final String value;
  final String state;
}

const List<String> _sensors = <String>['Inlet', 'Outlet', 'Ambient', 'Coolant'];

/// Enough rows that the cap is doing something.
final List<Reading> _rows = <Reading>[
  for (var index = 0; index < 24; index += 1)
    Reading(
      '09:${(index * 2).toString().padLeft(2, '0')}',
      _sensors[index % _sensors.length],
      '${(18 + ((index * 7) % 23) / 2).toStringAsFixed(1)} °C',
      index % 7 == 3 ? 'Warning' : 'Nominal',
    ),
];

class TableScroll extends StatelessWidget {
  const TableScroll({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: PlTable<Reading>(
        caption: const Text('Overnight readings'),
        stickyHeader: true,
        maxHeight: 280,
        striped: true,
        hoverable: true,
        rows: _rows,
        columns: <PlTableColumn<Reading>>[
          PlTableColumn<Reading>(
            header: const Text('Time'),
            width: 90,
            cell: (Reading row, int index) => Text(row.at),
          ),
          PlTableColumn<Reading>(
            header: const Text('Sensor'),
            cell: (Reading row, int index) => Text(row.sensor),
          ),
          PlTableColumn<Reading>(
            header: const Text('Value'),
            align: PlassAlign.end,
            cell: (Reading row, int index) => Text(row.value),
          ),
          PlTableColumn<Reading>(
            header: const Text('State'),
            cell: (Reading row, int index) => Text(row.state),
          ),
        ],
      ),
    );
  }
}
