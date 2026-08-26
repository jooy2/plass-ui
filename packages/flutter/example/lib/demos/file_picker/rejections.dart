import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui_example/demos/file_picker/fake.dart';

const Map<PlFileRejectionReason, String> _reasons = <PlFileRejectionReason, String>{
  PlFileRejectionReason.type: 'that is not an image',
  PlFileRejectionReason.size: 'that file is over 200 kB',
  PlFileRejectionReason.count: 'two is the limit',
};

class FilePickerRejections extends StatefulWidget {
  const FilePickerRejections({super.key});

  @override
  State<FilePickerRejections> createState() => _FilePickerRejectionsState();
}

class _FilePickerRejectionsState extends State<FilePickerRejections> {
  List<PlFile> _files = const <PlFile>[];
  String? _message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: PlFilePicker(
        label: const Text('Screenshots'),
        hint: const Text('PNG or JPEG, under 200 kB, two at most'),
        accept: 'image/*',
        multiple: true,
        maxFiles: 2,
        maxSize: 200000,
        error: _message == null ? null : Text(_message!),
        value: _files,
        onBrowse: () => pickFakeFiles(count: 3),
        onFilesChanged: (List<PlFile> next) => setState(() {
          _files = next;
          _message = null;
        }),
        onRejected: (List<PlFileRejection> turned) => setState(() {
          final first = turned.first;

          _message = '${first.file.name}: ${_reasons[first.reason]}.';
        }),
      ),
    );
  }
}
