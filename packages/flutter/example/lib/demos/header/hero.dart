import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HeaderHero extends StatelessWidget {
  const HeaderHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 520,
      child: PlHeader(
        brand: <Widget>[
          PlAppLogo(
            size: PlassSize.sm,
            name: const Text('Acme'),
            onPressed: () {},
            child: const Image(image: NetworkImage('/samples/marks/lantern.webp')),
          ),
        ],
        actions: <Widget>[
          PlButton(
            size: PlassSize.sm,
            variant: PlassVariant.ghost,
            color: PlassColor.secondary,
            onPressed: () {},
            child: const Text('Log in'),
          ),
          PlButton(size: PlassSize.sm, onPressed: () {}, child: const Text('Sign up')),
        ],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: <Widget>[
            for (final String item in <String>['Product', 'Pricing', 'Docs'])
              PlTextLink(onPressed: () {}, child: Text(item)),
          ],
        ),
      ),
    );
  }
}
