import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AccordionVariants extends StatelessWidget {
  const AccordionVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: <Widget>[
        for (final variant in PlassVariant.values)
          SizedBox(
            width: 220,
            child: PlAccordion<String>(
              variant: variant,
              size: PlassSize.sm,
              value: const <String>{'one'},
              onChanged: (Set<String> next) {},
              items: <PlAccordionItem<String>>[
                PlAccordionItem<String>(
                  value: 'one',
                  title: Text(variant.name),
                  child: Text('The sheet is ${variant.name}.'),
                ),
                const PlAccordionItem<String>(
                  value: 'two',
                  title: Text('Second'),
                  child: Text('And a second fold under it.'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
