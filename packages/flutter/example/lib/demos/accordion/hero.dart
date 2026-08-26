import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AccordionHero extends StatefulWidget {
  const AccordionHero({super.key});

  @override
  State<AccordionHero> createState() => _AccordionHeroState();
}

class _AccordionHeroState extends State<AccordionHero> {
  Set<String> _open = <String>{'shipping'};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: PlAccordion<String>(
        value: _open,
        onChanged: (Set<String> next) => setState(() => _open = next),
        items: const <PlAccordionItem<String>>[
          PlAccordionItem<String>(
            value: 'shipping',
            title: Text('Shipping'),
            subtitle: Text('Where it goes and how fast'),
            child: Text(
              'Standard delivery arrives in three to five working days. Express is next-day '
              'for orders placed before 4pm.',
            ),
          ),
          PlAccordionItem<String>(
            value: 'returns',
            title: Text('Returns'),
            subtitle: Text('Thirty days, no questions'),
            child: Text(
              'Send anything back within thirty days of delivery. Refunds land on the original '
              'payment method within a week of the parcel arriving with us.',
            ),
          ),
          PlAccordionItem<String>(
            value: 'warranty',
            title: Text('Warranty'),
            subtitle: Text('Two years on every part'),
            child: Text('Manufacturing faults are covered for two years. Wear is not.'),
          ),
        ],
      ),
    );
  }
}
