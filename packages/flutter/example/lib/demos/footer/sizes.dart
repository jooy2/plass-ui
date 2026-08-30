import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class FooterSizes extends StatelessWidget {
  const FooterSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      child: Column(
        spacing: 16,
        children: <Widget>[
          for (final PlassSize size in PlassSize.values)
            PlFooter(size: size, child: Text('© 2026 Acme — ${size.name}')),
        ],
      ),
    );
  }
}
