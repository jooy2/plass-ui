import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TextLinkIcons extends StatelessWidget {
  const TextLinkIcons({super.key});

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
          PlTextLink(onPressed: () {}, external: true, child: const Text('Base UI')),
          '— the arrow arrives with external.',
        ),
        line(
          PlTextLink(onPressed: () {}, showIcon: true, child: const Text('The chain')),
          '— showIcon on its own, for a link that stays here.',
        ),
        line(
          PlTextLink(
            onPressed: () {},
            external: true,
            showIcon: false,
            child: const Text('No mark at all'),
          ),
          '— still announced as leaving.',
        ),
      ],
    );
  }
}
