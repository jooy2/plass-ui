import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ModalControlled extends StatefulWidget {
  const ModalControlled({super.key});

  @override
  State<ModalControlled> createState() => _ModalControlledState();
}

class _ModalControlledState extends State<ModalControlled> {
  bool _open = false;
  bool _published = false;

  @override
  Widget build(BuildContext context) {
    // A preview is as tall as its content, and a sheet takes away whatever it is
    // inside. This is the page for it to take.
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              PlButton(onPressed: () => setState(() => _open = true), child: const Text('Publish')),
              if (_published)
                const PlTypography(
                  'Published',
                  level: PlTypographyLevel.caption,
                  color: PlassColor.success,
                  weight: PlTypographyWeight.semibold,
                ),
            ],
          ),
          PlModal(
            open: _open,
            size: PlassSize.sm,
            onOpenChanged: (bool next) => setState(() => _open = next),
            title: const Text('Publish this version?'),
            description: const Text('Everyone on the team will see it.'),
            actions: <Widget>[
              PlButton(
                variant: PlassVariant.ghost,
                color: PlassColor.secondary,
                onPressed: () => setState(() => _open = false),
                child: const Text('Not yet'),
              ),
              PlButton(
                onPressed: () => setState(() {
                  _published = true;
                  _open = false;
                }),
                child: const Text('Publish'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
