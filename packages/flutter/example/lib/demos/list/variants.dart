import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ListVariants extends StatelessWidget {
  const ListVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final variant in PlassVariant.values)
            PlList(
              variant: variant,
              size: PlassSize.sm,
              children: <Widget>[
                PlListItem(onPressed: () {}, child: Text(variant.name)),
                PlListItem(onPressed: () {}, child: const Text('A second row')),
              ],
            ),
        ],
      ),
    );
  }
}
