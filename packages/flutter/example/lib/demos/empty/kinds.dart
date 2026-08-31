import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class EmptyKinds extends StatelessWidget {
  const EmptyKinds({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 620,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Expanded(
            child: PlCard(
              child: PlEmpty(
                size: PlassSize.sm,
                icon: Text('🔍'),
                title: Text('No results'),
                description: Text('Try fewer words.'),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PlCard(
              child: PlEmpty(
                size: PlassSize.sm,
                color: PlassColor.danger,
                icon: const Text('⚠️'),
                title: const Text('Could not load'),
                description: const Text('The server did not answer.'),
                actions: <Widget>[
                  PlButton(
                    size: PlassSize.sm,
                    color: PlassColor.danger,
                    variant: PlassVariant.glass,
                    onPressed: () {},
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: PlCard(
              child: PlEmpty(
                size: PlassSize.sm,
                color: PlassColor.success,
                icon: Text('✅'),
                title: Text('All done'),
                description: Text('Your order is on its way.'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
