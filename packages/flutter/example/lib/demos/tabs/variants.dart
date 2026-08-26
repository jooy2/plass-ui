import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TabsVariants extends StatelessWidget {
  const TabsVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          for (final variant in PlassVariant.values)
            PlTabs<String>(
              variant: variant,
              size: PlassSize.sm,
              value: 'one',
              onChanged: (String next) {},
              tabs: <PlTab<String>>[
                PlTab<String>(
                  value: 'one',
                  label: const Text('First'),
                  panel: Text('The bar is ${variant.name}.'),
                ),
                const PlTab<String>(value: 'two', label: Text('Second')),
                const PlTab<String>(value: 'three', label: Text('Third')),
              ],
            ),
        ],
      ),
    );
  }
}
