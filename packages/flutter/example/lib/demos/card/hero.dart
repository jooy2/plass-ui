import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CardHero extends StatelessWidget {
  const CardHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: PlCard(
        title: const Text('Team plan'),
        subtitle: const Text('Billed yearly'),
        headerAction: PlTypography(
          'Current',
          level: PlTypographyLevel.caption,
          color: PlassColor.primary,
          weight: PlTypographyWeight.semibold,
        ),
        // One widget, so a footer with two buttons in it brings its own row.
        footer: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            PlButton(size: PlassSize.sm, onPressed: () {}, child: const Text('Upgrade')),
            PlButton(
              size: PlassSize.sm,
              variant: PlassVariant.ghost,
              color: PlassColor.secondary,
              onPressed: () {},
              child: const Text('Compare plans'),
            ),
          ],
        ),
        child: const Text(
          'Everything in Pro, plus shared projects, audit logs and a seat for anyone you invite.',
        ),
      ),
    );
  }
}
