import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class PopoverForm extends StatefulWidget {
  const PopoverForm({super.key});

  @override
  State<PopoverForm> createState() => _PopoverFormState();
}

class _PopoverFormState extends State<PopoverForm> {
  final TextEditingController _name = TextEditingController(text: 'Untitled view');
  bool _open = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlPopover(
      open: _open,
      onOpenChanged: (bool next) => setState(() => _open = next),
      showClose: true,
      width: 320,
      title: const Text('Rename this view'),
      description: const Text('Everyone on the team sees it'),
      trigger: PlButton(onPressed: () => setState(() => _open = true), child: const Text('Rename')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          PlTextField(label: const Text('Name'), controller: _name),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: <Widget>[
              PlButton(
                variant: PlassVariant.ghost,
                onPressed: () => setState(() => _open = false),
                child: const Text('Cancel'),
              ),
              PlButton(onPressed: () => setState(() => _open = false), child: const Text('Save')),
            ],
          ),
        ],
      ),
    );
  }
}
