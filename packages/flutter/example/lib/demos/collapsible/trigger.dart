import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class CollapsibleTrigger extends StatefulWidget {
  const CollapsibleTrigger({super.key});

  @override
  State<CollapsibleTrigger> createState() => _CollapsibleTriggerState();
}

class _CollapsibleTriggerState extends State<CollapsibleTrigger> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: PlCollapsible(
        variant: PlassVariant.ghost,
        open: _open,
        onOpenChanged: (bool next) => setState(() => _open = next),
        triggerBuilder: (BuildContext context, bool open, VoidCallback toggle) => Align(
          alignment: AlignmentDirectional.centerStart,
          child: PlButton(
            variant: PlassVariant.ghost,
            onPressed: toggle,
            child: Text(open ? 'Hide the details' : 'Show the details'),
          ),
        ),
        child: const Text(
          'A builder rather than a widget: a Dart widget cannot be handed a tap handler '
          'after it was made, so the builder is given the state and the callback instead.',
        ),
      ),
    );
  }
}
