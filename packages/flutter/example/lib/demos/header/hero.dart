import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HeaderHero extends StatelessWidget {
  const HeaderHero({super.key});

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 520,
      child: PlHeader(
        brand: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: tokens.family(PlassColor.primary).fill,
              borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.sm]!),
            ),
            child: SizedBox(
              width: 28,
              height: 28,
              child: Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    color: tokens.family(PlassColor.primary).onSolid,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          const Text('Acme', style: TextStyle(fontWeight: FontWeight.w600)),
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
