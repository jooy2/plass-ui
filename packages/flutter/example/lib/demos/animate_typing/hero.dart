import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateTypingHero extends StatelessWidget {
  const AnimateTypingHero({super.key});

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: <Widget>[
        const PlTypography('Terminal', level: PlTypographyLevel.overline),
        DefaultTextStyle(
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 16,
            color: tokens.family(PlassColor.primary).accent,
          ),
          child: const PlAnimateTyping(
            'flutter pub add plass_ui',
            speed: 14,
            hold: Duration(milliseconds: 1600),
            erase: true,
            repeat: null,
          ),
        ),
      ],
    );
  }
}
