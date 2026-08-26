import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<String> _actions = <String>['Bold', 'Italic', 'Underline', 'Strikethrough'];

class TooltipProvider extends StatelessWidget {
  const TooltipProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return PlTooltipProvider(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            for (final action in _actions)
              PlTooltip(
                content: Text(action),
                child: PlButton(
                  size: PlassSize.sm,
                  variant: PlassVariant.ghost,
                  color: PlassColor.secondary,
                  semanticLabel: action,
                  onPressed: () {},
                  child: Text(action[0]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
