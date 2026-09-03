import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/panes/filled.dart';

class PanesOrientation extends StatelessWidget {
  const PanesOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      height: 224,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.lg]!),
        child: const PlPanes(
          panes: <PlPane>[
            PlPane(defaultSize: PlPaneSize.percent(40), child: Filled('Left')),
            PlPane(
              child: PlPanes(
                orientation: PlassResponsive<PlassOrientation>(PlassOrientation.vertical),
                panes: <PlPane>[
                  PlPane(child: Filled('Top right')),
                  PlPane(child: Filled('Bottom right')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
