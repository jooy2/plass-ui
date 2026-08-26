import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class OverlayTones extends StatefulWidget {
  const OverlayTones({super.key});

  @override
  State<OverlayTones> createState() => _OverlayTonesState();
}

class _OverlayTonesState extends State<OverlayTones> {
  PlOverlayTone? _tone;

  @override
  Widget build(BuildContext context) {
    // A preview is as tall as its content, and a sheet takes away whatever it is
    // inside. This is the page for it to take.
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final tone in PlOverlayTone.values)
                PlButton(
                  size: PlassSize.sm,
                  variant: PlassVariant.glass,
                  color: PlassColor.secondary,
                  onPressed: () => setState(() => _tone = tone),
                  child: Text(tone.name),
                ),
            ],
          ),
          const PlTypography(
            'Press one, then press the sheet to close it.',
            level: PlTypographyLevel.caption,
          ),
          PlOverlay(
            open: _tone != null,
            dismissible: true,
            tone: _tone ?? PlOverlayTone.scrim,
            label: 'The ${_tone?.name} overlay',
            onOpenChanged: (bool next) => setState(() => _tone = null),
            child: PlTypography(
              _tone?.name ?? '',
              level: PlTypographyLevel.h4,
              color: PlassColor.primary,
            ),
          ),
        ],
      ),
    );
  }
}
