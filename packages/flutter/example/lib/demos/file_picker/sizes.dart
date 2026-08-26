import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlassSize> _steps = <PlassSize>[PlassSize.sm, PlassSize.md, PlassSize.lg];

class FilePickerSizes extends StatelessWidget {
  const FilePickerSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final size in _steps)
            PlFilePicker(
              size: size,
              title: Text('size: ${size.name}'),
              value: const <PlFile>[],
              onBrowse: () async => const <PlFile>[],
              onFilesChanged: (List<PlFile> next) {},
            ),
        ],
      ),
    );
  }
}
