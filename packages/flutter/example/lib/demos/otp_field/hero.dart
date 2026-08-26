import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class OtpFieldHero extends StatefulWidget {
  const OtpFieldHero({super.key});

  @override
  State<OtpFieldHero> createState() => _OtpFieldHeroState();
}

class _OtpFieldHeroState extends State<OtpFieldHero> {
  final TextEditingController _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlOtpField(
      controller: _code,
      groupSize: 3,
      label: const Text('Verification code'),
      description: Text(_code.text.length == 6 ? 'Checking…' : 'We texted it to you.'),
      onChanged: (String _) => setState(() {}),
    );
  }
}
