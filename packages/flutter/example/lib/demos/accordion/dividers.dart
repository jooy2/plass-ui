import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AccordionDividers extends StatelessWidget {
  const AccordionDividers({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: <Widget>[
        SizedBox(
          width: 248,
          child: PlAccordion<String>(
            size: PlassSize.sm,
            value: const <String>{'one'},
            onChanged: (Set<String> next) {},
            items: const <PlAccordionItem<String>>[
              PlAccordionItem<String>(
                value: 'one',
                title: Text('Scored'),
                child: Text('The rule reaches both edges.'),
              ),
              PlAccordionItem<String>(
                value: 'two',
                title: Text('Second'),
                child: Text('One pane, two folds.'),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 248,
          child: PlAccordion<String>(
            size: PlassSize.sm,
            dividers: false,
            value: const <String>{'one'},
            onChanged: (Set<String> next) {},
            items: const <PlAccordionItem<String>>[
              PlAccordionItem<String>(
                value: 'one',
                title: Text('Tiled'),
                child: Text('Each fold is its own tile.'),
              ),
              PlAccordionItem<String>(
                value: 'two',
                title: Text('Second'),
                child: Text('Told apart by space instead.'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
