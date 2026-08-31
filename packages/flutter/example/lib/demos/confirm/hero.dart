import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ConfirmHero extends StatefulWidget {
  const ConfirmHero({super.key});

  @override
  State<ConfirmHero> createState() => _ConfirmHeroState();
}

class _ConfirmHeroState extends State<ConfirmHero> {
  String? _result;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return PlConfirmProvider(
      child: Builder(
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              PlButton(
                color: PlassColor.danger,
                onPressed: () async {
                  final ok = await PlConfirmProvider.of(context).confirm(
                    const PlConfirmOptions(
                      title: Text('Delete this project?'),
                      description: Text('Ten members lose access, and it cannot be undone.'),
                      confirmLabel: Text('Delete'),
                      color: PlassColor.danger,
                    ),
                  );

                  setState(() => _result = ok ? 'Deleted.' : 'Kept.');
                },
                child: const Text('Delete project'),
              ),
              const SizedBox(height: 12),
              Text(
                _result ?? 'Nothing has happened yet.',
                style: TextStyle(color: tokens.mutedFg, fontSize: 13),
              ),
            ],
          );
        },
      ),
    );
  }
}
