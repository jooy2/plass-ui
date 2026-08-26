import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AccordionMultiple extends StatefulWidget {
  const AccordionMultiple({super.key});

  @override
  State<AccordionMultiple> createState() => _AccordionMultipleState();
}

class _AccordionMultipleState extends State<AccordionMultiple> {
  Set<String> _open = <String>{'cpu', 'memory'};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: PlAccordion<String>(
        multiple: true,
        value: _open,
        onChanged: (Set<String> next) => setState(() => _open = next),
        items: const <PlAccordionItem<String>>[
          PlAccordionItem<String>(
            value: 'cpu',
            title: Text('CPU'),
            child: Text('8 cores, 3.4 GHz.'),
          ),
          PlAccordionItem<String>(
            value: 'memory',
            title: Text('Memory'),
            child: Text('32 GB, 6000 MT/s.'),
          ),
          PlAccordionItem<String>(
            value: 'storage',
            title: Text('Storage'),
            child: Text('1 TB NVMe.'),
          ),
        ],
      ),
    );
  }
}
