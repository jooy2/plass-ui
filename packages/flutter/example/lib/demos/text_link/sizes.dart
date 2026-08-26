import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TextLinkSizes extends StatelessWidget {
  const TextLinkSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: <Widget>[
        for (final size in PlassSize.values)
          PlTextLink(
            onPressed: () {},
            size: size,
            color: PlassColor.primary,
            child: Text('size: ${size.name}'),
          ),
      ],
    );
  }
}
