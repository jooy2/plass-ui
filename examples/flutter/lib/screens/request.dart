import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:plass_showcase/app/page.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlSelectOption<String>> _teams = <PlSelectOption<String>>[
  PlSelectOption<String>(value: 'design', label: Text('Design')),
  PlSelectOption<String>(value: 'engineering', label: Text('Engineering')),
  PlSelectOption<String>(value: 'finance', label: Text('Finance')),
  PlSelectOption<String>(value: 'support', label: Text('Support')),
];

const List<PlComboboxOption<String>> _cities = <PlComboboxOption<String>>[
  PlComboboxOption<String>(value: 'seoul', label: 'Seoul'),
  PlComboboxOption<String>(value: 'lisbon', label: 'Lisbon'),
  PlComboboxOption<String>(value: 'quito', label: 'Quito'),
  PlComboboxOption<String>(value: 'reykjavik', label: 'Reykjavík'),
  PlComboboxOption<String>(value: 'nairobi', label: 'Nairobi'),
];

/// A long form with every kind of field, three steps deep.
class RequestScreen extends StatefulWidget {
  /// Creates the screen.
  const RequestScreen({required this.bottomInset, super.key});

  /// Room held under the content for the bottom bar.
  final double bottomInset;

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final TextEditingController _code = TextEditingController();

  int _step = 0;
  String? _team;
  String? _city;
  DateTime? _date;
  DateTime? _time;
  double? _nights = 2;
  double _budget = 600;
  double _priority = 3;
  String _travel = 'train';
  bool _insurance = true;
  bool _terms = false;
  String? _label = '#3F63F2';

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    _code.dispose();
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty) {
      setState(() => _step = 0);
      PlToastProvider.of(context).show(
        const PlToast(
          color: PlassColor.danger,
          title: Text('Enter your name'),
          description: Text('The first step needs it.'),
        ),
      );

      return;
    }

    PlToastProvider.of(context).show(
      PlToast(
        color: PlassColor.success,
        title: Text('Request sent for ${_name.text.trim()}'),
        description: const Text('You will hear back within a day.'),
      ),
    );
    setState(() => _step = 0);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScroll(
      title: 'Request',
      subtitle: 'Book a work trip',
      bottomInset: widget.bottomInset,
      children: <Widget>[
        PlStepper(
          active: _step,
          onActiveChanged: (int next) => setState(() => _step = next),
          steps: <PlStep>[
            PlStep(
              label: const Text('You'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: <Widget>[
                  PlTextField(
                    fullWidth: true,
                    controller: _name,
                    label: const Text('Your name'),
                    placeholder: 'Ada Lovelace',
                    textInputAction: TextInputAction.next,
                  ),
                  PlSelect<String>(
                    fullWidth: true,
                    label: const Text('Team'),
                    placeholder: const Text('Pick a team'),
                    options: _teams,
                    value: _team,
                    onChanged: (String? next) => setState(() => _team = next),
                  ),
                  PlTextField(
                    fullWidth: true,
                    controller: _notes,
                    label: const Text('Why this trip'),
                    placeholder: 'A sentence or two',
                    multiline: true,
                  ),
                ],
              ),
            ),
            PlStep(
              label: const Text('Trip'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: <Widget>[
                  PlCombobox<String>(
                    fullWidth: true,
                    label: const Text('Destination'),
                    placeholder: 'Search cities',
                    options: _cities,
                    value: _city,
                    onChanged: (String? next) => setState(() => _city = next),
                  ),
                  PlDatePicker(
                    fullWidth: true,
                    label: const Text('Departure'),
                    placeholder: const Text('Pick a day'),
                    value: _date,
                    onChanged: (DateTime? next) => setState(() => _date = next),
                  ),
                  PlTimePicker(
                    label: const Text('Leaving at'),
                    placeholder: const Text('Pick a time'),
                    minuteStep: 15,
                    value: _time,
                    onChanged: (DateTime? next) => setState(() => _time = next),
                  ),
                  PlNumberField(
                    fullWidth: true,
                    label: const Text('Nights'),
                    min: 1,
                    max: 14,
                    value: _nights,
                    onChanged: (double? next) => setState(() => _nights = next),
                  ),
                  PlSlider(
                    label: const Text('Budget'),
                    values: <double>[_budget],
                    min: 100,
                    max: 2000,
                    step: 50,
                    showValue: true,
                    formatValue: (List<double> values) => '£${values.first.round()}',
                    onChanged: (List<double> next) => setState(() => _budget = next.first),
                  ),
                  PlRadioGroup<String>(
                    label: const Text('Travel by'),
                    value: _travel,
                    onChanged: (String next) => setState(() => _travel = next),
                    options: const <PlRadioOption<String>>[
                      PlRadioOption<String>(value: 'train', label: Text('Train')),
                      PlRadioOption<String>(value: 'plane', label: Text('Plane')),
                      PlRadioOption<String>(value: 'car', label: Text('Car')),
                    ],
                  ),
                ],
              ),
            ),
            PlStep(
              label: const Text('Confirm'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: <Widget>[
                  PlOtpField(
                    controller: _code,
                    groupSize: 3,
                    label: const Text('Code from your manager'),
                  ),
                  PlRating(
                    value: _priority,
                    onChanged: (double next) => setState(() => _priority = next),
                  ),
                  PlColorPicker(
                    label: const Text('Calendar colour'),
                    value: _label,
                    onValueChanged: (String next) => setState(() => _label = next),
                  ),
                  PlSwitch(
                    value: _insurance,
                    onChanged: (bool next) => setState(() => _insurance = next),
                    label: const Text('Add travel insurance'),
                  ),
                  PlCheckbox(
                    value: _terms,
                    onChanged: (bool next) => setState(() => _terms = next),
                    label: const Text('I have read the travel policy'),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            PlButton(
              variant: PlassVariant.ghost,
              color: PlassColor.secondary,
              onPressed: _step == 0 ? null : () => setState(() => _step -= 1),
              child: const Text('Back'),
            ),
            PlButton(
              onPressed: _step == 2 ? _submit : () => setState(() => _step += 1),
              child: Text(_step == 2 ? 'Send request' : 'Next'),
            ),
          ],
        ),
      ],
    );
  }
}
