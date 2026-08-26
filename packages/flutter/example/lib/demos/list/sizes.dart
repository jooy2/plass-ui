import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ListSizes extends StatelessWidget {
  const ListSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final size in PlassSize.values)
            PlList(
              size: size,
              children: <Widget>[
                PlListItem(
                  description: const Text('and a description'),
                  onPressed: () {},
                  child: Text(size.name),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
