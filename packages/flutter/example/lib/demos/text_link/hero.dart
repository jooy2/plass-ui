import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TextLinkHero extends StatelessWidget {
  const TextLinkHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            const TextSpan(
              text: 'Every gradient stop is measured against its own label — the numbers are in ',
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: PlTextLink(onPressed: () {}, child: const Text('the colour reference')),
            ),
            const TextSpan(text: ', and the reasoning is in '),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: PlTextLink(onPressed: () {}, external: true, child: const Text('WCAG 2.2')),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
