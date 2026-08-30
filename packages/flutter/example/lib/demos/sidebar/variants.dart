import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SidebarVariants extends StatelessWidget {
  const SidebarVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        for (final PlassVariant variant in PlassVariant.values)
          SizedBox(
            width: 220,
            height: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.md]!),
              child: PlPageLayout(
                collapseBelow: null,
                sidebar: PlSidebar(
                  size: PlassSize.xs,
                  width: 90,
                  variant: variant,
                  semanticLabel: variant.name,
                  child: Text(variant.name),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('The panel is never dyed.'),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
