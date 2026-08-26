import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Region {
  const Region(this.name, this.quarters);

  final String name;
  final List<String> quarters;
}

const List<Region> _rows = <Region>[
  Region('North', <String>['120', '134', '118', '160']),
  Region('South', <String>['96', '101', '130', '122']),
  Region('East', <String>['141', '128', '139', '171']),
  Region('West', <String>['88', '94', '90', '103']),
];

class TableStriped extends StatelessWidget {
  const TableStriped({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      child: PlTable<Region>(
        striped: true,
        hoverable: true,
        rows: _rows,
        columns: <PlTableColumn<Region>>[
          PlTableColumn<Region>(
            header: const Text('Region'),
            cell: (Region row, int index) => Text(row.name),
          ),
          for (var quarter = 0; quarter < 4; quarter += 1)
            PlTableColumn<Region>(
              header: Text('Q${quarter + 1}'),
              align: PlassAlign.end,
              cell: (Region row, int index) => Text(row.quarters[quarter]),
            ),
        ],
      ),
    );
  }
}
