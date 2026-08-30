import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HeaderSizes extends StatelessWidget {
  const HeaderSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      child: Column(
        spacing: 16,
        children: <Widget>[
          for (final PlassSize size in PlassSize.values)
            PlHeader(
              size: size,
              brand: <Widget>[Text(size.name, style: const TextStyle(fontWeight: FontWeight.w600))],
              actions: <Widget>[
                PlButton(size: size, onPressed: () {}, child: const Text('Sign in')),
              ],
            ),
        ],
      ),
    );
  }
}
