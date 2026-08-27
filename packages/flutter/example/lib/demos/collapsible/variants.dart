import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CollapsibleVariants extends StatefulWidget {
  const CollapsibleVariants({super.key});

  @override
  State<CollapsibleVariants> createState() => _CollapsibleVariantsState();
}

class _CollapsibleVariantsState extends State<CollapsibleVariants> {
  final Set<PlassVariant> _open = <PlassVariant>{PlassVariant.glass};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final PlassVariant variant in PlassVariant.values)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: <Widget>[
                PlTypography(variant.name, level: PlTypographyLevel.caption),
                PlCollapsible(
                  variant: variant,
                  open: _open.contains(variant),
                  onOpenChanged: (bool next) => setState(() {
                    next ? _open.add(variant) : _open.remove(variant);
                  }),
                  title: const Text('What is inside'),
                  child: const Text(
                    "The sheet is never dyed: a fold holds other people's content.",
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
