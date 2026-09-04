import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// A stand-in for a product's own artwork: a bare glyph, which is the case a
/// plate exists for.
class _Glyph extends StatelessWidget {
  const _Glyph();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(dimension: 24, child: FittedBox(child: Text('A')));
  }
}

class AppLogoHero extends StatelessWidget {
  const AppLogoHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: <Widget>[
          PlAppLogo(shape: PlAppLogoShape.plate, name: Text('Acme'), child: _Glyph()),
          PlAppLogo(
            shape: PlAppLogoShape.circle,
            variant: PlassVariant.glass,
            name: Text('Acme'),
            description: Text('Staging'),
            child: _Glyph(),
          ),
          PlAppLogo(name: Text('Acme'), child: _Glyph()),
        ],
      ),
    );
  }
}
