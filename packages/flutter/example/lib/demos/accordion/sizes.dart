import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AccordionSizes extends StatelessWidget {
  const AccordionSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final size in <PlassSize>[PlassSize.sm, PlassSize.md, PlassSize.lg])
            PlAccordion<String>(
              size: size,
              value: const <String>{'one'},
              onChanged: (Set<String> next) {},
              items: <PlAccordionItem<String>>[
                PlAccordionItem<String>(
                  value: 'one',
                  title: Text('size: ${size.name}'),
                  subtitle: const Text('Title, subtitle, body'),
                  child: const Text(
                    'The three ladders move together: the title, the body under it and the '
                    'padding around both.',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
