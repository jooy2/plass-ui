import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui_example/demos/file_picker/fake.dart';

class FilePickerBatch extends StatefulWidget {
  const FilePickerBatch({super.key});

  @override
  State<FilePickerBatch> createState() => _FilePickerBatchState();
}

class _FilePickerBatchState extends State<FilePickerBatch> {
  List<PlFile> _files = const <PlFile>[];
  String? _message;
  int _picks = 0;

  /// The first pick finds a PDF on its own, and every pick after it an image
  /// with the PDF.
  Future<List<PlFile>> _browse() async {
    _picks += 1;

    final found = await pickFakeFiles(count: 2);

    return _picks == 1 ? found.sublist(1) : found;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: PlFilePicker(
        label: const Text('Cover image'),
        hint: const Text('One image. Choose it with anything else and only the image is kept.'),
        accept: 'image/*',
        error: _message == null ? null : Text(_message!),
        value: _files,
        onBrowse: _browse,
        onFilesChanged: (List<PlFile> next) => setState(() => _files = next),
        // An error only when nothing in the pick could be used.
        onAdded: (PlFileBatch batch) => setState(() {
          _message = batch.kept.isEmpty && batch.rejected.isNotEmpty
              ? 'None of those is an image.'
              : null;
        }),
      ),
    );
  }
}
