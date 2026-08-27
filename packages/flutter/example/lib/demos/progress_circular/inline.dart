import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class _Upload {
  const _Upload(this.name, this.done);

  final String name;
  final double? done;
}

const List<_Upload> _uploads = <_Upload>[
  _Upload('invoice-2026-03.pdf', 100),
  _Upload('annual-report.key', 48),
  _Upload('raw-footage.mov', null),
];

class ProgressCircularInline extends StatelessWidget {
  const ProgressCircularInline({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      child: PlTable<_Upload>(
        size: PlassSize.sm,
        rows: _uploads,
        columns: <PlTableColumn<_Upload>>[
          PlTableColumn<_Upload>(
            header: const Text('File'),
            cell: (_Upload row, int index) => Text(row.name),
          ),
          PlTableColumn<_Upload>(
            header: const Text('Upload'),
            align: PlassAlign.end,
            cell: (_Upload row, int index) => PlProgressCircular(
              size: PlassSize.xs,
              value: row.done,
              label: Text(row.name),
              showValue: true,
            ),
          ),
        ],
      ),
    );
  }
}
