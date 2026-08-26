import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/grid/cell.dart';

class GridAlignment extends StatelessWidget {
  const GridAlignment({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 512,
      child: PlGrid(
        spacing: PlassResponsive<double>(3),
        alignItems: PlassAlignItems.center,
        items: <PlGridItem>[
          PlGridItem(span: PlassResponsive<int>(4), child: Cell('centred\nagainst\nthe tall one')),
          PlGridItem(span: PlassResponsive<int>(4), child: Cell('centred')),
          PlGridItem(
            span: PlassResponsive<int>(4),
            alignSelf: PlassAlignSelf.end,
            child: Cell('alignSelf end'),
          ),
        ],
      ),
    );
  }
}
