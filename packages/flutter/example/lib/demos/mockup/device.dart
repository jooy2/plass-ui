import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class MockupDevice extends StatelessWidget {
  const MockupDevice({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 32,
      runSpacing: 32,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        PlMockup(device: PlMockupDevice.mobile, width: 110),
        PlMockup(device: PlMockupDevice.tablet, width: 170),
        PlMockup(device: PlMockupDevice.desktop, width: 300),
        PlMockup(
          device: PlMockupDevice.desktop,
          hardware: PlMockupHardware.laptop,
          os: PlMockupOs.windows,
          width: 300,
        ),
      ],
    );
  }
}
