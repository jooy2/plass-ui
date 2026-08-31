import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class PopconfirmAsync extends StatefulWidget {
  const PopconfirmAsync({super.key});

  @override
  State<PopconfirmAsync> createState() => _PopconfirmAsyncState();
}

class _PopconfirmAsyncState extends State<PopconfirmAsync> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return PlPopconfirm(
      open: _open,
      onOpenChanged: (bool next) => setState(() => _open = next),
      title: const Text('Revoke this key?'),
      description: const Text('Anything using it stops working.'),
      confirmLabel: const Text('Revoke'),
      onConfirm: () => Future<void>.delayed(const Duration(milliseconds: 1200)),
      trigger: PlButton(
        color: PlassColor.danger,
        onPressed: () => setState(() => _open = true),
        child: const Text('Revoke key'),
      ),
    );
  }
}
