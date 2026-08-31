import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ProviderLocale extends StatefulWidget {
  const ProviderLocale({super.key});

  @override
  State<ProviderLocale> createState() => _ProviderLocaleState();
}

class _ProviderLocaleState extends State<ProviderLocale> {
  DateTime? _value;

  @override
  Widget build(BuildContext context) {
    // One place names the words, and every date widget under it answers.
    return PlassTheme.merge(
      defaults: const PlassDefaults(
        names: PlDateNames(
          months: <String>[
            '1월',
            '2월',
            '3월',
            '4월',
            '5월',
            '6월',
            '7월',
            '8월',
            '9월',
            '10월',
            '11월',
            '12월',
          ],
          weekdaysShort: <String>['일', '월', '화', '수', '목', '금', '토'],
        ),
        labels: PlPickerLabels(today: '오늘', clear: '지우기'),
        weekStartsOn: PlassWeekday.monday,
      ),
      child: SizedBox(
        width: 300,
        child: PlDatePicker(
          fullWidth: true,
          label: const Text('출발일'),
          placeholder: const Text('날짜를 고르세요'),
          clearable: true,
          value: _value,
          onChanged: (DateTime? next) => setState(() => _value = next),
        ),
      ),
    );
  }
}
