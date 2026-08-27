import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BoxPadded extends StatelessWidget {
  const BoxPadded({super.key});

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 448,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          const PlBox(child: PlTypography('padded — the default')),
          PlBox(
            padded: false,
            clipped: true,
            child: ColoredBox(
              color: tokens.family(PlassColor.primary).soft,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: PlTypography(
                  'padded: false — the content reaches the edges',
                  align: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
