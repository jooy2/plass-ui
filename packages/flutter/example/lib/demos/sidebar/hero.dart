import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<String> _items = <String>['Overview', 'Reports', 'Customers', 'Settings'];

class SidebarHero extends StatelessWidget {
  const SidebarHero({super.key});

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 520,
      height: 320,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.md]!),
        child: PlPageLayout(
          collapseBelow: null,
          header: const PlHeader(
            size: PlassSize.sm,
            brand: <Widget>[Text('Acme', style: TextStyle(fontWeight: FontWeight.w600))],
          ),
          sidebar: PlSidebar(
            size: PlassSize.sm,
            semanticLabel: 'Main navigation',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: <Widget>[
                for (final String item in _items)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: item == _items.first ? tokens.family(PlassColor.primary).soft : null,
                      borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.sm]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontWeight: item == _items.first ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: <Widget>[
                Text('Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(
                  'The column is the complementary landmark — related to the screen, but not '
                  'the screen.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
