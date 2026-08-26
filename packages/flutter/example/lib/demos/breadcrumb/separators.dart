import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BreadcrumbSeparators extends StatelessWidget {
  const BreadcrumbSeparators({super.key});

  @override
  Widget build(BuildContext context) {
    List<PlBreadcrumbItem> steps(String last) {
      return <PlBreadcrumbItem>[
        PlBreadcrumbItem(label: const Text('Home'), onPressed: () {}),
        PlBreadcrumbItem(label: const Text('Docs'), onPressed: () {}),
        PlBreadcrumbItem(label: Text(last)),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final separator in PlBreadcrumbSeparator.values)
          PlBreadcrumb(items: steps(separator.name), separator: separator),
        PlBreadcrumb(
          items: steps('a widget of your own'),
          separatorWidget: PlTypography('→', color: PlassColor.secondary),
        ),
      ],
    );
  }
}
