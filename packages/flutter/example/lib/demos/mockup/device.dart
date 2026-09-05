import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const BoxDecoration _dawn = BoxDecoration(
  image: DecorationImage(
    image: NetworkImage('/samples/illustrations/layered-mountains-rising-sun.webp'),
    fit: BoxFit.cover,
  ),
);

const BoxDecoration _night = BoxDecoration(
  image: DecorationImage(
    image: NetworkImage('/samples/illustrations/night-train-floating-lanterns.webp'),
    fit: BoxFit.cover,
  ),
);

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
        PlMockup(device: PlMockupDevice.mobile, width: 110, wallpaper: _dawn),
        PlMockup(device: PlMockupDevice.tablet, width: 170, wallpaper: _night),
        PlMockup(device: PlMockupDevice.desktop, width: 300, wallpaper: _dawn),
        PlMockup(
          device: PlMockupDevice.desktop,
          hardware: PlMockupHardware.laptop,
          os: PlMockupOs.windows,
          width: 300,
          wallpaper: _night,
        ),
      ],
    );
  }
}
