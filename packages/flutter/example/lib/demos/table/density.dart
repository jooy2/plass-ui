import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Header {
  const Header(this.name, this.value);

  final String name;
  final String value;
}

const List<Header> _rows = <Header>[
  Header('content-type', 'application/json'),
  Header('cache-control', 'no-store'),
  Header('x-request-id', '7f2c1a'),
];

List<PlTableColumn<Header>> _columns() {
  return <PlTableColumn<Header>>[
    PlTableColumn<Header>(
      header: const Text('Header'),
      cell: (Header row, int index) => Text(row.name),
    ),
    PlTableColumn<Header>(
      header: const Text('Value'),
      cell: (Header row, int index) => Text(row.value),
    ),
  ];
}

class TableDensity extends StatelessWidget {
  const TableDensity({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        for (final density in PlassDensity.values)
          SizedBox(
            width: 280,
            child: PlTable<Header>(
              size: PlassSize.sm,
              density: density,
              caption: Text(density.name),
              rows: _rows,
              columns: _columns(),
            ),
          ),
      ],
    );
  }
}
