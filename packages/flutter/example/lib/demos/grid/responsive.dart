import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/grid/cell.dart';

class GridResponsive extends StatelessWidget {
  const GridResponsive({super.key});

  static const List<String> _names = <String>['one', 'two', 'three', 'four', 'five', 'six'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 640,
      child: PlGrid(
        spacing: const PlassResponsive<double>(2, md: 4),
        items: <PlGridItem>[
          for (final String name in _names)
            PlGridItem(
              span: const PlassResponsive<int>(12, sm: 6, md: 4, xl: 2),
              child: Cell(name),
            ),
        ],
      ),
    );
  }
}
