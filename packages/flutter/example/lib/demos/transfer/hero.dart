import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlTransferItem> _columns = <PlTransferItem>[
  PlTransferItem(value: 'name', label: 'Name'),
  PlTransferItem(value: 'email', label: 'Email'),
  PlTransferItem(value: 'role', label: 'Role'),
  PlTransferItem(value: 'team', label: 'Team'),
  PlTransferItem(value: 'joined', label: 'Joined'),
  PlTransferItem(value: 'status', label: 'Status'),
  PlTransferItem(value: 'id', label: 'Identifier', disabled: true),
];

class TransferHero extends StatefulWidget {
  const TransferHero({super.key});

  @override
  State<TransferHero> createState() => _TransferHeroState();
}

class _TransferHeroState extends State<TransferHero> {
  List<String> _value = <String>['name', 'email'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: PlTransfer(
        items: _columns,
        value: _value,
        onValueChanged: (List<String> next) => setState(() => _value = next),
        sourceLabel: 'Available columns',
        targetLabel: 'In the report',
      ),
    );
  }
}
