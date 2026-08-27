---
title: PlTimePicker
order: 14
---

# PlTimePicker

<p class="plass-lede">열에서 시각을 고릅니다. 열인 이유는, 시간 picker가 실제로 받는 질문에 답하는 모양이 열이기 때문입니다.</p>

<Demo src="time-picker/hero" :flutter="false" :min-height="200" />

::: fw react

```tsx
import { PlTimePicker } from 'plass-ui';

<PlTimePicker label="Doors" placeholder="Pick a time" minuteStep={15} />;
```

:::

## Props

<PropsTable name="PlTimePicker" />

::: fw react

나머지 `<div>` 속성은 field 래퍼로 그대로 통과합니다. `color`는 위 표의 `color`와 겹쳐서, `defaultValue`는 DOM 속성이 아니라 값으로 쓰기 때문에, `children`은 열들이 곧 컴포넌트이기 때문에 제외했습니다.

:::

[`PlDatePicker`](./date-picker)가 `locale`과 날짜 라이브러리의 부재에 대해 말한 것은 여기서도 성립합니다 — 시계가 12시간 다이얼인지, 오전/오후를 뭐라 부르는지는 `Intl`이 정합니다.

## 다이얼이 아니라 열입니다

"9시 반"은 두 열에 대한 두 번의 눈길입니다. "정각이면 아무 때나"는 아예 건드리지 않는 열입니다. 시계 문자판은 더 예쁘고, 읽으려면 `transform`이 필요하며, 어느 질문에도 더 빨리 답하지 못합니다 — 그리고 이 라이브러리는 컨트롤에 `transform`을 걸지 않습니다.

각 열에서 고른 행은 열릴 때 한 번 화면 안으로 스크롤됩니다. 장식이 아닙니다 — 값이 `45`인데 `00`에서 열리는 60분짜리 열은 자기 답을 숨긴 것입니다.

## 경계는 열 단위로 검사합니다

작동하는 시간 picker와 짜증나는 시간 picker를 가르는 지점입니다. 경계는 한 행이 대표하는 **구간** 에 대고 검사하지, 그 안의 한 순간에 대고 검사하지 않습니다.

`minTime`이 09:30이면 시각 `9`는 09:00:00–09:59:59를 덮고 그것은 허용 범위와 겹치므로 그대로 남습니다. 그리고 `00`부터 `25`가 흐려지는 곳은 분 열입니다. 후보 전체를 비교하면 9가 통째로 사라지고 9시 반은 닿을 수 없게 됩니다.

## 값은 Date입니다

문자열도, 분의 개수도 아닙니다. 이 라이브러리에서 순간을 지니는 다른 모든 것이 `Date`이고, 맨 시각에는 서머타임 경계를 넘었다는 사실을 기록할 자리가 없습니다. `referenceDate`는 맨 시각이 얹히는 날이고, picker가 마운트되어 있는 동안 고정입니다 — 자정을 넘겨 열어 둔 팝업이 값을 조용히 다른 날로 옮기면 안 됩니다.

## Examples

### hour12

말하지 않으면 `locale`에서 가져옵니다. 12시간 다이얼은 `0, 1, 2`가 아니라 `12, 1, 2 … 11`로 읽히고 AM/PM 열이 붙습니다. 24시간 다이얼은 `00`부터 `23`까지이고 그 열이 없습니다.

<Demo src="time-picker/dials" :flutter="false" :min-height="160">

<<< @/.vitepress/demos/time-picker/dials.tsx

</Demo>

### 간격

`hourStep`, `minuteStep`, `secondStep`이 행 간격을 정합니다. 15분 단위로만 받는 예약이라면 09:07을 나중에 거절하는 대신 `minuteStep={15}`로 미리 말해야 합니다.

<Demo src="time-picker/steps" :flutter="false" :min-height="160">

<<< @/.vitepress/demos/time-picker/steps.tsx

</Demo>

### minTime · maxTime · shouldDisableTime

`minTime`과 `maxTime`은 시계만 읽습니다 — 거기 붙은 날짜는 무시됩니다. `shouldDisableTime`은 열마다 행마다, 그 행이 만들어 낼 시각과 그 행이 속한 열을 받아 한 번씩 호출됩니다. 규칙은 "오후는 안 됨"만큼 성길 수도, 1분만큼 촘촘할 수도 있습니다.

<Demo src="time-picker/bounds" :flutter="false" :min-height="160">

<<< @/.vitepress/demos/time-picker/bounds.tsx

</Demo>

### closeOnSelect

여기서는 `false`이고 [`PlDatePicker`](./date-picker)에서는 `true`입니다. 날은 답이 하나이고 시각은 둘입니다. 첫 답에 닫아 버리면 9:30을 고르는 데 팝업을 두 번 열어야 합니다.

열들을 읽는 동안 팝업이 떠 있으므로, _그게 그거다_ 라는 뜻으로 누를 것이 있어야 합니다 — 그래서 푸터에 **Done** 이 있습니다. `closeOnSelect`를 켜면 할 일이 없어지므로 사라집니다.

### readOnly · disabled · error

<Demo src="time-picker/states" :flutter="false" :min-height="160">

<<< @/.vitepress/demos/time-picker/states.tsx

</Demo>

## Accessibility

- 각 열은 자기가 담은 단위의 이름을 단 `role="listbox"`이고, 각 행은 `aria-selected`를 지닌 `option`입니다.
- 막힌 행은 `disabled` 속성이 아니라 `aria-disabled`를 답니다. 그래서 닿을 수 있는 자리에 남고, 사용할 수 없다고 읽힙니다.
- 이름 없는 숫자 목록 셋은 보지 않는 독자에게 아무 말도 하지 않습니다. 그래서 열들 옆의 polite live region이 값이 바뀔 때마다 전체 시각을 한 문장으로 읽어 줍니다.
- 각 열에서 고른 행은 **자기 열 안에서만** 화면 안으로 들어옵니다. `scrollIntoView`가 아니라 `scrollTop`을 씁니다 — 전자는 문서까지 올라가며 스크롤 가능한 모든 조상을 훑고, 팝업이 열리는 그 프레임에는 곧 움직일 행을 보여 주겠다고 페이지를 맨 위로 끌어올립니다.
- trigger는 담을 수 있는 가장 긴 시각의 너비로 붙잡혀 있습니다. 그 샘플들은 `aria-hidden`이고 generated content로 그려집니다.
- `name`이 있으면 hidden input이 값을 로컬 `HH:MM`으로 담습니다 — `<input type="time">`이 제출하는 모양이라, 그것을 이미 파싱하는 서버는 새 코드가 필요 없습니다.
