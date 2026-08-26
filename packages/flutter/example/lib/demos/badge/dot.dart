import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BadgeDot extends StatelessWidget {
  const BadgeDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 32,
      runSpacing: 32,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlBadge(
          dot: true,
          color: PlassColor.danger,
          label: 'Unsaved changes',
          child: PlButton(
            variant: PlassVariant.glass,
            color: PlassColor.secondary,
            onPressed: () {},
            child: const Text('Draft'),
          ),
        ),
        PlBadge(
          dot: true,
          count: 12,
          color: PlassColor.warning,
          label: '12 items need review',
          child: PlButton(
            variant: PlassVariant.glass,
            color: PlassColor.secondary,
            onPressed: () {},
            child: const Text('Review queue'),
          ),
        ),
        const PlBadge(dot: true, color: PlassColor.success),
      ],
    );
  }
}
