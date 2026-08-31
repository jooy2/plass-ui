---
title: PlCalendar
order: 21
---

# PlCalendar

<p class="plass-lede">popup 안이 아니라 페이지 위의 한 달입니다. <code>PlDatePicker</code>가 여는 바로 그 grid에서 trigger와 popup을 걷어낸 것입니다.</p>

<Demo src="calendar/hero" :min-height="400" />

::: fw react

```tsx
import { PlCalendar } from 'plass-ui';

<PlCalendar value={day} onValueChange={setDay} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlCalendar(
  value: day,
  onChanged: (DateTime? next) => setState(() => day = next),
);
```

:::

## Props

<PropsTable name="PlCalendar" />

::: fw react

네이티브 `<div>` 속성은 그대로 통과합니다. `label`도 `description`도 `error`도 없습니다 — 이것은 field가 아니라서 둘러싼 텍스트가 없습니다. 설명이 필요하면 [`PlFieldset`](./fieldset) 안에 넣으세요.

:::

::: fw flutter

`label`도 `description`도 `error`도 없습니다 — 이것은 field가 아니라서 둘러싼 텍스트가 없습니다. 설명이 필요하면 [`PlFieldset`](./fieldset) 안에 넣으세요.

React 빌드와 다른 점 둘은, 이 패키지의 모든 날짜 컴포넌트가 갖는 그 둘입니다. `names`와 `labels`가 `locale` 문자열 대신 말 자체를 받습니다 — 프레임워크에 `Intl`이 없기 때문입니다. 기본은 영어이고, 이미 `package:intl`을 쓰는 앱은 세 줄로 `PlDateNames`를 만듭니다. 그리고 **`name`이 없습니다.** Dart의 폼은 HTML의 폼이 아니므로 제출할 hidden input도 없고, 값을 보내는 것은 호출자의 몫입니다.

:::

`density`는 없습니다. 정사각형 마흔두 개짜리 grid에 padding을 더하는 것은 그것들이 정사각형이기를 그만두게 하는 일입니다. 대신 `size`가 사다리 전체를 함께 움직입니다. 공유 축이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## PlDatePicker 대신 이것을 쓸 때

[`PlDatePicker`](./date-picker)는 calendar를 여는 **field**입니다. 폼 안에서 다른 field 옆에 놓이고, 열기 전까지 그 답은 텍스트 한 줄입니다. 이 컴포넌트는 field를 대신하고 있지 않은 calendar입니다 — 예약 페이지, 예약 가능 현황, 대시보드의 날짜 레일. grid가 폼을 채우는 방법이 아니라 인터페이스 그 자체입니다.

답이 다른 input들 옆 폼 안에 놓인다면 picker를 쓰세요.

## Examples

### precision

시작 화면이 아니라 **바닥**입니다. `month`에서는 월 grid가 마지막 grid이고 거기서 셀을 누르면 그것이 답입니다. 그 아래에 일 grid가 아예 없습니다 — 카드 만료일은 월이고, *2027년 12월의 며칠이냐*를 답하게 만드는 컨트롤은 잘못 답하게 될 컨트롤입니다.

값은 고른 것의 시작으로 정규화됩니다. 그달의 1일, 1월 1일이지, 커서가 마침 얹혀 있던 날이 아닙니다.

<Demo src="calendar/precision" :min-height="360">

::: fw react

<<< @/.vitepress/demos/calendar/precision.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/calendar/precision.dart

:::

</Demo>

### minDate, maxDate, shouldDisableDate

두 경계는 calendar 자신의 `precision`으로 읽습니다. 그래서 `month` calendar에서 7월 15일의 `minDate`는 7월을 고를 수 있게 남겨 둡니다. `shouldDisableDate`는 일 단위이며 나머지 둘에서는 아예 참조되지 않습니다.

<Demo src="calendar/bounds" :min-height="400">

::: fw react

<<< @/.vitepress/demos/calendar/bounds.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/calendar/bounds.dart

:::

</Demo>

### variant

기본은 `glass`이고, `PlCard`가 가진 시트와 elevation을 씁니다. 이미 시트를 그리는 것 안에 calendar가 들어간다면 `ghost`를 쓰세요 — 사각형 안의 두 번째 테두리 사각형은 두 번째 사각형입니다.

<Demo src="calendar/variants" :min-height="400">

::: fw react

<<< @/.vitepress/demos/calendar/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/calendar/variants.dart

:::

</Demo>

### 화면의 달을 제어하기

`month`와 `onMonthChange`는 무엇이 선택됐는지와 무관하게 화면에 보이는 달을 제어합니다. calendar 두 개를 한 달 간격으로 유지할 때 필요한 것입니다.

```tsx
const [month, setMonth] = useState(startOfMonth(new Date()));

<PlCalendar month={month} onMonthChange={setMonth} value={day} onValueChange={setDay} />;
```

제어하지 않으면 달은 값을 따라갑니다. 뒤 주의 날을 고르면 grid가 그 날의 달로 옮겨 갑니다 — 화면에 없는 달에서의 선택은 아무도 볼 수 없는 선택이기 때문입니다.

### 폼 안에서

::: fw react

`name`은 hidden input을 답니다. 표기는 `precision`을 따릅니다 — `YYYY-MM-DD`, 그다음 `YYYY-MM`과 `YYYY`. 같은 모양의 네이티브 input이 제출하는 형식입니다.

```tsx
<form action={book}>
  <PlCalendar name="departure" />
</form>
```

:::

::: fw flutter

더할 것이 없습니다. Dart의 폼은 HTML의 폼이 아니므로 hidden input도, 거기 줄 이름도 없습니다 — 값은 `onChanged`로 오고, 그것을 보내는 것은 호출자의 몫입니다.

:::

### disabled

calendar를 흐리게 하고 `inert` 속성으로 손이 닿지 않게 합니다 — 셀 마흔두 개에 `disabled`를 다는 대신 속성 하나입니다.

옆에 `readOnly`가 없고, 빠뜨린 것이 아닙니다. read-only field는 여전히 사용자가 선택하고 복사할 값을 보여 주지만, calendar에는 복사할 것이 없습니다. 전부가 아니라 일부 날짜만 막으려면 `shouldDisableDate`를 쓰세요.

## Accessibility

- 진짜 `role="grid"`이며 roving tab stop **하나**입니다. 그래서 <kbd>Tab</kbd>은 셀 마흔두 개를 걷는 대신 calendar를 빠져나갑니다. ARIA date-picker practice가 기술하는 패턴이고, 어떤 셀도 `disabled` 버튼이 아닌 이유입니다 — 막힌 날은 `aria-disabled`이고 여전히 닿을 수 있어서, 키보드 사용자가 그것이 막혔다는 사실을 알 수 있습니다.
- 화살표 키는 셀 하나씩, <kbd>PageUp</kbd>/<kbd>PageDown</kbd>은 한 달씩(<kbd>Shift</kbd>와 함께면 한 해씩), <kbd>Home</kbd>/<kbd>End</kbd>는 주의 양끝으로 움직입니다. 가장자리를 넘어가면 멈추는 대신 calendar가 한 칸 넘어갑니다.
- 각 셀의 accessible name은 calendar의 `locale`로 쓴 전체 날짜입니다. 그래서 스크린 리더가 "27"이 아니라 "2026년 7월 27일 월요일"을 읽습니다.
- `autoFocus`는 picker와 반대로 기본이 **꺼짐**입니다. popup은 그 안으로 들어가려는 사람이 방금 연 것이고, 페이지 안의 calendar는 그렇지 않습니다.
