import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SidebarSides extends StatelessWidget {
  const SidebarSides({super.key});

  @override
  Widget build(BuildContext context) {
    // Scrolled rather than squeezed: two bars and a page do not fit a phone.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 520,
        height: 220,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(PlassTheme.of(context).radii[PlassSize.md]!),
          child: const PlPageLayout(
            collapseBelow: null,
            sidebar: PlSidebar(
              size: PlassSize.xs,
              width: 140,
              semanticLabel: 'Navigation',
              child: Text('Navigation'),
            ),
            endSidebar: PlSidebar(
              size: PlassSize.xs,
              width: 140,
              semanticLabel: 'On this page',
              child: Text('On this page'),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Two columns, one on each end. Neither needs a side of its own: the slot it was '
                'handed to is what decides.',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
