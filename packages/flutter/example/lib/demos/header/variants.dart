import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HeaderVariants extends StatelessWidget {
  const HeaderVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      child: Column(
        spacing: 16,
        children: <Widget>[
          for (final PlassVariant variant in PlassVariant.values)
            PlHeader(
              size: PlassSize.sm,
              variant: variant,
              brand: <Widget>[
                Text(variant.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
              actions: const <Widget>[Text('Account')],
            ),
        ],
      ),
    );
  }
}
