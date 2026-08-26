import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SkeletonShapes extends StatelessWidget {
  const SkeletonShapes({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 448,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: <Widget>[
          PlSkeleton(),
          PlSkeleton(lines: 4),
          PlSkeleton(shape: PlSkeletonShape.rect),
          PlSkeleton(shape: PlSkeletonShape.circle),
        ],
      ),
    );
  }
}
