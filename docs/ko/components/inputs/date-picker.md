---
title: PlDatePicker
order: 12
---

# PlDatePicker

<p class="plass-lede">달력에서 하루를 고릅니다. trigger는 달력 글리프를 단 <code>PlTextField</code>의 껍데기 그대로라, 날짜 field와 그 옆의 field들이 하나의 물건으로 읽힙니다.</p>

<Demo src="date-picker/hero" :flutter="false" :min-height="200" />

::: fw react

```tsx
import { PlDatePicker } from 'plass-ui';

<PlDatePicker label="Departure" placeholder="Pick a day" minDate={new Date()} />;
```

:::

## Props

<PropsTable name="PlDatePicker" />

::: fw react

나머지 `<div>` 속성은 field 래퍼로 그대로 통과합니다. `color`는 위 표의 `color`와 겹쳐서, `defaultValue`는 DOM 속성이 아니라 값으로 쓰기 때문에, `children`은 달력이 곧 컴포넌트이기 때문에 제외했습니다.

:::

공유 축(`variant` `size` `color` `density` `elevation`)이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 날짜 라이브러리도, 번역 파일도 없습니다

picker들은 의존성 트리에 **아무것도** 더하지 않습니다. 하는 일은 열두 줄짜리 `Date` 연산이거나, 플랫폼이 이미 싣고 있고 어떤 번들 테이블보다 더 많은 언어의 월 이름을 아는 `Intl`입니다. `date-fns`를 조용히 끌어오는 — 더 나쁘게는 dayjs / luxon / Temporal 논쟁에서 소비자 대신 편을 드는 — 컴포넌트 라이브러리라면 자기 것이 아닌 결정을 내린 셈입니다.

로캘 이야기도 그게 전부입니다. import하고 등록할 언어별 모듈이 없습니다. `locale`은 BCP 47 태그이고, 거기서부터 `Intl`이 월 이름, 요일 이름, 오전/오후, 한 주가 시작하는 요일, 헤더 두 버튼의 순서, trigger가 날짜를 쓰는 방식을 전부 제공합니다. **열두 언어로 출시하는 프로젝트가 열한 개에 대해 내는 비용이 0입니다.**

남는 문자열은 picker 자신의 버튼에 적히는 것들 — "Today", "Previous month", "Choose a year" — 뿐입니다. 플랫폼이 그것들에 대해서는 아무 의견이 없기 때문입니다. 영어 기본값을 가진 `labels` 객체 하나입니다.

## 직접 입력할 수 없습니다

의도한 것입니다. 자유 텍스트에서 날짜를 파싱하는 일은 날짜 라이브러리 없이는 정직하게 할 수 없을 만큼 로캘에 의존하고, 어떤 브라우저에서는 `27/7/26`을 알아듣고 다음 브라우저에서는 못 알아듣는 field는 애초에 그런 척하지 않은 field보다 나쁩니다. trigger는 [`PlSelect`](./select)의 것과 똑같이 버튼이고, 답은 달력에서 나옵니다.

## Examples

### 헤더가 핵심입니다

한 번에 한 달씩만 넘기는 picker는 30년 전 생일을 180번의 클릭 너머에 둡니다. 그래서 월 이름과 연도가 각각 자기 그리드를 여는 **버튼** 입니다 — 열두 달, 그다음 한 번에 열두 해. 화면에 보이는 연도의 어느 달이든 두 번, 어느 해든 세 번입니다.

세 뷰는 너비도 _높이도_ 같아서, 뷰를 바꿔도 그것을 연 포인터 아래에서 팝업 크기가 변하지 않습니다. 날짜 그리드가 언제나 여섯 주인 것도 같은 이유입니다 — 네 줄이면 되는 2월과 여섯 줄이 필요한 3월 사이를 넘길 때마다 모든 칸이 움직일 테니까요.

### locale

월과 요일 이름, 오전/오후, 한 주가 시작하는 요일, 헤더 두 버튼의 순서, trigger 자신의 형식까지 전부 여기서 나옵니다. 한국어에서는 `2026년 7월`, 영어에서는 `July 2026` — 고정된 순서로 찍는 대신 두 버튼이 자리를 바꿉니다. 순서가 틀린 헤더는 그것이 틀린 바로 그 독자에게 고장으로 읽히기 때문입니다.

<Demo src="date-picker/locales" :flutter="false" :min-height="280">

<<< @/.vitepress/demos/date-picker/locales.tsx

</Demo>

### minDate · maxDate · shouldDisableDate

`minDate`와 `maxDate`는 **일 단위** 입니다. 거기 붙은 시각은 무시됩니다 — 그 경계는 어떤 날이 존재하는가에 대한 것이니까요. `shouldDisableDate`는 범위 안이지만 그래도 쓸 수 없는 날들을 위한 것입니다 — 주말, 공휴일, 이미 예약된 방.

