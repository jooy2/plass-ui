import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlTransferItem> _permissions = <PlTransferItem>[
  PlTransferItem(value: 'read', label: 'Read'),
  PlTransferItem(value: 'write', label: 'Write'),
  PlTransferItem(value: 'admin', label: 'Administer', disabled: true),
  PlTransferItem(value: 'billing', label: 'Billing'),
];

class TransferStates extends StatelessWidget {
  const TransferStates({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 560,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          PlTransfer(
            size: PlassSize.sm,
            items: _permissions,
            defaultValue: <String>['read'],
            height: 130,
          ),
          PlTransfer(
            size: PlassSize.sm,
            items: _permissions,
            defaultValue: <String>['read'],
            height: 130,
            disabled: true,
          ),
        ],
      ),
    );
  }
}
