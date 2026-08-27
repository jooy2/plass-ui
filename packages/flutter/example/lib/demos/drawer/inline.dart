import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DrawerInline extends StatelessWidget {
  const DrawerInline({super.key});

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 512,
      height: 256,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.lg]!),
        child: ColoredBox(
          color: tokens.glassPress,
          child: Row(
            children: <Widget>[
              const PlDrawer(
                mode: PlDrawerMode.inline,
                open: true,
                size: PlassSize.sm,
                extent: 200,
                title: Text('Sections'),
                child: PlList(
                  variant: PlassVariant.ghost,
                  size: PlassSize.sm,
                  children: <Widget>[
                    PlListItem(child: Text('Overview')),
                    PlListItem(child: Text('Members')),
                    PlListItem(child: Text('Billing')),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'The screen is laid out around it: no scrim, no portal, no focus trap, '
                    'nothing to dismiss.',
                    style: TextStyle(fontSize: 13, color: tokens.mutedFg),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
