import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateShakeHero extends StatefulWidget {
  const AnimateShakeHero({super.key});

  @override
  State<AnimateShakeHero> createState() => _AnimateShakeHeroState();
}

class _AnimateShakeHeroState extends State<AnimateShakeHero> {
  int _attempts = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          PlAnimateShake(
            replay: _attempts,
            child: PlTextField(
              label: const Text('Password'),
              error: _attempts == 0 ? null : const Text('That password is wrong.'),
              invalid: _attempts > 0,
              obscureText: true,
            ),
          ),
          PlButton(onPressed: () => setState(() => _attempts += 1), child: const Text('Sign in')),
        ],
      ),
    );
  }
}
