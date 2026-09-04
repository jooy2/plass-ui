import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// Artwork with its own background and its own margin — the case `bare` exists
/// for, and the case a plate or a circle would ruin.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return Container(
      width: 108,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tokens.family(PlassColor.info).soft,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('ACME CO', style: TextStyle(color: tokens.fg, fontSize: 13, letterSpacing: 2)),
    );
  }
}

class AppLogoShapes extends StatelessWidget {
  const AppLogoShapes({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: <Widget>[
          PlAppLogo(semanticLabel: 'Acme Co', child: _Wordmark()),
          PlAppLogo(shape: PlAppLogoShape.plate, semanticLabel: 'Acme Co', child: _Wordmark()),
        ],
      ),
    );
  }
}
