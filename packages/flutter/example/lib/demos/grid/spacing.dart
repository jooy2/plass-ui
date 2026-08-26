import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/grid/cell.dart';

class GridSpacing extends StatelessWidget {
  const GridSpacing({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          for (final double spacing in <double>[0, 2, 6])
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: <Widget>[
                PlTypography('spacing: $spacing', level: PlTypographyLevel.caption),
                PlGrid(
                  spacing: PlassResponsive<double>(spacing),
                  items: <PlGridItem>[
                    for (int index = 0; index < 4; index++)
                      const PlGridItem(span: PlassResponsive<int>(3), child: Cell('3')),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
