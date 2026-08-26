import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Build {
  const Build(this.id, this.branch, this.duration);

  final String id;
  final String branch;
  final String duration;
}

const List<Build> _rows = <Build>[
  Build('#412', 'main', '2m 04s'),
  Build('#411', 'fix/glass-edge', '1m 58s'),
  Build('#410', 'main', '2m 11s'),
];

class TableRows extends StatefulWidget {
  const TableRows({super.key});

  @override
  State<TableRows> createState() => _TableRowsState();
}

class _TableRowsState extends State<TableRows> {
  String? _opened;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 460,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          PlTable<Build>(
            rows: _rows,
            onRowPressed: (Build row, int index) => setState(() => _opened = row.id),
            columns: <PlTableColumn<Build>>[
              PlTableColumn<Build>(
                header: const Text('Build'),
                cell: (Build row, int index) => Text(row.id),
              ),
              PlTableColumn<Build>(
                header: const Text('Branch'),
                cell: (Build row, int index) => Text(row.branch),
              ),
              PlTableColumn<Build>(
                header: const Text('Duration'),
                align: PlassAlign.end,
                cell: (Build row, int index) => Text(row.duration),
              ),
            ],
          ),
          PlTypography(
            _opened != null
                ? 'Opened build $_opened.'
                : 'Press a row, or focus one and press Enter.',
            level: PlTypographyLevel.caption,
            color: PlassColor.secondary,
          ),
        ],
      ),
    );
  }
}
