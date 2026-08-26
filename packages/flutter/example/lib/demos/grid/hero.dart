import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/grid/cell.dart';

class GridHero extends StatelessWidget {
  const GridHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 640,
      child: PlGrid(
        spacing: const PlassResponsive<double>(3),
        items: <PlGridItem>[
          for (int index = 0; index < 4; index++)
            const PlGridItem(span: PlassResponsive<int>(12, sm: 6, lg: 3), child: Cell('3')),
          const PlGridItem(span: PlassResponsive<int>(12, md: 8), child: Cell('8')),
          const PlGridItem(span: PlassResponsive<int>(12, md: 4), child: Cell('4')),
        ],
      ),
    );
  }
}
