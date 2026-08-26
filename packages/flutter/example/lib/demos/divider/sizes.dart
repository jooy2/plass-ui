import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DividerSizes extends StatelessWidget {
  const DividerSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: <Widget>[
          for (final size in PlassSize.values) PlDivider(size: size, child: Text(size.name)),
        ],
      ),
    );
  }
}
