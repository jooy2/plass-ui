import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AspectRatioRatios extends StatelessWidget {
  const AspectRatioRatios({super.key});

  static const Map<String, double> _ratios = <String, double>{
    '1 / 1': 1,
    '4 / 3': 4 / 3,
    '16 / 9': 16 / 9,
    '21 / 9': 21 / 9,
  };

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 512,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          for (final MapEntry<String, double> entry in _ratios.entries)
            Expanded(
              child: PlAspectRatio(
                ratio: entry.value,
                rounded: true,
                child: ColoredBox(
                  color: tokens.glassPress,
                  child: Center(child: Text(entry.key, style: const TextStyle(fontSize: 11))),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
