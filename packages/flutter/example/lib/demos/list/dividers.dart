import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ListDividers extends StatelessWidget {
  const ListDividers({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: <Widget>[
          PlList(
            children: <Widget>[
              PlListItem(onPressed: () {}, child: const Text('Tiles, with space between them')),
              PlListItem(onPressed: () {}, child: const Text('The sheet keeps its padding')),
            ],
          ),
          PlList(
            dividers: true,
            children: <Widget>[
              PlListItem(onPressed: () {}, child: const Text('Ruled lines, edge to edge')),
              PlListItem(onPressed: () {}, child: const Text('The sheet gives its padding up')),
            ],
          ),
        ],
      ),
    );
  }
}
