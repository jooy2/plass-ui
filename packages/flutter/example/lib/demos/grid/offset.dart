import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/grid/cell.dart';

class GridOffset extends StatelessWidget {
  const GridOffset({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 512,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: <Widget>[
          PlGrid(
            items: <PlGridItem>[
              PlGridItem(
                span: PlassResponsive<int>(4),
                offset: PlassResponsive<int>(4),
                child: Cell('span 4, offset 4'),
              ),
            ],
          ),
          PlGrid(
            items: <PlGridItem>[
              PlGridItem(span: PlassResponsive<int>(4), child: Cell('span 4')),
              PlGridItem(
                span: PlassResponsive<int>(4),
                offset: PlassResponsive<int>(4),
                child: Cell('span 4, offset 4'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
