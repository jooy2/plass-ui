import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DataListOrientation extends StatelessWidget {
  const DataListOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 300,
      child: PlDataList(
        orientation: PlassOrientation.vertical,
        children: <Widget>[
          PlDataListItem(
            label: Text('Endpoint'),
            value: Text('https://api.example.com/v2/projects/9f21/events'),
          ),
          PlDataListItem(label: Text('Region'), value: Text('eu-west-1')),
        ],
      ),
    );
  }
}
