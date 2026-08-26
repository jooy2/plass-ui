import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DividerLength extends StatelessWidget {
  const DividerLength({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 448,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: <Widget>[
          PlDivider(),
          PlDivider(length: 160),
          PlDivider(length: 224, thickness: 2),
          PlDivider(thickness: 4),
        ],
      ),
    );
  }
}
