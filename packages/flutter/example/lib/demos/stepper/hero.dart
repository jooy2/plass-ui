import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class StepperHero extends StatefulWidget {
  const StepperHero({super.key});

  @override
  State<StepperHero> createState() => _StepperHeroState();
}

class _StepperHeroState extends State<StepperHero> {
  int _active = 1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PlStepper(
            active: _active,
            onActiveChanged: (int next) => setState(() => _active = next),
            steps: const <PlStep>[
              PlStep(
                label: Text('Account'),
                description: Text('Email and password'),
                child: Text('Where we send the receipt.'),
              ),
              PlStep(
                label: Text('Verify'),
                description: Text('Six digits'),
                child: Text('The code expires in ten minutes.'),
              ),
              PlStep(
                label: Text('Profile'),
                optional: Text('Optional'),
                child: Text('You can do this later.'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              PlButton(
                variant: PlassVariant.ghost,
                color: PlassColor.secondary,
                onPressed: _active == 0 ? null : () => setState(() => _active -= 1),
                child: const Text('Back'),
              ),
              PlButton(
                onPressed: _active == 2 ? null : () => setState(() => _active += 1),
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
