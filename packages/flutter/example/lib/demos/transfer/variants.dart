import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlTransferItem> _items = <PlTransferItem>[
  PlTransferItem(value: 'a', label: 'Alpha'),
  PlTransferItem(value: 'b', label: 'Beta'),
  PlTransferItem(value: 'c', label: 'Gamma'),
];

class TransferVariants extends StatelessWidget {
  const TransferVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          for (final PlassVariant variant in PlassVariant.values)
            PlTransfer(
              variant: variant,
              size: PlassSize.sm,
              items: _items,
              defaultValue: const <String>['b'],
              sourceLabel: variant.name,
              targetLabel: 'Chosen',
              height: 110,
            ),
        ],
      ),
    );
  }
}
