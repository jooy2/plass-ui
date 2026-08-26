import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SkeletonAnimated extends StatelessWidget {
  const SkeletonAnimated({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 448,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: <Widget>[
          PlSkeleton(lines: 2),
          PlSkeleton(lines: 2, animated: false),
          PlSkeleton(shape: PlSkeletonShape.rect, height: 56, color: PlassColor.primary),
        ],
      ),
    );
  }
}
