import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/panes/filled.dart';

class PanesHero extends StatelessWidget {
  const PanesHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      height: 224,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.lg]!),
        child: const PlPanes(
          label: 'Sidebar width',
          panes: <PlPane>[
            PlPane(
              defaultSize: PlPaneSize.pixels(180),
              minSize: PlPaneSize.pixels(120),
              maxSize: PlPaneSize.percent(60),
              child: Filled('Sidebar'),
            ),
            PlPane(child: Filled('Body — drag the handle')),
          ],
        ),
      ),
    );
  }
}
