import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CardSlots extends StatelessWidget {
  const CardSlots({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        const SizedBox(
          width: 248,
          child: PlCard(title: Text('Title only'), child: Text('The body sits under it.')),
        ),
        const SizedBox(
          width: 248,
          child: PlCard(
            title: Text('With a subtitle'),
            subtitle: Text('One step down, and muted'),
            child: Text('The two are one block of text, so the gap between them is tight.'),
          ),
        ),
        SizedBox(
          width: 248,
          child: PlCard(
            title: const Text('With a header action'),
            headerAction: PlButton(
              size: PlassSize.xs,
              variant: PlassVariant.ghost,
              color: PlassColor.secondary,
              semanticLabel: 'More',
              onPressed: () {},
              child: const Text('•••'),
            ),
            child: const Text(
              'The action stays on the title’s line while the title wraps beside it.',
            ),
          ),
        ),
        SizedBox(
          width: 248,
          child: PlCard(
            title: const Text('With a footer'),
            footer: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                PlButton(size: PlassSize.sm, onPressed: () {}, child: const Text('Save')),
                PlButton(
                  size: PlassSize.sm,
                  variant: PlassVariant.ghost,
                  color: PlassColor.secondary,
                  onPressed: () {},
                  child: const Text('Cancel'),
                ),
              ],
            ),
            child: const Text('A footer is one widget, so a pair of buttons brings its own row.'),
          ),
        ),
      ],
    );
  }
}
