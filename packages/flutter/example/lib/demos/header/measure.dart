import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HeaderMeasure extends StatelessWidget {
  const HeaderMeasure({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: Column(
        children: <Widget>[
          const PlHeader(
            size: PlassSize.sm,
            maxWidth: PlassSize.xs,
            brand: <Widget>[Text('Acme', style: TextStyle(fontWeight: FontWeight.w600))],
            actions: <Widget>[Text('Account')],
          ),
          const PlContainer(
            size: PlassSize.sm,
            maxWidth: PlassSize.xs,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'The sheet spans the frame; the row inside it stops where the container under it '
                'does, so the logo and this paragraph sit on one edge.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
