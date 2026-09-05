import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SkeletonMatching extends StatefulWidget {
  const SkeletonMatching({super.key});

  @override
  State<SkeletonMatching> createState() => _SkeletonMatchingState();
}

class _SkeletonMatchingState extends State<SkeletonMatching> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          PlButton(
            size: PlassSize.sm,
            variant: PlassVariant.glass,
            color: PlassColor.secondary,
            onPressed: () => setState(() => _loaded = !_loaded),
            child: Text(_loaded ? 'Show the placeholder' : 'Show the real thing'),
          ),
          Row(
            spacing: 12,
            children: <Widget>[
              if (_loaded)
                const PlAvatar(
                  name: 'Nadia Rowan',
                  image: NetworkImage('/samples/avatars/nadia-rowan.webp'),
                )
              else
                const PlSkeleton(shape: PlSkeletonShape.circle),
              Expanded(
                child: _loaded
                    ? const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4,
                        children: <Widget>[
                          PlTypography('Nadia Rowan', weight: PlTypographyWeight.semibold),
                          PlTypography('Design systems', level: PlTypographyLevel.caption),
                        ],
                      )
                    : const PlSkeleton(lines: 2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
