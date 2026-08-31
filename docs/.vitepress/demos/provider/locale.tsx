import { PlDatePicker, PlassProvider } from 'plass-ui';

export default function ProviderLocale() {
  return (
    <PlassProvider
      locale="ko-KR"
      weekStartsOn={1}
      labels={{ today: '오늘', clear: '지우기', chooseMonth: '월 선택', chooseYear: '연 선택' }}
    >
      <PlDatePicker label="출발일" placeholder="날짜를 고르세요" clearable />
    </PlassProvider>
  );
}
