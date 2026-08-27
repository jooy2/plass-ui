---
title: PlDateTimePicker
order: 15
---

# PlDateTimePicker

<p class="plass-lede">한 팝업 안의 날짜와 시각입니다. 시계가 자란 date picker도, 달력이 자란 time picker도 아닙니다 — 두 패널의 높이가 같은 건 의도된 것입니다.</p>

<Demo src="date-time-picker/hero" :flutter="false" :min-height="200" />

::: fw react

```tsx
import { PlDateTimePicker } from 'plass-ui';

<PlDateTimePicker label="Starts" placeholder="Pick a moment" minDate={new Date()} />;
```

:::

## Props

<PropsTable name="PlDateTimePicker" />

::: fw react

나머지 `<div>` 속성은 field 래퍼로 그대로 통과합니다. `color`는 위 표의 `color`와 겹쳐서, `defaultValue`는 DOM 속성이 아니라 값으로 쓰기 때문에, `children`은 패널들이 곧 컴포넌트이기 때문에 제외했습니다.

:::

달력은 [`PlDatePicker`](./date-picker)의 것이고 열들은 [`PlTimePicker`](./time-picker)의 것이며, 둘 다 그대로입니다. 그 두 페이지가 `locale`과 헤더와 열과 날짜 라이브러리의 부재에 대해 말한 것이 여기서도 성립합니다.

## 패널 둘이 아니라 사각형 하나

달력의 그리드는 헤더까지 세어 일곱 줄입니다. 시계의 열들은 같은 칸 일곱 개입니다. 정확히 그 이유로 둘은 같은 `--p-cell` 사다리를 읽고, 그래서 팝업은 크기가 다른 두 덩어리를 붙여 놓은 것이 아니라 사각형 하나입니다 — 달력을 월 뷰나 연 뷰로 바꿔도 그대로입니다.

## 여기서 경계는 더 많은 일을 합니다

`minDate`와 `maxDate`를 **전체 정밀도로** 읽습니다. [`PlDatePicker`](./date-picker)와 갈라지는 유일한 지점입니다. 거기서 경계는 어떤 날이 존재하는가에 대한 것이고 붙은 시각은 무시됩니다. 여기서는 27일 09:30이라는 최솟값이 달력에서 27일을 그대로 고를 수 있게 두고, 시계에서 오전을 흐리게 만듭니다.

"지금 이전은 안 됨" 규칙이 실제로 필요로 하는 동작이 그것이고, 일 단위 검사로는 낼 수 없습니다 — 오늘 전체를 막거나 오늘 아침을 허용하거나 둘 중 하나가 됩니다.

<Demo src="date-time-picker/precision" :flutter="false" :min-height="200">

<<< @/.vitepress/demos/date-time-picker/precision.tsx

</Demo>

## Examples

### 어느 순서로든

날을 고르면 날짜만 바뀌고 시계는 그대로, 시각을 고르면 시계만 바뀌고 날짜는 그대로입니다. 날짜를 고칠 때마다 시각을 자정으로 되돌리는 picker는 순간을 고르는 일을 순서가 정해진 작업으로 만들고, 팝업을 쓰인 순서대로 읽는 사람은 없습니다.

아직 날을 고르지 않았다면 시계는 오늘 위에 쓰이고, 나중에 날을 고르면 설정된 시각이 유지됩니다.

`closeOnSelect`가 여기서 `false`인 것도 같은 이유입니다 — 순간은 답 둘이라, 푸터에 **Done** 이 있습니다.

### 간격

`hourStep`, `minuteStep`, `secondStep`은 [`PlTimePicker`](./time-picker)의 것 그대로입니다.

<Demo src="date-time-picker/steps" :flutter="false" :min-height="200">

<<< @/.vitepress/demos/date-time-picker/steps.tsx

</Demo>

### locale

태그 하나가 월과 요일 이름, 헤더 두 버튼의 순서, 시계가 12시간 다이얼인지, 오전/오후를 뭐라 부르는지, 그리고 trigger가 순간 전체를 어떻게 쓰는지를 정합니다.

<Demo src="date-time-picker/locales" :flutter="false" :min-height="220">

<<< @/.vitepress/demos/date-time-picker/locales.tsx

</Demo>

### readOnly · disabled · error

<Demo src="date-time-picker/states" :flutter="false" :min-height="240">

<<< @/.vitepress/demos/date-time-picker/states.tsx

</Demo>

## Accessibility

- 달력은 [`PlDatePicker`](./date-picker)의 것 전부입니다 — `role="grid"`, roving tab stop 하나, 접근성 이름은 날짜 전체 — 그리고 열들은 [`PlTimePicker`](./time-picker)의 것이며, 시각을 한 문장으로 읽어 주는 live region까지 포함합니다.
- trigger는 둘이 아니라 **달력 글리프 하나만** 답니다. 컨트롤은 한 번에 두 가지를 말할 수 없고, 독자가 훑는 부분은 날짜입니다.
- 전체 정밀도 경계에 막힌 날과 같은 경계에 막힌 시각 둘 다 속성이 아니라 `aria-disabled`를 답니다. 어느 쪽도 키보드가 걷는 경로에서 빠지지 않습니다.
- `name`이 있으면 hidden input이 값을 로컬 `YYYY-MM-DDTHH:MM`으로 담습니다 — `<input type="datetime-local">`이 제출하는 모양입니다. `toISOString()`은 절대 아닙니다. 서울의 picker라면 다른 날을 제출하게 됩니다.
