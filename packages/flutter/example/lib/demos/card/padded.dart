import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CardPadded extends StatelessWidget {
  const CardPadded({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: PlCard(
        padded: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 112,
              child: Image(
                image: NetworkImage('/samples/photos/artisan-bread-wooden-rack.webp'),
                fit: BoxFit.cover,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: <Widget>[
                  PlTypography('Full bleed', weight: PlTypographyWeight.semibold),
                  PlTypography(
                    'With padded off the sheet keeps no inset, so the banner reaches all four '
                    'edges and the text brings its own.',
                    level: PlTypographyLevel.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
