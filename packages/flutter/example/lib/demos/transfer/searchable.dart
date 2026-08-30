import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlTransferItem> _people = <PlTransferItem>[
  PlTransferItem(value: 'ada', label: 'Ada Lovelace'),
  PlTransferItem(value: 'alan', label: 'Alan Turing'),
  PlTransferItem(value: 'grace', label: 'Grace Hopper'),
  PlTransferItem(value: 'katherine', label: 'Katherine Johnson'),
  PlTransferItem(value: 'linus', label: 'Linus Torvalds'),
];

class TransferSearchable extends StatelessWidget {
  const TransferSearchable({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 560,
      child: PlTransfer(
        items: _people,
        searchable: true,
        defaultValue: <String>['grace'],
        sourceLabel: 'Everyone',
        targetLabel: 'On the channel',
        height: 180,
      ),
    );
  }
}
