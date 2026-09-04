import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Doc {
  const Doc(this.id, this.name, this.size, {this.locked = false});

  final String id;
  final String name;
  final String size;
  final bool locked;
}

const List<Doc> _rows = <Doc>[
  Doc('1', 'quarterly-report.pdf', '2.4 MB'),
  Doc('2', 'logo.svg', '18 KB'),
  Doc('3', 'contract-signed.pdf', '840 KB', locked: true),
  Doc('4', 'notes.md', '4 KB'),
];

class DataTablePicking extends StatefulWidget {
  const DataTablePicking({super.key});

  @override
  State<DataTablePicking> createState() => _DataTablePickingState();
}

class _DataTablePickingState extends State<DataTablePicking> {
  List<Object> _selected = <Object>[];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: PlDataTable<Doc>(
        rows: _rows,
        rowKey: (Doc row, int _) => row.id,
        selection: PlDataTableSelection.multiple,
        selected: _selected,
        onSelectedChanged: (List<Object> next, List<Doc> _) => setState(() => _selected = next),
        // A locked file cannot be chosen, so it is left out of the tick-all too.
        isRowSelectable: (Doc row, int _) => !row.locked,
        toolbar: PlButton(
          size: PlassSize.sm,
          color: PlassColor.danger,
          variant: PlassVariant.ghost,
          onPressed: _selected.isEmpty ? null : () {},
          child: Text('Delete ${_selected.isEmpty ? '' : _selected.length}'),
        ),
        footer: Text('${_selected.length} of ${_rows.length} chosen'),
        columns: <PlDataTableColumn<Doc>>[
          PlDataTableColumn<Doc>(
            key: 'name',
            header: const Text('Name'),
            cell: (Doc row, int _) => Text(row.name),
          ),
          PlDataTableColumn<Doc>(
            key: 'size',
            header: const Text('Size'),
            align: PlassAlign.end,
            cell: (Doc row, int _) => Text(row.size),
          ),
        ],
      ),
    );
  }
}
