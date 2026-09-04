import 'package:flutter/widgets.dart';
import 'package:plass_ui/locales.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlTransferItem> columns = <PlTransferItem>[
  PlTransferItem(value: 'name', label: '이름'),
  PlTransferItem(value: 'email', label: '이메일'),
  PlTransferItem(value: 'role', label: '역할'),
  PlTransferItem(value: 'team', label: '팀'),
  PlTransferItem(value: 'joined', label: '합류일'),
];

class ProviderLabels extends StatefulWidget {
  const ProviderLabels({super.key});

  @override
  State<ProviderLabels> createState() => _ProviderLabelsState();
}

class _ProviderLabelsState extends State<ProviderLabels> {
  List<String> _value = <String>['name'];

  @override
  Widget build(BuildContext context) {
    // Nothing here names a word. Both column headings, the tick-everything
    // link, the two move buttons and the empty line all come from the pack.
    return PlassTheme.merge(
      defaults: const PlassDefaults(labels: ko),
      child: PlTransfer(
        items: columns,
        value: _value,
        onValueChanged: (List<String> next) => setState(() => _value = next),
      ),
    );
  }
}
