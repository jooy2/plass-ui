import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BadgeCounts extends StatelessWidget {
  const BadgeCounts({super.key});

  @override
  Widget build(BuildContext context) {
    Widget anchor(String label) {
      return PlButton(
        variant: PlassVariant.glass,
        color: PlassColor.secondary,
        size: PlassSize.sm,
        onPressed: () {},
        child: Text(label),
      );
    }

    return Wrap(
      spacing: 32,
      runSpacing: 32,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlBadge(count: 0, label: 'Nothing unread', child: anchor('0, hidden')),
        PlBadge(count: 0, showZero: true, label: 'Nothing unread', child: anchor('0, shown')),
        PlBadge(count: 128, label: '128 unread', child: anchor('capped')),
        PlBadge(count: 128, max: 999, label: '128 unread', child: anchor('max 999')),
      ],
    );
  }
}
