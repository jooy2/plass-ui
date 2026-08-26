import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class OverlayDismissible extends StatefulWidget {
  const OverlayDismissible({super.key});

  @override
  State<OverlayDismissible> createState() => _OverlayDismissibleState();
}

class _OverlayDismissibleState extends State<OverlayDismissible> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    // A preview is as tall as its content, and a sheet takes away whatever it is
    // inside. This is the page for it to take.
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          PlButton(
            size: PlassSize.sm,
            onPressed: () => setState(() => _open = true),
            child: const Text('Open a dismissible one'),
          ),
          PlOverlay(
            open: _open,
            dismissible: true,
            tone: PlOverlayTone.glass,
            label: 'Press anywhere to close',
            onOpenChanged: (bool next) => setState(() => _open = next),
            child: const PlTypography(
              'Press anywhere, or Escape.',
              level: PlTypographyLevel.lead,
              color: PlassColor.primary,
            ),
          ),
        ],
      ),
    );
  }
}
