import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<String> _sections = <String>['account', 'billing', 'team'];

class AccordionControlled extends StatefulWidget {
  const AccordionControlled({super.key});

  @override
  State<AccordionControlled> createState() => _AccordionControlledState();
}

class _AccordionControlledState extends State<AccordionControlled> {
  Set<String> _open = <String>{'account'};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          Wrap(
            spacing: 8,
            children: <Widget>[
              PlButton(
                size: PlassSize.xs,
                variant: PlassVariant.glass,
                onPressed: () => setState(() => _open = _sections.toSet()),
                child: const Text('Open all'),
              ),
              PlButton(
                size: PlassSize.xs,
                variant: PlassVariant.glass,
                onPressed: () => setState(() => _open = <String>{}),
                child: const Text('Close all'),
              ),
            ],
          ),
          PlAccordion<String>(
            multiple: true,
            value: _open,
            onChanged: (Set<String> next) => setState(() => _open = next),
            items: const <PlAccordionItem<String>>[
              PlAccordionItem<String>(
                value: 'account',
                title: Text('Account'),
                child: Text('Your name, your avatar, your language.'),
              ),
              PlAccordionItem<String>(
                value: 'billing',
                title: Text('Billing'),
                child: Text('Cards, invoices and the plan you are on.'),
              ),
              PlAccordionItem<String>(
                value: 'team',
                title: Text('Team'),
                child: Text('Who else is here and what they can do.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
