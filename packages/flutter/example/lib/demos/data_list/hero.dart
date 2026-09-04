import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DataListHero extends StatelessWidget {
  const DataListHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 380,
      child: PlCard(
        child: PlDataList(
          divider: true,
          children: <Widget>[
            PlDataListItem(label: Text('Owner'), value: Text('Ada Lovelace')),
            PlDataListItem(label: Text('Plan'), value: Text('Team')),
            PlDataListItem(
              label: Text('Status'),
              value: PlChip(color: PlassColor.success, child: Text('Active')),
            ),
            PlDataListItem(label: Text('Created'), value: Text('12 March 2026')),
          ],
        ),
      ),
    );
  }
}
