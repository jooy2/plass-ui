import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ScrollAreaAxes extends StatelessWidget {
  const ScrollAreaAxes({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      width: 360,
      child: PlScrollArea(
        orientation: PlScrollAreaAxis.both,
        height: 200,
        scrollbars: PlScrollbars.always,
        label: 'A grid that runs off both edges',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int row = 0; row < 12; row += 1)
              Row(
                children: <Widget>[
                  for (int column = 0; column < 8; column += 1)
                    Container(
                      width: 96,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Text(
                        'R${row + 1} C${column + 1}',
                        style: TextStyle(color: tokens.mutedFg, fontSize: 13),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
