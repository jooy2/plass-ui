import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HeaderAlign extends StatelessWidget {
  const HeaderAlign({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      child: Column(
        spacing: 16,
        children: <Widget>[
          for (final PlassAlign align in PlassAlign.values)
            PlHeader(
              size: PlassSize.sm,
              align: align,
              brand: const <Widget>[Text('Acme', style: TextStyle(fontWeight: FontWeight.w600))],
              actions: const <Widget>[Text('Account')],
              child: Text('align: ${align.name}'),
            ),
        ],
      ),
    );
  }
}
