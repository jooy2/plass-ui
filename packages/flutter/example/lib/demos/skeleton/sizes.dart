import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SkeletonSizes extends StatelessWidget {
  const SkeletonSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: <Widget>[
          for (final size in PlassSize.values)
            Row(
              spacing: 16,
              children: <Widget>[
                SizedBox(
                  width: 32,
                  child: PlTypography(size.name, level: PlTypographyLevel.caption),
                ),
                Expanded(child: PlSkeleton(size: size, lines: 2)),
                PlSkeleton(size: size, shape: PlSkeletonShape.circle),
              ],
            ),
        ],
      ),
    );
  }
}
