import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BreadcrumbCurrent extends StatelessWidget {
  const BreadcrumbCurrent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        PlBreadcrumb(
          items: <PlBreadcrumbItem>[
            PlBreadcrumbItem(label: const Text('Home'), onPressed: () {}),
            PlBreadcrumbItem(label: const Text('Docs'), onPressed: () {}),
            const PlBreadcrumbItem(label: Text('The last step is the current one')),
          ],
        ),
        PlBreadcrumb(
          items: <PlBreadcrumbItem>[
            PlBreadcrumbItem(label: const Text('Home'), onPressed: () {}),
            PlBreadcrumbItem(
              label: const Text('Claimed here instead'),
              current: true,
              onPressed: () {},
            ),
            PlBreadcrumbItem(label: const Text('Still a link'), onPressed: () {}),
          ],
        ),
        PlBreadcrumb(
          items: <PlBreadcrumbItem>[
            PlBreadcrumbItem(label: const Text('Home'), onPressed: () {}),
            PlBreadcrumbItem(label: const Text('Unavailable'), disabled: true, onPressed: () {}),
            const PlBreadcrumbItem(label: Text('Here')),
          ],
        ),
      ],
    );
  }
}
