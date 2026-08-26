import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class OverlayAlign extends StatefulWidget {
  const OverlayAlign({super.key});

  @override
  State<OverlayAlign> createState() => _OverlayAlignState();
}

class _OverlayAlignState extends State<OverlayAlign> {
  PlassAlign? _align;

  @override
  Widget build(BuildContext context) {
    // A preview is as tall as its content, and a sheet takes away whatever it is
    // inside. This is the page for it to take.
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final align in PlassAlign.values)
                PlButton(
                  size: PlassSize.sm,
                  variant: PlassVariant.glass,
                  color: PlassColor.secondary,
                  onPressed: () => setState(() => _align = align),
                  child: Text(align.name),
                ),
            ],
          ),
          PlOverlay(
            open: _align != null,
            dismissible: true,
            align: _align ?? PlassAlign.center,
            label: 'Aligned to ${_align?.name}',
            onOpenChanged: (bool next) => setState(() => _align = null),
            child: PlTypography(
              _align?.name ?? '',
              level: PlTypographyLevel.h4,
              color: PlassColor.primary,
            ),
          ),
        ],
      ),
    );
  }
}
