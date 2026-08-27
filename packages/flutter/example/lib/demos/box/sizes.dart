import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BoxSizes extends StatelessWidget {
  const BoxSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final PlassSize size in PlassSize.values)
            PlBox(size: size, child: PlTypography('size: ${size.name}')),
        ],
      ),
    );
  }
}
