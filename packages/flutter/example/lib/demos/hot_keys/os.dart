import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HotKeysOs extends StatelessWidget {
  const HotKeysOs({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        for (final os in PlHotKeysOS.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: <Widget>[
              SizedBox(width: 80, child: PlTypography(os.name, level: PlTypographyLevel.caption)),
              PlHotKeys(keys: 'Mod+Shift+P', os: os),
            ],
          ),
      ],
    );
  }
}
