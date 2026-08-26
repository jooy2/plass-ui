import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SliderOrientation extends StatefulWidget {
  const SliderOrientation({super.key});

  @override
  State<SliderOrientation> createState() => _SliderOrientationState();
}

class _SliderOrientationState extends State<SliderOrientation> {
  final Map<String, double> _bands = <String, double>{'Bass': 30, 'Mid': 65, 'Treble': 48};

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 32,
      children: <Widget>[
        for (final band in _bands.keys)
          PlSlider(
            orientation: PlassOrientation.vertical,
            semanticLabel: band,
            values: <double>[_bands[band]!],
            onChanged: (List<double> next) => setState(() => _bands[band] = next.first),
          ),
      ],
    );
  }
}
