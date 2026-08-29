import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateLightingHero extends StatelessWidget {
  const AnimateLightingHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 340,
      child: PlAnimateLighting(
        size: PlassSize.lg,
        child: PlCard(
          size: PlassSize.lg,
          title: Text('Recommended'),
          subtitle: Text('Team — £29 a seat'),
          headerAction: PlChip(size: PlassSize.sm, child: Text('Most picked')),
          child: Text('Unlimited projects, audit log, and single sign-on.'),
        ),
      ),
    );
  }
}
