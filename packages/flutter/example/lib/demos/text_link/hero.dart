import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TextLinkHero extends StatelessWidget {
  const TextLinkHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: <Widget>[
          const PlTypography('Every gradient stop is measured against its own label — the'),
          const PlTypography('numbers are in'),
          PlTextLink(onPressed: () {}, child: const Text('the colour reference')),
          const PlTypography(', and the reasoning is in'),
          PlTextLink(onPressed: () {}, external: true, child: const Text('WCAG 2.2')),
        ],
      ),
    );
  }
}