막힌 날은 사라지지 않고 그리드에 남고, `disabled` 버튼이 아닙니다. 화살표 경로에서 자기 자리를 지키므로, 한 달을 화살표로 훑는 독자가 막힌 날마다 구멍에 빠지지 않습니다.

<Demo src="date-picker/bounds" :flutter="false" :min-height="220">

<<< @/.vitepress/demos/date-picker/bounds.tsx

</Demo>

### format

`Intl.DateTimeFormat`으로 그대로 넘어갑니다. `{ dateStyle: 'full' }`도 `{ year: 'numeric', month: 'long' }`도 됩니다.

무엇이라 쓰든 trigger는 담을 수 있는 가장 긴 날짜의 너비로 붙잡혀 있습니다 — 28일 뒤에 1일을 골라도, 그것을 고른 포인터 아래에서 field가 줄어들지 않습니다.

<Demo src="date-picker/format" :flutter="false" :min-height="240">

<<< @/.vitepress/demos/date-picker/format.tsx

</Demo>

### readOnly · disabled · error

`error`는 picker를 invalid로도 만들고, 그러면 색 계열 전체가 `danger`로 옮겨 갑니다 — 테두리와 ring과 메시지가 함께 넘어갑니다. `invalid`는 메시지 없이 같은 일을 합니다.

`readOnly` picker는 값과 포커스를 유지하되 **열리지 않습니다.** 그것이 담고 있는 건 읽을 것이고, 모든 칸이 죽어 있는 달력은 아무것도 없는 메뉴입니다.

<Demo src="date-picker/states" :flutter="false" :min-height="280">

<<< @/.vitepress/demos/date-picker/states.tsx

</Demo>

### Controlled

`value`를 `onValueChange`와 함께 주세요. 값은 로컬 자정의 `Date`이거나, 이미 갖고 있던 시각 그대로의 `Date`입니다. 새 날을 고르면 날짜만 바뀌고 시계는 그대로 남으므로, 시각도 함께 담는 필드에 묶인 picker가 날짜를 고칠 때마다 시각을 조용히 초기화하지 않습니다.

`null`은 controlled picker가 정당하게 가질 수 있는 값입니다. 비워진 picker가 그것입니다.

## Accessibility

- 그리드는 `gridcell`들로 이루어진 `role="grid"`이고 **roving tab stop이 하나** 라서, <kbd>Tab</kbd>은 칸 마흔둘을 걷는 대신 달력을 빠져나갑니다. ARIA date picker 관행이 설명하는 패턴입니다.
- <kbd>←</kbd> <kbd>→</kbd> <kbd>↑</kbd> <kbd>↓</kbd>는 하루와 한 주씩, <kbd>Home</kbd>과 <kbd>End</kbd>는 그 주의 양 끝으로, <kbd>PageUp</kbd> / <kbd>PageDown</kbd>은 한 달씩 — <kbd>Shift</kbd>와 함께면 한 해씩 — 움직입니다. 가장자리를 벗어나면 멈추는 대신 달력이 넘어갑니다.
- 막힌 날은 `disabled` 속성이 아니라 `aria-disabled`를 답니다. 그래서 화살표 경로에 남고, 사용할 수 없다고 읽힙니다.
- 모든 칸의 접근성 이름은 숫자 하나가 아니라 **날짜 전체** 입니다 — picker 자신의 로캘로, `Intl`에서 나온 `2026년 7월 27일 월요일`.
- 오늘은 `aria-current="date"`와 링이 아닌 점을 답니다. 링은 포커스 표시의 몫이고, 한 칸 안의 링 둘은 아무 말도 하지 않는 칸이기 때문입니다.
- 요일 헤더는 전체 이름을 라벨로 단 `columnheader`입니다. 눈으로 보는 독자가 "월"을 볼 때 스크린리더는 "월요일"을 듣습니다.
- `name`이 있으면 hidden input이 값을 **로컬** `YYYY-MM-DD`로 담습니다. `toISOString()`은 절대 아닙니다 — 서울의 picker라면 화면에 보이는 날의 전날을 제출하게 됩니다.
- trigger는 담을 수 있는 가장 긴 날짜의 너비로 붙잡혀 있습니다. 그 샘플들은 `aria-hidden`이고 generated content로 그려지므로, 더 읽히는 것도 페이지 내 검색에 걸리는 것도 없습니다.
- 팝업은 `<body>` 끝으로 portal되고 positioner가 `.plass-portal`을 답니다. CSS 리셋을 subtree에 한정한 호스트가 같은 리셋을 걸 수 있는 자리입니다.
