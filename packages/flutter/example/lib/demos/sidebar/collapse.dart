import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SidebarCollapse extends StatelessWidget {
  const SidebarCollapse({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      height: 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.md]!),
        child: const PlPageLayout(
          collapseBelow: PlassBreakpoint.md,
          header: PlHeader(
            size: PlassSize.sm,
            brand: <Widget>[
              PlSidebarTrigger(size: PlassSize.sm),
              Text('Acme', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          sidebar: PlSidebar(
            size: PlassSize.sm,
            semanticLabel: 'Main navigation',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: <Widget>[Text('Overview'), Text('Reports'), Text('Settings')],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'This frame is narrower than md, so the column is a drawer and the hamburger is '
              'what brings it back.',
            ),
          ),
        ),
      ),
    );
  }
}
