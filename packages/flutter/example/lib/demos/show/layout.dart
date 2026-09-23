import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Service {
  const Service(this.name, this.region, this.status);

  final String name;
  final String region;
  final String status;
}

const List<Service> _rows = <Service>[
  Service('api', 'ap-northeast-2', 'Healthy'),
  Service('worker', 'eu-west-1', 'Degraded'),
];

class ShowLayout extends StatelessWidget {
  const ShowLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PlShow(
            from: PlassBreakpointFloor.md,
            child: PlTable<Service>(
              rows: _rows,
              columns: <PlTableColumn<Service>>[
                PlTableColumn<Service>(
                  header: const Text('Service'),
                  cell: (Service row, int index) => Text(row.name),
                ),
                PlTableColumn<Service>(
                  header: const Text('Region'),
                  cell: (Service row, int index) => Text(row.region),
                ),
                PlTableColumn<Service>(
                  header: const Text('Status'),
                  cell: (Service row, int index) => Text(row.status),
                ),
              ],
            ),
          ),
          PlShow(
            until: PlassBreakpointFloor.md,
            child: PlList(
              dividers: true,
              children: <Widget>[
                for (final Service row in _rows)
                  PlListItem(
                    description: Text('${row.region} · ${row.status}'),
                    child: Text(row.name),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
