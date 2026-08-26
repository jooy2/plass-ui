import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Metric {
  const Metric(this.name, this.value);

  final String name;
  final String value;
}

const List<Metric> _rows = <Metric>[Metric('Requests', '12.4k'), Metric('Errors', '18')];

List<PlTableColumn<Metric>> _columns() {
  return <PlTableColumn<Metric>>[
    PlTableColumn<Metric>(
      header: const Text('Metric'),
      cell: (Metric row, int index) => Text(row.name),
    ),
    PlTableColumn<Metric>(
      header: const Text('Value'),
      align: PlassAlign.end,
      cell: (Metric row, int index) => Text(row.value),
    ),
  ];
}

class TableVariants extends StatelessWidget {
  const TableVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final variant in PlassVariant.values)
            PlTable<Metric>(variant: variant, size: PlassSize.sm, rows: _rows, columns: _columns()),
        ],
      ),
    );
  }
}
