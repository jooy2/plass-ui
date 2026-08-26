import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SliderRange extends StatefulWidget {
  const SliderRange({super.key});

  @override
  State<SliderRange> createState() => _SliderRangeState();
}

class _SliderRangeState extends State<SliderRange> {
  List<double> _price = <double>[25, 75];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: PlSlider(
        label: const Text('Price'),
        values: _price,
        showValue: true,
        formatValue: (List<double> values) =>
            '\$${values.first.round()} – \$${values.last.round()}',
        onChanged: (List<double> next) => setState(() => _price = next),
      ),
    );
  }
}
