import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class EmptyTable extends StatelessWidget {
  const EmptyTable({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 460,
      child: PlTable<Map<String, String>>(
        columns: <PlTableColumn<Map<String, String>>>[
          PlTableColumn<Map<String, String>>(
            header: const Text('Name'),
            cell: (Map<String, String> row, int _) => Text(row['name'] ?? ''),
          ),
          PlTableColumn<Map<String, String>>(
            header: const Text('Id'),
            cell: (Map<String, String> row, int _) => Text(row['id'] ?? ''),
          ),
        ],
        rows: const <Map<String, String>>[],
        empty: PlEmpty(
          size: PlassSize.sm,
          title: const Text('Nothing matches that filter'),
          description: const Text('Clear it to see everything again.'),
          actions: <Widget>[
            PlButton(
              size: PlassSize.sm,
              variant: PlassVariant.glass,
              color: PlassColor.secondary,
              onPressed: () {},
              child: const Text('Clear filters'),
            ),
          ],
        ),
      ),
    );
  }
}
