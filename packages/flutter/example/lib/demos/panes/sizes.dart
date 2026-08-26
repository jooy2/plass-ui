import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/panes/filled.dart';

class PanesSizes extends StatelessWidget {
  const PanesSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final PlassSize size in <PlassSize>[PlassSize.xs, PlassSize.md, PlassSize.xl])
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: <Widget>[
                PlTypography('size: ${size.name}', level: PlTypographyLevel.caption),
                SizedBox(
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.md]!),
                    child: PlPanes(
                      size: size,
                      color: PlassColor.info,
                      panes: const <PlPane>[
                        PlPane(child: Filled('One')),
                        PlPane(child: Filled('Two')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
