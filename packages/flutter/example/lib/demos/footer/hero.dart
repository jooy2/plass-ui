import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const Map<String, List<String>> _columns = <String, List<String>>{
  'Product': <String>['Overview', 'Pricing', 'Changelog'],
  'Company': <String>['About', 'Careers', 'Contact'],
  'Legal': <String>['Privacy', 'Terms'],
};

class FooterHero extends StatelessWidget {
  const FooterHero({super.key});

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 520,
      child: PlFooter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 24,
              children: <Widget>[
                for (final MapEntry<String, List<String>> column in _columns.entries)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: <Widget>[
                        Text(
                          column.key.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: tokens.mutedFg,
                          ),
                        ),
                        for (final String link in column.value)
                          PlTextLink(onPressed: () {}, child: Text(link)),
                      ],
                    ),
                  ),
              ],
            ),
            const PlDivider(),
            Text(
              '© 2026 Acme. All rights reserved.',
              style: TextStyle(fontSize: 12, color: tokens.mutedFg),
            ),
          ],
        ),
      ),
    );
  }
}
