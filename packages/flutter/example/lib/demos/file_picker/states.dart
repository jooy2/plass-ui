import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class FilePickerStates extends StatelessWidget {
  const FilePickerStates({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: <Widget>[
          SizedBox(
            width: 220,
            child: PlFilePicker(
              size: PlassSize.sm,
              label: const Text('Disabled'),
              disabled: true,
              value: const <PlFile>[],
              onBrowse: () async => const <PlFile>[],
              onFilesChanged: (List<PlFile> next) {},
            ),
          ),
          SizedBox(
            width: 220,
            child: PlFilePicker(
              size: PlassSize.sm,
              label: const Text('Invalid'),
              error: const Text('A signed contract is required.'),
              value: const <PlFile>[],
              onBrowse: () async => const <PlFile>[],
              onFilesChanged: (List<PlFile> next) {},
            ),
          ),
        ],
      ),
    );
  }
}
