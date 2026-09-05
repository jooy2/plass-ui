import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class MockupFinish extends StatelessWidget {
  const MockupFinish({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        for (final PlMockupFinish finish in PlMockupFinish.values)
          PlMockup(device: PlMockupDevice.mobile, finish: finish, width: 110, elevation: 2),
      ],
    );
  }
}
