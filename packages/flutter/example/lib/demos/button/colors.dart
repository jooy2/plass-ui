import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ButtonColors extends StatelessWidget {
  const ButtonColors({super.key});

  static const Map<PlassColor, String> _roles = <PlassColor, String>{
    PlassColor.primary: 'Primary',
    PlassColor.secondary: 'Secondary',
    PlassColor.success: 'Success',
    PlassColor.warning: 'Warning',
    PlassColor.danger: 'Danger',
    PlassColor.info: 'Info',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final variant in <PlassVariant>[PlassVariant.solid, PlassVariant.glass])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                for (final role in _roles.entries)
                  PlButton(
                    variant: variant,
                    color: role.key,
                    onPressed: () {},
                    child: Text(role.value),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
