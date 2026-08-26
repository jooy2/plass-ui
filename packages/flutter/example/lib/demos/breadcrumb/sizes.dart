import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BreadcrumbSizes extends StatelessWidget {
  const BreadcrumbSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        for (final size in PlassSize.values)
          PlBreadcrumb(
            size: size,
            items: <PlBreadcrumbItem>[
              PlBreadcrumbItem(label: const Text('Home'), onPressed: () {}),
              PlBreadcrumbItem(label: const Text('Docs'), onPressed: () {}),
              PlBreadcrumbItem(label: Text(size.name)),
            ],
          ),
      ],
    );
  }
}
