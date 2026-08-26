import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DividerOrientation extends StatelessWidget {
  const DividerOrientation({super.key});

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
          // A vertical divider takes the height of whatever gives it one, so the
          // toolbar row is measured by its tallest item first.
          IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: <Widget>[
                PlTypography('Cut'),
                PlDivider(orientation: PlassOrientation.vertical),
                PlTypography('Copy'),
                PlDivider(orientation: PlassOrientation.vertical),
                PlTypography('Paste'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
