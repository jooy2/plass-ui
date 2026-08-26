import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SliderHero extends StatefulWidget {
  const SliderHero({super.key});

  @override
  State<SliderHero> createState() => _SliderHeroState();
}

class _SliderHeroState extends State<SliderHero> {
  double _volume = 62;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: PlSlider(
        label: const Text('Volume'),
        values: <double>[_volume],
        showValue: true,
        formatValue: (List<double> values) => '${values.first.round()}%',
        onChanged: (List<double> next) => setState(() => _volume = next.first),
      ),
    );
  }
}
