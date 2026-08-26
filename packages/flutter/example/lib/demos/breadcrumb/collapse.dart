import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<String> _steps = <String>[
  'Home',
  'Projects',
  'Aurora',
  'Services',
  'Ingest',
  'Settings',
];

class BreadcrumbCollapse extends StatelessWidget {
  const BreadcrumbCollapse({super.key});

  @override
  Widget build(BuildContext context) {
    List<PlBreadcrumbItem> trail() {
      return <PlBreadcrumbItem>[
        for (var index = 0; index < _steps.length; index += 1)
          PlBreadcrumbItem(
            label: Text(_steps[index]),
            onPressed: index == _steps.length - 1 ? null : () {},
          ),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        PlBreadcrumb(items: trail(), maxItems: 4),
        PlBreadcrumb(
          items: trail(),
          maxItems: 4,
          itemsBeforeCollapse: 2,
          itemsAfterCollapse: 2,
          expandable: false,
        ),
      ],
    );
  }
}
