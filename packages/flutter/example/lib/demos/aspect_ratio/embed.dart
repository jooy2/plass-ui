import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AspectRatioEmbed extends StatelessWidget {
  const AspectRatioEmbed({super.key});

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 448,
      child: PlAspectRatio(
        ratio: 16 / 9,
        rounded: true,
        size: PlassSize.lg,
        child: ColoredBox(
          color: tokens.glassPress,
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'A player, a map, a chart — anything that has to keep 16 / 9',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
