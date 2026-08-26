import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BadgeSizes extends StatelessWidget {
  const BadgeSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[for (final size in PlassSize.values) PlBadge(size: size, count: 12)],
    );
  }
}
