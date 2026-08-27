import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// What a `locale` string is in the React build.
///
/// The framework ships no `Intl`, so the words arrive as an object — English by
/// default, and three lines of `DateFormat` for an app that already depends on
/// `package:intl`.
const PlDateNames _korean = PlDateNames(
  months: <String>['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
  monthsShort: <String>['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
  weekdays: <String>['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'],
  weekdaysShort: <String>['일', '월', '화', '수', '목', '금', '토'],
  monthBeforeYear: false,
);

const PlPickerLabels _koreanLabels = PlPickerLabels(
  previousMonth: '이전 달',
  nextMonth: '다음 달',
  chooseMonth: '월 선택',
  chooseYear: '연도 선택',
  today: '오늘',
  clear: '지우기',
);

class DatePickerLocales extends StatefulWidget {
  const DatePickerLocales({super.key});

  @override
  State<DatePickerLocales> createState() => _DatePickerLocalesState();
}

class _DatePickerLocalesState extends State<DatePickerLocales> {
  DateTime _inEnglish = DateTime(2026, 7, 27);
  DateTime _inKorean = DateTime(2026, 7, 27);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: <Widget>[
          PlDatePicker(
            fullWidth: true,
            label: const Text('English'),
            value: _inEnglish,
            onChanged: (DateTime? next) => setState(() => _inEnglish = next ?? _inEnglish),
          ),
          PlDatePicker(
            fullWidth: true,
            label: const Text('한국어'),
            names: _korean,
            labels: _koreanLabels,
            formatValue: (DateTime date) => '${date.year}. ${date.month}. ${date.day}.',
            value: _inKorean,
            onChanged: (DateTime? next) => setState(() => _inKorean = next ?? _inKorean),
          ),
        ],
      ),
    );
  }
}
