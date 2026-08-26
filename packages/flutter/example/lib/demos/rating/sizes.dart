import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class RatingSizes extends StatelessWidget {
  const RatingSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        for (final PlassSize size in PlassSize.values)
          PlRating(value: 4, size: size, readOnly: true),
      ],
    );
  }
}
