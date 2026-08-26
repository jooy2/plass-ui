import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SkeletonHero extends StatelessWidget {
  const SkeletonHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 448,
      child: PlCard(
        title: PlSkeleton(width: 160, label: 'Loading the card'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: <Widget>[
            PlSkeleton(shape: PlSkeletonShape.rect, height: 120),
            Row(
              spacing: 12,
              children: <Widget>[
                PlSkeleton(shape: PlSkeletonShape.circle),
                Expanded(child: PlSkeleton(lines: 2)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
