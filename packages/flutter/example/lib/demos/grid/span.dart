import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/grid/cell.dart';

class GridSpan extends StatelessWidget {
  const GridSpan({super.key});

  static const List<List<int>> _rows = <List<int>>[
    <int>[12],
    <int>[6, 6],
    <int>[4, 4, 4],
    <int>[3, 3, 3, 3],
    <int>[8, 4],
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: <Widget>[
          for (final List<int> row in _rows)
            PlGrid(
              items: <PlGridItem>[
                for (final int span in row)
                  PlGridItem(span: PlassResponsive<int>(span), child: Cell('$span')),
              ],
            ),
        ],
      ),
    );
  }
}
