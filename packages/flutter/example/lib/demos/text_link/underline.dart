import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TextLinkUnderline extends StatelessWidget {
  const TextLinkUnderline({super.key});

  @override
  Widget build(BuildContext context) {
    Widget line(PlTextLink link, String note) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: <Widget>[link, PlTypography(note)],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: <Widget>[
        line(
          PlTextLink(onPressed: () {}, child: const Text('always')),
          '— the default, and the only mark a reader already knows.',
        ),
        line(
          PlTextLink(
            onPressed: () {},
            underline: PlTextLinkUnderline.hover,
            child: const Text('hover'),
          ),
          '— for a dense list where every line is a link.',
        ),
        line(
          PlTextLink(
            onPressed: () {},
            underline: PlTextLinkUnderline.none,
            color: PlassColor.primary,
            child: const Text('none'),
          ),
          '— only where the surroundings already say what it is.',
        ),
      ],
    );
  }
}
