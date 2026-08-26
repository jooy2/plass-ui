import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CardDividers extends StatelessWidget {
  const CardDividers({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        SizedBox(
          width: 248,
          child: PlCard(
            size: PlassSize.sm,
            title: const Text('Spaced'),
            footer: PlButton(size: PlassSize.xs, onPressed: () {}, child: const Text('Save')),
            child: const Text('The sections are told apart by a gap.'),
          ),
        ),
        SizedBox(
          width: 248,
          child: PlCard(
            size: PlassSize.sm,
            dividers: true,
            title: const Text('Scored'),
            footer: PlButton(size: PlassSize.xs, onPressed: () {}, child: const Text('Save')),
            child: const Text('The rules run the full width of the sheet.'),
          ),
        ),
      ],
    );
  }
}
