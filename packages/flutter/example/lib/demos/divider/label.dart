import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DividerLabel extends StatelessWidget {
  const DividerLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: <Widget>[
          for (final align in PlassAlign.values)
            PlDivider(textAlign: align, child: Text(align.name)),
        ],
      ),
    );
  }
}
