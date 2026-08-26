import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DividerHero extends StatelessWidget {
  const DividerHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 448,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          PlTypography('Continue with your work email.'),
          PlDivider(child: Text('OR')),
          PlTypography('Use a single sign-on provider.'),
        ],
      ),
    );
  }
}
