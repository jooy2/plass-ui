import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class PageLayoutHero extends StatelessWidget {
  const PageLayoutHero({super.key});

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 520,
      height: 320,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.md]!),
        child: PlPageLayout(
          collapseBelow: null,
          header: PlToolbar(
            divider: true,
            rounded: false,
            size: PlassSize.sm,
            start: const <Widget>[Text('Acme', style: TextStyle(fontWeight: FontWeight.w600))],
            end: <Widget>[
              PlButton(size: PlassSize.sm, onPressed: () {}, child: const Text('Sign in')),
            ],
          ),
          sidebar: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: tokens.divider)),
            ),
            child: const SizedBox(
              width: 160,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: <Widget>[Text('Overview'), Text('Reports'), Text('Settings')],
                ),
              ),
            ),
          ),
          footer: PlToolbar(
            divider: true,
            rounded: false,
            side: PlassSide.bottom,
            size: PlassSize.sm,
            density: PlassDensity.compact,
            child: Text('© 2026 Acme', style: TextStyle(color: tokens.mutedFg, fontSize: 12)),
          ),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: <Widget>[
                Text('Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('Everything between the bars is the main region.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
