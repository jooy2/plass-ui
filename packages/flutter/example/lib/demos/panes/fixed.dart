import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/panes/filled.dart';

class PanesFixed extends StatelessWidget {
  const PanesFixed({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      height: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.lg]!),
        child: const PlPanes(
          resizable: false,
          panes: <PlPane>[
            PlPane(defaultSize: PlPaneSize.percent(25), child: Filled('A quarter')),
            PlPane(defaultSize: PlPaneSize.percent(50), child: Filled('A half')),
            PlPane(defaultSize: PlPaneSize.percent(25), child: Filled('A quarter')),
          ],
        ),
      ),
    );
  }
}
