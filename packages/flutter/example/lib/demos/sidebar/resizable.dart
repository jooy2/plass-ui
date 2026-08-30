import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SidebarResizable extends StatefulWidget {
  const SidebarResizable({super.key});

  @override
  State<SidebarResizable> createState() => _SidebarResizableState();
}

class _SidebarResizableState extends State<SidebarResizable> {
  double _width = 220;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 520,
      height: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.md]!),
        child: PlPageLayout(
          collapseBelow: null,
          sidebar: PlSidebar(
            size: PlassSize.sm,
            semanticLabel: 'Files',
            resizable: true,
            width: 220,
            minWidth: 140,
            maxWidth: 320,
            onResize: (double width) => setState(() => _width = width),
            child: const Text('Drag the inner edge.'),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'The column is ${_width.round()} wide. The handle straddles the edge rather than '
              'sitting inside it, and the arrow keys move it too.',
            ),
          ),
        ),
      ),
    );
  }
}
