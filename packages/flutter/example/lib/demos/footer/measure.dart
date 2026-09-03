import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class FooterMeasure extends StatelessWidget {
  const FooterMeasure({super.key});

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 560,
      child: Column(
        children: <Widget>[
          const PlContainer(
            size: PlassSize.sm,
            maxWidth: PlassResponsive<PlContainerWidth?>(PlContainerWidth.rung(PlassSize.xs)),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'The page stops at the measure, and so does the line under it — the sheet still '
                'reaches both edges of the frame.',
              ),
            ),
          ),
          PlFooter(
            size: PlassSize.sm,
            maxWidth: PlassResponsive<PlContainerWidth?>(PlContainerWidth.rung(PlassSize.xs)),
            child: Text('© 2026 Acme', style: TextStyle(fontSize: 12, color: tokens.mutedFg)),
          ),
        ],
      ),
    );
  }
}
